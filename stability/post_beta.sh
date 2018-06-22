#!/bin/bash
#SBATCH --partition=analysis
#SBATCH --ntasks=1
#SBATCH --tasks-per-node=1
#SBATCH --time=48:00:00
#SBATCH --output=pism.%j
#SBATCH --mem=214G

cd $SLURM_SUBMIT_DIR

ulimit -l unlimited
ulimit -s unlimited
ulimit


# stop if a variable is not defined
set -u
# stop on errors
set -e
set -x

# Extract "beta" field from select years, convert to GTiff and extract contours

odir=2018_05_ctrl
mkdir -p ${odir}/beta
grid=900
basin=CW
for rcp in 85; do
    for year in 2008 2100 2200 2500; do
        cdo -L divc,1e9 -selvar,beta,thk -selyear,$year ${odir}/basins/b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_2000/b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_2000.nc ${odir}/beta/beta_b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.nc
        ncap2 -O -s "where(thk<1e-8) beta=1.e20;"  ${odir}/beta/beta_b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.nc  ${odir}/beta/beta_b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.nc
        gdal_translate -a_nodata 1.e20 NETCDF:${odir}/beta/beta_b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.nc:beta ${odir}/beta/beta_b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.tif
        gdal_contour -a beta -fl 10 100 1000 10000 100000 250000 ${odir}/beta/beta_b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.tif ${odir}/beta/beta_b_${basin}_ex_g${grid}m_v3a_rcp_${rcp}_id_CTRL_${year}.shp 
    done
done

