#!/bin/bash
#SBATCH --mail-user=jernie@utu.fi
#SBATCH --mail-type=ALL
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=50G
#SBATCH --time=04:00:00
#SBATCH --partition=normal

echo "Hosts are"
srun -l hostname
echo "$SLURM_JOB_NODELIST"

partyvar="education"
fake_indicator=0
#covariates="c0"

srun python fig-education-cis.py
