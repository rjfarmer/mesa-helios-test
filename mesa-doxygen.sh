#!/bin/bash

#SBATCH -N 1
#SBATCH -c 4
#SBATCH -t 24:00:00
#SBATCH --mem 16gb
#SBATCH -J doxygen
#SBATCH --no-requeue

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

MESA_DIR=$(mktemp -d -p /hddstore/rfarmer/)
echo $MESA_DIR

mkdir -p "$OUT_FOLD"

skip_tests=0
svn co -r "$VIN" file:///home/rfarmer/mesa/mesa/assembla_mesa/trunk "$MESA_DIR"

if [[ $? != 0 ]]; then
	echo "checkout failed"
	exit 1
fi

cd "$MESA_DIR"
source $HOME/mesa/scripts/mesa_test.sh
export MESA_DIR
./clean
./install

echo "Running doxygen"
cd "$MESA_DIR"
sed -i "s/PROJECT_NUMBER\ \ \ \ \ \ \ \ \ =.*/PROJECT_NUMBER\ \ \ \ \ \ \ \ \ =\ $VIN/" Doxyfile
"$HOME"/bin/doxygen Doxyfile
if [[ $? == 0 ]];then
	echo "Doxygen succesfully built uploading"
	rsync -avz --delete dox/html/* rfarmer1@web.sourceforge.net:/home/project-web/mesa/htdocs/dox/
fi

rm -rf $MESA_DIR

} 2>&1 | tee "$OUT_FOLD"/doxygen.txt


