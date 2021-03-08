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
 - CMake 3.18
    - Modify `Installers/CMake/install_cmake.sh` to change version
 - OpenCV 4.1.1 (With CUDA/cuDNN)
    - Modify `Installers/CMake/opencv_build.sh` to change version/compile flags
 - Pylon 6.1.1
    - Retrive `.deb` from https://www.baslerweb.com/en/sales-support/downloads/software-downloads/pylon-6-1-1-linux-x86-64-bit-debian/
 - tkDNN v0.5

## Build instructions
Retrive the missing binaries and place it in `Installers` as such,
```
Installers/
├─ CMake/
│  └─ install_cmake.sh
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
 - [x] Put OpenCV in (Test if opencv is installed properly)
    - Clean up bandaids
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
