#!/bin/bash

var=tas
box="-73,-12,59,84"
ens=r1i1p1
data_dir=cmip5-2300
tmp_dir=tmp
mkdir -p ${data_dir}/${tmp_dir}

for rcp in 26 45 85; do
    for gcm in GISS-E2-H GISS-E2-R IPSL-CM5A-LR MPI-ESM-LR; do
        cdo -O mergetime ${data_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_*.nc ${data_dir}/${tmp_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_2006-23xx.nc
        cdo -O -L yearmean -selyear,2006/2300 -fldmean -sellonlatbox,$box ${data_dir}/${tmp_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_2006-23xx.nc ${data_dir}/${tmp_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_ym_GRIS_2006-2300.nc
        cdo -O sub ${data_dir}/${tmp_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_ym_GRIS_2006-2300.nc -timmean -selyear,2006/2015 ${data_dir}/${tmp_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_ym_GRIS_2006-2300.nc ${data_dir}/${tmp_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_ym_anom_GRIS_2006-2300.nc
        cdo -O -L selyear,2008/2300  ${data_dir}/${tmp_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_ym_anom_GRIS_2006-2300.nc ${data_dir}/${tmp_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_ym_anom_GRIS_2008-2300.nc
        cdo -O trend -selyear,2201/2300 ${data_dir}/${tmp_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_ym_anom_GRIS_2008-2300.nc ${data_dir}/${tmp_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_ym_anom_GRIS_2008-2300_a.nc ${data_dir}/${tmp_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_ym_anom_GRIS_2008-2300_b.nc
        ncks -O ${data_dir}/${tmp_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_ym_anom_GRIS_2008-2300.nc ${data_dir}/${tmp_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_ym_anom_GRIS_2008-7008.nc 
        python extend_cmip5.py ${data_dir}/${tmp_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_ym_anom_GRIS_2008-7008.nc  ${data_dir}/${tmp_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_ym_anom_GRIS_2008-2300_a.nc ${data_dir}/${tmp_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_ym_anom_GRIS_2008-2300_b.nc
        ncrename -O -v tas,delta_T ${data_dir}/${tmp_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_ym_anom_GRIS_2008-7008.nc
        ncwa -a lat,lon -O ${data_dir}/${tmp_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_ym_anom_GRIS_2008-7008.nc ${data_dir}/${tmp_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_ym_anom_GRIS_2008-7008.nc
        ncatted -O -a units,time,o,c,"years since 1-1-1 12:00" ${data_dir}/${tmp_dir}/${var}_Amon_${gcm}_rcp${rcp}_${ens}_ym_anom_GRIS_2008-7008.nc ${var}_Amon_${gcm}_rcp${rcp}_${ens}_ym_anom_GRIS_0-5000.nc
    done
    cdo -O -P 4 ensmin ${var}_Amon_GISS-E2-H_rcp${rcp}_${ens}_ym_anom_GRIS_0-5000.nc ${var}_Amon_GISS-E2-R_rcp${rcp}_${ens}_ym_anom_GRIS_0-5000.nc ${var}_Amon_IPSL-CM5A-LR_rcp${rcp}_${ens}_ym_anom_GRIS_0-5000.nc ${var}_Amon_MPI-ESM-LR_rcp${rcp}_${ens}_ym_anom_GRIS_0-5000.nc ${var}_Amon_ENSMIN_rcp${rcp}_${ens}_ym_anom_GRIS_0-5000.nc
    cdo -O -P 4 ensmean ${var}_Amon_GISS-E2-H_rcp${rcp}_${ens}_ym_anom_GRIS_0-5000.nc ${var}_Amon_GISS-E2-R_rcp${rcp}_${ens}_ym_anom_GRIS_0-5000.nc ${var}_Amon_IPSL-CM5A-LR_rcp${rcp}_${ens}_ym_anom_GRIS_0-5000.nc ${var}_Amon_MPI-ESM-LR_rcp${rcp}_${ens}_ym_anom_GRIS_0-5000.nc ${var}_Amon_ENSMEAN_rcp${rcp}_${ens}_ym_anom_GRIS_0-5000.nc
    cdo -O -P 4 ensmax ${var}_Amon_GISS-E2-H_rcp${rcp}_${ens}_ym_anom_GRIS_0-5000.nc ${var}_Amon_GISS-E2-R_rcp${rcp}_${ens}_ym_anom_GRIS_0-5000.nc ${var}_Amon_IPSL-CM5A-LR_rcp${rcp}_${ens}_ym_anom_GRIS_0-5000.nc ${var}_Amon_MPI-ESM-LR_rcp${rcp}_${ens}_ym_anom_GRIS_0-5000.nc ${var}_Amon_ENSMAX_rcp${rcp}_${ens}_ym_anom_GRIS_0-5000.nc
done
