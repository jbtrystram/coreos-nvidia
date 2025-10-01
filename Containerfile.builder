ARG BASE_IMAGE=quay.io/fedora/fedora-coreos:testing-devel
FROM ${BASE_IMAGE}
RUN dnf -y install rpmbuild elfutils-libelf-devel kernel-devel binutils-gold && dnf clean all
