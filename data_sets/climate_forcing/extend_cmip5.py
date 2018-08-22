#!/usr/bin/env python
# Copyright (C) 2017-18 Andy Aschwanden

import numpy as np
from netCDF4 import Dataset as NC

from netcdftime import utime
import dateutil
import numpy as np
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter


# Set up the option parser
parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.description = "Script extends CMIP5 forcing."
parser.add_argument("-a", dest='start_year', type=int,
                    help='Start year', default=292)
parser.add_argument("FILE", nargs=3)

options = parser.parse_args()
args = options.FILE


infile = args[0]
a_file = args[1]
b_file = args[2]
start_year = options.start_year

nc = NC(infile, 'a')
time_var = nc.variables['time']
time_bnds_var = nc.variables['time_bnds']
tas = nc.variables['tas']
# get trend, y = a + time*b
nc_a = NC(a_file, 'r')
a = np.squeeze(nc_a.variables['tas'][0])
nc_a.close()
nc_b = NC(b_file, 'r')
b = np.squeeze(nc_b.variables['tas'][0])
nc_b.close()

nt = len(time_var[:])
for t in range(0, 5001):
    time_var[t] = t
    time_bnds_var[t,0] =  t
    time_bnds_var[t,1] = t + 1
    if t > start_year:
        tas[t] =  a + b * (t - start_year + 100)
    if t > 492:
        tas[t] = tas[492]        
nc.close()
