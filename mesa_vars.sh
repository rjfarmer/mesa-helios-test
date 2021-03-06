export PATH=$HOME/bin:$PATH
export MESA_GIT=~/data/mesa/mesa_git # Where mesa-git is
export MESA_LOG=~/data/mesa/testhub_git # Where to log output to
export MESA_TMP=~/data/mesa/mesatest_git # Where to checkout each MESA to
export MESA_SCRIPTS=~/data/mesa/mesa-helios-test # Where this script sits

export MESA_TEST_VERSION=_1.1.5_

export MESASDK_ROOT=~/mesa/sdk/mesasdk-20.3.1
source $MESASDK_ROOT/bin/mesasdk_init.sh

export OMP_NUM_THREADS=4
export MAX_OPTS=20
export HDF5_USE_FILE_LOCKING='FALSE'

export OP_MONO_BASE=~/mesa/mesa
export MESA_OP_MONO_DATA_PATH=$OP_MONO_BASE/OP4STARS_1.3/mono
export MESA_OP_MONO_DATA_CACHE_FILENAME=$OP_MONO_BASE/OP4STARS_1.3/mono/op_mono_cache.bin






