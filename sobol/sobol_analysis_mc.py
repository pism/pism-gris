import numpy as np
import pandas as pd
import pylab as plt
from pandas.api.types import is_string_dtype
from SALib.analyze import delta

m_var = "Mass (Gt)"
response_df = pd.read_csv(
    "/Users/andy/base/pism-emulator/data/as19/aschwanden_et_al_2019_mc_2008_norm.csv.gz"
).rename(columns={"Experiment": "id"})
id_df = pd.read_csv(
    "/Users/andy/base/pism-emulator/data/samples/lhs_plus_mc_samples.csv"
)
param_names = id_df.drop(columns="id").columns.values.tolist()
for k, col in id_df.iteritems():
    if is_string_dtype(col):
        u = col.unique()
        u.sort()
        v = [k for k, v in enumerate(u)]
        col.replace(to_replace=dict(zip(u, v)), inplace=True)
        # Define a salib "problem"
problem = {
    "num_vars": len(id_df.drop(columns="id").columns.values),
    "names": param_names,  # Parameter names
    "bounds": zip(
        id_df.drop(columns="id").min().values,
        id_df.drop(columns="id").max().values,
    ),  # Parameter bounds
}


def analyze(data):
    m_date = data["m_date"]
    s_df = data["s_df"]
    id_df = data["id_df"]
    print(f"Processing {m_date}")
    missing_ids = list(set(id_df["id"]).difference(s_df["id"]))
    if missing_ids:
        print("The following simulation ids are missing:\n   {}".format(missing_ids))

        id_df_missing_removed = id_df[~id_df["id"].isin(missing_ids)]
        id_df_missing = id_df[id_df["id"].isin(missing_ids)]
        params = np.array(
            id_df_missing_removed.drop(columns="id").values, dtype=np.float32
        )
        s_r_df = s_df[~s_df["id"].isin(missing_ids)]
        response_matrix = s_r_df[m_var].values
    else:

        params = np.array(id_df.drop(columns="id").values, dtype=np.float32)
        response_matrix = s_df[m_var].values

    Si = delta.analyze(
        problem,
        params,
        response_matrix,
        num_resamples=100,
        print_to_console=False,
    )
    sobol_indices = ["delta", "S1"]
    Si_df = Si.to_df()

    s_dfs = []
    for s_index in sobol_indices:
        m_df = pd.DataFrame(
            data=Si_df[s_index].values.reshape(1, -1),
            columns=Si_df.transpose().columns,
        )
        m_df["Date"] = m_date
        m_df.set_index("Date")
        m_df["Si"] = s_index

        m_conf_df = pd.DataFrame(
            data=Si_df[s_index + "_conf"].values.reshape(1, -1),
            columns=Si_df.transpose().columns,
        )
        m_conf_df["Date"] = m_date
        m_conf_df.set_index("Date")
        m_conf_df["Si"] = s_index + "_conf"
        s_dfs.append(pd.concat([m_df, m_conf_df]))
    s_df = pd.concat(s_dfs)
    Sobol_dfs.append(s_df)


df = pd.merge(id_df, response_df, on="id")
df = df[(df["Year"] > 2008) & (df["Year"] < 2101)]
all_sobol_dfs = []
for rcp in [26, 45, 85]:
    Sobol_dfs = []
    for m_date, s_df in df[df["RCP"] == rcp].groupby(by="Year"):
        print(f"Processing {m_date}")
        missing_ids = list(set(id_df["id"]).difference(s_df["id"]))
        if missing_ids:
            print(
                "The following simulation ids are missing:\n   {}".format(missing_ids)
            )

            id_df_missing_removed = id_df[~id_df["id"].isin(missing_ids)]
            id_df_missing = id_df[id_df["id"].isin(missing_ids)]
            params = np.array(
                id_df_missing_removed.drop(columns="id").values, dtype=np.float32
            )
            s_r_df = s_df[~s_df["id"].isin(missing_ids)]
            response_matrix = s_r_df[m_var].values
        else:

            params = np.array(id_df.drop(columns="id").values, dtype=np.float32)
            response_matrix = s_df[m_var].values

        Si = delta.analyze(
            problem,
            params,
            response_matrix,
            num_resamples=100,
            print_to_console=False,
        )
        sobol_indices = ["delta", "S1"]
        Si_df = Si.to_df()

        s_dfs = []
        for s_index in sobol_indices:
            m_df = pd.DataFrame(
                data=Si_df[s_index].values.reshape(1, -1),
                columns=Si_df.transpose().columns,
            )
            m_df["Date"] = m_date
            m_df.set_index("Date")
            m_df["Si"] = s_index

            m_conf_df = pd.DataFrame(
                data=Si_df[s_index + "_conf"].values.reshape(1, -1),
                columns=Si_df.transpose().columns,
            )
            m_conf_df["Date"] = m_date
            m_conf_df.set_index("Date")
            m_conf_df["Si"] = s_index + "_conf"
            s_dfs.append(pd.concat([m_df, m_conf_df]))
        s_df = pd.concat(s_dfs)
        Sobol_dfs.append(s_df)

    Sobol_df = pd.concat(Sobol_dfs)
    Sobol_df.reset_index(inplace=True, drop=True)
    Sobol_df["RCP"] = rcp
    all_sobol_dfs.append(Sobol_df)
sobol_df = pd.concat(all_sobol_dfs)
sobol_df = sobol_df.reset_index(drop=True)

category_dict = {
    "Climate": {"color": "#81c77f", "vars": ["GCM", "PRS"]},
    "Surface": {"color": "#886c62", "vars": ["FSNOW", "FICE", "RFR"]},
    "Ocean": {"color": "#beaed4", "vars": ["VCM", "OCS", "OCM", "TCT"]},
    "Ice Dynamics": {
        "color": "#dcd588",
        "vars": ["PHIMIN", "PHIMAX", "ZMIN", "ZMAX", "SIAE", "SSAN", "PPQ", "TEFO"],
    },
}


fig, axs = plt.subplots(
    3,
    1,
    sharex="col",
    figsize=[24.0, 10],
)
fig.subplots_adjust(hspace=0.2, wspace=0.05)
k = 0
for rcp, m_df in sobol_df.groupby(by="RCP"):
    m_df = m_df[m_df["Si"] == "S1"]
    for key in category_dict.keys():
        m_df[key] = m_df[category_dict[key]["vars"]].sum(axis=1)
        # axs[k].bar(m_df["Date"], m_df[key], color=category_dict[key]["color"], label=key)
    m_cols = list(category_dict.keys())
    m_cols.append("Date")
    df = m_df[m_cols]
    df.set_index("Date").plot(
        kind="bar",
        stacked=True,
        ax=axs[k],
        color=[category_dict[key]["color"] for key in category_dict.keys()],
    )
    axs[k].set_title(rcp)
    k += 1
fig.savefig("sobol_ts.pdf")
