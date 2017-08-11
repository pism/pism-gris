#!/bin/bash


set -x -e

GRID=3000
infile=../bed_dem/pism_Greenland_ext_${GRID}m_mcb_jpl_v3a_ctrl.nc

# #####################################
# Ocean forcing
# #####################################

lat_0=70
lat_1=80

bmelt_0=300
bmelt_1=10
outfile=ocean_forcing_${bmelt_0}myr_${lat_0}n_${bmelt_1}myr_${lat_1}n.nc
ncks -6 -C -O -v x,y,mask,polar_stereographic $infile $outfile
python ocean_forcing.py --bmelt_0 ${bmelt_0} --bmelt_1 ${bmelt_1} --lat_0 ${lat_0} --lat_1 ${lat_1} $outfile
ncatted -a grid_mapping,mask,o,c,"polar_stereographic" -a grid_mapping,shelfbmassflux,o,c,"polar_stereographic" -a grid_mapping,shelfbtemp,o,c,"polar_stereographic" $outfile

bmelt_0=400
bmelt_1=20
outfile=ocean_forcing_${bmelt_0}myr_${lat_0}n_${bmelt_1}myr_${lat_1}n.nc
ncks -6 -C -O -v x,y,mask,polar_stereographic $infile $outfile
python ocean_forcing.py --bmelt_0 ${bmelt_0} --bmelt_1 ${bmelt_1} --lat_0 ${lat_0} --lat_1 ${lat_1} $outfile
ncatted -a grid_mapping,mask,o,c,"polar_stereographic" -a grid_mapping,shelfbmassflux,o,c,"polar_stereographic" -a grid_mapping,shelfbtemp,o,c,"polar_stereographic" $outfile

bmelt_0=500
bmelt_1=30
outfile=ocean_forcing_${bmelt_0}myr_${lat_0}n_${bmelt_1}myr_${lat_1}n.nc
ncks -6 -C -O -v x,y,mask,polar_stereographic $infile $outfile
python ocean_forcing.py --bmelt_0 ${bmelt_0} --bmelt_1 ${bmelt_1} --lat_0 ${lat_0} --lat_1 ${lat_1} $outfile
ncatted -a grid_mapping,mask,o,c,"polar_stereographic" -a grid_mapping,shelfbmassflux,o,c,"polar_stereographic" -a grid_mapping,shelfbtemp,o,c,"polar_stereographic" $outfile


# #####################################
# Thickness calving threshold forcing
# #####################################


lat_0=74
lat_1=76

tct_0=400
tct_1=50
outfile=tct_forcing_${tct_0}myr_${lat_0}n_${tct_1}myr_${lat_1}n.nc
ncks -6 -C -O -v x,y,mask,polar_stereographic $infile $outfile
python tct_forcing.py --tct_0 ${tct_0} --tct_1 ${tct_1} --lat_0 ${lat_0} --lat_1 ${lat_1} $outfile
ncatted -a grid_mapping,calving_threshold,o,c,"polar_stereographic" $outfile

tct_0=500
tct_1=100
outfile=tct_forcing_${tct_0}myr_${lat_0}n_${tct_1}myr_${lat_1}n.nc
ncks -6 -C -O -v x,y,mask,polar_stereographic $infile $outfile
python tct_forcing.py --tct_0 ${tct_0} --tct_1 ${tct_1} --lat_0 ${lat_0} --lat_1 ${lat_1} $outfile
ncatted -a grid_mapping,calving_threshold,o,c,"polar_stereographic" $outfile

tct_0=600
tct_1=100
outfile=tct_forcing_${tct_0}myr_${lat_0}n_${tct_1}myr_${lat_1}n.nc
ncks -6 -C -O -v x,y,mask,polar_stereographic $infile $outfile
python tct_forcing.py --tct_0 ${tct_0} --tct_1 ${tct_1} --lat_0 ${lat_0} --lat_1 ${lat_1} $outfile
ncatted -a grid_mapping,calving_threshold,o,c,"polar_stereographic" $outfile

