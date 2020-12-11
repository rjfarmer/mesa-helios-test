#!/bin/bash

#SBATCH -N 1
#SBATCH -c 12
#SBATCH -t 6:00:00
#SBATCH --mem 16gb
#SBATCH -J single
#SBATCH --no-requeue

{
echo $SLURM_JOB_NODELIST
echo $SLURM_LOCALID
echo $SLURM_NODE_ALIASES
echo $SLURM_NODEID
echo $SLURM_JOB_ID
echo $SLURMD_NODENAME
echo $MESA_DIR

#Set varaibales
source ~/data/mesa/mesa-helios-test/mesa_test.sh

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
#CD to folder

mkdir -p /hddstore/$USER
export MESA_CACHES_DIR=$(mktemp -d -p /hddstore/$USER)
echo $MESA_CACHES_DIR

ID=$SLURM_ARRAY_TASK_ID

cd $MESA_DIR/$OBJECT/test_suite

folder=$(./list_tests $ID)
echo $folder $ID

mv "$folder" "$MESA_CACHES_DIR/$folder"

ln -sf "${MESA_CACHES_DIR}/${folder}" "${MESA_DIR}/${OBJECT}/test_suite/${folder}"

sed -i '/mesa_dir/d' "$folder"/inlist*
sed -i '/^mesa_dir/d' "$folder/make/makefile"
sed -i '/^mesa_dir/d' "$folder/rn"

sed -i '/MESA_DIR/d' "$folder"/inlist*
sed -i '/^MESA_DIR/d' "$folder/make/makefile"
sed -i '/^MESA_DIR/d' "$folder/rn"


#~/bin/mesa_test test_one $MESA_DIR $ID --force --auto-diff -m=$OBJECT

cp "${MESA_DIR}/${OBJECT}/test_suite/$folder/out.txt" "${OUT_FOLD}/${folder}".txt

rm -rf $MESA_CACHES_DIR
}



