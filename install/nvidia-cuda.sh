#!/usr/bin/bash

set -euxo pipefail

# TODO make it arguments
# TODO make that a shared prelude between both scripts
export DRIVER_VERSION='580.65.06'
CUDA_VERSION='13.0.0'

DRIVER_STREAM=$(echo ${DRIVER_VERSION} | cut -d '.' -f 1)
CUDA_VERSION_ARRAY=(${CUDA_VERSION//./ }) \
CUDA_DASHED_VERSION=${CUDA_VERSION_ARRAY[0]}-${CUDA_VERSION_ARRAY[1]}

# set some options for dnf
dnf_opts=('--setopt=install_weak_deps=False' '--no-docs' '--best')
arch > /etc/dnf/vars/cudaarch

# install the RPM we built before
dnf install -y /nvidia-kmod.rpm

# enable nvidia cuda precompiled repo
# TODO make it work on both RHEL and fedora
curl https://developer.download.nvidia.com/compute/cuda/repos/fedora42/x86_64/cuda-fedora42.repo -o /etc/yum.repos.d/cuda-fedora42.repo

#dnf -y module enable nvidia-driver:${DRIVER_STREAM}-open/default
dnf install -y  "${dnf_opts[@]}" \
    nvidia-driver-${DRIVER_VERSION} \
    nvidia-driver-cuda-${DRIVER_VERSION} \
    nvidia-driver-libs-${DRIVER_VERSION} \
    nvidia-persistenced-${DRIVER_VERSION} \
    nvidia-container-toolkit \
    nvtop \
    pciutils

    # FIXME these rpm do not install because conflicting ownership of
    # /usr/local/cuda-13.0
    # cuda-cudart-${CUDA_DASHED_VERSION} \
    # cuda-compat-${CUDA_DASHED_VERSION} \

# clean up after ourselves
dnf clean all

# blacklist the nouveau driver
echo "blacklist nouveau" > /etc/modprobe.d/blacklist_nouveau.conf 

# enable services
ln -s /usr/lib/systemd/system/nvidia-persistenced.service /etc/systemd/system/multi-user.target.wants/nvidia-persistenced.service

# TODO inject bits into os-release
