#!/usr/bin/env python
# Copyright (C) 2017 Andy Aschwanden

import numpy as np
import time
from netCDF4 import Dataset as NC
from argparse import ArgumentParser                            
    

# Set up the option parser
parser = ArgumentParser()
parser.description = "Create climate forcing for an abrupt change from inter-glacial to glacial conditions"
parser.add_argument("FILE", nargs='*')
parser.add_argument("-b",dest="backpressure_max", type=float,
                    help="Maximum backpressure fraction",default=0.3)
parser.add_argument("-n",dest="n", type=float,
                    help="power-law exponent",default=2)


options = parser.parse_args()
args = options.FILE
backpressure_max = options.backpressure_max
n = options.n
start = 0
end = 25000
step = 10
bnds_interval_since_refdate = np.array(range(start, end + step, step))
time_interval_since_refdate = (bnds_interval_since_refdate[0:-1] +
                               np.diff(bnds_interval_since_refdate) / 2)

infile = args[0]

nc = NC(infile, 'w')
    
def def_var(nc, name, units):
    var = nc.createVariable(name, 'f', dimensions=('time'))
    var.units = units
    return var

# create a new dimension for bounds only if it does not yet exist
time_dim = "time"
if time_dim not in nc.dimensions.keys():
    nc.createDimension(time_dim)

# create a new dimension for bounds only if it does not yet exist
bnds_dim = "nb2"
if bnds_dim not in nc.dimensions.keys():
    nc.createDimension(bnds_dim, 2)

# variable names consistent with PISM
time_var_name = "time"
bnds_var_name = "time_bnds"

# create time variable
time_var = nc.createVariable(time_var_name, 'd', dimensions=(time_dim))
time_var[:] = time_interval_since_refdate
time_var.bounds = bnds_var_name
time_var.units = 'years since 1-1-1'
time_var.calendar = '365_day'
time_var.standard_name = time_var_name
time_var.axis = "T"

# create time bounds variable
time_bnds_var = nc.createVariable(bnds_var_name, 'd', dimensions=(time_dim, bnds_dim))
time_bnds_var[:, 0] = bnds_interval_since_refdate[0:-1]
time_bnds_var[:, 1] = bnds_interval_since_refdate[1::]

var = 'delta_T'
dT_var = def_var(nc, var, "K")
T_0 = 0.
T_1 = -15.
T_2 = 5.

temp = np.zeros_like(time_interval_since_refdate) + T_2
temp[0:500] = np.linspace(T_0, T_1, 500)
temp[500:2000] = T_1
temp[2000:2450] = np.linspace(T_1, T_2, 450) 
dT_var[:] = temp

var = 'delta_SL'
dSL_var = def_var(nc, var, "m")
SL_0 = 0.
SL_1 = -100.
SL_1 = 0.

SL = np.zeros_like(time_interval_since_refdate) + SL_1
SL[0:501] = np.linspace(SL_0, SL_1, 501)
dSL_var[:] = SL

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

var = "frac_MBP"
if (var not in nc.variables.keys()):
    frac_var = def_var(nc, var, "1")
else:
    frac_var = nc.variables[var]

frac_var[:] = psi

# writing global attributes
script_command = ' '.join([time.ctime(), ':', __file__.split('/')[-1],
                           ' '.join([str(x) for x in args])])
nc.history = script_command
nc.Conventions = "CF 1.6"
nc.close()
