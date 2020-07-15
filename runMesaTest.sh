#!/bin/bash

MIN_SAFE=13900

if pidof -x "`basename $0`" -o $$ >/dev/null; then
    echo "Process already running"
    exit 1
fi

{
echo "**********************"
echo $(date)
cd ~/mesa/scripts
pwd

svnsync sync file:///home/rfarmer/mesa/mesa/assembla_mesa
if [[ $? != 0 ]];then
	echo "Update failed"
	exit 1
fi

VIN=$(svn info file:///home/rfarmer/mesa/mesa/assembla_mesa)
if [[ $? != 0 ]];then
   echo "Subversion down"
   exit 1
fi

if [[ -z "$VIN" ]];then
   echo "Subversion failed"
   exit 1
fi

export v_end=$(echo -e "$VIN" | grep Revision | awk '{print $2}')

if [[ -z $v_end ]];then
	echo "Head is empty"
	exit 1
fi

if [[ $v_end -lt $MIN_SAFE ]]; then
	echo "Version below safe version" $v_end
	exit 1
fi

echo "Head is $v_end"


export testhub="$HOME/mesa/mesa/testhub/"
export OUT_FOLD="$testhub/$v_end-1"
echo $testhub
echo $OUT_FOLD
if [[ -d "$OUT_FOLD" ]]; then
	echo "Already tested up to $v_end"
        exit 0
fi

v_start=$(basename $(find $testhub -maxdepth 1 -type d  | sort | tail -n 1 | cut -f1 -d"-"))
v_start=$((v_start+1))
echo "Start is $v_start"

source ~/mesa/scripts/mesa_test.sh
#rm ${MESA_OP_MONO_DATA_CACHE_FILENAME} 2>/dev/null

if [[ "$v_end" -lt "$v_start" ]];then
	echo "Head lt start" $v_end $vstart
	exit 1
fi

last_ver=-1
for i in $(seq $v_start 1 $v_end);
do
	if [[ "$i" -lt $MIN_SAFE ]]; then
        	echo "PANIC PANIC PANIC" $i
        	exit 1
	fi


	export OUT_FOLD="$testhub/$i"-1
	mkdir $OUT_FOLD
	if [[ $? -eq 1 ]];then
		echo "Folder exists exit"
		exit 1
	fi

	echo "Submitting $i" $OUT_FOLD
	export VIN=$i

	export doxygen=0
	if [[ $i -eq $v_end ]]; then
		export dox_file=~/.dox.update
		if [[ $(($(($(date +%s) - $(stat $dox_file  -c %Y))) / 86400)) -ge 1 ]]; then
			export doxygen=1
			echo "Running doxygen"
			touch $dox_file
		fi
	fi

	if [[ $last_ver -lt 0 ]]; then
		last_ver=$(sbatch --parsable --export=VIN=$i,doxygen=$doxygen,HOME=$HOME,OUT_FOLD=$OUT_FOLD -o "$OUT_FOLD/build.txt" mesa-test.sh)
	else
		last_ver=$(sbatch --dependency=afterany:$last_ver --parsable --export=VIN=$i,doxygen=$doxygen,HOME=$HOME,OUT_FOLD=$OUT_FOLD -o "$OUT_FOLD/build.txt" mesa-test.sh)
	fi
	echo $last_ver
done
echo "**********************"
} 2>&1 | tee -a ~/log_mesa_test.txt
