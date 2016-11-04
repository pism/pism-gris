#!/bin/bash
set -x -e

pism_grid=3000
if [ $# -gt 0 ] ; then
  pism_grid="$1"
fi
if [ $# -gt 1 ] ; then
  N="$2"
fi

cdo=/opt/local/bin/cdo
method='ycon'
pism_grid_file=g${pism_grid}m.nc
create_greenland_ext_epsg3413_grid.py -g ${pism_grid} $pism_grid_file
nc2cdo.py $pism_grid_file

pismsmbfile=smb_$pism_grid
inanomalyfile=dsmb_01B13_ISMIP6_v2.nc
anomalyfile=dsmb_01B13_ISMIP6_v3.nc
anomalyfile_epsg3431=dsmb_${pism_grid}m.nc

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
ncap2  -O -s "climatic_mass_balance=1000.0*smb" $PISMVERSION $PISMVERSION
# Note: The RACMO field smb has value 0 as a missing value, unfortunately,
# everywhere the ice thickness is zero. Here we replace with 100 m a-1 ablation.
# This is a *choice* of the model of surface mass balance in thk==0 areas.
ncap2 -O -s "where(thk <= 0.0){climatic_mass_balance=-10000.0;}" $PISMVERSION $PISMVERSION
ncatted -O -a standard_name,climatic_mass_balance,m,c,"land_ice_surface_specific_mass_balance" $PISMVERSION
ncatted -O -a units,climatic_mass_balance,m,c,"kg m-2 year-1" $PISMVERSION
# de-clutter by only keeping vars we want
ncks -O -v mapping,lat,lon,bheatflx,topg,thk,precipitation,ice_surface_temp,climatic_mass_balance \
  $PISMVERSION $PISMVERSION
# straighten dimension names
ncrename -O -d x1,x -d y1,y -v x1,x -v y1,y $PISMVERSION $PISMVERSION
nc2cdo.py $PISMVERSION
echo "done."
if [[ $N == 1 ]] ; then
    EXTRAPOLATE=on $cdo remap${method},$pism_grid_file $PISMVERSION smb_Greenland_${pism_grid}m.nc
else
    EXTRAPOLATE=on $cdo -P $N remap${method},$pism_grid_file $PISMVERSION smb_Greenland_${pism_grid}m.nc
fi    
mpiexec -n $N fill_missing_petsc.py -v climatic_mass_balance,ice_surface_temp smb_Greenland_${pism_grid}m.nc tmp_smb_Greenland_${pism_grid}m.nc
ncks -A -v climatic_mass_balance,ice_surface_temp tmp_smb_Greenland_${pism_grid}m.nc smb_Greenland_racmo_1960-1990_${pism_grid}m.nc
ncks -A -v x,y,mapping ${pism_grid_file} smb_Greenland_racmo_1960-1990_${pism_grid}m.nc

bagrid=ba1kmgrid.nc
create_greenland_bamber_grid.py -g 1000 $bagrid
ncks -O -v dummy -x $bagrid $anomalyfile
ncks -A -v DSMB $inanomalyfile $anomalyfile
if [[ $N == 1 ]] ; then
    EXTRAPOLATE=on $cdo remap${method},$pism_grid_file $anomalyfile $anomalyfile_epsg3431
else
    EXTRAPOLATE=on $cdo -P $N remap${method},$pism_grid_file $anomalyfile $anomalyfile_epsg3431
fi

ncks -A -v x,y,mapping $pism_grid_file $anomalyfile_epsg3431
ncatted -a grid_mapping,DSMB,o,c,"mapping" $anomalyfile_epsg3431

outfilepre=initMIP_climate_forcing_${pism_grid}m_100a
nc2cdo.py pism_Greenland_ext_${pism_grid}m_mcb_jpl_v2.nc
python create_anomalies_from_file.py --topo_file pism_Greenland_ext_${pism_grid}m_mcb_jpl_v2.nc --anomaly_file $anomalyfile_epsg3431 --background_file smb_Greenland_racmo_1960-1990_${pism_grid}m.nc ${outfilepre}_asmb.nc
ncks -A -v x,y,mapping ${pism_grid_file} ${outfilepre}_asmb.nc
ncatted  -a units,ice_surface_temp,o,c,"Celsius" -a standard_name,ice_surface_temp,o,c,"air_temperature"  -a units,climatic_mass_balance,o,c,"kg m-2 year-1" -a _FillValue,climatic_mass_balance,d,, -a _FillValue,ice_surface_temp,d,, -a standard_name,climatic_mass_balance,o,c,"land_ice_surface_specific_mass_balance" -a grid_mapping,climatic_mass_balance,o,c,"mapping" -a grid_mapping,ice_surface_temp,o,c,"mapping" ${outfilepre}_asmb.nc
ncap2 -O -s "where(climatic_mass_balance>1.e10) climatic_mass_balance=-10000.;" ${outfilepre}_asmb.nc ${outfilepre}_asmb.nc
ncks -O -d time,0 ${outfilepre}_asmb.nc ${outfilepre}_ctrl.nc







