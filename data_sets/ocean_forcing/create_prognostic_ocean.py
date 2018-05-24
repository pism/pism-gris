#!/usr/bin/env python

# Copyright (C) 2011-16 Andy Aschwanden

from argparse import ArgumentParser
from dateutil.rrule import *
from datetime import *
from dateutil.parser import parse
from dateutil.relativedelta import *
import calendar
import numpy as np

import netCDF4 as netCDF
NC = netCDF.Dataset
from netcdftime import utime

try:
    import pypismtools.pypismtools as ppt
except:
    import pypismtools as ppt


# Set up the option parser
parser = ArgumentParser()
parser.description = "Script creates ocean forcing"
parser.add_argument("FILE", nargs=1)
parser.add_argument("-a", "--start_date", dest="start_date",
                    help='''Start date in ISO format. Default=2008-1-1''',
                    default='2008-1-1')
parser.add_argument("-e", "--end_date", dest="end_date",
                    help='''End date in ISO format. Default=2108-1-1''',
                    default='2108-1-1')
parser.add_argument("--bmelt_0",dest="bmelt_0", type=float,
                    help="southern basal melt rate, in m yr-1",default=228)
parser.add_argument("--bmelt_1",dest="bmelt_1", type=float,
                    help="northern basal melt rate, in m yr-1",default=10)
parser.add_argument("-m", "--process_mask", dest="mask", action="store_true",
                    help='''
                    Process the mask, no melting on land''', default=False)

options = parser.parse_args()
start_date = parse(options.start_date)
end_date = parse(options.end_date)
args = options.FILE
infile = args[0]

refdate = "2008-1-1"
time_units = "days since {}".format(refdate)
time_calendar = "standard"
periodicity = "monthly".upper()
time_var_name = "time"
bnds_var_name = "time_bnds"

ice_density = 910.

bmelt_0 = options.bmelt_0 * ice_density
bmelt_1 = options.bmelt_1 * ice_density
mask = options.mask

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


nc = NC(infile, 'a')

# create a new dimension for bounds only if it does not yet exist
time_dim = "time"
if time_dim not in list(nc.dimensions.keys()):
    nc.createDimension(time_dim)

# create a new dimension for bounds only if it does not yet exist
bnds_dim = "nb2"
if bnds_dim not in list(nc.dimensions.keys()):
    nc.createDimension(bnds_dim, 2)

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

cdftime = utime(time_units, time_calendar)

pdict = {}
pdict['DAILY'] = DAILY
pdict['MONTHLY'] = MONTHLY
prule = pdict[periodicity]

# create list with dates from start_date until end_date with
# periodicity prule.
bnds_datelist = list(rrule(prule, dtstart=start_date, until=end_date))

# calculate the days since refdate, including refdate, with time being the
# mid-point value:
# time[n] = (bnds[n] + bnds[n+1]) / 2
bnds_interval_since_refdate = cdftime.date2num(bnds_datelist)
time_interval_since_refdate = (bnds_interval_since_refdate[0:-1] +
                               np.diff(bnds_interval_since_refdate) / 2)


time_var[:] = time_interval_since_refdate

if bnds_var_name not in nc.variables:
    # create time bounds variable
    time_bnds_var = nc.createVariable(bnds_var_name, 'd', dimensions=(time_dim, bnds_dim))
else:
    time_bnds_var = nc.variables[bnds_var_name]
time_bnds_var[:, 0] = bnds_interval_since_refdate[0:-1]
time_bnds_var[:, 1] = bnds_interval_since_refdate[1::]


def def_var(nc, name, units):
    var = nc.createVariable(name, 'f', dimensions=(time_dim, ydim, xdim), zlib=True, complevel=3)
    var.units = units
    return var

var = "shelfbmassflux"
if (var not in list(nc.variables.keys())):
    bmelt_var = def_var(nc, var, "kg m-2 yr-1")
else:
    bmelt_var = nc.variables[var]
bmelt_var.grid_mapping = "mapping"

var = "shelfbtemp"
if (var not in list(nc.variables.keys())):
    btemp_var = def_var(nc, var, "deg_C")
else:
    btemp_var = nc.variables[var]
btemp_var.grid_mapping = "mapping"

var = "delta_MBP"
if (var not in list(nc.variables.keys())):
    mbp_var = nc.createVariable(var, 'f', dimensions=(time_dim), zlib=True, complevel=3)
else:
    mbp_var = nc.variables[var]

if mask:
    mask_var = nc.variables['mask'][:]
    nc.variables['mask'].grid_mapping = "mapping"
    land_mask = (mask_var != 0) & (mask_var !=3)

bmelt = a * Y + b
bmelt[Y<y0] = a * y0 + b
bmelt[Y>y1] = a * y1 + b
if mask:
    bmelt[land_mask] = 0.

nt = len(time_interval_since_refdate)
for t in range(nt):
    print(('Processing from {} to {}'.format(bnds_datelist[t], bnds_datelist[t+1])))
    if periodicity in 'DAILY':
        if calendar.isleap(bnds_datelist[t].year):
            mt = 366
        else:
            mt = 365
    elif periodicity in 'MONTHLY':
        mt = 12
    else:
        print(('Periodicity {} not recognized'.format(periodicity)))
    bmelt_var[t, Ellipsis] = bmelt * (1 + np.sin(2 * np.pi * t / mt))
    btemp_var[t, Ellipsis] = 0
    x = np.mod(t, mt)
    mbp_var[t] =  np.piecewise(x, [x < (mt / 2) , x >= (mt / 2)], [1, 0])
    nc.sync()

nc.close()
