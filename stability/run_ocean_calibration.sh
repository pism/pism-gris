#!/bin/bash

./warming_restart.py --o_dir 2017_06_ocean_calib --exstep monthly --params tct,ocean_m -n 72 -w 2:00:00 -g 1500 -s chinook -q t2standard --step 8 --end_year 8 ../calibration/2017_06_vc/state/gris_g1500m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

sbatch warm_gris_g1500m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_low_tct_low.sh
sbatch warm_gris_g1500m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_low_tct_high.sh
sbatch warm_gris_g1500m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_high_tct_low.sh
sbatch warm_gris_g1500m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_high_tct_high.sh


./warming_restart.py --o_dir 2017_06_ocean_calib --exstep monthly --params tct,ocean_m -n 72 -w 4:00:00 -g 1200 -s chinook -q t2standard --step 8 --end_year 8 ../calibration/2017_06_vc/state/gris_g1200m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

sbatch warm_gris_g1200m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_low_tct_low.sh
sbatch warm_gris_g1200m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_low_tct_high.sh
sbatch warm_gris_g1200m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_high_tct_low.sh
sbatch warm_gris_g1200m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_high_tct_high.sh


for basin in "CW" "NE" "NO" "NW" "SE" "SW"; do
             /Volumes/79n/data/gris-analysis/basins/extract_basins.py --basins $basin --o_dir ../spatial_basins ex_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_low_tct_low_0_1000.nc
done

