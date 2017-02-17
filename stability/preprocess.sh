#!/bin/bash

for tempmax in 1 2 3 4 5 6 7 8 9 10; do
    python ../data_sets/climate_forcing/create_warming_climate.py -T_max $tempmax pism_warming_climate_${tempmax}K.nc
done
