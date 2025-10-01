# Fedora CoreOS with NVIDIA drivers and tools

We are deriving Fedora CoreOS (FCOS) images to integrate NVIDIA components (kernel modules, drivers, etc).
These specialized images are hosted on Quay.io at [quay.io/coreos-devel/fedora-coreos-nvidia](https://quay.io/repository/coreos-devel/fedora-coreos-nvidia?tab=tags).

This work is primarily inspired by the methodology used in the RHEL AI [nvidia-bootc project](https://gitlab.com/redhat/rhel-ai/containers/nvidia-bootc/).

## Building locally
```bash
BUILDER_IMAGE=localhost/builder:latest
podman build -f Containerfile.builder -t $BUILDER_IMAGE
podman build -f Containerfile -t localhost/fedora-coreos-nvidia:testing-devel
```
