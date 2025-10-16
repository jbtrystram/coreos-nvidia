ARG BUILDER_IMAGE
ARG BASE_IMAGE
ARG STREAM

FROM ${BUILDER_IMAGE} as builder

ARG DRIVER_VERSION

COPY scripts/build-kmod-nvidia-open-dkms.sh /
RUN /build-kmod-nvidia-open-dkms.sh

FROM ${BASE_IMAGE}:${STREAM}

ARG DRIVER_VERSION

COPY --from=builder /usr/src/nvidia-${DRIVER_VERSION}/ /usr/src/nvidia-${DRIVER_VERSION}/
COPY --from=builder /var/lib/dkms/ /var/lib/dkms/

# We run the DKMS installation
COPY scripts/install-kmod-nvidia-open-dkms.sh /
RUN /install-kmod-nvidia-open-dkms.sh && rm -f /install-kmod-nvidia-open-dkms.sh

# We install the NVIDIA toolkit
COPY scripts/install-nvidia-toolkit.sh /
RUN /install-nvidia-toolkit.sh && rm -f /install-nvidia-toolkit.sh

# Install RamaLama
# Also add the video group to /etc/passwd in order to be able to add the core user
# to the group once booted c.f https://github.com/coreos/ignition/issues/1596
RUN dnf install -y ramalama && \
    dnf clean all && \
    grep ^video: /usr/lib/group >> /etc/group && \
    rm -rf /var/lib/dnf /var/cache/* /var/log/dnf5.log

RUN bootc container lint
