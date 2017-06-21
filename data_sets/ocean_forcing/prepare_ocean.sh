#!/bin/bash


set -x -e

GRID=3000

infile=../bed_dem/pism_Greenland_ext_${GRID}m_mcb_jpl_v3a.nc
lat=80
bmelt0=300
bmelt1=10
outfile=ocean_forcing_latitudinal_${bmelt0}myr_lat_69_${bmelt1}myr_${lat}n.nc
ncks -6 -C -O -v x,y,mask,polar_stereographic $infile $outfile
python ocean_forcing.py --bmelt_0 $bmelt0 --bmelt_1 $bmelt1 --lat_1 ${lat} $outfile
ncatted -a grid_mapping,mask,o,c,"polar_stereographic" -a grid_mapping,shelfbmassflux,o,c,"polar_stereographic" -a grid_mapping,shelfbtemp,o,c,"polar_stereographic" $outfile

bmelt0=400
bmelt1=20
outfile=ocean_forcing_latitudinal_${bmelt0}myr_lat_69_${bmelt1}myr_${lat}n.nc
ncks -6 -C -O -v x,y,mask,polar_stereographic $infile $outfile
python ocean_forcing.py --bmelt_0 $bmelt0 --bmelt_1 $bmelt1 --lat_1 ${lat} $outfile
ncatted -a grid_mapping,mask,o,c,"polar_stereographic" -a grid_mapping,shelfbmassflux,o,c,"polar_stereographic" -a grid_mapping,shelfbtemp,o,c,"polar_stereographic" $outfile

bmelt0=500
bmelt1=30
outfile=ocean_forcing_latitudinal_${bmelt0}myr_lat_69_${bmelt1}myr_${lat}n.nc
ncks -6 -C -O -v x,y,mask,polar_stereographic $infile $outfile
python ocean_forcing.py --bmelt_0 $bmelt0 --bmelt_1 $bmelt1 --lat_1 ${lat} $outfile
ncatted -a grid_mapping,mask,o,c,"polar_stereographic" -a grid_mapping,shelfbmassflux,o,c,"polar_stereographic" -a grid_mapping,shelfbtemp,o,c,"polar_stereographic" $outfile

exit

for bmelt0 in 285 300 350 400 450 500; do
    for lat in 78 79 80; do
        for bmelt1 in 5 10 20; do
            outfile=ocean_forcing_latitudinal_${bmelt0}myr_lat_69_${bmelt1}myr_${lat}n.nc
            ncks -6 -C -O -v x,y,mask,polar_stereographic $infile $outfile
            python ocean_forcing.py --bmelt_0 $bmelt0 --bmelt_1 $bmelt1 --lat_1 ${lat} $outfile
            ncatted -a grid_mapping,mask,o,c,"polar_stereographic" -a grid_mapping,shelfbmassflux,o,c,"polar_stereographic" -a grid_mapping,shelfbtemp,o,c,"polar_stereographic" $outfile
        done
    done
done
