#!/usr/bin/env python
# Copyright (C) 2016, 2017 Andy Aschwanden

import numpy as np
import pylab as plt
from matplotlib.mlab import griddata
from mpl_toolkits.mplot3d import Axes3D
from netCDF4 import Dataset as NC
from argparse import ArgumentParser



# set up the option parser
parser = ArgumentParser()
parser.description = "Generating synthetic outlet glacier."
parser.add_argument("FILE", nargs='*')
parser.add_argument("-g", "--grid", dest="grid_spacing", type=int,
                    help="horizontal grid resolution", default=1000)
parser.add_argument("-s", "--side_walls", dest="has_sidewalls", action='store_true',
                    help="horizontal grid resolution", default=False)
parser.add_argument("-f", "--format", dest="fileformat", type=str.upper,
                    choices=[
                        'NETCDF4', 'NETCDF4_CLASSIC', 'NETCDF3_CLASSIC', 'NETCDF3_64BIT'],
                    help="file format out output file", default='netcdf3_64bit')

options = parser.parse_args()
args = options.FILE
fileformat = options.fileformat.upper()
grid_spacing = options.grid_spacing
has_sidewalls = options.has_sidewalls

if len(args) == 0:
    nc_outfile = 'og' + str(grid_spacing) + 'm.nc'
elif len(args) == 1:
    nc_outfile = args[0]
else:
    print('wrong number arguments, 0 or 1 arguments accepted')
    parser.print_help()
    import sys
    sys.exit(0)

# Domain extend
x0, x1 = 0., 260.e3
y0, y1 = -50.e3, 50.e3

# Shift to cell centers
x0 += grid_spacing / 2
y0 += grid_spacing / 2
x1 -= grid_spacing / 2
y1 -= grid_spacing / 2

dx = dy = grid_spacing  # m
# Number of grid points
M = int((x1 - x0) / dx) + 1
N = int((y1 - y0) / dy) + 1

x = np.linspace(x0, x1, M)
y = np.linspace(y0, y1, N)
X, Y = np.meshgrid(x, y)


# Ellipsoid center
xe = 125e3
ye = 0
ze = -1000

# Ellipsoid parameters
a = 100e3
b = 5e3
c = 800

Ze = -c * np.sqrt(1-((np.array(X, dtype=np.complex) - xe) / a)**2 - ((np.array(Y, dtype=np.complex) -ye)/ b)**2);
Ze = np.real(Ze) + ze

# That works because outside the area of the ellipsoid the sqrt is purely imaginary (hence the 'real' command).
# Rotating this around the y-axis is not really complicated, per se. Rotation around an angle alpha would give you the following:

alpha = 0.5
beta = 0.7
Xp = np.cos(np.deg2rad(alpha)) * X - np.sin(np.deg2rad(alpha)) * Ze
Yp = Y
Zp = np.sin(np.deg2rad(alpha)) * X + np.cos(np.deg2rad(alpha)) * Ze
Zsurf = np.sin(np.deg2rad(beta)) * X - 500

# The only problem is now that Xp, Yp is no longer a regular grid, so you need to interpolate back onto the original grid:

Zpi = griddata(np.ndarray.flatten(Xp), np.ndarray.flatten(Yp), np.ndarray.flatten(Zp), X, Y, interp='linear')
# Remove mask
Zpi.masked = False
Zpi[:, 0] = Zpi[:, 1]
Zpi[:, -1] = Zpi[:, -2]

radius = 25e3
xcl, ycl = 50e3, y0
xcu, ycu = 50e3, y1

CL = ((X-xcl)**2 + (Y-ycl)**2 < radius**2)
CU = ((X-xcu)**2 + (Y-ycu)**2 < radius**2)

wall_elevation = 1000.
if has_sidewalls:
    Zpi[np.logical_or(CL, CU)] = wall_elevation
    Zpi[np.logical_and((X<xcl), (Y<ycl+radius))] = wall_elevation
    Zpi[np.logical_and((X<xcu), (Y>ycu-radius))] = wall_elevation

thk = Zsurf - Zpi
thk[X<50e3] = 0.
thk[thk<0] = 0.

nc = NC(nc_outfile, 'w', format=fileformat)

nc.createDimension("x", size=x.shape[0])
nc.createDimension("y", size=y.shape[0])

var = 'x'
var_out = nc.createVariable(var, 'd', dimensions=("x"))
var_out.axis = "X"
var_out.long_name = "X-coordinate in Cartesian system"
var_out.standard_name = "projection_x_coordinate"
var_out.units = "meters"
var_out[:] = x

var = 'y'
var_out = nc.createVariable(var, 'd', dimensions=("y"))
var_out.axis = "Y"
var_out.long_name = "Y-coordinate in Cartesian system"
var_out.standard_name = "projection_y_coordinate"
var_out.units = "meters"
var_out[:] = y

var = 'topg'
var_out = nc.createVariable(
    var,
    'f',
    dimensions=(
        "y",
        "x"))
var_out.units = "meters"
var_out.standard_name = 'bedrock_altitude'
var_out[:] = Zpi

var = 'usurf'
var_out = nc.createVariable(
    var,
    'f',
    dimensions=(
        "y",
        "x"))
var_out.units = "meters"
var_out.standard_name = 'surface_altitude'
var_out[:] = Zsurf

var = 'thk'
var_out = nc.createVariable(
    var,
    'f',
    dimensions=(
        "y",
        "x"))
var_out.units = "meters"
var_out.standard_name = 'land_ice_thickness'
var_out[:] = thk

var = 'no_model_mask'
var_out = nc.createVariable(
    var,
    'f',
    dimensions=(
        "y",
        "x"))
var_out.units = ""
var_out.flag_meanings = "normal special_treatment"
var_out.long_name = "mask: zeros (modeling domain) and ones (no-model buffer near grid edges)"
var_out.flag_values = 0., 1.
var_out.pism_intent = "model_state"
no_model_mask = np.zeros_like(thk)
no_model_mask[X>=256e3] = 1
var_out[:] = no_model_mask

nc.close()

# fig = plt.figure()
# ax = fig.add_subplot(111, projection='3d')
# ax.plot_surface(X, Y, Zsurf)
# plt.show()
