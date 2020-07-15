

export MESA_ROOT=~/mesa
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export MESASDK_ROOT=$MESA_ROOT/sdk/mesasdk-20.3.1
export MESA_CLUSTER=$MESA_ROOT/scripts
export GYRE_DIR=$MESA_DIR/gyre/gyre
source $MESASDK_ROOT/bin/mesasdk_init.sh
export LD_LIBRARY_PATH=$MESA_DIR/lib:$LD_LIBRARY_PATH
export MESA_SCRIPT=$MESA_ROOT/scripts
export SDK=1

export OP_MONO_BASE=~/mesa/mesa
export MESA_OP_MONO_DATA_PATH=$OP_MONO_BASE/OP4STARS_1.3/mono
export MESA_OP_MONO_DATA_CACHE_FILENAME=$OP_MONO_BASE/OP4STARS_1.3/mono/op_mono_cache.bin
