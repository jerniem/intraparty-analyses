#!/bin/bash
#SBATCH --mail-user=jernie@utu.fi
#SBATCH --job-name=toolexec5_uusimaa
#SBATCH --mail-type=ALL
#SBATCH --ntasks=1
#SBATCH --array=1-100
#SBATCH --mem=30G
#SBATCH --time=03:00:00
#SBATCH --partition=normal

partyvar="uusimaa"
empirical=0
Cpar="Cadj"
covariates="c0_partyf"

fake_indicator=0
python compute-cis.py $partyvar $fake_indicator $empirical $covariates $Cpar
#python compute-cis-test.py $partyvar $fake_indicator $empirical $covariates $Cpar

fake_indicator=1
python compute-cis.py $partyvar $fake_indicator $empirical $covariates $Cpar

