import delimited "/Users/jeremiasnieminen/Dropbox/local_speech/descriptives/descriptives-speakers.csv", encoding(ISO-8859-2) 



*line fshare_speech year, ytitle(share of speech)
*graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/fshare_speech.png", replace

*line fshare_mps year, ytitle(share of MPs)
*graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/fshare_mps.png", replace

*line fshare_speakers year, ytitle(share of speakers)
*graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/fshare_speakers.png", replace

* samassa
line fshare_speech fshare_mps fshare_speakers year
graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/fshare_combined.png", replace





*line ushare_speech year, ytitle(share of speech)
*graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/ushare_speech.png", replace

*line ushare_mps year, ytitle(share of MPs)
*graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/ushare_mps.png", replace

*line ushare_speakers year, ytitle(share of speakers)
*graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/ushare_speakers.png", replace


* samassa
line ushare_speech ushare_mps ushare_speakers year, title("Uusimaa & Helsinki")
graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/ushare_combined.png", replace



*line yshare_speech year, ytitle(share of speech)
*graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/yshare_speech.png", replace

*line yshare_mps year, ytitle(share of MPs)
*graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/yshare_mps.png", replace

*line yshare_speakers year, ytitle(share of speakers)
*graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/yshare_speakers.png", replace

* samassa
line yshare_speech yshare_mps yshare_speakers year, title("Age under 40")
graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/yshare_combined.png", replace



*line hshare_speech year, ytitle(share of speech)
*graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/hshare_speech.png", replace

*line hshare_mps year, ytitle(share of MPs)
*graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/hshare_mps.png", replace

*line hshare_speakers year, ytitle(share of speakers)
*graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/hshare_speakers.png", replace


* samassa
line hshare_speech hshare_mps hshare_speakers year, title("Higher education")
graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/hshare_combined.png", replace



*line wshare_speech year, ytitle(share of speech)
*graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/wshare_speech.png", replace

*line wshare_mps year, ytitle(share of MPs)
*graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/wshare_mps.png", replace

*line wshare_speakers year, ytitle(share of speakers)
*graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/wshare_speakers.png", replace


* samassa

line wshare_speech wshare_mps wshare_speakers year, title("White-collar profession")
graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/wshare_combined.png", replace





* firstterm samassa
line ftshare_speech ftshare_mps ftshare_speakers year, title("First term MPs")
graph export "/Users/jeremiasnieminen/intraparty-analyses/descriptives/new/ftshare_combined.png", replace






