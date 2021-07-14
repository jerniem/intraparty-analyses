#!/bin/bash
#SBATCH --mail-user=jernie@utu.fi
#SBATCH --job-name=subsampling-empirical-1
#SBATCH --mail-type=ALL
#SBATCH -e slurm-subsampling-errors-1.txt
#SBATCH -o slurm-subsampling-output.txt
#SBATCH --ntasks=1
#SBATCH --array=1-100
#SBATCH --mem=30G
#SBATCH --time=03:00:00
#SBATCH --partition=normal

echo "Hosts are"
srun -l hostname
echo "$SLURM_JOB_NODELIST"

partyvar="uusimaa"
nr_datasets=10
nr_cores=3
fake_indicator=0
penalty=1
Cpar="Cadj"

srun Rscript subsampling-empirical.R $SLURM_ARRAY_TASK_ID $partyvar $fake_indicator $Cpar

