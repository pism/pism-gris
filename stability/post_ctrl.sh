#!/bin/bash

# Scalar fields

odir=2018_05_ctrl
cd $odir/scalar
for rcp in 26 45 85; do
    for run in CTRL; do
        for grid in 18000 9000 4500 3600 1800; do
            adjust_timeline.py -i start -p yearly -a 2008-1-1 -u seconds -d 2008-1-1 ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc
        done
    done
done
cd ../../

odir=2018_05_ctrl
grid=600
cd $odir/scalar
for rcp in 26 45 85; do
    for run in CTRL; do
        cdo -O mergetime ts_gris_g600m_v3a_rcp_${rcp}_id_CTRL_0_100.nc ts_gris_g600m_v3a_rcp_${rcp}_id_${run}_100_200.nc  ts_gris_g600m_v3a_rcp_${rcp}_id_${run}_200_300.nc  ts_gris_g600m_v3a_rcp_${rcp}_id_${run}_300_400.nc  ts_gris_g600m_v3a_rcp_${rcp}_id_${run}_400_500.nc ts_gris_g600m_v3a_rcp_${rcp}_id_${run}_0_1000.nc
        adjust_timeline.py -i start -p yearly -a 2008-1-1 -u seconds -d 2008-1-1 ts_gris_g600m_v3a_rcp_${rcp}_id_${run}_0_1000.nc
    done
done
cd ../../

odir=2018_05_ctrl
grid=900
cd $odir/scalar
for rcp in 26 45 85; do
    for run in NISO CTRL NTRL; do
        cdo -f nc4 -O --sortname mergetime ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_500.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_500_1000.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc
        adjust_timeline.py -i start -p yearly -a 2008-1-1 -u seconds -d 2008-1-1 ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc
    done
done
cd ../../

odir=2018_05_ctrl
grid=900
cd $odir/scalar
run=CTRL
rcp=26
cdo -O --sortname mergetime ts_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_500.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_500_1000.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_1000_1500.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_1500_2000.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_2000_2500.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_2500_3000.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_3000_3500.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_3500_4000.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_4000_4500.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_4500_5000.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_5000.nc
adjust_timeline.py -i start -p yearly -a 2008-1-1 -u seconds -d 2008-1-1 ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_5000.nc
rcp=45
cdo -O --sortname mergetime ts_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_500.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_500_1000.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_1000_1500.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_1500_2000.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_2000_2500.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_2500_3000.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_3000_3500.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_3500_4000.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_4000_4500.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_4000_4500.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_5000.nc
adjust_timeline.py -i start -p yearly -a 2008-1-1 -u seconds -d 2008-1-1 ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_5000.nc
rcp=85
cdo -O --sortname  mergetime ts_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_500.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_500_1000.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_1000_1500.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_1500_2000.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_2000_2500.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_2500_3000.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_3000_3500.nc ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_5000.nc
adjust_timeline.py -i start -p yearly -a 2008-1-1 -u seconds -d 2008-1-1 ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_5000.nc
cd ../../

# Spatial fields

odir=2018_05_ctrl
grid=900
mkdir -p $odir/fldsum
for rcp in 26 45 85; do
    for run in CTRL NTRL; do
        # cdo -L -O fldsum -aexpr,"dMdt=tendency_of_ice_mass-tendency_of_ice_mass_due_to_flow" -selvar,ice_mass,tendency_of_ice_mass,tendency_of_ice_mass_due_to_flow,tendency_of_ice_mass_due_to_conservation_error,tendency_of_ice_mass_due_to_basal_mass_flux,tendency_of_ice_mass_due_to_surface_mass_flux,tendency_of_ice_mass_due_to_discharge,surface_runoff_rate,surface_accumulation_rate $odir/spatial/ex_gris_g900m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/fldsum/ts_gris_g900m_v3a_rcp_${rcp}_id_${run}_0_1000.nc
        ncks -4 -A -v limnsw,ice_area_glacierized $odir/scalar/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc
        cdo timmean -selyear,2095/2105 $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_2100.nc
        cdo timmean -selyear,2195/2205 $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_2200.nc
        cdo timmean -selyear,2495/2505 $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_2500.nc
        cdo timmean -selyear,2995/3005 $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_3000.nc
    done
done

# Extract DGMSL
odir=2018_05_ctrl
grid=900
mkdir -p $odir/dgmsl
for rcp in 26 45 85; do
    for year in 2100 2200 2500 3000; do
        for run in CTRL; do
            cdo -L setattribute,limnsw@units="cm" -setattribute,long_mame="contribution to global mean sea level" -divc,365 -divc,-1e13 -selvar,limnsw -sub -selyear,$year $odir/scalar/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc -selyear,2008 $odir/scalar/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/dgmsl/dgmsl_g${grid}m_rcp_${rcp}_${run}_${year}.nc
        done
    done
done

# Extract DGMSL from basins
odir=2018_05_ctrl
grid=900
mkdir -p $odir/basins/dgmsl
for rcp in 26 45 85; do
    for year in 3000; do
        for basin in CW NE NO NW SE SW; do
            for run in CTRL; do
                cdo -L  setattribute,limnsw@units="cm" -setattribute,long_mame="contribution to global mean sea level" -divc,365 -divc,-1e13 -selvar,ice_mass -sub -selyear,$year $odir/basins/scalar/ts_b_${basin}_ex_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc -selyear,2008 $odir/basins/scalar/ts_b_${basin}_ex_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/basins/dgmsl/dgmsl_b_${basin}_g${grid}m_rcp_${rcp}_${run}_${year}.nc
            done
        done
    done
done


odir=2018_05_ctrl
grid=900
mkdir -p $odir/final_states
cd $odir/state
for file in gris_g${grid}m*CTRL_500_1000.nc; do
    cdo aexpr,usurf=topg+thk -selvar,topg,thk,velsurf_mag $file ../final_states/$file
    ncap2 -4 -L 5 -O -s "where(topg<0) {topg=0.;}; where(thk<10) {velsurf_mag=-2e9; usurf=0.;};" ../final_states/$file ../final_states/$file
    gdal_translate NETCDF:../final_states/$file:velsurf_mag ../final_states/velsurf_mag_$file.tif
    gdal_translate -a_nodata 0 NETCDF:../final_states/$file:usurf ../final_states/usurf_$file.tif
    gdaldem hillshade ../final_states/usurf_$file.tif ../final_states/hs_usurf_$file.tif
    gdal_translate NETCDF:../final_states/$file:topg ../final_states/topg_$file.tif
    gdaldem hillshade ../final_states/topg_$file.tif ../final_states/hs_topg_$file.tif
done
cd ../../


odir=2018_05_ctrl
grid=900
mkdir -p ${odir}/profiles
for rcp in 45 85 26; do
    extract_profiles.py -v velsurf_mag,velbase_mag,thk,usurf,topg ../../gris-outlet-glacier-profiles/gris-outlet-glacier-profiles-100m.shp $odir/spatial/ex_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc $odir/profiles/profiles_100m_ex_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc
done

odir=2018_05_ctrl
grid=450
mkdir -p ${odir}/profiles
for rcp in 45; do
    extract_profiles.py -v velsurf_mag,velbase_mag,thk,usurf,topg ../../gris-outlet-glacier-profiles/gris-outlet-glacier-profiles-100m.shp $odir/spatial/ex_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_400.nc $odir/profiles/profiles_100m_ex_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_400.nc
done
