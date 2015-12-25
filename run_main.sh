#!/bin/bash

# Copyright (C) 2015 Andy Aschwanden and the PISM authors

set -e  # exit on error

CLIMLIST="{const, paleo, pdd, climate, ocean, climateocean}"
HYDROLIST="{null, routing, distributed}"

# preprocess.sh generates pism_*.nc files; run it first
if [ -n "${PISM_DATANAME:+1}" ] ; then  # check if env var is already set
    PISM_DATANAME=$PISM_DATANAME
else
    PISM_DATANAME=pism_Greenland_5km_v3_ctrl.nc
fi

if [ $# -lt 2 ] ; then
  echo "run.sh ERROR: needs 2 or 3 or 4 or 5 positional arguments ... ENDING NOW"
  echo
  echo "usage:"
  echo
  echo "    run.sh PROCS CLIMATE DURATION HYRDRO [OUTFILE] [BOOTFILE]"
  echo
  echo "  where:"
  echo "    PROCS     = 1,2,3,... is number of MPI processes"
  echo "    DURATION  = model run time in years; does '-ys -DURATION -ye 0'"
  echo "    HYDRO     in $HYDROLIST; default = null"
  echo "    OUTFILE   optional name of output file; default = unnamed.nc"
  echo "    BOOTFILE  optional name of input file; default = $PISM_DATANAME"
  echo
  echo "consider setting optional environment variables (see script for meaning):"
  echo "    PISM_DATANAME sets DATANAME file used for input data"
  echo "    TSSTEP       spacing between -ts_files outputs; defaults to yearly"
  echo "    EXSTEP       spacing in years between -extra_files outputs; defaults to 100"
  echo "    EXSPLIT      if set, extra files are split"
  echo "    EXVARS       desired -extra_vars; defaults to 'diffusivity,temppabase,"
  echo "                   tempicethk_basal,bmelt,tillwat,csurf,mask,thk,topg,usurf'"
  echo "                   plus ',hardav,cbase,tauc' if DYNAMICS=hybrid"
  echo "    NODIAGS      if set, DON'T use -ts_file or -extra_file"
  echo "    PARAM_BEDDEF  sets the bed deformation method"
  echo "                 [default=not set] for [iso,lc]"
  echo "    PARAM_CALVING_K sets eigen-calving K [default=1e18]"
  echo "    PARAM_CALVING_THK sets calving threshold [default=50]"
  echo "    PARAM_FRACTURE if set, run default fracture dynamics"
  echo "    PARAM_FSOFT sets fracture softening [default=1]"
  echo "    PARAM_NOAGE    if set, DON'T calculate age"
  echo "    PARAM_E_AGE_COUPLING    if set, couple enhancement factor to age of ice."
  echo "    PARAM_NOENERGY if set, DON'T use energy updates"
  echo "    PARAM_SHELF_BASE_MELT_RATE sets option -shelf_base_melt_rate \$PARAM_SHELF_BASE_MELT_RATE"
  echo "    PARAM_FTT    if set, use force-to-thickness method"
  echo "    PARAM_K      sets -hydraulic_conductivity \$PARAM_K"
  echo "                 [default=0.01] for [routing,distributed]"
  echo "    PARAM_ALPHA   sets -hydrology_thickness_power_in_flux \$PARAM_ALPHA"
  echo "                 [default=0.5] for [routing, distributed]"
  echo "    PARAM_OMEGA  sets -tauc_add_transportable_water -till_log_factor_transportable_water \$PARAM_OMEGA"
  echo "                 [default=0.04] for [routing, distributed]"
  echo "    PISM_PARAMS  gives you the flexibility of adding options"
  echo "                 [default=none]"
  echo "    PISM_DO      set to 'echo' if no run desired; defaults to empty"
  echo "    PISM_MPIDO   defaults to 'mpiexec -n'"
  echo "    PISM_PREFIX  set to path to pismr executable if desired; defaults to empty"
  echo "    PISM_EXEC    defaults to 'pismr'"
  echo "    PISM_CONFIG  config file, defaults to hydro_config.nc"
  echo "    PISM_SAVE    set -save_times, defaults to None"
  echo "    REGRIDFILE   set to file name to regrid from; defaults to empty (no regrid)"
  echo "    REGRIDVARS   desired -regrid_vars; applies *if* REGRIDFILE set;"
  echo "                   defaults to 'bmelt,enthalpy,litho_temp,thk,tillwat,Href'"
  echo "    STARTEND     sets START and END year of a simulation. If used, overwrites DURA. e.g. -50000,2500 for a run from -50000 to 2500 years"
  echo
  echo "example usage 1:"
  echo
  echo "    $ ./run.sh 4 const 1000 18000 sia"
  echo
  echo "  Does spinup with 4 processors, constant-climate, 1000 year run, 18 km"
  echo "  grid, and non-sliding SIA stress balance.  Bootstraps from and outputs to"
  echo "  default files."
  echo
  echo "example usage 2:"
  echo
  echo "    $ PISM_DO=echo ./run.sh 128 paleo 100.0 4500 hybrid out.nc boot.nc &> foo.sh"
  echo
  echo "  Creates a script foo.sh for spinup with 128 processors, simulated paleo-climate,"
  echo "  4.5 km grid, sliding with SIA+SSA hybrid, output to {out.nc,ts_out.nc,ex_out.nc},"
  echo "  and bootstrapping from boot.nc."
  echo
  exit
fi

if [ -n "${SCRIPTNAME:+1}" ] ; then
  echo "[SCRIPTNAME=$SCRIPTNAME (already set)]"
  echo ""
else
  SCRIPTNAME="#(run.sh)"
fi

if [ $# -gt 8 ] ; then
  echo "$SCRIPTNAME WARNING: ignoring arguments after argument 7 ..."
fi

NN="$1" # first arg is number of processes

# are we doing force to thickness?
PISM_FTT_FILE=$PISM_DATANAME
if [ -z "${PARAM_FTT}" ] ; then  # check if env var is NOT set
    FTT=""
else
    if [ -z "${PARAM_FTT_STARTTIME}" ] ; then  # check if env var is NOT set
        FTT=",forcing -force_to_thickness_start_time 0 -force_to_thickness_file $PISM_FTT_FILE"
    else
        FTT=",forcing -force_to_thickness_start_time $PARAM_FTT_STARTTIME -force_to_thickness_file $PISM_FTT_FILE"
    fi
fi

if [ -z "${PARAM_BEDDEF}" ] ; then  # check if env var is NOT set
    BEDDEF=""
else
    BEDDEF="-bed_def $PARAM_BEDDEF"
fi

# are we calculating the age of the ice?
if [ -z "${PARAM_NOAGE}" ] ; then  # check if env var is NOT set
    AGE="-age"
else
    AGE=""
fi

if [ -z "${PISM_SURFACE_BCFILE}" ] ; then  # check if env var is NOT set
    PISM_SURFACE_BCFILE=GR6b_ERAI_1989_2011_4800M_BIL_1989_baseline.nc
else
    PISM_SURFACE_BCFILE=$PISM_SURFACE_BCFILE
fi

if [ -z "${PISM_OCEAN_BCFILE}" ] ; then  # check if env var is NOT set
    OCEAN="-ocean constant"
else
    PISM_OCEAN_BCFILE=$PISM_OCEAN_BCFILE
    OCEAN="-ocean given -ocean_given_file $PISM_OCEAN_BCFILE"
fi

# override config file?
if [ -z "${PISM_CONFIG}" ] ; then  # check if env var is NOT set
    CONFIG=hydro_config.nc
else
    CONFIG=$PISM_CONFIG
fi



if [ -n "${PARAM_NOENERGY+1}" ] ; then  # check if env var is set
    ENERGY="-energy none"
else
    ENERGY=""
fi

# set stress balance from argument 4
if [ -n "${PARAM_SIA_N:+1}" ] ; then  # check if env var is NOT set
    SIA_N="-sia_n ${PARAM_SIA_N}"
else
    SIA_N="-sia_n 3"
fi

if [ -n "${PARAM_CALVING+1}" ] ; then  # check if env var is set
  PARAM_CALVING=$PARAM_CALVING
else
  PARAM_CALVING="ocean_kill"
fi

if [ -n "${PARAM_CALVING_THK+1}" ] ; then  # check if env var is set
  CALVING_THK=$PARAM_CALVING_THK
else
  CALVING_THK=50
fi

if [ -n "${PARAM_SHELF_BASE_MELT_RATE+1}" ] ; then  # check if env var is set
  SHELF_BASE_MELT_RATE="-shelf_base_melt_rate ${PARAM_SHELF_BASE_MELT_RATE}"
else
  SHELF_BASE_MELT_RATE=""
fi


if [ -n "${PARAM_CALVING_K+1}" ] ; then  # check if env var is set
  CALVING_K=$PARAM_CALVING_K
else
  CALVING_K=1e18
fi

if [ "$PARAM_CALVING" == "ocean_kill" ]; then
  CALVING="-calving $PARAM_CALVING -ocean_kill_file $PISM_DATANAME"
elif [ "$PARAM_CALVING" == "float_kill" ]; then
    CALVING="-calving $PARAM_CALVING"
elif [ "$PARAM_CALVING" == "eigen_calving" ]; then
    CALVING="-calving $PARAM_CALVING,thickness_calving -thickness_calving_threshold $CALVING_THK  -pik -eigen_calving_K $CALVING_K -cfl_eigen_calving"
    echo "Make sure you set the eigen-calving parameters"
    echo "This option is untested"
elif [ "$PARAM_CALVING" == "thickness_calving" ]; then
    CALVING="-calving $PARAM_CALVING -thickness_calving_threshold $CALVING_THK"
    echo "Make sure you set the thickness-calving parameters"
    echo "This option is untested"
else
    echo "invalid calving model $PARAM_CALVING"
    exit
fi

if [ -n "${PARAM_FRACTURE+1}" ] ; then  # check if env var is set
    THRESHOLD=4.5e4   #  stress threshold
    FRACRATE=0.5   #  fracture rate
    HEALTHRESHOLD=2.0e-10   #  healing threshold
    HEALRATE=0.05   #  healing rate
    SOFTRES=1   #  softening residual (avoid viscosity from degeneration), value 1 inhibits softening effect
    criterion=""
    boundary="-do_frac_on_grounded"
    healing=""
    if [ -n "${PARAM_FSOFT+1}" ]; then
        SOFTRES=$PARAM_FSOFT
    fi
    softening="-fracture_softening ${SOFTRES}"
    EXFRACS=",fracture_density,fracture_flow_enhancement,fracture_growth_rate,fracture_healing_rate,fracture_toughness"
    FRACTURE="-fractures ${FRACRATE},${THRESHOLD},${HEALRATE},${HEALTHRESHOLD} -write_fd_fields -scheme_fd2d ${healing} ${boundary} ${criterion} ${softening}"
else
    FRACTURE=""
fi


PHYS="$BEDDEF $ENERGY $CALVING"


if [ -n "${PARAM_ALPHA+1}" ] ; then  # check if env var is set
  PARAM_ALPHA=$PARAM_ALPHA
else
  PARAM_ALPHA="1.25"
fi
if [ -n "${PARAM_OMEGA+1}" ] ; then  # check if env var is set
  PARAM_OMEGA=$PARAM_OMEGA
else
  PARAM_OMEGA="0.1"
fi
if [ -n "${PARAM_K+1}" ] ; then  # check if env var is set
  PARAM_K=$PARAM_K
else
  PARAM_K="0.01"
fi

if [ -n "${PARAM_E_AGE_COUPLING+1}" ] ; then  # check if env var is set
  PARAM_E_AGE_COUPLING="-e_age_coupling"
else
  PARAM_E_AGE_COUPLING=""
fi

HYDROPARAMS="-hydrology_thickness_power_in_flux ${PARAM_ALPHA} -tauc_add_transportable_water -till_log_factor_transportable_water ${PARAM_OMEGA} -hydrology_hydraulic_conductivity ${PARAM_K}"

# set output filename from argument 3
if [ "$3" = "null" ]; then
  HYDRO="-hydrology null"
elif [ "$3" = "routing" ]; then
  HYDRO="-hydrology routing $HYDROPARAMS"
elif [ "$3" = "distributed" ]; then
  HYDRO="-hydrology distributed $HYDROPARAMS"
else
  echo "invalid sixth argument, must be in $HYDROLIST"
fi

# set output filename from argument 4
if [ -z "$4" ]; then
  OUTNAME=unnamed.nc
else
  OUTNAME=$4
fi
OUTNAMESANS=`basename $OUTNAME .nc`

# set bootstrapping input filename from argument 5
if [ -z "$5" ]; then
  INNAME=$PISM_DATANAME
else
  INNAME=$5
fi
INLIST="${INLIST} $INNAME $REGRIDFILE $CONFIG"

# now we have read options ... we know enough to report to user ...
echo
echo "# ===================================================================="
echo "# PISM Greenland run:"
echo "#    $NN processors, $DURATION a run, $dx m grid, $climname, $5 dynamics"
echo "# ===================================================================="

# actually check for input files
for INPUT in $INLIST; do
  if [ -e "$INPUT" ] ; then  # check if file exist
    echo "$SCRIPTNAME           input   $INPUT (found)"
  else
    echo "$SCRIPTNAME           input   $INPUT (MISSING!!)"
    echo
    echo "$SCRIPTNAME  ***WARNING***  you may need to run ./preprocess.sh to generate standard input files!"
    echo
  fi
done

echo "$SCRIPTNAME              NN = $NN"

# set output format:
#  $ export PISM_OFORMAT="netcdf4_parallel "
if [ -n "${PISM_OFORMAT:+1}" ] ; then  # check if env var is already set
  echo "$SCRIPTNAME                      PISM_OFORMAT = $PISM_OFORMAT  (already set)"
else
  PISM_OFORMAT="netcdf3"
  echo "$SCRIPTNAME                      PISM_OFORMAT = $PISM_OFORMAT"
fi
OFORMAT=$PISM_OFORMAT

# check if env var PISM_PARAMS was set
if [ -n "${PISM_PARAMS:+1}" ] ; then  # check if env var DO is already set
  echo "$SCRIPTNAME        PISM_PARAMS = $PISM_PARAMS  (already set)"
else
  PISM_PARAMS="" 
fi

# set MPIDO if using different MPI execution command, for example:
#  $ export PISM_MPIDO="aprun -n "
if [ -n "${PISM_MPIDO:+1}" ] ; then  # check if env var is already set
  echo "$SCRIPTNAME      PISM_MPIDO = $PISM_MPIDO  (already set)"
else
  PISM_MPIDO="mpiexec -n "
  echo "$SCRIPTNAME      PISM_MPIDO = $PISM_MPIDO"
fi

# check if env var PISM_DO was set (i.e. PISM_DO=echo for a 'dry' run)
if [ -n "${PISM_DO:+1}" ] ; then  # check if env var DO is already set
  echo "$SCRIPTNAME         PISM_DO = $PISM_DO  (already set)"
else
  PISM_DO="" 
fi

# prefix to pism (not to executables)
if [ -n "${PISM_PREFIX:+1}" ] ; then  # check if env var is already set
  echo "$SCRIPTNAME     PISM_PREFIX = $PISM_PREFIX  (already set)"
else
  PISM_PREFIX=""    # just a guess
  echo "$SCRIPTNAME     PISM_PREFIX = $PISM_PREFIX"
fi

# set PISM_EXEC if using different executables, for example:
#  $ export PISM_EXEC="pismr -energy cold"
if [ -n "${PISM_EXEC:+1}" ] ; then  # check if env var is already set
  echo "$SCRIPTNAME       PISM_EXEC = $PISM_EXEC  (already set)"
else
  PISM_EXEC="pismr"
  echo "$SCRIPTNAME       PISM_EXEC = $PISM_EXEC"
fi

# set TSSTEP to default if not set
if [ -n "${TSSTEP:+1}" ] ; then  # check if env var is already set
  echo "$SCRIPTNAME          TSSTEP = $TSSTEP  (already set)"
else
  TSSTEP=yearly
  echo "$SCRIPTNAME          TSSTEP = $TSSTEP"
fi

# set EXSTEP to default if not set
if [ -n "${EXSTEP:+1}" ] ; then  # check if env var is already set
  echo "$SCRIPTNAME          EXSTEP = $EXSTEP  (already set)"
else
  EXSTEP="100"
  echo "$SCRIPTNAME          EXSTEP = $EXSTEP"
fi

if [ -z "${EXSPLIT}" ] ; then  # check if env var is NOT set
    EXSPLIT=""
else
    EXSPLIT="-extra_split"
fi

# set EXVARS list to defaults if not set
if [ -n "${EXVARS:+1}" ] ; then  # check if env var is already set
  echo "$SCRIPTNAME          EXVARS = $EXVARS  (already set)"
else
  EXVARS="climatic_mass_balance_cumulative,tempsurf,effbwp,bwp,bwprel,bwat,bwatvel,diffusivity,temppabase,tempicethk_basal,bmelt,tillwat,velsurf_mag,mask,thk,topg,usurf,taud_mag,flux_divergence,velsurf,climatic_mass_balance,climatic_mass_balance_original,discharge_flux_cumulative,deviatoric_stresses,,$EXFRACS"
  EXVARS="${EXVARS},hardav,velbase_mag,tauc,taub_mag"
  echo "$SCRIPTNAME          EXVARS = $EXVARS"
fi

# if REGRIDFILE set then form regridcommand
if [ -n "${REGRIDFILE:+1}" ] ; then  # check if env var is already set
  echo "$SCRIPTNAME      REGRIDFILE = $REGRIDFILE"
  if [ -n "${REGRIDVARS:+1}" ] ; then  # check if env var is already set
    echo "$SCRIPTNAME      REGRIDVARS = $REGRIDVARS  (already set)"
  else
    REGRIDVARS='litho_temp,thk,enthalpy,tillwat,bmelt,Href,age'
    echo "$SCRIPTNAME      REGRIDVARS = $REGRIDVARS"
  fi
  regridcommand="-regrid_file $REGRIDFILE -regrid_vars $REGRIDVARS"
else
  regridcommand=""
fi

# set save times:
if [ -n "${PISM_SAVE:+1}" ] ; then  # check if env var is already set
  echo "$SCRIPTNAME                      PISM_SAVE = $PISM_SAVE  (already set)"
  OUTNAMESANS=`basename $OUTNAME .nc`
  SAVE="-save_times $PISM_SAVE -save_split -save_force_output_times -save_file save_$OUTNAMESANS"
else
  SAVE=""
fi


# show remaining setup options:
PISM="${PISM_PREFIX}${PISM_EXEC}"
echo "$SCRIPTNAME      executable = '$PISM'"
echo "$SCRIPTNAME         coupler = '$COUPLER'"
echo "$SCRIPTNAME        dynamics = '$PHYS'"

# are we using a time file for forcing?
if [ -z "${PISM_TIMEFILE}" ] ; then  # check if env var is NOT set
    if [ -z "${STARTEND}" ] ; then  # check if env var is NOT set
        DURATION=$2
        END=$DURATION
        START=0
        RUNSTARTEND="-ys $START -ye $END"
    else
        STARTEND=$STARTEND
        IFS=',' read START END <<<"$STARTEND"
        RUNSTARTEND="-ys $START -ye $END"
    fi
fi

# construct command
cmd="$PISM_MPIDO $NN $PISM ${SHELF_BASE_MELT_RATE} -config_override $CONFIG $AGE -i $INNAME -bootstrap $RUNSTARTEND $regridcommand $PARAM_E_AGE_COUPLING $PISM_PARAMS $COUPLER $PHYS $FRACTURE $HYDRO $SAVE  -o $OUTNAME"
echo
$PISM_DO $cmd

