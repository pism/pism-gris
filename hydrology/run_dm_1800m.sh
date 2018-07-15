#!/bin/sh
#SBATCH --partition=t2standard
#SBATCH --ntasks=120
#SBATCH --tasks-per-node=24
#SBATCH --time=64:00:00
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --output=pism.%j

module list

cd $SLURM_SUBMIT_DIR

# Generate a list of compute node hostnames reserved for this job,
# this ./nodes file is necessary for slurm to spawn mpi processes
# across multiple compute nodes
srun -l /bin/hostname | sort -n | awk '{print $2}' > ./nodes_$SLURM_JOBID

ulimit -l unlimited
ulimit -s unlimited
ulimit


# stop if a variable is not defined
set -u
# stop on errors
set -e

# path to the input directory (input data sets are contained in this directory)
input_dir="/import/c1/ICESHEET/aaschwanden/pism-gris"
# output directory
output_dir="//import/c1/ICESHEET/aaschwanden/pism-gris/hydrology/2018_05_routing"

# create required output directories
for each in $output_dir;
do
  mkdir -p $each
done

mpiexec -n 120 $HOME/pism-dev/bin/pismr \
        -i ../data_sets/bed_dem/pism_Greenland_1800m_mcb_jpl_v3a_ctrl.nc \
        -bootstrap \
        -Mz 3 \
        -time_file ../data_sets/hydrology/DMI-HIRHAM5_GL2_ERAI_1980_2014_MRROS_DM_EPSG3413_1800m_0.nc \
        -hydrology routing \
        -hydrology.tillwat_max 0 \
        -stress_balance none \
        -energy none \
        -hydrology.surface_input_file ../data_sets/hydrology/DMI-HIRHAM5_GL2_ERAI_1980_2014_MRROS_DM_EPSG3413_1800m_0.nc \
        -extra_times daily \
        -extra_vars bwat,tillwat,hydrology_fluxes,subglacial_water_input_rate \
        -extra_file $output_dir/ex_g1800m_water_routing_DMI-HIRHAM5_GL2_ERAI_1980_2014_dm.nc \
        -verbose 3 > $output_dir/job.$SLURM_JOBID 2>&1
