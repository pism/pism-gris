#!/usr/bin/env python
# Copyright (C) 2017 Andy Aschwanden

import numpy as np
import time
from netCDF4 import Dataset as NC
from argparse import ArgumentParser                            
    

# Set up the option parser
parser = ArgumentParser()
parser.description = "Create climate forcing for a warming climate"
parser.add_argument("FILE", nargs='*')
parser.add_argument("-f",dest="warming_factor", type=float,
                    help="Ocean warming factor",default=1)


options = parser.parse_args()
args = options.FILE
start = 0
end = 50000
warming_factor = options.warming_factor
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


psi = np.ones_like(time_var[:]) * warming_factor

var = "frac_mass_flux"
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
