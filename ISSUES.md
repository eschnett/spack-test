# Spack issues encountered during self-tests

* Installing gcc requires `~binutils`

Details unknown; need to investigate.

Might be related to LLNL/spack#1487.

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

This is discussed somewhere, but I can't recall where.

* It's not straightforward to make Spack use a Spack-build gcc

I build gcc with Spack, then want Spack to use this gcc. There is not
Spack command to add this gcc to Spack's list of compilers.

Work-around: Directly add the required yaml code to
"$HOME/.spack/compilers.yaml". This is tedious because it depends on
system details such as Spack's name for the current operating system.

* `binutils @2.25` is preferred

The newest binutils (@2.26) should be the preferred version.

See LLNL/spack#1506.

* Dependency resolution chooses wrong hypre variant

PETSc and Trilinos require `hypre ~internal-superlu`, but Spack's
dependency resolution does not choose this variant. Instead, Spack
aborts with an error.

Work-around: Require explicitly `hypre ~internal-superlu`.

* Python version incorrectly determined

By itself, Spack tries to install `python @2`. This version does not
even exist (is not listed in Python's package). The install fails
because this version cannot be downloaded or does not have a checksum.

Work-around: Require explicitly `python @2.7.12`.

* `spack reindex` is broken

`spack reindex` after installing all packages in a straightforward
manner fails reliably.

See LLNL/spack#1320.

* `spack view symlink` is broken

`spack view symlink` does not create symlinks that correspond to
symlinks. This breaks packages that use symlinks as part of their
install, including `lmod`, and most shared libraries.

Work-around: Use `spack view hardlink` instead.

See LLNL/spack#1293.

* `spack module` is broken

Calling `spack module` produces syntax errors. It seems some paths are
truncated.

See LLNL/spack#1290.
