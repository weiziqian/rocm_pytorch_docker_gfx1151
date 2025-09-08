#/bin/bash
cd $(dirname $0)

if ! (podman images | grep rocm_pytorch_base 1> /dev/null 2>&1); then
    echo "Building the base image"
    /bin/bash ../rocm_pytorch_base/build.sh
    [ $? -ne 0 ] && exit 1
fi

podman build -t rocm_faster_whisper .