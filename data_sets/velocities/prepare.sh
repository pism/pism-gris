#!/bin/bash

indir=$1
dataset_dir=measures
version=v1
mkdir -p ${dataset_dir}
profile_dir=profiles
mkdir -p ${profile_dir}
prefix=greenland_vel_mosaic250
for var in vx vy ex ey; do
    gdal_translate -a_srs epsg:3413 -a_nodata -2e9 "${indir}/${prefix}_${var}_${version}.tif" ${dataset_dir}/${prefix}_${var}_${version}.nc
    if [[ "${var}" == "vx" ]]; then
        mvar=uvelsurf
        ncrename -v Band1,${mvar} ${dataset_dir}/${prefix}_${var}_${version}.nc
        ncks -O -v ${mvar} ${dataset_dir}/${prefix}_${var}_${version}.nc ${dataset_dir}/${prefix}_${version}.nc
        ncatted -a units,${mvar},o,c,"m year-1"  ${dataset_dir}/${prefix}_${version}.nc
    elif [[ "${var}" == "vy" ]]; then
        mvar=vvelsurf
        ncrename -v Band1,${mvar} ${dataset_dir}/${prefix}_${var}_${version}.nc
        ncks -A -v ${mvar} ${dataset_dir}/${prefix}_${var}_${version}.nc ${dataset_dir}/${prefix}_${version}.nc
        ncatted -a units,${mvar},o,c,"m year-1"  ${dataset_dir}/${prefix}_${version}.nc
    elif  [[ "${var}" == "ex" ]]; then
        mvar=uvelsurf_error 
        ncrename -v Band1,${mvar} ${dataset_dir}/${prefix}_${var}_${version}.nc
        ncks -A -v ${mvar} ${dataset_dir}/${prefix}_${var}_${version}.nc ${dataset_dir}/${prefix}_${version}.nc
        ncatted -a units,${mvar},o,c,"m year-1"  ${dataset_dir}/${prefix}_${version}.nc
    elif  [[ "${var}" == "ey" ]]; then
        mvar=vvelsurf_error
        ncrename -v Band1,${mvar} ${dataset_dir}/${prefix}_${var}_${version}.nc
        ncks -A -v ${mvar} ${dataset_dir}/${prefix}_${var}_${version}.nc ${dataset_dir}/${prefix}_${version}.nc
        ncatted -a units,${mvar},o,c,"m year-1"  ${dataset_dir}/${prefix}_${version}.nc
    fi
done
ncap2 -O -s "velsurf_mag=(uvelsurf^2+vvelsurf^2)^0.5; velsurf_mag_error=(uvelsurf_error^2+vvelsurf_error^2)^(0.5);" ${dataset_dir}/${prefix}_${version}.nc ${dataset_dir}/${prefix}_${version}.nc
rm -f  ${profile_dir}/profiles_${grid}m_${prefix}_${version}.nc


flux_gate_file=$2
ftype=$3
grid=250
~/base/pypismtools/scripts/extract_profiles.py --special_vars --srs 3413 "${flux_gate_file}" ${dataset_dir}/${prefix}_${version}.nc ${profile_dir}/profiles_${grid}m_${ftype}_${prefix}_${version}.nc

ncap2 -O -s "velsurf_normal=double(velsurf_mag); velsurf_normal=uvelsurf*nx+vvelsurf*ny; velsurf_normal_error=double(velsurf_mag_error); velsurf_normal_error=uvelsurf_error*nx+vvelsurf_error*ny;" ${profile_dir}/profiles_${grid}m_${ftype}_${prefix}_${version}.nc ${profile_dir}/profiles_${grid}m_${ftype}_${prefix}_${version}.nc
ncatted -a units,velsurf_normal,o,c,"m year-1" -a units,velsurf_normal_error,o,c,"m year-1" ${profile_dir}/profiles_${grid}m_${ftype}_${prefix}_${version}.nc
