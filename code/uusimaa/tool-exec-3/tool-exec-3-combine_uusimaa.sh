#!/bin/bash
#SBATCH --job-name=combine
#SBATCH --mail-user=jernie@utu.fi
#SBATCH --mail-type=ALL
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=250G
#SBATCH --time=01:00:00
#SBATCH --partition=gpu

# Change:
partyvar="uusimaa"
covariates="c0_partyf"
fake_indicator=1

# Default:
nr_datasets=10
penalty=1
Cpar="Cadj"

# mem for checkphrases.py 230000

echo "Hosts are"
srun -l hostname
echo "$SLURM_JOB_NODELIST"

srun Rscript compute-multidata-combine.R $nr_datasets $partyvar $fake_indicator $penalty $covariates $Cpar
