#!/bin/bash

for tempmax in 0 1 2 3 4 5 6 7 8 9 10; do
    python ../data_sets/climate_forcing/create_warming_climate.py -T_max $tempmax pism_warming_climate_${tempmax}K.nc
done

for f in 1 1.1 1.25 1.5 2 4; do
    python ../data_sets/ocean_forcing/create_abrupt_ocean.py -f $f pism_abrupt_ocean_${f}.nc
done
