#!/bin/bash

odir=2017_12_les
s=chinook
q=t2standard
n=72
grid=3600

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_20171104.csv --calibrate --o_dir ${odir} --exstep 1 -n ${n} -w 10:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


for id in `seq 0 9`;
do
for rcp in 26 45 85;
do
sbatch 2017_11_lhs/run_scripts/lhs_g3600m_v3a_rcp_${rcp}_id_00${id}_j.sh;
done
done

for id2 in `seq 0 4`;
do
for id1 in `seq 0 9`;
do
for id in `seq 0 9`;
do
for rcp in 26 45 85;
do
JOBID=$(sbatch 2017_12_les/run_scripts/lhs_g3600m_v3a_rcp_${rcp}_id_${id2}${id1}${id}_j.sh | sed 's/[^0-9]*//g')
sbatch --dependency=afterok:$JOBID 2017_12_les/run_scripts/post_lhs_g3600m_v3a_rcp_${rcp}_id_${id2}${id1}${id}.sh;
done
done
done
done

odir=2017_12_les
s=pleiades_ivy
q=long
n=80
grid=3600

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_20171104.csv --calibrate --o_dir ${odir} --exstep 1 -n ${n} -w 10:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


for id2 in `seq 5 10`;
do
for id1 in `seq 0 9`;
do
for id in `seq 0 9`;
do
for rcp in 26 45 85;
do
qsub 2017_12_les/run_scripts/post_g3600m_v3a_rcp_${rcp}_id_${id2}${id1}${id}.sh 
#qsub -W depend=afterok:$JOBID 2017_12_les/run_scripts/post_lhs_g3600m_v3a_rcp_${rcp}_id_${id2}${id1}${id}.sh;
done
done
done
done



odir=2017_12_ctrl
s=chinook
q=t2small
n=24
grid=9000

./lhs_ensemble.py -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 2:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

odir=2017_12_ctrl
s=chinook
q=t2small
n=48
grid=4500

./lhs_ensemble.py -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 6:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

odir=2017_12_ctrl
s=chinook
q=t2standard
n=72
grid=3600

./lhs_ensemble.py -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 10:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


odir=2017_12_ctrl
s=chinook
q=t2standard
n=144
grid=1800

./lhs_ensemble.py -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 36:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

odir=2017_12_ctrl
s=chinook
q=t2standard
n=360
grid=900

./lhs_ensemble.py -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 168:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 2000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


odir=2017_12_ocean
s=chinook
q=t2standard
n=360
grid=900

./lhs_ensemble.py -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 168:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

odir=2017_12_600m
s=chinook
q=t2standard
n=480
grid=600

./lhs_ensemble.py -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 168:00:00 -g ${grid} -s ${s} -q ${q} --step 200 --duration 200 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc




odir=2017_12_ctrl
grid=900
mkdir -p ${odir}/station_ts
for rcp in 26 45 85; do
extract_profiles.py -v thk,usurf,tempsurf ../../data_sets/GreenlandIceCoreSites/ice-core-sites.shp ${odir}/spatial/ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc ${odir}/station_ts/profile_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc
done


# Cumulative contribution LES and CTRL
~/base/gris-analysis/plotting/plotting.py  -n 8 -o les --time_bounds 2008 3000 --ctrl_file 2017_12_ctrl/scalar/ts_gris_g900m_v3a_rcp_*_id_CTRL_0_1000.nc --plot rcp_mass 2017_12_les/scalar_ensstat/ens*_gris_g3600m_v3a_rcp_*id_*.nc
# Rates of GMSL rise LES and CTRL
~/base/gris-analysis/plotting/plotting.py -n 8 -o les --time_bounds 2008 3000 --no_legend --ctrl_file 2017_12_ctrl/scalar/ts_gris_g900m_v3a_rcp_*_id_CTRL_0_1000.nc --plot rcp_flux 2017_12_les/scalar_ensstat/ens*_gris_g3600m_v3a_rcp_*id_*.nc

# Flux Partitioning
~/base/gris-analysis/plotting/plotting.py -n 4 -o ctrl --time_bounds 2008 3000 --no_legend --plot flux_partitioning 2017_12_ctrl/scalar/ts_gris_g900m_v3a_rcp_*id_CTRL_*.nc

# Trajectory plots
~/base/gris-analysis/plotting/plotting.py -o les --time_bounds 2008 3000 --plot rcp_traj 2017_11_lhs/scalar/ts_gris_g3600m_v3a_rcp_*id_*.nc
~/base/gris-analysis/plotting/plotting.py -o les_flux --time_bounds 2008 3000 --no_legend --plot rcp_fluxes 2017_11_lhs/scalar/ts_gris_g3600m_v3a_rcp_*id_*.nc
# Plot fluxes for each basin
for rcp in 26 45 85; do
    ~/base/gris-analysis/plotting/plotting.py -o basins_rcp_${rcp} --time_bounds 2008 3000 --no_legend --plot basin_mass 2017_12_ctrl/basins/scalar/ts_b_*_ex_g900m_v3a_rcp_${rcp}_id_CTRL_0_2000.nc
done

~/base/gris-analysis/plotting/plotting.py -o ctrl --time_bounds 2008 3000 --no_legend --plot station_usurf 2017_12_ctrl/station_ts/profile_g900m_v3a_rcp_*_id_CTRL_0_1000.nc

# grid resolution
~/base/gris-analysis/plotting/plotting.py  -n 8 -o ctrl --time_bounds 2020 2200 --plot grid_res 2017_12_ctrl/scalar/ts_gris_g900m_v3a_rcp_85_id_CTRL_0_1000.nc 2017_12_ctrl/scalar/ts_gris_g1800m_v3a_rcp_85_id_CTRL_0_1000.nc 2017_12_ctrl/scalar/ts_gris_g3600m_v3a_rcp_85_id_CTRL_0_1000.nc 2017_12_ctrl/scalar/ts_gris_g4500m_v3a_rcp_85_id_CTRL_0_1000.nc 2017_12_ctrl/scalar/ts_gris_g9000m_v3a_rcp_85_id_CTRL_0_1000.nc 




# NISO-CTRL
odir=2017_11_ctrl
grid=3600
mkdir -p $odir/niso
for rcp in 26 45 85; do
    cdo sub -selvar,topg $odir/state/gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc -selvar,topg $odir/state/gris_g${grid}m_v3a_rcp_${rcp}_id_NISO_0_1000.nc $odir/niso/topg_CTRL_NISO_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
    gdal_translate $odir/niso/topg_CTRL_NISO_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/niso/topg_CTRL_NISO_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif
done

for rcp in 26 45 85; do
    ~/base/gris-analysis/plotting/plotting.py -o basins_rcp_${rcp} --time_bounds 2008 3000 --no_legend --plot basin_d 2017_11_ctrl/basins/scalar/ts_b_*_ex_g1800m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc
done
~/base/gris-analysis/plotting/plotting.py -o ctrl --time_bounds 2008 3000 --no_legend --plot per_basin_flux 2017_11_ctrl/basins/scalar/ts_b_*_ex_g3600m_v3a_rcp_*_id_CTRL_0_1000.nc

odir=2017_12_ctrl
grid=900
mkdir -p $odir/final_states
cd $odir/state
for file in gris_g${grid}m*0_1000.nc; do
    cdo aexpr,usurf=topg+thk -selvar,topg,thk,velsurf_mag $file ../final_states/$file
    ncap2 -O -s "where(topg<0) {topg=0.;}; where(thk<10) {velsurf_mag=-2e9; usurf=0.;};" ../final_states/$file ../final_states/$file
    gdal_translate NETCDF:../final_states/$file:velsurf_mag ../final_states/velsurf_mag_$file.tif
    gdal_translate -a_nodata 0 NETCDF:../final_states/$file:usurf ../final_states/usurf_$file.tif
    gdaldem hillshade ../final_states/usurf_$file.tif ../final_states/hs_usurf_$file.tif
    gdal_translate NETCDF:../final_states/$file:topg ../final_states/topg_$file.tif
    gdaldem hillshade ../final_states/topg_$file.tif ../final_states/hs_topg_$file.tif
done
cd ../../


odir=2017_12_ctrl
grid=900
mkdir -p $odir/spatial_processed
mkdir -p $odir/ice_extend
for rcp in 26 45 85; do
    cdo -L selvar,mask -selyear,2008,2100,2200,2300,2400,2500 $odir/spatial/ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_2000.nc $odir/spatial_processed/ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_2000.nc
    extract_interface.py -t grounding_line -o $odir/ice_extend/gl_ex_g900m_v3a_rcp_${rcp}_id_CTRL_0_2000.shp $odir/spatial_processed/ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_2000.nc
done



odir=2017_11_ctrl
grid=900
basin=NW
mkdir -p $odir/basins_processed
for rcp in 26 45 85; do
    for year in 2008 2100 2200 2300 2400 2500; do    
        cdo -L selvar,thk,velsurf_mag,usurf -selyear,$year $odir/basins/b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000/b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc $odir/basins_processed/b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.nc
        ncap2 -O -s "where(thk<10) {velsurf_mag=-2e9; usurf=1.e20;};" $odir/basins_processed/b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.nc $odir/basins_processed/b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.nc
        gdal_translate NETCDF:$odir/basins_processed/b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.nc:velsurf_mag $odir/basins_processed/velsurf_mag_b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.tif
        gdal_translate -a_nodata 1e20 NETCDF:$odir/basins_processed/b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.nc:usurf $odir/basins_processed/usurf_b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.tif
        gdaldem hillshade $odir/basins_processed/usurf_b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.tif $odir/basins_processed/hs_usurf_b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.tif
    done
done

for rcp in 26 45 85; do
    extract_interface.py -t grounding_line -o 2017_11_ctrl/basins/ice_extend/gl_b_NW_ex_g900m_v3a_rcp_${rcp}_id_CTRL_0_1000.shp 2017_11_ctrl/basins/b_NW_ex_g900m_v3a_rcp_${rcp}_id_CTRL_0_1000/b_NW_ex_g900m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc
done


odir=2017_11_ctrl
basin=CW
grid=1800
for var in beta; do
    mkdir -p $odir/basins/${var}
    for rcp in 26 45 85; do
        for year in 2008 2100 2200 2500; do
            for run in CTRL; do
                cdo -f nc4 -z zip_3 -L selyear,$year -selvar,${var},thk $odir/basins/b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000/b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc  $odir/basins/${var}/${var}_b_${basin}_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.nc
                ncap2 -O -4 -L 3 -s "where(thk<10) beta=1e20;" $odir/basins/${var}/${var}_b_${basin}_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.nc $odir/basins/${var}/${var}_b_${basin}_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.nc
                gdal_translate NETCDF:$odir/basins/${var}/${var}_b_${basin}_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.nc:${var} $odir/basins/${var}/${var}_b_${basin}_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.tif
                cdo divc,1e12 -selvar,beta $odir/basins/${var}/${var}_b_${basin}_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.nc  $odir/basins/${var}/gpa_${var}_b_${basin}_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.nc
                ncatted -a units,beta,o,c,"GPa s m-1" $odir/basins/${var}/gpa_${var}_b_${basin}_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.nc
                gdal_contour -a beta -fl 0.01 0.1 1 10 100 250 NETCDF:$odir/basins/${var}/gpa_${var}_b_${basin}_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.nc:beta $odir/basins/${var}/gpa_${var}_b_${basin}_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.shp
            done
        done
    done
done


odir=2017_11_ctrl
mkdir -p $odir/dgmsl
for rcp in 26 45 85; do
    for year in 2100 2200 2500 3000; do
        for run in CTRL NISO NFRN HOTH8 ISO0; do
            cdo divc,365 -divc,1e15 -selvar,limnsw -sub -selyear,$year $odir/scalar/ts_gris_g3600m_v3a_rcp_${rcp}_id_${run}_0_1000.nc -selyear,2008 $odir/scalar/ts_gris_g3600m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/dgmsl/dgms_g3600m_rcp_${rcp}_${run}_${year}.nc
        done
    done
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
    cdo -O -P 12 enssum $odir/sftgif/gris_g${grid}m_v3a_rcp_${rcp}_id_*_0_1000.nc $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
    cdo divc,9.89 $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
done 

mkdir -p $odir/velsurf_mag
mkdir -p $odir/velsurf_mag_pctl
cd $odir/state
for file in gris_g${grid}m*id_1*0_1000.nc; do
    if [ ! -f "../velsurf_mag/$file" ]; then
    echo $file
    cdo selvar,velsurf_mag $file ../velsurf_mag/$file
    fi
done
cd ../../
for rcp in 26 45 85; do
    cdo -O enspctl,50 $odir/velsurf_mag/gris_g${grid}m_v3a_rcp_${rcp}_id_*0_0_1000.nc $odir/velsurf_mag_pctl/median_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
    cdo -O enspctl,84 $odir/velsurf_mag/gris_g${grid}m_v3a_rcp_${rcp}_id_*0_0_1000.nc $odir/velsurf_mag_pctl/pctl84_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
done 

mkdir -p $odir/thk
mkdir -p $odir/thk_pctl
cd $odir/state
for file in gris_g${grid}m*id_*0_1000.nc; do
    if [ ! -f "../thk/$file" ]; then
    echo $file
    cdo selvar,thk $file ../thk/$file
    fi
done
cd ../../
for rcp in 26 45 85; do
    cdo -O enspctl,16 $odir/thk/gris_g${grid}m_v3a_rcp_${rcp}_id_*_0_1000.nc $odir/thk_pctl/pctl16_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
    cdo -O enspctl,50 $odir/thk/gris_g${grid}m_v3a_rcp_${rcp}_id_*_0_1000.nc $odir/thk_pctl/median_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
    cdo -O enspctl,84 $odir/thk/gris_g${grid}m_v3a_rcp_${rcp}_id_*_0_1000.nc $odir/thk_pctl/pctl84_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
done 

mkdir -p $odir/topg
mkdir -p $odir/topg_pctl
cd $odir/state
for file in gris_g${grid}m*id_*0_1000.nc; do
    if [ ! -f "../topg/$file" ]; then
    echo $file
    cdo selvar,topg $file ../topg/$file
    fi
done
cd ../../
for rcp in 26 45 85; do
    cdo -O enspctl,16 $odir/topg/gris_g${grid}m_v3a_rcp_${rcp}_id_*_0_1000.nc $odir/topg_pctl/pctl16_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
    cdo -O enspctl,50 $odir/topg/gris_g${grid}m_v3a_rcp_${rcp}_id_*_0_1000.nc $odir/topg_pctl/median_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
    cdo -O enspctl,84 $odir/topg/gris_g${grid}m_v3a_rcp_${rcp}_id_*_0_1000.nc $odir/topg_pctl/pctl84_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
done 

mkdir -p $odir/usurf_pctl
for rcp in 26 45 85; do
gdal_translate NETCDF:2017_11_lhs/sftgif_pctl/percent_gris_g3600m_v3a_rcp_${rcp}_0_1000.nc:sftgif 2017_11_lhs/sftgif_pctl/percent_gris_g3600m_v3a_rcp_${rcp}_0_1000.tif
ncks -O 2017_11_lhs/thk_pctl/pctl16_gris_g3600m_v3a_rcp_${rcp}_0_1000.nc 2017_11_lhs/usurf_pctl/pctl16_gris_g3600m_v3a_rcp_${rcp}_0_1000.nc
ncks -A -v topg 2017_11_lhs/topg_pctl/pctl16_gris_g3600m_v3a_rcp_${rcp}_0_1000.nc 2017_11_lhs/usurf_pctl/pctl16_gris_g3600m_v3a_rcp_${rcp}_0_1000.nc
ncap2 -O -s "usurf=thk+topg; where(thk<10) {usurf=0;};" 2017_11_lhs/usurf_pctl/pctl16_gris_g3600m_v3a_rcp_${rcp}_0_1000.nc 2017_11_lhs/usurf_pctl/pctl16_gris_g3600m_v3a_rcp_${rcp}_0_1000.nc
gdal_translate -a_nodata 0 NETCDF:2017_11_lhs/usurf_pctl/pctl16_gris_g3600m_v3a_rcp_${rcp}_0_1000.nc:usurf 2017_11_lhs/usurf_pctl/pctl16_gris_g3600m_v3a_rcp_${rcp}_0_1000.tif
gdaldem hillshade 2017_11_lhs/usurf_pctl/pctl16_gris_g3600m_v3a_rcp_${rcp}_0_1000.tif 2017_11_lhs/usurf_pctl/pctl16_gris_g3600m_v3a_rcp_${rcp}_0_1000_hs.tif

ncks -O 2017_11_lhs/thk_pctl/pctl84_gris_g3600m_v3a_rcp_${rcp}_0_1000.nc 2017_11_lhs/usurf_pctl/pctl84_gris_g3600m_v3a_rcp_${rcp}_0_1000.nc
ncks -A -v topg 2017_11_lhs/topg_pctl/pctl84_gris_g3600m_v3a_rcp_${rcp}_0_1000.nc 2017_11_lhs/usurf_pctl/pctl84_gris_g3600m_v3a_rcp_${rcp}_0_1000.nc
ncap2 -O -s "usurf=thk+topg; where(thk<10) {usurf=0;};" 2017_11_lhs/usurf_pctl/pctl84_gris_g3600m_v3a_rcp_${rcp}_0_1000.nc 2017_11_lhs/usurf_pctl/pctl84_gris_g3600m_v3a_rcp_${rcp}_0_1000.nc
gdal_translate -a_nodata 0 NETCDF:2017_11_lhs/usurf_pctl/pctl84_gris_g3600m_v3a_rcp_${rcp}_0_1000.nc:usurf 2017_11_lhs/usurf_pctl/pctl84_gris_g3600m_v3a_rcp_${rcp}_0_1000.tif
gdaldem hillshade 2017_11_lhs/usurf_pctl/pctl84_gris_g3600m_v3a_rcp_${rcp}_0_1000.tif 2017_11_lhs/usurf_pctl/pctl84_gris_g3600m_v3a_rcp_${rcp}_0_1000_hs.tif
done




odir=2017_11_ocean
s=chinook
q=t2standard
n=360
grid=900

./lhs_ensemble.py -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 48:00:00 -g ${grid} -s ${s} -q ${q} --step 100 --duration 100 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

odir=2017_11_ctrl
s=chinook
q=t2standard
n=480
grid=600

./lhs_ensemble.py -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 168:00:00 -g ${grid} -s ${s} -q ${q} --step 100 --duration 100 ../calibration/2017_06_vc/state/gris_g900m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc



odir=2017_11_ctrl
cd $odir/snap
for file in save_gris_g900m*; do
    gdal_translate 

# 300 members

~/base/gris-analysis/plotting/plotting.py  -n 4 -o les --time_bounds 2008 3000 --ctrl_file 2017_11_ctrl/scalar/ts_gris_g1800m_v3a_rcp_*_id_CTRL_0_1000.nc --plot rcp_mass 2017_11_lhs/scalar/ts_gris_g3600m_v3a_rcp_*id_0*.nc 2017_11_lhs/scalar/ts_gris_g3600m_v3a_rcp_*id_1*.nc 2017_11_lhs/scalar/ts_gris_g3600m_v3a_rcp_*id_2*.nc

Reading files for RCP 8.5
Year 2100: 0.11 - 0.19 - 0.28 m SLE
         CTRL 0.21 m SLE
Year 2200: 0.50 - 0.75 - 1.04 m SLE
         CTRL 0.72 m SLE
Year 2500: 2.52 - 3.40 - 4.31 m SLE
         CTRL 3.05 m SLE
Year 3000: 5.58 - 6.64 - 7.17 m SLE
         CTRL 6.05 m SLE
Reading files for RCP 4.5
Year 2100: 0.06 - 0.13 - 0.20 m SLE
         CTRL 0.16 m SLE
Year 2200: 0.20 - 0.36 - 0.55 m SLE
         CTRL 0.39 m SLE
Year 2500: 0.87 - 1.36 - 1.89 m SLE
         CTRL 1.27 m SLE
Year 3000: 2.24 - 3.27 - 4.24 m SLE
         CTRL 2.95 m SLE
Reading files for RCP 2.6
Year 2100: 0.03 - 0.10 - 0.16 m SLE
         CTRL 0.12 m SLE
Year 2200: 0.08 - 0.20 - 0.33 m SLE
         CTRL 0.23 m SLE
Year 2500: 0.16 - 0.42 - 0.73 m SLE
         CTRL 0.48 m SLE
Year 3000: 0.24 - 0.72 - 1.27 m SLE
         CTRL 0.75 m SLE
  - writing image les_rcp_limnsw.pdf ...

# 500 members
  Reading files for RCP 8.5
Year 2100: 0.11 - 0.19 - 0.28 m SLE
         CTRL 0.21 m SLE
Year 2200: 0.51 - 0.76 - 1.03 m SLE
         CTRL 0.72 m SLE
Year 2500: 2.56 - 3.42 - 4.33 m SLE
         CTRL 3.05 m SLE
Year 3000: 5.64 - 6.64 - 7.18 m SLE
         CTRL 6.05 m SLE
Reading files for RCP 4.5
Year 2100: 0.06 - 0.13 - 0.20 m SLE
         CTRL 0.16 m SLE
Year 2200: 0.21 - 0.37 - 0.55 m SLE
         CTRL 0.39 m SLE
Year 2500: 0.89 - 1.38 - 1.89 m SLE
         CTRL 1.27 m SLE
Year 3000: 2.27 - 3.30 - 4.25 m SLE
         CTRL 2.95 m SLE
Reading files for RCP 2.6
Year 2100: 0.04 - 0.10 - 0.16 m SLE
         CTRL 0.12 m SLE
Year 2200: 0.08 - 0.20 - 0.34 m SLE
         CTRL 0.23 m SLE
Year 2500: 0.18 - 0.44 - 0.74 m SLE
         CTRL 0.48 m SLE
Year 3000: 0.30 - 0.75 - 1.27 m SLE
         CTRL 0.75 m SLE
  - writing image les_rcp_limnsw.pdf ...


Reading files for RCP 8.5
Year 2100: 0.28 - 0.42 - 0.58 cm SLE year-1
Year 2200: 0.54 - 0.73 - 0.96 cm SLE year-1
Year 2500: 0.83 - 0.99 - 1.08 cm SLE year-1
Max loss rate 50th pctl in Year 2457: 1.020 cm SLE year-1
Max loss rate 16th pctl in Year 2457: 1.212 cm SLE year-1
Max loss rate 84th pctl in Year 2496: 0.827 cm SLE year-1
Max loss rate ctrl in Year 2496: 0.927 cm SLE year-1
Reading files for RCP 4.5
Year 2100: 0.12 - 0.21 - 0.30 cm SLE year-1
Year 2200: 0.18 - 0.29 - 0.42 cm SLE year-1
Year 2500: 0.28 - 0.39 - 0.51 cm SLE year-1
Max loss rate 50th pctl in Year 2739: 0.397 cm SLE year-1
Max loss rate 16th pctl in Year 2739: 0.525 cm SLE year-1
Max loss rate 84th pctl in Year 2988: 0.279 cm SLE year-1
Max loss rate ctrl in Year 2988: 0.333 cm SLE year-1
Reading files for RCP 2.6
Year 2100: 0.05 - 0.11 - 0.18 cm SLE year-1
Year 2200: 0.05 - 0.11 - 0.17 cm SLE year-1
Year 2500: 0.01 - 0.06 - 0.10 cm SLE year-1
Max loss rate 50th pctl in Year 2041: 0.132 cm SLE year-1
Max loss rate 16th pctl in Year 2041: 0.210 cm SLE year-1
Max loss rate 84th pctl in Year 2041: 0.062 cm SLE year-1
Max loss rate ctrl in Year 2041: 0.155 cm SLE year-1
  - writing image les_rcp_tendency_of_ice_mass_glacierized.pdf ...


  
