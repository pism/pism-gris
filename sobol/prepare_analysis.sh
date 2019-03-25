#!/bin/bash

var=limnsw
D=11

odir=$1
mkdir -p ${odir}/saltelli
mkdir -p ${odir}/sobol
mkdir -p ${odir}/${var}

echo "Running Sobol Analysis using $D parameters"
for N in 110 100 90 80 70 60 50 40 30 20 10; do
    echo "  Processing N=$N samples"
    # Number of Samples
    (( M = N * (D + 2)))
    # {000..M-1}
    (( MM = M - 1 ))
    python  ~/base/pism-gris/sobol/draw_samples.py -s ${N}  ${odir}/saltelli/saltelli_samples_${N}.csv
    echo "    Extracting ${var} from files 0..${MM}"
    python ~/base/pism-gris/sobol/nc2csv.py -t -1 -v ${var}  ${odir}/${var}/${var}_rcp_45_2100_${N}.csv ${odir}/scalar_clean/ts_gris_g1800m_v3a_rcp_45_id_{0..${MM}}_0_100.nc
    echo "    Calculating Sobol indices for ${var} from files 0..${MM}"
    python ~/base/pism-gris/sobol/sobol_analysis.py --o_dir ${odir}/sobol -s ${odir}/saltelli/saltelli_samples_${N}.csv ${odir}/${var}/${var}_rcp_45_2100_${N}.csv

done


python ~/base/pism-gris/sobol/show_convergence.py ${odir}/sobol/sobol-convergence.pdf ${odir}/sobol/limnsw_rcp_45_2100_*sobol.csv
