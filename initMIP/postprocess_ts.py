#!/usr/bin/env python
# Copyright (C) 2016 Andy Aschwanden

import os
import numpy as np
import csv
import cf_units
try:
    import subprocess32 as sub
except:
    import subprocess as sub
    
from argparse import ArgumentParser
from netCDF4 import Dataset as CDF
from resources_ismip6 import *

# Set up the option parser
parser = ArgumentParser()
parser.description = "Script to make ISMIP6-conforming scalar time series."
#parser.add_argument("INIT_FILE", nargs=1)
parser.add_argument("EXP_FILE", nargs=1)
parser.add_argument("-e", "--experiment", dest="experiment",
                    choices=['ctrl', 'asmb'],
                    help="Output size type", default='ctrl')
parser.add_argument("-t", "--target_resolution", dest="target_resolution", type=int,
                    choices=[1000, 5000],
                    help="Horizontal grid resolution", default=1000)

options = parser.parse_args()
experiment = options.experiment
infile = options.EXP_FILE[0]
target_resolution = options.target_resolution

# Need to get grid resolution from file
nc = CDF(infile, 'r')
pism_grid_dx = int(round(nc.variables['run_stats'].grid_dx_meters))
nc.close()
PISM_GRID_RES_ID = str(pism_grid_dx / 100)
TARGET_GRID_RES_ID = str(target_resolution / 1000)

IS = 'GIS'
GROUP = 'UAF'
MODEL = 'PISM' + PISM_GRID_RES_ID
EXP = experiment
TYPE = '_'.join([EXP, '0' + TARGET_GRID_RES_ID])
INIT = '_'.join(['init', '0' + TARGET_GRID_RES_ID])
project = '{IS}_{GROUP}_{MODEL}'.format(IS=IS, GROUP=GROUP, MODEL=MODEL)
pism_stats_vars = ['pism_config',
                   'run_stats']

ismip6_vars_dict = get_ismip6_vars_dict('ismip6vars.csv', 1)
ismip6_to_pism_dict = dict((k, v.pism_name) for k, v in ismip6_vars_dict.iteritems())
pism_to_ismip6_dict = dict((v.pism_name, k) for k, v in ismip6_vars_dict.iteritems())

pism_copy_vars = [x for x in (ismip6_to_pism_dict.values() + pism_stats_vars)]

if __name__ == "__main__":


    project_dir = os.path.join(GROUP, MODEL, TYPE)
    if not os.path.exists(project_dir):
        os.makedirs(project_dir)

    init_dir = os.path.join(GROUP, MODEL, INIT)
    if not os.path.exists(init_dir):
        os.makedirs(init_dir)
    
    out_filename = 'scalar_{project}_{exp}.nc'.format(project=project, exp=EXP)
    out_file = os.path.join(project_dir, out_filename)
    try:
        os.remove(out_file)
    except OSError:
        pass
    # Check if request variables are present
    nc = CDF(infile, 'r')
    for m_var in pism_copy_vars:
        if m_var not in nc.variables:
            print("Requested variable '{}' missing".format(m_var))
    nc.close()
    cmd = ['ncks', '-O',
           '-v', '{}'.format(','.join(pism_copy_vars)),
           infile, out_file]
    sub.call(cmd)
    
    # Adjust the time axis
    print('Adjusting time axis')
    adjust_time_axis(out_file)
    make_scalar_vars_ismip6_conforming(out_file, ismip6_vars_dict)

    # Update attributes
    print('Adjusting attributes')
    nc = CDF(out_file, 'a')
    nc.Conventions = 'CF-1.6'
    nc.close()
    print('Finished processing scalar file {}'.format(out_file))

    if EXP in ('ctrl'):
        init_file = '{}/scalar_{}_{}.nc'.format(init_dir, project, 'init')
        print('  Copying time 0 to file {}'.format(init_file))
        ncks_cmd = ['ncks', '-O', '-4', '-L', '3',
                    '-d', 'time,0',
                    out_file,
                    init_file]
        sub.call(ncks_cmd)
    
