#!/bin/bash

#SBATCH -N 1
#SBATCH -c 4
#SBATCH -t 24:00:00
#SBATCH --mem 16gb
#SBATCH -J test-build
#SBATCH --no-requeue
#SBATCH --exclude=helios-cn001,helios-cn004

echo $HOME
echo $OUT_FOLD
echo "-----"

{
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
cd $HOME/mesa/scripts

source $HOME/mesa/scripts/mesa_test.sh

echo $MESASDK_ROOT

echo $VIN

export OUT_FOLD="$HOME/mesa/mesa/testhub/$VIN-$SDK"
echo $OUT_FOLD

while [[ $(ls -d ~/mesa/mesa/mesatest/tmp.* | wc -l) -gt 10 ]];
do
	echo "Too many tests in progress sleeping"
	date
	sleep 10m
done


MESA_DIR=$(mktemp -d -p ~/mesa/mesa/mesatest)
echo $MESA_DIR

mkdir -p "$OUT_FOLD"


skip_tests=0
svn co -r "$VIN" file:///home/rfarmer/mesa/mesa/assembla_mesa/trunk "$MESA_DIR"

if [[ $? != 0 ]]; then
	echo "checkout failed"
	exit 1
fi

if [[ $(svn log -r "$VIN" file:///home/rfarmer/mesa/mesa/assembla_mesa/trunk) == *'[ci skip]'* ]];then
        skip_tests=1
fi


echo "* $MESA_DIR"
cd "$MESA_DIR"
source $HOME/mesa/scripts/mesa_test.sh
export MESA_DIR

./clean

./install
error_code=$?

~/bin/mesa_test submit_revision "$MESA_DIR" --force

if [[ $error_code != 0 ]] || [[ ! -f "$MESA_DIR/lib/libstar.a" ]]; then
	echo "Install failed"
	cd "$HOME"
	rm -rf "$MESA_DIR"
	exit 1
fi

#rm "$MESA_DIR"/data/*/cache/*


depend="$SLURM_JOB_ID"

if [[ $skip_tests -eq 0 ]]; then
	cd "$MESA_DIR"/star/test_suite
	star_count=$(./count_tests)
	if [[ -z "$star_count" ]];then
		echo "No star tests found"
	else
		cd "$MESA_CLUSTER"
		single=$(sbatch -a 1-"$star_count"%20 -o "$OUT_FOLD/single-%a.out" --export=MESA_DIR="$MESA_DIR",HOME="$HOME",OUT_FOLD="$OUT_FOLD" --parsable ./mesa-single.sh)
		depend=${depend}":$single"
	fi

	cd "$MESA_DIR"/binary/test_suite
	binary_count=$(./count_tests)
	if [[ -z "$binary_count" ]]; then
		echo "No binary tests found"
	else
		cd "$MESA_CLUSTER"
		binary=$(sbatch -a 1-"$binary_count" -o "$OUT_FOLD/binary-%a.out" --export=MESA_DIR="$MESA_DIR",HOME="$HOME",OUT_FOLD="$OUT_FOLD" --parsable ./mesa-binary.sh)
		depend=${depend}":$binary"
	fi


	cd "$MESA_DIR"/astero/test_suite
        astero_count=$(./count_tests)
        if [[ -z "$astero_count" ]]; then
                echo "No astero tests found"
        else
            	cd "$MESA_CLUSTER"
                astero=$(sbatch -a 1-"$astero_count" -o "$OUT_FOLD/astero-%a.out" --export=MESA_DIR="$MESA_DIR",HOME="$HOME",OUT_FOLD="$OUT_FOLD" --parsable ./mesa-astero.sh)
                depend=${depend}":$astero"
        fi


	echo "Star " $star_count "binary " $binary_count "Astero " $astero_count
	echo $single $binary $astero
else
	cd "$MESA_CLUSTER"
	single=$(sbatch -a 1-1 -o "$OUT_FOLD/single-%a.out" --export=MESA_DIR="$MESA_DIR",HOME="$HOME",OUT_FOLD="$OUT_FOLD" --parsable ./mesa-single.sh)
	depend=${depend}":$single"
fi
echo $depend
cd $HOME/mesa/scripts/
sbatch -o "$OUT_FOLD"/test-final.out --dependency=afterany:"$depend" --export=HOME="$HOME",MESA_DIR="$MESA_DIR",OUT_FOLD="$OUT_FOLD" ./mesa-test-final.sh



} 2>&1 | tee "$OUT_FOLD"/tee.txt


