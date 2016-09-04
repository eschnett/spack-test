# Spack issues encountered during self-tests

* Installing gcc requires `~binutils`

Details unknown; need to investigate.

Might be related to
[LLNL/spack#1487](https://github.com/LLNL/spack/issues/1487).

* Fetching packages as part of installing them is brittle

Fetching packages sometimes fails for spurious reasons. Installing a
single package succeeds almost always, installing 100 packages in one
go fails almost always. Spack should be more resilient.

Work-around: Call `spack fetch -D` several times in a row before
calling `spack install`.

* Installing a self-consistent set of packages is not directly
  supported

Spack can install individual packages and their dependencies, but
cannot install a set of packages while guaranteeing that they can be
used with each other, i.e. that they don't have conflicting
dependencies.

Work-around: Create a dummy "umbrella" packages with all desired
packages as dependency, then install this dummy package.

Compare [LLNL/spack#1603](https://github.com/LLNL/spack/pull/1603).

* It's not straightforward to make Spack use a Spack-build gcc

I build gcc with Spack, then want Spack to use this gcc. There is not
Spack command to add this gcc to Spack's list of compilers.

Work-around: Directly add the required yaml code to
`$HOME/.spack/compilers.yaml`. This is tedious, and it depends on
system details such as Spack's name for the current operating system.

* `binutils @2.25` is preferred

The newest binutils (`@2.26`) should be the preferred version.

See [LLNL/spack#1506](https://github.com/LLNL/spack/issues/1506).

* Dependency resolution chooses wrong hypre variant

PETSc and Trilinos require `hypre ~internal-superlu`, but Spack's
dependency resolution does not choose this variant. Instead, Spack
aborts with an error.

Work-around: Require explicitly `hypre ~internal-superlu`.

* Python version incorrectly determined

By itself, Spack tries to install `python @2.7`. This version does not
even exist (is not listed in Python's package). The install fails
because this version cannot be downloaded or does not have a checksum.

Work-around: Require explicitly `python @2.7.12`.

See [LLNL/spack#1280](https://github.com/LLNL/spack/issues/1280).

* `spack view symlink` is broken

`spack view symlink` does not create symlinks that correspond to
symlinks. This breaks packages that use symlinks as part of their
install, including `lmod`, and most shared libraries.

Work-around: Use `spack view hardlink` instead.

See [LLNL/spack#1293](https://github.com/LLNL/spack/issues/1293).

* `spack module` is broken

Calling `spack module` produces syntax errors. It seems some paths are
truncated.

See [LLNL/spack#1290](https://github.com/LLNL/spack/issues/1290).

* `-march=native` does not work

Some packages (which? why?) don't build if we explicitly pass
`-march=native` to GCC for the C, C++, and Fortran compilers.

* Spack puts installed libraries too early in include path

Julia installs its own `gmp @6.0.0`, and this leads to problems when
Spack has installed `gmp @6.1.1`, as their header files are
incompatible.

See [LLNL/spack#1380](https://github.com/LLNL/spack/issues/1380).

Note also that Julia should not install its own gmp anyway.
