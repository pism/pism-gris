#!/usr/bin/env python
# Copyright (C) 2017 Andy Aschwanden

from netCDF4 import Dataset as NC
import numpy as np
from pyproj import Proj



infile = 'JKS_BedElevation.nc'
nc_in = NC(infile, 'r')

x_in = nc_in.variables['X'][:]
y_in = nc_in.variables['Y'][:]
bed = nc_in.variables['Bed'][:]

outfile = 'JKS_BedElevation_150m.nc'
nc = NC(outfile, 'w')

xdim = 'x'
ydim = 'y'
    
e0 = np.min(x_in[:])
n0 = np.min(y_in[:])

M = 390
N = 234

grid_spacing = 150
de = dn = grid_spacing  # m

e1 = e0 + (M-1) * de
n1 = n0 + (N-1) * dn

easting = np.linspace(e0, e1, M)
northing = np.linspace(n0, n1, N)
ee, nn = np.meshgrid(easting, northing)

# Set up EPSG 3413 (NSIDC north polar stereo) projection
projection = "+init=epsg:3413"
proj = Proj(projection)

lon, lat = proj(ee, nn, inverse=True)

# number of grid corners
grid_corners = 4
# grid corner dimension name
grid_corner_dim_name = "nv4"

# array holding x-component of grid corners
gc_easting = np.zeros((M, grid_corners))
# array holding y-component of grid corners
gc_northing = np.zeros((N, grid_corners))
# array holding the offsets from the cell centers
# in x-direction (counter-clockwise)
de_vec = np.array([-de / 2, de / 2, de / 2, -de / 2])
# array holding the offsets from the cell centers
# in y-direction (counter-clockwise)
dn_vec = np.array([-dn / 2, -dn / 2, dn / 2, dn / 2])
# array holding lat-component of grid corners
gc_lat = np.zeros((N, M, grid_corners))
# array holding lon-component of grid corners
gc_lon = np.zeros((N, M, grid_corners))

for corner in range(0, grid_corners):
    ## grid_corners in x-direction
    gc_easting[:, corner] = easting + de_vec[corner]
    # grid corners in y-direction
    gc_northing[:, corner] = northing + dn_vec[corner]
    # meshgrid of grid corners in x-y space
    gc_ee, gc_nn = np.meshgrid(
        gc_easting[:, corner], gc_northing[:, corner])
    # project grid corners from x-y to lat-lon space
    gc_lon[:, :, corner], gc_lat[:, :, corner] = proj(
        gc_ee, gc_nn, inverse=True)
    
    
nc.createDimension(xdim, size=easting.shape[0])
nc.createDimension(ydim, size=northing.shape[0])
    
var = xdim
var_out = nc.createVariable(var, 'd', dimensions=(xdim))
var_out.axis = xdim
var_out.long_name = "X-coordinate in Cartesian system"
var_out.standard_name = "projection_x_coordinate"
var_out.units = "meters"
var_out[:] = easting

var = ydim
var_out = nc.createVariable(var, 'd', dimensions=(ydim))
var_out.axis = ydim
var_out.long_name = "Y-coordinate in Cartesian system"
var_out.standard_name = "projection_y_coordinate"
var_out.units = "meters"
var_out[:] = northing
    
var = 'lon'
var_out = nc.createVariable(var, 'd', dimensions=(ydim, xdim))
var_out.units = "degrees_east"
var_out.valid_range = -180., 180.
var_out.standard_name = "longitude"
var_out.bounds = "lon_bnds"
var_out[:] = lon

var = 'lat'
var_out = nc.createVariable(var, 'd', dimensions=(ydim, xdim))
var_out.units = "degrees_north"
var_out.valid_range = -90., 90.
var_out.standard_name = "latitude"
var_out.bounds = "lat_bnds"
var_out[:] = lat

nc.createDimension(grid_corner_dim_name, size=grid_corners)

var = 'lon_bnds'
# Create variable 'lon_bnds'
var_out = nc.createVariable(
var, 'f', dimensions=(ydim, xdim, grid_corner_dim_name))
# Assign units to variable 'lon_bnds'
var_out.units = "degrees_east"
# Assign values to variable 'lon_nds'
var_out[:] = gc_lon
        
var = 'lat_bnds'
# Create variable 'lat_bnds'
var_out = nc.createVariable(
    var, 'f', dimensions=(ydim, xdim, grid_corner_dim_name))
# Assign units to variable 'lat_bnds'
var_out.units = "degrees_north"
# Assign values to variable 'lat_bnds'
var_out[:] = gc_lat

var = 'bed'
var_out = nc.createVariable(
    var,
    'f',
dimensions=(
    "y",
    "x"),
    fill_value=-2e9)
var_out.units = "meters"
var_out.long_name = "bed elevation"
var_out.grid_mapping = "mapping"
var_out.coordinates = "lon lat"
var_out.standard_name = "bedrock_altitude"
var_out[:] = np.flipud(np.reshape(bed, (N,M), order='C'))
              
mapping = nc.createVariable("mapping", 'c')
mapping.ellipsoid = "WGS84"
mapping.false_easting = 0.
mapping.false_northing = 0.
mapping.grid_mapping_name = "polar_stereographic"
mapping.latitude_of_projection_origin = 90.
mapping.standard_parallel = 70.
mapping.straight_vertical_longitude_from_pole = -45.

from time import asctime
historystr = 'Created ' + asctime() + '\n'
nc.history = historystr
nc.proj4 = projection
nc.Conventions = 'CF-1.6'
nc.close()

