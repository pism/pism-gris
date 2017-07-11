#!/bin/bash


set -x -e

GRID=3000
infile=../bed_dem/pism_Greenland_ext_${GRID}m_mcb_jpl_v3a.nc


# #####################################
# Initial firn thickness
# #####################################


outfile=firn_forcing_ctrl.nc
ncks -6 -C -O -v x,y,mask,polar_stereographic,surface $infile $outfile
python firn_forcing.py $outfile
ncatted -a grid_mapping,firn_depth,o,c,"polar_stereographic" $outfile


outfile=firn_forcing_off.nc
ncks -6 -C -O -v x,y,mask,polar_stereographic,surface $infile $outfile
python firn_forcing.py --firn_1 0 --firn_0 0 $outfile
ncatted -a grid_mapping,firn_depth,o,c,"polar_stereographic" $outfile

