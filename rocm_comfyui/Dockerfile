FROM "localhost/rocm_pytorch_base:latest"

RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
        libjpeg-dev \
        libpng-dev \
        libwebp-dev \
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev \
        libavutil-dev \
        ffmpeg \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN python -m pip install \
    --index-url https://rocm.nightlies.amd.com/v2/gfx1151/ \
    torchvision==0.22.1+rocm7.0.0rc20250826 \
    torchaudio==2.7.1a0+rocm7.0.0rc20250826

WORKDIR /root
# (the lastest known working version of ComfyUI is v0.3.57)
RUN git clone https://github.com/comfyanonymous/ComfyUI.git && \
    pip install -r ComfyUI/requirements.txt

ENV TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1
ENV PYTORCH_TUNABLEOP_ENABLED=1

WORKDIR /root/ComfyUI
CMD ["python", "main.py", "--listen", "0.0.0.0", "--use-pytorch-cross-attention"]