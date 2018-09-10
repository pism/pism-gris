#!/usr/bin/env python

# Copyright (C) 2018 Andy Aschwanden

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
import numpy as np
from netCDF4 import Dataset as NC
import re

# set up the option parser
parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.description = "Generating scripts for warming experiments."
parser.add_argument("OUTFILE", nargs=1,
                    help="Ouput file (CSV)", default=None)
parser.add_argument("INFILES", nargs='*',
                    help="Input file (netCDF)", default=None)

options = parser.parse_args()
outfile = options.OUTFILE[0]
infiles = options.INFILES

ne = len(infiles)
data = np.zeros((2, ne))
for k, infile in enumerate(infiles):
    nc = NC(infile)
    id = re.search('id_(.+?)_', infile).group(1)
    data[0, k] = id
    dgmsl = nc.variables['limnsw'][-1]    
    data[1, k] = dgmsl
    nc.close()

np.savetxt(outfile, np.transpose(data), fmt=['%i', '%4.0f'], delimiter=',', header='run,dgmsl(cm)')
