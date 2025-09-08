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

RUN python -m pip install \
    --index-url https://rocm.nightlies.amd.com/v2/gfx1151/ \
    torch==2.7.1+rocm7.0.0rc20250826 \
    numpy

WORKDIR /root
CMD ["/bin/bash"]