#!/usr/bin/env python
# Copyright (C) 2017 Andy Aschwanden

import os
try:
    import subprocess32 as sub
except:
    import subprocess as sub
from glob import glob
import gdal
from nco import Nco
nco = Nco()
from nco import custom as c
import logging
import logging.handlers
from argparse import ArgumentParser

from netCDF4 import Dataset as NC

def compute_normal_speed(ifile):
    nc = NC(ifile, 'a')
    ux = nc.variables['uvelsurf'][:]
    vy = nc.variables['vvelsurf'][:]
    nx = nc.variables['nx'][:]
    ny = nc.variables['ny'][:]
    dims = nc.variables['uvelsurf'].dimensions
    nx = np.transpose(np.tile(nx, (1,1,1)), [1,0,2])
    ny = np.transpose(np.tile(ny, (1,1,1)), [1,0,2])
    fill_value = nc.variables['uvelsurf']._FillValue
    nc.createVariable('velsurf_normal', 'd', dimensions=dims, fill_value=fill_value)
    nc.variables['velsurf_normal'][:] = ux * nx + vy * ny
    nc.variables['velsurf_normal'].units = 'm year-1'
    nc.close()


# set up the option parser
parser = ArgumentParser()
parser.description = "Generating scripts for model calibration."
parser.add_argument("INDIR", nargs=1,
                    help="main directory", default=None)

options = parser.parse_args()
idir = options.INDIR[0]

# create logger
logger = logging.getLogger('prepare_velocity_observations')
logger.setLevel(logging.DEBUG)

# create file handler which logs even debug messages
fh = logging.handlers.RotatingFileHandler('prepare_velocity_observations.log')
fh.setLevel(logging.DEBUG)
# create console handler with a higher log level
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
# create formatter
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(module)s:%(lineno)d - %(message)s')

# add formatter to ch and fh
ch.setFormatter(formatter)
fh.setFormatter(formatter)

# add ch to logger
logger.addHandler(ch)
logger.addHandler(fh)

eqn_str = 'velsurf_normal=uvelsurf*nx+vvelsurf*ny;'
profile_basename = 'greenland-flux-gates'
profile_spacing = 250
profile_type = '29'
profile_basedir = '../data_sets/flux-gates'
profile_file = '.'.join(['-'.join([profile_basename, profile_type, ''.join([str(profile_spacing), 'm'])]), 'shp'])
profile_file_wd = os.path.join(profile_basedir, profile_file)

obs_dir = 'observations'
profile_dir = 'profiles'
velocity_file = 'greenland_vel_mosaic250_v1.nc'
velocity_file_wd = os.path.join(obs_dir, 'velocity', velocity_file)
velocity_profile_file_wd = os.path.join(obs_dir, profile_dir, 'profile_{}m_{}_{}'.format(profile_spacing, profile_type,  velocity_file))

cmd = ['extract_profiles.py', '-a',  profile_file_wd, velocity_file_wd, velocity_profile_file_wd]
sub.call(cmd)
logger.info('calculating profile-normal speed')
#compute_normal_speed(velocity_profile_file_wd)

#nco.ncap2(input='-s "{}" {}'.format(eqn_str, velocity_profile_file_wd), output=velocity_profile_file_wd, overwrite=True)

if not os.path.isdir(os.path.join(idir, 'profiles')):
    os.mkdir(os.path.join(idir, 'profiles'))
exp_files = glob(os.path.join(idir, 'state', '*.nc'))
for exp_file in exp_files:
    exp_profile_file = 'profile_{}m_{}_{}'.format(profile_spacing, profile_type,  os.path.split(exp_file)[-1])
    exp_profile_file_wd = os.path.join(idir, 'profiles', exp_profile_file)
    cmd = ['extract_profiles.py', '-a',  profile_file_wd, exp_file, exp_profile_file_wd]
    sub.call(cmd)
    logger.info('calculating profile-normal speed')
#    compute_normal_speed(exp_profile_file_wd)
