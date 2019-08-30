#!/usr/bin/env python
# Copyright (C) 2019 Andy Aschwanden

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
from braceexpand import braceexpand
import numpy as np
from netCDF4 import Dataset as NC
import os
import re
import pandas as pd
from pathlib import Path
from io import StringIO

ugids_names = StringIO(
    """
UGID,Name
0,Umiammakku Isbræ
1,Unnamed Vestfjord S
2,Rink Isbræ
3,Kangerlussuup Sermersua
4,
5,Sermeq Silarleq
6,
7,Lille Gletscher
8,Store Gletscher
9,Sermeq Avannarleq
10,Usulluup Sermia
11,Inuppaat Quuat
12,Kangiata Nunaata Sermia
13,Narsap Sermia
14,Akullersuup Sermia
15,Kangiata Nunaata Sermia
16,
17,Sermeq (glacier in Sermilik ice fjord)
18,Avannarleq Bræ
19,Sermilik Bræ
20,Qajuuttap Sermia
21,Kiattuut Sermiat
22,Inngia Isbræ
23,
24,Upernavik SS
25,Nunatakassaap Sermia
26,Kakivfaat Sermiat
27,Qeqertarsuup Sermia
28,Ussing Bræer
29,Ussing Bræer N
30,Cornell Gletscher
31,Illullip Sermia
32,Alison Gletscher
33,Unnamed south Hayes M
34,Kjer Gletscher
35,Sverdrup Gletscher
36,Nansen Gletscher
37,Steenstrup Gletscher
38,Storm Gletscher
39,Saqqap Sermersua
40,Nordenskiöld Gletscher
41,
42,Issuuarsuit Sermia
43,Rink Gletscher
44,Carlos Gletscher
45,Sermiarsupaluk
46,Heilprin Gletscher
47,Tracy Gletscher
48,Harald Moltke Bræ
49,Humboldt Gletscher
50,
51,
52,Ryder Gletscher
53,
54,Marie Sophie Gletscher
55,Academy Gletscher
56,
57,Nioghalvfjerdsfjorden (79North)
58,Zachariae Isstrøm
59,Storstrømmen
60,Daugaard-Jensen
61,Eielson Gletscher
62,Unnamed Kanger W
63,Helheimgletscher
64,Ikertivaq NN
65,Unnamed Mogens Heinesen S
66,Unnamed Napasorsuaq S
67,Køge Bugt SS
68,Køge Bugt N
69,Ukaasorsuaq
70,Frederikshåbs Isblink
71,Isunnguata Sermia
72,Eqip Sermia
73,
74,Kong Christian IV Gletscher
75,Sorgenfri Glacier
76,Vestfjord Gletscher
77,Jungersen
78,Døcker Smith Gletscher
79,
80,Tingmiarmiut Fjord
81,Sermeq Kujalleq
82,Kangilerngata Sermia
83,Graulv
84,C.H. Ostenfeld Gletscher
85,Kangerluarsuup Sermia
86,Upernavik Isstrøm N
87,Wordie Gletscher
88,
89,
90,
91,
92,
93,Fenrisgletscher
94,Midgårdgletscher
95,Unnamed Deception Ø CN
96,Unnamed Uunartit Islands
97,Kruuse Fjord
98,K.I.V. Steenstrup Nodre Bræ
99,Polaric Gletscher
100,Magga Dan Gletscher
101,
102,Styrtegletscher
103,Frederiksborg Gletscher
104,
105,Kangerdlugssuaq Gletscher
106,Farquhar Gletscher
107,Melville Gletscher
108,Sharp Gletscher
109,Køge Bugt C
110,Puisortoq N
111,Unnamed Mogens Heinesen SSS
112,Harder Gletscher
113,Unnamed South Danell Fjord
114,
115,
116,Unnamed Kangerluluk
117,Unnamed Herluf Trolle S
118,Unnamed Herluf Trolle N
119,Unnamed Anorituup Kangerlua SS
120,Unnamed Anorituup Kangerlua N
121,Unnamed Anorituup Kangerlua S
122,
123,Unnamed Danell Fjord
124,Mælkevejen
125,Unnamed Laube S
126,Laube Gletscher
127,Unnamed Polaric S
128,Heimdal Gletscher
129,Skinfaxe
130,Kong Oscar Gletscher
131,Fimbulgletscher
132,Knud Rasmussen
133,Pasterze
134,L. Bistrup Bræ
135,Admiralty Trefork
136,
137,
138,Sioralik Bræ
139,Sermilik
140,
141,Eqalorutsit Killiit Sermiat
142,
143,
144,Avannerleq N
145,Adolf Hoel Gletscher
146,Waltershausen Gletscher
147,Gerard de Geer Gletscher
148,Jættegletscher
149,Nordenskiöld Gletscher
150,
151,Hisinger Gletscher
152,Violingletscher
153,Steensby Gletscher
154,Gade Glacier
155,Døcker Smith Gl. W
156,
157,Rosenborg Gletscher
158,Kronborg Gletscher
159,Borggraven
160,Sydbræ
161,Bredegletscher
162,
163,Steno Bræ
164,Storbræ N
165,Dendritgletscher
166,
167,Hart Gletscher
168,
169,Hubbard Gletscher
170,
171,Bowdoin Gletscher
172,
173,
174,Verhoeff Gletscher
175,
176,
177,
178,
179,Morris Jesup Gletscher
180,
181,Diebitsch Gletscher
182,Bamse
183,Dodge Gletscher
184,
185,
186,
187,
188,Pitugfik Gletscher
189,
190,Savissuaq WWWW
191,
192,Savissuaq Gletscher
193,
194,Apuseerajik
195,
196,Køge Bugt S
197,
198,Apuseerserpia
199,Gyldenløve Fjord C
200,Rimfaxe
201,
202,Yngvar Nielsen Bræ W
203,Helland Gletscher
204,Yngvar Nielsen Bræ
205,Mohn Gletscher
206,Heim Gletscher
207,
208,
209,
210,F. Graae Gletscher
211,Charcot Gletscher
212,
213,Sortebræ
214,Upernavik Isstrøm C
215,Upernavik Isstrøm S
216,Puisortoq S
217,Unnamed Napasorsuaq N
218,Ikertivaq N
219,Ikertivaq M
220,Ikertivaq S
221,Hayes Gletscher
222,Brikkerne Gletscher
223,Hagen Bræ
224,
225,Jakobshavn Isbræ
226,Saqqarliup Sermia
227,Nordenskiöld Gletscher
228,
229,Sermeq Avannarleq
230,Petermann Gletscher
231,
232,
236,Berlingske Gletscher
240,Unnamed Mogens Heinesen C
241,
242,A.P. Bernstorff Gletscher
243,Unnamed Dendritgletscher S
244,
245,
246,Gyldenløve Fjord S
247,
248,Savissuaq W
249,Savissuaq WW
250,
251,Savissuaq WWW
252,Unnamed Mogens Heinesen N
"""
)

ugids_names_df = pd.read_csv(ugids_names, skipinitialspace=True)


# set up the option parser
parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.description = "Generating scripts for warming experiments."
parser.add_argument(
    "-v", "--variable", dest="variable", help="Variable to read in. Default=ice_mass", default="ice_mass"
)

options = parser.parse_args()
variable = options.variable
pctls = ["5", "16", "50", "84", "95"]
glacier_ugids = [225, 105, 63]
ng = len(glacier_ugids)

for rcp in ["85"]:
    for idx in [42, 92]:

        dfs = []
        for ifile in Path("2019_08_les/glaciers/scalar").glob("**/*fldsum*.nc"):
            m_id = re.search("_id_(.+?)_", str(ifile)).group(1)
            m_ugid = re.search("ugid_(.+?)_", str(ifile)).group(1)
            nc = NC(ifile)
            val = nc.variables[variable][0] - nc.variables[variable][idx]
            val /= 365 * 1e13
            df = pd.DataFrame(
                data=np.asarray([val[0][0], int(m_id), int(m_ugid)]).reshape(1, -1), columns=["sle", "id", "UGID"]
            )
            df = df.merge(ugids_names_df, on="UGID")
            dfs.append(df)
        df = pd.concat(dfs)
        year = 2008 + idx
        df.to_csv("2019_08_les/glaciers/pctls_dgmsl_rcp_{}_{}.csv".format(rcp, year), index=False)

# for rcp in ["85"]:
#     for idx in [42, 92]:
#         df = pd.DataFrame(data=glacier_ugids, columns=["UGID"])
#         for pctl in pctls:
#             pctl_vals = np.zeros([ng])
#             for k, ugid in enumerate(glacier_ugids):
#                 ifile = "2019_08_les/glaciers_ensstat/enspctl{}_fldsum_ugid_{}_ex_gris_g1800m_v3a_rcp_{}.nc".format(
#                     pctl, ugid, rcp
#                 )
#                 pctl_vals[k] = val
#                 nc.close()
#             df = df.join(pd.DataFrame(data=pctl_vals, columns=[pctl]))
#         year = 2008 + idx
#         df.to_csv("2019_08_les/glaciers_pctls/pctls_dgmsl_rcp_{}_{}.csv".format(rcp, year), index=False)
