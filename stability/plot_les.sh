#!/bin/bash

# CMIP forcing
~/base/gris-analysis/plotting/plotting.py  -o giss --plot cmip5 --time_bounds 2008 3000 ../data_sets/climate_forcing/tas_Amon_GISS-E2-H_rcp*0-5000.nc ../data_sets/climate_forcing/tas_cmip5_rcp*ensstd**anom*.nc
# Cumulative contribution LES and CTRL
~/base/gris-analysis/plotting/plotting.py  -o les18 --time_bounds 2008 3000 --ctrl_file 2017_12_ctrl/scalar/ts_gris_g900m_v3a_rcp_*_id_CTRL_0_1000.nc --plot rcp_mass 2018_01_les/scalar_ensstat/ens*_0_1000.nc
# Rates of GMSL rise LES and CTRL
~/base/gris-analysis/plotting/plotting.py -o les18 --time_bounds 2008 3000 --no_legend --ctrl_file 2017_12_ctrl/scalar/ts_gris_g900m_v3a_rcp_*_id_CTRL_0_1000.nc --plot rcp_flux 2018_01_les/scalar_ensstat/ens*_0_1000.nc
# Long term evolution
~/base/gris-analysis/plotting/plotting.py  -o ctrl5k --plot ctrl_mass --time_bounds 2008 7000  2017_12_ctrl/scalar/ts_gris_g900m_v3a_rcp_26_id_CTRL_0_5000.nc 2017_12_ctrl/scalar/ts_gris_g900m_v3a_rcp_45_id_CTRL_0_5000.nc 2017_12_ctrl/scalar/ts_gris_g900m_v3a_rcp_85_id_CTRL_0_2000.nc
# Percent mass
~/base/gris-analysis/plotting/plotting.py  -o ctrl --plot percent_mass --time_bounds 0 100 --bounds 2008 3000 2017_12_ctrl/scalar_percent/ts_gris_g900m_v3a_rcp_*_id_CTRL_0_1000.nc

# Profiles
~/base/gris-analysis/plotting/plotting.py --bounds 0 12000 --time_bounds 2015 2315  -o rcp26 --plot profile_combined 2017_12_ctrl/profiles/profiles_100m_ex_g900m_v3a_rcp_26_id_CTRL_0_3000.nc
~/base/gris-analysis/plotting/plotting.py --bounds 0 12000 --time_bounds 2015 2315  -o rcp45 --plot profile_combined 2017_12_ctrl/profiles/profiles_100m_ex_g900m_v3a_rcp_45_id_CTRL_0_3000.nc
~/base/gris-analysis/plotting/plotting.py --bounds 0 12000 --time_bounds 2015 2315  -o rcp85 --plot profile_combined 2017_12_ctrl/profiles/profiles_100m_ex_g900m_v3a_rcp_85_id_CTRL_0_3000.nc

# Flux Partitioning
~/base/gris-analysis/plotting/plotting.py -n 4 -o ctrl --time_bounds 2008 3000 --no_legend --plot flux_partitioning 2017_12_ctrl/scalar/ts_gris_g900m_v3a_rcp_*id_CTRL_0_1000.nc 2017_12_ctrl/scalar/ts_gris_g900m_v3a_rcp_*id_NTRL_0_1000.nc
# Basin Flux Partitioning
~/base/gris-analysis/plotting/plotting.py -n 4 -o ctrl --bounds -850 450 --time_bounds 2008 3000 --no_legend --plot basin_flux_partitioning 2017_12_ctrl/basins/scalar/ts_b_*_ex_g900m_v3a_rcp_*_id_CTRL_0_2000.nc  2017_12_ctrl/basins/scalar/ts_b_*_ex_g3600m_v3a_rcp_*_id_NTRL_0_1000.nc 

# Plot fluxes for each basin
for rcp in 26 45 85; do
    ~/base/gris-analysis/plotting/plotting.py -o basins_rcp_${rcp}  --time_bounds 2008 3000 --no_legend --plot basin_mass 2017_12_ctrl/basins/scalar/ts_b_*_ex_g900m_v3a_rcp_${rcp}_id_CTRL_0_2000.nc
done

~/base/gris-analysis/plotting/plotting.py -o ctrl --time_bounds 2008 3000 --no_legend --plot station_usurf 2017_12_ctrl/station_ts/profile_g900m_v3a_rcp_*_id_CTRL_0_1000.nc

~/base/gris-analysis/plotting/plotting.py -o ctrl --time_bounds 2008 3000 --no_legend --plot per_basin_flux 2017_12_ctrl/basins/scalar/ts_b_*_ex_g900m_v3a_rcp_*_id_CTRL_0_2000.nc


# grid resolution
~/base/gris-analysis/plotting/plotting.py  -n 8 -o ctrl --time_bounds 2020 2200 --plot grid_res 2017_12_ctrl/scalar/ts_gris_g600m_v3a_rcp_*_id_CTRL_0_200.nc 2017_12_ctrl/scalar/ts_gris_g900m_v3a_rcp_*_id_CTRL_0_1000.nc 2017_12_ctrl/scalar/ts_gris_g1800m_v3a_rcp_*_id_CTRL_0_1000.nc 2017_12_ctrl/scalar/ts_gris_g3600m_v3a_rcp_*_id_CTRL_0_1000.nc 2017_12_ctrl/scalar/ts_gris_g4500m_v3a_rcp_*_id_CTRL_0_1000.nc 2017_12_ctrl/scalar/ts_gris_g9000m_v3a_rcp_*_id_CTRL_0_1000.nc 2017_12_ctrl/scalar/ts_gris_g18000m_v3a_rcp_*_id_CTRL_0_1000.nc

