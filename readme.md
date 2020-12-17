# MUR Docker
Dockerfile repo for MUR's dev env docker image

## Features
Base image: `nvidia/cudagl:10.0-devel-ubuntu18.04`
 - CUDA 10.0
 - OpenGL (glvnd 1.2)
 - cuDNN 7.6.5
 - TensorRT 7.0
 - ROS Melodic
 - Gazebo 9.15.0
 - CMake 3.18
 - OpenCV 4.1.1 (With CUDA/cuDNN)
 - Pylon 6.1.1
 - tkDNN v0.5

## Build instructions
Retrive the missing binaries and place it in `Installers` as such,
```
Installers/
├─ CMake/
│  ├─ cmake-3.18.2-Linux-x86_64.sh
│  └─ install_cmake.sh
├─ Nvidia/
│  ├─ nv-tensorrt-repo-ubuntu1804-cuda10.0-trt7.0.0.11-ga-20191216_1-1_amd64.deb`
│  ├─ libcudnn7_7.6.5.32-1+cuda10.0_amd64.deb
│  └─ libcudnn7-dev_7.6.5.32-1+cuda10.0_amd64.deb
├─ OpenCV/
│  └─ opencv_build.sh
├─ Pylon/
│  └─ pylon_6.1.1.19861-deb0_amd64.deb
├─ tkDNN/
│  └─ install_tkDNN.sh
└─ readme.md
```

Run `sudo make` to build

## Usage
As the docker image is based off of Nvidia's CUDA/cuDNN images, an Nvidia GPU is required as well as the latest GPU driver and the [Nvidia docker toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker).

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

### Meaning of the flags
 - `--gpus all` enable pass through of all physical gpus
 - `-v /tmp/.X11-unix/:/tmp/.X11-unix/:ro` mount host's `/tmp/.X11-unix/` to the image's `/tmp/.X11-unix/` with read-only (`:ro`)
 - `-e DISPLAY=$(echo $DISPLAY)` export the `DISPLAY` env variable in the image to point to the host's display
 - `--device=/dev/bus` allows the container access to `/dev/bus` (USB/Serial device access)
 - `-it` Enable interactive terminal

## TODO
 - [x] Find a way to share compiled image (Docker HUB?)
    - Using Docker hub
 - [ ] Use `XAuth` alternative to `xhost`
 - [x] Put OpenCV in (Test if opencv is installed properly)
    - Clean up bandaids
 - [x] Split up `Installers` folder
 - [ ] VSCode integration tutorial
 - [ ] Exposing Ports and forwarding ros packets to remote machines
 - [ ] Missing Utilities
    - ifconfig
    - ping
    - vim
 - [ ] Install gtk and gtk3 module for lidar_dev `sudo apt install libcanberra-gtk-module libcanberra-gtk3-module`
