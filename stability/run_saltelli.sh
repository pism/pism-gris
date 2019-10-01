#!/bin/bash


odir=2019_05_salt
s=pleiades_broadwell
q=long
n=112
grid=1800

PISM_PREFIX=~/pism-as19/bin/ ./lhs_ensemble.py -e ../sobol/saltelli_samples_200_vcm.csv --spatial_ts none --o_dir ${odir} --exstep 1 -n ${n} -w 36:00:00 -g ${grid} -s ${s} -q ${q} --step 100 --duration 100 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


odir=2019_02_salt
s=pleiades_broadwell
q=long
n=112
grid=1800

PISM_PREFIX=~/pism-as19/bin/ ./lhs_ensemble.py -e ../sobol/saltelli_samples_240.csv --spatial_ts none --o_dir ${odir} --exstep 1 -n ${n} -w 36:00:00 -g ${grid} -s ${s} -q ${q} --step 100 --duration 100 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

rcp=45
for id in {2180..2479}; do qsub /nobackupp8/aaschwan/pism-gris/stability/${odir}/run_scripts/lhs_g1800m_v3a_rcp_${rcp}_id_${id}_j.sh; done

rcp=45
for id in {3080..3179}; do qsub /nobackupp8/aaschwan/pism-gris/stability/${odir}/run_scripts/lhs_g1800m_v3a_rcp_${rcp}_id_${id}_j.sh; done

odir=2019_02_salt
s=chinook
q=t2standard
n=72
grid=1800

PISM_PREFIX=~/pism-as19/bin/ ./lhs_ensemble.py -e ../sobol/saltelli_samples_20.csv --spatial_ts basic --o_dir ${odir} --exstep 1 -n ${n} -w 48:00:00 -g ${grid} -s ${s} -q ${q} --step 100 --duration 100 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


exit

rcp=45
for id in {0..294}; do qsub /nobackupp8/aaschwan/pism-gris/stability/2019_05_salt/run_scripts/lhs_g1800m_v3a_rcp_${rcp}_id_${id}_j.sh; done
