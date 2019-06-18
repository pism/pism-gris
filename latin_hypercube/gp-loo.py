#!/env/bin python

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter

from functools import partial

import GPy as gp

import matplotlib

import multiprocessing

multiprocessing.set_start_method("forkserver", force=True)
from multiprocessing import Pool

from netCDF4 import Dataset as NC
import numpy as np
import pandas as pd
import pylab as plt

from SALib.sample import saltelli
from scipy.stats.distributions import truncnorm, gamma, uniform, randint


def set_size(w, h, ax=None):
    """ w, h: width, height in inches """

    if not ax:
        ax = plt.gca()
    l = ax.figure.subplotpars.left
    r = ax.figure.subplotpars.right
    t = ax.figure.subplotpars.top
    b = ax.figure.subplotpars.bottom
    figw = float(w) / (r - l)
    figh = float(h) / (t - b)
    ax.figure.set_size_inches(figw, figh)


def draw_samples(n_samples=1000):

    """
    Draw n_samples Sobol sequences using the Saltelli method
    """

    distributions = {
        "GCM": randint(0, 4),
        "FICE": truncnorm(-4 / 4.0, 4.0 / 4, loc=8, scale=4),
        "FSNOW": truncnorm(-4.1 / 3, 4.1 / 3, loc=4.1, scale=1.5),
        "PRS": uniform(loc=5, scale=2),
        "RFR": truncnorm(-0.4 / 0.3, 0.4 / 0.3, loc=0.5, scale=0.2),
        "OCM": randint(-1, 2),
        "OCS": randint(-1, 2),
        "TCT": randint(-1, 2),
        "VCM": truncnorm(-0.35 / 0.2, 0.35 / 0.2, loc=0.4, scale=0.2),
        "PPQ": truncnorm(-0.35 / 0.2, 0.35 / 0.2, loc=0.6, scale=0.2),
        "SIAE": gamma(1.5, scale=0.8, loc=1),
    }

    # Generate the Sobol sequence samples with uniform distributions

    # Names of all the variables
    keys = [x for x in distributions.keys()]

    # Describe the Problem
    problem = {"num_vars": len(keys), "names": keys, "bounds": [[0, 1]] * len(keys)}

    # Generate uniform samples (i.e. one unit hypercube)
    unif_sample = saltelli.sample(problem, n_samples, calc_second_order=False)

    # To hold the transformed variables
    dist_sample = np.zeros_like(unif_sample)

    # Now transform the unit hypercube to the prescribed distributions
    # For each variable, transform with the inverse of the CDF (inv(CDF)=ppf)
    for i, key in enumerate(keys):
        dist_sample[:, i] = distributions[key].ppf(unif_sample[:, i])

    # Save to CSV file using Pandas DataFrame and to_csv method
    header = keys
    # Convert to Pandas dataframe, append column headers, output as csv
    return pd.DataFrame(data=dist_sample, columns=header)


def gp_emulate(year, rcp, samples):

    # Load respone file as Pandas DataFrame
    response_file = "2018_09_les/dgmsl_csv/dgmsl_rcp_{}_{}.csv".format(rcp, year)
    response = pd.read_csv(response_file, delimiter=",", squeeze=True, skipinitialspace=True)
    # It is possible that not all ensemble simulations succeeded and returned a value
    # so we much search for missing response values
    missing_ids = list(set(samples["id"]).difference(response["id"]))
    Y = -response[response.columns[-1]].values.reshape(1, -1).T
    if missing_ids:
        print("The following simulation ids are missing:\n   {}".format(missing_ids))
        # and remove the missing samples
        samples_missing_removed = samples[~samples["id"].isin(missing_ids)]
        X = samples_missing_removed.values[:, 1::]

    else:
        X = samples.values[:, 1::]

    # Dimension n of kernel
    n = X.shape[1]

    # We choose a kernel
    k = gp.kern.Exponential(input_dim=n, ARD=True)
1
    m = gp.models.GPRegression(X, Y, k)
    m.optimize(messages=True)

    X_new = draw_samples(10000)

    p = m.predict(X_new.values)

    pctls_gp = np.percentile(p[0], m_percentiles)
    pctls = np.percentile(Y, m_percentiles)
    pctls_df = pd.DataFrame(data=np.vstack([pctls, pctls_gp]).T, index=[5, 16, 50, 84, 95], columns=["lhs", "gp"])
    pctls_df.to_csv("gp_pctl_rcp_{}_{}.csv".format(rcp, year), index_label="percentile")

    return Y


def gp_loo(kern, rcp, year):

    """
    Leave One Out (LOO)
    """

    # Load respone file as Pandas DataFrame
    response_file = "2018_09_les/dgmsl_csv/dgmsl_rcp_{}_{}.csv".format(rcp, year)
    response = pd.read_csv(response_file, delimiter=",", squeeze=True, skipinitialspace=True)
    # It is possible that not all ensemble simulations succeeded and returned a value
    # so we much search for missing response values
    missing_ids = list(set(samples["id"]).difference(response["id"]))

    Y = -response[response.columns[-1]].values.reshape(1, -1).T
    if missing_ids:
        print("The following simulation ids are missing:\n   {}".format(missing_ids))
        # and remove the missing samples
        samples_missing_removed = samples[~samples["id"].isin(missing_ids)]
        X = samples_missing_removed.values[:, 1::]

    else:
        X = samples.values[:, 1::]

    pool = Pool(n_procs)

    n = X.shape[1]
    kern = gp.kern.Exponential(input_dim=n, ARD=True)
    pool.map(partial(gp_loo_mp, X=X, Y=Y, kern=kern, rcp=rcp, year=year), range(2))


def gp_loo_mp(loo_idx, X, Y, kern, rcp, year):

    X_loo = np.delete(X, loo_idx, axis=0)
    Y_loo = np.delete(Y, loo_idx, axis=0)

    X_predict = X[loo_idx, :].reshape(1, -1)

    m = gp.models.GPRegression(X_loo, Y_loo, kern)
    m.optimize(messages=True)

    p = m.predict(X_predict)

    df = pd.DataFrame(data=np.asarray(p).reshape(1, -1), index=[loo_idx], columns=["prediction", "variance"])
    df.to_csv("gp_rcp_{}_{}_loo_{}.csv".format(rcp, year, loo_idx), index_label="LOO")


# pctls_df = pd.DataFrame(data=np.vstack([pctls, pctls_gp]).T, index=[5, 16, 50, 84, 95], columns=["lhs", "gp"])
# pctls_df.to_csv("gp_pctl_rcp_{}_{}.csv".format(rcp, year), index_label="percentile")


m_percentiles = [5, 16, 50, 84, 95]
rcp_col_dict = {"CTRL": "k", "85": "#990002", "45": "#5492CD", "26": "#003466"}
rcp_shade_col_dict = {"CTRL": "k", "85": "#F4A582", "45": "#92C5DE", "26": "#4393C3"}


if __name__ == "__main__":

    parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
    parser.description = "Gaussian Process Emulators."
    parser.add_argument(
        "-n", "--n_procs", dest="n_procs", type=int, help="""number of cores/processors. default=4.""", default=4
    )
    parser.add_argument("--start", help="Simulation start year", type=int, default=2009)
    parser.add_argument("--end", help="Simulation end year", type=int, default=2300)
    parser.add_argument("--rcp", help="RCP scenario. Default=85", default="85")
    parser.add_argument(
        "-s",
        "--samples_file",
        dest="samples_file",
        help="File that has all combinations for ensemble study",
        default="2018_09_les/lhs_samples_gcm.csv",
    )

    options = parser.parse_args()
    n_procs = options.n_procs
    start_year = options.start
    end_year = options.end
    duration = end_year - start_year
    rcp = options.rcp

    # Load Samples file as Pandas DataFrame
    samples_file = options.samples_file
    samples = pd.read_csv(samples_file, delimiter=",", squeeze=True, skipinitialspace=True)

    pool = Pool(n_procs)
    pool.map(partial(gp_emulate, rcp=rcp, samples=samples), range(duration))
    pool.close()

    # gp_loo(gp.models.GPRegression, rcp, 92)

    date = np.arange(0, duration) + start_year
    fig = plt.figure()
    ax = fig.add_subplot(111)

    pctls_gp, pctls_lhs = [], []
    for idx, pctl in enumerate(m_percentiles):
        pctls_lhs.append([])
        pctls_gp.append([])
        for year in range(len(date)):
            df = pd.read_csv("gp_pctl_rcp_{}_{}.csv".format(rcp, year))
            pctls_gp[idx].append(df[df["percentile"] == pctl]["gp"].values[0])
            pctls_lhs[idx].append(df[df["percentile"] == pctl]["lhs"].values[0])
    ax.fill_between(date, pctls_gp[0], pctls_gp[4], color=rcp_col_dict[rcp], linewidth=0.3, linestyle="-", alpha=0.1)
    ax.fill_between(date, pctls_gp[1], pctls_gp[3], color=rcp_col_dict[rcp], linewidth=0.3, linestyle="-", alpha=0.3)
    ax.plot(date, np.asarray(pctls_gp).T, color=rcp_col_dict[rcp], linewidth=0.3, linestyle="-")
    ax.plot(date, np.asarray(pctls_lhs).T, color=rcp_col_dict[rcp], linewidth=0.3, linestyle=":")
    ax.set_ylabel("Sea-level equivalent (cm)")
    ax.set_xlabel("Year")
    ax.set_xlim(2008, 2300)
    set_size(3.2, 1)
    fig.savefig("gp_rcp_{}.png".format(rcp), bbox_inches="tight", dpi=600)

    Y = gp_emulate(2100, rcp, samples)
    # fig = plt.figure()
    # ax = fig.add_subplot(111)
    # ax.hist(Y, bins=np.arange(int(p[0].min()), int(p[0].max()), 1.0), density=True, color=rcp_col_dict[rcp], alpha=0.4)
    # ax.hist(
    #     p[0],
    #     bins=np.arange(int(p[0].min()), int(p[0].max()), 1.0),
    #     histtype="step",
    #     linewidth=0.6,
    #     density=True,
    #     color=rcp_col_dict[rcp],
    #     alpha=1.0,
    # )
    # for pctl in [5, 16, 50, 84, 95]:
    #     ax.axvline(np.percentile(p[0], pctl), color=rcp_col_dict[rcp], linewidth=0.4)
    # for pctl in [5, 16, 50, 84, 95]:
    #     ax.axvline(np.percentile(Y, pctl), color=rcp_col_dict[rcp], linewidth=0.4, linestyle=":")
    # ax.set_xlabel("Sea-level equivalent (cm)")
    # ax.set_ylabel("Density")
    # set_size(3.2, 1.2)
    # fig.savefig("gp_rcp_{}_hist_2100.png".format(rcp), bbox_inches="tight", dpi=600)

    # # Extract percentiles
    # pctl5_gp = [x[0] for x in pctls_gp]
    # pctl16_gp = [x[1] for x in pctls_gp]
    # pctl50_gp = [x[2] for x in pctls_gp]
    # pctl84_gp = [x[3] for x in pctls_gp]
    # pctl95_gp = [x[4] for x in pctls_gp]

    # lw = 0.2
    # date = np.arange(0, 92) + 2008
    # fig = plt.figure()
    # ax = fig.add_subplot(111)
    # ax.fill_between(date, pctl5_gp, pctl95_gp, color=rcp_col_dict[rcp], linewidth=lw, alpha=0.1)
    # ax.fill_between(date, pctl16_gp, pctl84_gp, color=rcp_col_dict[rcp], linewidth=lw, alpha=0.2)
    # ax.plot(date, pctls, color=rcp_col_dict[rcp], linewidth=0.3, linestyle=":")
    # ax.plot(date, pctls_gp, color=rcp_col_dict[rcp], linewidth=0.3, linestyle="-")
    # ax.plot(date, pctl50, color=rcp_col_dict[rcp], linewidth=0.6, linestyle=":")
    # ax.plot(date, pctl50_gp, color=rcp_col_dict[rcp], linewidth=0.6, linestyle="-")
    # ax.set_ylabel("Sea-level equivalent (cm)")
    # ax.set_xlabel("Year")
    # ax.set_xlim(2008, 2100)
    # set_size(3.2, 1)
    # fig.savefig("gp_rcp_{}.png".format(rcp), bbox_inches="tight", dpi=600)

    # p = []
    # s = []
    # for idx in range(6):

    #     X_loo = np.delete(X, idx, axis=0)
    #     Y_loo = np.delete(Y, idx, axis=0)

    #     X_predict = X[idx, :].reshape(1, -1)

    #     k = gp.kern.Exponential(input_dim=n, ARD=True)

    #     m = gp.models.GPRegression(X_loo, Y_loo, k)
    #     m.optimize(messages=True)

    #     p.append(m.predict(X_predict))

    #     s.append((Y[idx] - p[0][idx]) ** 2 / p[1][idx] ** 2)
