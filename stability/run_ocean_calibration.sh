#!/bin/bash



./warming_restart.py --o_dir 2017_06_ocean_calib --exstep monthly --params tct,ocean_m -n 72 -w 4:00:00 -g 1200 -s chinook -q t2standard --step 8 --end_year 8 ../calibration/2017_06_vc/state/gris_g1200m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

sbatch warm_gris_g1200m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_low_tct_low.sh
sbatch warm_gris_g1200m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_low_tct_high.sh
sbatch warm_gris_g1200m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_high_tct_low.sh
sbatch warm_gris_g1200m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_high_tct_high.sh

sh warm_gris_g1200m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_low_tct_low_post.sh &
sh warm_gris_g1200m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_low_tct_high_post.sh &
sh warm_gris_g1200m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_high_tct_low_post.sh & 
sh warm_gris_g1200m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_high_tct_high_post.sh &

./warming_restart.py --o_dir 2017_06_ocean_calib --exstep monthly --params tct,ocean_m -n 72 -w 4:00:00 -g 2400 -s chinook -q t2standard --step 8 --end_year 8 ../calibration/2017_06_vc/state/gris_g2400m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

sbatch warm_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_low_tct_low.sh
sbatch warm_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_low_tct_high.sh
sbatch warm_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_high_tct_low.sh
sbatch warm_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_high_tct_high.sh

sh warm_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_low_tct_low_post.sh &
sh warm_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_low_tct_high_post.sh &
sh warm_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_high_tct_low_post.sh & 
sh warm_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_high_tct_high_post.sh &



for basin in "CW" "NE" "NO" "NW" "SE" "SW"; do
             /Volumes/79n/data/gris-analysis/basins/extract_basins.py --basins $basin --o_dir ../spatial_basins ex_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_low_tct_low_0_1000.nc
done

for basin in "CW" "NE" "NO" "NW" "SE" "SW"; do
             /Volumes/79n/data/gris-analysis/basins/extract_basins.py --basins $basin --o_dir ../spatial_basins ex_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_low_tct_low_0_1000.nc
             /Volumes/79n/data/gris-analysis/basins/extract_basins.py --basins $basin --o_dir ../spatial_basins ex_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_low_tct_high_0_1000.nc
             /Volumes/79n/data/gris-analysis/basins/extract_basins.py --basins $basin --o_dir ../spatial_basins ex_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_high_tct_low_0_1000.nc
             /Volumes/79n/data/gris-analysis/basins/extract_basins.py --basins $basin --o_dir ../spatial_basins ex_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_high_tct_high_0_1000.nc
done

om=low
tct=low

/Volumes/79n/data/gris-analysis/plotting/plotting.py -o ctrl --plot basin_mass --time_bounds 2008 3008 2017_06_ocean_1kyr/spatial_basins/b_*_ex_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_low_tct_low_0_1000/sum_fldsum_b_*_ex_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_${om}_tct_${tct}_0_1000.nc

/Volumes/79n/data/gris-analysis/plotting/plotting.py -o ctrl_runmean_10yr --runmean 10 --plot basin_discharge --bounds -100 10 --time_bounds 2008 3008 2017_06_ocean_1kyr/spatial_basins/b_*_ex_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_low_tct_low_0_1000/scalar_fldsum_b_*_ex_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_${om}_tct_${tct}_0_1000.nc

/Volumes/79n/data/gris-analysis/plotting/plotting.py -o ctrl_runmean_10yr --runmean 10 --plot basin_smb  --time_bounds 2008 3008 2017_06_ocean_1kyr/spatial_basins/b_*_ex_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_low_tct_low_0_1000/scalar_fldsum_b_*_ex_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_${om}_tct_${tct}_0_1000.nc

/Volumes/79n/data/gris-analysis/plotting/plotting.py -o ctrl --plot per_basin_cumulative  --time_bounds 2008 3008 2017_06_ocean_1kyr/spatial_basins/b_*_ex_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_low_tct_low_0_1000/sum_fldsum_b_*_ex_gris_g2400m_warming_v3a_no_bath_bd_off_calving_vonmises_calving_om_${om}_tct_${tct}_0_1000.nc

for rcp in 26 45 85; do
    /Volumes/79n/data/gris-analysis/plotting/plotting.py --plot rcp_mass 2017_07_rcp/scalar/cumsum_ts_gris_g2400m_warming_v3a_no_bath_rcp_*.nc
    /Volumes/79n/data/gris-analysis/plotting/plotting.py -o rcp_${rcp}_runmean_10yr --runmean 10 --plot basin_discharge --bounds -100 10 2017_07_rcp/spatial_basins/b_*_ex_gris_g2400m_warming_v3a_no_bath_rcp_${rcp}_bd_off_calving_vonmises_calving_0_1000/scalar_fldsum_b_*_ex_gris_g2400m_warming_v3a_no_bath_rcp_${rcp}_bd_off_calving_vonmises_calving_0_1000.nc
done

