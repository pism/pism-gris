#!/bin/bash

odir=2018_08_les_sky2
s=electra_skylake
q=long
n=160
grid=1800

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_gcm.csv --spatial_ts none --o_dir ${odir} --exstep 1 -n ${n} -w 100:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

26, 036
26, 069
26, 092
26, 160
26, 236
26, 310
26, 383
26, 392
26, 421
26, 456
26, 458

rcp=26
for id in 036 069 092 160 236 310 383 392 421 56 458 ; do qsub /nobackupp8/aaschwan/pism-gris/stability/2018_08_les_sky2/run_scripts/lhs_g1800m_v3a_rcp_85_id_${id}_j.sh; done

45, 025
45, 069
45, 092
45, 109
45, 117
45, 128
45, 160
45, 306
45, 310
45, 328
45, 338
45, 392
45, 406
45, 432
45, 456
45, 487

rcp=45
for id in 025 069 092 109 117 128 160 306 310 328 338 392 406 432 456 487 ; do qsub /nobackupp8/aaschwan/pism-gris/stability/2018_08_les_sky2/run_scripts/lhs_g1800m_v3a_rcp_85_id_${id}_j.sh; done

 005
 014
 036
 059
 080
 128
 146
 147
 149
 160
 196
 198
 236
 269
 310
 338
 343
 383
 406
 409
 409
 410
 410
 415
 434

rcp=85
for id in  005 014 036 059 080 128 146 147 149 160 196 198 236 269 310 338 343 383 406 409 410 415 434 ; do qsub /nobackupp8/aaschwan/pism-gris/stability/2018_08_les_sky2/run_scripts/lhs_g1800m_v3a_rcp_85_id_${id}_j.sh; done


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

# final run

for id in 338; do qsub /nobackupp8/aaschwan/pism-gris/stability/2018_08_les_san/run_scripts/lhs_g1800m_v3a_rcp_45_id_${id}_j.sh; done


for id in {527..549}; do qsub /nobackupp8/aaschwan/pism-gris/stability/2018_08_les_san/run_scripts/lhs_g1800m_v3a_rcp_85_id_${id}_j.sh; done

for id in {474..499}; do qsub /nobackupp8/aaschwan/pism-gris/stability/2018_08_les_san/run_scripts/lhs_g1800m_v3a_rcp_85_id_${id}_j.sh; done

odir=2018_08_les_bro
s=pleiades_broadwell
q=long
n=168
grid=1800

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_gcm.csv --spatial_ts none --o_dir ${odir} --exstep 1 -n ${n} -w 100:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

for id in {330..349}; do qsub /nobackupp8/aaschwan/pism-gris/stability/2018_08_les_bro/run_scripts/lhs_g1800m_v3a_rcp_26_id_${id}_j.sh; done

for id in {362..379}; do qsub /nobackupp8/aaschwan/pism-gris/stability/2018_08_les_bro/run_scripts/lhs_g1800m_v3a_rcp_26_id_${id}_j.sh; done

for id in {580..599}; do qsub /nobackupp8/aaschwan/pism-gris/stability/2018_08_les_bro/run_scripts/lhs_g1800m_v3a_rcp_26_id_${id}_j.sh; done

# Final Runs
for id in 005 006 012 014 030 036 069 092 ; do qsub /nobackupp8/aaschwan/pism-gris/stability/2018_08_les_bro/run_scripts/lhs_g1800m_v3a_rcp_26_id_${id}_j.sh; done


odir=2018_08_les_chi
s=chinook
q=t2standard
n=168
grid=1800

./lhs_ensemble.py -e ../latin_hypercube/lhs_samples_gcm.csv --spatial_ts none --o_dir ${odir} --exstep 1 -n ${n} -w 80:00:00 -g ${grid} -s ${s} -q ${q} --step 1000 --duration 1000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc

for id in {550..599}; do sbatch /import/c1/ICESHEET/aaschwanden/pism-gris/stability/2018_08_les_chi/run_scripts/lhs_g1800m_v3a_rcp_85_id_${id}_j.sh; done

odir=2018_09_cc
s=chinook
q=t2standard
n=144
grid=1800

./cc_ensemble.py -e ../latin_hypercube/cc_control.csv --o_dir ${odir} --exstep 10 -n ${n} -w 160:00:00 -g ${grid} -s ${s} -q ${q} --step 5000 --duration 5000 ../calibration/2017_06_vc/state/gris_g${grid}m_flux_v3a_no_bath_sia_e_1.25_sia_n_3_ssa_n_3.25_ppq_0.6_tefo_0.02_calving_vonmises_calving_0_100.nc



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
