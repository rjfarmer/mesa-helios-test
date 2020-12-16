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
echo $MODULE $SLURM_ARRAY_TASK_ID

#Set variables
source ~/data/mesa/mesa-helios-test/mesa_test.sh

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# Where we will run one test case
mkdir -p /hddstore/$USER
export MESA_CACHES_DIR=$(mktemp -d -p /hddstore/$USER)
echo $MESA_CACHES_DIR

ID=$SLURM_ARRAY_TASK_ID

cd "${MESA_DIR}/${MODULE}/test_suite"

# Map id number to MESA test case name
folder=$(./list_tests $ID)
echo $folder $ID

# We want to run mesa on a local hard drive but store MESA_DIR
# on the network.
# This moves the folder onto the local hard drive,
# then soft links back to MESA_DIR so mesa_test does not get confused about missing test cases
# Then we need to fix the inlists now that we are running outside of MESA_DIR

mv "$folder" "${MESA_CACHES_DIR}/${folder}"

ln -sf "${MESA_CACHES_DIR}/${folder}" "${MESA_DIR}/${MODULE}/test_suite/${folder}"

sed -i '/mesa_dir/Id' "${folder}"/inlist*
sed -i '/^mesa_dir/Id' "${folder}/make/makefile"
sed -i '/^mesa_dir/Id' "${folder}/rn"
sed -i '/^mesa_dir/Id' "${folder}/ck"

~/bin/mesa_test $MESA_TEST_VERSION test -m=$MODULE --mesadir=$MESA_DIR $ID

cp "${MESA_DIR}/${MODULE}/test_suite/${folder}/out.txt" "${OUT_FOLD}/${folder}".txt

rm "$folder"
mv "${MESA_CACHES_DIR}/${folder}" "$folder"

rm -rf "${MESA_CACHES_DIR}"
}



