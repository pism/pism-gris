#!/bin/bash

GRID=3600
if [ $# -gt 0 ] ; then
  GRID="$1"
fi

outfile=ocean_forcing_latitudinal_ctrl.nc
create_greenland_ext_epsg3413_grid.py -g $GRID $outfile
python ocean_forcing.py  --bmelt_0 228 $outfile

outfile=ocean_forcing_latitudinal_285.nc
create_greenland_ext_epsg3413_grid.py -g $GRID $outfile
python ocean_forcing.py --bmelt_0 285 $outfile
