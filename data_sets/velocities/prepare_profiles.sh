#!/bin/bash

infile=$1
ofile=$(basename $infile)
flux_gate_file=$2
ftype=$3
grid=250
profile_dir=profiles
mkdir -p ${profile_dir}

extract_profiles.py --special_vars --srs 3413 "${flux_gate_file}" $infile ${profile_dir}/profiles_${grid}m_${ftype}_${ofile}

ncap2 -O -s "velsurf_normal=double(velsurf_mag); velsurf_normal=uvelsurf*nx+vvelsurf*ny; velsurf_normal_error=double(velsurf_mag_error); velsurf_normal_error=uvelsurf_error*nx+vvelsurf_error*ny;"  ${profile_dir}/profiles_${grid}m_${ftype}_${ofile}  ${profile_dir}/profiles_${grid}m_${ftype}_${ofile}
ncatted -a units,velsurf_normal,o,c,"m year-1" -a units,velsurf_normal_error,o,c,"m year-1"  ${profile_dir}/profiles_${grid}m_${ftype}_${ofile}
