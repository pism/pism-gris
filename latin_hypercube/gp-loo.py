#!/env/bin python

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter

from functools import partial

import GPy as gp

import matplotlib

import multiprocessing

multiprocessing.set_start_method("forkserver", force=True)
from multiprocessing import Pool

import numpy as np
import pandas as pd
import pylab as plt

import os


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


def gp_loo(kernel, rcp, year):

    """
    Leave One Out (LOO)
    """

    # Load respone file as Pandas DataFrame
    response_file = os.path.join(basedir, "dgmsl_rcp_{}_year_{}.csv").format(rcp, year)
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

    n = X.shape[1]

    kern = kernel(input_dim=n, ARD=True)

    with Pool(n_procs) as pool:
        pool.map(partial(gp_loo_mp, X=X, Y=Y, kern=kern, rcp=rcp, year=year), range(2))
        pool.close()


def gp_loo_mp(loo_idx, X, Y, kern, rcp, year):

    X_loo = np.delete(X, loo_idx, axis=0)
    Y_loo = np.delete(Y, loo_idx, axis=0)

    X_predict = X[loo_idx, :].reshape(1, -1)

    m = gp.models.GPRegression(X_loo, Y_loo, kern)
    m.optimize(messages=True)

    p = m.predict(X_predict)

    df = pd.DataFrame(data=np.asarray(p).reshape(1, -1), index=[loo_idx], columns=["prediction", "variance"])
    df.to_csv("gp_rcp_{}_{}_loo_{}.csv".format(rcp, year, loo_idx), index_label="LOO")


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
    parser.add_argument("--year", help="Simulation start year", type=int, default=2100)
    parser.add_argument("--rcp", help="RCP scenario. Default=85", default="85")
    parser.add_argument(
        "-s",
        "--samples_file",
        dest="samples_file",
        help="File that has all combinations for ensemble study",
        default="2018_09_les/lhs_samples_gcm.csv",
    )
    parser.add_argument("INDIR", nargs=1, help="Base directory", default=None)

    options = parser.parse_args()
    basedir = options.INDIR[0]
    n_procs = options.n_procs
    rcp = options.rcp
    year = options.year

    # Load Samples file as Pandas DataFrame
    samples_file = options.samples_file
    samples = pd.read_csv(samples_file, delimiter=",", squeeze=True, skipinitialspace=True)

    gp_loo(gp.kern.Exponential, rcp, 2100)
