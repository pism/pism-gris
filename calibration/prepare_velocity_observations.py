#!/usr/bin/env python
# Copyright (C) 2017 Andy Aschwanden

import os
try:
    import subprocess32 as sub
except:
    import subprocess as sub
import gdal
from nco import Nco
nco = Nco()
from nco import custom as c

import logging
import logging.handlers

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

profile_basename = 'greenland-flux-gates'
profile_spacing = 250
profile_type = '29'
profile_basedir = '../../data_sets/flux-gates'
profile_file = '.'.join(['-'.join([profile_basename, profile_type, ''.join([str(profile_spacing), 'm'])]), 'shp'])
profile_file_wd = os.path.join(profile_basedir, profile_file)
print profile_file_wd
