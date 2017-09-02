#!/bin/bash

odir=2017_08_ens_calib
s=chinook
q=t2standard
n=72
grid=2400
gap=~/base/
gap=/Volumes/zachariae

# PDD
./warming_restart.py --calibrate --o_dir ${odir} --exstep 1 --params pdd -n ${n} -w 28:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

# RFR
./warming_restart.py --calibrate --o_dir ${odir} --exstep 1 --params rfr -n ${n} -w 28:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

# PRS
./warming_restart.py --calibrate --o_dir ${odir} --exstep 1 --params prs -n ${n} -w 28:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

# TLR
./warming_restart.py --calibrate --o_dir ${odir} --exstep 1 --params tlr -n ${n} -w 28:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

# PPQ
./warming_restart.py --calibrate --o_dir ${odir} --exstep 1 --params ppq -n ${n} -w 48:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

# VCM
./warming_restart.py --calibrate --o_dir ${odir} --exstep 1 --params vcm -n ${n} -w 28:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

# OCM
./warming_restart.py --calibrate --o_dir ${odir} --exstep 1 --params ocm -n ${n} -w 28:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

# OCS
./warming_restart.py --calibrate --o_dir ${odir} --exstep 1 --params ocs -n ${n} -w 28:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

# TCT
./warming_restart.py --calibrate --o_dir ${odir} --exstep 1 --params tct -n ${n} -w 28:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

for file in ${odir}/run_scripts/warm_*j.sh; do
    sbatch $file;
done

# Evaluate

cd $odir
mkdir -p plots
cd plots
# PDD
python ${gap}/gris-analysis/plotting/plotting.py -o ens_pdd --title PDD --no_legend --plot rcp_ens_mass ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_*_prs_0.05_pdd_*_rfr_0.6_ppq_0.6_vcm_1.0_ocs_mid_ocm_mid_tct_mid_bd_i0_0_1000.nc
# RFR
python ${gap}/gris-analysis/plotting/plotting.py -o ens_rfr --title RFR --no_legend --plot rcp_ens_mass ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_*_prs_0.05_pdd_mid_rfr_0.*_ppq_0.6_vcm_1.0_ocs_mid_ocm_mid_tct_mid_bd_i0_0_1000.nc
# PRS
python ${gap}/gris-analysis/plotting/plotting.py -o ens_prs --title PRS --no_legend --plot rcp_ens_mass ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_*_prs_0.*_pdd_mid_rfr_0.6_ppq_0.6_vcm_1.0_ocs_mid_ocm_mid_tct_mid_bd_i0_0_1000.nc
# TLR
python ${gap}/gris-analysis/plotting/plotting.py -o ens_tlr --title TLR --no_legend --plot rcp_ens_mass ../scalar/cumsum_ts_gris_g{grid}m_v3a_rcp_*_tlr_*_prs_0.05_pdd_mid_rfr_0.6_ppq_0.6_vcm_1.0_ocs_mid_ocm_mid_tct_mid_bd_i0_0_1000.nc

# PPQ
python ${gap}/gris-analysis/plotting/plotting.py -o ens_ppq --title PPQ --no_legend --plot rcp_ens_mass ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_26_prs_0.05_pdd_mid_rfr_0.6_ppq_0.*_vcm_1.0_ocs_mid_ocm_mid_tct_mid_bd_i0_0_1000.nc ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_45_prs_0.05_pdd_mid_rfr_0.6_ppq_0.*_vcm_1.0_ocs_mid_ocm_mid_tct_mid_bd_i0_0_1000.nc ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_85_prs_0.05_pdd_mid_rfr_0.6_ppq_0.*_vcm_1.0_ocs_mid_ocm_mid_tct_mid_bd_i0_0_1000.nc

# VCM
python ${gap}/gris-analysis/plotting/plotting.py -o ens_vcm --title VCM --no_legend --plot rcp_ens_mass ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_26_prs_0.05_pdd_mid_rfr_0.6_ppq_0.6_vcm_*_ocs_mid_ocm_mid_tct_mid_bd_i0_0_1000.nc ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_45_prs_0.05_pdd_mid_rfr_0.6_ppq_0.6_vcm_*_ocs_mid_ocm_mid_tct_mid_bd_i0_0_1000.nc ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_85_prs_0.05_pdd_mid_rfr_0.6_ppq_0.6_vcm_*_ocs_mid_ocm_mid_tct_mid_bd_i0_0_1000.nc

# OCS
python ${gap}/gris-analysis/plotting/plotting.py -o ens_ocs --title OCS --no_legend --plot rcp_ens_mass  ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_26_prs_0.05_pdd_mid_rfr_0.6_ppq_0.6_vcm_1.0_ocs_*_ocm_mid_tct_mid_bd_i0_0_1000.nc ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_45_prs_0.05_pdd_mid_rfr_0.6_ppq_0.6_vcm_1.0_ocs_*_ocm_mid_tct_mid_bd_i0_0_1000.nc ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_85_prs_0.05_pdd_mid_rfr_0.6_ppq_0.6_vcm_1.0_ocs_*_ocm_mid_tct_mid_bd_i0_0_1000.nc

# OCM
python ${gap}/gris-analysis/plotting/plotting.py -o ens_ocm --title OCM --no_legend --plot rcp_ens_mass ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_26_prs_0.05_pdd_mid_rfr_0.6_ppq_0.6_vcm_1.0_ocs_mid_ocm_*_tct_mid_bd_i0_0_1000.nc ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_45_prs_0.05_pdd_mid_rfr_0.6_ppq_0.6_vcm_1.0_ocs_mid_ocm_*_tct_mid_bd_i0_0_1000.nc ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_85_prs_0.05_pdd_mid_rfr_0.6_ppq_0.6_vcm_1.0_ocs_mid_ocm_*_tct_mid_bd_i0_0_1000.nc

# TCT
python ${gap}/gris-analysis/plotting/plotting.py -o ens_tct --title TCT --no_legend --plot rcp_ens_mass ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_26_prs_0.05_pdd_mid_rfr_0.6_ppq_0.6_vcm_1.0_ocs_mid_ocm_mid_tct_*_bd_i0_0_1000.nc ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_45_prs_0.05_pdd_mid_rfr_0.6_ppq_0.6_vcm_1.0_ocs_mid_ocm_mid_tct_*_bd_i0_0_1000.nc ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_85_prs_0.05_pdd_mid_rfr_0.6_ppq_0.6_vcm_1.0_ocs_mid_ocm_mid_tct_*_bd_i0_0_1000.nc

