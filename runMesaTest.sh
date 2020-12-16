#!/bin/bash

# Dont let script run more than once
if pidof -x "$(basename $0)" -o $$ >/dev/null; then
    echo "Process already running"
    exit 1
fi

{
echo "**********************"
date

source ~/data/mesa/mesa-helios-test/mesa_test.sh

cd "$MESA_GIT" || exit

# Get all updates over all branches
git fetch --all

if [[ $? != 0 ]];then
	echo "Update failed"
	exit 1
fi

last_ver=-1
# Loop over recent commits
for i in $(git log --since="10 mins" --all --format="%h");
do
	echo "Submitting $i" 

	if [[ $last_ver -lt 0 ]]; then
		last_ver=$(sbatch --parsable --export=VERSION=$i mesa-test.sh)
	else
		last_ver=$(sbatch --dependency=afterany:$last_ver --parsable --export=VERSION=$i mesa-test.sh)
	fi
	echo $last_ver

	# Run one test for now
	exit 0
done
date
echo "**********************"
} 2>&1 | tee -a ~/log_mesa_test.txt
