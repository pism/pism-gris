#!/usr/bin/env python

import pylab as plt
import csv
import re
import numpy as np

# get IDs of failed runs
failed_ids = []
with open("files.txt", "r") as f:
    regexp = re.compile(r".+id_([0-9]+)")
    for line in f:
        match = re.match(regexp, line)
        failed_ids.append(int(match.group(1)))

# get parameters from the CSV file
headers = []
failed = []
all_runs = []

with open("lhs_samples_20171022.csv", "rb") as f:
    reader = csv.reader(f, skipinitialspace=True)

    for row in reader:

        # get parameter names
        if headers == []:
            headers = row
            headers[0] = "ID"
            continue

        ID = int(row[0])
        row = list(map(float, row))

        if failed_ids.count(ID) == 1:
            failed.append(row)

        all_runs.append(row)

# turn lists into NumPy arrays to simplify plotting
failed = np.array(failed)
all_runs = np.array(all_runs)

# check that we found all the failed runs
assert(len(failed_ids) == len(failed))

plt.figure(1)
plt.clf()

# number of parameters
N = len(headers) - 1


def array_range(a):
    return a.min(), a.max()


for r in range(1, N + 1):
    for c in range(1, N + 1):
        n = N * (r - 1) + c
        plt.subplot(N, N, n)
        x_min, x_max = array_range(all_runs[:, c])
        y_min, y_max = array_range(all_runs[:, r])
        plt.scatter(all_runs[:, c], all_runs[:, r], s=1)
        plt.scatter(failed[:, c], failed[:, r], s=4)
        plt.axis([x_min, x_max, y_min, y_max])

        plt.yticks([])
        if c == 1:
            plt.ylabel(headers[r])

        plt.xticks([])
        if r == N:
            plt.xlabel(headers[c])
plt.savefig('crashed.pdf')
plt.show()
