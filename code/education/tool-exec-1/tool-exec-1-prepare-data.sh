#!/bin/bash
#SBATCH --job-name=prepare-data-educ
#SBATCH --mail-user=jernie@utu.fi
#SBATCH --mail-type=ALL
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=30G
#SBATCH --time=10:00:00
#SBATCH --partition=normal

# originally time 2 hours

partyvar="education"
nr_datasets=10
Cpar="Cadj"

# Create speaker_metadata.csv
srun python prepare-data-1.py

# Make directory for files to temp
mkdir /home/jernie/analysis/temp/$partyvar
mkdir /home/jernie/analysis/temp/$partyvar/inference
mkdir /home/jernie/analysis/output/$partyvar

###############################################################################
## CHANGE PARTYVAR IN CODE!! IT IS HARDCODED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
###############################################################################

# Create RDS files
srun Rscript prepare-data-2.R

# Optional: adjust C data 
srun Rscript prepare-data-2b.R $partyvar

# Split RDS files
srun Rscript prepare-data-3.R $nr_datasets $partyvar $Cpar
