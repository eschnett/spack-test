# spack-test
FROM ubuntu:16.04
MAINTAINER Erik Schnetter <schnetter@gmail.com>
RUN apt update && apt install -y curl git lbzip2 python xz-utils gcc g++ make zip
RUN useradd -m spacktest
USER spacktest
WORKDIR /home/spacktest
COPY /ImageMagick.patch ./
COPY /fontconfig.patch ./
COPY /qthreads.patch ./
COPY /spacktest-ubuntu16.sh ./
CMD ./spacktest-ubuntu16.sh 2>&1 | tee spacktest.out
