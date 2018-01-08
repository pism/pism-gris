#!/bin/bash

var=tas
box="-73,-12,59,84"
ens=r1i1p1
data_dir=cmip5
N=2 
for rcp in 26 45 85; do
    cd ${data_dir}/rcp${rcp}_${ens}_monNG
    for file in tas_mon*nc; do
        echo $file
        cdo -O yearmean -fldmean -selyear,2006/2100 -sellonlatbox,$box $file ../../fldmean_GRIS_2006_2100_$file
        cdo -O sub ../../fldmean_GRIS_2006_2100_$file -timmean -selyear,2006/2015 ../../fldmean_GRIS_2006_2100_$file ../../fldmean_anom_GRIS_2006_2100_$file
    done
    cd ../../
    cdo -O ensmean fldmean_anom_GRIS_2006_2100_*rcp${rcp}*.nc ${var}_cmip5_rcp${rcp}_ensmean_anom_GRIS_2006_2100.nc 
    cdo -O ensstd fldmean_anom_GRIS_2006_2100_*rcp${rcp}*.nc ${var}_cmip5_rcp${rcp}_ensstd_anom_GRIS_2006_2100.nc
    
    cdo -O add  ${var}_cmip5_rcp${rcp}_ensmean_anom_GRIS_2006_2100.nc ${var}_cmip5_rcp${rcp}_ensstd_anom_GRIS_2006_2100.nc ${var}_cmip5_rcp${rcp}_ensstdp1_anom_GRIS_2006_2100.nc 
    cdo -O sub ${var}_cmip5_rcp${rcp}_ensmean_anom_GRIS_2006_2100.nc ${var}_cmip5_rcp${rcp}_ensstd_anom_GRIS_2006_2100.nc ${var}_cmip5_rcp${rcp}_ensstdm1_anom_GRIS_2006_2100.nc

    ncrename -O -v tas,delta_T ${var}_cmip5_rcp${rcp}_ensstdm1_anom_GRIS_2006_2100.nc ${var}_cmip5_rcp${rcp}_ensstdm1_anom_GRIS_2006_2100.nc
    ncrename -O -v tas,delta_T ${var}_cmip5_rcp${rcp}_ensstdp1_anom_GRIS_2006_2100.nc ${var}_cmip5_rcp${rcp}_ensstdp1_anom_GRIS_2006_2100.nc
    
done

exit

for rcp in 26 45 85; do
    #    cdo -O ensmean G/${var}_mon_*native.nc ${var}_cmip5_ensmean.nc
    cd ${data_dir}/rcp${rcp}_${ens}_monNG
    for file in tas_mon*nc; do
        echo $file
        cdo -O yearmean -fldmean -selyear,2006/2100 -sellonlatbox,$box $file ../../fldmean_GRIS_2006_2100_$file
    done
    cd ../../
    cdo -O ensmean fldmean_GRIS_2006_2100_*rcp${rcp}*.nc ${var}_cmip5_rcp${rcp}_ensmean_GRIS_2006_2100.nc 
    cdo -O ensstd fldmean_GRIS_2006_2100_*rcp${rcp}*.nc ${var}_cmip5_rcp${rcp}_ensstd_GRIS_2006_2100.nc
    
    cdo -O add ${var}_cmip5_rcp${rcp}_ensmean_GRIS_2006_2100.nc ${var}_cmip5_rcp${rcp}_ensstd_GRIS_2006_2100.nc ${var}_cmip5_rcp${rcp}_ensstdp1_GRIS_2006_2100.nc
    cdo -O sub ${var}_cmip5_rcp${rcp}_ensmean_GRIS_2006_2100.nc ${var}_cmip5_rcp${rcp}_ensstd_GRIS_2006_2100.nc ${var}_cmip5_rcp${rcp}_ensstdm1_GRIS_2006_2100.nc

    cdo -O sub ${var}_cmip5_rcp${rcp}_ensmean_GRIS_2006_2100.nc -timmean -selyear,2006/2015 ${var}_cmip5_rcp${rcp}_ensmean_GRIS_2006_2100.nc ${var}_cmip5_rcp${rcp}_ensmean_GRIS_2006_2100_rel_warming.nc
    cdo -O selyear,2008/2100  ${var}_cmip5_rcp${rcp}_ensmean_GRIS_2006_2100_rel_warming.nc  ${var}_cmip5_rcp${rcp}_ensmean_GRIS_2008_2100_rel_warming.nc

    cdo -O sub ${var}_cmip5_rcp${rcp}_ensstdp1_GRIS_2006_2100.nc -timmean -selyear,2006/2015 ${var}_cmip5_rcp${rcp}_ensstdp1_GRIS_2006_2100.nc ${var}_cmip5_rcp${rcp}_ensstdp1_GRIS_2006_2100_rel_warming.nc
    cdo -O selyear,2008/2100  ${var}_cmip5_rcp${rcp}_ensstdp1_GRIS_2006_2100_rel_warming.nc  ${var}_cmip5_rcp${rcp}_ensstdp1_GRIS_2008_2100_rel_warming.nc

    cdo -O sub ${var}_cmip5_rcp${rcp}_ensstdm1_GRIS_2006_2100.nc -timmean -selyear,2006/2015 ${var}_cmip5_rcp${rcp}_ensstdm1_GRIS_2006_2100.nc ${var}_cmip5_rcp${rcp}_ensstdm1_GRIS_2006_2100_rel_warming.nc
    cdo -O selyear,2008/2100  ${var}_cmip5_rcp${rcp}_ensstdm1_GRIS_2006_2100_rel_warming.nc  ${var}_cmip5_rcp${rcp}_ensstdm1_GRIS_2008_2100_rel_warming.nc
    
done
