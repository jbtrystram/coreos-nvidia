#!/usr/bin/bash

set -euxo pipefail
# TODO make it arguments
export DRIVER_VERSION='580.65.06'
export BASE_URL='https://us.download.nvidia.com/tesla'

# TODO handle aarch64 and 64K page size

# gather versions of the running kernel
export KVER=$(rpm -q --qf "%{VERSION}" kernel-core)
# TODO make that sed expression work with RHEL and Fedora
export KREL=$(rpm -q --qf "%{RELEASE}" kernel-core | sed 's/\.fc.\(.\)*$//')
export KDIST=$(rpm -q --qf "%{RELEASE}" kernel-core | awk -F '.' '{ print "."$NF}')
export OS_VERSION_MAJOR=$(grep "^VERSION=" /etc/os-release | cut -d '=' -f 2 | sed 's/"//g' | cut -d '.' -f 1)
export BUILD_ARCH="$(arch)"


DRIVER_STREAM=$(echo ${DRIVER_VERSION} | cut -d '.' -f 1)

# prepare the rpm build
## TODO make that work for fedora and rhel (for rhel the branch is rhel${OS_VERSION_MAJOR})
git clone --depth 1 --single-branch -b fedora https://github.com/NVIDIA/yum-packaging-precompiled-kmod
cd yum-packaging-precompiled-kmod
mkdir BUILD BUILDROOT RPMS SRPMS SOURCES SPECS
mkdir nvidia-kmod-${DRIVER_VERSION}-${BUILD_ARCH}
curl -sLOf ${BASE_URL}/${DRIVER_VERSION}/NVIDIA-Linux-$(arch)-${DRIVER_VERSION}.run

sh ./NVIDIA-Linux-$(arch)-${DRIVER_VERSION}.run --extract-only --target tmp
mv tmp/kernel-open nvidia-kmod-${DRIVER_VERSION}-${BUILD_ARCH}/kernel
tar -cJf SOURCES/nvidia-kmod-${DRIVER_VERSION}-${BUILD_ARCH}.tar.xz nvidia-kmod-${DRIVER_VERSION}-${BUILD_ARCH}
mv kmod-nvidia.spec SPECS/

# create the signing key to sign the RPM
openssl req -x509 -new -nodes -utf8 -sha256 -days 36500 -batch \
      -config ${HOME}/x509-configuration.ini \
      -outform DER -out SOURCES/public_key.der \
      -keyout SOURCES/private_key.priv

# build the KMOD RPM
rpmbuild \
        --define "% _arch ${BUILD_ARCH}" \
        --define "%_topdir $(pwd)" \
        --define "debug_package %{nil}" \
        --define "kernel ${KVER}" \
        --define "kernel_release ${KREL}" \
        --define "kernel_dist ${KDIST}" \
        --define "driver ${DRIVER_VERSION}" \
        --define "driver_branch ${DRIVER_STREAM}" \
        --define "vendor ${VENDOR:-undefined}" \
        --define "_buildhost ${RPM_HOST:-${HOSTNAME}}" \
        -v -bb SPECS/kmod-nvidia.spec

# TODO make it nicer
mv RPMS/${BUILD_ARCH}/*.rpm /nvidia-kmod.rpm
