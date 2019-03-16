#!/usr/bin/env python
# (c) 2018-19 Doug Brinkerhoff, Andy Aschwanden

from argparse import ArgumentParser
from SALib.analyze import sobol
import numpy as np
import pandas
import os
from os.path import join, abspath, realpath, dirname
from scipy.interpolate import NearestNDInterpolator
from multiprocessing import Pool


def analyze(filename):
    print("Processing {}".format(filename))
    # Load the response file
    response = pandas.read_csv(filename, delimiter=",", squeeze=True)

    missing_ids = list(set(params["id"]).difference(response["id"]))
    print("The following simulation ids are missing:\n   {}".format(["{}\n".format(x) for x in missing_ids]))

    params_missing_removed = params[~params["id"].isin(missing_ids)]
    params_missing = params[params["id"].isin(missing_ids)]

    # Note that the "1::" is needed because our first columns is the experiment id, which
    # is discarded because it is not a parameter

    f = NearestNDInterpolator(params_missing_removed.values[:, 1::], response.values[:, 1], rescale=True)
    data = f(*np.transpose(params_missing.values[:, 1::]))

    filled = pandas.DataFrame(data=np.transpose([missing_ids, data]), columns=response.columns)
    response_filled = response.append(filled)
    response_filled = response_filled.sort_values(by="id")

    # Define a salib "problem"
    problem = {
        "num_vars": params.shape[1] - 1,  # Number of parameters
        "names": params.columns.values[1::],  # Parameter names
        "bounds": zip(params.min()[1::], params.max()[1::]),  # Parameter bounds
    }
    response_matrix = response_filled[response_filled.columns[-1]].values

    # Compute S1 sobol indices using the method of Plischke (2013, doi: https://doi.org/10.1016/j.ejor.2012.11.047)
    # as implemented in SALib
    Si = sobol.analyze(problem, response_matrix, calc_second_order=False, num_resamples=100, print_to_console=False)

    print(Si)

    # Save responses as text files
    outfile = join(output_dir, os.path.split(filename)[-1][:-4] + "_sobol.txt")
    np.savetxt(
        outfile,
        np.c_[params.columns.values[1::], Si["S1"], Si["S1_conf"]],
        delimiter=" ",
        header="Parameter S1 S1_conf",
        fmt=["%s", "%.03f", "%.03f"],
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
