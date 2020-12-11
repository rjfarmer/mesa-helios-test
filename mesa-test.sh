#!/bin/bash

#SBATCH -N 1
#SBATCH -c 4
#SBATCH -t 24:00:00
#SBATCH --mem 16gb
#SBATCH -J test-build
#SBATCH --no-requeue

echo $HOME
echo $OUT_FOLD
echo "-----"

{
# Dont let this file get confused with mesa_test.sh
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
	echo "script ${BASH_SOURCE[0]} is being sourced ..."
	exit 1
fi

echo $SLURM_JOB_NODELIST
echo $SLURM_LOCALID
echo $SLURM_NODE_ALIASES
echo $SLURM_NODEID
echo $SLURM_JOB_ID
echo $SLURMD_NODENAME
echo $OUT_FOLD
echo $HOME
echo "**********"
#Set variables

source ~/data/mesa/mesa-helios-test/mesa_test.sh
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

echo $MESASDK_ROOT

echo $VERSION

# Limit number of mesa's being tested at once
while [[ $(ls -d "$MESA_TMP"/tmp.* | wc -l) -gt 10 ]];
do
	echo "Too many tests in progress sleeping"
	date
	sleep 10m
done

# Make a temporay folder to build mesa in
export MESA_DIR=$(mktemp -d -p "$MESA_TMP")
echo $MESA_DIR

export OUT_FOLD=$MESA_LOG/$VERSION
mkdir -p "$OUT_FOLD"
echo $OUT_FOLD

# Checkout to new folder
git clone $MESA_GIT $MESA_DIR

if [[ $? != 0 ]]; then
	echo "Clone failed"
	exit 1
fi

cd $MESA_DIR || exit

git checkout $VERSION
if [[ $? != 0 ]]; then
        echo "checkout failed"
        exit 1
fi

# Look for tests to be skipped
export skip_tests=0
if [[ $(git log -1) == *'[ci skip]'* ]];then
        skip_tests=1
fi

./clean

./install
error_code=$?

#~/bin/mesa_test submit_revision "$MESA_DIR" --force

# Check if mesa installed correctly
if [[ $error_code != 0 ]] || [[ ! -f "$MESA_DIR/lib/libstar.a" ]]; then
	echo "Install failed"
	cd "$HOME" || exit
	rm -rf "$MESA_DIR"
	exit 1
fi

rm "$MESA_DIR"/data/*/cache/*


depend="$SLURM_JOB_ID"

# Submit test cases
if [[ $skip_tests -eq 0 ]]; then
	for i in star binary astero;
	do
		cd "$MESA_DIR"/$i/test_suite || exit
		count=$(./count_tests)
		if [[ -z "$count" ]];then
			echo "No $i tests found"
		else
			cd "$MESA_CLUSTER" || exit
			slurm_id=$(sbatch -a 1-"$count"%20 -o "$OUT_FOLD/${i}-%a.out" --export=MESA_DIR="$MESA_DIR",OUT_FOLD="$OUT_FOLD",OBJECT="$i" --parsable "$MESA_SCRIPTS"/mesa-run-test-suite.sh)
			depend=${depend}":$slurm_id"
		fi		
		echo $i $slurm_id
	done
fi
echo "$depend"
cd "$MESA_SCRIPTS" || exit
# Cleanup script to remove MESA_DIR
sbatch -o "${OUT_FOLD}"/test-final.out --dependency=afterany:"$depend" --export=HOME="$HOME",OUT_FOLD="$OUT_FOLD" "${MESA_SCRIPTS}/mesa-test-final.sh"



} 2>&1 | tee "${OUT_FOLD}"/tee.txt


