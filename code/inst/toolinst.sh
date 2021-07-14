#!/bin/bash
#SBATCH --job-name=pack
#SBATCH --mail-user=jernie@utu.fi
#SBATCH --mail-type=ALL
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=10G
#SBATCH --time=1:00:00


srun Rscript installnewpac.R

#srun Rscript installnewpac_2.R

#srun Rscript installnewpac_3.R
