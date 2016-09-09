#!/bin/bash

for file in gris_ext_g*00m_straight_paleo_v2_ctrl_ppq_0.33_tefo_0.02_bed_deformation_*.nc; do

    extract_sigma_levels.py $file processed_age/iso_$file
    cdo remapbil,Greenland_age_grid_cdo.nc processed_age/iso_$file processed_age/age_grid_iso_$file 
done

