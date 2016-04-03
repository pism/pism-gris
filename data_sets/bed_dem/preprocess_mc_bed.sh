#!/bin/bash

set -x -e

# run ./preprocess.sh 1 if you havent CDO compiled with OpenMP
NN=4  # default number of processors
if [ $# -gt 0 ] ; then
  NN="$1"
fi

infile=MCdataset-2015-04-27.nc
if [ -n "$2" ]; then
    infile=$2
fi
wget -nc ftp://sidads.colorado.edu/DATASETS/IDBMG4_BedMachineGr/$infile

ver=2
if [ -n "$3" ]; then
    ver=$3
fi

# username to download MCBs from beauregard
user=aaschwanden  # default number of processors
if [ $# -gt 4 ] ; then
  user="$4"
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
ncap2 -t $NN -O -s "climatic_mass_balance=1000.0*smb" $PISMVERSION $PISMVERSION
ncatted -O -a standard_name,climatic_mass_balance,m,c,"land_ice_surface_specific_mass_balance" $PISMVERSION
ncatted -O -a units,climatic_mass_balance,m,c,"kg m-2 year-1" $PISMVERSION
# This is a *choice* of the model of surface mass balance in thk==0 areas.
ncap2 -O -s "where(thk <= 0.0){climatic_mass_balance=-10000.0;}" $PISMVERSION $PISMVERSION
# de-clutter by only keeping vars we want
ncks -O -v mapping,lat,lon,bheatflx,topg,thk,precipitation,ice_surface_temp,climatic_mass_balance \
  $PISMVERSION $PISMVERSION
# straighten dimension names
ncrename -O -d x1,x -d y1,y -v x1,x -v y1,y $PISMVERSION $PISMVERSION
nc2cdo.py $PISMVERSION
echo "done."
echo

ibcaofile=IBCAO_V3_500m_RR
wget -nc http://www.ngdc.noaa.gov/mgg/bathymetry/arctic/grids/version3_0/${ibcaofile}_tif.zip
unzip -o ${ibcaofile}_tif.zip

# Create a buffer that is a multiple of the grid resolution
# and works for grid resolutions up to 36km.
buffer_x=148650
buffer_y=130000
xmin=$((-638000 - $buffer_x))
ymin=$((-3349600 - $buffer_y))
xmax=$((864700 + $buffer_x))
ymax=$((-657600 + $buffer_y))

CUT="-cutline ../shape-files/gris-domain.shp"

for GRID in 18000 9000 6000 4500 3600 3000 2400 1800 1500 1200 900 600 450 300; do
    outfile=pism_Greenland_ext_${GRID}m_mcb_jpl_v${ver}.nc
    for var in "bed" "errbed"; do
        rm -f g${GRID}m_${var}_v${ver}.tif g${GRID}m_${var}_v${ver}.nc
        gdalwarp $CUT -overwrite  -r average -s_srs EPSG:3413 -t_srs EPSG:3413 -te $xmin $ymin $xmax $ymax -tr $GRID $GRID -of GTiff NETCDF:$infile:$var g${GRID}m_${var}_v${ver}.tif
        gdal_translate -co "FORMAT=NC2" -of netCDF g${GRID}m_${var}_v${ver}.tif g${GRID}m_${var}_v${ver}.nc 
        ncatted -a nx,global,d,, -a ny,global,d,, -a xmin,global,d,, -a ymax,global,d,, -a spacing,global,d,, g${GRID}m_${var}_v${ver}.nc
        
    done
    for var in "surface" "thickness"; do
        rm -f g${GRID}m_${var}_v${ver}.tif g${GRID}m_${var}_v${ver}.nc
        gdalwarp -overwrite -r average -te $xmin $ymin $xmax $ymax -tr $GRID $GRID -of GTiff NETCDF:$infile:$var g${GRID}m_${var}_v${ver}.tif
        gdal_translate -co "FORMAT=NC2" -of netCDF g${GRID}m_${var}_v${ver}.tif g${GRID}m_${var}_v${ver}.nc
        ncatted -a _FillValue,$var,d,, g${GRID}m_${var}_v${ver}.nc
        ncap2 -O -s "where(${var}<=0) ${var}=0.;" g${GRID}m_${var}_v${ver}.nc g${GRID}m_${var}_v${ver}.nc
    done
    for var in "mask" "source"; do
        rm -f g${GRID}m_${var}_v${ver}.tif g${GRID}m_${var}_v${ver}.nc
        gdalwarp -overwrite -r near -te $xmin $ymin $xmax $ymax -tr $GRID $GRID -of GTiff NETCDF:$infile:$var g${GRID}m_${var}_v${ver}.tif
        gdal_translate -co "FORMAT=NC2" -of netCDF g${GRID}m_${var}_v${ver}.tif g${GRID}m_${var}_v${ver}.nc 
    done
    
    ncks -O g${GRID}m_bed_v${ver}.nc $outfile
    ncatted -a _FillValue,bed,d,, $outfile
    for var in "errbed" "surface" "thickness" "mask" "source"; do
        ncks -A g${GRID}m_${var}_v${ver}.nc $outfile
    done
    
    ncap2 -O -s "where(mask==3) bed=-9999" $outfile $outfile
    
    # This is not needed, but it can be used by PISM to calculate correct cell volumes, and for remapping scripts"
    ncatted -a proj4,global,o,c,"+init=epsg:3413" $outfile
    
    ba13file=Greenland_bedrock_topography_V3_clean
    rsync -rvu --progress $user@beauregard.gi.alaska.edu:/data/tmp/data_sets/greenland_beds_v3/${ba13file}.nc
    
    gdalwarp $CUT -overwrite -r average -s_srs "+proj=stere +ellps=WGS84 +datum=WGS84 +lon_0=-39 +lat_0=90 +lat_ts=71 +units=m" -t_srs EPSG:3413 -te $xmin $ymin $xmax $ymax -tr $GRID $GRID -dstnodata -9999 -of GTiff NETCDF:${ba13file}.nc:topg ${ba13file}_epsg3413_g${GRID}m.tif
    gdal_translate -co "FORMAT=NC2" -of netCDF ${ba13file}_epsg3413_g${GRID}m.tif ${ba13file}_epsg3413_g${GRID}m.nc
    
    ncks -A -v topg ${ba13file}_epsg3413_g${GRID}m.nc $outfile
    ncap2 -O -s "where(thickness==0) {bed=topg;}; where(bed==-9999) {bed=topg;};" $outfile $outfile

    gdalwarp $CUT -overwrite -r average -t_srs EPSG:3413 -te $xmin $ymin $xmax $ymax -tr $GRID $GRID -of GTiff ${ibcaofile}.tif ${ibcaofile}_epsg3413_g${GRID}m.tif
    gdal_translate -co "FORMAT=NC2" -of netCDF  ${ibcaofile}_epsg3413_g${GRID}m.tif  ${ibcaofile}_epsg3413_g${GRID}m.nc
    ncks -A -v Band1 ${ibcaofile}_epsg3413_g${GRID}m.nc $outfile
    ncap2 -O -s "where(bed==-9999) {bed=Band1;}; where(Band1<=-9990) {bed=-9999;};" $outfile $outfile

#    ncks -O -v Band1,topg -x $outfile $outfile

    ncks -O g${GRID}m_${var}_v${ver}.nc griddes_${GRID}m.nc
    nc2cdo.py --srs "+init=epsg:3413" griddes_${GRID}m.nc
    if [[ $NN == 1 ]] ; then
	REMAP_EXTRAPOLATE=on cdo -f nc2 remapbil,griddes_${GRID}m.nc ${PISMVERSION} v${ver}_tmp_${GRID}m_searise.nc
    else
	REMAP_EXTRAPOLATE=on cdo -P $NN -f nc2 remapbil,griddes_${GRID}m.nc ${PISMVERSION} v${ver}_tmp_${GRID}m_searise.nc
    fi
    mpiexec -np $NN fill_missing_petsc.py -v precipitation,ice_surface_temp,bheatflx,climatic_mass_balance v${ver}_tmp_${GRID}m_searise.nc v${ver}_tmp2_${GRID}m.nc
    ncks -A -v precipitation,ice_surface_temp,bheatflx,climatic_mass_balance v${ver}_tmp2_${GRID}m.nc $outfile
    ncatted -a long_name,bed,o,c,"bed topography" -a standard_name,bed,o,c,"bedrock_altitude" -a units,bed,o,c,"meters" -a _FillValue,bed,o,f,-9999. $outfile
    ncatted -a long_name,surface,o,c,"ice surface elevation" -a standard_name,surface,o,c,"surface_altitude" -a units,surface,o,c,"meters" $outfile
    ncatted -a long_name,errbed,o,c,"bed topography/ice thickness error" -a units,errbed,o,c,"meters" $outfile
    ncatted -a long_name,thickness,o,c,"ice thickness" -a standard_name,thickness,o,c,"land_ice_thickness" -a units,thickness,o,c,"meters" $outfile
    ncatted -a units,mask,d,, -a flag_values,mask,o,b,0,1,2,3 -a flag_meanings,mask,o,c,"ocean ice_free_land grounded_ice floating_ice" $outfile
    ncatted -a units,source,d,, -a flag_values,source,o,b,0,1,2,3,4,6 -a flag_meanings,source,o,c,"ocean gimpdem mass_conservation interpolation hydrodstatic_equilibrium kriging" $outfile
    ncatted -a Title,global,o,c,"BedMachine: Greenland dataset based on mass conservation" -a Author,global,o,c,"Mathieu Morlighem" -a version,global,o,c,"$ver" -a proj4,global,o,c,"+init=epsg:3413" $outfile
    ncatted -a _FillValue,,d,, -a missing_value,,d,, $outfile
    ncatted -a _FillValue,errbed,o,f,-9999. $outfile
    # remove regridding artifacts, give precedence to mask: we set thickness and
    # surface to 0 where mask has ocean
    ncap2 -O -s "where(thickness<0) thickness=0; ftt_mask[\$y,\$x]=1b; where(mask==0) {thickness=0.; surface=0.;};" $outfile $outfile

    
done
