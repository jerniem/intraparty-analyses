set graphics off

import delimited "/Users/jeremiasnieminen/Dropbox/local_speech/analysis/input/speaker_metadata_bipartisan.csv", encoding(UTF-8) clear

gen number = 1

gen n_females = 1 if female == 1
gen n_under40 = 1 if under40 == 1
gen n_whitecollar = 1 if whitecollar == 1
gen n_education = 1 if education == 1

collapse(sum) number n_females n_under40 n_whitecollar n_education, by(year)

line n_females year
graph export "/Users/jeremiasnieminen/Dropbox/local_speech/descriptives/n_females.png", replace

line n_under40 year
graph export "/Users/jeremiasnieminen/Dropbox/local_speech/descriptives/n_under40.png", replace

line n_whitecollar year
graph export "/Users/jeremiasnieminen/Dropbox/local_speech/descriptives/n_whitecollar.png", replace

line n_education year
graph export "/Users/jeremiasnieminen/Dropbox/local_speech/descriptives/n_highereducation.png", replace


gen sharef = n_females/number
gen sharewhitecollar = n_whitecollar/number
gen shareunder40 = n_under40/number
gen shareeducation = n_education/number


line sharef year
graph export "/Users/jeremiasnieminen/Dropbox/local_speech/descriptives/share_females.png", replace


line sharewhitecollar year
graph export "/Users/jeremiasnieminen/Dropbox/local_speech/descriptives/share_whitecollar.png", replace


line shareunder40 year
graph export "/Users/jeremiasnieminen/Dropbox/local_speech/descriptives/share_under40.png", replace


line shareeducation year
graph export "/Users/jeremiasnieminen/Dropbox/local_speech/descriptives/share_highereducation.png", replace



line number year
graph export "/Users/jeremiasnieminen/Dropbox/local_speech/descriptives/number_per_year.png", replace





import delimited "/Users/jeremiasnieminen/Dropbox/local_speech/analysis/input/speaker_metadata_bipartisan.csv", encoding(UTF-8) clear

gen number = 1

gen n_females = 1 if female == 1
gen n_under40 = 1 if under40 == 1
gen n_whitecollar = 1 if whitecollar == 1
gen n_education = 1 if education == 1

collapse(sum) number n_females n_under40 n_whitecollar n_education, by(year party)

gen sharef = n_females/number
gen sharewhitecollar = n_whitecollar/number
gen shareunder40 = n_under40/number
gen shareeducation = n_education/number

drop if missing(party)

drop if party == "-"


replace party = "Sosialistinen eduskuntaryhmä kuutoset" in 283
replace party = "Sosialistinen eduskuntaryhmä kuutoset" in 305

levelsof party, local(levels) 

set trace on


foreach l of local levels {
	*mkdir "/Users/jeremiasnieminen/Dropbox/local_speech/descriptives/by_party/`l'/"
	line sharef year if party == `"`l'"', ytitle("share of women") xlabel(1907(20)2019)
	graph export "/Users/jeremiasnieminen/Dropbox/local_speech/descriptives/by_party/`l'/sharef.png", replace
	
	line sharewhitecollar year if party == `"`l'"', ytitle("share of white-collar MPs") xlabel(1907(20)2019)
	graph export "/Users/jeremiasnieminen/Dropbox/local_speech/descriptives/by_party/`l'/sharewhitecollar.png", replace
	
	line shareunder40 year if party == `"`l'"', ytitle("share of MPs younger than 40") xlabel(1907(20)2019)
	graph export "/Users/jeremiasnieminen/Dropbox/local_speech/descriptives/by_party/`l'/shareunder40.png", replace
	
	line shareeducation year if party == `"`l'"', ytitle("share of MPs with higher education") xlabel(1907(20)2019)
	graph export "/Users/jeremiasnieminen/Dropbox/local_speech/descriptives/by_party/`l'/shareeducation.png", replace
}



