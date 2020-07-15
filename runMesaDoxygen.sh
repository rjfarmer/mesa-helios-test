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

source ~/mesa/scripts/mesa_test.sh

export OUT_FOLD="$testhub/$i"-1
mkdir $OUT_FOLD
echo "Submitting $i" $OUT_FOLD
export VIN=$i

sbatch --parsable --export=VIN=$i,HOME=$HOME,OUT_FOLD=$OUT_FOLD -o "$OUT_FOLD/dxoygen.txt" mesa-doxygen.sh
echo "**********************"
} 2>&1 | tee -a ~/log_mesa_doxygen.txt
