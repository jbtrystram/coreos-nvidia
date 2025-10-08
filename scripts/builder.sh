#!/usr/bin/bash

K_VER=$(rpm -q --qf "%{VERSION}" kernel-core)

dnf -y install \
  rpmbuild \
  elfutils-libelf-devel \
  kernel-devel-${K_VER} \
  binutils-gold \
  && dnf clean all
