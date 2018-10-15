#!/usr/bin/env python
# Copyright (C) 2016-17 Andy Aschwanden

from argparse import ArgumentParser
import numpy as np
from netCDF4 import Dataset as NC

# set up the option parser
parser = ArgumentParser()
parser.description = "Pasting 3d fields from subset domain into large domain."
parser.add_argument("FILE", nargs=2, help="Small and large domain files with 3d fields", default=None)

options = parser.parse_args()

file_sm = options.FILE[0]
file_lg = options.FILE[1]

print(("Pasting regrid fields from {} to {}".format(file_sm, file_lg)))

nc_sm = NC(file_sm, "r")
nc_lg = NC(file_lg, "a")

x_sm = nc_sm.variables["x"][:]
y_sm = nc_sm.variables["y"][:]

x_lg = nc_lg.variables["x"][:]
y_lg = nc_lg.variables["y"][:]

# latitude lower and upper index
y_li = np.argmin(np.abs(y_lg - y_sm[0]))
y_ui = np.argmin(np.abs(y_lg - y_sm[-1]))

# longitude lower and upper index
x_li = np.argmin(np.abs(x_lg - x_sm[0]))
x_ui = np.argmin(np.abs(x_lg - x_sm[-1]))

# 2d fields
# there seem to be some rounding issues or +1, to we have to add +1 to the upper bound
for field in ("tillwat", "bmelt", "Href", "thk"):
    print(("Processing variable {}".format(field)))
    nc_lg.variables[field][0, y_li : y_ui + 1, x_li : x_ui + 1] = nc_sm.variables[field][:]

print("Processing variable enthalpy")
nc_lg.variables["enthalpy"][0, y_li : y_ui + 1, x_li : x_ui + 1, 0:201] = nc_sm.variables["enthalpy"][:]
print("Processing variable litho_temp")
nc_lg.variables["litho_temp"][0, y_li : y_ui + 1, x_li : x_ui + 1, :] = nc_sm.variables["litho_temp"][:]

nc_sm.close()
nc_lg.close()
