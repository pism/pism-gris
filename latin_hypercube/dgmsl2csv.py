#!/usr/bin/env python
# Copyright (C) 2018 Andy Aschwanden

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
import numpy as np
from netCDF4 import Dataset as NC
import re

# set up the option parser
parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.description = "Generating scripts for warming experiments."
parser.add_argument("-v", "--variable", dest="variable", help="Variable to read in. Default=limnsw", default="limnsw")
parser.add_argument("OUTFILE", nargs=1, help="Ouput file (CSV)", default=None)
parser.add_argument("INFILES", nargs="*", help="Input file (netCDF)", default=None)
parser.add_argument("-y", "--year", type=int, help="Year to extract", default=3000)

options = parser.parse_args()
variable = options.variable
outfile = options.OUTFILE[0]
infiles = options.INFILES
idx = options.year - 2008

ne = len(infiles)
data = np.zeros((2, ne))
for k, infile in enumerate(infiles):
    nc = NC(infile)
    if not variable in nc.variables:
        print("Variable {} not found, skipping".format(variable))
    else:
        id = re.search("id_(.+?)_", infile).group(1)
        data[0, k] = id
        val = nc.variables[variable][idx]
        data[1, k] = val
        if val > 800:
            print(id)

    nc.close()

np.savetxt(outfile, np.transpose(data), fmt=["%i", "%4.0f"], delimiter=",", header="run,dgmsl(cm)")
