#!/usr/bin/env python
# Copyright (C) 2015 Andy Aschwanden

import numpy as np
from netCDF4 import Dataset as NC

from netcdftime import utime
import dateutil
import numpy as np
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter


def get_dims(nc):
    """
    Gets dimensions from netcdf instance

    Parameters:
    -----------
    nc: netCDF instance

    Returns:
    --------
    xdim, ydim, zdim, tdim: dimensions
    """

    # a list of possible x-dimensions names
    xdims = ["x", "x1"]
    # a list of possible y-dimensions names
    ydims = ["y", "y1"]
    # a list of possible z-dimensions names
    zdims = ["z", "z1"]
    # a list of possible time-dimensions names
    tdims = ["t", "time"]

    xdim = None
    ydim = None
    zdim = None
    tdim = None

    # assign x dimension
    for dim in xdims:
        if dim in list(nc.dimensions.keys()):
            xdim = dim
    # assign y dimension
    for dim in ydims:
        if dim in list(nc.dimensions.keys()):
            ydim = dim
    # assign z dimension
    for dim in zdims:
        if dim in list(nc.dimensions.keys()):
            zdim = dim
    # assign time dimension
    for dim in tdims:
        if dim in list(nc.dimensions.keys()):
            tdim = dim
    return xdim, ydim, zdim, tdim


def get_projection_from_file(nc):
    """
    Gets a Proj projection instance from a pointer to a netCDF file

    Parameters
    ----------
    nc : a netCDF object instance

    Returns
    -------
    p : Proj4 projection instance
    """

    from pyproj import Proj

    # First, check if we have a global attribute 'proj4'
    # which contains a Proj4 string:
    try:
        p = Proj(str(nc.proj4))
        print("Found projection information in global attribute proj4, using it")
    except:
        try:
            p = Proj(str(nc.projection))
            print("Found projection information in global attribute projection, using it")
        except:
            try:
                # go through variables and look for 'grid_mapping' attribute
                for var in list(nc.variables.keys()):
                    if hasattr(nc.variables[var], "grid_mapping"):
                        mappingvarname = nc.variables[var].grid_mapping
                        print(('Found projection information in variable "%s", using it' % mappingvarname))
                        break
                var_mapping = nc.variables[mappingvarname]
                p = Proj(
                    proj="stere",
                    ellps=var_mapping.ellipsoid,
                    datum=var_mapping.ellipsoid,
                    units="m",
                    lat_ts=var_mapping.standard_parallel,
                    lat_0=var_mapping.latitude_of_projection_origin,
                    lon_0=var_mapping.straight_vertical_longitude_from_pole,
                    x_0=var_mapping.false_easting,
                    y_0=var_mapping.false_northing,
                )
            except:
                print("No mapping information found, return empy string.")
                p = ""

    return p


# Set up the option parser
parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.description = "Script creates ocean forcing."
parser.add_argument("FILE", nargs="*")
parser.add_argument(
    "--tct_0", dest="tct_0", type=float, help="southern thickness calving threshold, in m", default=400
)
parser.add_argument("--tct_1", dest="tct_1", type=float, help="northern thickness calving threshold, in m", default=50)
parser.add_argument(
    "--lat_0", dest="lat_0", type=float, help="latitude to apply southern thickness calving threshold", default=74
)
parser.add_argument(
    "--lat_1", dest="lat_1", type=float, help="latitude to apply northern thickness calving threshold", default=76
)

options = parser.parse_args()
args = options.FILE

ice_density = 910.0

lat_0 = options.lat_0
lat_1 = options.lat_1
tct_0 = options.tct_0
tct_1 = options.tct_1

infile = args[0]

nc = NC(infile, "a")

lon_0 = -45

p = get_projection_from_file(nc)

xdim, ydim, zdim, tdim = get_dims(nc)

# x0, y0 = p(lon_0, lat_0)
# x1, y1 = p(lon_0, lat_1)


# tct = a*y + b
a_tct = (tct_1 - tct_0) / (lat_1 - lat_0)
b_tct = tct_0 - a_tct * lat_0

x = nc.variables[xdim]
y = nc.variables[ydim]

X, Y = np.meshgrid(x, y)

Lon, Lat = p(X, Y, inverse=True)

# create a new dimension for bounds only if it does not yet exist
if tdim is None:
    time_dim = "time"
    nc.createDimension(time_dim)
else:
    time_dim = tdim

# create a new dimension for bounds only if it does not yet exist
bnds_dim = "nb2"
if bnds_dim not in list(nc.dimensions.keys()):
    nc.createDimension(bnds_dim, 2)

# variable names consistent with PISM
time_var_name = "time"
bnds_var_name = "time_bnds"

time_units = "years since 1-1-1"
time_calendar = "none"

# create time variable
if time_var_name not in nc.variables:
    time_var = nc.createVariable(time_var_name, "d", dimensions=(time_dim))
else:
    time_var = nc.variables[time_var_name]
time_var.bounds = bnds_var_name
time_var.units = time_units
time_var.standard_name = time_var_name
time_var.axis = "T"
time_var[:] = [1.0]

# create time bounds variable
if bnds_var_name not in nc.variables:
    time_bnds_var = nc.createVariable(bnds_var_name, "d", dimensions=(time_dim, bnds_dim))
else:
    time_bnds_var = nc.variables[bnds_var_name]
time_bnds_var[:, 0] = [0]
time_bnds_var[:, 1] = [1]


def def_var(nc, name, units):
    var = nc.createVariable(name, "f", dimensions=(time_dim, ydim, xdim), zlib=True, complevel=3)
    var.units = units
    return var


var = "calving_threshold"
if var not in list(nc.variables.keys()):
    tct_var = def_var(nc, var, "m")
else:
    tct_var = nc.variabels[var]
tct_var.grid_mapping = "mapping"


nt = len(time_var[:])
for t in range(nt):
    if time_bnds_var is not None:
        print(("Processing from {} to {}".format(time_bnds_var[t, 0], time_bnds_var[t, 1])))
    else:
        print(("Processing {}".format(dates[t])))
    tct_var[t, ::] = 0
    tct = a_tct * Lat + b_tct
    tct[Lat < lat_0] = a_tct * lat_0 + b_tct
    tct[Lat > lat_1] = a_tct * lat_1 + b_tct
    tct_var[t, ::] = tct
    nc.sync()


nc.close()
