#!/bin/bash

set -x -e

orig_file="$1"
adjusted_file="$2"
delta_file="$3"

ncks -O -v bed $orig_file $delta_file
ncks -A -v topg $adjusted_file $delta_file
ncap2 -O -s "topg_delta=topg-float(bed);" $delta_file $delta_file
ncks -O -x -v topg,bed $delta_file $delta_file
ncatted -a units,topg_delta,o,c,"m" -a standard_name,topg_delta,d,, -a long_name,topg_delta,o,c,"topg_adjusted-topg_original" -a pism_intent,topg_delta,d,, $delta_file
