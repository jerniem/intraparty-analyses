import pandas as pd
import re, csv
from collections import Counter

csc = 0

if csc == 1:
    pathroot = '/home/jernie/'
else:
    pathroot = '/Users/jeremiasnieminen/Dropbox/local_speech/mpdata/selected/'

outdir = pathroot + 'build/output/'
path = pathroot + 'build/input/'

file = 'Excel_entiset-edustajat-1907-2014-edits.xlsx'
file2 = 'Excel_entiset-edustajat-2015-2018-edits.xlsx'

# for i in range(len(df)):
#     lastname = df["Sukunimi"].iloc[i]
#     if re.findall(r"\d-", lastname):
#         print(lastname)
districtlist = []
###############################################################################
# Functions:
def getTerm(startdate, enddate, year):
    '''
    Define the active term for a MP in given year.
    1908, 1909, 1917, 1929, 1930, 1975: election mid-year, treat as special
    cases.
    full = serves full year
    spring = assume serves spring season if year = endyear
    fall = assume serves fall season if year = startyear
    sstp = flags incomplete year 1923 for SSTP members
    '''
    startdate = startdate.strip()
    enddate = enddate.strip()
    startmonth = int(startdate.split('.')[1])

    if enddate != '':
        endmonth = int(enddate.split('.')[1])
        endyear = int(enddate.split('.')[-1])
    else:
        endmonth = 12
        endyear = 2020

    startyear = int(startdate.split('.')[-1])

    if year == startyear:
        if year == 1908:
            if startdate == '10.02.1908' and endyear != year:
                term = "full"
            elif startdate == '10.02.1908' and endyear == year:
                term = "first"
            elif startdate == '01.08.1908':
                term = "second"
            else:
                term = "fall"

        elif year == 1909:
            if startdate == '16.02.1909' and endyear != year:
                term = "full"
            elif startdate == '16.02.1909' and endyear == year:
                term = "first"
            elif startdate == '01.06.1909':
                term = "second"
            else:
                term = "fall"

        elif year == 1917:
            if startdate == '04.04.1917' and endyear != year:
                term = "full"
            elif startdate == '04.04.1917' and endyear == year:
                term = "first"
            elif startdate == '01.11.1917':
                term = "second"
            else:
                term = "fall"

        elif year == 1929:
            if startdate == '01.02.1929' and endyear != year:
                term = "full"
            elif startdate == '01.02.1929' and endyear == year:
                term = "first"
            elif startdate == '01.08.1929':
                term = "second"
            else:
                term = "fall"

        elif year == 1930:
            if startdate == '01.02.1930' and endyear != year:
                term = "full"
            elif startdate == '01.02.1930' and endyear == year:
                term = "first"
            elif startdate == '21.10.1930':
                term = "second"
            else:
                term = "fall"

        elif year == 1975:
            if startdate == '04.02.1975' and endyear != year:
                term = "full"
            elif startdate == '04.02.1975' and endyear == year:
                term = "first"
            elif startdate == '27.09.1975':
                term = "second"
            else:
                term = "fall"

        else:
                term = "fall"

    elif year == endyear:
        if year == 1908:
            if enddate == '02.02.1908':
                term = "spring"
            elif enddate == '31.07.1908':
                term = "first"
            else:
                if endmonth > 9:
                    term = "full"
                else:
                    term = "spring"

        elif year == 1909:
            if enddate == '15.02.1909':
                term = "spring"
            elif enddate == '31.05.1909':
                term = "first"
            else:
                if endmonth > 9:
                    term = "full"
                else:
                    term = "spring"

        elif year == 1917:
            if enddate == '03.04.1917':
                term = "spring"
            elif enddate == '31.10.1917':
                term = "first"
            else:
                if endmonth > 10:
                    term = "full"
                else:
                    term = "spring"

        elif year == 1929:
            if enddate == '31.01.1929':
                term = "spring"
            elif enddate == '31.07.1929':
                term = "first"
            else:
                if endmonth > 9:
                    term = "full"
                else:
                    term = "spring"

        elif year == 1930:
            if enddate == '31.01.1930':
                term = "spring"
            elif enddate == '20.10.1930':
                term = "first"
            else:
                if endmonth > 10:
                    term = "full"
                else:
                    term = "spring"

        elif year == 1975:
            if enddate == '03.02.1975':
                term = "spring"
            elif enddate == '26.09.1975':
                term = "first"
            else:
                if endmonth > 9:
                    term = "full"
                else:
                    term = "spring"

        elif enddate == '17.10.1923':
            # SSTP party thrown out
            term = 'sstp'

        else:
            if endmonth > 9:
                term = "full"
            else:
                term = "spring"

    else:
        term = "full"

    #print(startdate, enddate, year, term)
    return term

def getLastNames(lastname):
    '''
    Input: lastname (e.g. 'Niinistö', 'Stenius, 1978: Mattsson, 1982: Stenius-Kaukonen')
    Output: lastnamedict with key: year, value: current last name
    '''
    namechangeyears = re.findall(r"(\d+):", lastname)
    lastnames = lastname.split(',')
    names = [re.sub(r"[\d:\s]", "", name) for name in lastnames]

    lastnamedict = {}
    for year in range(1900, 2020):
        # Fill the dict with the first last name
        lastnamedict[year] = names[0]
        # Replace with the later last names
        for i in range(len(namechangeyears)):
            if year >= int(namechangeyears[i]):
                lastnamedict[year] = names[i+1]

    return lastnamedict

###############################################################################
df = pd.read_excel(path+file)

mps_yearly = []
for i in range(len(df)):
    districts = df["Edelliset vaalipiirit"].iloc[i]
    districts = districts.split('\n')
    districts =', '.join(districts)
    firstdistrict = districts.split(',')[0].split()[0]
    #print(firstdistrict)

    if firstdistrict == "-":
        firstdistrict = "missing"

    districtlist.append(firstdistrict)

    partyhist = df["Edelliset eduskuntaryhmät"].iloc[i]
    partyhist = partyhist.split('\n')
    # Name:
    firstnames = df["Etunimet"].iloc[i]
    lastname = df["Sukunimi"].iloc[i]
    if df["Sukupuoli"].iloc[i].strip() == "Nainen":
        female = 1
    else:
        female = 0
    lastnamedict = getLastNames(lastname)


#############################################################

    # ADD BIRTHDAY AND BIRTHYEAR
    birthday = df["MOPBirthdayText"].iloc[i]

    from datetime import datetime
    dt = datetime.strptime(birthday, '%d.%m.%Y')

    birthyear = dt.year

    # ADD PROFESSION AND EDUCATION
    profession = df["Ammatti"].iloc[i]
    education = df["Koulutus"].iloc[i]



#############################################################
    

    for entry in partyhist:
        # Split at first number (thus, assure no nrs in party name)
        splits = re.compile(r"(^[\D]+)(\d.+$)").split(entry)
        party = splits[1].strip()
        dates = splits[2]

        # All dashes are not dashes but sometimes em or en dashes:
        try:
            startdate = dates.split('-')[0]
            enddate = dates.split('-')[1]
        except:
            if re.findall(u"\u2014", dates):
                startdate = re.compile(u"\u2014").split(dates)[0]
                enddate = re.compile(u"\u2014").split(dates)[1]
            else:
                startdate = re.compile(u"\u2013").split(dates)[0]
                enddate = re.compile(u"\u2013").split(dates)[1]

        # Replace dates to get rid of em and en dashes
        dates = '-'.join([startdate, enddate])
        startyear = startdate.split('.')[-1]
        endyear = enddate.split('.')[-1]

        districts = df["Edelliset vaalipiirit"][i]
        districts = districts.split('\n')
        districts =', '.join(districts)

        for year in range(int(startyear), int(endyear)+1):
            term = getTerm(startdate, enddate, year)
            # Get current lastname
            lastname = lastnamedict.get(year)
            fullname = ' '.join([firstnames, lastname])
            # BIRTHDAY, BIRTHYEAR, PROFESSION & EDUCATION ADDED
            mps_yearly.append([year, term, i, fullname, lastname, df["Etunimet"].iloc[i], party, dates, female, df["Syntymäpaikka"].iloc[i],
                               districts, firstdistrict, birthday, birthyear,
                               profession, education, startyear, endyear])

speakernames = [entry[2] for entry in mps_yearly]
firstlen = len(set(speakernames))

'''
Process second data file
'''
df = pd.read_excel(path + file2)

for i in range(len(df)):
    if isinstance(df["Edelliset vaalipiirit"].iloc[i], str):
        districts = df["Edelliset vaalipiirit"].iloc[i]
        districts = districts.split('\n')
    else:
        districts = []


    districts.append(df["Vaalipiiri"].iloc[i])
    districts =', '.join(districts)
    firstdistrict = districts.split(',')[0].split()[0]
    #print(firstdistrict)

    if firstdistrict == "-":
        firstdistrict = "missing"

    districtlist.append(firstdistrict)

    if df["Sukupuoli"].iloc[i].strip() == "Nainen":
        female = 1
    else:
       	female = 0

    if isinstance(df["Edelliset eduskuntaryhmät"].iloc[i], str):
        partyhist = df["Edelliset eduskuntaryhmät"].iloc[i]
        partyhist = partyhist.split('\n')
    else:
        partyhist = []

    partyhist.append(df["Eduskuntaryhmät"].iloc[i])
    # Name:
    firstnames = df["Etunimet"].iloc[i]
    lastname = df["Sukunimi"].iloc[i]
    lastnamedict = getLastNames(lastname)


    ############################################################# 

    # ADD BIRTHDAY AND BIRTHYEAR, old
    #birthday = df["MOPBirthdayText"].iloc[i]
    #birthyear = re.findall(r'\d{4}', birthday)

    # ADD BIRTHDAY AND BIRTHYEAR
    birthday = df["MOPBirthdayText"].iloc[i]

    #from datetime import datetime
    dt = datetime.strptime(birthday, '%d.%m.%Y')

    birthyear = dt.year


    # ADD PROFESSION AND EDUCATION
    profession = df["Ammatti"].iloc[i]
    education = df["Koulutus"].iloc[i]

    #############################################################

    for entry in partyhist:
        #print(df["Sukunimi"].iloc[i], entry)
        splits = re.compile(r"(^[\D]+)(\d.+$)").split(entry)
        party = splits[1].strip()
        dates = splits[2]

        startdate = dates.split('-')[0]
        enddate = dates.split('-')[1]

        if enddate.strip() == '':
            endyear = '2019'
        else:
            endyear = enddate.split('.')[-1]
        startyear = startdate.split('.')[-1]

        for year in range(int(startyear), int(endyear)+1):
            term = getTerm(startdate, enddate, year)
            # Get current lastname
            lastname = lastnamedict.get(year)
            fullname = ' '.join([firstnames, lastname])
            # BIRTHDAY, BIRTHYEAR, PROFESSION & EDUCATION ADDED
            mps_yearly.append([year, term, i + firstlen+1, fullname, lastname, df["Etunimet"].iloc[i], party, dates,
                               female, df["Syntymäpaikka"].iloc[i], districts, firstdistrict, birthday,
                               birthyear, profession, education, startyear, endyear])

print("MP rows:", len(mps_yearly))


# added startyear and endyear here
outdf = pd.DataFrame.from_records(mps_yearly, columns=["year", "term",
    "speaker_id", "full_name", "last_name", "first_names", "party", "dates",
    "female", "birthplace", "electroral_districts", "first_district", "birthday", "birthyear", "profession", "education", "startyear", "endyear"])




outdf.to_csv(outdir + 'mp-data.csv', sep ='|', index = False, encoding = 'utf-8')

# print(df.shape)
for col in outdf.columns:
     print(col)
     print(outdf[col].iloc[1:2])

# Speaker id, fullname
keys = [(entry[2], entry[3]) for entry in mps_yearly]
uniqkeys = list(set(keys))
speakers = [entry[1] for entry in uniqkeys]

# Check that every name has only one id
uniqspeakers = list(set([entry[1] for entry in uniqkeys]))
# 'Heikki Törmä' appears in unique keys twice but they are two different people.
print([item for item, count in Counter(speakers).items() if count > 1])

print("Nr MPs in data:", len(set(speakers)))

print("Ready, wohoo!")

# ss = set(districtlist)
# for s in ss:
#     print(s)
# import re
# mystrs = ["Savolainen, 1926: Savolainen-Tapaninen", "Poikelainen"]
# for mystr in mystrs:
#     list = mystr.split(',')
#     if len(list)>1:
#         for mem in list:
#             mems = mem.split(':')
#             if re.search(r"\d+", mems[0]):
#                 print(mems[0].strip())
#                 print(mems[1].strip())
