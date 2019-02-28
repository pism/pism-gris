#!/bin/bash


./cc_ensemble.py --hydrology diffuse --o_dir 2019_02_jib --ensemble_file ../latin_hypercube/cc_control.csv -g 600 -d jib -n 120 -s chinook -q t2standard ../calibration/2017_06_vc/state/gris_g600m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc
