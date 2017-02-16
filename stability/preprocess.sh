#!/bin/bash

for tempmax in 1; do
    python ../data_sets/climate_forcing/create_warming_climate.py -T_max $tempmax pism_warming_climate_${tempmax}K.nc
done
