"""
resources
=========

Provides:
  - general resources such as grid constructors, calving, hydrology, etc.
    for the Greenland Ice Sheet and sub-regions thereof

"""

from collections import OrderedDict
import os


def generate_prefix_str(pism_exec):
    '''
    Generate prefix string.

    Returns: string
    '''

    try:
        p = os.environ['PISM_PREFIX']  + pism_exec
    except:
        p  = pism_exec
    
    return p


def generate_domain(domain):
    '''
    Generate domain specific options

    Returns: string
    '''
    
    if domain.lower() in ('greenland', 'gris', 'gris_ext'):
        pism_exec = 'pismr'
    elif domain.lower() in ('og'):
        pism_exec = 'pismo -no_model_strip 0 -calving_wrap_around'
    elif domain.lower() in ('hia'):
        x_min = -652200.
        x_max = -232600.
        y_min = -1263900.
        y_max = -943500.
        pism_exec = '''pismo -x_range {x_min},{x_max} -y_range {y_min},{y_max} -bootstrap'''.format(x_min=x_min, x_max=x_max, y_min=y_min, y_max=y_max)        
    elif domain.lower() in ('jakobshavn', 'jib'):
        x_min = -280000.
        x_max = 320000.
        y_min = -2410000.
        y_max = -2020000.
        pism_exec = '''pismo -x_range {x_min},{x_max} -y_range {y_min},{y_max} -bootstrap'''.format(x_min=x_min, x_max=x_max, y_min=y_min, y_max=y_max)
    else:
        print('Domain {} not recognized, exiting'.format(domain))
        import sys
        sys.exit(0)

    return pism_exec


def default_spatial_ts_vars():
    '''
    Returns a list of commonly-used extra vars
    '''
    
    exvars = ['basal_mass_balance_average',
              'beta',
              'bmelt',
              'cell_area',
              'dHdt',
              'diffusivity',
              'discharge_mass_flux',
              'eigen_calving_rate',
              'flux_divergence',
              'height_above_flotation',
              'ice_mass',
              'mask',
              'lat',
              'lat_bnds',
              'lon',
              'lon_bnds',
              'saccum',
              'saccum_average',
              'smelt',
              'smelt_average',
              'srunoff',
              'srunoff_average',              
              'strain_rates',
              'surface_mass_balance_average',
              'taub_mag',
              'tauc',
              'taud_mag',
              'tempicethk_basal',
              'temppabase',
              'tempsurf',
              'thk',
              'tillwat',
              'topg',
              'usurf',
              'velbar',
              'velbase',
              'velbase_mag',
              'velsurf',
              'velsurf_mag',
              'vonmises_calving_rate',
              'vonmises_stress',
              'wvelbase',
              'wvelsurf']
    
    return exvars

def stability_spatial_ts_vars():
    '''
    Returns a list of commonly-used extra vars
    '''
    
    exvars = ['basal_mass_balance',
              'beta',
              'cell_area',
              'dbdt',
              'dHdt',
              'diffusivity',
              'discharge_mass_flux',
              'flux_divergence',
              'height_above_flotation',
              'ice_mass',
              'mask',
              'lat',
              'lat_bnds',
              'lon',
              'lon_bnds',
              'saccum_average',
              'sftgif',
              'smelt_average',
              'srunoff_average',
              'surface_mass_balance',
              'taub_mag',
              'tauc',
              'tempicethk',
              'tempicethk_basal',
              'temppabase',
              'tempsurf',
              'thk',
              'topg',
              'usurf',
              'velbase',
              'velbase_mag',
              'velsurf',
              'velsurf_mag']
    
    return exvars


def glacial_spatial_ts_vars():
    '''
    Returns a list of commonly-used extra vars
    '''
    
    exvars = ['basal_mass_balance_average',
              'bmelt',
              'cell_area',
              'dHdt',
              'discharge_mass_flux',
              'eigen_calving_rate',
              'height_above_flotation',
              'ice_mass',
              'mask',
              'lat',
              'lat_bnds',
              'lon',
              'lon_bnds',
              'saccum_average',
              'smelt_average',
              'srunoff_average',              
              'sea_level',
              'surface_mass_balance_average',
              'temppabase',
              'tempsurf',
              'thk',
              'topg',
              'topg_sl_adjusted',
              'usurf',
              'velbase',
              'velbase_mag',
              'velsurf',
              'velsurf_mag',
              'vonmises_calving_rate',
              'vonmises_stress']
    
    return exvars


def calibrate_spatial_ts_vars():
    '''
    Returns a list of essential extra vars
    '''
    
    exvars = ['flux_divergence',
              'dHdt',
              'mask',
              'lat',
              'lat_bnds',
              'lon',
              'lon_bnds',
              'surface_mass_balance_average',
              'thk',
              'topg',
              'usurf',
              'velbase_mag',
              'velsurf_mag']
    
    return exvars

def essential_spatial_ts_vars():
    '''
    Returns a list of essential extra vars
    '''
    
    exvars = ['beta',
              'bmelt',
              'dHdt',
              'mask',
              'lat',
              'lat_bnds',
              'lon',
              'lon_bnds',
              'surface_mass_balance_average',
              'taub_mag',
              'tauc',
              'taud_mag',
              'tempsurf',
              'thk',
              'tillwat',
              'topg',
              'topg_sl_adjusted',
              'usurf',
              'velbase',
              'velbase_mag',
              'velsurf',
              'velsurf_mag',
              'wvelbase',
              'wvelsurf']
    
    return exvars


def ismip6_spatial_ts_vars():
    '''
    Returns a list of commonly-used extra vars
    '''
    
    exvars = ['basal_mass_balance_average',
              'beta',
              'bmelt',
              'cell_area',
              'dbdt',
              'dHdt',
              'diffusivity',
              'discharge_mass_flux',
              'flux_divergence',
              'height_above_flotation',
              'hfgeoubed',
              'mask',
              'lat',
              'lat_bnds',
              'lon',
              'lon_bnds',
              'nuH',
              'relative_flotation',
              'sftgrf',
              'sftflf',
              'sftgif',
              'surface_mass_balance_average',
              'taub_mag',
              'tauc',
              'taud_mag',
              'tempicethk_basal',
              'tempbase',
              'temppabase',
              'tempsurf',
              'thk',
              'topg',
              'usurf',
              'velbar',
              'velbase',
              'velbase_mag',
              'velsurf',
              'velsurf_mag',
              'wvelbase',
              'wvelsurf']
    
    return exvars


def init_spatial_ts_vars():
    '''
    Returns a list of commonly-used extra vars for initialization
    '''
    
    exvars = ['basal_mass_balance_average',
              'beta',
              'bmelt',
              'bwat',
              'bwatvel',
              'bwp',
              'cell_area',
              'dbdt',
              'dHdt',
              'diffusivity',
              'discharge_mass_flux',
              'eigen_calving_rate',
              'ice_mass',
              'mask',
              'lat',
              'lat_bnds',
              'lon',
              'lon_bnds',
              'nuH',
              'saccum_average',
              'smelt_average',
              'srunoff_average',              
              'sea_level',
              'strain_rates',
              'surface_mass_balance_average',
              'taub_mag',
              'tauc',
              'taud_mag',
              'tempicethk_basal',
              'temppabase',
              'tempsurf',
              'thk',
              'topg',
              'topg_sl_adjusted',
              'usurf',
              'velbase',
              'velbase_mag',
              'velsurf',
              'velsurf_mag',
              'vonmises_calving_rate',
              'vonmises_stress']
    
    return exvars


def generate_spatial_ts(outfile, exvars, step, start=None, end=None, split=None, odir=None):
    '''
    Return dict to generate spatial time series

    Returns: OrderedDict
    '''

    # check if list or comma-separated string is given.
    try:
        exvars = ','.join(exvars)
    except:
        pass

    params_dict = OrderedDict()
    if split is True:
        outfile, ext = os.path.splitext(outfile)
        params_dict['extra_split'] = ''
    if odir is None:
        params_dict['extra_file'] = 'ex_' + outfile
    else:
        params_dict['extra_file'] = os.path.join(odir, 'ex_' + outfile)
    params_dict['extra_vars'] = exvars
        
    if step is None:
        step = 'yearly'

    if (start is not None and end is not None):
        times = '{start}:{step}:{end}'.format(start=start, step=step, end=end)
    else:
        times = step
        
    params_dict['extra_times'] = times        
  
    return params_dict


def generate_scalar_ts(outfile, step, start=None, end=None, odir=None):
    '''
    Return dict to create scalar time series

    Returns: OrderedDict
    '''

    params_dict = OrderedDict()
    if odir is None:
        params_dict['ts_file'] = 'ts_' + outfile
    else:
        params_dict['ts_file'] = os.path.join(odir, 'ts_' + outfile)
    
    if step is None:
        step = 'yearly'

    if (start is not None and end is not None):
        times = '{start}:{step}:{end}'.format(start=start, step=step, end=end)
    else:
        times = step
    params_dict['ts_times'] = times

    return params_dict


def generate_snap_shots(outfile, times, odir=None):
    '''
    Return dict to generate snap shots

    Returns: OrderedDict
    '''

    params_dict = OrderedDict()
    if odir is None:
        params_dict['save_file'] = 'save_' + outfile.split('.nc')[0]
    else:
        params_dict['save_file'] = os.path.join(odir, 'save_' + outfile.split('.nc')[0])

    params_dict['save_times'] = ','.join(str(e) for e in times)
    params_dict['save_split'] = ''
    params_dict['save_force_output_times'] = ''

    return params_dict


def generate_grid_description(grid_resolution, domain, restart=False):
    '''
    Generate grid description dict

    Returns: OrderedDict
    '''

    if domain.lower() in ('greenland_ext', 'gris_ext', 'greenland', 'gris'):
    
        if domain.lower() in ('greenland_ext', 'gris_ext'):
            mx_max = 15120
            my_max = 19680
        else:
            mx_max = 10560
            my_max = 18240

        resolution_max = 150

        accepted_resolutions = (150, 300, 450, 600, 900, 1200, 1500, 1800, 2400, 3000, 3600, 4500, 6000, 9000, 18000, 36000)

        try:
            grid_resolution in accepted_resolutions
            pass
        except:
            print('grid resolution {}m not recognized'.format(grid_resolution))

        if grid_resolution < 1200:
            skip_max = 200
            mz = 501
            mzb = 41
        elif (grid_resolution >= 1200) and (grid_resolution < 4500):
            skip_max = 100
            mz = 251
            mzb = 21
        elif (grid_resolution >= 4500) and (grid_resolution < 18000):
            skip_max = 50
            mz = 251
            mzb = 21
        else:
            skip_max = 20
            mz = 101
            mzb = 11
            
    elif domain.lower() in ('og'):

        mx_max = 2601
        my_max = 1001

        resolution_max = 100

        accepted_resolutions = (100, 200, 250, 500, 1000, 2000, 5000)

        try:
            grid_resolution in accepted_resolutions
            pass
        except:
            print('grid resolution {}m not recognized'.format(grid_resolution))

        skip_max = 200
        mz = 401
        mzb = 0

    grid_div = (grid_resolution / resolution_max)
              
    mx = mx_max / grid_div
    my = my_max / grid_div

    horizontal_grid = OrderedDict()
    horizontal_grid['Mx'] = mx
    horizontal_grid['My'] = my

    vertical_grid = OrderedDict()
    ## This sould be a temporary hack to restart from an older simulation
    if domain.lower() in ('gris', 'og'):
        vertical_grid['Lz'] = 4000
    else:
        vertical_grid['Lz'] = 5000
    vertical_grid['Lbz'] = 2000
    vertical_grid['z_spacing'] = 'equal'
    vertical_grid['Mz'] = mz
    vertical_grid['Mbz'] = mzb

    grid_options = {}
    grid_options['skip'] = ''
    grid_options['skip_max'] = skip_max

    grid_dict = merge_dicts(horizontal_grid, vertical_grid, grid_options)

    if restart is True:
        return grid_options
    else:
        return grid_dict


def merge_dicts(*dict_args):
    '''
    Given any number of dicts, shallow copy and merge into a new dict,
    precedence goes to key value pairs in latter dicts.

    Returns: OrderedDict
    '''
    result = OrderedDict()
    for dictionary in dict_args:
        result.update(dictionary)
    return result


def uniquify_list(seq, idfun=None):
    '''
    Remove duplicates from a list, order preserving.
    From http://www.peterbe.com/plog/uniqifiers-benchmark
    '''

    if idfun is None:
        def idfun(x): return x
    seen = {}
    result = []
    for item in seq:
        marker = idfun(item)
        if marker in seen:
            continue
        seen[marker] = 1
        result.append(item)
    return result


def generate_stress_balance(stress_balance, additional_params_dict):
    '''
    Generate stress balance params

    Returns: OrderedDict
    '''

    accepted_stress_balances = ('sia', 'ssa+sia')

    if stress_balance not in accepted_stress_balances:
        print('{} not in {}'.format(stress_balance, accepted_stress_balances))
        print('available stress balance solvers are {}'.format(accepted_stress_balances))
        import sys
        sys.exit(0)

    params_dict = OrderedDict()
    params_dict['stress_balance'] = stress_balance
    if stress_balance in ('ssa+sia'):
        params_dict['options_left'] = ''
        params_dict['cfbc'] = ''
        params_dict['kill_icebergs'] = ''
        params_dict['part_grid'] = ''
        params_dict['part_redist'] = ''
        params_dict['sia_flow_law'] = 'gpbld3'
        params_dict['pseudo_plastic'] = ''
        params_dict['tauc_slippery_grounding_lines'] = ''

    return merge_dicts(additional_params_dict, params_dict)


def generate_hydrology(hydro, **kwargs):
    '''
    Generate hydrology params

    Returns: OrderedDict
    '''
    
    params_dict = OrderedDict()
    if hydro in ('null'):
        params_dict['hydrology'] = 'null'
    elif hydro in ('diffuse'):
        params_dict['hydrology'] = 'null'
        params_dict['hydrology_null_diffuse_till_water'] = ''
    elif hydro in ('routing'):
        params_dict['hydrology'] = 'routing'
    elif hydro in ('distributed'):
        params_dict['hydrology'] = 'distributed'
    else:
        print('hydrology {} not recognized, exiting'.format(hydro))
        import sys
        sys.exit(0)

    return merge_dicts(params_dict, kwargs)


def generate_calving(calving, **kwargs):
    '''
    Generate calving params

    Returns: OrderedDict
    '''

    params_dict = OrderedDict()
    if calving in ('ocean_kill'):
        params_dict['calving'] = calving
    elif calving in ('thickness_calving'):
        params_dict['calving'] = calving
    elif calving in ('eigen_calving', 'vonmises_calving'):
        params_dict['calving'] = '{},thickness_calving'.format(calving)
    elif calving in ('hybrid_calving'):
        params_dict['calving'] = 'eigen_calving,vonmises_calving,thickness_calving'
    elif calving in ('float_kill', 'float_kill,ocean_kill', 'vonmises_calving,ocean_kill', 'eigen_calving,ocean_kill'):
        params_dict['calving'] = calving
    else:
        print('calving {} not recognized, exiting'.format(calving))
        import sys
        sys.exit(0)
    if 'frontal_melt' in kwargs and kwargs['frontal_melt'] is True:
        params_dict['calving'] += ',frontal_melt'
        # need to delete the entry
        del kwargs['frontal_melt']
    return merge_dicts(params_dict, kwargs)


def generate_climate(climate, **kwargs):
    '''
    Generate climate params

    Returns: OrderedDict
    '''
    
    params_dict = OrderedDict()
    if climate in ('paleo'):
        params_dict['atmosphere'] = 'searise_greenland,delta_T,paleo_precip'
        if 'atmosphere_paleo_precip_file' not in kwargs:
            params_dict['atmosphere_paleo_precip_file'] = 'pism_dT.nc'
        if 'atmosphere_delta_T_file' not in kwargs:
            params_dict['atmosphere_delta_T_file'] = 'pism_dT.nc'
        params_dict['surface'] = 'pdd'
        params_dict['pdd_std_dev_method'] = 'quadratic'  # Wake and Marshall (2015)
    elif climate in ('abrupt_glacial'):
        params_dict['atmosphere'] = 'searise_greenland,delta_T,paleo_precip'
        if 'atmosphere_paleo_precip_file' not in kwargs:
            params_dict['atmosphere_paleo_precip_file'] = 'pism_abrupt_glacial_climate_forcing.nc'
        if 'atmosphere_delta_T_file' not in kwargs:
            params_dict['atmosphere_delta_T_file'] = 'pism_abrupt_glacial_climate_forcing.nc'
        params_dict['surface'] = 'pdd'
        params_dict['pdd_std_dev_method'] = 'quadratic'  # Wake and Marshall (2015)
    elif climate in ('warming'):
        params_dict['atmosphere'] = 'given,lapse_rate,delta_T'
        if 'atmosphere_delta_T_file' not in kwargs:
            params_dict['atmosphere_delta_T_file'] = 'pism_warming_climate_forcing.nc'
        params_dict['surface'] = 'pdd'
    elif climate in ('warming_precip'):
        params_dict['atmosphere'] = 'given,lapse_rate,delta_T,paleo_precip'
        if 'atmosphere_paleo_precip_file' not in kwargs:
            params_dict['atmosphere_paleo_precip_file'] = 'pism_warming_climate_forcing.nc'
        if 'atmosphere_delta_T_file' not in kwargs:
            params_dict['atmosphere_delta_T_file'] = 'pism_warming_climate_forcing.nc'
        params_dict['surface'] = 'pdd'
    elif climate in ('paleo_const'):
        params_dict['atmosphere'] = 'searise_greenland'
        params_dict['surface'] = 'given'
    elif climate in ('pdd'):
        params_dict['atmosphere'] = 'given'
        if 'atmosphere_given_file' not in kwargs:
            params_dict['atmosphere_given_file'] = 'foo.nc'
        params_dict['surface'] = 'pdd'
    elif climate in ('pdd_lapse'):
        params_dict['atmosphere'] = 'given,lapse_rate'
        if 'atmosphere_given_file' not in kwargs:
            params_dict['atmosphere_given_file'] = 'foo.nc'
        if 'temp_lapse_rate' not in kwargs:
            params_dict['temp_lapse_rate'] = 0.0
        params_dict['surface'] = 'pdd'
    elif climate in ('const'):
        params_dict['surface'] = 'given'
    elif climate in ('relax', 'given'):
        params_dict['surface'] = 'given'
    elif climate in ('flux'):
        params_dict['surface'] = 'given,forcing'
    elif climate in ('elevation'):
        params_dict['surface'] = 'elevation'
    else:
        print('climate {} not recognized, exiting'.format(climate))
        import sys
        sys.exit(0)
        
    return merge_dicts(params_dict, kwargs)

        
def generate_ocean(ocean, **kwargs):
    '''
    Generate ocean params

    Returns: OrderedDict
    '''

    params_dict = OrderedDict()
    if ocean == 'paleo':
        params_dict['ocean'] = 'given,delta_SL,frac_SMB'
        if 'ocean_delta_SL_file' not in kwargs:
            params_dict['ocean_delta_SL_file'] = 'pism_dSL.nc'
    elif ocean == 'abrupt_glacial':
        params_dict['ocean'] = 'given,delta_SL,frac_SMB'
        if 'ocean_delta_SL_file' not in kwargs:
            params_dict['ocean_delta_SL_file'] = 'pism_abrupt_glacial_climate_forcing.nc'
    elif ocean == 'abrupt_glacial_mbp':
        params_dict['ocean'] = 'given,delta_SL,frac_SMB,delta_MBP'
        if 'ocean_delta_SL_file' not in kwargs:
            params_dict['ocean_delta_SL_file'] = 'pism_abrupt_glacial_climate_forcing.nc'
    elif ocean == 'paleo_mbp':
        params_dict['ocean'] = 'given,delta_SL,frac_SMB,delta_MBP'
        if 'ocean_delta_SL_file' not in kwargs:
            params_dict['ocean_delta_SL_file'] = 'pism_dSL.nc'
    elif ocean == 'warming':
        params_dict['ocean'] = 'given,frac_SMB'
    elif ocean == 'warming_3eqn':
        params_dict['ocean'] = 'th,delta_T'
    elif ocean == 'paleo_const':
        params_dict['ocean'] = 'given,delta_SL'        
    elif ocean == 'paleo_const_mbp':
        params_dict['ocean'] = 'given,delta_SL,delta_MBP'
    elif ocean in ('given', 'relax'):
        params_dict['ocean'] = 'given'
    elif ocean in ('given_mbp'):
        params_dict['ocean'] = 'given,delta_MBP'
    elif ocean == 'const':
        params_dict['ocean'] = 'constant'
    else:
        print('ocean {} not recognized, exiting'.format(ocean))
        import sys
        sys.exit(0)

    return merge_dicts(params_dict, kwargs)


def list_systems():

    '''
    Return a list of supported systems.
    '''
    
    list = ['debug',
            'chinook',
            'electra_broadwell',
            'fish',
            'pacman',
            'pleiades',
            'pleiades_ivy',
            'pleiades_haswell',
            'pleiades_broadwell']
    
    return list


def list_queues():

    '''
    Return a list of supported queues.
    '''
    
    list = ['debug',
            'devel',
            'gpu',
            'gpu_long',
            'normal',
            'long',
            'standard',
            'standard_16',
            't1standard',
            't2standard',
            't1small',
            't2small']
    
    return list



def list_bed_types():

    '''
    Return a list of supported bed types.
    '''
    
    list = ['ctrl',
            'cresis',
            'cresisp',
            'minus',
            'plus',
            'ba01_bed',
            '970mW_hs',
            'jak_1985',
            'no_bath']
    
    return list


def make_batch_header(system, cores, walltime, queue):
    '''
    Generate header file for different HPC system.

    Returns: String
    '''
    
    systems = {}
    mpido = 'mpiexec -n {cores}'.format(cores=cores)
    systems['debug'] = {'mpido' : mpido,
                        'submit': 'echo',
                        'job_id' : 'PBS_JOBID'}
    mpido = 'mpiexec -n {cores}'.format(cores=cores)
    systems['fish'] = {'mpido': 'aprun -n {cores}'.format(cores=cores),
                       'submit' : 'qsub',
                       'work_dir' : 'PBS_O_WORKDIR',
                       'job_id' : 'PBS_JOBID',
                       'queue' : {
                           'gpu' : 16,
                           'gpu_long' : 16,
                           'standard' : 12 }}
    mpido = 'mpirun -np {cores}'.format(cores=cores)
    systems['pacman'] = {'mpido' : mpido,
                         'submit' : 'qsub',
                         'work_dir' : 'PBS_O_WORKDIR',
                         'job_id' : 'PBS_JOBID',
                         'queue' : {
                             'standard_16' : 16 }}
    mpido = 'mpirun -np {cores} -machinefile ./nodes_$SLURM_JOBID'.format(cores=cores)                         
    systems['chinook'] = {'mpido' : mpido,
                          'submit' : 'sbatch',
                          'work_dir' : 'SLURM_SUBMIT_DIR',
                          'job_id' : 'SLURM_JOBID',
                          'queue' : {
                              't1standard' : 24,
                              't1small' : 24,
                              't2standard' : 24,
                              't2small' : 24,
                              'debug' : 24}}
    mpido = 'mpiexec.hydra -n {cores}'.format(cores=cores)
    systems['electra_broadwell'] = {'mpido' : mpido,
                           'submit' : 'qsub',
                           'work_dir' : 'PBS_O_WORKDIR',
                           'job_id' : 'PBS_JOBID',
                           'queue' : {
                               'long' : 28,
                               'normal': 28}}
    systems['pleiades'] = {'mpido' : mpido,
                           'submit' : 'qsub',
                           'work_dir' : 'PBS_O_WORKDIR',
                           'job_id' : 'PBS_JOBID',
                           'queue' : {
                               'long' : 20,
                               'normal': 20}}
    systems['pleiades_haswell'] = {'mpido' : mpido,
                           'submit' : 'qsub',
                           'work_dir' : 'PBS_O_WORKDIR',
                           'job_id' : 'PBS_JOBID',
                           'queue' : {
                               'long' : 24,
                               'normal': 24}}
    systems['pleiades_ivy'] = {'mpido' : mpido,
                           'submit' : 'qsub',
                           'work_dir' : 'PBS_O_WORKDIR',
                           'job_id' : 'PBS_JOBID',
                           'queue' : {
                               'long' : 20,
                               'normal': 20}}
    systems['pleiades_broadwell'] = {'mpido' : mpido,
                           'submit' : 'qsub',
                           'work_dir' : 'PBS_O_WORKDIR',
                           'job_id' : 'PBS_JOBID',
                           'queue' : {
                               'long' : 28,
                               'normal': 28}}

    assert system in systems.keys()
    if system not in 'debug':
        assert queue in systems[system]['queue'].keys()
        assert cores > 0

        ppn = systems[system]['queue'][queue]
        nodes = cores / ppn

    if system in ('debug'):

        header = ''
        
    elif system in ('chinook'):
        
        header = """#!/bin/sh
#SBATCH --partition={queue}
#SBATCH --ntasks={cores}
#SBATCH --tasks-per-node={ppn}
#SBATCH --time={walltime}
#SBATCH --mail-user=aaschwanden@alaska.edu
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --output=pism.%j

module list

cd $SLURM_SUBMIT_DIR

# Generate a list of compute node hostnames reserved for this job,
# this ./nodes file is necessary for slurm to spawn mpi processes
# across multiple compute nodes
srun -l /bin/hostname | sort -n | awk \'{{print $2}}\' > ./nodes_$SLURM_JOBID

""".format(queue=queue, walltime=walltime, nodes=nodes, ppn=ppn, cores=cores)
    elif system in ('electra_broadwell'):
        
        header = """#PBS -S /bin/bash
#PBS -N cfd
#PBS -l walltime={walltime}
#PBS -m e
#PBS -q {queue}
#PBS -lselect={nodes}:ncpus={ppn}:mpiprocs={ppn}:model=bro_ele
#PBS -j oe

module list

cd $PBS_O_WORKDIR

""".format(queue=queue, walltime=walltime, nodes=nodes, ppn=ppn, cores=cores)
    elif system in ('pleiades'):
        
        header = """#PBS -S /bin/bash
#PBS -N cfd
#PBS -l walltime={walltime}
#PBS -m e
#PBS -q {queue}
#PBS -lselect={nodes}:ncpus={ppn}:mpiprocs={ppn}:model=ivy
#PBS -j oe

module list

cd $PBS_O_WORKDIR

""".format(queue=queue, walltime=walltime, nodes=nodes, ppn=ppn, cores=cores)
    elif system in ('pleiades_broadwell'):
        
        header = """#PBS -S /bin/bash
#PBS -N cfd
#PBS -l walltime={walltime}
#PBS -m e
#PBS -q {queue}
#PBS -lselect={nodes}:ncpus={ppn}:mpiprocs={ppn}:model=bro
#PBS -j oe

module list

cd $PBS_O_WORKDIR

""".format(queue=queue, walltime=walltime, nodes=nodes, ppn=ppn, cores=cores)
    elif system in ('pleiades_haswell'):
        
        header = """#PBS -S /bin/bash
#PBS -N cfd
#PBS -l walltime={walltime}
#PBS -m e
#PBS -q {queue}
#PBS -lselect={nodes}:ncpus={ppn}:mpiprocs={ppn}:model=has
#PBS -j oe

module list

cd $PBS_O_WORKDIR

""".format(queue=queue, walltime=walltime, nodes=nodes, ppn=ppn, cores=cores)
    elif system in ('pleiades_ivy'):
        
        header = """#PBS -S /bin/bash
#PBS -N cfd
#PBS -l walltime={walltime}
#PBS -m e
#PBS -q {queue}
#PBS -lselect={nodes}:ncpus={ppn}:mpiprocs={ppn}:model=ivy
#PBS -j oe

module list

cd $PBS_O_WORKDIR

""".format(queue=queue, walltime=walltime, nodes=nodes, ppn=ppn, cores=cores)
    else:
        header = """#!/bin/bash
#PBS -q {queue}
#PBS -l walltime={walltime}
#PBS -l nodes={nodes}:ppn={ppn}
#PBS -j oe

module list

cd $PBS_O_WORKDIR

""".format(queue=queue, walltime=walltime, nodes=nodes, ppn=ppn, cores=cores)

    return header, systems[system]

def make_batch_post_header(system):

    if system in ('electra_broadwell', 'pleiades', 'pleiades_ivy', 'pleiades_broadwell', 'pleiades_haswell'):

        header = """#PBS -S /bin/bash
#PBS -lselect=1:mem=94GB
#PBS -lwalltime=8:00:00
#PBS -q ldan

module list

cd $PBS_O_WORKDIR

"""
    elif system in ('chinook'):
        header = """#!/bin/bash
#PBS -q t2small
#PBS -l walltime=12:00:00
#PBS -l nodes=1:ppn=1
#PBS -j oe

module list

cd $PBS_O_WORKDIR

"""
    else:
        header = """#!/bin/bash

"""
    return header
