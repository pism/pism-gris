#!/bin/bash

odir=2017_10_lhs
s=chinook
q=t2standard
n=72
grid=3600
gap=~/base/
gap=/Volumes/zachariae

./lhs_ensemble.py -e ../../latin_hypercube/lhs_samples_20171020.csv --calibrate --o_dir ${odir}_ctrl --exstep 1 -n ${n} -w 6:00:00 -g ${grid} -s ${s} -q ${q} --step 500 --duration 500 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


exit 
for file in ${odir}_*/run_scripts/warm_*j.sh; do
    sbatch $file;
done

# Evaluate
mkdir -p $odir/plots
cd $odir/plots
for var in pdd rfr prs tlr ppq vcm ocm ocs tct sia reb; do
    python ${gap}/gris-analysis/plotting/plotting.py -o ens_${var} --time_bounds 2008 2508 --title ${var} --no_legend --plot rcp_ens_mass ../../${odir}_${var}/scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_*.nc
done

# PDD
python ${gap}/gris-analysis/plotting/plotting.py -o ens_pdd --title PDD --no_legend --plot rcp_ens_mass ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_*_prs_0.05_pdd_*_rfr_0.6_ppq_0.6_vcm_1.0_ocs_mid_ocm_mid_tct_mid_bd_i0_0_1000.nc
# RFR
python ${gap}/gris-analysis/plotting/plotting.py -o ens_rfr --title RFR --no_legend --plot rcp_ens_mass ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_*_prs_0.05_pdd_mid_rfr_0.*_ppq_0.6_vcm_1.0_ocs_mid_ocm_mid_tct_mid_bd_i0_0_1000.nc
# PRS
python ${gap}/gris-analysis/plotting/plotting.py -o ens_prs --title PRS --no_legend --plot rcp_ens_mass ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_*_prs_0.*_pdd_mid_rfr_0.6_ppq_0.6_vcm_1.0_ocs_mid_ocm_mid_tct_mid_bd_i0_0_1000.nc
# TLR
python ${gap}/gris-analysis/plotting/plotting.py -o ens_tlr --title TLR --no_legend --plot rcp_ens_mass ../scalar/cumsum_ts_gris_g{grid}m_v3a_rcp_*_tlr_*_prs_0.05_pdd_mid_rfr_0.6_ppq_0.6_vcm_1.0_ocs_mid_ocm_mid_tct_mid_bd_i0_0_1000.nc
# SIA
python ${gap}/gris-analysis/plotting/plotting.py -o ens_sia --title SIA --no_legend --plot rcp_ens_mass ../scalar/cumsum_ts_gris_g2400m_v3a_rcp_26_prs_0.05_pdd_mid_rfr_0.6_ppq_0.6_vcm_1.0_ocs_mid_ocm_mid_tct_mid_bd_i0_0_1000.nc ../scalar/cumsum_ts_gris_g2400m_v3a_rcp_45_prs_0.05_pdd_mid_rfr_0.6_ppq_0.6_vcm_1.0_ocs_mid_ocm_mid_tct_mid_bd_i0_0_1000.nc ../scalar/cumsum_ts_gris_g2400m_v3a_rcp_85_prs_0.05_pdd_mid_rfr_0.6_ppq_0.6_vcm_1.0_ocs_mid_ocm_mid_tct_mid_bd_i0_0_1000.nc ../scalar/cumsum_ts_gris_g2400m_v3a_rcp_*_prs_0.05_pdd_mid_rfr_0.6_sia_e_3_ppq_0.6_vcm_1.0_ocs_mid_ocm_mid_tct_mid_bd_i0_0_1000.nc 


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

# REB
python ${gap}/gris-analysis/plotting/plotting.py -o ens_reb --title REB --no_legend --plot rcp_ens_mass ../scalar/cumsum_ts_gris_g${grid}m_v3a_rcp_*_prs_0.05_pdd_mid_rfr_0.6_ppq_0.6_vcm_1.0_ocs_mid_ocm_mid_tct_mid_bd_*.nc
