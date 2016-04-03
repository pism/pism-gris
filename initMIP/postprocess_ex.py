#!/usr/bin/env python
# Copyright (C) 2016 Andy Aschwanden

import os
import glob
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
parser.description = "Script to make ISMIP6-conforming 2D time series."
#parser.add_argument("INIT_FILE", nargs=1)
parser.add_argument("EXP_FILE", nargs=1)
parser.add_argument("-n", '--n_procs', dest="n_procs", type=int,
                    help='''number of cores/processors. default=4.''', default=4)
parser.add_argument("-e", "--experiment", dest="experiment",
                    choices=['ctrl', 'asmb'],
                    help="Experiment type", default='ctrl')
parser.add_argument("-r", "--remap_method", dest="remap_method",
                    choices=['con', 'bil'],
                    help="Remapping method", default='con')
parser.add_argument("-t", "--target_resolution", dest="target_resolution", type=int,
                    choices=[1000, 5000],
                    help="Horizontal grid resolution", default=1000)

parser.add_argument("-w", "--override_weights_file",
                    dest="override_weights_file", action="store_true",
                    help="Override weights file", default=False)

options = parser.parse_args()
experiment = options.experiment
infile = options.EXP_FILE[0]
n_procs = options.n_procs
override_weights_file = options.override_weights_file
remap_method = options.remap_method
target_resolution = options.target_resolution
target_grid_filename = 'searise_grid_{}m.nc'.format(target_resolution)

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
pism_proj_vars = ['cell_area',
                  'mapping',
                  'lat',
                  'lat_bnds',
                  'lon',
                  'lon_bnds']
ismip6_vars_dict = get_ismip6_vars_dict('ismip6vars.csv', 2)
ismip6_to_pism_dict = dict((k, v.pism_name) for k, v in ismip6_vars_dict.iteritems())
pism_to_ismip6_dict = dict((v.pism_name, k) for k, v in ismip6_vars_dict.iteritems())

pism_copy_vars = [x for x in (ismip6_to_pism_dict.values() + pism_stats_vars + pism_proj_vars)]


    
if __name__ == "__main__":


    project_dir = os.path.join(GROUP, MODEL, TYPE)
    if not os.path.exists(project_dir):
        os.makedirs(project_dir)

    init_dir = os.path.join(GROUP, MODEL, INIT)
    if not os.path.exists(init_dir):
        os.makedirs(init_dir)

    tmp_dir = os.path.join('_'.join(['tmp', MODEL]))
    if not os.path.exists(tmp_dir):
        os.makedirs(tmp_dir)

    tmp_filename = 'tmp_{}.nc'.format(EXP)
    tmp_file = os.path.join(tmp_dir, tmp_filename)
    try:
        os.remove(tmp_file)
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
           infile, tmp_file]
    sub.call(cmd)
    
    # Make the file ISMIP6 conforming
    make_spatial_vars_ismip6_conforming(tmp_file, ismip6_vars_dict)
    # Should be temporary until new runs
    ncatted_cmd = ["ncatted",
                   "-a", '''bounds,lat,o,c,lat_bnds''',
                   "-a", '''bounds,lon,o,c,lon_bnds''',
                   "-a", '''coordinates,lat_bnds,d,,''',
                   "-a", '''coordinates,lon_bnds,d,,''',
                   tmp_file]
    sub.call(ncatted_cmd)
                
    # Create source grid definition file
    source_grid_filename = 'source_grid.nc'
    source_grid_file = os.path.join(tmp_dir, source_grid_filename)
    ncks_cmd = ['ncks', '-O', '-v', 'thk,mapping', infile, source_grid_file]
    sub.call(ncks_cmd)
    nc2cdo_cmd = ['nc2cdo.py', source_grid_file]
    sub.call(nc2cdo_cmd)

    # If exist, remove target grid description file
    target_grid_file = os.path.join(tmp_dir, target_grid_filename)
    try:
        os.remove(target_grid_file)
    except OSError:
        pass

    # Create target grid description file
    create_searise_grid(target_grid_file, target_resolution)
    
    # Generate weights if weights file does not exist yet
    cdo_weights_filename = 'searise_grid_{resolution}m_{method}_weights.nc'.format(resolution=target_resolution, method=remap_method)
    cdo_weights_file = os.path.join(tmp_dir, cdo_weights_filename)
    if (not os.path.isfile(cdo_weights_file)) or (override_weights_file is True):
        print('Generating CDO weights file {}'.format(cdo_weights_file))
        cdo_cmd = ['cdo', '-P', '{}'.format(n_procs),
                   'gen{method},{grid}'.format(method=remap_method, grid=target_grid_file),
            source_grid_file,
            cdo_weights_file]
        sub.call(cdo_cmd)

    # Remap to SeaRISE grid    
    out_filename = '{project}_{exp}.nc'.format(project=project, exp=EXP)
    out_file = os.path.join(tmp_dir, out_filename)
    try:
        os.remove(out_file)
    except OSError:
        pass
    print('Remapping to SeaRISE grid')
    cdo_cmd = ['cdo', '-P', '{}'.format(n_procs),
               'remap,{},{}'.format(target_grid_file, cdo_weights_file),
               tmp_file,
               out_file]
    sub.call(cdo_cmd)

    # Adjust the time axis
    print('Adjusting time axis')
    adjust_time_axis(out_file)

    for m_var in ismip6_vars_dict.keys():
        final_file = '{}/{}_{}_{}.nc'.format(project_dir, m_var, project, EXP)
        print('Finalizing variable {}'.format(m_var))
        # Generate file
        print('  Copying to file {}'.format(final_file))
        ncks_cmd = ['ncks', '-O', '-4', '-L', '3',
                    '-v', ','.join([m_var,'lat','lat_vertices','lon','lon_vertices']),
                    out_file,
                    final_file]
        sub.call(ncks_cmd)
        # Add stats vars
        print('  Adding config/stats variables')
        ncks_cmd = ['ncks', '-A',
                    '-v', ','.join(pism_stats_vars),
                    tmp_file,
                    final_file]
        sub.call(ncks_cmd)
        # Add coordinate vars and mapping
        print('  Adding coordinte and mapping variables')
        ncks_cmd = ['ncks', '-A', '-v', 'x,y,mapping',
                    target_grid_file,
                    final_file]
        sub.call(ncks_cmd)
        # Update attributes
        print('  Adjusting attributes')
        nc = CDF(final_file, 'a')
        try:
            nc_var = nc.variables[m_var]
            nc_var.coordintes = 'lat lon'
            nc_var.mapping = 'mapping'
            nc_var.standard_name = ismip6_vars_dict[m_var].standard_name
            nc_var.units = ismip6_vars_dict[m_var].units
        except:
            pass
        nc.Conventions = 'CF-1.6'
        nc.close()
        print('  Done finalizing variable {}'.format(m_var))

        if EXP in ('ctrl'):
            init_file = '{}/{}_{}_{}.nc'.format(init_dir, m_var, project, 'init')
            print('  Copying time 0 to file {}'.format(init_file))
            ncks_cmd = ['ncks', '-O', '-4', '-L', '3',
                        '-d', 'time,0',
                        '-v', m_var,
                        final_file,
                        init_file]
            sub.call(ncks_cmd)
            

    
