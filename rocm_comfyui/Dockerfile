FROM "localhost/rocm_pytorch_base:latest" as base

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git cmake cmake-curses-gui vim \
        && \
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

FROM base as final

ARG VISION_WHL
COPY $VISION_WHL /root

RUN pip install $(basename $VISION_WHL)
RUN rm $(basename $VISION_WHL)

RUN USE_ROCM=1 pip install --no-build-isolation git+https://github.com/pytorch/audio.git@v2.7.0

WORKDIR /root
# (the lastest known working version of ComfyUI is v0.3.57)
RUN git clone https://github.com/comfyanonymous/ComfyUI.git && \
    pip install -r ComfyUI/requirements.txt

ENV TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1
ENV PYTORCH_TUNABLEOP_ENABLED=1

WORKDIR /root/ComfyUI
CMD ["python", "main.py", "--listen", "0.0.0.0", "--use-pytorch-cross-attention"]