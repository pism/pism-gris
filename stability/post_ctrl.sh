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
odir=2017_12_ctrl

mkdir -p ${odir}/contrib
grid=900
for rcp in 26 45 85; do
    cdo -L aexpr,"d_contrib=tendency_of_ice_mass*(tendency_of_ice_mass_due_to_discharge/(tendency_of_ice_mass_due_to_discharge+surface_runoff_rate))" -timcumsum ${odir}/scalar/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc ${odir}/contrib/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_CTRL_0_1000.nc
done

exit

cd ${odir}_tmp/
for file in *.nc; do
    echo $file
    ncks -O -4 -L 3 $file $file
done
cd ..
