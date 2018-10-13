#!/usr/bin/env python
# Copyright (C) 2016-17 Andy Aschwanden

import itertools
from collections import OrderedDict
import numpy as np
import os

try:
    import subprocess32 as sub
except:
    import subprocess as sub

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
import sys

sys.path.append("../resources/")
from resources import *


def map_dict(val, mdict):
    try:
        return mdict[val]
    except:
        return val


grid_choices = [18000, 9000, 6000, 4500, 3600, 3000, 2400, 1800, 1500, 1200, 900, 600, 450, 300, 150]

# set up the option parser
parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.description = "Generating scripts for warming experiments."
parser.add_argument("FILE", nargs=1, help="Input file to restart from", default=None)
parser.add_argument(
    "-n", "--n_procs", dest="n", type=int, help="""number of cores/processors. default=140.""", default=140
)
parser.add_argument(
    "-w", "--wall_time", dest="walltime", help="""walltime. default: 100:00:00.""", default="100:00:00"
)
parser.add_argument(
    "-q", "--queue", dest="queue", choices=list_queues(), help="""queue. default=long.""", default="long"
)
parser.add_argument(
    "--calving",
    dest="calving",
    choices=["float_kill", "ocean_kill", "vonmises_calving"],
    help="calving",
    default="vonmises_calving",
)
parser.add_argument(
    "-d", "--domain", dest="domain", choices=["gris", "gris_ext"], help="sets the modeling domain", default="gris"
)
parser.add_argument("--exstep", dest="exstep", help="Writing interval for spatial time series", default=10)
parser.add_argument(
    "-f",
    "--o_format",
    dest="oformat",
    choices=["netcdf3", "netcdf4_parallel", "pnetcdf"],
    help="output format",
    default="netcdf4_parallel",
)
parser.add_argument(
    "-g", "--grid", dest="grid", type=int, choices=grid_choices, help="horizontal grid resolution", default=9000
)
parser.add_argument("--o_dir", dest="odir", help="output directory. Default: current directory", default="foo")
parser.add_argument(
    "--o_size", dest="osize", choices=["small", "medium", "big", "big_2d"], help="output size type", default="medium"
)
parser.add_argument(
    "-s",
    "--system",
    dest="system",
    choices=list_systems(),
    help="computer system to use.",
    default="pleiades_broadwell",
)
parser.add_argument(
    "-b", "--bed_type", dest="bed_type", choices=list_bed_types(), help="output size type", default="no_bath"
)
parser.add_argument(
    "--forcing_type", dest="forcing_type", choices=["ctrl", "e_age"], help="output size type", default="ctrl"
)
parser.add_argument(
    "--hydrology",
    dest="hydrology",
    choices=["null", "diffuse", "routing"],
    help="Basal hydrology model.",
    default="diffuse",
)
parser.add_argument(
    "-p", "--params", dest="params_list", help="Comma-separated list with params for sensitivity", default=None
)
parser.add_argument(
    "--stable_gl",
    dest="float_kill_calve_near_grounding_line",
    action="store_false",
    help="Stable grounding line",
    default=True,
)
parser.add_argument(
    "--stress_balance",
    dest="stress_balance",
    choices=["sia", "ssa+sia", "ssa"],
    help="stress balance solver",
    default="ssa+sia",
)
parser.add_argument(
    "--topg_delta", dest="topg_delta_file", help="end of initialization detla=(topg-topg_initial) file", default=None
)
parser.add_argument(
    "--dataset_version", dest="version", choices=["2", "3", "3a"], help="input data set version", default="3a"
)
parser.add_argument(
    "--vertical_velocity_approximation",
    dest="vertical_velocity_approximation",
    choices=["centered", "upstream"],
    help="How to approximate vertical velocities",
    default="upstream",
)
parser.add_argument("--start_year", dest="start_year", type=int, help="Simulation start year", default=0)
parser.add_argument("--duration", dest="duration", type=int, help="Years to simulate", default=1000)
parser.add_argument("--step", dest="step", type=int, help="Step in years for restarting", default=1000)
parser.add_argument(
    "--test_climate_models",
    dest="test_climate_models",
    action="store_true",
    help="Turn off ice dynamics and mass transport to test climate models",
    default=False,
)
parser.add_argument(
    "--calibrate",
    dest="calibrate",
    action="store_true",
    help="Run calibration mode (no spatial time series written)",
    default=False,
)

options = parser.parse_args()

nn = options.n
odir = options.odir
oformat = options.oformat
osize = options.osize
queue = options.queue
walltime = options.walltime
system = options.system

calibrate = options.calibrate

bed_type = options.bed_type
calving = options.calving
climate = "warming"
exstep = options.exstep
float_kill_calve_near_grounding_line = options.float_kill_calve_near_grounding_line
forcing_type = options.forcing_type
frontal_melt = True
grid = options.grid
hydrology = options.hydrology
stress_balance = options.stress_balance
topg_delta_file = options.topg_delta_file
test_climate_models = options.test_climate_models
vertical_velocity_approximation = options.vertical_velocity_approximation
version = options.version

# Check which parameters are used for sensitivity study
params_list = options.params_list
do_pdd_ice = False
do_pdd_snow = False
do_rfr = False
do_firn = False
do_tlr = False
do_sia_e = False
do_vcm = False
do_ocs = False
do_ocm = False
do_prs = False
do_tct = False
do_bed_def = False
do_ppq = False
do_std_dev = False
if params_list is not None:
    params = params_list.split(",")
    if "sia_e" in params:
        do_sia_e = True
    if "fice" in params:
        do_pdd_ice = True
    if "fsnow" in params:
        do_pdd_snow = True
    if "firn" in params:
        do_firn = True
    if "tlr" in params:
        do_tlr = True
    if "ocm" in params:
        do_ocm = True
    if "ocs" in params:
        do_ocs = True
    if "prs" in params:
        do_prs = True
    if "vcm" in params:
        do_vcm = True
    if "tct" in params:
        do_tct = True
    if "bed_def" in params:
        do_bed_def = True
    if "ppq" in params:
        do_ppq = True
    if "rfr" in params:
        do_rfr = True
    if "std_dev" in params:
        do_std_dev = True

domain = options.domain
pism_exec = generate_domain(domain)

if options.FILE is None:
    print("Missing input file")
    import sys

    sys.exit()
else:
    input_file = options.FILE[0]

if domain.lower() in ("greenland_ext", "gris_ext"):
    pism_dataname = "../data_sets/bed_dem/pism_Greenland_ext_{}m_mcb_jpl_v{}_{}.nc".format(grid, version, bed_type)
else:
    pism_dataname = "../data_sets/bed_dem/pism_Greenland_{}m_mcb_jpl_v{}_{}.nc".format(grid, version, bed_type)

climate_file = "../data_sets/climate_forcing/DMI-HIRHAM5_GL2_ERAI_2001_2014_YDM_BIL_EPSG3413_{}m.nc".format(grid)

regridvars = "litho_temp,enthalpy,age,tillwat,bmelt,Href,thk"


pism_config = "init_config"
pism_config_nc = ".".join([pism_config, "nc"])
pism_config_cdl = os.path.join("../config", ".".join([pism_config, "cdl"]))
ncgen = "ncgen"
cmd = [ncgen, "-o", pism_config_nc, pism_config_cdl]
sub.call(cmd)
if not os.path.isdir(odir):
    os.mkdir(odir)

perf_dir = "performance"
state_dir = "state"
scalar_dir = "scalar"
spatial_dir = "spatial"
snap_dir = "snap"
script_dir = "run_scripts"
for tsdir in (perf_dir, scalar_dir, spatial_dir, snap_dir, state_dir, script_dir):
    if not os.path.isdir(os.path.join(odir, tsdir)):
        os.mkdir(os.path.join(odir, tsdir))
odir_tmp = "_".join([odir, "tmp"])
if not os.path.isdir(odir_tmp):
    os.mkdir(odir_tmp)

# ########################################################
# set up model initialization
# ########################################################

ssa_n = 3.25
ssa_e = 1.0
tefo = 0.020
phi_min = 5.0
phi_max = 40.0
topg_min = -700
topg_max = 700

rcp_values = ["26", "45", "85", "ctrl"]

if do_std_dev:
    std_dev_values = [2.5, 4.23, 5.5]
else:
    std_dev_values = [4.23]
if do_sia_e:
    sia_e_values = [1, 1.25, 3]
else:
    sia_e_values = [1.25]
if do_ppq:
    ppq_values = [0.3, 0.6, 0.9]
else:
    ppq_values = [0.6]
if do_rfr:
    rfr_values = [0.30, 0.47, 0.60, 0.75]
else:
    rfr_values = [0.60]
if do_tlr:
    tlr_rate_values = [0, 6]
else:
    tlr_rate_values = [6]
if do_pdd_ice:
    pdd_ice_values = [4, 8, 12, 16]
else:
    pdd_ice_values = [8]
if do_pdd_snow:
    pdd_snow_values = [3, 4, 5]
else:
    pdd_snow_values = [3]
if do_firn:
    firn_values = ["off", "ctrl"]
else:
    firn_values = ["ctrl"]
if do_vcm:
    vcm_values = [0.7e6, 1.0e6, 1.4e6]
else:
    vcm_values = [1e6]
if do_ocs:
    ocs_values = ["off", "low", "mid", "high"]
else:
    ocs_values = ["mid"]
if do_ocm:
    ocm_values = ["low", "mid", "high"]
else:
    ocm_values = ["mid"]
if do_prs:
    prs_values = [0, 0.05, 0.07]
else:
    prs_values = [0.05]
if do_tct:
    thickness_calving_threshold_values = ["low", "mid", "high"]
else:
    thickness_calving_threshold_values = ["mid"]
if do_bed_def:
    bed_deformation_values = ["off", "i0", "ip"]
else:
    bed_deformation_values = ["off"]

combinations = list(
    itertools.product(
        rcp_values,
        pdd_ice_values,
        pdd_snow_values,
        std_dev_values,
        prs_values,
        rfr_values,
        ocm_values,
        ocs_values,
        thickness_calving_threshold_values,
        vcm_values,
        ppq_values,
        sia_e_values,
        bed_deformation_values,
        tlr_rate_values,
        firn_values,
    )
)

firn_dict = {-1.0: "low", 0.0: "off", 1.0: "ctrl"}
ocs_dict = {-1.0: "low", 0.0: "mid", 1.0: "high"}
ocm_dict = {-1.0: "low", 0.0: "mid", 1.0: "high"}
tct_dict = {-1.0: "low", 0.0: "mid", 1.0: "high"}
bd_dict = {-1.0: "off", 0.0: "i0", 1.0: "ip"}

tsstep = "yearly"

scripts = []
scripts_combinded = []
scripts_post = []

simulation_start_year = options.start_year
simulation_end_year = options.start_year + options.duration
restart_step = options.step

if restart_step > (simulation_end_year - simulation_start_year):
    print("Error:")
    print(
        (
            "restart_step > (simulation_end_year - simulation_start_year): {} > {}".format(
                restart_step, simulation_end_year - simulation_start_year
            )
        )
    )
    print("Try again")
    import sys

    sys.exit(0)


for n, combination in enumerate(combinations):

    rcp, fice, fsnow, std_dev, prs, rfr, ocm, ocs, tct, vcm, ppq, sia_e, bed_deformation, lapse_rate, firn = (
        combination
    )

    ttphi = "{},{},{},{}".format(phi_min, phi_max, topg_min, topg_max)

    name_options = OrderedDict()
    name_options["rcp"] = rcp
    name_options["prs"] = prs
    name_options["fice"] = fice
    name_options["fsnow"] = fsnow
    name_options["stddev"] = std_dev
    name_options["rfr"] = rfr
    name_options["firn"] = firn
    name_options["sia_e"] = sia_e
    name_options["ppq"] = ppq
    name_options["vcm"] = vcm / 1e6
    name_options["ocs"] = map_dict(ocs, ocs_dict)
    name_options["ocm"] = map_dict(ocm, ocm_dict)
    name_options["tct"] = map_dict(tct, tct_dict)
    name_options["bd"] = bed_deformation
    if do_tlr:
        name_options["tlr"] = lapse_rate
    if test_climate_models == True:
        name_options["test_climate"] = "on"

    vversion = "v" + str(version)
    full_exp_name = "_".join([vversion, "_".join(["_".join([k, str(v)]) for k, v in list(name_options.items())])])
    full_outfile = "g{grid}m_{experiment}.nc".format(grid=grid, experiment=full_exp_name)
    if rcp == "ctrl":
        climate_modifier_file = "pism_warming_climate_{tempmax}K.nc".format(tempmax=0)
    elif rcp == "26":
        climate_modifier_file = "../data_sets/climate_forcing/tas_Amon_GISS-E2-H_rcp26_ensmean_ym_anom_GRIS_0-5000.nc"
    elif rcp == "45":
        climate_modifier_file = "../data_sets/climate_forcing/tas_Amon_GISS-E2-H_rcp45_ensmean_ym_anom_GRIS_0-5000.nc"
    elif rcp == "85":
        climate_modifier_file = "../data_sets/climate_forcing/tas_Amon_GISS-E2-H_rcp85_ensmean_ym_anom_GRIS_0-5000.nc"
    else:
        print("How did I get here")

    # All runs in one script file for coarse grids that fit into max walltime
    script_combined = os.path.join(odir, script_dir, "warm_g{}m_{}_j.sh".format(grid, full_exp_name))
    with open(script_combined, "w") as f_combined:

        outfiles = []
        job_no = 0
        for start in range(simulation_start_year, simulation_end_year, restart_step):
            job_no += 1

            end = start + restart_step

            experiment = "_".join(
                [
                    vversion,
                    "_".join(["_".join([k, str(v)]) for k, v in list(name_options.items())]),
                    "{}".format(start),
                    "{}".format(end),
                ]
            )

            script = os.path.join(odir, script_dir, "warm_g{}m_{}.sh".format(grid, experiment))
            scripts.append(script)

            for filename in script:
                try:
                    os.remove(filename)
                except OSError:
                    pass

            batch_header, batch_system = make_batch_header(system, nn, walltime, queue)
            if start == simulation_start_year:
                f_combined.write(batch_header)

            with open(script, "w") as f:

                f.write(batch_header)

                outfile = "{domain}_g{grid}m_{experiment}.nc".format(
                    domain=domain.lower(), grid=grid, experiment=experiment
                )

                prefix = generate_prefix_str(pism_exec)

                general_params_dict = OrderedDict()
                general_params_dict["profile"] = os.path.join(
                    odir, perf_dir, "profile_${}.py".format(batch_system["job_id"].split(".")[0])
                )
                if start == simulation_start_year:
                    general_params_dict["bootstrap"] = ""
                    general_params_dict["i"] = pism_dataname
                    general_params_dict["regrid_file"] = input_file
                    general_params_dict["regrid_vars"] = regridvars
                    general_params_dict["regrid_special"] = ""
                else:
                    general_params_dict["i"] = regridfile
                if (start == simulation_start_year) and (topg_delta_file is not None):
                    general_params_dict["topg_delta_file"] = topg_delta_file
                general_params_dict["ys"] = start
                general_params_dict["ye"] = end
                general_params_dict["calendar"] = "365_day"
                general_params_dict["climate_forcing_buffer_size"] = 365

                general_params_dict["o"] = os.path.join(odir, state_dir, outfile)
                general_params_dict["o_format"] = oformat
                general_params_dict["o_size"] = osize
                general_params_dict["config_override"] = pism_config_nc
                if test_climate_models == True:
                    general_params_dict["test_climate_models"] = ""
                    general_params_dict["no_mass"] = ""

                if bed_deformation != "off":
                    general_params_dict["bed_def"] = "lc"
                if bed_deformation == "ip":
                    general_params_dict[
                        "bed_deformation.bed_uplift_file"
                    ] = "../data_sets/uplift/uplift_g{}m.nc".format(grid)
                if forcing_type in ("e_age"):
                    general_params_dict["e_age_coupling"] = ""

                if start == simulation_start_year:
                    grid_params_dict = generate_grid_description(grid, domain)
                else:
                    grid_params_dict = generate_grid_description(grid, domain, restart=True)

                sb_params_dict = OrderedDict()
                sb_params_dict["sia_e"] = sia_e
                sb_params_dict["ssa_e"] = ssa_e
                sb_params_dict["ssa_n"] = ssa_n
                sb_params_dict["pseudo_plastic_q"] = ppq
                sb_params_dict["till_effective_fraction_overburden"] = tefo
                if start == simulation_start_year:
                    sb_params_dict["topg_to_phi"] = ttphi
                sb_params_dict["vertical_velocity_approximation"] = vertical_velocity_approximation

                stress_balance_params_dict = generate_stress_balance(stress_balance, sb_params_dict)
                ice_density = 910.0

                if firn == "off":
                    firn_file = "../data_sets/climate_forcing/firn_forcing_off.nc"
                elif firn == "ctrl":
                    firn_file = "../data_sets/climate_forcing/hirham_firn_depth_4500m_ctrl.nc"
                else:
                    print("How did I get here?")

                climate_params_dict = generate_climate(
                    climate,
                    **{
                        "surface.pdd.factor_ice": fice / ice_density,
                        "surface.pdd.factor_snow": fsnow / ice_density,
                        "surface.pdd.refreeze": rfr,
                        "pdd_firn_depth_file": firn_file,
                        "surface.pdd.std_dev": std_dev,
                        "atmosphere_given_file": climate_file,
                        "atmosphere_given_period": 1,
                        "atmosphere_lapse_rate_file": climate_file,
                        "atmosphere.precip_exponential_factor_for_temperature": prs,
                        "temp_lapse_rate": lapse_rate,
                        "atmosphere_paleo_precip_file": climate_modifier_file,
                        "atmosphere_delta_T_file": climate_modifier_file,
                    }
                )

                if ocm == "low":
                    ocean_file = "../data_sets/ocean_forcing/ocean_forcing_300myr_70n_10myr_80n.nc"
                elif ocm == "mid":
                    ocean_file = "../data_sets/ocean_forcing/ocean_forcing_400myr_70n_20myr_80n.nc"
                elif ocm == "high":
                    ocean_file = "../data_sets/ocean_forcing/ocean_forcing_500myr_70n_30myr_80n.nc"
                elif ocm == "extr":
                    ocean_file = "../data_sets/ocean_forcing/ocean_forcing_10000myr_70n_500myr_80n.nc"
                else:
                    pass

                if tct == "low":
                    tct_file = "../data_sets/ocean_forcing/tct_forcing_400myr_74n_50myr_76n.nc"
                elif tct == "mid":
                    tct_file = "../data_sets/ocean_forcing/tct_forcing_500myr_74n_100myr_76n.nc"
                elif tct == "high":
                    tct_file = "../data_sets/ocean_forcing/tct_forcing_600myr_74n_150myr_76n.nc"
                else:
                    print("not implemented")

                if ocs == "low":
                    ocean_alpha = 0.5
                    ocean_beta = 1.0
                elif ocs == "mid":
                    ocean_alpha = 0.55
                    ocean_beta = 1.1
                elif ocs == "high":
                    ocean_alpha = 1.0
                    ocean_beta = 2.0
                else:
                    pass

                if ocs == "off":
                    ocean = "given"
                    ocean_params_dict = generate_ocean(ocean, **{"ocean_given_file": ocean_file})
                else:
                    ocean = "warming"
                    ocean_params_dict = generate_ocean(
                        ocean,
                        **{
                            "ocean_given_file": ocean_file,
                            "ocean.runoff_to_ocean_melt_power_alpha": ocean_alpha,
                            "ocean.runoff_to_ocean_melt_power_beta": ocean_beta,
                            "ocean_runoff_smb_file": climate_modifier_file,
                        }
                    )

                hydro_params_dict = generate_hydrology(hydrology)
                if start == simulation_start_year:
                    calving_params_dict = generate_calving(
                        calving,
                        **{
                            "thickness_calving_threshold_file": tct_file,
                            "float_kill_calve_near_grounding_line": float_kill_calve_near_grounding_line,
                            "ocean_kill_file": input_file,
                            "frontal_melt": frontal_melt,
                            "calving.vonmises.sigma_max": vcm,
                        }
                    )
                else:
                    calving_params_dict = generate_calving(
                        calving,
                        **{
                            "thickness_calving_threshold_file": tct_file,
                            "float_kill_calve_near_grounding_line": float_kill_calve_near_grounding_line,
                            "ocean_kill_file": regridfile,
                            "frontal_melt": frontal_melt,
                            "calving.vonmises.sigma_max": vcm,
                        }
                    )

                scalar_ts_dict = generate_scalar_ts(
                    outfile,
                    tsstep,
                    start=simulation_start_year,
                    end=simulation_end_year,
                    odir=os.path.join(odir, scalar_dir),
                )

                if start != simulation_start_year:
                    scalar_ts_dict["ts_append"] = ""

                exvars = stability_spatial_ts_vars()
                if not calibrate:
                    spatial_ts_dict = generate_spatial_ts(full_outfile, exvars, exstep, odir=odir_tmp, split=False)
                    if start != simulation_start_year:
                        spatial_ts_dict["extra_append"] = ""

                    all_params_dict = merge_dicts(
                        general_params_dict,
                        grid_params_dict,
                        stress_balance_params_dict,
                        climate_params_dict,
                        ocean_params_dict,
                        hydro_params_dict,
                        calving_params_dict,
                        spatial_ts_dict,
                        scalar_ts_dict,
                    )
                else:
                    all_params_dict = merge_dicts(
                        general_params_dict,
                        grid_params_dict,
                        stress_balance_params_dict,
                        climate_params_dict,
                        ocean_params_dict,
                        hydro_params_dict,
                        calving_params_dict,
                        scalar_ts_dict,
                    )
                all_params = " ".join([" ".join(["-" + k, str(v)]) for k, v in list(all_params_dict.items())])

                if system in ("debug"):
                    cmd = " ".join(
                        [
                            batch_system["mpido"],
                            prefix,
                            all_params,
                            "2>&1 | tee {outdir}/job_{job_no}.${batch}".format(
                                outdir=odir, job_no=job_no, batch=batch_system["job_id"]
                            ),
                        ]
                    )
                else:
                    cmd = " ".join(
                        [
                            batch_system["mpido"],
                            prefix,
                            all_params,
                            "> {outdir}/job_{job_no}.${batch}  2>&1".format(
                                outdir=odir, job_no=job_no, batch=batch_system["job_id"]
                            ),
                        ]
                    )

                f.write(cmd)
                f.write("\n")

                f_combined.write(cmd)
                f_combined.write("\n\n")

                regridfile = os.path.join(odir, state_dir, outfile)
                outfiles.append(outfile)

    scripts_combinded.append(script_combined)

    script_post = os.path.join(odir, script_dir, "post_warm_g{}m_{}.sh".format(grid, full_exp_name))
    scripts_post.append(script_post)

    post_header = make_batch_post_header(system)

    with open(script_post, "w") as f:

        f.write(post_header)

        if exstep == "monthly":
            mexstep = 1.0 / 12
        elif exstep == "daily":
            mexstep = 1.0 / 365
        else:
            mexstep = int(exstep)

        if not calibrate:
            extra_file_tmp = spatial_ts_dict["extra_file"]
            extra_file = "{}_{}_{}.nc".format(
                os.path.split(extra_file_tmp)[-1].split(".nc")[0], simulation_start_year, simulation_end_year
            )
            extra_file = os.path.join(odir, spatial_dir, extra_file)
            cmd = " ".join(["ncks -O -4 -L 3 ", extra_file_tmp, extra_file, "\n"])
            f.write(cmd)
            cmd = " ".join(
                ["adjust_timeline.py -i start -p yearly -a 2008-1-1 -u seconds -d 2008-1-1", extra_file, "\n"]
            )
            f.write(cmd)
            cmd = " ".join(["~/gris-analysis/scripts/nc_add_hillshade.py -z 2 ", extra_file, "\n"])
            f.write(cmd)
        ts_file = os.path.join(
            odir,
            scalar_dir,
            "ts_{domain}_g{grid}m_{experiment}_{start}_{end}.nc".format(
                domain=domain.lower(),
                grid=grid,
                experiment=full_exp_name,
                start=simulation_start_year,
                end=simulation_end_year,
            ),
        )
        cmd = " ".join(
            ["adjust_timeline.py -i start -p yearly -a 2008-1-1 -u seconds -d 2008-1-1", "{}".format(ts_file), "\n"]
        )
        f.write(cmd)
        cumsum_file = os.path.join(
            odir,
            scalar_dir,
            "cumsum_ts_{domain}_g{grid}m_{experiment}".format(
                domain=domain.lower(), grid=grid, experiment=full_exp_name
            ),
        )
        cumsum_outfile = "_".join(["{}_{}_{}.nc".format(cumsum_file, simulation_start_year, simulation_end_year)])
        cmd = " ".join(
            [
                "cdo setattribute,ice_mass@units=Gt,discharge_cumulative@units=Gt,basal_mass_flux_grounded_cumulative@units=Gt,basal_mass_flux_floating_cumulative@units=Gt,,surface_mass_flux_cumulative@units=Gt -divc,1e12 -chname,mass_rate_of_change_glacierized,ice_mass,tendency_of_ice_mass_due_to_flow,flow_cumulative,tendency_of_ice_mass_due_to_conservation_error,conservation_error_cumulative,basal_mass_flux_floating,basal_mass_flux_floating_cumulative,basal_mass_flux_grounded,basal_mass_flux_grounded_cumulative,tendency_of_ice_mass_due_to_surface_mass_balance,surface_mass_flux_cumulative,tendency_of_ice_mass_due_to_discharge,discharge_cumulative -timcumsum",
                ts_file,
                cumsum_outfile,
                "\n",
            ]
        )
        f.write(cmd)
        rel_file = os.path.join(
            odir,
            scalar_dir,
            "rel_ts_{domain}_g{grid}m_{experiment}".format(domain=domain.lower(), grid=grid, experiment=full_exp_name),
        )
        rel_outfile = "_".join(["{}_{}_{}.nc".format(rel_file, simulation_start_year, simulation_end_year)])
        cmd = " ".join(
            [
                'cdo setattribute,rel_area_cold@units=1,rel_volume_cold@units=1 -expr,"rel_area_cold=area_glacierized_cold_base/area_glacierized;rel_volume_cold=volume_glacierized_cold/volume_glacierized;"',
                ts_file,
                rel_outfile,
                "\n",
            ]
        )
        f.write(cmd)
        for start in range(simulation_start_year, simulation_end_year, restart_step):
            end = start + restart_step
            outfile = "{domain}_g{grid}m_{experiment}_{start}_{end}.nc".format(
                domain=domain.lower(), grid=grid, experiment=full_exp_name, start=start, end=end
            )
            state_file = os.path.join(odir, state_dir, outfile)
            cmd = " ".join(["ncks -O -4 -L 3", state_file, state_file, "\n"])
            f.write(cmd)


scripts = uniquify_list(scripts)
scripts_combinded = uniquify_list(scripts_combinded)
scripts_post = uniquify_list(scripts_post)
print("\n".join([script for script in scripts]))
print("\nwritten\n")
print("\n".join([script for script in scripts_combinded]))
print("\nwritten\n")
print("\n".join([script for script in scripts_post]))
print("\nwritten\n")
