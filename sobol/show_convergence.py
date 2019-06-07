#!/usr/bin/env python
# (c) 2018-19 Doug Brinkerhoff, Andy Aschwanden

from argparse import ArgumentParser
import numpy as np
import pandas as pd
import pylab as plt


def set_size(w, h, ax=None):
    """ w, h: width, height in inches """

    if not ax:
        ax = plt.gca()
    l = ax.figure.subplotpars.left
    r = ax.figure.subplotpars.right
    t = ax.figure.subplotpars.top
    b = ax.figure.subplotpars.bottom
    figw = float(w) / (r - l)
    figh = float(h) / (t - b)
    ax.figure.set_size_inches(figw, figh)


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


ns = []
for m_file in files:
    n = int(m_file.split("_")[-2])
    ns.append(n)
    m_df = pd.read_csv(m_file, delimiter=" ", squeeze=True)
    D = len(m_df["Parameter"])
    handles = []
    #    for k in range(len(m_df["S1"].values)):
    for k in range(1, 3):
        l = ax.errorbar(
            n * (D - 2),
            float(m_df["S1"].values[k]),
            yerr=float(m_df["S1_conf"].values[k]),
            fmt="o",
            capsize=3,
            capthick=0.4,
            color=colors[k],
            linewidth=0.5,
            markersize=3,
            label=m_df["Parameter"][k],
        )
        handles.append(l)

legend = ax.legend(handles=handles, loc="upper right", edgecolor="0", ncol=3)
legend.get_frame().set_linewidth(0.0)
legend.get_frame().set_alpha(0.0)


ax.set_xlabel("Number of Samples (1)")
ax.set_ylabel("Variance (1)")

set_size(4.5, 3)

fig.savefig(outfile)
