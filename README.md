# spack-test

Test [Spack](https://github.com/LLNL/spack) by installing packages for
a typical HPC environment

The current setup uses [Docker](https://www.docker.com) and starts
from a minimal
[Ubuntu 16.04](https://wiki.ubuntu.com/XenialXerus/ReleaseNotes/16.04)
system image.

Current results are available [here](https://gist.github.com/eschnett/277b5818762a49674594fd706a9a4460). This shows only the last few lines of installing more than 100 packages.

The file [ISSUES.md](../master/ISSUES.md) describes Spack
problems encountered during self-tests, including issue numbers
and work-arounds (if any).
