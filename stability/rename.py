import os

try:
    import subprocess32 as sub
except:
    import subprocess as sub
import shlex

odir = "2019_02_salt"

for m_file in os.listdir(os.path.join(odir, "scalar_pruned")):
    m_file_split = m_file.split("_")
    id = int(m_file_split[-3])
    m_file_split[-3] = str(id)
    o_file = "_".join([x for x in m_file_split])
    ifile = os.path.join(odir, "scalar_pruned", m_file)
    ofile = os.path.join(odir, "scalar_clean", o_file)
    if not os.path.isfile(ofile):
        print(ifile, ofile)
        cmd = "cdo -O seltimestep,1/100 -selvar,tendency*,surface*,li*,ice_*,dt,basal* {} {}".format(ifile, ofile)
        sub.call(shlex.split(cmd))
        cmd = "adjust_timeline.py -i start -p yearly -a 2008-1-1 -u seconds -d 2008-1-1 {}".format(ofile)
        sub.call(shlex.split(cmd))
