#!/bin/bash

16.9.18: 9:00
rcp26: 000..349
rcp26: 400..499


rcp45: 000..399
rcp45: 400..499
rcp85: 000..499

odir=2018_09_les
s=electra_skylake
q=long
n=160
grid=1800

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_gcm.csv --spatial_ts none --o_dir ${odir} --exstep 1 -n ${n} -w 60:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


rcp=26
for id in {350..399} ; do qsub /nobackupp8/aaschwan/pism-gris/stability/${odir}/run_scripts/lhs_g1800m_v3a_rcp_${rcp}_id_${id}_j.sh; done

for id in {200..299} ; do qsub /nobackupp8/aaschwan/pism-gris/stability/${odir}/run_scripts/lhs_g1800m_v3a_rcp_${rcp}_id_${id}_j.sh; done

rcp=45
for id in {000..099} ; do qsub /nobackupp8/aaschwan/pism-gris/stability/${odir}/run_scripts/lhs_g1800m_v3a_rcp_${rcp}_id_${id}_j.sh; done

for id in {150..199} ; do qsub /nobackupp8/aaschwan/pism-gris/stability/${odir}/run_scripts/lhs_g1800m_v3a_rcp_${rcp}_id_${id}_j.sh; done


odir=2018_09_les
s=pleiades_ivy
q=long
n=160
grid=1800

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_gcm.csv --spatial_ts none --o_dir ${odir} --exstep 1 -n ${n} -w 100:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

rcp=26
#for id in {350..399} ; do qsub /nobackupp8/aaschwan/pism-gris/stability/${odir}/run_scripts/lhs_g1800m_v3a_rcp_${rcp}_id_${id}_j.sh; done

for id in {400..499} ; do qsub /nobackupp8/aaschwan/pism-gris/stability/${odir}/run_scripts/lhs_g1800m_v3a_rcp_${rcp}_id_${id}_j.sh; done

rcp=45
for id in {350..399} ; do qsub /nobackupp8/aaschwan/pism-gris/stability/${odir}/run_scripts/lhs_g1800m_v3a_rcp_${rcp}_id_${id}_j.sh; done


rcp=85
for id in {450..499} ; do qsub /nobackupp8/aaschwan/pism-gris/stability/${odir}/run_scripts/lhs_g1800m_v3a_rcp_${rcp}_id_${id}_j.sh; done



odir=2018_09_les
s=pleiades_broadwell
q=long
n=168
grid=1800

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_gcm.csv --spatial_ts none --o_dir ${odir} --exstep 1 -n ${n} -w 100:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

rcp=85
for id in {100..149} ; do qsub /nobackupp8/aaschwan/pism-gris/stability/${odir}/run_scripts/lhs_g1800m_v3a_rcp_${rcp}_id_${id}_j.sh; done


odir=2018_09_les
s=pleiades_ivy
q=long
n=160
grid=1800

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_gcm.csv --spatial_ts none --o_dir ${odir} --exstep 1 -n ${n} -w 100:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

rcp=85
for id in {400..499} ; do qsub /nobackupp8/aaschwan/pism-gris/stability/${odir}/run_scripts/lhs_g1800m_v3a_rcp_${rcp}_id_${id}_j.sh; done

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

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_gcm.csv --spatial_ts none --o_dir ${odir} --exstep 1 -n ${n} -w 100:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

for id in {500..539}; do qsub /nobackupp8/aaschwan/pism-gris/stability/2018_08_les_san/run_scripts/lhs_g1800m_v3a_rcp_45_id_${id}_j.sh; done

for id in {450..499}; do qsub /nobackupp8/aaschwan/pism-gris/stability/2018_08_les_san/run_scripts/lhs_g1800m_v3a_rcp_45_id_${id}_j.sh; done



odir=2018_09_les_chi
s=chinook
q=t2standard
n=168
grid=1800

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_gcm.csv --spatial_ts none --o_dir ${odir} --exstep 1 -n ${n} -w 80:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

rcp=26
for id in {400..449}; do sbatch /import/c1/ICESHEET/aaschwanden/pism-gris/stability/2018_09_les_chi/run_scripts/lhs_g1800m_v3a_rcp_26_id_${id}_j.sh; done

odir=2018_09_cc_stable
s=chinook
q=t2standard
n=144
grid=1800

./cc_ensemble.py -e ../latin_hypercube/cc_control.csv --o_dir ${odir} --exstep 10 -n ${n} -w 160:00:00 -g ${grid} -s ${s} -q ${q} --step 5000 --duration 5000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

odir=2018_09_cc_stable
s=chinook
q=t2standard
n=192
grid=1500

./cc_ensemble.py -e ../latin_hypercube/cc_control.csv --o_dir ${odir} --exstep monthly -n ${n} -w 160:00:00 -g ${grid} -s ${s} -q ${q} --step 5000 --duration 5000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc



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
s=chinook
q=t2standard
n=360
grid=900

./lhs_ensemble.py --spatial_ts none -e ../latin_hypercube/lhs_control.csv --o_dir ${odir} --exstep 1 -n ${n} -w 160:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 5000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc


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


# Walltime
4615660: rcp45_id_34??
