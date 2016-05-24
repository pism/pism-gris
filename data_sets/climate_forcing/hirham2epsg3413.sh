#!/bin/bash

set -x

HIRHAMMASK=glmask_geog.nc
HIRHAMUSURF=topo_geog.nc
SERVER=http://prudence.dmi.dk/data/temp/RUM/ANDY
STARTY=1980
ENDY=2014
DMIPREFIX=DMI-HIRHAM5_GL2
PREFIX=${DMIPREFIX}_ERAI_${STARTY}_${ENDY}

source ./prepare_files.sh
