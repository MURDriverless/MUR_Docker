# syntax=docker/dockerfile:1.2
FROM nvidia/cudagl:10.0-devel-ubuntu18.04

ARG DEBIAN_FRONTEND=noninteractive
ARG UBUNTU_RELEASE=bionic

ARG CUDA_VERSION=cuda10.0
ARG CUDNN_VERSION=7.6.5.32
ARG TENSORRT_VERSION=7.0.0

WORKDIR /usr/local

# Basic tools
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
  apt update && \
  apt-get install -y \
  net-tools \
  iputils-ping \
  vim \
  wget \
  libcanberra-gtk-module \
  libcanberra-gtk3-module

# cuDNN
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
  apt update && \
  apt-get install -y \
  libcudnn7=${CUDNN_VERSION}-1+${CUDA_VERSION} \
  libcudnn7-dev=${CUDNN_VERSION}-1+${CUDA_VERSION}

# TensorRT
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
  apt update && \
  apt-get install -y \
  libnvinfer7=${TENSORRT_VERSION}-1+${CUDA_VERSION} \
  libnvonnxparsers7=${TENSORRT_VERSION}-1+${CUDA_VERSION} \
  libnvparsers7=${TENSORRT_VERSION}-1+${CUDA_VERSION} \
  libnvinfer-plugin7=${TENSORRT_VERSION}-1+${CUDA_VERSION} \
  libnvinfer-dev=${TENSORRT_VERSION}-1+${CUDA_VERSION} \
  libnvonnxparsers-dev=${TENSORRT_VERSION}-1+${CUDA_VERSION} \
  libnvparsers-dev=${TENSORRT_VERSION}-1+${CUDA_VERSION} \
  libnvinfer-plugin-dev=${TENSORRT_VERSION}-1+${CUDA_VERSION} \
  python-libnvinfer=${TENSORRT_VERSION}-1+${CUDA_VERSION} \
  python3-libnvinfer=${TENSORRT_VERSION}-1+${CUDA_VERSION} && \
  apt-mark hold libnvinfer7 libnvonnxparsers7 libnvparsers7 libnvinfer-plugin7 libnvinfer-dev libnvonnxparsers-dev libnvparsers-dev libnvinfer-plugin-dev python-libnvinfer python3-libnvinfer

# ROS
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $UBUNTU_RELEASE main" > /etc/apt/sources.list.d/ros-latest.list'

RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get update && \
    apt-get install -y ros-melodic-desktop-full

RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential && \
    rosdep init && \
    rosdep update

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt\
    apt-get update && apt-get install -y python3-pip && \
    pip3 install catkin_tools

# Gazebo Update
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable $UBUNTU_RELEASE main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN curl https://packages.osrfoundation.org/gazebo.key | apt-key add
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get update && \
    apt-get install -y gazebo9

# MISC ROS
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get upgrade -y libignition-math2
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get install -y ros-melodic-tf2-sensor-msgs libgoogle-glog-dev ros-melodic-effort-controllers ros-melodic-position-controllers

# CMake
ARG CMAKE_VERSION=3.18.2

RUN mkdir -p /usr/local/Installers/CMake
WORKDIR /usr/local/Installers/CMake
RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.sh && \
    cp cmake-${CMAKE_VERSION}-Linux-x86_64.sh /opt/  && \
    cd /opt  && \
    sh ./cmake-${CMAKE_VERSION}-Linux-x86_64.sh --skip-license --include-subdir  && \
    rm cmake-${CMAKE_VERSION}-Linux-x86_64.sh  && \
    ln -s cmake-${CMAKE_VERSION}-Linux-x86_64 cmake
WORKDIR /usr/local

ENV PATH=/opt/cmake/bin${PATH:+:${PATH}}

# OpenCV
RUN mkdir -p /usr/local/Installers/OpenCV
WORKDIR /usr/local/Installers/OpenCV
RUN --mount=type=bind,source=Installers/OpenCV/,target=/usr/local/Installers/OpenCV/,rw \
    sh ./opencv_build.sh
WORKDIR /usr/local

# Pylon
RUN mkdir -p /usr/local/Installers/Pylon
WORKDIR /usr/local/Installers/Pylon
RUN wget https://www.baslerweb.com/fp-1589378344/media/downloads/software/pylon_software/pylon_6.1.1.19861-deb0_amd64.deb && \
    apt-get install -y ./pylon_6.1.1.19861-deb0_amd64.deb && \
    rm ./pylon*.deb
RUN echo "source /opt/pylon/bin/pylon-setup-env.sh /opt/pylon" >> ~/.bashrc
WORKDIR /usr/local

# tkDNN
RUN --mount=type=bind,source=Installers/tkDNN/,target=/usr/local/Installers/tkDNN/,rw \
    cd /usr/local/Installers/tkDNN && \
    sh ./install_tkDNN.sh

# Cleanup
RUN rm -r -f Installers && \
    ldconfig
