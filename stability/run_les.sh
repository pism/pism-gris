#!/bin/bash

odir=2018_09_ctrl
s=chinook
q=t2standard
n=120
grid=600

./jib.py -e lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 80:00:00 -g ${grid} -s ${s} -q ${q} --step 100 --duration 100 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

odir=2018_08_les_sky
s=electra_skylake
q=long
n=160
grid=1800

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_gcm.csv --spatial_ts none --o_dir ${odir} --exstep 1 -n ${n} -w 80:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

for id in {425..450}; do qsub /nobackupp8/aaschwan/pism-gris/stability/2018_08_les_sky/run_scripts/lhs_g1800m_v3a_rcp_85_id_${id}_j.sh; done

odir=2018_08_les_san
s=pleiades_sandy
q=long
n=160
grid=1800

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_gcm.csv --spatial_ts none --o_dir ${odir} --exstep 1 -n ${n} -w 80:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

for id in {450..499}; do qsub /nobackupp8/aaschwan/pism-gris/stability/2018_08_les_san/run_scripts/lhs_g1800m_v3a_rcp_45_id_${id}_j.sh; done

for id in {590..599}; do qsub /nobackupp8/aaschwan/pism-gris/stability/2018_08_les_san/run_scripts/lhs_g1800m_v3a_rcp_45_id_${id}_j.sh; done



for id in {527..549}; do qsub /nobackupp8/aaschwan/pism-gris/stability/2018_08_les_san/run_scripts/lhs_g1800m_v3a_rcp_85_id_${id}_j.sh; done

for id in {470..499}; do qsub /nobackupp8/aaschwan/pism-gris/stability/2018_08_les_san/run_scripts/lhs_g1800m_v3a_rcp_85_id_${id}_j.sh; done

odir=2018_08_les_bro
s=pleiades_broadwell
q=long
n=168
grid=1800

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_gcm.csv --spatial_ts none --o_dir ${odir} --exstep 1 -n ${n} -w 80:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

for id in {330..349}; do qsub /nobackupp8/aaschwan/pism-gris/stability/2018_08_les_bro/run_scripts/lhs_g1800m_v3a_rcp_26_id_${id}_j.sh; done

for id in {362..379}; do qsub /nobackupp8/aaschwan/pism-gris/stability/2018_08_les_bro/run_scripts/lhs_g1800m_v3a_rcp_26_id_${id}_j.sh; done

for id in {580..599}; do qsub /nobackupp8/aaschwan/pism-gris/stability/2018_08_les_bro/run_scripts/lhs_g1800m_v3a_rcp_26_id_${id}_j.sh; done


odir=2018_08_les_chi
s=chinook
q=t2standard
n=168
grid=1800

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_gcm.csv --spatial_ts none --o_dir ${odir} --exstep 1 -n ${n} -w 80:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

for id in {550..599}; do sbatch /import/c1/ICESHEET/aaschwanden/pism-gris/stability/2018_08_les_chi/run_scripts/lhs_g1800m_v3a_rcp_85_id_${id}_j.sh; done




odir=2018_08_ctrl
s=chinook
q=t2standard
n=360
grid=900

./lhs_ensemble.py -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 150:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

odir=2018_08_ctrl
s=chinook
q=t2standard
n=360
grid=900

./lhs_ensemble.py --spatial_ts none -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 100:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 5000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


odir=2018_08_ctrl
s=pleiades_broadwell
q=long
n=420
grid=900

./lhs_ensemble.py  -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 100:00:00 -g ${grid} -s ${s} -q ${q} --step 500 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

./lhs_ensemble.py --spatial_ts none -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 100:00:00 -g ${grid} -s ${s} -q ${q} --step 500 --duration 5000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_batqqh_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

odir=2018_08_ctrl
s=pleiades_ivy
q=normal
n=10
grid=18000

./lhs_ensemble.py --spatial_ts none -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 1:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


odir=2018_08_ctrl
s=chinook
q=t2small
n=12
grid=18000

./lhs_ensemble.py  -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 1:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


odir=2018_08_ctrl
s=pleiades_ivy
q=normal
n=20
grid=9000

./lhs_ensemble.py --spatial_ts none -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 1:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


odir=2018_08_ctrl
s=pleiades_ivy
q=normal
n=40
grid=4500

./lhs_ensemble.py --spatial_ts none -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 6:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

odir=2018_08_ctrl
s=pleiades_ivy
q=long
n=80
grid=3600

./lhs_ensemble.py --spatial_ts none -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 10:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

odir=2018_08_ctrl
s=pleiades_ivy
q=long
n=140
grid=1800

./lhs_ensemble.py --spatial_ts none -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 36:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


odir=2018_08_ctrl
s=pleiades_broadwell
q=long
n=560
grid=600

./lhs_ensemble.py -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 80:00:00 -g ${grid} -s ${s} -q ${q} --step 200 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

odir=2018_08_ctrl
s=chinook
q=t2standard
n=576
grid=600

./lhs_ensemble.py -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 100:00:00 -g ${grid} -s ${s} -q ${q} --step 100 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


odir=2018_08_ctrl
s=pleiades_broadwell
q=long
n=1120
grid=450

./lhs_ensemble.py -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 100:00:00 -g ${grid} -s ${s} -q ${q} --step 100 --duration 500 ../calibration/2017_06_vc/state/gris_g600m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

odir=2018_08_ctrl
s=chinook
q=t2standard
n=1200
grid=450

./lhs_ensemble.py -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 160:00:00 -g ${grid} -s ${s} -q ${q} --step 100 --duration 1000 ../calibration/2017_06_vc/state/gris_g600m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


################################3
# INITIALIZATION
################################3

odir=2017_06_vc
s=pleiades_ivy
q=long
n=80
grid=3600

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_20171104.csv --spatial_ts none --o_dir ${odir} --exstep 1 -n ${n} -w 10:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc
