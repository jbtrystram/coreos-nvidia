#!/usr/bin/bash

set -euxo pipefail

# TODO make it arguments
# TODO make that a shared prelude between both scripts
export DRIVER_VERSION='580.65.06'
DRIVER_STREAM=$(echo ${DRIVER_VERSION} | cut -d '.' -f 1)

CUDA_VERSION_ARRAY=(${CUDA_VERSION//./ }) \
CUDA_DASHED_VERSION=${CUDA_VERSION_ARRAY[0]}-${CUDA_VERSION_ARRAY[1]}

# install the RPM we built
dnf install -y /nvidia-kmod.rpm

# enable nvidia cuda precompiled repo
# TODO make it work on both RHEL and fedora
# TODO check if we need to import the gpg key first ?
curl https://developer.download.nvidia.com/compute/cuda/repos/fedora42/x86_64/cuda-fedora42.repo -o /etc/yum.repos.d/cuda-fedora42.repo
dnf install -y --enable-repo='cuda-fedora42-x86_64' --disable-repo='*' \
    nvidia-driver-${DRIVER_VERSION} \
    nvidia-driver-cuda-${DRIVER_VERSION} \
    nvidia-driver-libs-${DRIVER_VERSION} \
    cuda-compat-${CUDA_DASHED_VERSION} \
    cuda-cudart-${CUDA_DASHED_VERSION} \
    nvidia-persistenced-${DRIVER_VERSION}

# remove nvidia repo
rm /etc/yum.repos.d/cuda-fedora42.repo

# install other tools from regular repos
dnf install -y nvidia-container-toolkit \
      nvtop \
      pciutils

# blacklist the nouveau driver
echo "blacklist nouveau" > /etc/modprobe.d/blacklist_nouveau.conf 

# enable services
ln -s /usr/lib/systemd/system/nvidia-persistenced.service /etc/systemd/system/multi-user.target.wants/nvidia-persistenced.service

# TODO inject bits into os-release

