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

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git  cmake cmake-curses-gui ffmpeg libopenblas-dev vim \
        wget \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV ONEDNN_VERSION=3.1.1
RUN wget -q https://github.com/oneapi-src/oneDNN/archive/refs/tags/v${ONEDNN_VERSION}.tar.gz && \
    tar xf *.tar.gz && \
    rm *.tar.gz && \
    cd oneDNN-* && \
    cmake -DCMAKE_BUILD_TYPE=Release -DONEDNN_LIBRARY_TYPE=STATIC -DONEDNN_BUILD_EXAMPLES=OFF\
          -DONEDNN_BUILD_TESTS=OFF -DONEDNN_ENABLE_WORKLOAD=INFERENCE -DONEDNN_ENABLE_PRIMITIVE="CONVOLUTION;REORDER" \
          -DONEDNN_BUILD_GRAPH=OFF . && \
    make -j$(nproc) install && \
    cd .. && \
    rm -r oneDNN-*

# install pytorch audio
RUN USE_ROCM=1 pip install --no-build-isolation git+https://github.com/pytorch/audio.git@v2.7.0

#build and install ROCm CTranslate2 from source
ENV CTRANSLATE2_ROOT=/opt/ctranslate2
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CTRANSLATE2_ROOT/lib

WORKDIR /root
COPY ct2_3.23.0_rocm.patch /root/
RUN git clone https://github.com/OpenNMT/CTranslate2.git \
    && cd CTranslate2 \
    && git checkout v3.23.0 \
    && git submodule update --init --recursive \
    && git apply /root/ct2_3.23.0_rocm.patch \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=${CTRANSLATE2_ROOT}  \
         -DWITH_CUDA=ON -DWITH_CUDNN=ON -DWITH_MKL=OFF -DWITH_DNNL=ON -DOPENMP_RUNTIME=COMP \
         -DCMAKE_HIP_ARCHITECTURES="gfx1151" -DGPU_TARGETS="gfx1151" -DAMDGPU_TARGETS="gfx1151" \
         -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=ON -DGPU_RUNTIME=HIP -DWITH_OPENBLAS=ON  -DENABLE_CPU_DISPATCH=OFF .. \
    && make install  -j16 
RUN cd /root/CTranslate2/python \
     && pip install -r install_requirements.txt \
     && pip install .

# faster-whisper
WORKDIR /root
RUN git clone https://github.com/SYSTRAN/faster-whisper.git \
    && cd faster-whisper \
    && git checkout  v0.10.0  \
    && pip install --upgrade pip \
    && pip install . \
    && pip install pytest scipy

# cleanup
WORKDIR /root
RUN rm -rf faster-whisper CTranslate2 ct2_3.23.0_rocm.patch

CMD ["/bin/bash"]