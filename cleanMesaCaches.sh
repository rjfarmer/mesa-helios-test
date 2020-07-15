#!/bin/bash

for i in $(seq -f "%03g" 1 19);do
	echo "Removing caches from $i"
	sbatch -t 0-01:00:00 -N 1 -c 1 --mem 4gb --nodelist=helios-cn$i ~/bin/cleanCache.sh
done
