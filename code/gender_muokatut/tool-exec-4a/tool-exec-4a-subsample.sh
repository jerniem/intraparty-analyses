#!/bin/bash
#SBATCH --mail-user=jernie@utu.fi
#SBATCH --job-name=subsampling-1
#SBATCH --mail-type=ALL
#SBATCH -e slurm-subsampling-errors-left-1.txt
#SBATCH -o slurm-subsampling-output.txt
#SBATCH --ntasks=1
#SBATCH --array=1-100
#SBATCH --mem=40G
#SBATCH --time=05:00:00

# Change:
partyvar="gender"
fake_indicator=0
covariates="c0_partyf"

# Defaults
penalty=1
Cpar="Cadj"

echo "Hosts are"
srun -l hostname
echo "$SLURM_JOB_NODELIST"

if [ $covariates == "c0" ]
then
    srun Rscript subsampling.R $SLURM_ARRAY_TASK_ID $partyvar $fake_indicator $penalty $Cpar

elif [ $covariates == "c0_partyf" ]
then
    srun Rscript subsampling-c0_partyf.R $SLURM_ARRAY_TASK_ID $partyvar $fake_indicator $penalty $Cpar
    #srun Rscript strat-subsampling-c0_partyf.R $SLURM_ARRAY_TASK_ID $partyvar $fake_indicator $penalty $Cpar
elif [ $covariates == "c1" ]
then
    srun Rscript subsampling-c1.R $SLURM_ARRAY_TASK_ID $partyvar $fake_indicator $penalty $Cpar

elif [ $covariates == "c2" ]
then
    srun Rscript subsampling-c2.R $SLURM_ARRAY_TASK_ID $partyvar $fake_indicator $penalty $Cpar

elif [ $covariates == "c3" ]
then
    srun Rscript subsampling-c3.R $SLURM_ARRAY_TASK_ID $partyvar $fake_indicator $penalty $Cpar

elif [ $covariates == "c4" ]
then
    srun Rscript subsampling-c4.R $SLURM_ARRAY_TASK_ID $partyvar $fake_indicator $penalty $Cpar

elif [ $covariates == "c99" ]
then
    srun Rscript subsampling-c99.R $SLURM_ARRAY_TASK_ID $partyvar $fake_indicator $penalty $Cpar

elif [ $covariates == "c100" ]
then
    srun Rscript subsampling-c100.R $SLURM_ARRAY_TASK_ID $partyvar $fake_indicator $penalty $Cpar

fi
