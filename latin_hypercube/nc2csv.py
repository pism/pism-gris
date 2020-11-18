#!/usr/bin/env python
# Copyright (C) 2019 Andy Aschwanden

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
import numpy as np
from netCDF4 import Dataset as NC
import os
import re
from glob import glob
import pandas as pd

# set up the option parser
parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.description = "Generating scripts for warming experiments."
parser.add_argument("-v", "--variable", dest="variable", help="Variable to read in. Default=limnsw", default="limnsw")

options = parser.parse_args()
infiles = glob(os.path.join("2018_09_les/scalar_clean", "ts_*.nc"))
start_year = 2008

dfs = []
for infile in infiles:
    print(f"Processing {infile}")
    if os.path.isfile(infile):
        nc = NC(infile)
        m_id = int(re.search("id_(.+?)_", infile).group(1))
        m_rcp = int(re.search("rcp_(.+?)_", infile).group(1))
        m_m = np.squeeze(nc.variables["limnsw"][:]) / 1e12
        m_m -= m_m[0]
        m_dm = np.squeeze(nc.variables["tendency_of_ice_mass_glacierized"][:]) / 1e12
        m_dm -= m_dm[0]
        m_smb = np.squeeze(nc.variables["tendency_of_ice_mass_due_to_surface_mass_balance"][:]) / 1e12
        m_d = np.squeeze(nc.variables["tendency_of_ice_mass_due_to_discharge"][:]) / 1e12
        n = len(m_m)
        m_years = start_year + np.linspace(0, n - 1, n)

        dfs.append(
            pd.DataFrame(
                data=np.hstack(
                    [
                        m_years.reshape(-1, 1),
                        m_m.reshape(-1, 1),
                        m_dm.reshape(-1, 1),
                        m_smb.reshape(-1, 1),
                        m_d.reshape(-1, 1),
                        np.repeat(m_id, n).reshape(-1, 1),
                        np.repeat(m_rcp, n).reshape(-1, 1),
                    ]
                ),
                columns=[
                    "Year",
                    "Mass (Gt)",
                    "Mass change (Gt/yr)",
                    "SMB (Gt/yr)",
                    "D (Gt/yr)",
                    "Experiment",
                    "RCP",
                ],
            )
        )

        nc.close()
df = pd.concat(dfs)
df.to_csv("aschwanden_et_al_2019_les.gz", index=False)
