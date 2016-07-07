#!/usr/bin/env python
# Copyright (C) 2015 Andy Aschwanden

import itertools
from collections import OrderedDict
import os
try:
    import subprocess32 as sub
except:
    import subprocess as sub
from argparse import ArgumentParser
import sys
sys.path.append('../resources/')
from resources import *

grid_choices = [18000, 9000, 6000, 4500, 3600, 3000, 2400, 1800, 1500, 1200, 900, 600, 450, 300, 150]

# set up the option parser
parser = ArgumentParser()
parser.description = "Generating scripts for model initialization."
parser.add_argument("-n", '--n_procs', dest="n", type=int,
                    help='''number of cores/processors. default=140.''', default=140)
parser.add_argument("-w", '--wall_time', dest="walltime",
                    help='''walltime. default: 100:00:00.''', default="100:00:00")
parser.add_argument("-q", '--queue', dest="queue", choices=list_queues(),
                    help='''queue. default=long.''', default='long')
parser.add_argument("--climate", dest="climate",
                    choices=['const', 'paleo'],
                    help="Climate", default='paleo')
parser.add_argument("--calving", dest="calving",
                    choices=['float_kill', 'ocean_kill', 'eigen_calving', 'thickness_calving', 'vonmises_calving', 'hybrid_calving'],
                    help="claving", default='vonmises_calving')
parser.add_argument("-d", "--domain", dest="domain",
                    choices=['gris', 'gris_ext'],
                    help="sets the modeling domain", default='gris_ext')
parser.add_argument("-f", "--o_format", dest="oformat",
                    choices=['netcdf3', 'netcdf4_parallel', 'pnetcdf'],
                    help="output format", default='netcdf4_parallel')
parser.add_argument("-g", "--grid", dest="grid", type=int,
                    choices=grid_choices,
                    help="horizontal grid resolution", default=9000)
parser.add_argument("--o_dir", dest="odir",
                    help="output directory. Default: current directory", default='foo')
parser.add_argument("--o_size", dest="osize",
                    choices=['small', 'medium', 'big', '2dbig'],
                    help="output size type", default='2dbig')
parser.add_argument("-s", "--system", dest="system",
                    choices=list_systems(),
                    help="computer system to use.", default='pleiades_broadwell')
parser.add_argument("-b", "--bed_type", dest="bed_type",
                    choices=list_bed_types(),
                    help="output size type", default='ctrl')
parser.add_argument("--bed_deformation", dest="bed_deformation",
                    choices=[None, 'lc', 'iso'],
                    help="Bed deformation model.", default='lc')
parser.add_argument("--forcing_type", dest="forcing_type",
                    choices=['ctrl', 'e_age'],
                    help="output size type", default='ctrl')
parser.add_argument("--hydrology", dest="hydrology",
                    choices=['null', 'diffuse', 'routing'],
                    help="Basal hydrology model.", default='diffuse')
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

nn = options.n
odir = options.odir
oformat = options.oformat
osize = options.osize
queue = options.queue
walltime = options.walltime
system = options.system

bed_deformation = options.bed_deformation
bed_type = options.bed_type
calving = options.calving
climate = options.climate
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
    pism_dataname = 'pism_Greenland_ext_{}m_mcb_jpl_v{}_{}.nc'.format(grid, version, bed_type)
else:
    pism_dataname = 'pism_Greenland_{}m_mcb_jpl_v{}_{}.nc'.format(grid, version, bed_type)

regridvars = 'litho_temp,enthalpy,age,tillwat,bmelt,Href,thk'
save_times = [-125000, -25000, -20000, -15000, -11700, -1000, -500, -200, -100, -5]

    
pism_config = 'init_config'
pism_config_nc = '.'.join([pism_config, 'nc'])
pism_config_cdl = os.path.join('../config', '.'.join([pism_config, 'cdl']))
if not os.path.isfile(pism_config_nc):
    cmd = ['ncgen', '-o',
           pism_config_nc, pism_config_cdl]
    sub.call(cmd)
if not os.path.isdir(odir):
    os.mkdir(odir)
odir_tmp = '_'.join([odir, 'tmp'])
if not os.path.isdir(odir_tmp):
    os.mkdir(odir_tmp)

# ########################################################
# set up model initialization
# ########################################################

sia_e = (3.0)
ssa_n = (3.25)
ssa_e = (1.0)

eigen_calving_k = 1e18

ocean_melt_power_values = [1, 2]
thickness_calving_threshold_vales = [50, 75]
ppq_values = [0.33]
tefo_values = [0.020]
phi_min_values = [5.0]
phi_max_values = [40.]
topg_min_values = [-700]
topg_max_values = [700]
combinations = list(itertools.product(ocean_melt_power_values, thickness_calving_threshold_vales, ppq_values, tefo_values, phi_min_values, phi_max_values, topg_min_values, topg_max_values))

tsstep = 'yearly'
exstep = 100

scripts = []
scripts_post = []

paleo_start_year = -125000
paleo_end_year = 0
restart_step = 25000

for n, combination in enumerate(combinations):

    ocean_melt_power, thickness_calving_threshold, ppq, tefo, phi_min, phi_max, topg_min, topg_max = combination

    ttphi = '{},{},{},{}'.format(phi_min, phi_max, topg_min, topg_max)

    name_options = OrderedDict()
    name_options['ppq'] = ppq
    name_options['tefo'] = tefo
    name_options['bed_deformation'] = bed_deformation
    name_options['calving'] = calving
    if calving in ('thickness_calving', 'eigen_calving', 'vonmises_calving', 'hybrid_calving'):
        name_options['threshold'] = thickness_calving_threshold
    name_options['ocean_n'] = ocean_melt_power
    name_options['forcing_type'] = forcing_type
    
    vversion = 'v' + str(version)
    full_exp_name =  '_'.join([climate, vversion, bed_type, '_'.join(['_'.join([k, str(v)]) for k, v in name_options.items()])])
    full_outfile = '{domain}_g{grid}m_{experiment}.nc'.format(domain=domain.lower(),grid=grid, experiment=full_exp_name)

    outfiles = []

    for start in range(paleo_start_year, paleo_end_year, restart_step):

        end = start + restart_step

        experiment =  '_'.join([climate, vversion, bed_type, '_'.join(['_'.join([k, str(v)]) for k, v in name_options.items()]), '{}'.format(start), '{}'.format(end)])

        script = 'init_{}_g{}m_{}.sh'.format(domain.lower(), grid, experiment)
        scripts.append(script)

        for filename in (script):
            try:
                os.remove(filename)
            except OSError:
                pass

        batch_header, batch_system = make_batch_header(system, nn, walltime, queue)

        with open(script, 'w') as f:

            f.write(batch_header)

            outfile = '{domain}_g{grid}m_straight_{experiment}.nc'.format(domain=domain.lower(),grid=grid, experiment=experiment)

            prefix = generate_prefix_str(pism_exec)

            general_params_dict = OrderedDict()
            if start == paleo_start_year:
                general_params_dict['bootstrap'] = ''
                general_params_dict['i'] = pism_dataname
            else:
                general_params_dict['i'] = regridfile
            general_params_dict['ys'] = start
            general_params_dict['ye'] = end
            general_params_dict['o'] = os.path.join(odir, outfile)
            general_params_dict['o_format'] = oformat
            general_params_dict['o_size'] = osize
            general_params_dict['config_override'] = pism_config_nc
            general_params_dict['age'] = ''
            if bed_deformation is not None:
                general_params_dict['bed_def'] = bed_deformation
            if forcing_type in ('e_age'):
                general_params_dict['e_age_coupling'] = ''

            if start == paleo_start_year:
                grid_params_dict = generate_grid_description(grid, domain)

            sb_params_dict = OrderedDict()
            sb_params_dict['sia_e'] = sia_e
            sb_params_dict['ssa_e'] = ssa_e
            sb_params_dict['ssa_n'] = ssa_n
            sb_params_dict['pseudo_plastic_q'] = ppq
            sb_params_dict['till_effective_fraction_overburden'] = tefo
            if start == paleo_start_year:
                sb_params_dict['topg_to_phi'] = ttphi
            sb_params_dict['vertical_velocity_approximation'] = vertical_velocity_approximation

            stress_balance_params_dict = generate_stress_balance(stress_balance, sb_params_dict)
            climate_params_dict = generate_climate(climate)
            ocean_params_dict = generate_ocean(climate, ocean_given_file='ocean_forcing_latitudinal_ctrl.nc', ocean_frac_mass_flux_file='pism_fSMB_n_{}.nc'.format(ocean_melt_power))
            hydro_params_dict = generate_hydrology(hydrology)
            calving_params_dict = generate_calving(calving, thickness_calving_threshold=thickness_calving_threshold, eigen_calving_k=eigen_calving_k, ocean_kill_file=pism_dataname)

            exvars = init_spatial_ts_vars()
            spatial_ts_dict = generate_spatial_ts(full_outfile, exvars, exstep, odir=odir_tmp, split=True)
            scalar_ts_dict = generate_scalar_ts(outfile, tsstep,
                                                start=paleo_start_year,
                                                end=paleo_end_year,
                                                odir=odir)
            snap_shot_dict = generate_snap_shots(outfile, save_times, odir=odir)

            if start == paleo_start_year:
                all_params_dict = merge_dicts(general_params_dict, grid_params_dict, stress_balance_params_dict, climate_params_dict, ocean_params_dict, hydro_params_dict, calving_params_dict, spatial_ts_dict, scalar_ts_dict)
            else:
                all_params_dict = merge_dicts(general_params_dict, stress_balance_params_dict, climate_params_dict, ocean_params_dict, hydro_params_dict, calving_params_dict, spatial_ts_dict, scalar_ts_dict, snap_shot_dict)                
            all_params = ' '.join([' '.join(['-' + k, str(v)]) for k, v in all_params_dict.items()])

            cmd = ' '.join([batch_system['mpido'], prefix, all_params, '> {outdir}/job.${batch}  2>&1'.format(outdir=odir,batch=batch_system['job_id'])])

            f.write(cmd)
            f.write('\n')

            regridfile = os.path.join(odir, outfile)
            outfiles.append(outfile)


    script_post = 'init_{}_g{}m_{}_post.sh'.format(domain.lower(), grid, full_exp_name)
    scripts_post.append(script_post)

    with open(script_post, 'w') as f:
        extra_file = spatial_ts_dict['extra_file']
        myfiles = ' '.join(['{}_{}.000.nc'.format(extra_file, k) for k in range(paleo_start_year+exstep, paleo_end_year, exstep)])
        myoutfile = extra_file + '.nc'
        myoutfile = os.path.join(odir, os.path.split(myoutfile)[-1])
        cmd = ' '.join(['ncrcat -O -4 -L 3', myfiles, myoutfile, '\n'])
        f.write(cmd)
        for myfile in outfiles:
            cmd = ' '.join(['ncks -O -4 -L 3', os.path.join(odir, myfile), os.path.join(odir, myfile), '\n'])
            f.write(cmd)

    
scripts = uniquify_list(scripts)
scripts_post = uniquify_list(scripts_post)
print '\n'.join([script for script in scripts])
print('written')
