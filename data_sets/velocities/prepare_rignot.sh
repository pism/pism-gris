#!/bin/bash

set -x 
indir=$1
dataset_dir=rignot
version=v4Aug2014
mkdir -p ${dataset_dir}
prefix=velocity_greenland
infile=${indir}/${prefix}_${version}.nc
# The input file is upside down and needs to be flipped
ncpdq -4 -O -a -ny,nx "$infile" ${dataset_dir}/${prefix}_${version}.nc
srsfile=srs.nc
gdal_translate -a_srs epsg:3413 NETCDF:${dataset_dir}/${prefix}_${version}.nc:vx $srsfile
ncrename -d ny,y -d nx,x -v xaxis,x -v yaxis,y -v vx,uvelsurf -v vy,vvelsurf -v err,uvelsurf_error ${dataset_dir}/${prefix}_${version}.nc
ncatted  -a units,uvelsurf,o,c,"m year-1"  -a units,vvelsurf,o,c,"m year-1"  -a units,uvelsurf_error,o,c,"m year-1" -a grid_mapping,uvelsurf,o,c,"polar_stereographic"  -a grid_mapping,vvelsurf,o,c,"polar_stereographic"  -a grid_mapping,uvelsurf_error,o,c,"polar_stereographic"  ${dataset_dir}/${prefix}_${version}.nc
ncap2 -O -s "x=double(x); y=double(y); velsurf_mag=(uvelsurf^2+vvelsurf^2)^0.5; velsurf_mag_error=uvelsurf_error; vvelsurf_error=uvelsurf_error;" ${dataset_dir}/${prefix}_${version}.nc ${dataset_dir}/${prefix}_${version}.nc
ncks -A -C -v polar_stereographic $srsfile  ${dataset_dir}/${prefix}_${version}.nc
rm $srsfile

# Convert to annual velocities and update uncertainties (see Aschwanden, 2016):
ncap2 -O -s "uvelsurf=uvelsurf*1.1; vvelsurf=vvelsurf*1.1; velsurf_mag=velsurf_mag*1.1; uvelsurf_error=uvelsurf_error+0.05*uvelsurf; vvelsurf_error=vvelsurf_error+0.05*vvelsurf; velsurf_mag_error=(uvelsurf_error^2+vvelsurf_error^2)^0.5;" ${dataset_dir}/${prefix}_${version}.nc ${dataset_dir}/${prefix}_${version}_annual.nc
