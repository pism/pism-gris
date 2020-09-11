#!/bin/bash
#SBATCH --partition=t2small
#SBATCH --ntasks=28
#SBATCH --tasks-per-node=28
#SBATCH --time=6:00:00
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --output=gp-loo.%j

umask 007

cd $SLURM_SUBMIT_DIR

ulimit -l unlimited
ulimit -s unlimited
ulimit

module purge
module load slurm
module load lang/Python/3.5.2-pic-intel-2016b

rcp=$1
year=$2
kernel=$3

module purge
module load slurm
module load lang/Python/3.5.2-pic-intel-2016b

python ../latin_hypercube/gp-loo.py -n 28 --rcp ${rcp} --year ${year} --kernel ${kernel} -s 2018_09_les/lhs_samples_gcm.csv 2018_09_les/dgmsl_csv/
