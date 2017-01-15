#
# RIOT-CI Jenkins Slave Dockerfile
#
# based on RIOT-OS docker: https://github.com/RIOT-OS/riotdocker

FROM ubuntu:xenial

MAINTAINER Sebastian Meiling <s@mlng>

ENV DEBIAN_FRONTEND noninteractive

# The following package groups will be installed:
# - upgrade all system packages to latest available version
# - native platform development and build system functionality (about 400 MB installed)
# - Cortex-M development (about 550 MB installed), through the gcc-arm-embedded PPA
# - MSP430 development (about 120 MB installed)
# - AVR development (about 110 MB installed)
# - LLVM/Clang build environment (about 125 MB installed)
# - x86 bare metal emulation (about 125 MB installed) (this pulls in all of X11)
# All apt files will be deleted afterwards to reduce the size of the container image.
# This is all done in a single RUN command to reduce the number of layers and to
# allow the cleanup to actually save space.
# Total size without cleaning is approximately 1.525 GB (2016-03-08)
# After adding the cleanup commands the size is approximately 1.497 GB
RUN \
    echo 'Adding gcc-arm-embedded PPA' >&2 && \
    echo "deb http://ppa.launchpad.net/team-gcc-arm-embedded/ppa/ubuntu xenial main" \
     > /etc/apt/sources.list.d/gcc-arm-embedded.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 \
    --recv-keys B4D03348F75E3362B1E1C2A1D1FAA6ECF64D33B0 && \
    echo 'Upgrading all system packages to the latest available versions' >&2 && \
    apt-get update && apt-get -y dist-upgrade \
    && echo 'Installing native toolchain and build system functionality' >&2 && \
    apt-get -y install \
        bsdmainutils \
        build-essential \
        ccache \
        cmake \
        curl \
        cppcheck \
        doxygen \
        gcc-multilib \
        gdb \
        g++-multilib \
        git \
        graphviz \
        libpcre3 \
        default-jre-headless \
        openssh-server \
        parallel \
        pcregrep \
        python \
        python3 \
        python3-pexpect \
        p7zip \
        subversion \
        unzip \
        wget \
    && echo 'Installing Cortex-M toolchain' >&2 && \
    apt-get -y install \
        gcc-arm-embedded \
    && echo 'Installing MSP430 toolchain' >&2 && \
    apt-get -y install \
        gcc-msp430 \
    && echo 'Installing AVR toolchain' >&2 && \
    apt-get -y install \
        gcc-avr \
        binutils-avr \
        avr-libc \
    && echo 'Installing LLVM/Clang toolchain' >&2 && \
    apt-get -y install \
        llvm \
        clang \
    && echo 'Installing x86 bare metal emulation' >&2 && \
    apt-get -y install \
        qemu-system-x86 \
    && echo 'Cleaning up installation files' >&2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install MIPS binary toolchain
RUN mkdir -p /opt && \
    wget -q http://codescape-mips-sdk.imgtec.com/components/toolchain/2016.05-03/Codescape.GNU.Tools.Package.2016.05-03.for.MIPS.MTI.Bare.Metal.CentOS-5.x86_64.tar.gz -O- \
    | tar -C /opt -xz

ENV PATH $PATH:/opt/mips-mti-elf/2016.05-03/bin
ENV MIPS_ELF_ROOT /opt/mips-mti-elf/2016.05-03

# Set a global system-wide git user and email address
RUN git config --system user.name "jenkins" && \
    git config --system user.email "jenkins@riot-ci.inet.haw-hamburg.de"

RUN useradd -m -d /opt/jenkins -r -u 999 -s /bin/bash -U jenkins && \
    mkdir -p /opt/jenkins/.ssh && \
    chown jenkins:jenkins /opt/jenkins/.ssh && \
    chmod 755 /opt/jenkins/.ssh && \
    mkdir -p /var/run/sshd && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

EXPOSE 22

COPY jenkins.pub /opt/jenkins/.ssh/authorized_keys

CMD ["/usr/sbin/sshd", "-D"]
