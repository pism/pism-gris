#!/usr/bin/env python
# Copyright (C) 2015 Andy Aschwanden

import numpy as np
from netCDF4 import Dataset as NC

try:
    import pypismtools.pypismtools as ppt
except:
    import pypismtools as ppt

from netcdftime import utime
import dateutil
import numpy as np
from argparse import ArgumentParser                            
    

# Set up the option parser
parser = ArgumentParser()
parser.description = "Create delta mass flux fractions from GRIP record."
parser.add_argument("FILE", nargs='*')


options = parser.parse_args()
args = options.FILE


infile = args[0]

nc = NC(infile, 'a')

temp = nc.variables['delta_T'][:]
    
def def_var(nc, name, units):
    var = nc.createVariable(name, 'f', dimensions=('time'), zlib=True, complevel=3)
    var.units = units
    return var


x1 = 1
x2 = 11.
y1 = 0.01
y2 = 1.
n = -3
a = (y2-y1)/(np.power(x2,n)-np.power(x1,n))
b = y1 - a*np.power(x1, n)

frac = np.zeros_like(temp)
frac = a*temp**n+b
frac[temp<x1] = y1

var = "frac_mass_flux"
if (var not in nc.variables.keys()):
    frac_var = def_var(nc, var, "1")
else:
    frac_var = nc.variables[var]

    

nc.close()
