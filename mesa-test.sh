#!/bin/bash

#SBATCH -N 1
#SBATCH -c 4
#SBATCH -t 24:00:00
#SBATCH --mem 16gb
#SBATCH -J test-build
#SBATCH --no-requeue
#SBATCH  --exclude=helios-cn007

echo $HOME
echo $OUT_FOLD
echo "-----"

source ~/.bashrc

{
# Dont let this file get confused with mesa_test.sh
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
	echo "script ${BASH_SOURCE[0]} is being sourced ..."
	exit 1
fi
date
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
while [[ $(ls -d "${MESA_TMP}"/tmp.* | wc -l) -gt 10 ]];
do
	echo "Too many tests in progress sleeping"
	date
	sleep 10m
done

# Make a temporay folder to build mesa in
export MESA_DIR=$(mktemp -d -p "$MESA_TMP")
echo $MESA_DIR
echo $HOME

export MESA_GIT_LFS_SLEEP=10

# Checkout and install to new folder
~/bin/mesa_test $MESA_TEST_VERSION install -c --mesadir=$MESA_DIR $VERSION 

~/bin/mesa_test $MESA_TEST_VERSION submit -e --mesadir=$MESA_DIR


if ! grep -q "MESA installation was successful" "$MESA_DIR/build.log" ; then
	echo "Checkout failed"
	rm -rf $MESA_DIR
	exit 1
fi
date

cd "${MESA_DIR}" || exit

# Look for tests to be skipped
export skip_tests=0
if [[ $(git log -1) == *'[ci skip]'* ]];then
	export skip_tests=1
fi

# Should we split test cases?
export split_tests=0
if [[ $(git log -1) == *'[ci split]'* ]];then
  	export split_tests=1
fi



rm "${MESA_DIR}"/data/*/cache/*


depend="$SLURM_JOB_ID"

# Submit test cases
if [[ $skip_tests -eq 0 ]]; then
	for module in star binary astero;
	do
		cd "${MESA_DIR}/${module}/test_suite" || exit
		count=$(./count_tests)
		if [[ -z "$count" ]];then
			echo "No $module tests found"
		else
			tests="1-${count}%20"
			if [[ $split_tests -eq 1 ]];then
			    tests="$((count/2))-${count}%20"
			fi
			echo "Running tests: $tests"
			slurm_id=$(sbatch -a $tests -o "${OUT_FOLD}/${module}-%a.out" --export=MESA_DIR="${MESA_DIR}",HOME=$HOME,OUT_FOLD="${OUT_FOLD}",MODULE="${module}" --parsable "${MESA_SCRIPTS}/mesa-run-test-suite.sh")
			depend=${depend}":$slurm_id"
		fi
		echo $module $slurm_id
	done
fi
echo "$depend"
cd "$MESA_SCRIPTS" || exit
# Cleanup script to remove MESA_DIR
sbatch -o "${OUT_FOLD}"/test-final.out --dependency=afterany:"${depend}" --export=MESA_DIR="$MESA_DIR" "${MESA_SCRIPTS}/mesa-test-final.sh"

}


