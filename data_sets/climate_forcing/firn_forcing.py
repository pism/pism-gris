#!/usr/bin/env python
# Copyright (C) 2017 Andy Aschwanden

import numpy as np
from netCDF4 import Dataset as NC

from netcdftime import utime
import dateutil
import numpy as np
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter

def get_dims(nc):
    '''
    Gets dimensions from netcdf instance

    Parameters:
    -----------
    nc: netCDF instance

    Returns:
    --------
    xdim, ydim, zdim, tdim: dimensions
    '''

    # a list of possible x-dimensions names
    xdims = ['x', 'x1']
    # a list of possible y-dimensions names
    ydims = ['y', 'y1']
    # a list of possible z-dimensions names
    zdims = ['z', 'z1']
    # a list of possible time-dimensions names
    tdims = ['t', 'time']

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
    '''
    Gets a Proj projection instance from a pointer to a netCDF file

    Parameters
    ----------
    nc : a netCDF object instance

    Returns
    -------
    p : Proj4 projection instance
    '''

    from pyproj import Proj

    # First, check if we have a global attribute 'proj4'
    # which contains a Proj4 string:
    try:
        p = Proj(str(nc.proj4))
        print(
            'Found projection information in global attribute proj4, using it')
    except:
        try:
            p = Proj(str(nc.projection))
            print(
                'Found projection information in global attribute projection, using it')
        except:
            try:
                # go through variables and look for 'grid_mapping' attribute
                for var in list(nc.variables.keys()):
                    if hasattr(nc.variables[var], 'grid_mapping'):
                        mappingvarname = nc.variables[var].grid_mapping
                        print((
                            'Found projection information in variable "%s", using it' %
                            mappingvarname))
                        break
                var_mapping = nc.variables[mappingvarname]
                p = Proj(proj="stere",
                         ellps=var_mapping.ellipsoid,
                         datum=var_mapping.ellipsoid,
                         units="m",
                         lat_ts=var_mapping.standard_parallel,
                         lat_0=var_mapping.latitude_of_projection_origin,
                         lon_0=var_mapping.straight_vertical_longitude_from_pole,
                         x_0=var_mapping.false_easting,
                         y_0=var_mapping.false_northing)
            except:
                print('No mapping information found, return empy string.')
                p = ''

    return p

# Set up the option parser
parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.description = "Script creates ocean forcing."
parser.add_argument("FILE", nargs='*')
parser.add_argument("--firn_0",dest="firn_0", type=float,
                    help="fir thickness at alt_0, in m",default=0.)
parser.add_argument("--firn_1",dest="firn_1", type=float,
                    help="firn thickness at alt_1, in m",default=100.)
parser.add_argument("--alt_0",dest="alt_0", type=float,
                    help="altitude 0",default=1200.)
parser.add_argument("--alt_1",dest="alt_1", type=float,
                    help="altitude 1",default=3000.)


options = parser.parse_args()
args = options.FILE

ice_density = 910.
infile = args[0]

firn_1 = options.firn_1
firn_0 = options.firn_0
alt_1 = float(options.alt_1)
alt_0 = float(options.alt_0)

print(options)
nc = NC(infile, 'a')

xdim, ydim, zdim, tdim = get_dims(nc)

altitude = nc.variables['surface'][:]
# create a new dimension for bounds only if it does not yet exist
if tdim is None:
    time_dim = 'time'
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

time_units = 'years since 1-1-1'
time_calendar = 'none'

# create time variable
if time_var_name not in nc.variables:
    time_var = nc.createVariable(time_var_name, 'd', dimensions=(time_dim))
else:
    time_var = nc.variables[time_var_name]
time_var.bounds = bnds_var_name
time_var.units = time_units
time_var.standard_name = time_var_name
time_var.axis = "T"
time_var[:] = [1.]

# create time bounds variable
if bnds_var_name not in nc.variables:
    time_bnds_var = nc.createVariable(bnds_var_name, 'd', dimensions=(time_dim, bnds_dim))
else:
    time_bnds_var = nc.variables[bnds_var_name]
time_bnds_var[:, 0] = [0]
time_bnds_var[:, 1] = [1]
    
def def_var(nc, name, units):
    var = nc.createVariable(name, 'f', dimensions=(time_dim, ydim, xdim), zlib=True, complevel=3)
    var.units = units
    return var

var = "firn_depth"
if (var not in list(nc.variables.keys())):
    firn_var = def_var(nc, var, "m")
else:
    firn__var = nc.variabels[var]
firn_var.grid_mapping = "mapping"


# firn_depth = a*y + b
a = (firn_1 - firn_0) / (alt_1 - alt_0)
b = firn_0 - a * alt_0
nt = len(time_var[:])
for t in range(nt):
    if time_bnds_var is not None:
        print(('Processing from {} to {}'.format(time_bnds_var[t,0], time_bnds_var[t,1])))
    else:
        print(('Processing {}'.format(dates[t])))            
    firn = a * altitude + b
    firn[altitude<alt_0] = firn_0
    firn[altitude>alt_1] = firn_1
    firn_var[t,::] = firn
    nc.sync()
        

nc.close()
