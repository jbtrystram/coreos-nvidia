ARG BUILDER_IMAGE
ARG BASE_IMAGE

FROM ${BUILDER_IMAGE} as builder

ARG DRIVER_VERSION

COPY scripts/build-kmod-nvidia-open-dkms.sh /
RUN /build-kmod-nvidia-open-dkms.sh

FROM ${BASE_IMAGE}

ARG DRIVER_VERSION

COPY --from=builder /usr/src/nvidia-${DRIVER_VERSION}/ /usr/src/nvidia-${DRIVER_VERSION}/
COPY --from=builder /var/lib/dkms/ /var/lib/dkms/

# We run the DKMS installation
COPY scripts/install-kmod-nvidia-open-dkms.sh /
RUN /install-kmod-nvidia-open-dkms.sh && rm -f /install-kmod-nvidia-open-dkms.sh

# We install the NVIDIA toolkit
COPY scripts/install-nvidia-toolkit.sh /
RUN /install-nvidia-toolkit.sh && rm -f /install-nvidia-toolkit.sh

RUN dnf install -y ramalama && \
    dnf clean all && \
    rm -rf /var/lib/dnf /var/cache/* /var/log/dnf5.log

RUN bootc container lint
