# spack-test
FROM ubuntu:16.04
MAINTAINER Erik Schnetter <schnetter@gmail.com>
RUN apt update && apt install -y curl git lbzip2 python gcc g++ make zip
RUN useradd -m spacktest
USER spacktest
WORKDIR /home/spacktest
ADD /spacktest-ubuntu16.sh .
CMD ./spacktest-ubuntu16.sh 2>&1 | tee spacktest.out
