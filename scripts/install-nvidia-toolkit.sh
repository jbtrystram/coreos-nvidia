#!/usr/bin/bash
set -euxo pipefail

NVIDIA_REPO="https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo"
LOCAL_REPO="/etc/yum.repos.d/nvidia-container-toolkit.repo"
curl -L $NVIDIA_REPO -o $LOCAL_REPO
dnf install -y nvidia-container-toolkit-base
rm -f $LOCAL_REPO
dnf clean all
rm -rf /var/lib/dnf /var/cache/* /var/log/dnf5.log
