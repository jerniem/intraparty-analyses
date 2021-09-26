'''
Extract name, party, time as minister from Parliament's minister databank.

Created by Salla Simola, July 24, 2019.
Accessed July 24, 2019.
'''

import re
import csv
import requests
from lxml import html
from lxml.cssselect import CSSSelector

path = '/Users/Salla/Dropbox (Aalto)/speech-polatization/code/remote/parliamentary-speech/build/input/'

# All ministers in alphabetical order
transcript_url = "https://valtioneuvosto.fi/tietoa/historiaa/hallitukset-ja-ministerit/raportti/-/r/v5s/henkilo.nimi"

# Get html
transcript_page = requests.get(transcript_url)

# build the DOM tree
transcript_tree = html.fromstring(transcript_page.text)

# Construct a selector
URL_SELECTOR = CSSSelector('div.table-responsive tr td a')

url_elementlist = URL_SELECTOR(transcript_tree)

urllist = [element.get('href') for element in url_elementlist]
root = 'https://valtioneuvosto.fi/'
#urllist = ['https://valtioneuvosto.fi/tietoa/historiaa/hallitukset-ja-ministerit/raportti/-/r/m2/25']
#root=''
records = []

for url in urllist:
    dates = []
    titles = []
    parties = []

    page = requests.get(root + url)
    tree = html.fromstring(page.text)

    # Just could not get the birthplace selector to work
    #BIRTHPLACESELECTOR = CSSSelector('margin-top-large p')
    #BIRTHPLACESELECTOR = CSSSelector('p strong')
    #BIRTHPLACESELECTOR = CSSSelector('.border-top-emphasis p strong')

    NAMESELECTOR = CSSSelector('.padding-top')
    #TIMESELECTOR = CSSSelector('div.table-responsive tr td')
    TIMESELECTOR = CSSSelector('.table-responsive:nth-child(5) td')
    #TITLESELECTOR = CSSSelector('div.table-responsive tr td span')
    #TITLESELECTOR = CSSSelector('td:nth-child(2) .r_lineup')
    TITLESELECTOR = CSSSelector('.table-responsive:nth-child(5) td:nth-child(2) .r_lineup')
    PARTYSELECTOR = CSSSelector('td~ td+ td .r_lineup')

    names = NAMESELECTOR(tree)
    # Do not remove the following print (for unknown reason program gives
    # an error without)
    print(names)
    name = names[0].text

    # Hard code a couple exceptions due to later occurring double matches:
    if name == "Vennamo, Veikko":
        # Add more names to not confuse with son, Pekka Veikko Vennamo
        name = "Vennamo, Veikko Emil Aleksander"
    if name == "Koivisto, Juho":
        # to not confuse with Juho Matti Koivisto
        name = "Koivisto, Johannes Juho"
    print(name)

    sections = TIMESELECTOR(tree)
    elements = [str(p.text) for p in sections]
    for el in elements:
        if re.findall(r"^.+\..+$", el):
            date = re.findall(r"^.+\..+$", el)[0]
            dates.append(date)

    sections = TITLESELECTOR(tree)
    elements = [str(p.text) for p in sections]
    for el in elements:
        if re.findall(r"^\D*$", el) and el != "None":
            title = el
            titles.append(title)

    sections = PARTYSELECTOR(tree)
    elements = [str(p.text) for p in sections]
    for el in elements:
        if re.findall(r"^\D*$", el) and el != "None":
            words = re.findall(r"^\D*$", el)
            for word in words:
                if re.match("(?!.*inisteri.*$)", word):
                    party = word
                    parties.append(party)

    assert len(parties) == len(titles)
    assert len(parties) == len(dates)

    for i in range(len(parties)):
        records.append([name, dates[i], titles[i], parties[i]])

with open(path + 'ministers.csv', 'w', newline='', encoding = 'UTF-8') as f:
    writer = csv.writer(f, lineterminator = '\n', delimiter = '|')
    writer.writerows([["name", "in_office", "title", "party"]])
    for record in records:
        writer.writerows([[record[0], record[1], record[2], record[3]]])
