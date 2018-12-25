#!/usr/bin/env python
# Copyright (C) 2017 Andy Aschwanden

import os

try:
    import subprocess32 as sub
except:
    import subprocess as sub
from glob import glob
import numpy as np
import gdal
from nco import Nco

nco = Nco()
from nco import custom as c
import logging
import logging.handlers
from argparse import ArgumentParser

from netCDF4 import Dataset as NC


def permute_nc(variable, output_order=("time", "station", "profile", "z", "zb")):
    """
    Permute dimensions of a NetCDF variable to match the output
    storage order.

    Parameters
    ----------
    variable : a netcdf variable
               e.g. thk = nc.variables['thk']
    output_order: dimension tuple (optional)
                  default ordering is ('time', 'z', 'zb', 'y', 'x')

    Returns
    -------
    var_perm : array_like
    """

    input_dimensions = variable.dimensions

    # filter out irrelevant dimensions
    dimensions = [x for x in output_order if x in input_dimensions]

    # create the mapping
    mapping = [dimensions.index(x) for x in input_dimensions]

    if mapping:
        return np.transpose(variable[:], mapping)
    else:
        return variable[:]  # so that it does not break processing "mapping"


def permute(
    array,
    input_order=("time", "station", "profile", "z", "zb"),
    output_order=("station", "time", "profile", "z", "zb"),
):
    """
    Permute dimensions of an array to match the output
    storage order.

    Parameters
    ----------
    array: array_like
    input_order: dimension tuple (optional)
                  default ordering is ('time', 'station', 'profile', 'z', 'zb')'
    output_order: dimension tuple (optional)
                  default ordering is ('time', 'station', 'profile', 'z', 'zb')'

    Returns
    -------
    var_perm : array_like
    """

    input_dimensions = input_order

    # filter out irrelevant dimensions
    dimensions = [x for x in output_order if x in input_dimensions]

    # create the mapping
    mapping = [dimensions.index(x) for x in input_dimensions]

    return np.transpose(array, mapping)


def compute_normal_speed(ifile):
    """
    Compute normal-to-profile speeds
    """
    nc = NC(ifile, "a")
    ux = permute_nc(nc.variables["uvelsurf"])
    vy = permute_nc(nc.variables["vvelsurf"])
    nx = permute_nc(nc.variables["nx"])
    ny = permute_nc(nc.variables["ny"])
    dims = nc.variables["uvelsurf"].dimensions
    fill_value = nc.variables["uvelsurf"]._FillValue
    nc.createVariable("velsurf_normal", "d", dimensions=dims, fill_value=fill_value)
    vn = ux * nx + vy * ny
    # filter out irrelevant dimensions
    input_dims = [x for x in ("time", "station", "profile", "z", "zb") if x in dims]
    nc.variables["velsurf_normal"][:] = permute(vn, input_order=input_dims, output_order=dims)
    nc.variables["velsurf_normal"].units = "m year-1"
    nc.close()


def add_run_stats(ifile, ds=1500):
    """
    Add missing run_stats
    """
    nc = NC(ifile, "a")
    if "run_stats" not in nc.variables:
        nc.createVariable("run_stats", "b", dimensions=())
    nc.variables["run_stats"].grid_dx_meters = ds
    nc.close()


# set up the option parser
parser = ArgumentParser()
parser.description = "Generating scripts for model calibration."
parser.add_argument("INDIR", nargs=1, help="main directory", default=None)
parser.add_argument(
    "-a",
    "--append",
    dest="append",
    action="store_true",
    help="Append. Only process new files. Default=False",
    default=False,
)
parser.add_argument("--ds", dest="ds", type=int, help="Add run_stats: grid_dx_meters", default=1500)

options = parser.parse_args()
append = options.append
ds = options.ds
idir = options.INDIR[0]

# create logger
logger = logging.getLogger("prepare flux gates")
logger.setLevel(logging.DEBUG)

# create file handler which logs even debug messages
fh = logging.handlers.RotatingFileHandler("prepare_velocity_observations.log")
fh.setLevel(logging.DEBUG)
# create console handler with a higher log level
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
# create formatter
formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(module)s:%(lineno)d - %(message)s")

# add formatter to ch and fh
ch.setFormatter(formatter)
fh.setFormatter(formatter)

# add ch to logger
logger.addHandler(ch)
logger.addHandler(fh)

eqn_str = "velsurf_normal=uvelsurf*nx+vvelsurf*ny;"
profile_name = "greenland"
profile_spacing = 250
profile_type = "29"
profile_basename = "{}-flux-gates-{}-{}m".format(profile_name, profile_type, profile_spacing)
profile_basedir = "~/base/gris-analysis/flux-gates"
profile_file = ".".join([profile_basename, "shp"])
profile_file_wd = os.path.join(profile_basedir, profile_file)


# Process observations
obs_dir = "../data_sets/velocities/"
profile_dir = "profiles"
velocity_file = "greenland_vel_mosaic250_v1.nc"
velocity_file_wd = os.path.join(obs_dir, "measures", velocity_file)
velocity_profile_file_wd = os.path.join(
    obs_dir, profile_dir, "profile_{}_{}m_{}_{}".format(profile_name, profile_spacing, profile_type, velocity_file)
)

# Preparing Observations
logger.info("Preparing observations")
cmd = [
    "extract_profiles.py",
    "--srs",
    "3413",
    "--special_vars",
    profile_file_wd,
    velocity_file_wd,
    velocity_profile_file_wd,
]
print(" ".join(cmd))
sub.call(cmd)
# logger.info("calculating profile-normal speed")
# compute_normal_speed(velocity_profile_file_wd)

# Process experiments
if not os.path.isdir(os.path.join(idir, "profiles")):
    os.mkdir(os.path.join(idir, "profiles"))

exp_files = glob(os.path.join(idir, "state", "*.nc"))
for exp_file in exp_files:
    exp_profile_file = "profile_{}_{}m_{}_{}".format(
        profile_name, profile_spacing, profile_type, os.path.split(exp_file)[-1]
    )
    exp_profile_file_wd = os.path.join(idir, "profiles", exp_profile_file)
    if (not append) or (not append and not os.path.isfile(exp_profile_file)):
        logger.info("processing {}".format(exp_file))
        cmd = ["extract_profiles.py", "--special_vars", profile_file_wd, exp_file, exp_profile_file_wd]
        sub.call(cmd)
        logger.info("calculating profile-normal speed")
        compute_normal_speed(exp_profile_file_wd)
        # ds = int(os.path.split(exp_file)[-1].split('gris_g')[1].split('m_')[0])
        # add_run_stats(exp_profile_file_wd, ds=ds)
