#!/bin/bash

set -e
set -x

# sudo apt install python[spack] gcc g++ make[gcc] zip[gcc/java]
# wget https://raw.githubusercontent.com/eschnett/spack-test/master/spacktest-ubuntu16.sh
# bash ./spacktest-ubuntu16.sh 2>&1 | tee spacktest.out

installflags="-v"

# Prepare directory
basedir="$HOME/spacktest"
rm -rf "$basedir"
mkdir -p "$basedir"
cd "$basedir"

# Download
rm -rf "$HOME/.spack"
rm -rf "/tmp/$USER/spack-stage"
git clone https://github.com/LLNL/spack.git
cd spack
# git pull
source share/spack/setup-env.sh

# Install gcc
systemcc="gcc@5.4.0"
# Why `~binutils`?
spack spec gcc ~binutils %"$systemcc"
# Fetching is unstable
for i in $(seq 1 10); do
    echo "Fetching gcc, attempt #$i..."
    spack fetch -D gcc ~binutils %"$systemcc" && break || true
done
spack fetch -D gcc ~binutils %"$systemcc"
spack install $installflags gcc ~binutils %"$systemcc"

# Tell Spack about this gcc
osname="Ubuntu16"
gccpath=$(spack find -p 'gcc@6.1.0' | awk '/ gcc.*@/ { print $2; }')
compiler="gcc@6.1.0-spacktest"
spack compiler remove "$compiler" || true
cat >> "$HOME/.spack/compilers.yaml" <<EOT
- compiler:
    modules: []
    operating_system: $osname
    paths:
      cc: $gccpath/bin/gcc
      cxx: $gccpath/bin/g++
      f77: $gccpath/bin/gfortran
      fc: $gccpath/bin/gfortran
    flags:
      cflags: -march=native
      cxxflags: -march=native
      fflags: -march=native
    spec: $compiler
EOT

# Install some packages

# We create an umbrella pseudo-package to ensure that Spack resolves
# all dependencies in a self-consistent manner
umbrelladir="var/spack/repos/builtin/packages/umbrella"
mkdir -p "$umbrelladir"
cat >"$umbrelladir/package.py" <<EOF
from spack import *

class Umbrella(Package):
    homepage = "Umbrella package"
    # This is just a dummy download
    url = "http://zlib.net/zlib-1.2.8.tar.gz"
    version('1.2.8', '44d667c142d7cda120332623eab69f40')

    depends_on("binutils @2.26")   # llvm dependency doesn't suffice for this
    depends_on("boost +mpi")
    depends_on("bzip2")
    depends_on("cereal")
    depends_on("cmake")
    depends_on("curl")
    depends_on("fftw +mpi +openmp")
    depends_on("git")
    depends_on("gsl")
    depends_on("hdf5 +mpi")
    depends_on("hdf5-blosc")
    depends_on("hpx5 +mpi")
    depends_on("hwloc")
    depends_on("hypre ~internal-superlu")   # ~internal-superlu is required, but is not chosen automatically
    depends_on("jemalloc")
    depends_on("julia")
    # depends_on("julia +hdf5 +mpi")
    depends_on("libmng")
    depends_on("libpng")
    depends_on("libtool")
    depends_on("llvm ^binutils @2.26")   # llvm fails with binutils@2.25
    depends_on("lmod")
    depends_on("lua")
    depends_on("mbedtls")
    depends_on("openblas +openmp")
    depends_on("openmpi")
    depends_on("papi")
    depends_on("parallel")
    depends_on("petsc +boost +hdf5 +mpi")
    depends_on("py-cython")
    depends_on("py-h5py +mpi")
    depends_on("py-matplotlib")
    depends_on("py-mpi4py")
    depends_on("py-nose")
    depends_on("py-numpy")
    depends_on("py-scipy")
    depends_on("py-sympy")
    depends_on("python @2.7.12")   # specify version explicitly to circumvent a concretization bug
    depends_on("qthreads")
    depends_on("rsync")
    depends_on("slepc")
    depends_on("swig")
    depends_on("tmux")
    # depends_on("trilinos +python")   # Trilinos cannot be downloaded
    depends_on("zlib")

    def install(self, spec, prefix):
        # This package does not install anything; it only installs its
        # dependencies
        mkdirp(prefix.lib)
EOF
spack spec umbrella %"$compiler"
# Fetching is unstable
for i in $(seq 1 10); do
    echo "Fetching umbrella, attempt #$i..."
    spack fetch -D umbrella %"$compiler" && break || true
done
spack fetch -D umbrella %"$compiler"
spack install $installflags umbrella %"$compiler"

# Run some Spack commands
spack env lmod
spack find -p
spack location -i lmod
echo y | spack module refresh
# "spack reindex" is broken #1320
# spack reindex

# lmod
# lmoddir=$(spack location -i lmod)
# source "$lmoddir/lmod/lmod/init/bash"
# "module" is broken (a path seems truncated)
# module avail -l 2>&1
# module refresh -l 2>&1

# spack view
# "spack view symlink" is broken #1293
# spack view -d true symlink "$basedir/view" umbrella
spack view -d true hardlink "$basedir/view" umbrella

# lmod
lmoddir="$basedir/view"
# source "$lmoddir/lmod/lmod/init/bash"
source "$lmoddir/lmod/*/init/bash"
# "module" is broken (a path seems truncated)
# module avail -l 2>&1
# module refresh -l 2>&1

# TODO: spack load

# TODO: spack uninstall, including uninstall by hash

# TODO: abort build, then restart Spack

# TODO: Test packages
