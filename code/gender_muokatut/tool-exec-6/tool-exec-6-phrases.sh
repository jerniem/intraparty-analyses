#!/bin/bash
#SBATCH --job-name=phrase-partisanship
#SBATCH --mail-user=jernie@utu.fi
#SBATCH --mail-type=ALL
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=250G
#SBATCH --time=00:45:00
#SBATCH --partition=gpu

partyvar="gender"
fake_indicator=0
Cpar="Cadj"
covariates="c0_partyf"

# 195G required March 2020
# mem for checkphrases.py 230000

echo "Hosts are"
srun -l hostname
echo "$SLURM_JOB_NODELIST"

srun Rscript compute-phrase-partisanship.R $partyvar $fake_indicator $covariates $Cpar
#Rscript tabulate-phrase-partisanship.R $partyvar $fake_indicator $covariates $Cpar 
#Rscript tabulate-phrase-partisanship-get-qs.R $partyvar $fake_indicator $covariates $Cpar
#Rscript tabulate-rho.R $partyvar $fake_indicator $covariates $Cpar
#Rscript tabulate-rho-get-qs.R $partyvar $fake_indicator $covariates $Cpar


