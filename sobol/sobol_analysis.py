#!/usr/bin/env python
# (c) 2018-19 Doug Brinkerhoff, Andy Aschwanden

from argparse import ArgumentParser
from SALib.analyze import sobol
import numpy as np
import pandas
import os
from os.path import join, abspath, realpath, dirname
from scipy.interpolate import LinearNDInterpolator, NearestNDInterpolator
from multiprocessing import Pool
import pylab as plt
import re

rcp_col_dict = {"CTRL": "k", "85": "#990002", "45": "#5492CD", "26": "#003466"}
rcp_shade_col_dict = {"CTRL": "k", "85": "#F4A582", "45": "#92C5DE", "26": "#4393C3"}
rcp_dict = {"26": "RCP 2.6", "45": "RCP 4.5", "85": "RCP 8.5", "CTRL": "CTRL"}


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


def analyze(filename):
    print("Processing {}".format(filename))

    rcp = re.search("rcp_(.+?)_", filename).group(1)

    # Define a salib "problem"
    problem = {
        "num_vars": params.shape[1] - 1,  # Number of parameters
        "names": params.columns.values[1::],  # Parameter names
        "bounds": zip(params.min()[1::], params.max()[1::]),  # Parameter bounds
    }

    # Load the response file
    response = pandas.read_csv(filename, delimiter=",", squeeze=True)

    missing_ids = list(set(params["id"]).difference(response["id"]))

    if missing_ids:
        print("The following simulation ids are missing:\n   {}".format(missing_ids))

        params_missing_removed = params[~params["id"].isin(missing_ids)]
        params_missing = params[params["id"].isin(missing_ids)]

        # Note that the "1::" is needed because our first columns is the experiment id, which
        # is discarded because it is not a parameter

        f = NearestNDInterpolator(params_missing_removed.values[:, 1::], response.values[:, 1], rescale=True)
        data = f(*np.transpose(params_missing.values[:, 1::]))
        filled = pandas.DataFrame(data=np.transpose([missing_ids, data]), columns=response.columns)
        response_filled = response.append(filled)
        response_filled = response_filled.sort_values(by="id")

        response_matrix = response_filled[response_filled.columns[-1]].values

    else:
        response_matrix = response[response.columns[-1]].values

    make_sle = True
    if make_sle:
        kg2cmSLE = 1.0e-12 / 365 / 10.0

        response_matrix = response_matrix * kg2cmSLE

    outfile = join(
        output_dir, os.path.split(filename)[-1][:-4] + "_" + os.path.split(samples_file)[-1][:-4] + "_filled.csv"
    )
    np.savetxt(
        outfile,
        np.c_[params["id"].values, response_matrix],
        delimiter=",",
        comments="",
        header="id, sle(cm)",
        fmt=["%i", "%.03f"],
    )

    for k in range(1, len(params.columns)):
        fig = plt.figure()
        ax = fig.add_subplot(111)
        ax.plot(
            params[params.columns[k]].values, response_filled[response_filled.columns[-1]].values, ".", color="0.5"
        )
        ax.set_ylabel("Sea-level equivalent (cm)")
        ax.set_xlabel("{}".format(params.columns[k]))
        set_size(4.5, 3)
        fig.savefig(join(output_dir, os.path.split(filename)[-1][:-4] + "_{}.png".format(params.columns[k])))

    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.hist(
        response_matrix,
        bins=105,
        range=[response_matrix.min(), response_matrix.max()],
        density=True,
        color=rcp_col_dict[rcp],
    )
    p16, p50, p84 = np.percentile(response_matrix, [16, 50, 84])
    ax.errorbar(
        p50,
        0.06,
        xerr=[[p50 - p16], [p84 - p50]],
        fmt="o",
        capsize=3,
        capthick=0.5,
        color=rcp_col_dict[rcp],
        linewidth=0.75,
        markersize=3,
    )
    ax.set_xlabel("Sea-level equivalent (cm)")
    ax.set_ylabel("Density")
    set_size(4.5, 3)
    fig.savefig(join(output_dir, os.path.split(filename)[-1][:-4] + "_pdf.png"))

    # Compute S1 sobol indices using the method of Plischke (2013, doi: https://doi.org/10.1016/j.ejor.2012.11.047)
    # as implemented in SALib
    Si = sobol.analyze(problem, response_matrix, calc_second_order=False, num_resamples=100, print_to_console=False)

    # Save Sobol indices as text files
    outfile = join(
        output_dir, os.path.split(filename)[-1][:-4] + "_" + os.path.split(samples_file)[-1][:-4] + "_sobol.csv"
    )
    np.savetxt(
        outfile,
        np.c_[params.columns.values[1::], Si["S1"], Si["S1_conf"]],
        delimiter=" ",
        header="Parameter S1 S1_conf",
        fmt=["%s", "%.03f", "%.03f"],
        comments="",
    )


parser = ArgumentParser()
parser.description = "Calculate sobel indices"
parser.add_argument("FILE", nargs="*")
parser.add_argument(
    "-n", "--n_procs", dest="n", type=int, help="""number of cores/processors. default=4.""", default=4
)
parser.add_argument(
    "-s",
    "--samples_file",
    dest="samples_file",
    help="""number of cores/processors.""",
    default="./lhs_samples_gcm.csv",
)
parser.add_argument("--o_dir", dest="output_dir", help="output directory", default="test_dir")
options = parser.parse_args()
files = options.FILE
n = options.n
output_dir = abspath(options.output_dir)
samples_file = options.samples_file

if not os.path.isdir(output_dir):
    os.makedirs(output_dir)

# Use pandas to import parameter sample files
params = pandas.read_csv(samples_file, delimiter=",", squeeze=True)

if len(files) > 1:
    p = Pool(n)
    p.map(analyze, files)
else:
    analyze(files[0])
