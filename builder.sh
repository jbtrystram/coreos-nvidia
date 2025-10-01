#!/usr/bin/bash

export KVER=$(rpm -q --qf "%{VERSION}" kernel-core)

dnf -y install \
  && pmbuild \
  && elfutils-libelf-devel \
  && kernel-devel-${KVER} \
  && binutils-gold \
  && dnf clean all
