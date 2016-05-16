#!/usr/bin/env python

# Copyright (C) 2011-2012 Andy Aschwanden

from argparse import ArgumentParser
from dateutil.rrule import *
from datetime import *
from dateutil.relativedelta import *
import numpy as np

try:
    import netCDF4 as netCDF
except:
    import netCDF3 as netCDF
NC = netCDF.Dataset
from netcdftime import utime

# Set up the option parser
parser = ArgumentParser()
parser.description = "Script adds time bounds to time axis"
parser.add_argument("FILE", nargs='*')
parser.add_argument("-p", "--periodicity", dest="periodicity",
                    help='''periodicity, e.g. monthly, daily, etc. Default=monthly''',
                    default="monthly")

options = parser.parse_args()
periodicity = options.periodicity.upper()
args = options.FILE
infile = args[0]
nc = NC(infile, 'a')
time = nc.variables["time"]
time_units = time.units
time_calendar = time.calendar

cdftime = utime(time_units, time_calendar)

pdict = {}
pdict['DAILY'] = DAILY
pdict['MONTHLY'] = MONTHLY
prule = pdict[periodicity]

r = time_units.split(' ')[2].split('-')
refdate = datetime(int(r[0]), int(r[1]), int(r[2]))
nt = len(time)

t0 = cdftime.num2date(time[0])
start_date = datetime(t0.year, t0.month,1)
datelist = list(rrule(prule, dtstart=start_date, count=nt+1))

# calculate the days since refdate, including refdate
days_since_refdate = cdftime.date2num(datelist)


# set a fill value
fill_value = np.nan

# create a new dimension for bounds only if it does not yet exist
dim = "tbnds"
if dim not in nc.dimensions.keys():
    nc.createDimension(dim, 2)

def def_var(nc, name, units, fillvalue):
    var = nc.createVariable(name, 'f', dimensions=("time", "tbnds"), fill_value=fill_value)
    return var

var = "time_bnds"
if (var not in nc.variables.keys()):
    time_bnds_var = def_var(nc, var, time_units, fill_value)
    time_bnds_var[:,0] = days_since_refdate[0:-1]
    time_bnds_var[:,1] = days_since_refdate[1::]
else:
    nc.variables[var][:,0] = days_since_refdate[0:-1]
    nc.variables[var][:,1] = days_since_refdate[1::]

time.bounds = var
nc.close()
