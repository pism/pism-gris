#!/usr/bin/env python
import numpy as np

# try different netCDF modules
try:
    from netCDF4 import Dataset as CDF
except:
    from netCDF3 import Dataset as CDF

from argparse import ArgumentParser

__author__ = "Andy Aschwanden"

parser = ArgumentParser()
parser.description = "extract mask with a time dimension"
parser.add_argument("FILE", nargs='*')
parser.add_argument("-v", "--variable", dest="mask_name",
                    help='''Variable to plot, default = "icemask".''', default='icemask')
parser.add_argument("-y", "--yx_dims", dest="y_dims", action="store_true",
                    help='''Use (time,y,x) instead of (time,rlat,rlon)".''', default=False)

options = parser.parse_args()
args = options.FILE
mask_name = options.mask_name
y_dims = options.y_dims

if (len(args)==2):
    infile = args[0]
    outfile = args[1]
else:
    print("wrong number of input arguments, 2 expected")
    exit(1)

nc_in = CDF(infile, 'r')
nc_out = CDF(outfile, 'a')

mask_in = nc_in.variables[mask_name][:]

time = nc_out.variables["time"]

var_name = "mask"
if var_name not in nc_out.variables.keys():
    if y_dims:
        nc_out.createVariable(var_name, "b", dimensions=("time", "y", "x"))
    else:    
        nc_out.createVariable(var_name, "b", dimensions=("time", "rlat", "rlon"))

var = nc_out.variables[var_name]

for t in range(len(time)):
    var[t,::] = mask_in

nc_in.close()
nc_out.close()
