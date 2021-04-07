#!/bin/bash

source ~/.bashrc
source ~/data/mesa/mesa-helios-test/mesa_vars.sh

i=$1

export OUT_FOLD=$MESA_LOG/$i
mkdir -p "$OUT_FOLD"

sbatch -o "$OUT_FOLD"/build.txt --parsable --export=VERSION=$i,HOME=$HOME,OUT_FOLD="$OUT_FOLD" "${MESA_SCRIPTS}/mesa-test.sh"
