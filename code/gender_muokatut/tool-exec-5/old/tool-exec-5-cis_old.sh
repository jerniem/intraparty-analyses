#!/bin/bash

partyvar="left"
empirical=0
Cpar="Cadj"
covariates="c100"


fake_indicator=0
python compute-cis.py $partyvar $fake_indicator $empirical $covariates $Cpar
#python compute-cis-test.py $partyvar $fake_indicator $empirical $covariates $Cpar

fake_indicator=1
python compute-cis.py $partyvar $fake_indicator $empirical $covariates $Cpar

