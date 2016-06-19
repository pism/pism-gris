#!/bin/bash

# Copyright (C) 2014-16 Andy Aschwanden

# generates config file
# downloads "SeaRISE" master dataset
# downloads various MCB master datasets

set -e -x  # exit on error

# username to download MCBs from beauregard
user=aaschwanden  # default number of processors
if [ $# -gt 0 ] ; then
  user="$1"
fi


# get file; see page http://websrv.cs.umt.edu/isis/index.php/Present_Day_Greenland
DATAVERSION=1.1
DATAURL=http://websrv.cs.umt.edu/isis/images/a/a5/
DATANAME=Greenland_5km_v$DATAVERSION.nc

echo "fetching master file ... "
wget -nc ${DATAURL}${DATANAME}   # -nc is "no clobber"
echo "  ... done."
echo


PISMVERSION=pism_$DATANAME
echo -n "creating bootstrapable $PISMVERSION from $DATANAME ... "
# copy the vars we want, and preserve history and global attrs
ncks -O -v mapping,lat,lon,bheatflx,topg,thk,presprcp,smb,airtemp2m $DATANAME $PISMVERSION
# convert from water equiv to ice thickness change rate; assumes ice density 910.0 kg m-3
ncap2 -O -s "precipitation=presprcp*(1000.0/910.0)" $PISMVERSION $PISMVERSION
ncatted -O -a units,precipitation,c,c,"m/year" $PISMVERSION
ncatted -O -a long_name,precipitation,c,c,"ice-equivalent mean annual precipitation rate" $PISMVERSION
# delete incorrect standard_name attribute from bheatflx; there is no known standard_name
ncatted -a standard_name,bheatflx,d,, $PISMVERSION
# use pism-recognized name for 2m air temp
ncrename -O -v airtemp2m,ice_surface_temp  $PISMVERSION
ncatted -O -a units,ice_surface_temp,c,c,"Celsius" $PISMVERSION
# use pism-recognized name and standard_name for surface mass balance, after
# converting from liquid water equivalent thickness per year to [kg m-2 year-1]
ncap2 -O -s "climatic_mass_balance=1000.0*smb" $PISMVERSION $PISMVERSION
# Note: The RACMO field smb has value 0 as a missing value, unfortunately,
# everywhere the ice thickness is zero.  Here we replace with 1 m a-1 ablation.
# This is a *choice* of the model of surface mass balance in thk==0 areas.
ncap2 -O -s "where(thk <= 0.0){climatic_mass_balance=-2000.0;}" $PISMVERSION $PISMVERSION
ncatted -O -a standard_name,climatic_mass_balance,m,c,"land_ice_surface_specific_mass_balance" $PISMVERSION
ncatted -O -a units,climatic_mass_balance,m,c,"kg m-2 year-1" $PISMVERSION
# de-clutter by only keeping vars we want
ncks -O -v mapping,lat,lon,bheatflx,topg,thk,precipitation,ice_surface_temp,climatic_mass_balance \
  $PISMVERSION $PISMVERSION
# straighten dimension names
ncrename -O -d x1,x -d y1,y -v x1,x -v y1,y $PISMVERSION $PISMVERSION
nc2cdo.py $PISMVERSION
echo "done."
echo

# extract paleo-climate time series into files suitable for option
# -atmosphere ...,delta_T
TEMPSERIES=pism_dT.nc
echo -n "creating paleo-temperature file $TEMPSERIES from $DATANAME ... "
ncks -O -v oisotopestimes,temp_time_series $DATANAME $TEMPSERIES
ncrename -O -d oisotopestimes,time \
            -v oisotopestimes,time \
            -v temp_time_series,delta_T $TEMPSERIES
# reverse time dimension
ncpdq -O --rdr=-time $TEMPSERIES $TEMPSERIES
# make times follow same convention as PISM
ncap2 -O -s "time=-time" $TEMPSERIES $TEMPSERIES
ncatted -O -a units,time,m,c,"years since 1-1-1" $TEMPSERIES
ncatted -O -a calendar,time,c,c,"365_day" $TEMPSERIES
ncatted -O -a units,delta_T,m,c,"Kelvin" $TEMPSERIES
echo "done."
echo

# extract paleo-climate time series into files suitable for option
# -ocean ...,frac_SMB
OSMBSERIES=pism_fSMB.nc
echo -n "creating paleo-temperature file $OSMBSERIES from $DATANAME ... "
ncks -O $TEMPSERIES $OSMBSERIES
# ncrename -v delta_T,frac_mass_flux $OSMBSERIES
python create_paleo_ocean_melt.py $OSMBSERIES
# ncatted -O -a units,frac_mass_flux,d,, -a long_name,frac_mass_flux,o,c,"sub-shelf melt scalar fraction offset" $OSMBSERIES
# ncap2 -O -s "frac_mass_flux=(frac_mass_flux)/(max(abs(frac_mass_flux))*1.1)+1;" $OSMBSERIES $OSMBSERIES

exit

# extract paleo-climate time series into files suitable for option
# -ocean ...,delta_SL
SLSERIES=pism_dSL.nc
echo -n "creating paleo-sea-level file $SLSERIES from $DATANAME ... "
ncks -O -v sealeveltimes,sealevel_time_series $DATANAME $SLSERIES
ncrename -O -d sealeveltimes,time \
            -v sealeveltimes,time \
            -v sealevel_time_series,delta_SL $SLSERIES
# reverse time dimension
ncpdq -O --rdr=-time $SLSERIES $SLSERIES
# make times follow same convention as PISM
ncap2 -O -s "time=-time" $SLSERIES $SLSERIES
ncatted -O -a units,time,m,c,"years since 1-1-1" $SLSERIES
ncatted -O -a calendar,time,c,c,"365_day" $SLSERIES
echo "done."
echo

# get old Bamber topograpy
DATAVERSION=0.93
DATAURL=http://websrv.cs.umt.edu/isis/images/8/86/
DATANAME=Greenland_5km_v$DATAVERSION.nc

echo "fetching master file ... "
wget -nc ${DATAURL}${DATANAME}   # -nc is "no clobber"
echo "  ... done."
echo

PISMVERSIONOLD=pism_$DATANAME
echo -n "creating bootstrapable $PISMVERSIONOLD from $DATANAME ... "
# copy the vars we want, and preserve history and global attrs
ncks -O -v mapping,lat,lon,topg,thk $DATANAME $PISMVERSIONOLD
# straighten dimension names
ncrename -O -d x1,x -d y1,y -v x1,x -v y1,y $PISMVERSIONOLD $PISMVERSIONOLD
nc2cdo.py $PISMVERSIONOLD
echo "done."
echo
