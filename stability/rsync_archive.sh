#!/bin/bash
#SBATCH --partition=transfer
#SBATCH --ntasks=1
#SBATCH --tasks-per-node=1
#SBATCH --time=24:00:00
#SBATCH --output=transfer.%j

cd $SLURM_SUBMIT_DIR

ulimit -l unlimited
ulimit -s unlimited
ulimit


count=0

rc=1

while [ $rc -gt 0 ]; do

  echo "Error counter: $count"

  rsync --progress -auvhr --delete /import/c1/ICESHEET/aaschwanden/pism-gris/stability/2017_12_ctrl_tmp /archive/u1/uaf/aaschwanden/pism-gris/stability
  rsync --progress -auvhr --delete /import/c1/ICESHEET/aaschwanden/pism-gris/stability/2017_12_ctrl /archive/u1/uaf/aaschwanden/pism-gris/stability
  rsync --progress -auvhr --delete /import/c1/ICESHEET/aaschwanden/pism-gris/stability/2017_12_les /archive/u1/uaf/aaschwanden/pism-gris/stability

  rc=$?

  ((count+=1))

done
