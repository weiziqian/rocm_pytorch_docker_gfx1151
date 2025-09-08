# ROCm PyTorch Docker Files for AMD Strix Halo (AI Max+ 395, gfx1151, 8060s)

This repository provides Docker files to build ROCm-enabled PyTorch environments for the AMD AI 395+ Strix Halo, to leverage GPU acceleration for PyTorch workloads.

> **Note:** The official [ROCm PyTorch docker image](https://hub.docker.com/r/rocm/pytorch) does not include the gfx1151 architecture, so many HIP features are unavailable.

## The base Pytorch image

Includes:

- Ubuntu 24.04 with ROCm 6.5.3 (base image from [ROCm dev-ubuntu-24.04](https://hub.docker.com/r/rocm/dev-ubuntu-24.04))
- torch 2.7.0 built on ROCm 6.5.0rc and Python 3.11 (thanks to [scottt/rocm-TheRock](https://github.com/scottt/rocm-TheRock/releases/v6.5.0rc-pytorch))

### Usage

Install the latest ROCm driver in the host machine. ([Guide](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/quick-start.html))<br> 
Build Docker image:

```bash
cd rocm_pytorch_base
podman build -t rocm_pytorch_base .
```

Test run:

```bash
podman run -it --rm \
  --group-add keep-groups --privileged \
  --security-opt seccomp=unconfined \
  --device=/dev/kfd --device=/dev/dri \
  --ipc=host \
  rocm_pytorch_base:latest \
  /bin/bash -c "python -c 'import torch; print(torch.cuda.is_available()); print(torch.version.hip); print(torch._C._cuda_getArchFlags())'"
```

<details>
 <summary>Expected result (e.g.):</summary>

```
True
6.5.25190-39c57805b
gfx1151
```
</details>

## ComfyUI

Includes:
- (Based on the above base image)
- torchaudio v2.7.0
- torchvision v0.22.0

### Usage

Build Docker image:

```bash
cd rocm_comfyui
./build.sh
```

Run:

```bash
# optionally mount a host ComfyUI path, to persistent storage for models etc.
git clone https://github.com/comfyanonymous/ComfyUI.git
podman run -it --rm \
  --group-add keep-groups --privileged \
  --security-opt seccomp=unconfined \
  --device=/dev/kfd --device=/dev/dri \
  --ipc=host \
  -p 8188:8188 \
  -v ./ComfyUI:/root/ComfyUI \
  rocm_comfyui:latest
```


## Faster-Whisper & CTranslate

Includes:

- (Based on the above base image)
- oneDNN v3.1.1
- CTranslate2 v3.23.0
- torchaudio v2.7.0
- faster-whisper v0.10.0

### Usage

Build Docker image:

```bash
cd rocm_faster_whisper
podman build -t rocm_faster_whisper .
```

