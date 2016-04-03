#!/usr/bin/env python
# Copyright (C) 2016 Andy Aschwanden and the PISM authors

import itertools
from collections import OrderedDict
import os
from argparse import ArgumentParser
from resources import *

grid_choices = [18000, 9000, 6000, 4500, 3600, 1800, 1500, 1200, 900, 600, 450, 300, 150]

# set up the option parser
parser = ArgumentParser()
parser.description = "initMIP relaxation."
parser.add_argument("FILE", nargs=1)
parser.add_argument("-n", '--n_procs', dest="n", type=int,
                    help='''number of cores/processors. default=192.''', default=192)
parser.add_argument("-w", '--wall_time', dest="walltime",
                    help='''walltime. default: 96:00:00.''', default="96:00:00")
parser.add_argument("-q", '--queue', dest="queue", choices=['standard_4', 'standard_16', 'standard', 'gpu', 'gpu_long', 'long', 'normal'],
                    help='''queue. default=standard_4.''', default='standard')
parser.add_argument("--calving", dest="calving",
                    choices=['float_kill', 'ocean_kill', 'eigen_calving', 'thickness_calving'],
                    help="claving", default='ocean_kill')
parser.add_argument("-d", "--domain", dest="domain",
                    choices=['gris', 'gris_ext'],
                    help="sets the modeling domain", default='gris_ext')
parser.add_argument("-f", "--o_format", dest="oformat",
                    choices=['netcdf3', 'netcdf4_parallel', 'pnetcdf'],
                    help="output format", default='netcdf4_parallel')
parser.add_argument("-g", "--grid", dest="grid", type=int,
                    choices=grid_choices,
                    help="horizontal grid resolution", default=1200)
parser.add_argument("--o_size", dest="osize",
                    choices=['small', 'medium', 'big', '2dbig'],
                    help="output size type", default='2dbig')
parser.add_argument("-b", "--bed_type", dest="bed_type",
                    choices=['ctrl', 'old_bed', 'ba01_bed', '970mW_hs', 'jak_1985', 'cresis'],
                    help="output size type", default=None)
parser.add_argument("--bed_deformation", dest="bed_deformation",
                    choices=[None, 'lc', 'iso'],
                    help="Bed deformation model.", default=None)
parser.add_argument("--duration", dest="dura", type=int,
                    help="Length of simulation in years (integers)", default=50)
parser.add_argument("--forcing_type", dest="forcing_type",
                    choices=['ctrl', 'e_age'],
                    help="output size type", default='ctrl')
parser.add_argument("--hydrology", dest="hydrology",
                    choices=['null', 'diffuse'],
                    help="Basal hydrology model.", default='diffuse')
parser.add_argument("--regrid_thickness", dest="regrid_thickness", action="store_true",
                    help="Regrid ice thickness from input file rather than from boot file", default=False)

parser.add_argument("-s", "--system", dest="system",
                    choices=list_systems(),
                    help="computer system to use.", default='chinook')
parser.add_argument("--stress_balance", dest="stress_balance",
                    choices=['sia', 'ssa+sia', 'ssa'],
                    help="stress balance solver", default='ssa+sia')
parser.add_argument("--dataset_version", dest="version",
                    choices=['2'],
                    help="input data set version", default='2')
parser.add_argument("--vertical_velocity_approximation", dest="vertical_velocity_approximation",
                    choices=['centered', 'upstream'],
                    help="How to approximate vertical velocities", default='upstream')


options = parser.parse_args()
filename = options.FILE[0]


nn = options.n
oformat = options.oformat
osize = options.osize
queue = options.queue
walltime = options.walltime
system = options.system

bed_deformation = options.bed_deformation
bed_type = options.bed_type
calving = options.calving
climate = 'relax'
climate_file = 'initMIP_climate_forcing_{grid}m_100a_ctrl.nc'.format(grid=options.grid)
forcing_type = options.forcing_type
grid = options.grid
hydrology = options.hydrology
stress_balance = options.stress_balance
vertical_velocity_approximation = options.vertical_velocity_approximation
version = options.version

domain = options.domain
pism_exec = generate_domain(domain)
    
infile = ''
if domain.lower() in ('greenland_ext', 'gris_ext'):
    pism_dataname = 'pism_Greenland_ext_{}m_mcb_jpl_v{}'.format(grid, version)
else:
    pism_dataname = 'pism_Greenland_{}m_mcb_jpl_v{}'.format(grid, version)
if bed_type is None:
    pism_dataname = '{}.nc'.format(pism_dataname)
else:
    pism_dataname = '{}_{}.nc'.format(pism_dataname, bed_type)
    
dura = options.dura
regridfile = filename
regrid_thickness = options.regrid_thickness
#regridvars = 'age,litho_temp,enthalpy,tillwat,bmelt,Href'
regridvars = 'litho_temp,enthalpy,tillwat,bmelt,Href'
if regrid_thickness:
    regridvars = '{},thk'.format(regridvars)


# ########################################################
# set up initMIP relaxation run
# ########################################################

# these values are for non-coupled simulations
# need to be adjusted
sia_e = (1.25)
ssa_n = (3.25)
ssa_e = (1.0)

eigen_calving_k = 1e18

thickness_calving_threshold_vales = [50]
ppq_values = [0.33, 0.6]
tefo_values = [0.020]
phi_min_values = [5.0]
phi_max_values = [40.]
topg_min_values = [-700]
topg_max_values = [700]
combinations = list(itertools.product(thickness_calving_threshold_vales, ppq_values, tefo_values, phi_min_values, phi_max_values, topg_min_values, topg_max_values))

tsstep = 'yearly'
exstep = 'yearly'

scripts = []

start = 0
end = dura

for n, combination in enumerate(combinations):

    thickness_calving_threshold, ppq, tefo, phi_min, phi_max, topg_min, topg_max = combination

    ttphi = '{},{},{},{}'.format(phi_min, phi_max, topg_min, topg_max)

    name_options = OrderedDict()
    name_options['ppq'] = ppq
    name_options['tefo'] = tefo
    name_options['calving'] = calving
    if calving in ('eigen_calving'):
        name_options['k'] = eigen_calving_k
        name_options['threshold'] = thickness_calving_threshold
    if calving in ('thickness_calving'):
        name_options['threshold'] = thickness_calving_threshold
    name_options['forcing_type'] = forcing_type
    name_options['hydro'] = hydrology
    
    vversion = 'v' + str(version)
    if bed_type is None:
        experiment =  '_'.join([climate, vversion, '_'.join(['_'.join([k, str(v)]) for k, v in name_options.items()])])
    else:
        experiment =  '_'.join([climate, vversion, bed_type, '_'.join(['_'.join([k, str(v)]) for k, v in name_options.items()])])

        
    script = 'relax_{}_g{}m_{}.sh'.format(domain.lower(), grid, experiment)
    scripts.append(script)
    
    for filename in (script):
        try:
            os.remove(filename)
        except OSError:
            pass

    batch_header, batch_system = make_batch_header(system, nn, walltime, queue)
            
    with open(script, 'w') as f:

        f.write(batch_header)

        outfile = '{domain}_g{grid}m_{experiment}_{dura}a.nc'.format(domain=domain.lower(),grid=grid, experiment=experiment, dura=dura)

        prefix = generate_prefix_str(pism_exec)

        general_params_dict = OrderedDict()
        general_params_dict['i'] = pism_dataname
        general_params_dict['bootstrap'] = ''
        general_params_dict['regrid_file'] = regridfile
        general_params_dict['regrid_vars'] = regridvars
        general_params_dict['ys'] = start
        general_params_dict['ye'] = end
        general_params_dict['o'] = outfile
        general_params_dict['o_format'] = oformat
        general_params_dict['o_size'] = osize
        general_params_dict['config_override'] = 'init_config.nc'
        if bed_deformation is not None:
            general_params_dict['bed_def'] = bed_deformation
        if forcing_type in ('e_age'):
            general_params_dict['e_age_coupling'] = ''
        
        grid_params_dict = generate_grid_description(grid, domain)

        sb_params_dict = OrderedDict()
        sb_params_dict['sia_e'] = sia_e
        sb_params_dict['ssa_e'] = ssa_e
        sb_params_dict['ssa_n'] = ssa_n
        sb_params_dict['pseudo_plastic_q'] = ppq
        sb_params_dict['till_effective_fraction_overburden'] = tefo
        sb_params_dict['topg_to_phi'] = ttphi
        sb_params_dict['vertical_velocity_approximation'] = vertical_velocity_approximation

        stress_balance_params_dict = generate_stress_balance(stress_balance, sb_params_dict)
        climate_params_dict = generate_climate(climate, surface_given_file=climate_file)
        ocean_params_dict = generate_ocean(climate, ocean_given_file='ocean_forcing_latitudinal.nc')
        hydro_params_dict = generate_hydrology(hydrology)
        calving_params_dict = generate_calving(calving, thickness_calving_threshold=thickness_calving_threshold, eigen_calving_k=eigen_calving_k, ocean_kill_file=pism_dataname)

        exvars = default_spatial_ts_vars()
        spatial_ts_dict = generate_spatial_ts(outfile, exvars, exstep, start=start, end=end)
        scalar_ts_dict = generate_scalar_ts(outfile, tsstep, start=start, end=end)

        
        all_params_dict = merge_dicts(general_params_dict, grid_params_dict, stress_balance_params_dict, climate_params_dict, ocean_params_dict, hydro_params_dict, calving_params_dict, spatial_ts_dict, scalar_ts_dict)
        all_params = ' '.join([' '.join(['-' + k, str(v)]) for k, v in all_params_dict.items()])
        
        cmd = ' '.join([batch_system['mpido'], prefix, all_params, '2>&1 | tee job.${batch}'.format(batch=batch_system['job_id'])])

        f.write(cmd)
        f.write('\n')

        if vversion in ('v2', 'v2_1985'):
            mytype = "MO14 2015-04-27"
        else:
            import sys
            print('TYPE {} not recognized, exiting'.format(vversion))
            sys.exit(0)        
    
scripts = uniquify_list(scripts)

submit = 'submit_{domain}_g{grid}m_{climate}.sh'.format(domain=domain.lower(), grid=grid, climate=climate, bed_type=bed_type)
try:
    os.remove(submit)
except OSError:
    pass

with open(submit, 'w') as f:

    f.write('#!/bin/bash\n')
    for k in range(len(scripts)):
        f.write('JOBID=$({batch_submit} {script})\n'.format(batch_submit=batch_system['submit'], script=scripts[k]))

print("\nRun {} to submit all jobs to the scheduler\n".format(submit))

