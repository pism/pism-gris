#!/env/bin python

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
from dateutil import rrule
from dateutil.parser import parse
from datetime import datetime

from functools import partial

import GPy as gp

import matplotlib

import multiprocessing

multiprocessing.set_start_method("forkserver", force=True)
from multiprocessing import Pool

from netCDF4 import Dataset as NC
from cftime import utime

import numpy as np
import pandas as pd
import pylab as plt

from SALib.sample import saltelli
from scipy.stats.distributions import truncnorm, gamma, uniform, randint

import re
import os


def create_netcdf(
    filename,
    start_date="2008-1-1",
    end_date="2300-1-1",
    ref_unit="days",
    ref_date="2008-1-1",
    periodicity="yearly",
    interval_type="mid",
):

    nc = NC(filename, "w")

    time_units = "%s since %s" % (ref_unit, ref_date)
    # currently PISM only supports the gregorian standard calendar
    # once this changes, calendar should become a command-line option
    time_calendar = "standard"

    cdftime = utime(time_units, time_calendar)

    # create a dictionary so that we can supply the periodicity as a
    # command-line argument.
    pdict = {}
    pdict["SECONDLY"] = rrule.SECONDLY
    pdict["MINUTELY"] = rrule.MINUTELY
    pdict["HOURLY"] = rrule.HOURLY
    pdict["DAILY"] = rrule.DAILY
    pdict["WEEKLY"] = rrule.WEEKLY
    pdict["MONTHLY"] = rrule.MONTHLY
    pdict["YEARLY"] = rrule.YEARLY
    prule = pdict[periodicity.upper()]

    # reference date from command-line argument
    r = time_units.split(" ")[2].split("-")
    refdate = datetime(int(r[0]), int(r[1]), int(r[2]))

    # create list with dates from start_date until end_date with
    # periodicity prule.
    bnds_datelist = list(rrule.rrule(prule, dtstart=parse(start_date), until=parse(end_date)))

    # calculate the days since refdate, including refdate, with time being the
    bnds_interval_since_refdate = cdftime.date2num(bnds_datelist)
    if interval_type == "mid":
        # mid-point value:
        # time[n] = (bnds[n] + bnds[n+1]) / 2
        time_interval_since_refdate = bnds_interval_since_refdate[0:-1] + np.diff(bnds_interval_since_refdate) / 2
    elif interval_type == "start":
        time_interval_since_refdate = bnds_interval_since_refdate[:-1]
    else:
        time_interval_since_refdate = bnds_interval_since_refdate[1:]

    # create a new dimension for bounds only if it does not yet exist
    time_dim = "time"
    if time_dim not in list(nc.dimensions.keys()):
        nc.createDimension(time_dim)

    # create a new dimension for bounds only if it does not yet exist
    bnds_dim = "nb2"
    if bnds_dim not in list(nc.dimensions.keys()):
        nc.createDimension(bnds_dim, 2)

    # variable names consistent with PISM
    time_var_name = "time"
    bnds_var_name = "time_bnds"

    # create time variable
    time_var = nc.createVariable(time_var_name, "d", dimensions=(time_dim))
    time_var[:] = time_interval_since_refdate
    time_var.bounds = bnds_var_name
    time_var.units = time_units
    time_var.calendar = time_calendar
    time_var.standard_name = time_var_name
    time_var.axis = "T"

    # create time bounds variable
    time_bnds_var = nc.createVariable(bnds_var_name, "d", dimensions=(time_dim, bnds_dim))
    time_bnds_var[:, 0] = bnds_interval_since_refdate[0:-1]
    time_bnds_var[:, 1] = bnds_interval_since_refdate[1::]

    nc.Conventions = "CF 1.5"
    nc.close()


def save_to_netcdf(filename, data, ens):
    """ Save results to a netcdf file"""

    time = np.asarray([item["year"] for item in data])

    start_year, end_year = time[0], time[-1]
    create_netcdf(filename, start_date="{}-1-1".format(start_year), end_date="{}-1-1".format(end_year))

    ne = len(data[0]["Y_gp"][0])

    nc = NC(filename, "a")
    for idx, varname in enumerate(("limnsw", "limnsw_variance")):
        var = nc.createVariable(varname, "d", dimensions=("time"), zlib=True, complevel=3)
        var.units = "kg"
        var[:] = np.squeeze(np.asarray([x["Y_gp"][idx][ens] for x in data]))

    nc.close()


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


def emulate(year, X_new, samples_file, metadata):

    rcp = metadata["rcp"]
    basedir = metadata["basedir"]

    response_file = os.path.join(basedir, "dgmsl_rcp_{}_year_{}.csv").format(rcp, year)

    print("\nProcessing {}".format(response_file))

    # Load Samples file as Pandas DataFrame
    samples = pd.read_csv(samples_file, delimiter=",", squeeze=True, skipinitialspace=True)

    # Load Respone file as Pandas DataFrame
    response = pd.read_csv(response_file, delimiter=",", squeeze=True, skipinitialspace=True)
    # It is possible that not all ensemble simulations succeeded and returned a value
    # so we much search for missing response values
    missing_ids = list(set(samples["id"]).difference(response["id"]))
    Y = response[response.columns[-1]].values.reshape(1, -1).T
    if missing_ids:
        print("The following simulation ids are missing:\n   {}".format(missing_ids))
        # and remove the missing samples
        samples_missing_removed = samples[~samples["id"].isin(missing_ids)]
        X = samples_missing_removed.values[:, 1::]

    else:
        X = samples.values[:, 1::]

    # Dimension n of kernel
    n = X.shape[1]

    # We choose an exponential kernel
    kern = gp.kern.Exponential(input_dim=n, ARD=True)

    m = gp.models.GPRegression(X, Y, kern)
    m.optimize(messages=True)

    p = m.predict(X_new.values)

    pctls_gp = np.percentile(p[0], m_percentiles)
    pctls_lhs = np.percentile(Y, m_percentiles)
    gp_df = pd.DataFrame(data=pctls_gp, index=[5, 16, 50, 84, 95], columns=["gp"])
    lhs_df = pd.DataFrame(data=pctls_lhs, index=[5, 16, 50, 84, 95], columns=["lhs"])

    return {"year": year, "gp": gp_df, "lhs": lhs_df, "Y_gp": p, "Y_lhs": Y}


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


m_percentiles = [5, 16, 50, 84, 95]
rcp_col_dict = {"CTRL": "k", "85": "#990002", "45": "#5492CD", "26": "#003466"}
rcp_shade_col_dict = {"CTRL": "k", "85": "#F4A582", "45": "#92C5DE", "26": "#4393C3"}


if __name__ == "__main__":

    __spec__ = None

    parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
    parser.description = "Gaussian Process Emulator."
    parser.add_argument(
        "-n", "--n_procs", dest="n_procs", type=int, help="""number of cores/processors. default=4.""", default=4
    )
    parser.add_argument("--n_samples", dest="n_samples", type=int, help="""Number of new samples.""", default=10000)
    parser.add_argument(
        "-a", "--start_year", dest="start_year", type=int, help="""Start year. default=2009.""", default=2009
    )
    parser.add_argument(
        "-e", "--end_year", dest="end_year", type=int, help="""End year. default=2300.""", default=2300
    )
    parser.add_argument("--rcp", dest="rcp", help="""RCP. Default=85.""", default="85")
    parser.add_argument(
        "-s",
        "--samples_file",
        dest="samples_file",
        help="File that has all combinations for ensemble study",
        default="2018_09_les/lhs_samples_gcm.csv",
    )
    parser.add_argument("INDIR", nargs=1, help="Base directory", default=None)

    options = parser.parse_args()
    n_procs = options.n_procs
    n_samples = options.n_samples
    start_year = options.start_year
    end_year = options.end_year
    rcp = options.rcp

    samples_file = options.samples_file
    basedir = options.INDIR[0]
    odir = os.path.join(basedir, "gp")

    if not os.path.isdir(odir):
        os.makedirs(odir)

    X_new = draw_samples(n_samples)

    metadata = {"rcp": rcp, "basedir": basedir}
    with Pool(n_procs) as pool:
        results = pool.map(
            partial(emulate, samples_file=samples_file, X_new=X_new, metadata=metadata),
            range(start_year, end_year + 1),
        )
        pool.close()

    # for ens in range(n_samples):
    #     filename = os.path.join(odir, "gp_{}_{}.nc".format(ens, n_samples))
    #     save_to_netcdf(filename, results, ens)

    gp = dict()
    gp["years"] = np.asarray([item["year"] for item in results])
    lhs = dict()
    lhs["years"] = np.asarray([item["year"] for item in results])

    for idx, pctl in enumerate(m_percentiles):
        gp[pctl] = np.squeeze(np.asarray([item["gp"].values[idx, :] for item in results]).reshape(1, -1))
        lhs[pctl] = np.squeeze(np.asarray([item["lhs"].values[idx, :] for item in results]).reshape(1, -1))

    # Because the above analysis can take some time,
    # here we want to take the results and save it in a file instead of making a plot right now.

    fontsize = 6
    lw = 0.65

    # params = {
    #     "backend": "ps",
    #     "axes.linewidth": 0.25,
    #     "lines.linewidth": lw,
    #     "axes.labelsize": fontsize,
    #     "font.size": fontsize,
    #     "xtick.direction": "in",
    #     "xtick.labelsize": fontsize,
    #     "xtick.major.size": 2.5,
    #     "xtick.major.width": 0.25,
    #     "ytick.direction": "in",
    #     "ytick.labelsize": fontsize,
    #     "ytick.major.size": 2.5,
    #     "ytick.major.width": 0.25,
    #     "legend.fontsize": fontsize,
    #     "font.size": fontsize,
    # }

    # plt.rcParams.update(params)

    # lw = 0.3
    # fig = plt.figure()
    # ax = fig.add_subplot(111)
    # ax.fill_between(gp["years"], gp[5], gp[95], color=rcp_col_dict[rcp], linewidth=lw, alpha=0.2)
    # ax.fill_between(gp["years"], gp[16], gp[84], color=rcp_col_dict[rcp], linewidth=lw, alpha=0.2)
    # for pctl in m_percentiles:
    #     if pctl != 5:
    #         ax.plot(lhs["years"], lhs[pctl], color=rcp_col_dict[rcp], linewidth=0.3, linestyle=":")
    #     else:
    #         ax.plot(lhs["years"], lhs[pctl], color=rcp_col_dict[rcp], linewidth=0.3, linestyle=":", label="AS19")
    # for pctl in m_percentiles:
    #     ax.annotate("{}".format(pctl), (2300, gp[pctl][-1]), size=5)
    #     if pctl != 5:
    #         ax.plot(gp["years"], gp[pctl], color=rcp_col_dict[rcp], linewidth=0.3, linestyle="-")
    #     else:
    #         ax.plot(gp["years"], gp[pctl], color=rcp_col_dict[rcp], linewidth=0.3, linestyle="-", label="GP")
    # ax.annotate("50", (2320, gp[50][-1]))
    # legend = plt.legend()
    # legend.get_frame().set_linewidth(0.0)
    # legend.get_frame().set_alpha(0.0)
    # ax.set_ylabel("Sea-level equivalent\n(cm)")
    # ax.set_xlabel("Year")
    # ax.set_xlim(lhs["years"].min(), lhs["years"].max())
    # set_size(3.2, 1.2)
    # fig.savefig("gp_rcp_{}.pdf".format(rcp), bbox_inches="tight", dpi=600)

    # m_year = 2100
    # Y_gp = results[91]["Y_gp"][0]
    # Y_lhs = results[91]["Y_lhs"]
    # fig = plt.figure()
    # ax = fig.add_subplot(111)
    # plt.title("Probability Density Year 2100")
    # ax.hist(
    #     Y_lhs, bins=np.arange(int(Y_gp.min()), int(Y_gp.max()), 1), density=True, color=rcp_col_dict[rcp], alpha=0.4
    # )
    # ax.hist(
    #     Y_gp,
    #     bins=np.arange(int(Y_gp.min()), int(Y_gp.max()), 1),
    #     histtype="step",
    #     linewidth=0.6,
    #     density=True,
    #     color=rcp_col_dict[rcp],
    #     alpha=1.0,
    # )
    # # for pctl in m_percentiles:
    # #     ax.axvline(gp[pctl][91], linewidth=0.3, linestyle="-")
    # #     ax.axvline(lhs[pctl][91], linewidth=0.3, linestyle=":")
    # ax.set_xlabel("Sea-level equivalent (cm)")
    # ax.set_ylabel("Density")
    # set_size(3.2, 1.2)
    # fig.savefig("gp_rcp_{}_hist_{}.pdf".format(rcp, m_year), bbox_inches="tight", dpi=600)
