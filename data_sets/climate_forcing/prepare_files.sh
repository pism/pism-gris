#!/bin/bash

set -x

for VAR in "TAS"; do
    wget -nc ${SERVER}/${PREFIX}_${VAR}_DM.tar
    tar -k -xvf ${PREFIX}_${VAR}_DM.tar
    cdo -O -f nc4 -z zip_3 mergetime ${DMIPREFIX}_ERAI_${STARTY}_1990_${VAR}_DM.nc ${DMIPREFIX}_ERAI_1991_2000_${VAR}_DM.nc ${DMIPREFIX}_ERAI_2001_2010_${VAR}_DM.nc ${DMIPREFIX}_ERAI_2011_${ENDY}_${VAR}_DM.nc ${PREFIX}_${VAR}_DM.nc
    cdo -O -f nc4 -z zip_3 monmean ${PREFIX}_${VAR}_DM.nc ${PREFIX}_${VAR}_MM.nc
done
wget -nc ${SERVER}/${HIRHAMMASK}
wget -nc ${SERVER}/${HIRHAMUSURF}
