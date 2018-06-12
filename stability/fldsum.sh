#!/bin/bash
#PBS -q analysis
#PBS -l walltime=36:00:00
#PBS -l nodes=1:ppn=1
#PBS -j oe
#SBATCH --mem=214GB

source ~/.bash_profile

cd $SLURM_SUBMIT_DIR

odir=2018_05_ctrl
grid=900
mkdir -p $odir/fldsum
run=$2
rcp=$1
cdo -L -O fldsum -setmisstoc,0 -setattribute,dMdt@units="Gt year-1" -aexpr,"dMdt=tendency_of_ice_mass-tendency_of_ice_mass_due_to_flow" -selvar,ice_mass,tendency_of_ice_mass,tendency_of_ice_mass_due_to_flow,tendency_of_ice_mass_due_to_conservation_error,tendency_of_ice_mass_due_to_basal_mass_flux,tendency_of_ice_mass_due_to_surface_mass_flux,tendency_of_ice_mass_due_to_discharge,surface_runoff_rate,surface_accumulation_rate $odir/spatial/ex_gris_g900m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/fldsum/ts_gris_g900m_v3a_rcp_${rcp}_id_${run}_0_1000.nc
cd ../../
