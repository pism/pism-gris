var=limnsw

odir=$1
mkdir -p ${odir}/dgmsl_csv


for rcp in 26 45 85; do

    for id in {0..292}; do
        year=$(( $id + 2009 ))
        python ~/base/pism-gris/latin_hypercube/nc2csv.py -t $id  -v ${var}  ${odir}/dgmsl_csv/dgmsl_rcp_${rcp}_year_${year}.csv ${odir}/dgmsl/dgmsl_ts_gris_g1800m_v3a_rcp_${rcp}_id_*_0_1000.nc

    done
done
