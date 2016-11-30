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


# Set up the option parser
parser = ArgumentParser()
parser.description = "Script creates melange back pressure time series"
parser.add_argument("FILE", nargs=1)

parser.add_argument("-a", "--start_date", dest="start_date",
                    help='''Start date in ISO format. Default=2008-1-1''',
                    default='2008-1-1')
parser.add_argument("-e", "--end_date", dest="end_date",
                    help='''End date in ISO format. Default=2108-1-1''',
                    default='2108-1-1')
parser.add_argument("--winter_value",dest="winter_value", type=float,
                    help="Winter values of melange back pressure",default=1.)

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


winter_value = options.winter_value

infile = args[0]

nc = NC(infile, 'w')
    

# create a new dimension for bounds only if it does not yet exist
time_dim = "time"
if time_dim not in nc.dimensions.keys():
    nc.createDimension(time_dim)

# create a new dimension for bounds only if it does not yet exist
bnds_dim = "nb2"
if bnds_dim not in nc.dimensions.keys():
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


var = "delta_MBP"
if (var not in nc.variables.keys()):
    mbp_var = nc.createVariable(var, 'f', dimensions=(time_dim))
else:
    mbp_var = nc.variables[var]



nt = len(time_interval_since_refdate)
for t in range(nt):
    print('Processing from {} to {}'.format(bnds_datelist[t], bnds_datelist[t+1]))
    if periodicity in 'DAILY':
        if calendar.isleap(bnds_datelist[t].year):
            mt = 366
        else:
            mt = 365
    elif periodicity in 'MONTHLY':
        mt = 12
    else:
        print('Periodicity {} not recognized'.format(periodicity))
    x = np.mod(t, mt)
    if x < (mt / 2):
        mbp = winter_value
    else:
        mbp = 0
    mbp_var[t] = mbp
    nc.sync()

nc.close()
