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

odir=2017_12_ocean
cd $odir/scalar
for file in ts_*; do
    echo $file
    ncks -O -4 -L 3 $file $file
done
cd ../state
for file in g*; do
    echo $file
    ncks -O -4 -L 3 $file $file
done
cd ..
cd ${odir}_tmp/
for file in *.nc; do
    echo $file
    ncks -O -4 -L 3 $file $file
done
cd ..
