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
parser.description = "Script adds ocean forcing to HIRHAM atmosphere/surface forcing file. Sets a constant, spatially-uniform basal melt rate of b_a before time t_a, and b_e after time t_a."
parser.add_argument("FILE", nargs='*')
parser.add_argument("--bmelt_0",dest="bmelt_0",
                    help="southern basal melt rate, in kg m-2 s-1",default=228e3*0.91)
parser.add_argument("--bmelt_1",dest="bmelt_1",
                    help="northern basal melt rate, in kg m-2 s-1",default=10*0.91)


options = parser.parse_args()
args = options.FILE

bmelt_0 = options.bmelt_0
bmelt_1 = options.bmelt_1

infile = args[0]

nc = NC(infile, 'a')
    
lon_0 = -45
# Jakobshavn
lat_0 = 69
# Petermann
lat_1 = 81

p = ppt.get_projection_from_file(nc)

xdim, ydim, zdim, tdim = ppt.get_dims(nc)

x0, y0 = p(lon_0, lat_0)
x1, y1 = p(lon_0, lat_1)

# bmelt = a*y + b
a = (bmelt_1 - bmelt_0) / (y1 - y0)
b = bmelt_0 - a * y0
    
x = nc.variables[xdim]
y = nc.variables[ydim]

X, Y = np.meshgrid(x, y)

# create a new dimension for bounds only if it does not yet exist
if tdim is None:
    time_dim = 'time'
    nc.createDimension(time_dim)
else:
    time_dim = tdim

# create a new dimension for bounds only if it does not yet exist
bnds_dim = "nb2"
if bnds_dim not in nc.dimensions.keys():
    nc.createDimension(bnds_dim, 2)

# variable names consistent with PISM
time_var_name = "time"
bnds_var_name = "time_bnds"

time_units = 'years since 1-1-1'
time_calendar = 'none'

# create time variable
time_var = nc.createVariable(time_var_name, 'd', dimensions=(time_dim))
time_var.bounds = bnds_var_name
time_var.units = time_units
time_var.standard_name = time_var_name
time_var.axis = "T"
time_var[:] = [1.]

# create time bounds variable
time_bnds_var = nc.createVariable(bnds_var_name, 'd', dimensions=(time_dim, bnds_dim))
time_bnds_var[:, 0] = [0]
time_bnds_var[:, 1] = [1]
    
def def_var(nc, name, units):
    var = nc.createVariable(name, 'f', dimensions=(time_dim, ydim, xdim), zlib=True, complevel=3)
    var.units = units
    return var

var = "shelfbmassflux"
if (var not in nc.variables.keys()):
    bmelt_var = def_var(nc, var, "kg m-2 yr-1")
else:
    bmelt_var = nc.variables[var]
bmelt_var.grid_mapping = "mapping"

var = "shelfbtemp"
if (var not in nc.variables.keys()):
    btemp_var = def_var(nc, var, "deg_C")
else:
    btemp_var = nc.variabels[var]
btemp_var.grid_mapping = "mapping"
    

nt = len(time_var[:])
for t in range(nt):
    if time_bnds_var is not None:
        print('Processing from {} to {}'.format(time_bnds_var[t,0], time_bnds_var[t,1]))
    else:
        print('Processing {}'.format(dates[t]))        
    bmelt = a * Y + b
    bmelt[Y<y0] = a * y0 + b
    bmelt[Y>y1] = a * y1 + b
    bmelt_var[t,::] = bmelt
    btemp_var[t,::] = 0
    nc.sync()
        

nc.close()
