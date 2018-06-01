#!/bin/bash


odir=2018_05_ctrl
grid=600
cd $odir/scalar
for rcp in 26 45 85; do
    for run in CTRL; do
        cdo -O mergetime ts_gris_g600m_v3a_rcp_${rcp}_id_CTRL_0_100.nc ts_gris_g600m_v3a_rcp_${rcp}_id_${run}_100_200.nc  ts_gris_g600m_v3a_rcp_${rcp}_id_${run}_200_300.nc  ts_gris_g600m_v3a_rcp_${rcp}_id_${run}_300_400.nc  ts_gris_g600m_v3a_rcp_${rcp}_id_${run}_400_500.nc ts_gris_g600m_v3a_rcp_${rcp}_id_${run}_0_500.nc
        adjust_timeline.py -i start -p yearly -a 2008-1-1 -u seconds -d 2008-1-1 ts_gris_g600m_v3a_rcp_${rcp}_id_${run}_0_500.nc
    done
done
cd ../../

odir=2018_05_ctrl
grid=900
cd $odir/scalar
for rcp in 26 45 85; do
    for run in CTRL NISO NTRL; do
        cdo -O mergetime ts_gris_g900m_v3a_rcp_${rcp}_id_CTRL_0_500.nc ts_gris_g900m_v3a_rcp_${rcp}_id_${run}_500_1000.nc ts_gris_g900m_v3a_rcp_${rcp}_id_${run}_0_1000.nc
        adjust_timeline.py -i start -p yearly -a 2008-1-1 -u seconds -d 2008-1-1 ts_gris_g900m_v3a_rcp_${rcp}_id_${run}_0_1000.nc
    done
done
cd ../../

odir=2018_05_ctrl
grid=900
mkdir -p $odir/fldsum
for rcp in 26 45 85; do
    for run in CTRL; do
        cdo -L -O fldsum -aexpr,dMdt=tendency_of_ice_mass-tendency_of_ice_mass_due_to_flow -selvar,tendency_of_ice_mass,tendency_of_ice_mass_due_to_flow,tendency_of_ice_mass_due_to_conservation_error,tendency_of_ice_mass_due_to_basal_mass_flux,tendency_of_ice_mass_due_to_surface_mass_flux,tendency_of_ice_mass_due_to_discharge,surface_runoff_rate,surface_accumulation_rate $odir/spatial/ex_gris_g900m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/fldsum/ts_gris_g900m_v3a_rcp_${rcp}_id_${run}_0_1000.nc
    done
done
cd ../../

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
    extract_profiles.py -v velsurf_mag,velbase_mag,thk,usurf,topg ../../gris-outlet-glacier-profiles/gris-outlet-glacier-profiles-100m.shp $odir/spatial/ex_gris_g900m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc $odir/profiles/profiles_100m_ex_gris_g900m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc
done


exit


odir=2017_12_ctrl
grid=900
mkdir -p $odir/spatial_processed
mkdir -p $odir/ice_extend
for rcp in 26 45 85; do
    cdo -L selvar,mask -selyear,2008,2100,2200,2300,2400,2500,2600,2700,2800,2900,3000 $odir/spatial/ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_3000.nc $odir/spatial_processed/ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_3000.nc
    extract_interface.py -t grounding_line -o $odir/ice_extend/gl_ex_g900m_v3a_rcp_${rcp}_id_CTRL.shp $odir/spatial_processed/ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_3000.nc
done




odir=2017_12_ctrl
grid=900
mkdir -p $odir/ice_extend
for rcp in 26 45 85; do
    extract_interface.py -t grounding_line -o $odir/ice_extend/gl_ex_g900m_v3a_rcp_${rcp}_id_CTRL.shp ${odir}/spatial/ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_3000.nc
done


odir=2017_11_ctrl
mkdir -p $odir/dgmsl
for rcp in 26 45 85; do
    for year in 2100 2200 2500 3000; do
        for run in CTRL; do
            cdo divc,365 -divc,1e15 -selvar,limnsw -sub -selyear,$year $odir/scalar/ts_gris_g1800m_v3a_rcp_${rcp}_id_${run}_0_1000.nc -selyear,2008 $odir/scalar/ts_gris_g1800m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/dgmsl/dgms_g1800m_rcp_${rcp}_${run}_${year}.nc
        done
    done
done

odir=2017_12_ctrl
mkdir -p $odir/dgmsl
for rcp in 26 45 85; do
    for year in 2100 2200 2500 3000; do
        for run in CTRL; do
            cdo divc,365 -divc,1e15 -selvar,limnsw -sub -selyear,$year $odir/scalar/ts_gris_g900m_v3a_rcp_${rcp}_id_${run}_0_1000.nc -selyear,2008 $odir/scalar/ts_gris_g900m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/dgmsl/dgms_g900m_rcp_${rcp}_${run}_${year}.nc
        done
    done
done

odir=2017_12_ctrl
grid=900
#mkdir -p ${odir}/station_ts
mkdir -p ${odir}/profiles
for rcp in 45 85 26; do
    # extract_profiles.py -v thk,usurf,tempsurf ../../data_sets/GreenlandIceCoreSites/ice-core-sites.shp ${odir}/spatial/ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_3000.nc ${odir}/station_ts/profile_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_3000.nc
    extract_profiles.py -v velsurf_mag,velbase_mag,thk,usurf,topg ../../gris-outlet-glacier-profiles/gris-outlet-glacier-profiles-100m.shp 2017_12_ctrl/spatial/ex_g900m_v3a_rcp_${rcp}_id_CTRL_0_3000.nc 2017_12_ctrl/profiles/profiles_100m_ex_g900m_v3a_rcp_${rcp}_id_CTRL_0_3000.nc
done


odir=2017_12_ctrl
grid=900
mkdir -p ${odir}/discharge_relative
for rcp in 45 85 26; do
    cdo runmean,11 -expr,d_rel="100*tendency_of_ice_mass_due_to_discharge/(tendency_of_ice_mass_due_to_discharge-surface_runoff_rate/1e12)" ${odir}/scalar/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc ${odir}/discharge_relative/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc
done

odir=2018_04_enth
grid=900
mkdir -p ${odir}/enth_base
for rcp in 85 45; do
    for year in 1 92 192 292; do
        for pc in 5 10; do
            #python ~/base/gris-analysis/enth_base/extract_basal_enthalpy.py -t $pc ${odir}/snap/save_gris_g900m_v3a_rcp_${rcp}_id_CTRL_0_500_${year}.000.nc ${odir}/enth_base/enth_base_${pc}_gris_g900m_v3a_rcp_${rcp}_id_CTRL_0_500_${year}.000.nc
            #gdal_translate -a_srs EPSG:3413 NETCDF:${odir}/enth_base/enth_base_${pc}_gris_g900m_v3a_rcp_${rcp}_id_CTRL_0_500_${year}.000.nc:basal_enthalpy ${odir}/enth_base/enth_base_${pc}_gris_g900m_v3a_rcp_${rcp}_id_CTRL_0_500_${year}.tif
            cd ${odir}/enth_base
            mkdir -p ../basins
            for basin in CW; do
                # ~/base/gris-analysis/basins/extract_basins.py --no_timeseries --basins  $basin --o_dir ../basins enth_base_${pc}_gris_g900m_v3a_rcp_${rcp}_id_CTRL_0_500_${year}.000.nc
                gdal_translate -a_srs EPSG:3413 NETCDF:../basins/b_${basin}_enth_base_${pc}_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_500_${year}.000/b_${basin}_enth_base_${pc}_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_500_${year}.000.nc:basal_enthalpy enth_base_${pc}_b_${basin}_gris_g900m_v3a_rcp_${rcp}_id_CTRL_0_500_${year}.tif
            done
        cd ../../
        done
    done
done
