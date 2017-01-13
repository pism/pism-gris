#!/usr/bin/env python
# Copyright (C) 2015 Andy Aschwanden

import numpy as np
from netCDF4 import Dataset as NC
from argparse import ArgumentParser                            
    

# Set up the option parser
parser = ArgumentParser()
parser.description = "Create delta mass flux fractions from GRIP record."
parser.add_argument("FILE", nargs='*')
parser.add_argument("-b",dest="backpressure_max", type=float,
                    help="Maximum backpressure fraction",default=0.3)
parser.add_argument("-n",dest="n", type=float,
                    help="power-law exponent",default=2)


options = parser.parse_args()
args = options.FILE
n = options.n
backpressure_max = options.backpressure_max

infile = args[0]

nc = NC(infile, 'a')

temp = nc.variables['delta_T'][:]
    
def def_var(nc, name, units):
    var = nc.createVariable(name, 'f', dimensions=('time'))
    var.units = units
    return var


T_max = 0
T_min = -10
psi_min = 0.01
psi_max = 1.

a = (psi_max - psi_min) / (np.power(T_max, n) - np.power(T_min, n))
b = psi_min - a * np.power(T_min, n)

psi = np.zeros_like(temp)
psi = a * (temp)**n + b
psi[temp<T_min] = psi_min

var = "frac_mass_flux"
if (var not in nc.variables.keys()):
    frac_var = def_var(nc, var, "1")
else:
    frac_var = nc.variables[var]

frac_var[:] = psi


T_max = 0
T_min = -10
psi_min = backpressure_max
psi_max = 0.05

a = (psi_max - psi_min) / (np.power(T_max, n) - np.power(T_min, n))
b = psi_min - a * np.power(T_min, n)
psi = np.zeros_like(temp)
psi = a * (temp)**n + b
psi[temp<T_min] = psi_min
psi[temp>T_max] = psi_max

var = "delta_MBP"
if (var not in nc.variables.keys()):
    frac_var = def_var(nc, var, "1")
else:
    frac_var = nc.variables[var]

frac_var[:] = psi


nc.close()
