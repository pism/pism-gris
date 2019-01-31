"""
resources
=========

Provides:
  - general resources such as grid constructors, calving, hydrology, etc.
    for the Greenland Ice Sheet and sub-regions thereof

"""

from collections import OrderedDict
import os
import math
import sys
import os.path


def generate_prefix_str(pism_exec):
    """
    Generate prefix string.

    Returns: string
    """

    return os.path.join(os.environ.get("PISM_PREFIX", ""), pism_exec)


def generate_domain(domain):
    """
    Generate domain specific options

    Returns: string
    """

    if domain.lower() in ("greenland", "gris", "gris_ext"):
        pism_exec = "pismr"
    elif domain.lower() in ("og"):
        pism_exec = "pismr -no_model_strip 0 -calving_wrap_around"
    elif domain.lower() in ("hia"):
        x_min = -652200.0
        x_max = -232600.0
        y_min = -1263900.0
        y_max = -943500.0
        pism_exec = """pismr -x_range {x_min},{x_max} -y_range {y_min},{y_max} -bootstrap""".format(
            x_min=x_min, x_max=x_max, y_min=y_min, y_max=y_max
        )
    elif domain.lower() in ("jakobshavn", "jib"):
        x_min = -280000.0
        x_max = 320000.0
        y_min = -2410000.0
        y_max = -2020000.0
        pism_exec = """pismr -regional -x_range {x_min},{x_max} -y_range {y_min},{y_max}  -bootstrap -regional.zero_gradient true -regional.no_model_strip 4.5""".format(
            x_min=x_min, x_max=x_max, y_min=y_min, y_max=y_max
        )
    else:
        print(("Domain {} not recognized, exiting".format(domain)))
        import sys

        sys.exit(0)

    return pism_exec


spatial_ts_vars = {}

spatial_ts_vars["basic"] = [
    "basal_melt_rate_grounded",
    "beta",
    "dbdt",
    "dHdt",
    "hardav",
    "height_above_flotation",
    "ice_mass",
    "mask",
    "mass_fluxes",
    "sftgif",
    "temppabase",
    "tempsurf",
    "thk",
    "topg",
    "usurf",
    "velbase_mag",
    "velsurf",
    "velsurf_mag",
]

spatial_ts_vars["hydro"] = [
    "basal_melt_rate_grounded",
    "bwat",
    "bwp",
    "bwatvel",
    "beta",
    "dHdt",
    "hydraulic_potential",
    "ice_mass",
    "mask",
    "mass_fluxes",
    "lat",
    "lon",
    "sftgif",
    "temppabase",
    "tillwat",
    "thk",
    "topg",
    "usurf",
    "velbase_mag",
    "velsurf_mag",
]


def generate_spatial_ts(outfile, exvars, step, start=None, end=None, split=None, odir=None):
    """
    Return dict to generate spatial time series

    Returns: OrderedDict
    """

    # check if list or comma-separated string is given.
    try:
        exvars = ",".join(exvars)
    except:
        pass

    params_dict = OrderedDict()
    if split is True:
        outfile, ext = os.path.splitext(outfile)
        params_dict["extra_split"] = ""
    if odir is None:
        params_dict["extra_file"] = "ex_" + outfile
    else:
        params_dict["extra_file"] = os.path.join(odir, "ex_" + outfile)
    params_dict["extra_vars"] = exvars

    if step is None:
        step = "yearly"

    if start is not None and end is not None:
        times = "{start}:{step}:{end}".format(start=start, step=step, end=end)
    else:
        times = step

    params_dict["extra_times"] = times

    return params_dict


def generate_scalar_ts(outfile, step, start=None, end=None, odir=None):
    """
    Return dict to create scalar time series

    Returns: OrderedDict
    """

    params_dict = OrderedDict()
    if odir is None:
        params_dict["ts_file"] = "ts_" + outfile
    else:
        params_dict["ts_file"] = os.path.join(odir, "ts_" + outfile)

    if step is None:
        step = "yearly"

    if start is not None and end is not None:
        times = "{start}:{step}:{end}".format(start=start, step=step, end=end)
    else:
        times = step
    params_dict["ts_times"] = times

    return params_dict


def generate_snap_shots(outfile, times, odir=None):
    """
    Return dict to generate snap shots

    Returns: OrderedDict
    """

    params_dict = OrderedDict()
    if odir is None:
        params_dict["save_file"] = "save_" + outfile.split(".nc")[0]
    else:
        params_dict["save_file"] = os.path.join(odir, "save_" + outfile.split(".nc")[0])

    params_dict["save_times"] = ",".join(str(e) for e in times)
    params_dict["save_split"] = ""
    params_dict["save_force_output_times"] = ""

    return params_dict


def generate_grid_description(grid_resolution, domain, restart=False):
    """
    Generate grid description dict

    Returns: OrderedDict
    """

    if domain.lower() in ("greenland_ext", "gris_ext", "greenland", "gris"):

        if domain.lower() in ("greenland_ext", "gris_ext"):
            mx_max = 15120
            my_max = 19680
        else:
            mx_max = 10560
            my_max = 18240

        resolution_max = 150

        accepted_resolutions = (
            150,
            300,
            450,
            600,
            900,
            1200,
            1500,
            1800,
            2400,
            3000,
            3600,
            4500,
            6000,
            9000,
            18000,
            36000,
        )

        try:
            grid_resolution in accepted_resolutions
            pass
        except:
            print(("grid resolution {}m not recognized".format(grid_resolution)))

        if grid_resolution < 1200:
            skip_max = 200
            mz = 201
            mzb = 21
        elif (grid_resolution >= 1200) and (grid_resolution < 4500):
            skip_max = 100
            mz = 201
            mzb = 21
        elif (grid_resolution >= 4500) and (grid_resolution < 18000):
            skip_max = 50
            mz = 201
            mzb = 21
        else:
            skip_max = 20
            mz = 101
            mzb = 11

    elif domain.lower() in ("jakobshavn", "jib"):

        mx_max = 4000
        my_max = 2600

        resolution_max = 150

        accepted_resolutions = (
            150,
            300,
            450,
            600,
            900,
            1200,
            1500,
            1800,
            2400,
            3000,
            3600,
            4500,
            6000,
            9000,
            18000,
            36000,
        )

        try:
            grid_resolution in accepted_resolutions
            pass
        except:
            print(("grid resolution {}m not recognized".format(grid_resolution)))

        if grid_resolution < 1200:
            skip_max = 200
            mz = 201
            mzb = 21
        elif (grid_resolution >= 1200) and (grid_resolution < 4500):
            skip_max = 100
            mz = 201
            mzb = 21
        elif (grid_resolution >= 4500) and (grid_resolution < 18000):
            skip_max = 50
            mz = 201
            mzb = 21
        else:
            skip_max = 20
            mz = 101
            mzb = 11

    elif domain.lower() in ("og"):

        mx_max = 2601
        my_max = 1001

        resolution_max = 100

        accepted_resolutions = (100, 200, 250, 500, 1000, 2000, 5000)

        try:
            grid_resolution in accepted_resolutions
            pass
        except:
            print(("grid resolution {}m not recognized".format(grid_resolution)))

        skip_max = 200
        mz = 401
        mzb = 0

    grid_div = grid_resolution / resolution_max

    mx = int(mx_max / grid_div)
    my = int(my_max / grid_div)

    horizontal_grid = OrderedDict()
    horizontal_grid["Mx"] = mx
    horizontal_grid["My"] = my

    vertical_grid = OrderedDict()
    # This sould be a temporary hack to restart from an older simulation
    if domain.lower() in ("gris", "og", "jib", "jakobshavn"):
        vertical_grid["Lz"] = 4000
    else:
        vertical_grid["Lz"] = 5000
    vertical_grid["Lbz"] = 2000
    vertical_grid["z_spacing"] = "equal"
    vertical_grid["Mz"] = mz
    vertical_grid["Mbz"] = mzb

    grid_options = {}
    grid_options["skip"] = ""
    grid_options["skip_max"] = skip_max

    grid_dict = merge_dicts(horizontal_grid, vertical_grid, grid_options)

    if restart is True:
        return grid_options
    else:
        return grid_dict


def merge_dicts(*dict_args):
    """
    Given any number of dicts, shallow copy and merge into a new dict,
    precedence goes to key value pairs in latter dicts.

    Returns: OrderedDict
    """
    result = OrderedDict()
    for dictionary in dict_args:
        result.update(dictionary)
    return result


def uniquify_list(seq, idfun=None):
    """
    Remove duplicates from a list, order preserving.
    From http://www.peterbe.com/plog/uniqifiers-benchmark
    """

    if idfun is None:

        def idfun(x):
            return x

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
    """
    Generate stress balance params

    Returns: OrderedDict
    """

    accepted_stress_balances = ("sia", "ssa+sia")

    if stress_balance not in accepted_stress_balances:
        print(("{} not in {}".format(stress_balance, accepted_stress_balances)))
        print(("available stress balance solvers are {}".format(accepted_stress_balances)))
        import sys

        sys.exit(0)

    params_dict = OrderedDict()
    params_dict["stress_balance"] = stress_balance
    if stress_balance in ("ssa+sia"):
        params_dict["options_left"] = ""
        params_dict["cfbc"] = ""
        params_dict["kill_icebergs"] = ""
        params_dict["part_grid"] = ""
        params_dict["part_redist"] = ""
        params_dict["sia_flow_law"] = "gpbld"
        params_dict["pseudo_plastic"] = ""
        params_dict["tauc_slippery_grounding_lines"] = ""

    return merge_dicts(additional_params_dict, params_dict)


def generate_hydrology(hydro, **kwargs):
    """
    Generate hydrology params

    Returns: OrderedDict
    """

    params_dict = OrderedDict()
    if hydro in ("null"):
        params_dict["hydrology"] = "null"
    elif hydro in ("diffuse"):
        params_dict["hydrology"] = "null"
        params_dict["hydrology_null_diffuse_till_water"] = ""
    elif hydro in ("routing"):
        params_dict["hydrology"] = "routing"
        params_dict["basal_yield_stress.add_transportable_water"] = "true"
    elif hydro in ("distributed"):
        params_dict["hydrology"] = "distributed"
        params_dict["basal_yield_stress.add_transportable_water"] = "true"
    else:
        print(("hydrology {} not recognized, exiting".format(hydro)))
        import sys

        sys.exit(0)

    return merge_dicts(params_dict, kwargs)


def generate_calving(calving, **kwargs):
    """
    Generate calving params

    Returns: OrderedDict
    """

    params_dict = OrderedDict()
    if calving in ("ocean_kill"):
        params_dict["calving"] = calving
    elif calving in ("thickness_calving"):
        params_dict["calving"] = calving
    elif calving in ("eigen_calving", "vonmises_calving"):
        params_dict["calving"] = "{},thickness_calving".format(calving)
    elif calving in ("hybrid_calving"):
        params_dict["calving"] = "eigen_calving,vonmises_calving,thickness_calving"
    elif calving in ("float_kill", "float_kill,ocean_kill", "vonmises_calving,ocean_kill", "eigen_calving,ocean_kill"):
        params_dict["calving"] = calving
    else:
        print(("calving {} not recognized, exiting".format(calving)))
        import sys

        sys.exit(0)
    if "frontal_melt" in kwargs and kwargs["frontal_melt"] is True:
        params_dict["calving"] += ",frontal_melt"
        # need to delete the entry
        del kwargs["frontal_melt"]
    return merge_dicts(params_dict, kwargs)


def generate_climate(climate, **kwargs):
    """
    Generate climate params

    Returns: OrderedDict
    """

    params_dict = OrderedDict()
    if climate in ("paleo"):
        params_dict["atmosphere"] = "searise_greenland,delta_T,paleo_precip"
        if "atmosphere_paleo_precip_file" not in kwargs:
            params_dict["atmosphere_paleo_precip_file"] = "pism_dT.nc"
        if "atmosphere_delta_T_file" not in kwargs:
            params_dict["atmosphere_delta_T_file"] = "pism_dT.nc"
        params_dict["surface"] = "pdd"
        params_dict["pdd_std_dev_method"] = "quadratic"  # Wake and Marshall (2015)
    elif climate in ("abrupt_glacial"):
        params_dict["atmosphere"] = "searise_greenland,delta_T,paleo_precip"
        if "atmosphere_paleo_precip_file" not in kwargs:
            params_dict["atmosphere_paleo_precip_file"] = "pism_abrupt_glacial_climate_forcing.nc"
        if "atmosphere_delta_T_file" not in kwargs:
            params_dict["atmosphere_delta_T_file"] = "pism_abrupt_glacial_climate_forcing.nc"
        params_dict["surface"] = "pdd"
        params_dict["pdd_std_dev_method"] = "quadratic"  # Wake and Marshall (2015)
    elif climate in ("warming"):
        params_dict["atmosphere"] = "given,lapse_rate,delta_T,paleo_precip"
        if "atmosphere_delta_T_file" not in kwargs:
            params_dict["atmosphere_delta_T_file"] = "pism_warming_climate_forcing.nc"
        params_dict["surface"] = "pdd"
    elif climate in ("warming_precip"):
        params_dict["atmosphere"] = "given,lapse_rate,delta_T,paleo_precip"
        if "atmosphere_paleo_precip_file" not in kwargs:
            params_dict["atmosphere_paleo_precip_file"] = "pism_warming_climate_forcing.nc"
        if "atmosphere_delta_T_file" not in kwargs:
            params_dict["atmosphere_delta_T_file"] = "pism_warming_climate_forcing.nc"
        params_dict["surface"] = "pdd"
    elif climate in ("paleo_const"):
        params_dict["atmosphere"] = "searise_greenland"
        params_dict["surface"] = "given"
    elif climate in ("pdd"):
        params_dict["atmosphere"] = "given"
        if "atmosphere_given_file" not in kwargs:
            params_dict["atmosphere_given_file"] = "foo.nc"
        params_dict["surface"] = "pdd"
    elif climate in ("pdd_lapse"):
        params_dict["atmosphere"] = "given,lapse_rate"
        if "atmosphere_given_file" not in kwargs:
            params_dict["atmosphere_given_file"] = "foo.nc"
        if "temp_lapse_rate" not in kwargs:
            params_dict["temp_lapse_rate"] = 0.0
        params_dict["surface"] = "pdd"
    elif climate in ("const"):
        params_dict["surface"] = "given"
    elif climate in ("relax", "given"):
        params_dict["surface"] = "given"
    elif climate in ("flux"):
        params_dict["surface"] = "given,forcing"
    elif climate in ("elevation"):
        params_dict["surface"] = "elevation"
    else:
        print(("climate {} not recognized, exiting".format(climate)))
        import sys

        sys.exit(0)

    return merge_dicts(params_dict, kwargs)


def generate_ocean(ocean, **kwargs):
    """
    Generate ocean params

    Returns: OrderedDict
    """

    params_dict = OrderedDict()
    if ocean == "paleo":
        params_dict["ocean"] = "given,delta_SL,frac_SMB"
        if "ocean_delta_SL_file" not in kwargs:
            params_dict["ocean_delta_SL_file"] = "pism_dSL.nc"
    elif ocean == "abrupt_glacial":
        params_dict["ocean"] = "given,delta_SL,frac_SMB"
        if "ocean_delta_SL_file" not in kwargs:
            params_dict["ocean_delta_SL_file"] = "pism_abrupt_glacial_climate_forcing.nc"
    elif ocean == "abrupt_glacial_mbp":
        params_dict["ocean"] = "given,delta_SL,frac_SMB,delta_MBP"
        if "ocean_delta_SL_file" not in kwargs:
            params_dict["ocean_delta_SL_file"] = "pism_abrupt_glacial_climate_forcing.nc"
    elif ocean == "paleo_mbp":
        params_dict["ocean"] = "given,delta_SL,frac_SMB,delta_MBP"
        if "ocean_delta_SL_file" not in kwargs:
            params_dict["ocean_delta_SL_file"] = "pism_dSL.nc"
    elif ocean == "warming":
        params_dict["ocean"] = "given,runoff_SMB"
    elif ocean == "warming_3eqn":
        params_dict["ocean"] = "th,delta_T"
    elif ocean == "paleo_const":
        params_dict["ocean"] = "given,delta_SL"
    elif ocean == "paleo_const_mbp":
        params_dict["ocean"] = "given,delta_SL,delta_MBP"
    elif ocean in ("given", "relax"):
        params_dict["ocean"] = "given"
    elif ocean in ("given_mbp"):
        params_dict["ocean"] = "given,delta_MBP"
    elif ocean == "const":
        params_dict["ocean"] = "constant"
    else:
        print(("ocean {} not recognized, exiting".format(ocean)))
        import sys

        sys.exit(0)

    return merge_dicts(params_dict, kwargs)


def list_systems():
    """
    Return a list of supported systems.
    """
    return sorted(systems.keys())


def list_queues():
    """
    Return a list of supported queues.
    """
    result = set()
    for s in list(systems.values()):
        for q in list(s["queue"].keys()):
            result.add(q)

    return result


def list_bed_types():
    """
    Return a list of supported bed types.
    """

    list = ["ctrl", "cresis", "cresisp", "minus", "plus", "ba01_bed", "970mW_hs", "jak_1985", "no_bath"]

    return list


# information about systems
systems = {}

systems["debug"] = {"mpido": "mpiexec -n {cores}", "submit": "echo", "job_id": "PBS_JOBID", "queue": {}}

systems["chinook"] = {
    "mpido": "mpirun -np {cores} -machinefile ./nodes_$SLURM_JOBID",
    "submit": "sbatch",
    "work_dir": "SLURM_SUBMIT_DIR",
    "job_id": "SLURM_JOBID",
    "queue": {"t1standard": 24, "t1small": 24, "t2standard": 24, "t2small": 24, "debug": 24},
}

systems["pleiades"] = {
    "mpido": "mpiexec -n {cores}",
    "submit": "qsub",
    "work_dir": "PBS_O_WORKDIR",
    "job_id": "PBS_JOBID",
    "queue": {"long": 20, "normal": 20},
}

systems["pleiades_haswell"] = systems["pleiades"].copy()
systems["pleiades_haswell"]["queue"] = {"long": 24, "normal": 24}

systems["pleiades_ivy"] = systems["pleiades"].copy()
systems["pleiades_ivy"]["queue"] = {"long": 20, "normal": 20}

systems["pleiades_sandy"] = systems["pleiades"].copy()
systems["pleiades_sandy"]["queue"] = {"long": 16, "normal": 16}

systems["pleiades_broadwell"] = systems["pleiades"].copy()
systems["pleiades_broadwell"]["queue"] = {"long": 28, "normal": 28}

systems["electra_broadwell"] = systems["pleiades_broadwell"].copy()

systems["electra_skylake"] = systems["pleiades"].copy()
systems["electra_skylake"]["queue"] = {"long": 40, "normal": 40}


# headers for batch jobs
#
# Available keywords:
#
# cores    - number of cores (MPI tasks)
# queue    - queue (partition) name
# nodes    - number of nodes
# ppn      - number of tasks per node
# walltime - wall time limit

systems["debug"]["header"] = ""

systems["chinook"][
    "header"
] = """#!/bin/sh
#SBATCH --partition={queue}
#SBATCH --ntasks={cores}
#SBATCH --tasks-per-node={ppn}
#SBATCH --time={walltime}
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --output=pism.%j

module list

cd $SLURM_SUBMIT_DIR

# Generate a list of compute node hostnames reserved for this job,
# this ./nodes file is necessary for slurm to spawn mpi processes
# across multiple compute nodes
srun -l /bin/hostname | sort -n | awk '{{print $2}}' > ./nodes_$SLURM_JOBID

ulimit -l unlimited
ulimit -s unlimited
ulimit

"""

systems["chinook"][
    "footer"
] = """
# clean up the list of hostnames
rm -rf ./nodes_$SLURM_JOBID
"""

systems["electra_broadwell"][
    "header"
] = """#PBS -S /bin/bash
#PBS -N cfd
#PBS -l walltime={walltime}
#PBS -m e
#PBS -q {queue}
#PBS -lselect={nodes}:ncpus={ppn}:mpiprocs={ppn}:model=bro_ele
#PBS -j oe

module list

cd $PBS_O_WORKDIR

"""

systems["pleiades"][
    "header"
] = """#PBS -S /bin/bash
#PBS -N cfd
#PBS -l walltime={walltime}
#PBS -m e
#PBS -W group_list=s1878
#PBS -q {queue}
#PBS -lselect={nodes}:ncpus={ppn}:mpiprocs={ppn}:model=ivy
#PBS -j oe

module list

cd $PBS_O_WORKDIR

"""

systems["pleiades_broadwell"][
    "header"
] = """#PBS -S /bin/bash
#PBS -N cfd
#PBS -l walltime={walltime}
#PBS -m e
#PBS -W group_list=s1878
#PBS -q {queue}
#PBS -lselect={nodes}:ncpus={ppn}:mpiprocs={ppn}:model=bro
#PBS -j oe

module list

cd $PBS_O_WORKDIR

"""

systems["pleiades_sandy"][
    "header"
] = """#PBS -S /bin/bash
#PBS -N cfd
#PBS -l walltime={walltime}
#PBS -m e
#PBS -W group_list=s1878
#PBS -q {queue}
#PBS -lselect={nodes}:ncpus={ppn}:mpiprocs={ppn}:model=san
#PBS -j oe

module list

cd $PBS_O_WORKDIR

"""

systems["pleiades_haswell"][
    "header"
] = """#PBS -S /bin/bash
#PBS -N cfd
#PBS -l walltime={walltime}
#PBS -m e
#PBS -W group_list=s1878
#PBS -q {queue}
#PBS -lselect={nodes}:ncpus={ppn}:mpiprocs={ppn}:model=has
#PBS -j oe

module list

cd $PBS_O_WORKDIR

"""

systems["pleiades_ivy"][
    "header"
] = """#PBS -S /bin/bash
#PBS -N cfd
#PBS -l walltime={walltime}
#PBS -m e
#PBS -W group_list=s1878
#PBS -q {queue}
#PBS -lselect={nodes}:ncpus={ppn}:mpiprocs={ppn}:model=ivy
#PBS -j oe

module list

cd $PBS_O_WORKDIR

"""

systems["electra_skylake"][
    "header"
] = """#PBS -S /bin/bash
#PBS -N cfd
#PBS -l walltime={walltime}
#PBS -m e
#PBS -W group_list=s1878
#PBS -q {queue}
#PBS -lselect={nodes}:ncpus={ppn}:mpiprocs={ppn}:model=sky_ele
#PBS -j oe

module list

cd $PBS_O_WORKDIR

"""

systems["debug"][
    "header"
] = """

"""

# headers for post-processing jobs

post_headers = {}
post_headers[
    "default"
] = """#!/bin/bash

"""

post_headers[
    "pbs"
] = """#PBS -S /bin/bash
#PBS -l select=1:mem=94GB
#PBS -l walltime=8:00:00
#PBS -q ldan

cd $PBS_O_WORKDIR

"""

post_headers[
    "slurm"
] = """#!/bin/bash
#SBATCH --partition=analysis
#SBATCH --ntasks=1
#SBATCH --tasks-per-node=1
#SBATCH --time=48:00:00
#SBATCH --output=pism.%j
#SBATCH --mem=214G

cd $SLURM_SUBMIT_DIR

ulimit -l unlimited
ulimit -s unlimited
ulimit

"""


def make_batch_header(system_name, n_cores, walltime, queue):
    """
    Generate header file for different HPC system.

    Returns: String
    """

    # get system info; use "debug" if the requested name was not found
    system = systems.get(system_name, systems["debug"]).copy()

    assert n_cores > 0

    if system_name == "debug":
        # when debugging, assume that all we need is one node
        ppn = n_cores
        nodes = 1
    else:
        try:
            ppn = system["queue"][queue]
        except:
            raise ValueError(
                "There is no queue {} on {}. Pick one of {}.".format(queue, system_name, list(system["queue"].keys()))
            )
        # round up when computing the number of nodes needed to run on 'n_cores' cores
        nodes = int(math.ceil(float(n_cores) / ppn))

        if nodes * ppn != n_cores:
            print(
                (
                    "Warning! Running {n_cores} tasks on {nodes} {ppn}-processor nodes, wasting {N} processors!".format(
                        nodes=nodes, ppn=ppn, n_cores=n_cores, N=ppn * nodes - n_cores
                    )
                )
            )

    system["mpido"] = system["mpido"].format(cores=n_cores)
    system["header"] = system["header"].format(queue=queue, walltime=walltime, nodes=nodes, ppn=ppn, cores=n_cores)
    system["header"] += version_header()

    return system["header"], system


def make_batch_post_header(system):

    v = version_header()

    if system in ("electra_broadwell", "pleiades", "pleiades_ivy", "pleiades_broadwell", "pleiades_haswell"):
        return post_headers["pbs"] + v
    elif system in ("chinook"):
        return post_headers["slurm"] + v
    else:
        return post_headers["default"] + v


def make_batch_header_test():
    "print headers of all supported systems and queues (for testing)"
    for s in list(systems.keys()):
        for q in list(systems[s]["queue"].keys()):
            print("# system: {system}, queue: {queue}".format(system=s, queue=q))
            print(make_batch_header(s, 100, "1:00:00", q)[0])


def version():
    """Return the path to the top directory of the Git repository
    containing this script, the URL of the "origin" remote and the version."""
    import inspect
    import shlex
    import subprocess

    def output(command):
        path = os.path.realpath(os.path.dirname(inspect.stack(0)[0][1]))
        return subprocess.check_output(shlex.split(command), cwd=path).strip()

    return (
        output("git rev-parse --show-toplevel"),
        output("git remote get-url origin"),
        output("git describe --always"),
    )


def version_header():
    "Return shell comments containing version info."
    version_info = version()
    return """
# Generated by {script}
# Command: {command}
# Git top level: {path}
# URL: {url}
# Version: {version}

""".format(
        script=os.path.realpath(sys.argv[0]),
        command=" ".join(sys.argv),
        path=version_info[0],
        url=version_info[1],
        version=version_info[2],
    )
