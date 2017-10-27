#!/bin/bash

odir=2017_10_lhs
s=chinook
q=t2standard
n=72
grid=3600
gap=~/base/
gap=/Volumes/zachariae

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_20171022.csv --calibrate --o_dir ${odir}_ctrl --exstep 1 -n ${n} -w 10:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


exit 
for file in ${odir}/run_scripts/lhs_*j.sh; do
    sbatch $file;
done

# Evaluate
mkdir -p $odir/plots
cd $odir/plots
for var in pdd rfr prs tlr ppq vcm ocm ocs tct sia reb; do
    python ${gap}/gris-analysis/plotting/plotting.py -o ens_${var} --time_bounds 2008 2508 --title ${var} --no_legend --plot rcp_ens_mass ../../${odir}_${var}/scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_*.nc
done
