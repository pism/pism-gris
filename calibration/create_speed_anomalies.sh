#!/bin/bash

odir=2019_12_calib

rm  ${odir}/speed/v_merged.nc  ${odir}/speed/v_anom.nc
# Merge files
cdo -O -f nc4 -z zip_3 mergetime ${odir}/speed/velsurf_mag_g*.nc  ${odir}/speed/v_merged.nc
# Create anomalies
cdo -O -f nc4 -z zip_3 setmisstoc,0 -sub ${odir}/speed/v_merged.nc -timmean ${odir}/speed/v_merged.nc ${odir}/speed/v_anom.nc
