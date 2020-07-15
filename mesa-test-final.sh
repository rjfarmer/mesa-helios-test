#!/bin/bash
#SBATCH -N 1
#SBATCH -c 1
#SBATCH -t 1:00:00
#SBATCH --mem 16gb
#SBATCH -J mesatestfinal
#SBATCH --no-requeue
#SBATCH --exclude=helios-cn001,helios-cn004



echo $SLURM_JOB_NODELIST
echo $SLURM_LOCALID
echo $SLURM_NODE_ALIASES
echo $SLURM_NODEID
echo $SLURM_JOB_ID
echo $SLURMD_NODENAME
echo $HOME
echo $MESA_DIR
echo $OUT_FOLD

#Set variables
cd $HOME/mesa/scripts
source $HOME/mesa/scripts/mesa_test.sh

#/bin/mesa_test submit_revision $MESA_DIR --force

#export output=$(head -n 1 $MESA_DIR/testfolder)

function cp_output {
	for i in $(find ${MESA_DIR} -name $1); do
        	cp $i ${OUT_FOLD}/"$(basename "$(dirname "$i")")".$1
	done
}

#cp_output out.txt
#cp_output final_check_diff.txt
#cp_output restart_photo

#for i in $(find $MESA_DIR -name out.txt); do
#	cp ${i} ${OUT_FOLD}/"$(basename "$(dirname "$i")")".out.txt
#done

#for i in $(find $MESA_DIR -name final_check_diff.txt); do
#        cp $i $OUT_FOLD/"$(basename "$(dirname "$i")")".final_check_diff.txt
#done

#for i in $(find $MESA_DIR -name restart_photo); do
#        cp $i $OUT_FOLD/"$(basename "$(dirname "$i")")".final_check_diff.txt
#done


rm -rf $MESA_DIR

