#!/usr/bin/env python
# Copyright (C) 2019 Andy Aschwanden

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
from braceexpand import braceexpand
import numpy as np
from netCDF4 import Dataset as NC
import os
import re

# set up the option parser
parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.description = "Generating scripts for warming experiments."
parser.add_argument("-v", "--variable", dest="variable", help="Variable to read in. Default=limnsw", default="limnsw")
parser.add_argument("OUTFILE", nargs=1, help="Ouput file (CSV)", default=None)
parser.add_argument("INFILES", nargs="*", help="Input file (netCDF)", default=None)
parser.add_argument("-t", "--time_step", type=int, help="Time step to extract", default=-1)

options = parser.parse_args()
variable = options.variable
outfile = options.OUTFILE[0]
# need to switch between the two solutions
infiles = list(braceexpand(options.INFILES[-1]))
infiles = options.INFILES
idx = options.time_step

ne = len(infiles)
data = np.zeros((2, 1))
k = 0
for infile in infiles:
    if os.path.isfile(infile):
        nc = NC(infile)
        if not variable in nc.variables:
            print("Variable {} not found, skipping".format(variable))
        else:
            id = int(re.search("id_(.+?)_", infile).group(1))
            val = float(nc.variables[variable][0] - nc.variables[variable][idx])
            units = nc.variables[variable].units
            if k == 0:
                data[:] = [[id], [val]]
            else:
                data = np.append(data, [[id], [val]], axis=1)
            k += 1

        nc.close()

np.savetxt(
    outfile,
    np.transpose(data),
    fmt=["%i", "%4.1f"],
    delimiter=",",
    header="id,{variable}({units})".format(variable=variable, units=units),
    comments="",
)
