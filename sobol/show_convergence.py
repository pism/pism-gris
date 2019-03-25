#!/usr/bin/env python
# (c) 2018-19 Doug Brinkerhoff, Andy Aschwanden

from argparse import ArgumentParser
import numpy as np
import pandas as pd
import pylab as plt

parser = ArgumentParser()
parser.description = "Calculate sobel indices"
parser.add_argument("OUTFILE", nargs=1)
parser.add_argument("FILE", nargs="*")
options = parser.parse_args()
outfile = options.OUTFILE[-1]
files = options.FILE

fig = plt.figure()
ax = fig.add_subplot(111)

colors = [
    "#a6cee3",
    "#1f78b4",
    "#b2df8a",
    "#33a02c",
    "#fb9a99",
    "#e31a1c",
    "#fdbf6f",
    "#ff7f00",
    "#cab2d6",
    "#6a3d9a",
    "#ffff99",
]

for m_file in files:
    n = int(m_file.split("_")[-2])
    m_df = pd.read_csv(m_file, delimiter=" ", squeeze=True)
    handles = []
    for k in range(len(m_df["S1"].values)):
        l = ax.errorbar(
            n,
            float(m_df["S1"].values[k]),
            yerr=float(m_df["S1_conf"].values[k]),
            fmt="o",
            capsize=2,
            capthick=0.4,
            color=colors[k],
            linewidth=0.4,
            markersize=2,
            label=m_df["Parameter"][k],
        )
        handles.append(l)

legend = ax.legend(handles=handles, loc="upper right", edgecolor="0", ncol=3)
legend.get_frame().set_linewidth(0.0)
legend.get_frame().set_alpha(0.0)

D = len(m_df["Parameter"])

# ax.set_xlim(0, 100)

# xmin, xmax = ax.get_xlim()
# axn = ax.twiny()
# ax.set_autoscalex_on(False)
# axn.set_autoscalex_on(False)
# axn.set_xlim(xmin * (D - 2), xmax * (D - 2))

ax.set_xlabel("Number of Samples (1)")
ax.set_ylabel("Variance (1)")
fig.savefig(outfile)
