#!/bin/bash

source ~/.bashrc
source ~/data/mesa/mesa-helios-test/mesa_vars.sh

i=$1

export OUT_FOLD=$MESA_LOG/${i}_single
rm -rf "$OUT_FOLD"
mkdir -p "$OUT_FOLD"

sbatch -o "$OUT_FOLD"/build.txt --parsable --export=VERSION=$i,HOME=$HOME,OUT_FOLD="$OUT_FOLD",SKIP_OPTS=1 "${MESA_SCRIPTS}/mesa-test.sh"
