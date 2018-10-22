#!/bin/bash

odir=2018_10_sobol2
s=chinook
q=t2standard
n=72
grid=3600

./lhs_ensemble.py -e ../sobol/saltelli_samples.csv --spatial_ts none --o_dir ${odir} --exstep 1 -n ${n} -w 10:00:00 -g ${grid} -s ${s} -q ${q} --step 100 --duration 100 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

rcp=45
for id in {000..129}; do sbatch /import/c1/ICESHEET/aaschwanden/pism-gris/stability/2018_10_sobol/run_scripts/lhs_g3600m_v3a_rcp_${rcp}_id_${id}_j.sh; done
for id in {130..168}; do sbatch /import/c1/ICESHEET/aaschwanden/pism-gris/stability/2018_10_sobol/run_scripts/lhs_g3600m_v3a_rcp_${rcp}_id_${id}_j.sh; done
