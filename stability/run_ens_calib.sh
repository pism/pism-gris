#!/bin/bash

odir=2017_08_ens_calib

# PDD
./warming_restart.py --calibrate --o_dir ${odir} --exstep 1 --params pdd -n 72 -w 28:00:00 -g 2400 -s chinook -q t2standard --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g2400m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

# RFR
./warming_restart.py --calibrate --o_dir ${odir} --exstep 1 --params rfr -n 72 -w 28:00:00 -g 2400 -s chinook -q t2standard --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g2400m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

# PRS
./warming_restart.py --calibrate --o_dir ${odir} --exstep 1 --params prs -n 72 -w 28:00:00 -g 2400 -s chinook -q t2standard --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g2400m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

# TLR
./warming_restart.py --calibrate --o_dir ${odir} --exstep 1 --params tlr -n 72 -w 28:00:00 -g 2400 -s chinook -q t2standard --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g2400m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

# PPQ
./warming_restart.py --calibrate --o_dir ${odir} --exstep 1 --params ppq -n 72 -w 48:00:00 -g 2400 -s chinook -q t2standard --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g2400m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

# VCM
./warming_restart.py --calibrate --o_dir ${odir} --exstep 1 --params vcm -n 72 -w 28:00:00 -g 2400 -s chinook -q t2standard --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g2400m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

# OCM
./warming_restart.py --calibrate --o_dir ${odir} --exstep 1 --params ocm -n 72 -w 28:00:00 -g 2400 -s chinook -q t2standard --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g2400m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

# OCS
./warming_restart.py --calibrate --o_dir ${odir} --exstep 1 --params ocs -n 72 -w 28:00:00 -g 2400 -s chinook -q t2standard --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g2400m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

# TCT
./warming_restart.py --calibrate --o_dir ${odir} --exstep 1 --params tct -n 72 -w 28:00:00 -g 2400 -s chinook -q t2standard --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g2400m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

for file in ${odir}/run_scripts/warm_*j.sh; do
    echo $file;
done
