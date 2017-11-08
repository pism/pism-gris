#!/bin/bash

odir=2017_11_lhs
s=chinook
q=t2standard
n=72
grid=3600

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_20171104.csv --calibrate --o_dir ${odir} --exstep 1 -n ${n} -w 10:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


exit 

for id in `seq 0 9`;
do
for rcp in 26 45 85;
do
sbatch 2017_11_lhs/run_scripts/lhs_g3600m_v3a_rcp_${rcp}_id_00${id}_j.sh;
done
done

for id1 in `seq 0 9`;
do
for id in `seq 0 9`;
do
for rcp in 26 45 85;
do
sbatch 2017_11_lhs/run_scripts/lhs_g3600m_v3a_rcp_${rcp}_id_1${id1}${id}_j.sh;
done
done
done


~/base/gris-analysis/plotting/plotting.py -o les --time_bounds 2008 3000 --no_legend --ctrl_file 2017_11_ctrl/scalar/ts_gris_g3600m_v3a_rcp_*_id_CTRL_0_1000.nc --plot rcp_flux 2017_11_lhs/scalar/ts_gris_g3600m_v3a_rcp_*id_0*.nc
~/base/gris-analysis/plotting/plotting.py -o les --time_bounds 2008 3000 --ctrl_file 2017_11_ctrl/scalar/ts_gris_g3600m_v3a_rcp_*_id_CTRL_0_1000.nc --plot rcp_mass 2017_11_lhs/scalar/ts_gris_g3600m_v3a_rcp_*id_0*.nc
~/base/gris-analysis/plotting/plotting.py -o les --time_bounds 2008 3000 --plot rcp_traj 2017_11_lhs/scalar/ts_gris_g3600m_v3a_rcp_*id_0*.nc
~/base/gris-analysis/plotting/plotting.py -o les_flux --time_bounds 2008 3000 --no_legend --plot rcp_fluxes 2017_11_lhs/scalar/ts_gris_g3600m_v3a_rcp_*id_0*.nc

mkdir -p $odir/sftgif
mkdir -p $odir/sftgif_pctl
cd $odir/state
for file in gris_g${grid}m*id_0*0_1000.nc; do
    if [ ! -f "../sftgif/$file" ]; then
    echo $file
    cdo selvar,sftgif $file ../sftgif/$file
    fi
done
cd ../../
for rcp in 26 45 85; do
    cdo -O enssum $odir/sftgif/gris_g${grid}m_v3a_rcp_${rcp}_id_0*_0_1000.nc $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
    cdo mulc,1 $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
done 

mkdir -p $odir/velsurf_mag
mkdir -p $odir/velsurf_mag_pctl
cd $odir/state
for file in gris_g${grid}m*id_0*0_1000.nc; do
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
for file in gris_g${grid}m*id_0*0_1000.nc; do
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

for rcp in 26 45 85; do
gdal_translate NETCDF:2017_11_lhs/sftgif_pctl/percent_gris_g3600m_v3a_rcp_${rcp}_0_1000.nc:sftgif 2017_11_lhs/sftgif_pctl/percent_gris_g3600m_v3a_rcp_${rcp}_0_1000.tif
gdal_translate NETCDF:2017_11_lhs/velsurf_mag_pctl/median_gris_g3600m_v3a_rcp_${rcp}_0_1000.nc:velsurf_mag 2017_11_lhs/velsurf_mag_pctl/median_gris_g3600m_v3a_rcp_${rcp}_0_1000.tif
gdal_translate NETCDF:2017_11_lhs/velsurf_mag_pctl/pctl84_gris_g3600m_v3a_rcp_${rcp}_0_1000.nc:velsurf_mag 2017_11_lhs/velsurf_mag_pctl/pctl84_gris_g3600m_v3a_rcp_${rcp}_0_1000.tif
gdal_translate NETCDF:2017_11_lhs/thk_pctl/median_gris_g3600m_v3a_rcp_${rcp}_0_1000.nc:thk 2017_11_lhs/thk_pctl/percent_gris_g3600m_v3a_rcp_${rcp}_0_1000.tif
done

odir=2017_11_ctrl
s=chinook
q=t2standard
n=72
grid=3600

./lhs_ensemble.py -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 10:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


odir=2017_11_ctrl
s=chinook
q=t2standard
n=144
grid=1800

./lhs_ensemble.py -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 36:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

odir=2017_11_ctrl
s=chinook
q=t2standard
n=360
grid=900

./lhs_ensemble.py -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 168:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


odir=2017_10_lhs
cd $odir/state
for file in gris_g*00m_v3a_rcp_*_id_*1000.nc; do
    for var in sftgif thk; do
        mkdir -p ../$var
        if [ ! -f "../$var/$var_$file" ]; then
            echo $file;
            cdo -f nc4 selvar,$var $file ../$var/$var_$file;
        fi;
    done
done
cd ../../

for rcp in 26; do
cdo -f nc4 enssum $odir/sftgif/*gris_g*00m_v3a_rcp_${rcp}_*.nc $odir/sftgif_sum/sftgif_gris_g3600m_v3a_rcp_${rcp}.nc
done

odir=2017_10_calib
s=chinook
q=t2standard
n=72
grid=1200
gap=~/base/
gap=/Volumes/zachariae

./lhs_ensemble.py -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 03:00:00 -g ${grid} -s ${s} -q ${q} --step 8 --duration 8 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

odir=2017_10_ctrl
s=chinook
q=t2small
n=24
grid=4500
gap=~/base/
gap=/Volumes/zachariae

./lhs_ensemble.py -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 04:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc



for file in ${odir}/run_scripts/lhs_*j.sh; do
    sbatch $file;
done

# Evaluate
mkdir -p $odir/plots
cd $odir/plots
for var in pdd rfr prs tlr ppq vcm ocm ocs tct sia reb; do
    python ${gap}/gris-analysis/plotting/plotting.py -o ens_${var} --time_bounds 2008 2508 --title ${var} --no_legend --plot rcp_ens_mass ../../${odir}_${var}/scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_*.nc
done
