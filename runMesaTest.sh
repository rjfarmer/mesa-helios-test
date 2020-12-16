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
git pull origin main

if [[ $? != 0 ]];then
	echo "Update failed"
	exit 1
fi

last_ver=-1
# Loop over recent commits
for i in $(git log --since="200 minutes" --all --format="%h");
do
	echo "Submitting $i" 

	export OUT_FOLD=$MESA_LOG/$i
	mkdir -p "$OUT_FOLD"

	if [[ $last_ver -lt 0 ]]; then
		last_ver=$(sbatch -o "$OUT_FOLD"/build.txt --parsable --export=VERSION=$i,HOME=$HOME,OUT_FOLD="$OUT_FOLD" "${MESA_SCRIPTS}/mesa-test.sh")
	else
		last_ver=$(sbatch -o "$OUT_FOLD"/build.txt --dependency=afterany:$last_ver --parsable --export=VERSION=$i,HOME=$HOME,OUT_FOLD="$OUT_FOLD" "${MESA_SCRIPTS}/mesa-test.sh")
	fi
	echo $last_ver

	# Run one test for now
	exit 0
done
date
echo "**********************"
} 2>&1 | tee -a ~/log_mesa_test.txt
