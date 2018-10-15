#!/usr/bin/env python

from argparse import ArgumentParser
import numpy as np


def input_filename(prefix, rcp, year):
    return '{prefix}_rcp{rcp}_{year}sobel.txt'.format(prefix=prefix, rcp=rcp, year=year)

def read_sobel_file(filename):

    data = np.loadtxt(filename, usecols=(1))
    return data


def sobel_table(ifiles):
    years = [2100, 2200, 2300, 3000]
    rcps = [26, 45, 85]

    result = []

    for rcp in rcps:
        for year in years:
            filename = input_filename(prefix, rcp, year)
            mdata = read_sobel_file(filename)
            result.append(mdata)

    table_row = ''
    for col in range(len(result)):
        table_row += ' & \\textbf{{{:2.0f}}}'.format(np.sum([result[col][0], result[col][3]]) * 100 )
    table_row += " \\\\"
    print(table_row)
    table_row = ''
    for col in range(len(result)):
        table_row += ' & \\textbf{{{:2.0f}}}'.format(np.sum([result[col][1], result[col][2], result[col][4]]) * 100 )
    table_row += " \\\\"
    print(table_row)
    table_row = ''
    for col in range(len(result)):
        table_row += ' & \\textbf{{{:2.0f}}}'.format(np.sum(result[col][5:9]) * 100 )
    table_row += " \\\\"
    print(table_row)
    table_row = ''
    for col in range(len(result)):
        table_row += ' & \\textbf{{{:2.0f}}}'.format(np.sum(result[col][9:11]) * 100 )
    table_row += " \\\\"
    print(table_row)
    result = np.transpose(result) * 100
    return result


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.description = "Generate tables for the paper"
    parser.add_argument("FILE", nargs='*')
    options = parser.parse_args()
    ifiles = options.FILE
    prefix = 'les_gcm'
    print("% Sobel Indices")
    labels = ['$\Delta T_{\\textrm{air}}$',
              '$f_{\\text{i}}$',
              '$f_{\\text{s}}$',
              '$\omega$',
              '$\psi$',
              '$\dot m^{\\text{o}}_{x}$',
              '$\dot m^{\\text{o}}_{t}$',
              '$h_{\\text{min}}$',
              '$\sigma_{\\text{max}}$',
              '$q$',
              '$E$']
    for k, row in enumerate(sobel_table(prefix)):
        table_row = labels[k]
        for x in row:
            table_row += " & " + "{:.0f}".format(x)
        table_row += " \\\\"
        print(table_row)
