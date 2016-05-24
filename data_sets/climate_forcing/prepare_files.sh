#!/bin/bash

set -x

SERVER=http://prudence.dmi.dk/data/temp/RUM/ANDY
PREFIX=DMI-HIRHAM5_GL2_ERAI_1980_2014
for VAR in "TAS"; do
    wget -nc ${SERVER}/${PREFIX}_${VAR}_DM.tar
    tar -k -xvf ${PREFIX}_${VAR}_DM.tar
    cdo mergetime *_${VAR}_DM.nc ${PREFIX}_${VAR}_DM.nc
done
HIRHAMMASK=glmask_geog.nc
wget -nc ${SERVER}/${HIRHAMMASK}
HIRHAMUSURF=topo_geog.nc
wget -nc ${SERVER}/${HIRHAMUSURF}
