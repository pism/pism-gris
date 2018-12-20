#!/bin/bash

# GCM forcing
~/base/gris-analysis/plotting/plotting.py  -o gcm_2300 --plot cmip5_rcp --time_bounds 2008 2300 ../data_sets/climate_forcing/tas_cmip5_rcp*ensstd**anom*.nc ../data_sets/climate_forcing/tas_Amon_*_rcp*_r1i1p1_ym_anom_GRIS_0-5000.nc

# LES
~/base/gris-analysis/plotting/plotting.py  -o les18 --time_bounds 2008 3000 --ctrl_file 2018_08_ctrl/scalar_clean/ts_gris_g900m_v3a_rcp_*_id_CTRL_0_1000.nc 2018_08_ctrl/contrib_flux_percent/*_0_1000.nc 2018_08_ctrl/contrib_flux_absolute/*_0_1000.nc --plot les 2018_09_les/scalar_ensstat/ens*_0_1000.nc ../data_sets/climate_forcing/tas_cmip5_rcp*ensstd**anom*.nc ../data_sets/climate_forcing/tas_Amon_*_rcp*_r1i1p1_ym_anom_GRIS_0-5000.nc  2018_09_les/contrib_flux_percent/ens*_0_1000.nc 2018_09_les/contrib_flux_absolute/ens*_0_1000.nc

# Profiles
~/base/gris-analysis/plotting/plotting.py -c ~/base/gris-analysis/plotting/bath_112.cpt --bounds 0 12000 --time_bounds 2015 2315  -o rcp45 --plot profile 2018_08_ctrl/profiles/profiles_100m_ex_gris_g900m_v3a_rcp_45_id_CTRL_0_1000.nc

~/base/gris-analysis/plotting/plotting.py -c ~/base/gris-analysis/plotting/bath_112.cpt --bounds 0 12000 --time_bounds 2015 2315  -o rcp45_g450m --plot profile 2018_08_ctrl/profiles/profiles_100m_ex_gris_g450m_v3a_rcp_45_id_CTRL_0_400.nc

# Flux Partitioning
~/base/gris-analysis/plotting/plotting.py -n 4 -o ctrl --time_bounds 2008 3000 --no_legend --plot flux_partitioning 2018_08_ctrl/fldsum/ts_gris_g900m_v3a_rcp_*id_CTRL_0_1000.nc 2018_08_ctrl/fldsum/ts_gris_g900m_v3a_rcp_*id_NTRL_0_1000.nc
# Basin Flux Partitioning
~/base/gris-analysis/plotting/plotting.py -n 4 -o ctrl --bounds -1500 450 --time_bounds 2008 3000 --no_legend --plot basin_flux_partitioning 2018_08_ctrl/basins/scalar/ts_b_*_ex_gris_g900m_v3a_rcp_*_id_CTRL_0_1000.nc

# Animation
~/base/gris-analysis/plotting/plotting.py -f png --plot ctrl_mass_anim 2018_08_ctrl/scalar/ts_gris_g900m_v3a_rcp_*_id_CTRL_0_1000.nc
~/base/gris-analysis/plotting/plotting.py -f png --time_bounds 2015 2415 --plot d_contrib_anim 2018_09_les/contrib_flux_percent/ens*_0_1000.nc

# Profile Animation
~/base/gris-analysis/plotting/plotting.py -r 1200 -c ~/base/gris-analysis/plotting/bath_112.cpt --bounds 0 12000 --time_bounds 2015 2315  -o rcp45 --plot profile_anim 2018_08_ctrl/profiles/profiles_100m_ex_gris_g900m_v3a_rcp_45_id_CTRL_0_1000.nc

~/base/gris-analysis/plotting/plotting.py -r 1200 -c ~/base/gris-analysis/plotting/bath_112.cpt --bounds 0 12000 --time_bounds 2015 2315  -o rcp45 --plot profile_anim 2018_08_ctrl/profiles/profiles_100m_ex_gris_g600m_v3a_rcp_45_id_CTRL_0_1000.nc

~/base/gris-analysis/plotting/plotting.py -f png -r 1200 -c ~/base/gris-analysis/plotting/bath_112.cpt --bounds 0 8000 --time_bounds 2015 2415  -o rcp85 --plot profile_anim 2018_08_ctrl/profiles/profiles_100m_ex_gris_g600m_v3a_rcp_85_id_CTRL_0_1000.nc

# grid resolution
~/base/gris-analysis/plotting/plotting.py  -n 8 -o ctrl --time_bounds 2020 2200 --bounds -750 0 --plot grid_res 2018_08_ctrl/scalar_clean/ts_gris_g450m_v3a_rcp_*_id_CTRL_0_1000.nc 2018_08_ctrl/scalar_clean/ts_gris_g600m_v3a_rcp_*_id_CTRL_0_1000.nc 2018_08_ctrl/scalar_clean/ts_gris_g900m_v3a_rcp_*_id_CTRL_0_1000.nc 2018_08_ctrl/scalar_clean/ts_gris_g1800m_v3a_rcp_*_id_CTRL_0_1000.nc 2018_08_ctrl/scalar_clean/ts_gris_g3600m_v3a_rcp_*_id_CTRL_0_1000.nc 2018_08_ctrl/scalar_clean/ts_gris_g4500m_v3a_rcp_*_id_CTRL_0_1000.nc 2018_08_ctrl/scalar_clean/ts_gris_g9000m_v3a_rcp_*_id_CTRL_0_1000.nc 2018_08_ctrl/scalar_clean/ts_gris_g18000m_v3a_rcp_*_id_CTRL_0_1000.nc

# Random ice discharge
~/base/gris-analysis/plotting/plotting.py -n 4 -o test  --time_bounds 2008 3000 --plot random_flux 2018_09_les/scalar_clean/ts_gris_g1800m_v3a_rcp_85_*.nc



~/base/gris-analysis/plotting/plotting.py -o ctrl_2300 --time_bounds 2008 3000 --bounds 0 2  --plot ens_mass 2018_09_les/scalar_ensstat/ens*_0_1000.nc
~
~/base/gris-analysis/plotting/plotting.py -o les18 --no_legend --time_bounds 2008 3000 --ctrl_file 2018_08_ctrl/scalar_clean/ts_gris_g900m_v3a_rcp_*_id_CTRL_0_1000.nc  --plot forcing_mass 2018_09_les/scalar_ensstat/ens*_0_1000.nc ../data_sets/climate_forcing/tas_cmip5_rcp*ensstd**anom*.nc ../data_sets/climate_forcing/tas_Amon_*_rcp*_r1i1p1_ym_anom_GRIS_0-5000.nc

~/base/gris-analysis/plotting/plotting.py  -o les18_ens --time_bounds 2008 2300  --plot les 2018_09_les/scalar_ensstat/ens*_0_1000.nc ../data_sets/climate_forcing/tas_cmip5_rcp*ensstd**anom*.nc ../data_sets/climate_forcing/tas_Amon_*_rcp*_r1i1p1_ym_anom_GRIS_0-5000.nc  2018_09_les/contrib_flux_percent/ens*_0_1000.nc 2018_09_les/contrib_flux_absolute/ens*_0_1000.nc

~/base/gris-analysis/plotting/plotting.py  -o les18_c --time_bounds 2008 3000  --plot mass_d 2018_09_les/scalar_ensstat/ens*_0_1000.nc ../data_sets/climate_forcing/tas_cmip5_rcp*ensstd**anom*.nc ../data_sets/climate_forcing/tas_Amon_*_rcp*_r1i1p1_ym_anom_GRIS_0-5000.nc  2018_09_les/contrib_flux_percent/ens*_0_1000.nc 2018_09_les/contrib_flux_absolute/ens*_0_1000.nc


~/base/gris-analysis/plotting/plotting.py  -o sobel --time_bounds 2015 2500  --plot sobel 2018_09_les/scalar_ensstat/ens*_0_1000.nc
