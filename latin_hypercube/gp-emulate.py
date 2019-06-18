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

import re
import os


def emulate(year, X_new, samples_file, metadata):

    rcp = metadata["rcp"]
    basedir = metadata["basedir"]

    response_file = os.path.join(basedir, "dgmsl_rcp_{}_year_{}.csv").format(rcp, year)

    print("Processing {}".format(response_file))

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

    # We choose a kernel
    k = gp.kern.Exponential(input_dim=n, ARD=True)

    m = gp.models.GPRegression(X, Y, k)
    m.optimize(messages=True)

    p = m.predict(X_new.values)

    pctls_gp = np.percentile(p[0], m_percentiles)
    pctls_lhs = np.percentile(Y, m_percentiles)
    gp_df = pd.DataFrame(data=pctls_gp, index=[5, 16, 50, 84, 95], columns=["gp"])
    lhs_df = pd.DataFrame(data=pctls_lhs, index=[5, 16, 50, 84, 95], columns=["lhs"])

    return {"year": year, "gp": gp_df, "lhs": lhs_df}


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
    parser.description = "Gaussian Process Emulators."
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

    X_new = draw_samples(n_samples)

    metadata = {"rcp": rcp, "basedir": basedir}
    with Pool(n_procs) as pool:
        results = pool.map(
            partial(emulate, samples_file=samples_file, X_new=X_new, metadata=metadata),
            range(start_year, end_year + 1),
        )
        pool.close()

        print(results)

    gp = dict()
    gp["years"] = np.asarray([item["year"] for item in results])
    lhs = dict()
    lhs["years"] = np.asarray([item["year"] for item in results])

    for idx, pctl in enumerate(m_percentiles):
        gp[pctl] = np.squeeze(np.asarray([item["gp"].values[idx, :] for item in results]).reshape(1, -1))
        lhs[pctl] = np.squeeze(np.asarray([item["lhs"].values[idx, :] for item in results]).reshape(1, -1))
