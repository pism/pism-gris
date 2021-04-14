#!/bin/bash

# (c) 2021 Andy Aschwanden

set -x -e


# First we download the Bamber 2001 SeaRISE data set

bfile=Geothermal_Heat_Flux_Greenland
cfile=TopoHeat_Greenland_20210224
wget -nc https://store.pangaea.de/Publications/Martos-etal_2018/${bfile}.xyz

# Create a buffer that is a multiple of the grid resolution
# and works for grid resolutions up to 36km.
buffer_x=148650
buffer_y=130000
xmin=$((-638000 - $buffer_x - 468000))
ymin=$((-3349600 - $buffer_y))
xmax=$((864700 + $buffer_x))
ymax=$((-657600 + $buffer_y))


for GRID in 18000 9000 6000 4500 3600 3000 2400 1800 1500 1200 900 600 450; do
    gdalwarp  -overwrite  -r average -s_srs EPSG:32623 -t_srs EPSG:3413 -te $xmin $ymin $xmax $ymax -tr $GRID $GRID ${bfile}.xyz ${bfile}_g${GRID}m.nc
    gdalwarp  -overwrite  -r average -s_srs EPSG:3413 -t_srs EPSG:3413 -te $xmin $ymin $xmax $ymax -tr $GRID $GRID NETCDF:${cfile}.nc:correction ${cfile}_g${GRID}m.nc
    cdo -O -f nc4 -z zip_2 setmisstoc,42.0 -setattribute,bheatflx@units="mW m-2" -chname,Band1,bheatflx -mul ${bfile}_g${GRID}m.nc -addc,1 ${cfile}_g${GRID}m.nc Geothermal_Heat_Flux_Greenland_corrected_g${GRID}m.nc
    ncatted -a _FillValue,bheatflx,d,, -a missing_value,bheatflx,d,, Geothermal_Heat_Flux_Greenland_corrected_g${GRID}m.nc
done
