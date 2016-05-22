#!/bin/bash


set -x -e

start="2000-01-01"
end="2108-01-01"

for GRID in 18000 9000 6000 4500 3600 3000 2400 1800 1500 1200 900 600 450 300; do
    infile=../bed_dem/pism_Greenland_ext_${GRID}m_mcb_jpl_v2.nc
    outfile=ocean_forcing_${GRID}m_latitudinal_285_$start_$end.nc
    ncks -4 -L 3 -C -O -v x,y,mask,polar_stereographic $infile $outfile
    python create_prognostic_ocean.py -a $start -e $end --bmelt_0 285 $outfile
    
    outfile=ocean_forcing_${GRID}m_latitudinal_masked_285_$start_$end.nc
    ncks -4 -L 3 -C -O -v x,y,mask,polar_stereographic $infile $outfile
    python create_prognostic_ocean.py -m -a $start -e $end --bmelt_0 285 $outfile
done

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
