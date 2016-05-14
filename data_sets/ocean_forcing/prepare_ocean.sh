#!/bin/bash

GRID=300
if [ -n "$1" ]; then
    GRID=$1
fi

infile=../bed_dem/pism_Greenland_ext_${GRID}m_mcb_jpl_v2.nc
if [ -n "$2" ]; then
    infile=$2
fi
#wget -nc ftp://sidads.colorado.edu/DATASETS/IDBMG4_BedMachineGr/$infile

set -x -e

#gridfile=gris_ext_g${GRID}m.nc
#create_greenland_ext_epsg3413_grid.py -g $GRID $gridfile

start="2008-01-01"
end="2108-01-01"

outfile=ocean_forcing_${GRID}m_latitudinal_285_$start_$end.nc
ncks -4 -L 3 -C -O -v x,y,mask,polar_stereographic $infile $outfile
python create_prognostic_ocean.py -a $start -e $end --bmelt_0 285 $outfile

exit

outfile=ocean_forcing_latitudinal_masked_ctrl.nc
ncks -4 -L 3 -C -O -v x,y,mask,polar_stereographic $infile $outfile
python ocean_forcing.py  -m --bmelt_0 228 $outfile

outfile=ocean_forcing_latitudinal_masked_285.nc
ncks -4 -L 3 -C -O -v x,y,mask,polar_stereographic $infile $outfile
python ocean_forcing.py -m --bmelt_0 285 $outfile


outfile=ocean_forcing_latitudinal_ctrl.nc
ncks -4 -L 3 -C -O -v x,y,mask,polar_stereographic $infile $outfile
python ocean_forcing.py  --bmelt_0 228 $outfile

outfile=ocean_forcing_latitudinal_285.nc
ncks -4 -L 3 -C -O -v x,y,mask,polar_stereographic $infile $outfile
python ocean_forcing.py --bmelt_0 285 $outfile
