# Fedora CoreOS with NVIDIA drivers and tools

**STATUS:** **Work In Progress** — This image is in active development and is not yet ready for production use.

We are deriving Fedora CoreOS (FCOS) images to integrate NVIDIA components (kernel modules, drivers, etc).
This specialized image is hosted on Quay.io at [quay.io/coreos-devel/fedora-coreos-nvidia](https://quay.io/repository/coreos-devel/fedora-coreos-nvidia?tab=tags).

The build process utilizes official NVIDIA DKMS packages from [NVIDIA repo](https://developer.download.nvidia.com/compute/cuda/repos/) to
compile the open kernel modules, a method usually reserved for the client system.
Despite requiring a tweak to target the immutable image's specific kernel (rather than the build host's), using DKMS simplifies integration significantly.

## Building locally
```bash
source build-args.conf
podman build --build-arg-file build-args.conf -f Containerfile.builder -t $BUILDER_IMAGE
podman build --build-arg-file build-args.conf -f Containerfile -t localhost/fedora-coreos-nvidia:testing-devel
```

## To test it
```bash
[core@localhost ~]$ lsmod | grep nvidia
nvidia_drm            155648  0
nvidia_modeset       2248704  1 nvidia_drm
nvidia              15917056  1 nvidia_modeset
drm_ttm_helper         16384  1 nvidia_drm
video                  81920  1 nvidia_modeset

[core@localhost ~]$ lspci -nnk | grep -A2 NVIDIA
00:03.0 VGA compatible controller [0300]: NVIDIA Corporation GA102 [GeForce RTX 3080] [10de:2206] (rev a1)
	Subsystem: NVIDIA Corporation GA102 [GeForce RTX 3080] [10de:1467]
	Kernel driver in use: nvidia
	Kernel modules: nouveau, nvidia_drm, nvidia

# Checking the licenses
[core@localhost ~]$ modinfo -l nvidia nvidia_drm nvidia_modeset
Dual MIT/GPL
Dual MIT/GPL
Dual MIT/GPL
```

## Serve a LLM with RamaLama

Boot a FCOS image and rebase to an image containing the NVIDIA kernel modules:
```
sudo rpm-ostree rebase ostree-unverified-registry:quay.io/coreos-devel/fedora-coreos-nvidia:stable-580.95.05 --reboot
```

Install the `nvidia-driver-cuda` sysext to get the NVIDIA CUDA driver and libs:
```
sudo systemctl enable --now systemd-sysext
sudo mkdir -p /var/lib/extensions/
sudo curl -L https://jcapitao.fedorapeople.org/sysexts/nvidia-driver-cuda-580.95.05-3-580.95.05-1.fc42-42-x86-64.raw \
     -o /var/lib/extensions/nvidia-driver-cuda-580.95.05.raw
sudo systemd-sysext refresh
```

Check if everything is ok:
```
nvidia-smi
```

And finally, serve the requested LLM with RamaLama
```
ramalama --engine podman serve -p 8081 --oci-runtime runc --image quay.io/ramalama/cuda:0.12.4 mistral:7b-v3
```
