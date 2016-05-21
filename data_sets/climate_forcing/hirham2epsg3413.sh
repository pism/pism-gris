#!/bin/bash

# Copyright (C) 2011-2016 Andy Aschwanden, University of Alaska Fairbanks
#
# Script remaps ERA-Interim fields (climatic mass balance, 2-m air temperature
# and precipication) from HIRHAM5 onto the grid used by PISM
#
# By default (./remap2pism.sh) input file prefix is ERAI_1989_2009_DMI
# but the prefix can be set by the environment variable INPREFIX
# In bash, e.g., do
# $ INPREFIX=ERAI_1989_2009_DMI_run2 ./remap2pism.sh
# to process the updated forcing files.

set -e -x

NN=4  # default number of processors
if [ $# -gt 0 ] ; then
  NN="$1"
fi

# default interpolation method is conservative
IMETHOD=bil
if [ $# -gt 1 ] ; then  # if user says "./hirham2epsg3413.sh N con2" then second order conservative remapping is used 
  IMETHOD=$2
fi
METHOD=`echo $IMETHOD | tr [a-z] [A-Z]`
# FIXME: check that $METHOD if either "bil", "con", or "con2". How's that done in bash?

HIRHAMMASK=glmask5km.nc
HIRHAMUSURF=topo5km.nc
PREFIX=GR6b_ERAI_1989_2011

if [ -n "${INPREFIX:+1}" ] ; then
    INPREFIX=$INPREFIX
else
    INPREFIX=$PREFIX
fi
echo "PREFIX=$INPREFIX"


for INPUT in $HIRHAMGRID $HIRHAMUSURF; do
  if [ -e "$INPUT" ] ; then  # check if file exist
    echo "$SCRIPTNAME           input   $INPUT (found)"
  else
    echo "$SCRIPTNAME           input   $INPUT (MISSING!!)"
    echo
  fi
done


for GRID in 18000 9000 6000 4500 3600 3000 2400 1800 1500 1200 900 600 450 300; do
#for GRID in 18000; do

    PISMGRID=epsg3413_${GRID}m_grid.nc
    create_greenland_ext_epsg3413_grid.py -g $GRID $PISMGRID
    nc2cdo.py $PISMGRID

    for INPUT in $PISMGRID; do
        if [ -e "$INPUT" ] ; then  # check if file exist
          echo "$SCRIPTNAME           input   $INPUT (found)"
        else
          echo "$SCRIPTNAME           input   $INPUT (MISSING!!)"
          echo
        fi
    done

    for VAR in "SMB" "TAS" "PR"; do

        INFILEMM=${INPREFIX}_${VAR}_MM.nc

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
        ncatted -a units,time,o,c,"days since 1989-01-01" $TMPFILE

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
        
        #rm $TMPFILE $TMPMASK

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

    ACABFILE=${PPREFIX}_SMB_${GRID}M_${METHOD}_MM.nc
    ARTMFILE=${PPREFIX}_TAS_${GRID}M_${METHOD}_MM.nc
    PRECIPFILE=${PPREFIX}_PR_${GRID}M_${METHOD}_MM.nc
    OUTFILE=${PREFIX}_${GRID}M_${METHOD}_MM.nc
    ncks -O -v smb $ACABFILE $OUTFILE
    ncks -A -v tas $ARTMFILE $OUTFILE
    ncks -A -v pr $PRECIPFILE $OUTFILE
    ncks -A -v x,y $PISMGRID $OUTFILE
    ncks -A -v usurf $USURFFILE $OUTFILE
    ncrename -O -v tas,ice_surface_temp -v pr,precipitation -v smb,climatic_mass_balance $OUTFILE $OUTFILE
    ncatted -a table,,d,, -a code,,d,,  -a table,,d,,  $OUTFILE
    
    ncatted -a proj4,global,o,c,"+init=epsg:3413" $OUTFILE
    ncap2 -O -s "where(climatic_mass_balance==-9999) climatic_mass_balance=-200000; air_temp=ice_surface_temp;" $OUTFILE $OUTFILE
    ncatted -a long_name,air_temp,o,c,"near-surface air temperature" $OUTFILE
    python add_timebounds.py $OUTFILE

    mpirun -np $NN $SLURM_PRE fill_missing_petsc.py -v air_temp,climatic_mass_balance,precipitation,ice_surface_temp,usurf $OUTFILE tmp_$OUTFILE
    mv tmp_$OUTFILE $OUTFILE

    cdo ymonmean ${PREFIX}_${GRID}M_${METHOD}_MM.nc ${PREFIX}_${GRID}M_${METHOD}_MMEAN.nc
    ncks -A -v x,y $PISMGRID ${PREFIX}_${GRID}M_${METHOD}_MMEAN.nc
    
    start="2008-01-01"
    end="2108-01-01"
    ncks -4 -L 3 -O ${PREFIX}_${GRID}M_${METHOD}_MMEAN.nc ${PREFIX}_${GRID}M_${METHOD}_MMEAN_${start}_${end}.nc 
    python create_prognostic_climate.py -a $start -e $end ${PREFIX}_${GRID}M_${METHOD}_MMEAN_${start}_${end}.nc 
    
    cdo timmean -seldate,1989-1-1,1990-1-1 $OUTFILE ${PREFIX}_${GRID}M_${METHOD}_1989_baseline.nc
    ncks -A -v x,y $PISMGRID ${PREFIX}_${GRID}M_${METHOD}_1989_baseline.nc  

 
done
