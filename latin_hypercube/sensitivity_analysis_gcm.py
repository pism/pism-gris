#!/usr/bin/env python
# (c) 2018 Doug Brinkerhoff, adapted by Andy Aschwanden

from argparse import ArgumentParser
from SALib.analyze import delta
import numpy as np
import pandas
import os
from os.path import join, abspath, realpath, dirname

from multiprocessing import Pool

def analyze(filename):
    print("Processing {}".format(filename))
    # Load the response file
    response = pandas.read_table(filename, delimiter = ',', index_col=0, squeeze=True)

    try:
        id = [True for k in response.values if k < 800 and k is not str]
    except:
        print(filename)
        pass
    
    # Convert data frame into numpy array
    response_matrix = response.as_matrix()[id].astype(float).ravel()
    
    # Convert parameter values into numpy array
    params_matrix = params.as_matrix()[response.index[id]].astype(float)
    
    # Define a salib "problem"
    problem = {
        'num_vars': params.shape[1],                 # Number of parameters
        'names': params.columns.values,              # Parameter names
        'bounds': zip(params.min(),params.max())     # Parameter bounds
    }

    # Compute S1 sobol indices using the method of Plischke (2013, doi: https://doi.org/10.1016/j.ejor.2012.11.047) 
    # as implemented in SALib
    Si = delta.analyze(problem, params_matrix, response_matrix, num_resamples=100, print_to_console=False)

    # Save responses as text files
    outfile = join(output_dir, os.path.split(filename)[-1][:-4] + "_sobel.txt")
    np.savetxt(outfile, np.c_[params.columns.values, Si['S1'], Si['S1_conf']], delimiter=' ', header='Parameter S1 S1_conf', fmt=['%s','%.03f','%.03f'])



parser = ArgumentParser()
parser.description = "Calculate sobel indices"
parser.add_argument("FILE", nargs="*")
parser.add_argument(
    "-n", "--n_procs", dest="n", type=int, help="""number of cores/processors. default=4.""", default=4
)
parser.add_argument(
    "-s", "--samples_file", dest="samples_file", help="""number of cores/processors.""", default='./lhs_samples_gcm.csv'
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
params = pandas.read_table(samples_file, delimiter=',', index_col=0)

p = Pool(n)
p.map(analyze, files)



