#!/bin/bash

# Dont let script run more than once
if pidof -x "$(basename $0)" -o $$ >/dev/null; then
    echo "Process already running"
    exit 1
fi

{
echo "**********************"
date

source ~/.bashrc
source ~/data/mesa/mesa-helios-test/mesa_vars.sh

cd "$MESA_GIT" || exit

# Get all updates over all branches
git fetch --all
git pull origin main

# remove now deleted branches
git remote prune origin

if [[ $? != 0 ]];then
	echo "Update failed"
	exit 1
fi

last_ver=-1
# Loop over recent commits, do both time and number to catch when things go wrong
for i in $(git log --since="20 minutes" --all --format="%h") $(git log -10 --all --format="%h");
do
	export OUT_FOLD=$MESA_LOG/$i

	if [ -d $OUT_FOLD ]; then
		echo "Skipping $i"
		continue
	else
		echo "Submitting $i" 
		mkdir -p "$OUT_FOLD"
	fi

	if [[ $last_ver -lt 0 ]]; then
		last_ver=$(sbatch -o "$OUT_FOLD"/build.txt --parsable --export=VERSION=$i,HOME=$HOME,OUT_FOLD="$OUT_FOLD" "${MESA_SCRIPTS}/mesa-test.sh")
	else
		last_ver=$(sbatch -o "$OUT_FOLD"/build.txt --dependency=afterany:$last_ver --parsable --export=VERSION=$i,HOME=$HOME,OUT_FOLD="$OUT_FOLD" "${MESA_SCRIPTS}/mesa-test.sh")
	fi
	echo $last_ver

done

# Clean up old folders
#cd $MESA_LOG
#find . -mindepth 1 -maxdepth 1 -type d -ctime +10 -exec rm -rf {} +

date
echo "**********************"
} 2>&1 | tee -a ~/log_mesa_test.txt
