#!/usr/bin/env python
# Copyright (C) 2016 Andy Aschwanden

import itertools
from collections import OrderedDict
import os
from argparse import ArgumentParser
import sys
sys.path.append('../resources/')
from resources import *
import numpy as np

grid_choices = [18000, 9000, 6000, 4500, 3600, 1800, 1500, 1200, 900, 600, 450, 300, 150]

# set up the option parser
parser = ArgumentParser()
parser.description = "Generating scripts for relaxation simulations."
parser.add_argument("FILE", nargs=1)
parser.add_argument("-n", '--n_procs', dest="n", type=int,
                    help='''number of cores/processors. default=64.''', default=64)
parser.add_argument("-w", '--wall_time', dest="walltime",
                    help='''walltime. default: 12:00:00.''', default="12:00:00")
parser.add_argument("-q", '--queue', dest="queue", choices=list_queues(),
                    help='''queue. default=t1standard.''', default='t1standard')
parser.add_argument("--regrid_thickness", dest="regrid_thickness", action="store_true",
                    help="Regrid ice thickness from input file rather than from boot file", default=False)
parser.add_argument("--climate", dest="climate",
                    choices=['relax'],
                    help="Climate", default='relax')
parser.add_argument("--climate_file", dest="climate_file",
                    help="Climate file with temperature and climatic mass balance.", default=None)
parser.add_argument("--calving", dest="calving",
                    choices=['float_kill', 'ocean_kill', 'eigen_calving', 'stress_calving'],
                    help="claving", default='ocean_kill')
parser.add_argument("-d", "--domain", dest="domain",
                    choices=['gris', 'gris_ext'],
                    help="sets the modeling domain", default='gris_ext')
parser.add_argument("--duration", dest="dura", type=int,
                    help="Length of simulation in years (integers)", default=100)
parser.add_argument("-f", "--o_format", dest="oformat",
                    choices=['netcdf3', 'netcdf4_parallel', 'pnetcdf'],
                    help="output format", default='netcdf4_parallel')
parser.add_argument("-g", "--grid", dest="grid", type=int,
                    choices=grid_choices,
                    help="horizontal grid resolution", default=9000)
parser.add_argument("--o_size", dest="osize",
                    choices=['small', 'medium', 'big', 'big_2d'],
                    help="output size type", default='big_2d')
parser.add_argument("-s", "--system", dest="system",
                    choices=['pleiades', 'fish', 'pacman', 'debug'],
                    help="computer system to use.", default='pacman')
parser.add_argument("-b", "--bed_type", dest="bed_type",
                    choices=list_bed_types(),
                    help="output size type", default='no_bath')
parser.add_argument("--forcing_type", dest="forcing_type",
                    choices=['ctrl', 'e_age'],
                    help="output size type", default='ctrl')
parser.add_argument("--stress_balance", dest="stress_balance",
                    choices=['sia', 'ssa+sia', 'ssa'],
                    help="stress balance solver", default='ssa+sia')
parser.add_argument("--dataset_version", dest="version",
                    choices=['2'],
                    help="input data set version", default='2')
parser.add_argument("--hydrology", dest="hydrology",
                    choices=['null', 'diffuse', 'routing', 'distributed'],
                    help="Basal hydrology model.", default='diffuse')


options = parser.parse_args()
filename = options.FILE[0]


nn = options.n
oformat = options.oformat
osize = options.osize
queue = options.queue
walltime = options.walltime
system = options.system

dura = options.dura
regridfile = filename
regrid_thickness = options.regrid_thickness
calving = options.calving
climate = options.climate
climate_file = options.climate_file
forcing_type = options.forcing_type
grid = options.grid
hydro = options.hydro
bed_type = options.bed_type
version = options.version
stress_balance = options.stress_balance

domain = options.domain
pism_exec = generate_domain(domain)
    
infile = ''
if domain.lower() in ('greenland_ext', 'gris_ext'):
    pism_dataname = 'pism_Greenland_ext_{}m_mcb_jpl_v{}_{}.nc'.format(grid, version, bed_type)
else:
    pism_dataname = 'pism_Greenland_{}m_mcb_jpl_v{}_{}.nc'.format(grid, version, bed_type)
    
pism_config = 'init_config'
pism_config_nc = '.'.join([pism_config, 'nc'])
pism_config_cdl = os.path.join('../config', '.'.join([pism_config, 'cdl']))
# Anaconda libssl problem on chinook
if system in ('chinook'):
    ncgen = '/usr/bin/ncgen'
else:
    ncgen = 'ncgen'
cmd = [ncgen, '-o',
       pism_config_nc, pism_config_cdl]
sub.call(cmd)


# ########################################################
# set up relaxation simulation
# ########################################################

sia_e = (3.0)
ppq = (0.6)
tefo = (0.02)
ssa_n = (3.25)
ssa_e = (1.0)

calving_thk_threshold_values = [300]
calving_k_values = [1e18]
phi_min_values = [5.0]
phi_max_values = [40.]
topg_min_values = [-700]
topg_max_values = [700]
combinations = list(itertools.product(calving_thk_threshold_values, calving_k_values, phi_min_values, phi_max_values, topg_min_values, topg_max_values))

regridvars = 'age,litho_temp,enthalpy,tillwat,bmelt,Href'
if regrid_thickness:
    regridvars = '{},thk'.format(regridvars)

tsstep = 'yearly'
exstep = '1'


scripts = []

start = 0
end = dura

for n, combination in enumerate(combinations):

    calving_thk_threshold, calving_k , phi_min, phi_max, topg_min, topg_max = combination

    ttphi = '{},{},{},{}'.format(phi_min, phi_max, topg_min, topg_max)

    name_options = OrderedDict()
    name_options['sia_e'] = sia_e
    name_options['ppq'] = ppq
    name_options['tefo'] = tefo
    name_options['ssa_n'] = ssa_n
    name_options['ssa_e'] = ssa_e
    name_options['phi_min'] = phi_min
    name_options['phi_max'] = phi_max
    name_options['topg_min'] = topg_min
    name_options['topg_max'] = topg_max
    name_options['calving'] = calving
    if calving in ('eigen_calving'):
        name_options['calving_k'] = calving
        name_options['calving_thk_threshold'] = calving
    name_options['forcing_type'] = forcing_type
    name_options['hydro'] = hydro
    
    vversion = 'v' + str(version)
    experiment =  '_'.join([climate, vversion, bed_type, '_'.join(['_'.join([k, str(v)]) for k, v in list(name_options.items())])])

        
    script = '{}_{}_g{}m_{}.sh'.format(climate, domain.lower(), grid, experiment)
    scripts.append(script)
    
    for filename in (script):
        try:
            os.remove(filename)
        except OSError:
            pass

    pbs_header = make_pbs_header(system, nn, walltime, queue)
            
    with open(script, 'w') as f:

        f.write(pbs_header)

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
        general_params_dict['config_override'] = pism_config_nc
        general_params_dict['age'] = ''
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

        stress_balance_params_dict = generate_stress_balance(stress_balance, sb_params_dict)
        climate_params_dict = generate_climate(climate, surface_given_file=climate_file)
        ocean_params_dict = generate_ocean('const', shelf_base_melt_rate=10.)
        hydro_params_dict = generate_hydrology(hydro)
        calving_params_dict = generate_calving(calving, ocean_kill_file=pism_dataname)

        exvars = "climatic_mass_balance_cumulative,tempsurf,diffusivity,temppabase,bmeltvelsurf_mag,mask,thk,topg,usurf,taud_mag,velsurf_mag,climatic_mass_balance,climatic_mass_balance_original,velbase_mag,tauc,taub_mag"
        spatial_ts_dict = generate_spatial_ts(outfile, exvars, exstep, start=start, end=end)
        scalar_ts_dict = generate_scalar_ts(outfile, tsstep, start=start, end=end)
        
        all_params_dict = merge_dicts(general_params_dict, grid_params_dict, stress_balance_params_dict, climate_params_dict, ocean_params_dict, hydro_params_dict, calving_params_dict, spatial_ts_dict, scalar_ts_dict)
        all_params = ' '.join([' '.join(['-' + k, str(v)]) for k, v in list(all_params_dict.items())])
        
        cmd = ' '.join([prefix, all_params, '2>&1 | tee job.${PBS_JOBID}'])

        f.write(cmd)
        f.write('\n')

        if vversion in ('v2', 'v2_1985'):
            mytype = "MO14 2015-04-27"
        else:
            import sys
            print(('TYPE {} not recognized, exiting'.format(vversion)))
            sys.exit(0)        
    
scripts = uniquify_list(scripts)

submit = 'submit_{domain}_g{grid}m_{climate}_{bed_type}.sh'.format(domain=domain.lower(), grid=grid, climate=climate, bed_type=bed_type)
try:
    os.remove(submit)
except OSError:
    pass

with open(submit, 'w') as f:

    f.write('#!/bin/bash\n')

    for k in range(len(scripts)):
        f.write('JOBID=$(qsub {script})\n'.format(script=scripts[k]))

print(("\nRun {} to submit all jobs to the scheduler\n".format(submit)))

