ARG BUILDER_IMAGE=localhost/builder:latest
ARG BASE_IMAGE=quay.io/coreos-devel/fedora-coreos:testing-devel
FROM $BUILDER_IMAGE as builder

COPY install/build-nvidia-kmod.sh /nvidia/
COPY install/x509-config.ini /nvidia/
WORKDIR /nvidia
RUN /nvidia/build-nvidia-kmod.sh
 
FROM ${BASE_IMAGE}

COPY --from=builder /nvidia-kmod.rpm /
COPY install/ /install

WORKDIR /install
RUN ./nvidia-cuda.sh

RUN rm -rf /install /nvidia-kmod.rpm

COPY nvidia-toolkit-firstboot.service /usr/lib/systemd/system/nvidia-toolkit-firstboot.service
RUN ln -s /usr/lib/systemd/system/nvidia-toolkit-firstboot.service /usr/lib/systemd/system/basic.target.wants/nvidia-toolkit-firstboot.service

RUN dnf clean all \ 
   && bootc container lint

