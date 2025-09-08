FROM "localhost/rocm_pytorch_base:latest"

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
RUN python -m pip install \
    --index-url https://rocm.nightlies.amd.com/v2/gfx1151/ \
    torchaudio==2.7.1a0+rocm7.0.0rc20250826

#build and install ROCm CTranslate2 from source
ENV ROCM_PATH=/opt/rocm
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
RUN apt-get update && \
    apt-get install -y --no-install-recommends pkg-config \
    libavformat-dev libavcodec-dev libavdevice-dev \
    libavutil-dev libavfilter-dev libswscale-dev libswresample-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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