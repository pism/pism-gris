#!/bin/bash

odir=2017_11_lhs
s=chinook
q=t2standard
n=72
grid=3600

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_20171104.csv --calibrate --o_dir ${odir} --exstep 1 -n ${n} -w 10:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


exit 
odir=2017_11_lhs
s=pleiades_broadwell
q=normal
n=84
grid=3600

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_20171104.csv --calibrate --o_dir ${odir} --exstep 1 -n ${n} -w 08:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


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
sbatch 2017_11_lhs/run_scripts/lhs_g3600m_v3a_rcp_${rcp}_id_4${id1}${id}_j.sh;
done
done
done


for rcp in 26 45 85; do
    cdo -O enspctl,16 $odir/scalar/ts_gris_g3600m_v3a_rcp_*id_*.nc $odir/thk_pctl/pctl16_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
done 

# NISO-CTRL
odir=2017_11_ctrl
grid=3600
mkdir -p $odir/niso
for rcp in 26 45 85; do
    cdo sub -selvar,topg $odir/state/gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc -selvar,topg $odir/state/gris_g${grid}m_v3a_rcp_${rcp}_id_NISO_0_1000.nc $odir/niso/topg_CTRL_NISO_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
    gdal_translate $odir/niso/topg_CTRL_NISO_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/niso/topg_CTRL_NISO_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif
done

# Cumulative contribution LES and CTRL
~/base/gris-analysis/plotting/plotting.py -o les --time_bounds 2008 3000 --ctrl_file 2017_11_ctrl/scalar/ts_gris_g1800m_v3a_rcp_*_id_CTRL_0_1000.nc --plot rcp_mass 2017_11_lhs/scalar/ts_gris_g3600m_v3a_rcp_*id_*.nc
# Rates of GMSL rise LES and CTRL
~/base/gris-analysis/plotting/plotting.py -o les --time_bounds 2008 3000 --no_legend --ctrl_file 2017_11_ctrl/scalar/ts_gris_g1800m_v3a_rcp_*_id_CTRL_0_1000.nc --plot rcp_flux 2017_11_lhs/scalar/ts_gris_g3600m_v3a_rcp_*id_*.nc

~/base/gris-analysis/plotting/plotting.py -o les --time_bounds 2008 3000 --plot rcp_traj 2017_11_lhs/scalar/ts_gris_g3600m_v3a_rcp_*id_*.nc
~/base/gris-analysis/plotting/plotting.py -o les_flux --time_bounds 2008 3000 --no_legend --plot rcp_fluxes 2017_11_lhs/scalar/ts_gris_g3600m_v3a_rcp_*id_*.nc
for rcp in 26 45 85; do
    ~/base/gris-analysis/plotting/plotting.py -o basins_rcp_${rcp} --time_bounds 2008 3000 --no_legend --plot basin_mass 2017_11_ctrl/basins/scalar/ts_b_*_ex_g3600m_v3a_rcp_${rcp}_id_CTRL_0_1000/ts_b_*_ex_g3600m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc
done
for rcp in 26 45 85; do
    ~/base/gris-analysis/plotting/plotting.py -o basins_rcp_${rcp} --time_bounds 2008 3000 --no_legend --plot basin_d 2017_11_ctrl/basins/scalar/ts_b_*_ex_g1800m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc
done
~/base/gris-analysis/plotting/plotting.py -o ctrl --time_bounds 2008 3000 --no_legend --plot per_basin_flux 2017_11_ctrl/basins/scalar/ts_b_*_ex_g3600m_v3a_rcp_*_id_CTRL_0_1000.nc

odir=2017_11_ctrl
grid=1800
mkdir -p $odir/final_states
cd $odir/state
for file in gris_g${grid}m*0_1000.nc; do
    cdo aexpr,usurf=topg+thk -selvar,topg,thk,velsurf_mag $file ../final_states/$file
    ncap2 -O -s "where(thk<10) {velsurf_mag=-2e9; usurf=0.;};" ../final_states/$file ../final_states/$file
    gdal_translate NETCDF:../final_states/$file:velsurf_mag ../final_states/velsurf_mag_$file.tif
    gdal_translate -a_nodata 0 NETCDF:../final_states/$file:usurf ../final_states/usurf_$file.tif
    gdaldem hillshade ../final_states/usurf_$file.tif ../final_states/hs_usurf_$file.tif
done
cd ../../


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
    for year in 2100 2200 3000; do
        for run in CTRL NISO NFRN; do
            cdo divc,365 -divc,1e15 -selvar,limnsw -sub -selyear,$year $odir/scalar/ts_gris_g3600m_v3a_rcp_${rcp}_id_${run}_0_1000.nc -selyear,2008 $odir/scalar/ts_gris_g3600m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/dgmsl/dgms_rcp_${rcp}_${run}_${year}.nc
        done
    done
done

odir=2017_11_ctrl
mkdir -p $odir/dgmsl
for rcp in 26 45 85; do
    for year in 2100 2200 3000; do
        for run in CTRL; do
            cdo divc,365 -divc,1e15 -selvar,limnsw -sub -selyear,$year $odir/scalar/ts_gris_g1800m_v3a_rcp_${rcp}_id_${run}_0_1000.nc -selyear,2008 $odir/scalar/ts_gris_g1800m_v3a_rcp_${rcp}_id_${run}_0_1000.nc $odir/dgmsl/dgms_rcp_${rcp}_${run}_${year}.nc
        done
    done
done

odir=2017_11_lhs
grid=3600
mkdir -p $odir/sftgif
mkdir -p $odir/sftgif_pctl
cd $odir/state
for file in gris_g${grid}m*id_*0_1000.nc; do
    if [ ! -f "../sftgif/$file" ]; then
    echo $file
    cdo selvar,sftgif $file ../sftgif/$file
    fi
done
cd ../../
for rcp in 26 45 85; do
    cdo -O enssum $odir/sftgif/gris_g${grid}m_v3a_rcp_${rcp}_id_*_0_1000.nc $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
    cdo divc,5 $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
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

# 300 members

Reading files for RCP 8.5
Year 2100: 0.11 - 0.19 - 0.28 m SLE
         CTRL 0.21 m SLE
Year 2200: 0.50 - 0.76 - 1.04 m SLE
         CTRL 0.72 m SLE
Year 2500: 2.56 - 3.43 - 4.33 m SLE
         CTRL 3.05 m SLE
Year 3000: 5.64 - 6.64 - 7.18 m SLE
         CTRL 6.05 m SLE
Reading files for RCP 4.5
Year 2100: 0.06 - 0.13 - 0.20 m SLE
         CTRL 0.16 m SLE
Year 2200: 0.21 - 0.37 - 0.55 m SLE
         CTRL 0.39 m SLE
Year 2500: 0.89 - 1.38 - 1.90 m SLE
         CTRL 1.27 m SLE
Year 3000: 2.27 - 3.31 - 4.25 m SLE
         CTRL 2.95 m SLE
Reading files for RCP 2.6
Year 2100: 0.04 - 0.10 - 0.16 m SLE
         CTRL 0.12 m SLE
Year 2200: 0.08 - 0.20 - 0.34 m SLE
         CTRL 0.23 m SLE
Year 2500: 0.17 - 0.44 - 0.74 m SLE
         CTRL 0.48 m SLE
Year 3000: 0.28 - 0.75 - 1.28 m SLE
         CTRL 0.75 m SLE
  - writing image les_rcp_limnsw.pdf ...

Reading files for RCP 8.5
Year 2100: 0.28 - 0.42 - 0.59 cm SLE year-1
Year 2200: 0.53 - 0.74 - 0.96 cm SLE year-1
Year 2500: 0.82 - 0.99 - 1.08 cm SLE year-1
Reading files for RCP 4.5
Year 2100: 0.11 - 0.21 - 0.30 cm SLE year-1
Year 2200: 0.18 - 0.29 - 0.42 cm SLE year-1
Year 2500: 0.28 - 0.39 - 0.52 cm SLE year-1
Reading files for RCP 2.6
Year 2100: 0.04 - 0.11 - 0.18 cm SLE year-1
Year 2200: 0.05 - 0.11 - 0.18 cm SLE year-1
Year 2500: 0.01 - 0.06 - 0.10 cm SLE year-1
  - writing image les_rcp_tendency_of_ice_mass_glacierized.pdf ...

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
