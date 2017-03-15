#!/bin/bash

for grid in 2000; do
    python create_geometry.py -g $grid pism_outletglacier_g${grid}m.nc
done
