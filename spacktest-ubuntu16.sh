#!/bin/bash

set -e
set -x

# sudo apt install python[spack] gcc g++ make[gcc] zip[gcc/java]
# wget https://raw.githubusercontent.com/eschnett/spack-test/master/spacktest-ubuntu16.sh
# bash ./spacktest-ubuntu16.sh 2>&1 | tee spacktest.out

installflags="-v"

# Prepare directory
basedir="/home/eschnett/spacktest"
rm -rf "$basedir.old"
mv "$basedir" "$basedir.old" || true
mkdir -p "$basedir"
cd "$basedir"

# Download
rm -rf "$HOME/.spack"
rm -rf "/tmp/$USER/spack-stage"
git clone https://github.com/scalability-llnl/spack.git
cd spack
# git pull
source share/spack/setup-env.sh

# Install gcc
systemcc="gcc@5.4.0"
spack spec gcc ~binutils %"$systemcc"
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
    spec: $compiler
EOT

# Install some packages

# spack install $installflags boost +mpi %"$compiler" ^openmpi
# spack install $installflags fftw +mpi +openmp %"$compiler" ^openmpi
# spack install $installflags git %"$compiler"
# spack install $installflags gsl %"$compiler"
# spack install $installflags hdf5 +mpi %"$compiler" ^openmpi
# spack install $installflags hdf5-blosc %"$compiler"
# spack install $installflags hwloc %"$compiler"
# spack install $installflags jemalloc %"$compiler"
# # spack install $installflags julia +hdf5 +mpi %"$compiler" ^hdf5+mpi ^openmpi
# spack install $installflags julia %"$compiler" ^hdf5+mpi ^openmpi
# spack install $installflags llvm %"$compiler"
# spack install $installflags lmod %"$compiler"
# spack install $installflags openblas %"$compiler"
# spack install $installflags openmpi %"$compiler"
# spack install $installflags papi %"$compiler"
# spack install $installflags petsc +boost +hdf5 +mpi %"$compiler" ^boost+mpi ^hdf5+mpi ^openblas ^openmpi
# spack install $installflags py-h5py +mpi %"$compiler" ^hdf5+mpi ^openmpi ^python
# spack install $installflags py-mpi4py %"$compiler" ^openmpi ^python
# spack install $installflags py-numpy %"$compiler" ^openblas ^python
# spack install $installflags py-scipy %"$compiler" ^openblas ^python
# spack install $installflags python %"$compiler"
# spack install $installflags qthreads %"$compiler"
# spack install $installflags swig %"$compiler"
# spack install $installflags tmux %"$compiler"

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

    depends_on("boost +mpi")
    depends_on("bzip2")
    depends_on("cereal")
    depends_on("cmake")
    # depends_on("cuda")
    depends_on("curl")
    depends_on("fftw +mpi +openmp")
    depends_on("git")
    depends_on("gsl")
    depends_on("hdf5 +mpi")
    depends_on("hdf5-blosc")
    depends_on("hpx5 +mpi")
    depends_on("hwloc")
    depends_on("hypre")
    depends_on("jemalloc")
    # depends_on("julia")   # depends_on("julia +hdf5 +mpi")
    depends_on("libmng")
    depends_on("libpng")
    depends_on("libtool")
    depends_on("llvm")
    depends_on("lmod")
    depends_on("lua")
    depends_on("mbedtls")
    depends_on("openblas +openmp")
    depends_on("openmpi")
    depends_on("papi")
    depends_on("parallel")
    depends_on("petsc +boost +hdf5 +mpi")
    depends_on("py-cython")
    # depends_on("py-h5py +mpi")   # py-h5py has an install error
    depends_on("py-matplotlib")
    depends_on("py-mpi4py")
    depends_on("py-nose")
    depends_on("py-numpy")
    depends_on("py-scipy")
    depends_on("py-sympy")
    # depends_on("py-yt")
    depends_on("python @2.7.12")   # Specify version explicitly to circumvent a concretization bug
    depends_on("qthreads")
    depends_on("rsync")
    depends_on("slepc")
    depends_on("swig")
    depends_on("tmux")
    depends_on("zlib")

    def install(self, spec, prefix):
        # This package does not install anything; it only installs its
        # dependencies
        mkdirp(prefix.lib)
EOF
spack spec umbrella %"$compiler"
spack install $installflags umbrella %"$compiler"

# Run some Spack commands
spack env lmod
spack find -p
spack location -i lmod
# spack module refresh
spack reindex

# lmod
# lmoddir=$(spack location -i lmod)
# source "$lmoddir/lmod/lmod/init/bash"
# "module" is broken (a path seems truncated)
# module avail -l 2>&1

# spack view
spack view -d true symlink "$basedir/view" umbrella

# lmod
lmoddir="$basedir/view"
# source "$lmoddir/lmod/lmod/init/bash"
source "$lmoddir/lmod/6.4.1/init/bash"
# "module" is broken (a path seems truncated)
# module avail -l 2>&1

# TODO: spack load

# TODO: Test packages
