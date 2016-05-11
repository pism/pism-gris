#!/bin/bash

GRID=150

infile=MCdataset-2015-04-27.nc
if [ -n "$1" ]; then
    infile=$1
fi
wget -nc ftp://sidads.colorado.edu/DATASETS/IDBMG4_BedMachineGr/$infile


outfile=ocean_forcing_latitudinal_ctrl.nc
create_greenland_ext_epsg3413_grid.py -g $GRID $outfile
python ocean_forcing.py  --bmelt_0 228 $outfile

outfile=ocean_forcing_latitudinal_285.nc
create_greenland_ext_epsg3413_grid.py -g $GRID $outfile
python ocean_forcing.py --bmelt_0 285 $outfile
