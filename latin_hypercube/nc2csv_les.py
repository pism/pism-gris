#!/usr/bin/env python
# Copyright (C) 2019-21 Andy Aschwanden

import numpy as np
from netCDF4 import Dataset as NC
import os
import re
from glob import glob
import pandas as pd

infiles = glob(os.path.join("2018_09_les/scalar_clean", "ts_*.nc"))
start_year = 2008
norm_years = [2008, 2015]
idx_norm_years = [0, 7]


for (norm_year, idx_norm_year) in zip(norm_years, idx_norm_years):
    dfs = []
    for infile in infiles:
        print(f"Processing {infile}")
        if os.path.isfile(infile):
            nc = NC(infile)
            m_id = int(re.search("id_(.+?)_", infile).group(1))
            m_dx = int(re.search("gris_g(.+?)m", infile).group(1))
            m_rcp = int(re.search("rcp_(.+?)_", infile).group(1))
            m_m = np.squeeze(nc.variables["limnsw"][:]) / 1e12
            m_m -= m_m[idx_norm_year]
            m_dm = np.squeeze(nc.variables["tendency_of_ice_mass_glacierized"][:]) / 1e12
            m_dm -= m_dm[idx_norm_year]
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
                            np.repeat(m_dx, n).reshape(-1, 1),
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
                        "Resolution (m)",
                    ],
                )
            )

            nc.close()
    df = pd.concat(dfs)
    df.to_csv(f"aschwanden_et_al_2019_les_{norm_year}_norm.csv.gz", index=False)
