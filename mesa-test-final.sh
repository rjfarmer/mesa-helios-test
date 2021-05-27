#!/bin/bash
#SBATCH -N 1
#SBATCH -c 1
#SBATCH -t 1:00:00
#SBATCH --mem 16gb
#SBATCH -J mesatestfinal
#SBATCH --no-requeue
#SBATCH  --exclude=helios-cn007,helios-cn001

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
source ~/data/mesa/mesa-helios-test/mesa_vars.sh

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

echo $MESA_GIT
git -C "$MESA_GIT" worktree remove --force "$MESA_DIR"
rm -rf "$MESA_DIR" # Just in case
