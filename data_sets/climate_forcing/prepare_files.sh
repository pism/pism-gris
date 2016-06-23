#!/bin/bash

set -x


# # Get the files from chinook
# rsync -rvu ${SERVER}/${HIRHAMMASK} .
# rsync -rvu ${SERVER}/${HIRHAMUSURF} .
# rsync -rvu ${SERVER}/${TARFILE} .

# tar -xvf ${TARFILE}
# for file in *.gz; do
#     gunzip -f $file
# done

# fix time axis in gld

# for VAR in "gld"; do
#     ncks -A -v time ${DMIPREFIX}_ERAI_${STARTY}_1990_TAS_DM.nc ${DMIPREFIX}_ERAI_${STARTY}_1990_${VAR}_DM.nc
#     ncks -A -v time ${DMIPREFIX}_ERAI_1991_2000_TAS_DM.nc ${DMIPREFIX}_ERAI_1991_2000_${VAR}_DM.nc
#     ncks -A -v time ${DMIPREFIX}_ERAI_2001_2010_TAS_DM.nc  ${DMIPREFIX}_ERAI_2001_2010_${VAR}_DM.nc
#     ncks -A -v time ${DMIPREFIX}_ERAI_2011_${ENDY}_TAS_DM.nc ${DMIPREFIX}_ERAI_2011_${ENDY}_${VAR}_DM.nc
# done

# for VAR in "gld" "PR" "RAIN" "SNFALL" "TAS"; do
for VAR in "TAS"; do
    cdo -O -f nc4 -z zip_3 mergetime ${DMIPREFIX}_ERAI_${STARTY}_1990_${VAR}_DM.nc ${DMIPREFIX}_ERAI_1991_2000_${VAR}_DM.nc ${DMIPREFIX}_ERAI_2001_2010_${VAR}_DM.nc ${DMIPREFIX}_ERAI_2011_${ENDY}_${VAR}_DM.nc ${PREFIX}_${VAR}_DM.nc
    cdo -O -f nc4 -z zip_3 monmean ${PREFIX}_${VAR}_DM.nc ${PREFIX}_${VAR}_MM.nc
done
