'''
Example usage: 
python prepare-data-1.py 

Add indicators for party:
left
leftnonsmp
green

Map first_district to dialectical regions

Input: mps-ministers.csv
Output: speaker_metadata_bipartisan.csv

Edited Jan 2020 Salla Simola

'''
import pandas as pd
import numpy as np
import sys
from collections import Counter

##################################################################################

testing = 0
csc = 1

if csc == 1:
    pathroot = "/home/jernie/"
else:
    pathroot = "/Users/jeremiasnieminen/Dropbox/local_speech/"

inputpath = pathroot + 'build/output/'
outputpath = pathroot + 'analysis/input/'

leftpartyfile = pathroot + 'analysis/input/left-parties.xlsx'

if testing == 1:
    output = pathroot + 'analysis/code/test/'

##################################################################################
# Functions

def galtan(party):
    if party == "Vihreä eduskuntaryhmä":
       	return 1
    elif party == "Perussuomalaisten eduskuntaryhmä":
        return 0
    else:
        return np.nan

def leftie(party, leftparties):
    if party in	leftparties:
        return 1
    elif party == "-" or pd.isna(party) == True:
        return np.nan
    else:
        return 0

def leftienonSMP(party, leftparties):
    if party in leftparties:
        return 1
    elif party != "Suomen maaseudun puolueen eduskuntaryhmä" and party != "-" \
       and pd.isna(party) == False:
        return 0
    else:
        return np.nan

def leftnonVennamo(party, speaker_id, leftparties):
    if party in leftparties:
        return 1
    elif party == "-" or pd.isna(party) == True:
        return np.nan
    elif speaker_id == 2194:
        print("Creating left non-Vennamo var, outputting nan for Vennamo")
        return np.nan
    else:
        return 0

def active(term):
    notspring = ['full', 'first', 'second', 'fall', 'sstp']
    for s in notspring:
        if term.find(s) != -1:
            return 1

    return 0

def getDialect(district):
    ''' 
    Mapping from electoral district to dialectical regions
    '''

    if district in ['Viipurin', 'Kaakkois-Suomen', 'Kymen']:
        dialect = "Southeast"
    elif district in [np.nan, "missing"]:
       	dialect	= "missing"
    elif district in ['Uudenmaan', 'Helsingin']:
       	dialect	= "Helsinki and Uusimaa"
    elif district in ['Hämeen', 'Pirkanmaan']:
       	dialect	= "Häme and Pirkanmaa"
    elif district in ['Turun', 'Satakunnan', 'Varsinais-Suomen']:
       	dialect	= "Southwest"
    elif district in ['Vaasan']:
       	dialect	= "Southern Ostrobothnia"
    elif district in ['Oulun', 'Lapin', 'Lapinmaan']:
        dialect = "Lapland and Northern Ostrobothnia"
    elif district in ['Kuopion', 'Pohjois-Karjalan',  'Keski-Suomen', 'Pohjois-Savon', 'Mikkelin',
        'Savo-Karjalan', 'Etelä-Savon']:
        dialect = "Savo"
    else: 
        dialect = "Åland"
    return dialect




####################### UUSIMAA AND HELSINKI ##############################



# getUusimaa (Uusimaa or Helsinki)
def getUusimaa(district):
    if district in ['Uudenmaan', 'Helsingin']:
       	uusimaa	= 1
    elif district in [np.nan, "missing"]:
       	uusimaa = np.nan
    else:
        uusimaa = 0
    return uusimaa

#getHelsinki (Helsinki)
def getHelsinki(district):
    if district in ['Helsingin']:
       	helsinki = 1
    elif district in [np.nan, "missing"]:
       	helsinki = np.nan
    else:
        helsinki = 0
    return helsinki

#getUrban
#def getHelsinki(birthplace):
#    if birthplace in ['Helsingin']:
#       	urban = 1
#    elif birthplace in [np.nan, "missing"]:
#       	urban = np.nan
#    else:
#        urban = 0
#    return urban


############################################################################


def getKokkesk(party):
    if party in ["Kansallisen kokoomuksen eduskuntaryhmä", "Suomalainen puolue"]:
        kokkesk = 1
    elif party in ["Keskustan eduskuntaryhmä", "Maalaisliiton eduskuntaryhmä"]:
       	kokkesk	= 0
    else:
        kokkesk = np.nan

    return kokkesk

def getDemkesk(party):
    if party in ["Sosialidemokraattinen eduskuntaryhmä"]:
        demkesk = 1
    elif party in ["Keskustan eduskuntaryhmä", "Maalaisliiton eduskuntaryhmä"]:
        demkesk = 0
    else:
        demkesk = np.nan

    return demkesk

def getDemkok(party):
    if party in ["Sosialidemokraattinen eduskuntaryhmä"]:
        demkok = 1
    elif party in ["Kansallisen kokoomuksen eduskuntaryhmä", "Suomalainen puolue"]:
        demkok = 0
    else:
        demkok = np.nan

    return demkok

def getVaskok(party):
    if party in ["Suomen kansan demokraattisen liiton eduskuntaryhmä",
        "Vasemmistoliiton eduskuntaryhmä", 
        "Suomen sosialistinen työväenpuolue", 
        "Työväen ja pienviljelijäin vaaliliitto", 
        "Työväen ja pienviljelijäin puolue",
        "Työväen ja pienviljelijäin sosialidemokraattinen liitto"]:
        vaskok = 1
    elif party in ["Kansallisen kokoomuksen eduskuntaryhmä", "Suomalainen puolue"]:
        vaskok = 0
    else:
        vaskok = np.nan

    return vaskok


# Gender2: drop parties that do not have any females in SOME years (EXCEPT for SDP where no females only in 1918)

def getGender2(party, female):
    if party in ["Alkiolainen keskustaryhmä", "Eduskuntaryhmä Immonen", "Eduskuntaryhmä Nuorsuomalaiset ja Risto Kuisma",
                   "Eduskuntaryhmä Puhjo", "Eduskuntaryhmä Virtanen", "Hannu Suhosen eduskuntaryhmä",
                   "Isänmaallinen kansanliike", "Kansalaispuolueen eduskuntaryhmä", "Kansallinen edistyspuolue", "Kansanpuolue",
                   "Keskustan eduskuntaryhmä", "Kristillisdemokraattinen eduskuntaryhmä", "Kristillisen liiton eduskuntaryhmä", "Liberaalien eduskuntaryhmä",
                   "Liberaalisen kansanpuolueen eduskuntaryhmä", "Liike Nyt -eduskuntaryhmä", "Maalaisliiton eduskuntaryhmä",
                   "Muutospuolueen eduskuntaryhmä", "Nuorsuomalainen puolue", "Nuorsuomalaisten eduskuntaryhmä", "Perussuomalaisten eduskuntaryhmä",
                   "Perustuslaillinen oikeistopuolue", "Remonttiryhmä", "Ruotsalainen eduskuntaryhmä", "Ruotsalainen vasemmisto",
                   "Ryhmä Erlund", "Sosialidemokraattinen riippumaton eduskuntaryhmä", "Suomalainen puolue", "Suomalaisen rintaman eduskuntaryhmä",
                   "Suomen kansan yhtenäisyyden puolue", "Suomen kansanpuolue", "Suomen kristillisen työväen liitto",
                   "Suomen maaseudun puolueen eduskuntaryhmä", "Suomen perustuslaillinen kansanpuolue", "Suomen pientalonpoikien puolue",
                   "Suomen pienviljelijäin ja maalaiskansan puolue", "Suomen pienviljelijäin puolue",
                   "Suomen sosialistinen työväenpuolue", "Työväen ja pienviljelijäin vaaliliitto", "Vaihtoehto Suomelle -eduskuntaryhmä",
                   "Vapaamielisten liitto", "Vapaiden demokraattien eduskuntaryhmä", "Vasemmistoryhmä", "Vasenryhmän eduskuntaryhmä",
                   "Vihreä eduskuntaryhmä", "edustaja Väyrynen"]:
        return np.nan 
    else:
        if female == 1:
            return 1
        else:
            return 0

# Gender: drop parties that do not have any females in ANY years

def getGender(party, female):
    if party in ["Alkiolainen keskustaryhmä", "Eduskuntaryhmä Immonen", "Eduskuntaryhmä Nuorsuomalaiset ja Risto Kuisma",
                   "Eduskuntaryhmä Puhjo", "Eduskuntaryhmä Virtanen", "Hannu Suhosen eduskuntaryhmä",
                   "Kansalaispuolueen eduskuntaryhmä", "Kansanpuolue",
                   "Keskustan eduskuntaryhmä", "Kristillisdemokraattinen eduskuntaryhmä", "Kristillisen liiton eduskuntaryhmä",
                   "Liberaalien eduskuntaryhmä", "Liike Nyt -eduskuntaryhmä", "Muutospuolueen eduskuntaryhmä",
                   "Nuorsuomalaisten eduskuntaryhmä", "Remonttiryhmä", "Ruotsalainen vasemmisto",
                   "Ryhmä Erlund", "Sosialidemokraattinen riippumaton eduskuntaryhmä", "Suomalaisen rintaman eduskuntaryhmä",
                   "Suomen kansanpuolue", "Suomen kristillisen työväen liitto", "Suomen pientalonpoikien puolue",
                   "Suomen pienviljelijäin ja maalaiskansan puolue", 
                   "Työväen ja pienviljelijäin vaaliliitto", "Vaihtoehto Suomelle -eduskuntaryhmä", "Vapaamielisten liitto",
                   "Vapaiden demokraattien eduskuntaryhmä", "Vasemmistoryhmä", "Vasenryhmän eduskuntaryhmä", "edustaja Väyrynen", "-"] or pd.isna(party) == True:
        return np.nan 
    else:
        if female == 1:
            return 1
        else:
            return 0



################# NEW STUFF ########################


def getUnder40(year, birthyear):

    year2 = int(year)

    if pd.isna(birthyear):
        return np.nan
    else:
        b2 = birthyear.strip("[']")
        birthye = int(b2)
        age = year2 - birthye

        if age < 40:
            return 1

        if age >= 40:
            return 0
    

def getWhiteCollar(profession):

    if pd.isna(profession):
        return np.nan

    else:
        
        lst = ["opettaja", "tuomari", "asianajaja", "agronomi", "lisensiaatti", "lääkäri", "toimittaja", "johtaja", "sosionomi",
           "kirjanpitäjä", "maisteri", "kirkkoherra", "rovasti", "insinööri", "sihteeeri", "professori", "tohtori",
           "ministeri", "pastori", "neuvos", "kirjailija", "psykiatri", "kandidaatti", "ekonomi", "pormestari",
           "suurlähettiläs", "konsuli", "lehtori", "lakimies", "päällikkö", "tarkastaja", "toimisto", "farmaseutti",
           "arkkitehti", "piispa", "notaari", "rehtori", "tiedottaja", "markkinointikonsultti", "kirjuri", "konttoristi",
           "analyytikko", "senaattori", "majuri", "kansleri", "aktuaari", "tutkija", "kenraali", "tradenomi", "merkonomi",
           "kappalainen", "everstiluutnantti", "dosentti", "journalisti"]
        lst2 = ["viljelijä", "kirvesmies", "vartija", "vahtimestari", "maalari", "viilaaja", "kauppias", "sairaanhoitaja",
            "räätäli", "suutari", "posteljooni", "muurari", "perhepäivähoitaja", "myymälänhoitaja", "ompelija", "levyseppä",
            "talonmies", "kultaseppä", "satamavalvoja", "rakennusmestari", "puvustonhoitaja", "seppä", "mylläri",
            "liikunnanohjaaja", "konstaapeli", "vaatturi", "mestari", "veturinkuljettaja", "mäkitupalainen", "ulosottomies",
            "työmies", "ylikonstaapeli", "ylikomisario", "emäntä", "isännöitsijä", "teknikko", "tehdas", "työläinen",
            "hoitaja", "asioitsija", "asentaja", "faktori", "agrologi", "viilaaja", "kuljettaja", "kuljetusyrittäjä",
            "työntekijä", "betoni", "raudoittaja", "sitoja", "sorvaaja", "torppari", "korjausmies", "valaja", "kaavaaja",
            "muusikko", "palo", "verhoilija", "toimitsija", "kanttori", "urkuri", "asemamies", "kutoja", "leipuri",
            "tilallinen", "kuljettaja", "kirjaltaja", "merikapteeni", "puutarhuri", "autoilija", "rautatieläinen",
            "liikkenharjoittaja", "talollinen", "ajomies", "mekaanikko", "puutavaramies", "koneenkäyttäjä"]
        if any(s in profession for s in lst):
            return 1
        elif any(s in profession for s in lst2):
            return 0
        else:
            return np.nan
        

def getHigherEduc(education):

    if pd.isna(education):
        return np.nan

    else:
    
        lst3 = ["tohtori", "maisteri", "kandidaatti", "lisensiaatti", "agronomi",  "professori", "notaari", "varatuomari"]

        if any(s in education for s in lst3):
            return 1

        else:
            return 0



#####################################################




##################################################################################

leftdf = pd.read_excel(leftpartyfile)
leftparties = leftdf.party.tolist()

df = pd.read_csv(inputpath + 'mps-ministers.csv', delimiter = '|', lineterminator = "\n", encoding = "utf-8")
print(set(list(df.first_district.values)))
print(df.full_name[(df.speaker_id == 2194)])

if testing == 0:
    ck = 1
else:
    ck = int(input("Is this Vennamo? Input 1 if yes, 0 otherwise"))

if ck == 0:
    sys.exit("Fix Vennamo id in code")

df["id"] = df["year"].map(str) + df["speaker_id"].map(str) + 'a'
ids = df.id.tolist()
#print(set(df.party.tolist()))
assert len([item for item, count  in Counter(ids).items() if count > 1]) == 0, "Duplicate ids in data!"

df['active'] = df.apply(lambda x: active(x['term']), axis=1)
#print("Active: ", df.active[(df.speaker_id == 368)])
#print(df.head())
#print(df[(df.term == "spring")].head())

# Drop non-actives (added Jan, 2020)
df = df[(df.active == 1)]

# Create various different party indicators
df['left'] = df.apply(lambda x: leftie(x['party'], leftparties), axis=1)
df['leftnonsmp'] = df.apply(lambda x: leftienonSMP(x['party'], leftparties), axis=1)
df['green'] = df.apply(lambda x: galtan(x['party']), axis=1)
df['leftnonvennamo'] = df.apply(lambda x: leftnonVennamo(x['party'], x['speaker_id'], leftparties), axis = 1) 
df['kokkesk'] = df.apply(lambda x: getKokkesk(x['party']), axis = 1)
df['demkesk'] = df.apply(lambda x: getDemkesk(x['party']), axis = 1)
df['demkok']  = df.apply(lambda x: getDemkok(x['party']), axis = 1)
df['vaskok']  = df.apply(lambda x: getVaskok(x['party']), axis = 1)
df['dialect'] = df.apply(lambda x: getDialect(x['first_district']), axis = 1)

# gender added, helsinki added, uusimaa added
df['gender']  = df.apply(lambda x: getGender(x['party'], x['female']), axis = 1)
df['helsinki']  = df.apply(lambda x: getHelsinki(x['first_district']), axis = 1)
df['uusimaa']  = df.apply(lambda x: getUusimaa(x['first_district']), axis = 1)

# birthplace urban-rural
#df['urban']  = df.apply(lambda x: getUrban(x['birthplace']), axis = 1)

###new stuff
#young
df['under40']  = df.apply(lambda x: getUnder40(x['year'], x['birthyear']), axis = 1)
#whitecollar
df['whitecollar']  = df.apply(lambda x: getWhiteCollar(x['profession']), axis = 1)
#highereducation
df['education']  = df.apply(lambda x: getHigherEduc(x['education']), axis = 1)


df = df[["year", "speaker_id", "id", "female", "gender", "party", "left", "green", "leftnonsmp", "leftnonvennamo", "govparty", "pmparty", "dialect", "kokkesk", "demkok",
         "demkesk", "vaskok", "helsinki", "uusimaa", "under40", "whitecollar", "education"]]

# rename female to gender
# df.rename(columns={'female': 'gender'}, inplace=True)

print(df.groupby(['dialect']).count())

#print(df.first_district[df.dialect=="missing"])
#print(df[["left", "leftnonsmp", "green", "party"]])
#print(df[["left", "leftnonsmp", "party"]][(df.party.isna() == True)])
#print(df[["year", "left", "leftnonsmp", "party"]][(df.party == "-")])
#print(df[["year", "left", "leftnonsmp", "party"]][(df.party == "Suomen maaseudun puolueen eduskuntaryhmä")])
print(df[["year", "demkok", "party"]][(df.party == "Sosialidemokraattinen eduskuntaryhmä")])
print(df[["year", "demkok", "party"]][(df.party == "Kansallisen kokoomuksen eduskuntaryhmä")])
print(df[["year", "demkok", "party"]][(df.party == "Suomalainen puolue")])
print(df[["year", "demkok", "vaskok", "party"]][(df.party == "Työväen ja pienviljelijäin sosialidemokraattinen liitto")])

print(df.head())
print(df.columns)

# Write to file
print("SSTP example: \n", df[(df.speaker_id == 368)])
df.to_csv(outputpath + 'speaker_metadata_bipartisan.csv', sep = '|', line_terminator = '\n', encoding = 'utf-8', index = False)

print("Output written to %s"%(outputpath + 'speaker_metadata_bipartisan.csv'))
