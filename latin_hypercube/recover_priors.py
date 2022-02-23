import xarray as xr
import numpy as np
import pandas as pd
import re
from glob import glob

data = {
    "id": [],
    "sia_e": [],
    "ssa_n": [],
    "pseudo_plastic_q": [],
    "till_effective_fraction_overburden": [],
    "topg_to_phi": [],
    "surface.pdd.factor_ice": [],
    "surface.pdd.factor_snow": [],
    "surface.pdd.refreeze": [],
    "atmosphere.precip_exponential_factor_for_temperature": [],
    "atmosphere_delta_T_file": [],
    "ocean_given_file": [],
    "thickness_calving_threshold_file": [],
    "calving.vonmises.sigma_max": [],
    "ocean.runoff_to_ocean_melt_power_alpha": [],
}

col_dict = {
    "sia_e": "SIAE",
    "ssa_n": "SSAN",
    "pseudo_plastic_q": "PPQ",
    "till_effective_fraction_overburden": "TEFO",
    "surface.pdd.factor_ice": "FICE",
    "surface.pdd.factor_snow": "FSNOW",
    "surface.pdd.refreeze": "RFR",
    "atmosphere.precip_exponential_factor_for_temperature": "PRS",
    "atmosphere_delta_T_file": "GCM",
    "ocean_given_file": "OCM",
    "thickness_calving_threshold_file": "TCT",
    "calving.vonmises.sigma_max": "VCM",
    "ocean.runoff_to_ocean_melt_power_alpha": "OCS",
}

gcm_dict = {
    0.0: "GISS-E2-H",
    1.0: "GISS-E2-R",
    2.0: "IPSL-CM5A-LR",
    3.0: "MPI-ESM-LR",
}

infiles = sorted(glob("*rcp_26_*100.nc"))
print(len(infiles))
for m_file in infiles:
    print(f"Processing {m_file}")
    ds = xr.open_dataset(m_file)
    cmd = ds.attrs["command"]

    for key, val in data.items():
        if key != "id":
            val = re.search(f"{key} +([^ ]+)", cmd).group(1)
            try:
                data[key].append(float(val))
            except:
                data[key].append(val)

    m_id = int(re.search("id_(.+?)_", m_file).group(1))

    data["id"].append(m_id)

print(len(data["id"]))
ttp = [item.split(",") for item in data["topg_to_phi"]]
data["PHIMIN"] = [float(item[0]) for item in ttp]
data["PHIMAX"] = [float(item[1]) for item in ttp]
data["ZMIN"] = [float(item[2]) for item in ttp]
data["ZMAX"] = [float(item[3]) for item in ttp]
df = pd.DataFrame.from_dict(data).drop(columns=["topg_to_phi"]).rename(columns=col_dict)

for col in [
    "FICE",
    "FSNOW",
]:
    df[col] *= 1000
df["VCM"] /= 1e6
df["PRS"] *= 100

df.replace(
    {
        "GCM": {
            "/import/c1/ICESHEET/ICESHEET/pism-gris/data_sets/climate_forcing/tas_Amon_GISS-E2-H_rcp26_r1i1p1_ym_anom_GRIS_0-5000.nc": 0.0,
            "/import/c1/ICESHEET/ICESHEET/pism-gris/data_sets/climate_forcing/tas_Amon_GISS-E2-R_rcp26_r1i1p1_ym_anom_GRIS_0-5000.nc": 1.0,
            "/import/c1/ICESHEET/ICESHEET/pism-gris/data_sets/climate_forcing/tas_Amon_IPSL-CM5A-LR_rcp26_r1i1p1_ym_anom_GRIS_0-5000.nc": 2.0,
            "/import/c1/ICESHEET/ICESHEET/pism-gris/data_sets/climate_forcing/tas_Amon_MPI-ESM-LR_rcp26_r1i1p1_ym_anom_GRIS_0-5000.nc": 3.0,
        },
        "OCS": {
            0.5: -1.0,
            0.54: 0.0,
            0.85: 1.0,
        },
        "OCM": {
            "/import/c1/ICESHEET/ICESHEET/pism-gris/data_sets/ocean_forcing/ocean_forcing_300myr_71n_10myr_80n.nc": -1.0,
            "/import/c1/ICESHEET/ICESHEET/pism-gris/data_sets/ocean_forcing/ocean_forcing_400myr_71n_20myr_80n.nc": 0.0,
            "/import/c1/ICESHEET/ICESHEET/pism-gris/data_sets/ocean_forcing/ocean_forcing_500myr_71n_30myr_80n.nc": 1.0,
        },
        "TCT": {
            "/import/c1/ICESHEET/ICESHEET/pism-gris/data_sets/ocean_forcing/tct_forcing_400myr_74n_50myr_76n.nc": -1.0,
            "/import/c1/ICESHEET/ICESHEET/pism-gris/data_sets/ocean_forcing/tct_forcing_500myr_74n_100myr_76n.nc": 0.0,
            "/import/c1/ICESHEET/ICESHEET/pism-gris/data_sets/ocean_forcing/tct_forcing_600myr_74n_150myr_76n.nc": 1.0,
        },
    },
    inplace=True,
)
df.to_csv("lhs_plus_mc_samples.csv", index=None)

print(len(df))
