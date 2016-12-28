#!/usr/bin/env python
# Copyright (C) 2015 Andy Aschwanden

import numpy as np
from netCDF4 import Dataset as NC
from argparse import ArgumentParser                            
    

# Set up the option parser
parser = ArgumentParser()
parser.description = "Create delta mass flux fractions from GRIP record."
parser.add_argument("FILE", nargs='*')
parser.add_argument("-n",dest="n", type=float,
                    help="power-law exponent",default=2)


options = parser.parse_args()
args = options.FILE
n = options.n

infile = args[0]

nc = NC(infile, 'a')

temp = nc.variables['delta_T'][:]
    
def def_var(nc, name, units):
    var = nc.createVariable(name, 'f', dimensions=('time'))
    var.units = units
    return var


x1 = 0
x2 = 10.
y1 = 0.01
y2 = 1.

a = (y2-y1)/(np.power(x2,n)-np.power(x1,n))
b = y1 - a*np.power(x1, n)

frac = np.zeros_like(temp)
frac = a*(temp+x2)**n + b
frac[temp<-x2] = y1

var = "frac_mass_flux"
if (var not in nc.variables.keys()):
    frac_var = def_var(nc, var, "1")
else:
    frac_var = nc.variables[var]

frac_var[:] = frac


x1 = 0
x2 = 10.
y1 = 0.6
y2 = 0.1

a = (y2-y1)/(np.power(x2,n)-np.power(x1,n))
b = y1 - a*np.power(x1, n)

frac = np.zeros_like(temp)
frac = a*(temp+x2)**n + b
frac[temp<-x2] = y1
frac[frac<y2] = y2

var = "delta_MBP"
if (var not in nc.variables.keys()):
    frac_var = def_var(nc, var, "1")
else:
    frac_var = nc.variables[var]

frac_var[:] = frac


nc.close()
