#!/bin/bash
#SBATCH -N 1
#SBATCH -c 1
#SBATCH -t 1:00:00
#SBATCH --mem 16gb
#SBATCH -J mesatestfinal
#SBATCH --no-requeue

echo $SLURM_JOB_NODELIST
echo $SLURM_LOCALID
echo $SLURM_NODE_ALIASES
echo $SLURM_NODEID
echo $SLURM_JOB_ID
echo $SLURMD_NODENAME
echo $HOME
echo $MESA_DIR
echo $OUT_FOLD

source ~/.bashrc

#Set variables
source ~/data/mesa/mesa-helios-test/mesa_test.sh

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

rm -rf "$MESA_DIR"

