ARG BASE_IMAGE=quay.io/fedora/fedora-coreos:testing-devel
FROM ${BASE_IMAGE}

COPY builder.sh /
RUN /builder.sh

