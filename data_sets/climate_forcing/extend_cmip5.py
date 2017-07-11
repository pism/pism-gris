#!/usr/bin/env python
# Copyright (C) 2015 Andy Aschwanden

import numpy as np
from netCDF4 import Dataset as NC

from netcdftime import utime
import dateutil
import numpy as np
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter


# Set up the option parser
parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.description = "Script creates ocean forcing."
parser.add_argument("FILE", nargs=3)

options = parser.parse_args()
args = options.FILE

ice_density = 910.


infile = args[0]
a_file = args[1]
b_file = args[2]

nc = NC(infile, 'a')
time_var = nc.variables['time']
time_bnds_var = nc.variables['time_bnds']
tas = nc.variables['tas']
# get trend, y = a + time*b
nc_a = NC(a_file, 'r')
a = np.squeeze(nc_a.variables['tas'][:])
nc_a.close()
nc_b = NC(b_file, 'r')
b = np.squeeze(nc_b.variables['tas'][:])

tas_2300 = tas[292]

nt = len(time_var[:])
for t in range(0, 5001):
    time_var[t] = 911.25 + 365 * t
    time_bnds_var[t,0] = 730 + 365 * t
    time_bnds_var[t,1] = 1095 + 365 * t
    if t > 292:
        tas[t] =  a + b * (t-192)
    if t > 492:
        tas[t] = tas[492]        
nc.close()
