#!/bin/bash

# Scalar fields

odir=2018_08_ctrl
vars="velsurf_mag usurf_hs topg topg_hs"
postfix=".nc"
for basin in NW; do
    for rcp in 45; do
        for year in 2008 2100 2200 2300; do
                ifile=${odir}/basins/b_${basin}_ex_gris_g900m_v3a_rcp_${rcp}_id_CTRL_0_1000/b_${basin}_ex_gris_g900m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc
            for var in $vars; do
                ofile=${odir}/basins/b_${basin}_ex_gris_g900m_v3a_rcp_${rcp}_id_CTRL_0_1000/${var}_b_${basin}_ex_gris_g900m_v3a_rcp_${rcp}_id_CTRL_${year}.nc
                ofile_tiff=${ofile%"$postfix"}.tiff
                echo "Extracting $year and $var, saving it to $ofile"
                cdo -L selvar,$var -selyear,$year $ifile $ofile
                echo "Converting to $ofile_tiff"
                gdal_translate $ofile $ofile_tiff                
            done
            var=velsurf_mag
            ofile=${odir}/basins/b_${basin}_ex_gris_g900m_v3a_rcp_${rcp}_id_CTRL_0_1000/${var}_b_${basin}_ex_gris_g900m_v3a_rcp_${rcp}_id_CTRL_${year}-2008.nc
            ofile_tiff=${ofile%"$postfix"}.tiff
            echo "Extracting $year and $var, saving it to $ofile"
            cdo -L div -sub  -selvar,$var -selyear,$year $ifile  -selvar,$var -selyear,2008 $ifile -selvar,$var -selyear,2008 $ifile $ofile
            echo "Converting to $ofile_tiff"
            gdal_translate $ofile $ofile_tiff

        done
    done
done

odir=2018_08_ctrl
var=velsurf_mag
postfix=".nc"
for rcp in 45; do
    for year in 2008 2020 2040 2100 2200 2300; do
        ifile=${odir}/spatial/ex_gris_g900m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc
        ofile=${odir}/spatial/${var}_ex_gris_g900m_v3a_rcp_${rcp}_id_CTRL_${year}.nc
        ofile_tiff=${ofile%"$postfix"}.tiff
        echo "Extracting $year and $var, saving it to $ofile"
        cdo -L selvar,$var -selyear,$year $ifile $ofile
        echo "Converting to $ofile_tiff"
        gdal_translate $ofile $ofile_tiff                
        ofile_shp=${ofile%"$postfix"}.shp
        gdal_contour -a speed -fl 100 200 1000 ${ofile_tiff} ${ofile_shp}
        ofile=${odir}/spatial/abs_${var}_ex_gris_g900m_v3a_rcp_${rcp}_id_CTRL_${year}-2008.nc
        ofile_tiff=${ofile%"$postfix"}.tiff
        echo "Extracting $year and $var, saving it to $ofile"
        cdo -L sub  -selvar,$var -selyear,$year $ifile  -selvar,$var -selyear,2008 $ifile $ofile
        echo "Converting to $ofile_tiff"
        gdal_translate $ofile $ofile_tiff
        ofile=${odir}/spatial/rel_${var}_ex_gris_g900m_v3a_rcp_${rcp}_id_CTRL_${year}-2008.nc
        ofile_tiff=${ofile%"$postfix"}.tiff
        echo "Extracting $year and $var, saving it to $ofile"
        cdo -L div -sub  -selvar,$var -selyear,$year $ifile  -selvar,$var -selyear,2008 $ifile -selvar,$var -selyear,2008 $ifile
        $ofile
        echo "Converting to $ofile_tiff"
        gdal_translate $ofile $ofile_tiff
    done
done


odir=2018_08_ctrl
cd $odir/scalar
mkdir $odir/scalar_clean
for rcp in 26 45 85; do
    for run in CTRL; do
        for grid in 18000 9000 4500 3600 1800; do
            ncks -O ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc ../scalar_clean/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc
            adjust_timeline.py -i start -p yearly -a 2008-1-1 -u seconds -d 2008-1-1 ../scalar_clean/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc
        done
    done
done
cd ../../


odir=2018_08_ctrl
grid=900
mkdir $odir/scalar_clean
cd $odir/scalar
for rcp in 26 45 85; do
    for run in CTRL NTRL NISO; do
        ncks -O ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc ../scalar_clean/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc
        adjust_timeline.py -i start -p yearly -a 2008-1-1 -u seconds -d 2008-1-1 ../scalar_clean/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc
    done
done
cd ../../

odir=2018_08_ctrl
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

odir=2018_08_ctrl
grid=900
mkdir -p $odir/fldsum
for rcp in 26 45 85; do
    for run in CTRL NTRL; do
        # so PISM reports fluxes even in ice free cells, we need to correct for this
        cdo -L -O -f nc4 -z zip_3 fldsum -aexpr,"surface_runoff_rate=surface_runoff_rate*sftgif,surface_accumulation_rate=surface_accumulation_rate*sftgif,dMdt=dMdt*sftgif;tendency_of_ice_mass_due_to_conservation_error=tendency_of_ice_mass_due_to_conservation_error*sftgif;tendency_of_ice_mass_due_to_basal_mass_flux=tendency_of_ice_mass_due_to_basal_mass_flux*sftgif;tendency_of_ice_mass_due_to_surface_mass_flux=tendency_of_ice_mass_due_to_surface_mass_flux*sftgif;tendency_of_ice_mass_due_to_discharge=tendency_of_ice_mass_due_to_discharge*sftgif;" -setattribute,dMdt@units="Gt year-1" -aexpr,"dMdt=tendency_of_ice_mass-tendency_of_ice_mass_due_to_flow" -selvar,ice_mass,tendency_of_ice_mass,tendency_of_ice_mass_due_to_flow,tendency_of_ice_mass_due_to_conservation_error,tendency_of_ice_mass_due_to_basal_mass_flux,tendency_of_ice_mass_due_to_surface_mass_flux,tendency_of_ice_mass_due_to_discharge,surface_runoff_rate,surface_accumulation_rate,sftgif $odir/spatial/ex_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc
        ncks -A -v limnsw,ice_area_glacierized $odir/scalar_clean/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc
        cdo timmean -selyear,2095/2105 $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_2100.nc
        cdo timmean -selyear,2195/2205 $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_2200.nc
        cdo timmean -selyear,2295/2305 $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_2300.nc
        cdo timmean -selyear,2995/3005 $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_3000.nc
    done
done


# Extract DGMSL
odir=2018_08_ctrl
grid=900
mkdir -p $odir/dgmsl
for rcp in 26 45 85; do
    for year in 2100 2200 2300 3000; do
        for run in CTRL NISO NTRL; do
            cdo -L setattribute,limnsw@units="cm" -setattribute,limnsw@long_mame="contribution to global mean sea level" -divc,365 -divc,-1e13 -selvar,limnsw -sub -selyear,$year $odir/scalar_clean/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc -selyear,2008 $odir/scalar_clean/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/dgmsl/dgmsl_g${grid}m_rcp_${rcp}_${run}_${year}.nc
        done
    done
done

# Extract DGMSL
odir=2018_08_ctrl
grid=900
mkdir -p $odir/contrib_absolute
mkdir -p $odir/contrib_percent
mkdir -p $odir/contrib_flux_absolute
mkdir -p $odir/contrib_flux_percent
for rcp in 26 45 85; do
    for run in CTRL NISO NTRL; do
        # cdo -L  setattribute,discharge_contrib@units="cm" -setattribute,discharge_contrib@long_mame="ice discharge contribution to global mean sea level" -expr,"discharge_contrib=tendency_of_ice_mass_due_to_discharge/(tendency_of_ice_mass_due_to_discharge-surface_accumulation_rate)*tendency_of_ice_mass" -divc,365 -divc,-1e13 -timcumsum  $odir/scalar_clean/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/contrib_absolute/dgmsl_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
        # cdo -L  setattribute,discharge_contrib@units="" -setattribute,discharge_contrib@long_mame="ice discharge contribution to global mean sea level" -expr,"discharge_contrib=tendency_of_ice_mass_due_to_discharge/(tendency_of_ice_mass_due_to_discharge-surface_accumulation_rate)*100" -divc,365 -divc,-1e13 -timcumsum  $odir/scalar_clean/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/contrib_percent/dgmsl_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc

        cdo -L  setattribute,discharge_contrib@units="kg year-1" -setattribute,discharge_contrib@long_mame="ice discharge contribution to global mean sea level" -expr,"discharge_contrib=tendency_of_ice_mass_due_to_discharge/(tendency_of_ice_mass_due_to_discharge-surface_accumulation_rate)*tendency_of_ice_mass"  $odir/scalar_clean/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/contrib_flux_absolute/dgmsl_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
        # cdo -L  setattribute,discharge_contrib@units="" -setattribute,discharge_contrib@long_mame="ice discharge contribution to global mean sea level" -expr,"discharge_contrib=tendency_of_ice_mass_due_to_discharge/(tendency_of_ice_mass_due_to_discharge-surface_accumulation_rate)*100" -divc,365 -divc,-1e13  $odir/scalar_clean/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/contrib_flux_percent/dgmsl_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc

        # for year in 2100 2200 2300 3000; do
        #     cdo -L  setattribute,discharge_contrib@units="cm" -setattribute,discharge_contrib@long_mame="ice discharge contribution to global mean sea level" -expr,"discharge_contrib=tendency_of_ice_mass_due_to_discharge/(tendency_of_ice_mass_due_to_discharge-surface_accumulation_rate)*tendency_of_ice_mass" -divc,365 -divc,-1e13 -selyear,${year} -timcumsum $odir/scalar_clean/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/contrib/dgmsl_g${grid}m_rcp_${rcp}_${run}_${year}.nc
        #     cdo -L  setattribute,discharge_contrib@units="" -setattribute,discharge_contrib@long_mame="ice discharge contribution to global mean sea level" -expr,"discharge_contrib=tendency_of_ice_mass_due_to_discharge/(tendency_of_ice_mass_due_to_discharge-surface_accumulation_rate)*100" -divc,365 -divc,-1e13 -selyear,${year} -timcumsum $odir/scalar_clean/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/contrib_percent/dgmsl_g${grid}m_rcp_${rcp}_${run}_${year}.nc
        # done
    done
done

odir=2018_08_ctrl
mkdir -p $odir/percent_loss
for rcp in 26 45 85; do
    cdo -L mulc,-100 -div -sub $odir/scalar_clean/ts_gris_g900m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc -seltimestep,1  $odir/scalar_clean/ts_gris_g900m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc -seltimestep,1  $odir/scalar_clean/ts_gris_g900m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc $odir/percent_loss/ts_gris_g900m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc
    cdo selyear,2300 $odir/percent_loss/ts_gris_g900m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc $odir/percent_loss/ts_gris_g900m_v3a_rcp_${rcp}_id_CTRL_2300.nc
    cdo -L mulc,-100 -div -sub  $odir/scalar_clean/ts_gris_g18000m_v3a_rcp_${rcp}_id_SIA_0_1000.nc -seltimestep,1 $odir/scalar_clean/ts_gris_g18000m_v3a_rcp_${rcp}_id_SIA_0_1000.nc -seltimestep,1 $odir/scalar_clean/ts_gris_g18000m_v3a_rcp_${rcp}_id_SIA_0_1000.nc $odir/percent_loss/ts_gris_g18000m_v3a_rcp_${rcp}_id_SIA_0_1000.nc
    cdo selyear,2300 $odir/percent_loss/ts_gris_g18000m_v3a_rcp_${rcp}_id_SIA_0_1000.nc $odir/percent_loss/ts_gris_g18000m_v3a_rcp_${rcp}_id_SIA_2300.nc
done

# Extract DGMSL
odir=2018_08_ctrl
grid=900
mkdir -p $odir/dgmsl_ex
for rcp in 26 45 85; do
    for year in 2100 2200 2300 3000; do
        for run in CTRL ; do
            cdo -L setattribute,limnsw@units="cm" -setattribute,long_mame="contribution to global mean sea level" -divc,365 -divc,-1e13 -selvar,limnsw -sub -selyear,$year $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc -selyear,2008 $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/dgmsl_ex/dgmsl_g${grid}m_rcp_${rcp}_${run}_${year}.nc
        done
    done
done

odir=2018_08_ctrl
grid=900
mkdir -p $odir/dgmsl_mass
for rcp in 26 45 85; do
    for year in 2100 2200 2300 3000; do
        for run in CTRL ; do
            cdo -L setattribute,ice_mass@units="cm" -setattribute,long_mame="contribution to global mean sea level" -divc,365 -divc,-1e13 -selvar,ice_mass -sub -selyear,$year $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc -selyear,2008 $odir/fldsum/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/dgmsl_mass/dgmsl_g${grid}m_rcp_${rcp}_${run}_${year}.nc
        done
    done
done

# Extract DGMSL from basins
odir=2018_08_ctrl
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


odir=2018_08_ctrl
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


odir=2018_08_ctrl
grid=900
mkdir -p ${odir}/profiles
for rcp in 45; do
    extract_profiles.py -v velsurf_mag,velbase_mag,thk,usurf,topg ../../gris-outlet-glacier-profiles/gris-outlet-glacier-profiles-100m.shp $odir/spatial/ex_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc $odir/profiles/profiles_100m_ex_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc
done

odir=2018_08_ctrl
grid=600
mkdir -p ${odir}/profiles
for rcp in 85 45; do
    extract_profiles.py -v velsurf_mag,velbase_mag,thk,usurf,topg ../../gris-outlet-glacier-profiles/gris-outlet-glacier-profiles-epsg3413-filtered-100m.shp $odir/spatial/ex_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc $odir/profiles/profiles_100m_ex_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc
done

odir=2018_08_ctrl
grid=450
mkdir -p ${odir}/profiles
for rcp in 45; do
    extract_profiles.py -v velsurf_mag,velbase_mag,thk,usurf,topg ../../gris-outlet-glacier-profiles/gris-outlet-glacier-profiles-100m.shp $odir/spatial/ex_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_400.nc $odir/profiles/profiles_100m_ex_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_400.nc
done
