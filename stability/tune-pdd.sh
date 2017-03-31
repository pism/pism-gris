#!/bin/bash

./warming_restart.py -s debug -n 4 -g 4500 --end_year 4 --step 4 --exstep 1 --test_climate_models --params fsnow,fice,lapse --o_dir 2017_03_tune_pdd_cycle --o_format netcdf3 g4500m_tune_pdd.nc

for file in warm_gris_g4500m_warming_v2_ctrl_lapse_0_tm_0_fice_*_fsnow_*_bed_deformation_off_calving_vonmises_calving_threshold_100_test_climate_on.sh; do
    sh $file
done



GRID=4500

e0=-638000
n0=-3349600
e1=864700
n1=-657600

# Add a buffer on each side such that we get nice grids up to a grid spacing
# of 36 km.

buffer_e=40650
buffer_n=22000
e0=$(($e0 - $buffer_e))
n0=$(($n0 - $buffer_n))
e1=$(($e1 + $buffer_e))
n1=$(($n1 + $buffer_n))

# Shift to cell centers
e0=$(($e0 + $GRID / 2 ))
n0=$(($n0 + $GRID / 2))
e1=$(($e1 - $GRID / 2))
n1=$(($n1 - $GRID / 2))

climate_ext=DMI-HIRHAM5_GL2_ERAI_2001_2014_TM_EPSG3413_${GRID}m.nc
climate_sm=DMI-HIRHAM5_GL2_ERAI_2001_2014_TM_EPSG3413_${GRID}m_sm.nc
climate_melt=DMI-HIRHAM5_GL2_ERAI_2001_2014_TM_EPSG3413_${GRID}m_melt.nc
ncap2 -6 -O -s "where(climatic_mass_balance>-910) climatic_mass_balance=-2e9;" $climate_sm $climate_melt
ncatted -a _FillValue,climatic_mass_balance,o,d,-2e9 $climate_melt
ncks -A -v mask pism_Greenland_4500m_mcb_jpl_v2_ctrl.nc $climate_melt
ncap2 -6 -O -s "where(mask!=2) climatic_mass_balance=-2e9;" $climate_melt $climate_melt

dir=2017_03_tune_pdd_cycle
rmsd_dir=cmb_rmsd
mkdir -p $dir/$rmsd_dir
cd  $dir/state/
for file in *${GRID}*.nc; do
    ncks -6 -O -v climatic_mass_balance $file ../$rmsd_dir/$file
    ncks -6 -A -v mask  ../../$climate_melt ../$rmsd_dir/$file
    ncap2 -O -s "where(mask!=2) climatic_mass_balance=-2e9; where(climatic_mass_balance>0) climatic_mass_balance=-2e9;" ../$rmsd_dir/$file ../$rmsd_dir/$file
    ncatted -a _FillValue,climatic_mass_balance,o,d,-2e9 ../$rmsd_dir/$file
    cdo sqrt -fldmean -sqr -sub -selvar,climatic_mass_balance ../$rmsd_dir/$file -selvar,climatic_mass_balance ../../$climate_melt ../$rmsd_dir/rmsd_$file
    ncks -6 -A -v pism_config $file ../$rmsd_dir/rmsd_$file
done
cd ../..
