#/bin/bash
cd $(dirname $0)

podman build -t rocm_pytorch_base .
