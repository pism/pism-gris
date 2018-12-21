#!/usr/bin/env python

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
import numpy as np
from netCDF4 import Dataset as NC

# set up the option parser
parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.description = "Extract basins from continental scale files."
parser.add_argument("FILE", nargs=1)
options = parser.parse_args()

infile = options.FILE[0]
nc = NC(infile, "a")

u = nc.variables["uvelsurf"]
v = nc.variables["vvelsurf"]
ex = nc.variables["uvelsurf_error"]
ey = nc.variables["vvelsurf_error"]
nx = nc.variables["nx"]
ny = nc.variables["ny"]
var = "velsurf_normal"
if var not in nc.variables:
    v_n = nc.createVariable(var, "d", dimensions=u.dimensions, fill_value=-2.0e9)
else:
    v_n = nc.variables[var]
v_n[:] = np.array(
    np.array(u[:], dtype="d") * np.array(nx[:], dtype="d") + np.array(v[:], dtype="d") * np.array(ny[:], dtype="d"),
    dtype="d",
)
var = "velsurf_normal_error"
if var not in nc.variables:
    v_n = nc.createVariable(var, "d", dimensions=u.dimensions, fill_value=-2.0e9)
else:
    v_n = nc.variables[var]

v_n[:] = ex[:]

nc.close()
