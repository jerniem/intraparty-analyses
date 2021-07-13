'''
Governments from government web site
Resulting data on specified level

dependencies: requests, lxml, pandas

Salla Simola Dec 11, 2019
'''

import requests
from lxml import html
from lxml.cssselect import CSSSelector
import pandas as pd

# all = 0 if generating gov data end of year situation
# all = 1 if generating gov data for a record for each operating year

all = 0
monthly = 0 # for creating month-level data
csc = 0
train = 0 # set training = 0 if not manually inputting ministers

if csc == 1:
    pathroot = '/wrk/simolasa/DONOTREMOVE/'
else:
    pathroot = '/Users/Salla/Dropbox (Aalto)/speech-polatization/code/remote/parliamentary-speech/'

path = pathroot + 'build/input/'
outdir = pathroot + 'build/output/'

wiki = pd.read_excel(path + 'government-wikipedia.xlsx')
wiki = wiki[['seats', 'parties', 'order']]

# List of govs
transcript_url = "https://valtioneuvosto.fi/tietoa/historiaa/hallitukset-ja-ministerit/raportti/-/r/v2"

################################################################################
# Functions
def editSeats(merged):
    # MPs died
    merged.loc[merged.seats == '198 < 200', 'seats'] = 200
    # Sorsa 3
    merged.loc[(merged.seats == '133 >< 102') & (merged.date < '1982-12-31'), 'seats'] = 133
    merged.loc[(merged.seats == '133 >< 102') & (merged.date >= '1982-12-31'), 'seats'] = 102
    # Holkeri
    merged.loc[(merged.seats == '131 > 122') & (merged.date < '1990-08-31'), 'seats'] = 131
    merged.loc[(merged.seats == '131 > 122') & (merged.date >= '1990-08-31'), 'seats'] = 122
    # Aho
    merged.loc[(merged.seats == '115 > 107') & (merged.date < '1994-06-30'), 'seats'] = 115
    merged.loc[(merged.seats == '115 > 107') & (merged.date >= '1994-06-30'), 'seats'] = 107
    # Lipponen 2
    merged.loc[(merged.seats == '140 > 129') & (merged.date < '2002-05-31'), 'seats'] = 140
    merged.loc[(merged.seats == '140 > 129') & (merged.date >= '2002-05-31'), 'seats'] = 129
    # Katainen
    merged.loc[(merged.seats == '128 > 126 > 112') & (merged.date < '2014-04-30'), 'seats'] = 126
    merged.loc[(merged.seats == '128 > 126 > 112') & (merged.date >= '2014-04-30'), 'seats'] = 112
    # Stubb
    merged.loc[(merged.seats == '112 > 102') & (merged.date < '2014-09-30'), 'seats'] = 112
    merged.loc[(merged.seats == '112 > 102') & (merged.date >= '2014-09-30'), 'seats'] = 102
    # Sipilä
    merged.loc[(merged.seats == '124 > 123 >< 106 > 105 > 103') & (merged.date < '2017-06-30'), 'seats'] = 124
    merged.loc[(merged.seats == '124 > 123 >< 106 > 105 > 103') & (merged.date < '2018-04-30'), 'seats'] = 106
    merged.loc[(merged.seats == '124 > 123 >< 106 > 105 > 103') & (merged.date < '2018-06-30'), 'seats'] = 105
    merged.loc[(merged.seats == '124 > 123 >< 106 > 105 > 103') & (merged.date >= '2018-06-30'), 'seats'] = 103

    return merged

################################################################################

# Get page
transcript_page = requests.get(transcript_url)

# Page source: transcript_page.text

# build the DOM tree
transcript_tree = html.fromstring(transcript_page.text)

# Extract lines:
CELL_SELECTOR = CSSSelector('div.table-responsive tr td')
GOV_SELECTOR = CSSSelector('div.table-responsive tr a')

# Construct a list of lines
cells = CELL_SELECTOR(transcript_tree)
govlist = GOV_SELECTOR(transcript_tree)

governments = []

i = 0
for gov in govlist:
    governments.append([gov.text,
        cells[i+1].text,
        cells[i+2].text,
        cells[i+3].text,
        cells[i+4].text])
    i += 5

df = pd.DataFrame(governments,
    columns = ["government",
    "period", "days", "pm_party", "type"])

# df.to_csv(tablepath + "governments.csv", sep = '|', index = False)
#
# df = pd.read_csv(tablepath + "governments.csv", delimiter = '|',
#     lineterminator = "\n", encoding = "utf-8")

df["startdate"]  = df["period"].apply(lambda x: x.split('-')[0])
df["startyear"]  = df["startdate"].apply(lambda x: x.split('.')[-1])
df["startmonth"] = df["startdate"].apply(lambda x: x.split('.')[-2])
df["order"] = df["government"].apply(lambda x: int(x.split('.')[0]))

df = df.set_index(pd.DatetimeIndex(df.startdate))

if all == 1:
    # Detour: Upsample data to monthly level, fill NAs with ffill ('MS' = month start)
    # Reason: resample('YS') (upsample to yearly level) only keeps the last
    # government of the year
    df = df.resample('MS').ffill()
    df["date"] = df.index
    df["year"] = df.date.apply(lambda x: x.year)
    merged = pd.merge(df, wiki, how = 'left', on = ['order'])
    df = editSeats(merged)

    # Select columns and rows
    df = df[['government', 'year', 'startmonth', 'period', 'days', 'pm_party', 'type', 'order', 'seats', 'parties']]
    df = df[df["government"].isnull() == False]

    # Data to yearly level
    df = df.drop_duplicates(subset = ['government', 'year', 'startmonth', 'period', 'days', 'pm_party', 'type', 'order', 'parties'])

    #merged = pd.merge(df, wiki, how = 'left', on = ['order'])
    #merged = editSeats(merged)
    df.to_csv(outdir + "governments.csv", sep = '|', index = False)

elif monthly == 1:
    # Detour: Upsample data to monthly level, fill NAs with ffill ('MS' = month start)
    # Reason: resample('YS') (upsample to yearly level) only keeps the last
    # government of the year
    df = df.resample('M').ffill()

    df["date"] = df.index
    #df["year"] = df.date.apply(lambda x: x.year)
    #df["month"] = df.date.apply(lambda x: x.month)

    # Select columns and rows
    df = df[['government', 'date', 'period', 'days', 'pm_party', 'type', 'order']]
    df = df[df["government"].isnull() == False]

    merged = pd.merge(df, wiki, how = 'left', on = ['order'])
    merged = editSeats(merged)
    merged.to_csv(outdir + "governments_eom.csv", sep = '|', index = False)

else:
    # Resample end of year situation
    df = df.resample('A').ffill()
    df["date"] = df.index
    df["year"] = df.date.apply(lambda x: x.year)
    merged = pd.merge(df, wiki, how = 'left', on = ['order'])
    df = editSeats(merged)

    # Select columns and rows
    df = df[['government', 'year', 'startmonth', 'period', 'days', 'pm_party', 'type', 'order', 'seats', 'parties']]
    df = df[df["government"].isnull() == False]

    # Data to yearly level
    df = df.drop_duplicates()

    df.to_csv(outdir+ "governments_eoy.csv", sep = '|', index = False)
