#!/bin/bash

for tempmax in 0 1 2 3 4 5 6 7 8 9 10; do
    python ../data_sets/climate_forcing/create_warming_climate.py -T_max $tempmax pism_warming_climate_${tempmax}K.nc
    ncap2 -O -s "delta_T=0.*delta_T; delta_T=delta_T+$tempmax;" pism_warming_climate_${tempmax}K.nc pism_step_climate_${tempmax}K.nc
done

for f in 1 1.1 1.25 1.5 2 4; do
    python ../data_sets/ocean_forcing/create_step_ocean.py -f $f pism_abrupt_ocean_${f}.nc
done
