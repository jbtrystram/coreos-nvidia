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
sudo bootc switch quay.io/coreos-devel/fedora-coreos-nvidia:stable-580.95.05 --apply
```

To install and enable the `nvidia-driver-cuda` system extension, follow these instructions https://fedora-sysexts.github.io/community/nvidia-driver-cuda-580.95.05/#usage-instructions

Once the system extension is installed, you will need to create the `nvidia-persistenced` user, following this instruction https://fedora-sysexts.github.io/community/nvidia-driver-cuda-580.95.05/#how-to-use


Check if everything is ok:
```
nvidia-smi
```

And finally, serve the requested LLM with RamaLama
```
# We're using a workaround to add the user in video group which is required for
# ramalama to be able to access the DRI device.
# https://github.com/coreos/butane/issues/411#issuecomment-1407544648
grep ^video: /usr/lib/group | sudo tee -a /etc/group && sudo usermod -a -G video $USER

ramalama --engine podman serve -p 8081 --oci-runtime crun --image quay.io/ramalama/cuda:0.12.4 mistral:7b-v3
```
