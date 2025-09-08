FROM docker.io/rocm/dev-ubuntu-24.04:6.4.3-complete

ENV CMAKE_PREFIX_PATH=/opt/rocm

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    build-essential \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    && rm -rf /var/lib/apt/lists/*

# Use a virtual env in order to upgrade the pip, setuptools and wheel,
# also to install the torch wheel of the corresponding version
RUN python3.11 -m venv /root/venv
ENV PATH="/root/venv/bin:$PATH"
RUN pip install --upgrade pip setuptools wheel

# ref: https://github.com/scottt/rocm-TheRock/releases/v6.5.0rc-pytorch
RUN pip install "https://github.com/scottt/rocm-TheRock/releases/download/v6.5.0rc-pytorch/torch-2.7.0a0+gitbfd8155-cp311-cp311-linux_x86_64.whl"

RUN pip install "numpy<2.0"

WORKDIR /root
CMD ["/bin/bash"]