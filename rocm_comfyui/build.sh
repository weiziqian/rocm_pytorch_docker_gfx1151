#/bin/bash
cd $(dirname $0)

DOCKER_CMD="podman"

if ! ($DOCKER_CMD images | grep rocm_pytorch_base 1> /dev/null 2>&1); then
    echo "Building the base image"
    /bin/bash ../rocm_pytorch_base/build.sh
    [ $? -ne 0 ] && exit 1
fi

if ls wheels/torchvision-*.whl 1> /dev/null 2>&1; then
    echo "Found existing torchvision wheel"
else
    echo "Preparing the base image for building torchvision wheels"
    mkdir -p wheels
    $DOCKER_CMD build \
        --target base \
        -t rocm_comfyui \
        .

    [ $? -ne 0 ] && exit 1
    
    echo "Building the torchvision wheel"
    $DOCKER_CMD run -it --rm \
        --group-add keep-groups --privileged \
        --security-opt seccomp=unconfined \
        --device=/dev/kfd --device=/dev/dri \
        --ipc=host \
        -v ./wheels:/output \
        rocm_comfyui:latest \
        /bin/bash -c "pip wheel --no-deps --no-index --no-build-isolation git+https://github.com/pytorch/vision.git@v0.22.0 -w /output"
fi

VISION_WHL=$(ls wheels/torchvision-*.whl | head -n 1)
if [ -z "$VISION_WHL" ]; then
    echo "Error: wheel build failed for TorchVision" >&2
    exit 1
fi

echo "Building the final image"
$DOCKER_CMD build \
    --target final \
    -t rocm_comfyui \
    --build-arg VISION_WHL=$VISION_WHL \
    .

[ $? -ne 0 ] && exit 1

echo "Build finished"

echo "Run with:"
echo """
$DOCKER_CMD run -it --rm \\
  --group-add keep-groups --privileged \\
  --security-opt seccomp=unconfined \\
  --device=/dev/kfd --device=/dev/dri \\
  --ipc=host \\
  -p 8188:8188 \\
  -v <your_local_comfyui_path_if_any>:/root/ComfyUI \\
  rocm_comfyui:latest
"""

