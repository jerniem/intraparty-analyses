import pandas as pd
import re, csv, sys
from collections import Counter
import numpy as np

csc = 0

if csc == 1:
    pathroot = '/home/jernie'
else:
    pathroot = '/Users/jeremiasnieminen/Dropbox/local_speech/mpdata/selected/'

path = pathroot + 'build/input/'
outdir = pathroot + 'build/output/'

'''
Add gov coalition, minister status

input:
mps-ministers-trained.csv
governments_eoy.csv
party_key.csv
'''
###############################################################################
# Functions:

def replacePartyName(party):
    '''
    To keep the party records consistent, replace party always with a
    consistent form of party's name.
    '''
    keyfile = pathroot + 'build/input/party_key.csv'

    key = pd.read_csv(keyfile, delimiter = '|', lineterminator = "\n", encoding = "utf-8")

    key = key[key.party == party]
    consistent_party_name = key["party2"].iloc[0]
    return consistent_party_name

def keepUnique(value):
    vals = str(value).split(',')
    vals = [v.strip() for v in vals if v != " " and v != ""]
    vs = list(set(vals))
    return ', '.join(vs)

def inGovernment(x):
    pos = str(x["coalition"]).find(str(x["party"]))
    if pos != -1:
        return 1
    else:
        return 0

def inPmparty(x):
    if x["party"] == x["pm_party"]:
        return 1
    else:
        return 0

def seatShare(x):
    return x["govseats"]/x["mpseats"]

###############################################################################

pmparty = pd.read_csv(outdir + 'governments_eoy.csv', delimiter = '|', lineterminator = "\n", encoding = "utf-8")
pmparty = pmparty[["year", "pm_party"]]
pmparty["pm_party"] = pmparty.pm_party.apply(lambda x: replacePartyName(x))

mpdf2 = pd.read_csv(outdir + 'mps-ministers-trained.csv', delimiter = '|',
    lineterminator = "\n", encoding = "utf-8")

# Generate minister dummy
mpdf2['minister'] = np.where(pd.isnull(mpdf2['titles']) != True, 1, 0)

# helper variable
mpdf2['ministerparty'] = np.where((mpdf2.minister == 1) &
    (mpdf2.minister_term != "spring"), mpdf2["party"], "")

# Coalition consists of parties of ministers in the end of the year
mpdf2['coalition'] = mpdf2.groupby(['year'])['ministerparty'].transform(lambda col: ', '.join(col))
mpdf2['coalition'] = mpdf2.coalition.apply(lambda x: keepUnique(x))

#mpdf2.to_csv(outdir + 'valitiedosto.csv', sep ='|', index = False, encoding = 'utf-8')
#mpdf2 = pd.read_csv(outdir + 'valitiedosto.csv', delimiter = '|', lineterminator = "\n", encoding = "utf-8")

# drop helper var
mpdf2 = mpdf2.drop(['ministerparty'], axis = 1)

# Create dummy for gov party members
mpdf2['govparty'] = mpdf2.apply(inGovernment, axis = 1)

# helper var
mpdf2['helper'] = np.where((mpdf2.term != "spring") &
    (mpdf2.term != "first") & (mpdf2.govparty == 1)
    & (mpdf2.party != "-"), 1, 0)

mpdf2['helper2'] = np.where((mpdf2.govparty == 1), 1, 0)

mpdf2['govseats'] = mpdf2.groupby(['year'])[['helper']].transform('sum')

# Create pm party dummy
mpdf2 = pd.merge(mpdf2, pmparty, how = 'left', on = ['year'])
mpdf2['pmparty'] = mpdf2.apply(inPmparty, axis = 1)
mpdf2 = mpdf2.drop(['pm_party', 'helper', 'helper2'], axis = 1)

# Sanity check:
for y in set(mpdf2.year):
    print("Government parties in %d (seats %s): %s"%(y, set(mpdf2.govseats[mpdf2.year == y]), sorted(set(mpdf2.coalition[mpdf2.year == y]))))
    if y == 1923:
        for name in set(mpdf2.full_name[(mpdf2.year == y) & (mpdf2.minister == 1)]):
            print(name)

mpdf2.to_csv(outdir + 'mps-ministers.csv', sep ='|', index = False, encoding = 'utf-8')
