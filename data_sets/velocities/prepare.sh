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
ncap2 -O -s "velsurf_mag=(uvelsurf^2+vvelsurf^2)^0.5; velsurf_mag_error=uvelsurf_error;" ${dataset_dir}/${prefix}_${version}.nc ${dataset_dir}/${prefix}_${version}.nc
rm -f ${profile_dir}/profiles_${prefix}_${version}.nc

flux_gate_file=$2
~/base/pypismtools/scripts/extract_profiles.py --special_vars --srs 3413 -s "${flux_gate_file}" ${dataset_dir}/${prefix}_${version}.nc ${profile_dir}/profiles_${prefix}_${version}.nc
#python add_normals.py ${profile_dir}/profiles_${prefix}_${version}.nc 
#ncatted -a units,velsurf_normal,o,c,"m year-1" -a units,velsurf_normal_error,o,c,"m year-1"  ${profile_dir}/profiles_${prefix}_${version}.nc 
