#!/bin/bash

set -e -x

NN=4  # default number of processors
if [ $# -gt 0 ] ; then
  NN="$1"
fi

# default interpolation method is conservative
IMETHOD=bil
if [ $# -gt 1 ] ; then  # if user says "./hirham2epsg3413.sh N con" then first order conservative remapping is used 
  IMETHOD=$2
fi
METHOD=`echo $IMETHOD | tr [a-z] [A-Z]`

HIRHAMMASK=glmask_geog.nc
HIRHAMUSURF=topo_geog.nc
SERVER=aaschwanden@chinook.alaska.edu:/center/d/ICESHEET/HIRHAM5
STARTY=1980
ENDY=2014
DMIPREFIX=DMI-HIRHAM5_GL2
PREFIX=${DMIPREFIX}_ERAI_${STARTY}_${ENDY}
TARFILE=HIRHAM5_ERAI_${STARTY}_${ENDY}_DM.tar


#source ./prepare_files.sh


for INPUT in $HIRHAMMASK $HIRHAMUSURF; do
  if [ -e "$INPUT" ] ; then  # check if file exist
    echo "$SCRIPTNAME           input   $INPUT (found)"
  else
    echo "$SCRIPTNAME           input   $INPUT (MISSING!!)"
    echo
  fi
done


for GRID in 9000; do

    PISMGRID=epsg3413_${GRID}m_grid.nc
    create_greenland_ext_epsg3413_grid.py -g $GRID $PISMGRID

    for INPUT in $PISMGRID; do
        if [ -e "$INPUT" ] ; then  # check if file exist
          echo "$SCRIPTNAME           input   $INPUT (found)"
        else
          echo "$SCRIPTNAME           input   $INPUT (MISSING!!)"
          echo
        fi
    done

    for VAR in "TAS"; do
        INFILEMM=${PREFIX}_${VAR}_MM.nc
        for INPUT in $INFILEMM; do
            if [ -e "$INPUT" ] ; then  # check if file exist
              echo "$SCRIPTNAME           input   $INPUT (found)"
            else
              echo "$SCRIPTNAME           input   $INPUT (MISSING!!)"
              echo
            fi
        done
        OUTFILEMM=pism_${PREFIX}_${VAR}_${GRID}M_${METHOD}_MM.nc
        TMPFILE=tmp_$INFILEMM

        # just copy over to a tmp file, preserve original
        ncks -O $INFILEMM $TMPFILE
        ncrename -d x,rlon -d y,rlat -O  $TMPFILE  $TMPFILE
        # ncatted -a units,time,o,c,"days since 1989-01-01" $TMPFILE

        if [ "$VAR" == "SMB" ]; then
            MASK=icemask.nc
            ncks -O $HIRHAMMASK $MASK
            ncwa -O -a height $MASK $MASK
            ncks -O -v height -x $MASK $MASK
            ncwa -O -a time $MASK $MASK
            ncks -O -v time -x $MASK $MASK
            python make_greenland_mask.py -v var232 $MASK $TMPFILE
            ncap2 -O -s "where(mask==0) smb=-9999;" $TMPFILE $TMPFILE
            ncatted -a _FillValue,smb,o,f,-9999 $TMPFILE
        fi

        if [[ $NN == 1 ]] ; then
            cdo remap${IMETHOD},$PISMGRID -setgrid,rotated_grid.txt $TMPFILE  $OUTFILEMM
        else
            cdo -P $NN remap${IMETHOD},$PISMGRID -setgrid,rotated_grid.txt $TMPFILE  $OUTFILEMM
        fi
        # Remap mask using nearest neighbor
        TMPMASK=tmp_smb_mask.nc
        if [ "$VAR" == "SMB" ]; then
            if [[ $NN == 1 ]] ; then
                cdo remapnn,$PISMGRID -setgrid,rotated_grid.txt -selvar,mask $TMPFILE $TMPMASK
            else
                cdo -P $NN remapnn,$PISMGRID -setgrid,rotated_grid.txt -selvar,mask $TMPFILE  $TMPMASK
            fi
            ncks -A -v x,y $PISMGRID $TMPMASK
            ncks -A -v mask $TMPMASK $OUTFILEMM
        fi        
        # let's get rid of the 'height' variable
        ncwa -O -a height $OUTFILEMM $OUTFILEMM
        ncks -O -v height -x $OUTFILEMM $OUTFILEMM
    done

    # deal with the ice upper surface elevation
    TMPFILE=tmp_topo.nc
    USURFFILE=hirham_usurf.nc
    ncks -O $HIRHAMUSURF $TMPFILE
    cdo -v remap${IMETHOD},$PISMGRID $TMPFILE $USURFFILE
    ncpdq -O -a y,x $USURFFILE $USURFFILE
    ncwa -O -a height $USURFFILE $USURFFILE
    ncks -O -v height -x $USURFFILE $USURFFILE
    ncwa -O -a time $USURFFILE $USURFFILE
    ncks -O -v time -x $USURFFILE $USURFFILE
    ncrename -O -v var6,usurf $USURFFILE $USURFFILE
    ncatted -O -a table,,d,, -a units,usurf,o,c,"m" -a long_name,usurf,o,c,"ice upper surface elevation" -a standard_name,usurf,o,c,"surface_altitude" $USURFFILE
    rm $TMPFILE
    
    # now create the forcing files for use with PISM's direct forcing classes.
    PPREFIX=pism_${PREFIX}
    
done


