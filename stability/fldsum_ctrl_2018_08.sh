#!/bin/bash
#PBS -q analysis 
#PBS -l walltime=36:00:00
#PBS -l nodes=1:ppn=1
#PBS -j oe

source ~/.bash_profile

cd $SLURM_SUBMIT_DIR

# Spatial fields
rcp=$1
odir=2018_08_ctrl
grid=900
mkdir -p $odir/fldsum
for run in CTRL NTRL NISO; do
    cdo -L -O fldsum -setattribute,dMdt@units="Gt year-1" -aexpr,"dMdt=tendency_of_ice_mass-tendency_of_ice_mass_due_to_flow" -selvar,ice_mass,tendency_of_ice_mass,tendency_of_ice_mass_due_to_flow,tendency_of_ice_mass_due_to_conservation_error,tendency_of_ice_mass_due_to_basal_mass_flux,tendency_of_ice_mass_due_to_surface_mass_flux,tendency_of_ice_mass_due_to_discharge,surface_runoff_rate,surface_accumulation_rate $odir/spatial/ex_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc
    ncks -A -v limnsw,ice_area_glacierized $odir/scalar_clean/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc
    cdo timmean -selyear,2095/2105 $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_2100.nc
    cdo timmean -selyear,2195/2205 $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_2200.nc
    cdo timmean -selyear,2295/2305 $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_2300.nc
    cdo timmean -selyear,2995/3005 $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_3000.nc
done

