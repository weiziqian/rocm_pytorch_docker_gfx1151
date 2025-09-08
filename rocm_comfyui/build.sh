#/bin/bash
cd $(dirname $0)

if ! (podman images | grep rocm_pytorch_base 1> /dev/null 2>&1); then
    echo "Building the base image"
    /bin/bash ../rocm_pytorch_base/build.sh
    [ $? -ne 0 ] && exit 1
fi

podman build -t rocm_comfyui .
[ $? -ne 0 ] && exit 1

echo "Build finished, Run with:"
echo """
podman run -it --rm \\
  --group-add keep-groups --privileged \\
  --security-opt seccomp=unconfined \\
  --device=/dev/kfd --device=/dev/dri \\
  --ipc=host \\
  -p 8188:8188 \\
  -v <your_local_comfyui_path_if_any>:/root/ComfyUI \\
  rocm_comfyui:latest
"""

