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

set +e

odir=2018_01_les
mkdir -p $odir/dgmsl
for grid in 1800; do
    for rcp in 26 45 85; do
        for year in 2100 2200 3000; do
            for id2 in `seq 0 4`; do
                for id1 in `seq 0 9`; do
                    for id in `seq 0 9`; do
                        cdo -L mulc,-1000 -divc,365 -divc,1e15 -selvar,limnsw -sub -selyear,$year $odir/scalar_pruned/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${id2}${id1}${id}_0_1000.nc -selyear,2008 $odir/scalar_pruned/ts_gris_g${grid}m_v3a_rcp_${rcp}_id_${id2}${id1}${id}_0_1000.nc $odir/dgmsl/dgms_g${grid}m_rcp_${rcp}_id_${id2}${id1}${id}_${year}.nc
                    done
                done
            done
        done
    done
done


# cd $odir/scalar
# for file in ts_*; do
#     echo $file
#     ncks -O -4 -L 3 $file $file
# done
# cd ../state
# for file in g*; do
#     echo $file
#     ncks -O -4 -L 3 $file $file
# done
# cd ..
