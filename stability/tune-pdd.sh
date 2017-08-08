#!/bin/bash

odir=2017_07_pdd_calib_1200m
grid=4500

./warming_restart.py --o_size big --o_dir $odir --test_climate_models --exstep monthly --params fice -n 4 -w 1:00:00 -g 4500 -s debug  --step 2 --duration 2  ../calibration/2017_06_vc/state/gris_g4500m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

sh warm_gris_g4500m_v3a_fice_8_bd_off_test_climate_on.sh

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
e0=$(($e0 + $grid / 2 ))
n0=$(($n0 + $grid / 2))
e1=$(($e1 - $grid / 2))
n1=$(($n1 - $grid / 2))

climate_ext=../data_sets/climate_forcing/DMI-HIRHAM5_GL2_ERAI_2001_2014_TM_BIL_EPSG3413_${grid}m.nc
climate_sm=../data_sets/climate_forcing/DMI-HIRHAM5_GL2_ERAI_2001_2014_TM_BIL_EPSG3413_${grid}m_sm.nc
climate_melt=../data_sets/climate_forcing/DMI-HIRHAM5_GL2_ERAI_2001_2014_TM_BIL_EPSG3413_${grid}m_melt.nc
climate_melt_sum=../data_sets/climate_forcing/DMI-HIRHAM5_GL2_ERAI_2001_2014_TM_BIL_EPSG3413_${grid}m_melt_fldsum.nc

ncks -O -d x,$e0.,$e1. -d y,$n0.,$n1. $climate_ext $climate_sm

ncatted -a _FillValue,climatic_mass_balance,o,d,-2e9 $climate_melt
ncks -A -v mask ../data_sets/bed_dem/pism_Greenland_4500m_mcb_jpl_v3a_ctrl.nc $climate_melt
ncap2 -6 -O -s "where(mask!=2) climatic_mass_balance=-2e9;" $climate_melt $climate_melt
cdo setattribute,climatic_mass_balance@units="Gt year-1"  -divc,1e12 -mulc,4500 -mulc,4500 -fldsum $climate_melt $climate_melt_sum

rmsd_dir=cmb_rmsd
mkdir -p $odir/$rmsd_dir
cd  $odir/state/
for file in *${grid}*.nc; do
    ncks -6 -O -v climatic_mass_balance $file ../$rmsd_dir/$file
    ncks -6 -A -v mask  ../../$climate_melt ../$rmsd_dir/$file
    ncap2 -O -s "where(mask!=2) climatic_mass_balance=-2e9;" ../$rmsd_dir/$file ../$rmsd_dir/$file
    ncatted -a _FillValue,climatic_mass_balance,o,d,-2e9 ../$rmsd_dir/$file
    cdo setattribute,climatic_mass_balance@units="Gt year-1"  -divc,1e12 -mulc,4500 -mulc,4500 -fldsum ../$rmsd_dir/$file ../$rmsd_dir/fldsum_$file

    cdo sqrt -fldmean -sqr -sub -selvar,climatic_mass_balance ../$rmsd_dir/$file -selvar,climatic_mass_balance ../../$climate_melt ../$rmsd_dir/rmsd_$file
    gdal_translate  NETCDF:../$rmsd_dir/$file:climatic_mass_balance  ../$rmsd_dir/$file.tif
done
cd ../..
