#!/usr/bin/env python

from argparse import ArgumentParser
import numpy as np


def input_filename(prefix, rcp, year):
    return "{prefix}_rcp{rcp}_{year}sobel.txt".format(prefix=prefix, rcp=rcp, year=year)


def read_sobel_file(filename):
    data = np.loadtxt(filename, usecols=(1))
    return data


def sobel_table(ifiles):

    result = []

    for rcp in rcps:
        for year in years:
            filename = input_filename(prefix, rcp, year)
            mdata = read_sobel_file(filename)
            result.append(mdata)

    table_row = ""
    for col in range(len(result)):
        atmosphere = np.sum([result[col][0], result[col][3]]) * 100
        table_row += " & \\textbf{{{:2.0f}}}".format(atmosphere)
    table_row += " \\\\"
    print(table_row)
    table_row = ""
    for col in range(len(result)):
        surface = np.sum([result[col][1], result[col][2], result[col][4]]) * 100
        table_row += " & \\textbf{{{:2.0f}}}".format(surface)
    table_row += " \\\\"
    print(table_row)
    table_row = ""
    for col in range(len(result)):
        ocean = np.sum(result[col][5:9]) * 100
        table_row += " & \\textbf{{{:2.0f}}}".format(ocean)
    table_row += " \\\\"
    print(table_row)
    table_row = ""
    for col in range(len(result)):
        internal = np.sum(result[col][9:11]) * 100
        table_row += " & \\textbf{{{:2.0f}}}".format(internal)
    table_row += " \\\\"
    print(table_row)
    result = np.transpose(result) * 100
    return result


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.description = "Generate tables for the paper"
    parser.add_argument("FILE", nargs="*")
    options = parser.parse_args()
    ifiles = options.FILE
    prefix = "les_gcm"
    print("% Sobel Indices")
    labels = [
        "$\Delta T_{\\textrm{air}}$",
        "$f_{\\text{i}}$",
        "$f_{\\text{s}}$",
        "$\omega$",
        "$\psi$",
        "$\dot m^{\\text{o}}_{x}$",
        "$\dot m^{\\text{o}}_{t}$",
        "$h_{\\text{min}}$",
        "$\sigma_{\\text{max}}$",
        "$q$",
        "$E$",
    ]

    years = [2100, 2200, 2300, 3000]
    rcps = [26, 45, 85]

    for k, row in enumerate(sobel_table(prefix)):
        table_row = labels[k]
        for x in row:
            table_row += " & " + "{:.0f}".format(x)
        table_row += " \\\\"
        print(table_row)

    result = sobel_table(prefix)
    climate = result[0] + result[3]
    surface = result[1] + result[2] + result[4]
    ocean = result[5] + result[6] + result[7] + result[8]
    ice = result[9] + result[10]

    import pylab as plt
    for m, rcp in enumerate(rcps):
        for n, year in enumerate(years):
            k = m + n
            fig = plt.figure()
            ax = fig.add_subplot(111)
            ax.bar(np.array([0, 1, 2, 3]) * 4, np.array([climate[k], surface[k], ocean[k], ice[k]]), width=3.8, color=["#81c77f", "#886c62", "#beaed4", "#dcd588"], edgecolor='k')
            plt.axis('off')
            ax.get_xaxis().set_visible(False)
            ax.get_yaxis().set_visible(False)
            ax.set_aspect('equal', 'datalim')
            fig.savefig("bar_rcp{}_{}.pdf".format(rcp, year), bbox_inches='tight')
