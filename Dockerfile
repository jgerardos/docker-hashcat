FROM ubuntu:18.04

# Based on MIT licensed code from Danylo Ulianych
LABEL maintainer="@jgerardos"

RUN apt-get update && apt-get install -y alien nano screen tmux vim

# Install Intel OpenCL driver
ENV INTEL_OPENCL_URL=http://registrationcenter-download.intel.com/akdlm/irc_nas/9019/opencl_runtime_16.1.1_x64_ubuntu_6.4.0.25.tgz

RUN mkdir -p /tmp/opencl-driver-intel
WORKDIR /tmp/opencl-driver-intel
RUN curl -O $INTEL_OPENCL_URL; \
    tar -xzf $(basename $INTEL_OPENCL_URL); \
    for i in $(basename $INTEL_OPENCL_URL .tgz)/rpm/*.rpm; do alien --to-deb $i; done; \
    dpkg -i *.deb; \
    mkdir -p /etc/OpenCL/vendors; \
    echo /opt/intel/*/lib64/libintelocl.so > /etc/OpenCL/vendors/intel.icd; \
    rm -rf *

# End Intel OpenCL driver installation #

ENV HASHCAT_VERSION        v6.1.1
ENV HASHCAT_UTILS_VERSION  v1.9

# Update & install packages for installing hashcat
RUN apt-get update && \
    apt-get install -y wget make clinfo build-essential git libcurl4-openssl-dev libssl-dev zlib1g-dev libcurl4-openssl-dev libssl-dev

WORKDIR /root

RUN git clone https://github.com/hashcat/hashcat.git && cd hashcat && git checkout ${HASHCAT_VERSION} && make install -j4

RUN git clone https://github.com/hashcat/hashcat-utils.git && cd hashcat-utils/src && git checkout ${HASHCAT_UTILS_VERSION} && make
RUN ln -s /root/hashcat-utils/src/cap2hccapx.bin /usr/bin/cap2hccapx

# Download and install rockyou
RUN wget https://github.com/danielmiessler/SecLists/raw/master/Passwords/Leaked-Databases/rockyou.txt.tar.gz
RUN tar zxvf rockyou.txt.tar.gz
RUN rm rockyou.txt.tar.gz
RUN mv rockyou.txt /etc/rockyou.txt
RUN ln -s /etc/rockyou.txt /root/rockyou.txt


