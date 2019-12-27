#!/usr/bin/env python
# Copyright (C) 2019 Andy Aschwanden

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
from braceexpand import braceexpand
import numpy as np
from netCDF4 import Dataset as NC
import os
import re
from glob import glob

# set up the option parser
parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.description = "Generating scripts for warming experiments."
parser.add_argument("-v", "--variable", dest="variable", help="Variable to read in. Default=limnsw", default="limnsw")
parser.add_argument("OUTFILE", nargs=1, help="Ouput file (CSV)", default=None)
parser.add_argument("--indir", help="Base directory", default="2019_02_salt")
parser.add_argument("-t", "--time_step", type=int, help="Time step to extract", default=92)
parser.add_argument("-s", "--no_samples", dest="no_samples", type=int, help="No of Saltelli samples", default=400)

options = parser.parse_args()
variable = options.variable
outfile = options.OUTFILE[0]
no_samples = options.no_samples
idx = options.time_step

data = np.zeros((2, 1))
k = 0
saltelli_multiplier = 13
for m_id in range(0, no_samples * saltelli_multiplier):
    infile = "{}/dgmsl/dgmsl_ts_gris_g1800m_v3a_rcp_45_id_{}_0_100.nc".format(options.indir, m_id)
    if os.path.isfile(infile):
        nc = NC(infile)
        print(infile)
        if not variable in nc.variables:
            print("Variable {} not found, skipping".format(variable))
        else:
            id = int(re.search("id_(.+?)_", infile).group(1))
            print(nc.variables[variable][92])
            val = nc.variables[variable][idx]
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
