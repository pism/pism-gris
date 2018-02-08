#!/bin/bash
#SBATCH --partition=analysis
#SBATCH --ntasks=7
#SBATCH --tasks-per-node=7
#SBATCH --time=48:00:00
#SBATCH --output=pism.%j
#SBATCH --mem=214G

cd $SLURM_SUBMIT_DIR

odir=2017_12_ctrl
grid=900
mkdir -p ${odir}/contrib
for rcp in 26 45 85; do
    cdo  divc,365 '-aexpr,d_contrib=-tendency_of_ice_mass*(-tendency_of_ice_mass_due_to_discharge/(-tendency_of_ice_mass_due_to_discharge+surface_runoff_rate/1e12));ru_contrib=-tendency_of_ice_mass*(surface_runoff_rate/1e12/(-tendency_of_ice_mass_due_to_discharge+surface_runoff_rate/1e12))' -timcumsum ${odir}/scalar/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc ${odir}/contrib/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc
done

odir=2017_12_ctrl
grid=900
mkdir -p ${odir}/station_ts
for rcp in 26 45 85; do
extract_profiles.py -v thk,usrf,tempsurf ../../data_sets/GreenlandIceCoreSites/ice-core-sites.shp ${odir}/spatial/ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc ${odir}/station_ts/profile_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc
done


odir=2017_12_les
grid=3600
mkdir -p $odir/sftgif
mkdir -p $odir/sftgif_pctl
cd $odir/state
for file in gris_g${grid}m*id_*0_1000.nc; do
    if [ ! -f "../sftgif/$file" ]; then
    cdo selvar,sftgif $file ../sftgif/$file
    fi
done
cd ../../
for rcp in 26 45 85; do
    cdo -O -P 7 enssum $odir/sftgif/gris_g${grid}m_v3a_rcp_${rcp}_id_*_0_1000.nc $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
    cdo divc,9.89 $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc 
    gdal_translate $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif
    gdal_contour -a pctl -fl 16 50 84  $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.shp
done 

odir=2017_12_ctrl
run=CTRL
mkdir -p $odir/scalar_percent
for grid in 18000 9000 4500 3600 1800 900; do
    for rcp in 26 45 85; do
        cdo mulc,100 -div -sub -seltimestep,1 -selvar,limnsw $odir/scalar/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc -selvar,limnsw $odir/scalar/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc -seltimestep,1 -selvar,limnsw $odir/scalar/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/scalar_percent/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc
    done
done
for grid in 900; do
    for rcp in 26 45; do
        cdo mulc,100 -div -sub -seltimestep,1 -selvar,limnsw $odir/scalar/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_3000.nc -selvar,limnsw $odir/scalar/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_3000.nc -seltimestep,1 -selvar,limnsw $odir/scalar/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_3000.nc $odir/scalar_percent/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_3000.nc
    done
done

odir=2017_12_ctrl
run=CTRL
mkdir -p $odir/dgmsl
for grid in 18000 9000 4500 3600 1800 900; do
    for rcp in 26 45 85; do
        for year in 2100 2200 2500 3000; do
            for run in CTRL; do
                cdo mulc,-1 -divc,365 -divc,1e15 -selvar,limnsw -sub -selyear,$year $odir/scalar/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc -selyear,2008 $odir/scalar/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/dgmsl/dgms_g${grid}m_rcp_${rcp}_${run}_${year}.nc
            done
        done
    done
done

odir=2017_12_ctrl
run=CTRL
grid=900
mkdir -p $odir/uplift
for rcp in 26 45 85; do
    gdal_translate NETCDF:${odir}/state/gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc:dbdt ${odir}/uplift/dbdt_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.tif
done

odir=2017_12_les
grid=3600
mkdir -p $odir/scalar_pruned
mkdir -p $odir/scalar_clean
mkdir -p $odir/scalar_ensstat
rsync -rvu --progress --min-size=470KB $odir/scalar/* $odir/scalar_pruned/
cd $odir/scalar_pruned/
for file in ts_*.nc; do
    cdo selvar,tendency*,surface*,li*,ice_*,dt,basal* $file ../scalar_clean/$file
done
cd ..
for rcp in 26 45 85; do
    for pctl in 16 50 84; do
        cdo -O -P 7 enspctl,$pctl $odir/scalar_clean/ts_gris_g${grid}m_v3a_rcp_${rcp}*0_1000.nc  $odir/scalar_ensstat/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
    done
done

odir=2017_12_ctrl
grid=900
mkdir -p $odir/spatial_processed
mkdir -p $odir/ice_extend
for rcp in 26 45 85; do
    cdo -L selvar,mask -selyear,2008,2100,2200,2300,2400,2500 $odir/spatial/ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_2000.nc $odir/spatial_processed/ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_2000.nc
    extract_interface.py -t grounding_line -o $odir/ice_extend/gl_ex_g900m_v3a_rcp_${rcp}_id_CTRL_0_2000.shp $odir/spatial_processed/ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_2000.nc
done
