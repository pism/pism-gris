#!/bin/bash

set -x -e


infile=bedrock_uplift.nc
if [ -n "$1" ]; then
    infile=$1
fi
file=bedrock_uplift_fix.nc
clean=bedrock_uplift_clean.nc
ncpdq -a y,x -O $infile $clean
ncatted -a proj4_params,mapping,o,c,"+init=epsg:3413" -a grid_mapping,u_elastic,o,c,"mapping" -a grid_mapping,u_GIA,o,c,"mapping" $clean
gdalwarp -overwrite -dstnodata -2e9 -of netCDF NETCDF:$clean:u_GIA $file
ncrename -v Band1,dbdt $file
nc2cdo.py --srs "+init=epsg:3413" $file

for GRID in 18000 9000 4500 3600 3000 2400 1800 1500 1200 900; do
    gridfile=g${GRID}m.nc
    outfile=uplift_g${GRID}m.nc
    outfile_tmp=tmp_$outfile
    create_greenland_epsg3413_grid.py -g $GRID $gridfile
    nc2cdo.py $gridfile
    cdo remapycon,$gridfile -selvar,dbdt $file $outfile_tmp
    mpirun -np 2 fill_missing_petsc.py -v dbdt $outfile_tmp $outfile
done
