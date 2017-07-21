#!/bin/bash


./warming_restart.py --o_dir 2017_07_rcps --exstep 1 --params rcp,lapse,precip_scaling -n 72 -w 8:00:00 -g 3600 -s chinook -q t2standard --step 1000 ../calibration/2017_06_vc/state/gris_g3600m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc 
_calving_vonmises_calving_0_100.nc

./warming_restart.py --o_dir 2017_07_rcps --exstep 1 --params rcp,lapse,precip_scaling,ocean_f -n 72 -w 8:00:00 -g 3600 -s chinook -q t2standard --step 1000 ../calibration/2017_06_vc/state/gris_g3600m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc 
_calving_vonmises_calving_0_100.nc



for lapse in 0 6; do
    for ps in 0 0.05; do
        end_year=2100
        /Volumes/79n/data/gris-analysis/plotting/plotting.py -o lapse_${lapse}_ps_${ps}_2009_${end_year} --title lapse_${lapse}_ps_${ps} --time_bounds 2009 ${end_year} --bounds 0 0.15 --plot rcp_mass 2017_07_rcps/scalar/cumsum_ts_gris_g3600m_warming_v3a_no_bath_lapse_${lapse}_ps_${ps}_rcp_*_bd_off_calving_vonmises_calving_0_1000.nc
        end_year=2200
        /Volumes/79n/data/gris-analysis/plotting/plotting.py -o lapse_${lapse}_ps_${ps}_2009_${end_year} --title lapse_${lapse}_ps_${ps} --time_bounds 2009 ${end_year} --bounds 0 0.75 --plot rcp_mass 2017_07_rcps/scalar/cumsum_ts_gris_g3600m_warming_v3a_no_bath_lapse_${lapse}_ps_${ps}_rcp_*_bd_off_calving_vonmises_calving_0_1000.nc
        end_year=3000
        /Volumes/79n/data/gris-analysis/plotting/plotting.py -o lapse_${lapse}_ps_${ps}_2009_${end_year} --title lapse_${lapse}_ps_${ps} --time_bounds 2009 ${end_year} --bounds 0 5 --plot rcp_mass 2017_07_rcps/scalar/cumsum_ts_gris_g3600m_warming_v3a_no_bath_lapse_${lapse}_ps_${ps}_rcp_*_bd_off_calving_vonmises_calving_0_1000.nc
    done
done

# FIX OF_ON/OF_OFF
ps=0.05
end_year=2100
/Volumes/79n/data/gris-analysis/plotting/plotting.py -o ps_${ps}_2009_${end_year} --title "\$\psi_w\$=${ps}" --time_bounds 2009 ${end_year} --bounds 0 0.25 --plot rcp_lapse_mass 2017_07_rcps/scalar/cumsum_ts_gris_g3600m_warming_v3a_no_bath_lapse_6_ps_0.05_rcp_*_bd_off_calving_vonmises_calving_of_on_0_1000.nc 2017_07_rcps/scalar/cumsum_ts_gris_g3600m_warming_v3a_no_bath_lapse_0_ps_0.05_rcp_*_bd_off_calving_vonmises_calving_0_1000.nc
end_year=2200
/Volumes/79n/data/gris-analysis/plotting/plotting.py -o ps_${ps}_2009_${end_year}  --title "\$\psi_w\$=${ps}" --time_bounds 2009 ${end_year} --bounds 0 1 --plot rcp_lapse_mass 2017_07_rcps/scalar/cumsum_ts_gris_g3600m_warming_v3a_no_bath_lapse_6_ps_0.05_rcp_*_bd_off_calving_vonmises_calving_of_on_0_1000.nc 2017_07_rcps/scalar/cumsum_ts_gris_g3600m_warming_v3a_no_bath_lapse_0_ps_0.05_rcp_*_bd_off_calving_vonmises_calving_0_1000.nc
end_year=3000
/Volumes/79n/data/gris-analysis/plotting/plotting.py -o ps_${ps}_2009_${end_year}  --title "\$\psi_w\$=${ps}" --time_bounds 2009 ${end_year} --bounds -0.1 7 --plot rcp_lapse_mass 2017_07_rcps/scalar/cumsum_ts_gris_g3600m_warming_v3a_no_bath_lapse_6_ps_0.05_rcp_*_bd_off_calving_vonmises_calving_of_on_0_1000.nc 2017_07_rcps/scalar/cumsum_ts_gris_g3600m_warming_v3a_no_bath_lapse_0_ps_0.05_rcp_*_bd_off_calving_vonmises_calving_0_1000.nc


cdo divc,1e12 -timmean -selyear,71/90 -selvar,surface_ice_flux ts_gris_g3600m_warming_v3a_no_bath_lapse_0_ps_0.05_rcp_45_bd_off_calving_vonmises_calving_0_1000.nc  ts_gris_g3600m_warming_v3a_no_bath_lapse_0_ps_0.05_rcp_45_bd_off_calving_vonmises_calving_2080-2100_mean.nc
cdo divc,1e12 -timmean -selyear,71/90 -selvar,surface_ice_flux ts_gris_g3600m_warming_v3a_no_bath_lapse_0_ps_0.05_rcp_85_bd_off_calving_vonmises_calving_0_1000.nc  ts_gris_g3600m_warming_v3a_no_bath_lapse_0_ps_0.05_rcp_85_bd_off_calving_vonmises_calving_2080-2100_mean.nc

for basin in CW NE NO NW SE SW; do
    for rcp in ctrl 26 45 85; do
        /Volumes/79n/data/gris-analysis/basins/extract_basins.py --o_dir ../basins --basins $basin ex_gris_g3600m_v3a_no_bath_lapse_6_ps_0_rcp_${rcp}_bd_off_calving_vonmises_calving_0_1000.nc       
    done
done
for basin in CW NE NO NW SE SW; do
    for rcp in 26 45 85; do
        /Volumes/79n/data/gris-analysis/basins/extract_basins.py --o_dir ../basins --basins $basin ex_gris_g3600m_v3a_no_bath_lapse_6_ps_0.05_rcp_${rcp}_bd_off_calving_vonmises_calving_0_1000.nc       
    done
done


for basin in CW NE NO NW SE SW; do
    for rcp in 26 45 85; do
        extract_interface.py --step 20 -t ice_ocean -o 2017_07_rcps_ps/ice_ocean/ice_ocean_g2400m_lapse_6_rcp_${rcp}_${basin}.shp 2017_07_rcps_ps/basins/b_${basin}_ex_gris_g2400m_warming_v3a_no_bath_lapse_6_ps_0.05_rcp_${rcp}_bd_off_calving_vonmises_calving_of_on_0_1000/b_${basin}_ex_gris_g2400m_warming_v3a_no_bath_lapse_6_ps_0.05_rcp_${rcp}_bd_off_calving_vonmises_calving_of_on_0_1000.nc
        dissolve_by_attribute.py -o  2017_07_rcps_ps/ice_ocean/ice_ocean_g2400m_lapse_6_rcp_${rcp}_${basin}_ds.shp  2017_07_rcps_ps/ice_ocean/ice_ocean_g2400m_lapse_6_rcp_${rcp}_${basin}.shp
    done
done



# Extract basins
for basin in CW NE NO NW SE SW; do
    for rcp in 26 45 85; do
        for lapse in 6; do
            /Volumes/79n/data/gris-analysis/basins/extract_basins.py --o_dir ../basins --basins $basin  ex_gris_g2400m_warming_v3a_no_bath_lapse_${lapse}_ps_0.05_rcp_${rcp}_bd_off_calving_vonmises_calving_of_on_0_1000.nc
        done
    done
done

~/base/pypismtools/scripts/extract_interface.py -o 2017_07_rcps_ps/ice_ocean/ice_ocean_g2400m_lapse_6_rcp_26_GRIS.shp  -t ice_ocean 2017_07_rcps_ps/spatial/ex_gris_g2400m_warming_v3a_no_bath_lapse_6_ps_0.05_rcp_26_bd_off_calving_vonmises_calving_of_on_0_1000.nc
dissolve_by_attribute.py -o 2017_07_rcps_ps/ice_ocean_g2400m_lapse_6_rcp_26_GRIS_ds.shp 2017_07_rcps_ps/ice_ocean_g2400m_lapse_6_rcp_26_GRIS.shp
~/base/pypismtools/scripts/extract_interface.py -o 2017_07_rcps_ps/ice_ocean/ice_ocean_g2400m_lapse_6_rcp_45_GRIS.shp  -t ice_ocean 2017_07_rcps_ps/spatial/ex_gris_g2400m_warming_v3a_no_bath_lapse_6_ps_0.05_rcp_45_bd_off_calving_vonmises_calving_of_on_0_1000.nc 
dissolve_by_attribute.py -o 2017_07_rcps_ps/ice_ocean_g2400m_lapse_6_rcp_45_GRIS_ds.shp 2017_07_rcps_ps/ice_ocean_g2400m_lapse_6_rcp_45_GRIS.shp
~/base/pypismtools/scripts/extract_interface.py -o 2017_07_rcps_ps/ice_ocean/ice_ocean_g2400m_lapse_6_rcp_85_GRIS.shp  -t ice_ocean 2017_07_rcps_ps/spatial/ex_gris_g2400m_warming_v3a_no_bath_lapse_6_ps_0.05_rcp_85_bd_off_calving_vonmises_calving_of_on_0_1000.nc 
dissolve_by_attribute.py -o 2017_07_rcps_ps/ice_ocean/ice_ocean_g2400m_lapse_6_rcp_85_GRIS_ds.shp 2017_07_rcps_ps/ice_ocean_g2400m_lapse_6_rcp_85_GRIS.shp

# Plot RCP mass
end_year=3000
 /Volumes/79n/data/gris-analysis/plotting/plotting.py -o lapse_6_2009_${end_year} --time_bounds 2009 ${end_year}  --plot rcp_mass 2017_07_rcps_ps/scalar/cumsum_ts_gris_g2400m_warming_v3a_no_bath_lapse_6_ps_0.05_rcp_*_bd_off_calving_vonmises_calving_of_on_0_1000.nc
# Plot RCP mass for two lapse rates
 /Volumes/79n/data/gris-analysis/plotting/plotting.py -o lapse_combined_2009_${end_year} --time_bounds 2009 ${end_year}  --plot rcp_lapse_mass 2017_07_rcps_ps/scalar/cumsum_ts_gris_g2400m_warming_v3a_no_bath_lapse_6_ps_0.05_rcp_*_bd_off_calving_vonmises_calving_of_on_0_1000.nc 2017_07_rcps_ps/scalar/cumsum_ts_gris_g2400m_warming_v3a_no_bath_lapse_0_ps_0.05_rcp_*_bd_off_calving_vonmises_calving_of_on_0_1000.nc

end_year=3000
ps=0.05
for rcp in 26 45 85; do
    /Volumes/79n/data/gris-analysis/plotting/plotting.py -o rcp_${rcp}_ps_${ps}_2009_${end_year} --title "RCP${rcp}" --time_bounds 2009 ${end_year}  --plot basin_discharge 2017_07_rcps_ps/basins/b_*_ex_gris_g2400m_warming_v3a_no_bath_lapse_6_ps_0.05_rcp_${rcp}_bd_off_calving_vonmises_calving_of_on_0_1000/scalar_fldsum_b_*_ex_gris_g2400m_warming_v3a_no_bath_lapse_6_ps_0.05_rcp_${rcp}_bd_off_calving_vonmises_calving_of_on_0_1000.nc
    /Volumes/79n/data/gris-analysis/plotting/plotting.py -o rcp_${rcp}_ps_${ps}_2009_${end_year} --title "RCP${rcp}" --time_bounds 2009 ${end_year}  --plot basin_mass_d 2017_07_rcps_ps/basins/b_*_ex_gris_g2400m_warming_v3a_no_bath_lapse_6_ps_0.05_rcp_${rcp}_bd_off_calving_vonmises_calving_of_on_0_1000/cumsum_b_*_ex_gris_g2400m_warming_v3a_no_bath_lapse_6_ps_0.05_rcp_${rcp}_bd_off_calving_vonmises_calving_of_on_0_1000.nc
done
  

# Basal enthalpy
grid=2400
mkdir -p 2017_07_rcps_ps/enth_base
python /Volumes/79n/data/gris-analysis/enth_base/extract_basal_enthalpy.py ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc  2017_07_rcps_ps/enth_base/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_of_on_0_100.nc
for rcp in ctrl 26 45 85; do
    python /Volumes/79n/data/gris-analysis/enth_base/extract_basal_enthalpy.py 2017_07_rcps_ps/state/gris_g${grid}m_warming_v3a_no_bath_lapse_6_ps_0.05_rcp_${rcp}_bd_off_calving_vonmises_calving_of_on_0_1000.nc 2017_07_rcps_ps/enth_base/gris_g${grid}m_warming_v3a_no_bath_lapse_6_ps_0.05_rcp_${rcp}_bd_off_calving_vonmises_calving_of_on_0_1000.nc
    cdo mulc,100 -div -sub 2017_07_rcps_ps/enth_base/gris_g${grid}m_warming_v3a_no_bath_lapse_6_ps_0.05_rcp_${rcp}_bd_off_calving_vonmises_calving_of_on_0_1000.nc 2017_07_rcps_ps/enth_base/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_of_on_0_100.nc 2017_07_rcps_ps/enth_base/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_of_on_0_100.nc 2017_07_rcps_ps/enth_base/gris_g${grid}m_warming_v3a_no_bath_lapse_6_ps_0.05_rcp_${rcp}_bd_off_calving_vonmises_calving_of_on_0_1000_rel_diff.nc
    gdal_translate -a_srs EPSG:3413 NETCDF:2017_07_rcps_ps/enth_base/gris_g${grid}m_warming_v3a_no_bath_lapse_6_ps_0.05_rcp_${rcp}_bd_off_calving_vonmises_calving_of_on_0_1000_rel_diff.nc:basal_enthalpy 2017_07_rcps_ps/enth_base/gris_g${grid}m_warming_v3a_no_bath_lapse_6_ps_0.05_rcp_${rcp}_bd_off_calving_vonmises_calving_of_on_0_1000_rel_diff.tif
done
