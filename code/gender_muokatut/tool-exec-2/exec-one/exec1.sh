#!/bin/bash
#SBATCH --mail-user=jernie@utu.fi
#SBATCH --job-name=estimate-1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=20
#SBATCH --ntasks=1
#SBATCH --array=1
#SBATCH --mem=20G
#SBATCH --time=02:00:00
#SBATCH --partition=normal

# aiemmin oli array=5

echo "Hosts are"
srun -l hostname
echo "$SLURM_JOB_NODELIST"

partyvar="gender"
covariates="c0_partyf"
fake_indicator=0

# Defaults
nr_datasets=10
nr_cores=2
penalty=1
Cpar="Cadj"

if [ $covariates == "c0" ]
then
    srun Rscript compute-multidata-estimate.R $nr_cores data_"$SLURM_ARRAY_TASK_ID" $partyvar $fake_indicator $penalty $Cpar

elif [ $covariates == "c0_partyf" ]
then
    srun Rscript compute-multidata-estimate-c0_partyf.R $nr_cores data_"$SLURM_ARRAY_TASK_ID" $partyvar $fake_indicator $penalty $Cpar

elif [ $covariates == "c1" ]
then
    srun Rscript compute-multidata-estimate-c1.R $nr_cores data_"$SLURM_ARRAY_TASK_ID" $partyvar $fake_indicator $penalty $Cpar

elif [ $covariates == "c2" ]
then
    srun Rscript compute-multidata-estimate-c2.R $nr_cores data_"$SLURM_ARRAY_TASK_ID" $partyvar $fake_indicator $penalty $Cpar

elif [ $covariates == "c3" ]
then
    srun Rscript compute-multidata-estimate-c3.R $nr_cores data_"$SLURM_ARRAY_TASK_ID" $partyvar $fake_indicator $penalty $Cpar

elif [ $covariates == "c4" ]
then
    srun Rscript compute-multidata-estimate-c4.R $nr_cores data_"$SLURM_ARRAY_TASK_ID" $partyvar $fake_indicator $penalty $Cpar

elif [ $covariates == "c99" ]
then
    srun Rscript compute-multidata-estimate-c99.R $nr_cores data_"$SLURM_ARRAY_TASK_ID" $partyvar $fake_indicator $penalty $Cpar

elif [ $covariates == "c100" ]
then
    srun Rscript compute-multidata-estimate-c100.R $nr_cores data_"$SLURM_ARRAY_TASK_ID" $partyvar $fake_indicator $penalty $Cpar
fi
