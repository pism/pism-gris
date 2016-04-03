#!/usr/bin/env python
# Copyright (C) 2015 Andy Aschwanden

import os
import numpy as np
from argparse import ArgumentParser
from netCDF4 import Dataset as NC

try:
    import pypismtools.pypismtools as ppt
except:
    import pypismtools as ppt

# Set up the option parser
parser = ArgumentParser()
parser.description = "Create initMIP SMB anomalies."
parser.add_argument("--topo_file", dest="topo_file",
                    help='''Topo smb file''')
parser.add_argument("--background_file", dest="background_file",
                    help='''Background smb file''')
parser.add_argument("OUTFILE", nargs=1)
options = parser.parse_args()
topo_file = options.topo_file
background_file = options.background_file

outfile = options.OUTFILE[0]

nc_a = NC(topo_file, 'r')
nc_b = NC(background_file, 'r')

# RCM p values
 
p1 = 0.0720
p2 = 2.2484
p3 = 0.0016
p4 = 0.1011

try:
    os.remove(outfile)
except OSError:
    pass
nc = NC(outfile, 'w')

xdim_a, ydim_a, zdim_a, tdim_a = ppt.get_dims(nc_a)
xdim_b, ydim_b, zdim_b, tdim_b = ppt.get_dims(nc_b)

assert xdim_a == xdim_b
assert ydim_a == ydim_b

xdim = xdim_a
ydim = ydim_a
tdim = 'time'

nx = len(nc_a.dimensions[xdim_a])
ny = len(nc_a.dimensions[ydim_b])

start = -5
end = 100
nt = end - start

nc.createDimension(xdim, size = (nx))
nc.createDimension(ydim, size = (ny))
nc.createDimension(tdim)

bnds_var_name = "time_bnds"
# create a new dimension for bounds only if it does not yet exist
bnds_dim = "nb2"
if bnds_dim not in nc.dimensions.keys():
    nc.createDimension(bnds_dim, 2)

time_var = nc.createVariable(tdim, 'float64', dimensions=(tdim))
time_var.bounds = bnds_var_name
time_var.units = 'years'
time_var.axis = 'T'
time_var[:] = range(start, end)

# create time bounds variable
time_bnds_var = nc.createVariable(bnds_var_name, 'd', dimensions=(tdim, bnds_dim))
time_bnds_var[:, 0] = range(start, end)
time_bnds_var[:, 1] = range(start+1, end+1)

varname = 'surface_altitude'
for name in nc_a.variables.keys():
    v = nc_a.variables[name]
    if getattr(v, "standard_name", "") == varname:
        print("variabe {0} found by its standard_name {1}".format(name,
                                                                  varname))
        myvar = name
h = np.squeeze(nc_a.variables[myvar][:])
lat = np.squeeze(nc_a.variables['lat'][:])

smb_background = nc_b.variables['climatic_mass_balance']
temp_background = nc_b.variables['ice_surface_temp']

smb_anomaly = p3*(h-p2) + p4*(lat-71)
smb_anomaly[smb_anomaly>p1] = p1
# convert m/year ice equivalent to kg m-2 yr-1
smb_anomaly *= 910.

smb_var = nc.createVariable('climatic_mass_balance', 'float64', dimensions=(tdim, ydim, xdim))

temp_var = nc.createVariable('ice_surface_temp', 'float64', dimensions=(tdim, ydim, xdim))

for k in range(nt):
    t = k + start
    temp_var[k,::] = np.squeeze(temp_background[:])
    if t < 0:
        smb_var[k,::] = np.squeeze(smb_background[:])
    elif (t >= 0) and (t < 40):
        smb_var[k,::] = np.squeeze(smb_background[:]) + np.squeeze(smb_anomaly[:]) * np.floor(t) / 40
    else:
        smb_var[k,::] = np.squeeze(smb_background[:]) + np.squeeze(smb_anomaly[:])
        

nc.close()
nc_a.close()
nc_b.close()
