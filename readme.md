# MUR Docker
Repo for MUR auto's dev stack docker image, refer to the usage section if not trying to compile the docker image.
## Features
Base image: `nvidia/cudagl:10.0-devel-ubuntu18.04`
 - CUDA 10.0
 - OpenGL (glvnd 1.2)
 - cuDNN 7.6.5
 - TensorRT 7.0
 - ROS Melodic
 - Gazebo 9.15.0
 - CMake 3.18.2
 - OpenCV 4.1.1 (With CUDA/cuDNN)
    - Modify `Installers/CMake/opencv_build.sh` to change version/compile flags
 - Pylon 6.1.1
    - Coded as `wget` in `Dockerfile`.
 - tkDNN v0.5

## Build instructions
Retrive the missing binaries and place it in `Installers` as such,
```
Installers/
├─ OpenCV/
│  └─ opencv_build.sh
├─ tkDNN/
│  └─ install_tkDNN.sh
└─ readme.md
```

Run `sudo make` to build

### Modifying versions
The following [docker build args](https://docs.docker.com/engine/reference/builder/#arg) are exposed with their default values,

```
ARG CUDA_VERSION=cuda10.0
ARG CUDNN_VERSION=7.6.5.32
ARG TENSORRT_VERSION=7.0.0

ARG CMAKE_VERSION=3.18.2
```

If the major versions of CUDA/cuDNN/TensorRT changes, it is not enough to simply change the corrosponding ARGs, but modification of the docker file is required, eg. upgrading Tensor RT from 7 to 8 requires `libnvinfer7 -> libnvinfer8`.
## Usage
The docker image is based off of Nvidia's cudagl images, development with CUDA will require an Nvidia GPU, the lastest GPU driver and the [Nvidia docker toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker) on the host machine. Machines without an Nvidia GPU should still be able to run and develop non CUDA based code.

A compiled docker image is hosted on docker hub under [murauto/mur_dev_stack](https://hub.docker.com/r/murauto/mur_dev_stack).

### Simplified Docker launcher script
Refer to [https://github.com/MURDriverless/mur_docker_launcher](https://github.com/MURDriverless/mur_docker_launcher), for a simplified launcher script to automate launching of the docker images.
### Manual Method
First allow X clients from any hosts to connect with,

`xhost +`

<sup>This allows **any** one to connect your host machine's X11 server, technically a sercurity fault</sup>

Then launch the docker image with `sudo ./run.sh`

```bash
docker run --gpus all \
    -v /tmp/.X11-unix/:/tmp/.X11-unix/:ro \
    -e DISPLAY=$(echo $DISPLAY) \
    --device=/dev/bus \
    -it \
    murauto/mur_dev_stack
```

#### Meaning of the flags
 - `--gpus all` enable pass through of all physical gpus
 - `-v /tmp/.X11-unix/:/tmp/.X11-unix/:ro` mount host's `/tmp/.X11-unix/` to the image's `/tmp/.X11-unix/` with read-only (`:ro`)
 - `-e DISPLAY=$(echo $DISPLAY)` export the `DISPLAY` env variable in the image to point to the host's display
 - `--device=/dev/bus` allows the container access to `/dev/bus` (USB/Serial device access)
 - `-it` Enable interactive terminal

## TODO
 - [ ] Integrate with Docker hub's CI?
 - [x] Find a way to share compiled image (Docker HUB?)
    - Using Docker hub
 - [ ] Put OpenCV in (Test if opencv is installed properly)
    - Opencv Tested
    - Integrate into dockerfile?
 - [ ] Integrate tkdnn into dockerfile?
 - [x] Split up `Installers` folder
 - [x] Refer to [Simplified launcher script](https://github.com/MURDriverless/mur_docker_launcher)
    - Use `XAuth` alternative to `xhost`
    - VSCode integration tutorial
    - Exposing Ports and forwarding ros packets to remote machines
 - [x] Missing Utilities
    - ifconfig
    - ping
    - vim
 - [x] Install gtk and gtk3 module for lidar_dev `sudo apt install libcanberra-gtk-module libcanberra-gtk3-module`
