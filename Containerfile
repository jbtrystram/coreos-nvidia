ARG BUILDER_IMAGE=localhost/builder:latest
FROM $BUILDER_IMAGE as builder

COPY install /nvidia
WORKDIR /nvidia
RUN /nvidia/build-nvidia-kmod.sh
 
FROM quay.io/coreos-devel/coreos:stable

COPY --from=builder /nvidia-kmod.rpm /
COPY install /install

WORKDIR /nvidia
RUN install/nvidia-cuda.sh

RUN rm -rf /nvidia /nvidia-kmod.rpm
RUN bootc container lint

