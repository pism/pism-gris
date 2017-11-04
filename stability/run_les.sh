#!/bin/bash

odir=2017_11_lhs
s=chinook
q=t2standard
n=72
grid=3600

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_20171104.csv --calibrate --o_dir ${odir} --exstep 1 -n ${n} -w 10:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


exit 

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
