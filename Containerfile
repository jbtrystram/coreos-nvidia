ARG BUILDER_IMAGE=localhost/builder:latest
ARG BASE_IMAGE=quay.io/fedora/fedora-coreos:testing-devel

FROM $BUILDER_IMAGE as builder

ARG DRIVER_VERSION=580.95.05

COPY scripts/build-kmod-nvidia-open-dkms.sh /
RUN /build-kmod-nvidia-open-dkms.sh

FROM ${BASE_IMAGE}

ARG DRIVER_VERSION=580.95.05

COPY --from=builder /usr/src/nvidia-${DRIVER_VERSION}/ /usr/src/nvidia-${DRIVER_VERSION}/
COPY --from=builder /var/lib/dkms/ /var/lib/dkms/

# We run the DKMS installation
COPY scripts/install-kmod-nvidia-open-dkms.sh /
RUN export DRIVER_VERSION=${DRIVER_VERSION} && ./install-kmod-nvidia-open-dkms.sh && rm -f /install-kmod-nvidia-open-dkms.sh

#COPY nvidia-toolkit-firstboot.service /usr/lib/systemd/system/nvidia-toolkit-firstboot.service
#RUN ln -s /usr/lib/systemd/system/nvidia-toolkit-firstboot.service /usr/lib/systemd/system/basic.target.wants/nvidia-toolkit-firstboot.service

RUN bootc container lint
