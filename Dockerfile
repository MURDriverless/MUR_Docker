# syntax=docker/dockerfile:experimental
FROM nvidia/cudagl:10.0-devel-ubuntu18.04

ARG DEBIAN_FRONTEND=noninteractive
ARG UBUNTU_RELEASE=bionic

WORKDIR /usr/local

# cuDNN
RUN --mount=type=bind,source=Installers/Nvidia/,target=/usr/local/Installers/Nvidia/ \
    dpkg -i Installers/Nvidia/libcudnn7*

# TensorRT
RUN --mount=type=bind,source=Installers/Nvidia/,target=/usr/local/Installers/Nvidia/ \
    dpkg -i Installers/Nvidia/nv-tensorrt-repo-ubuntu1804-cuda10.0-trt7.0.0.11-ga-20191216_1-1_amd64.deb

RUN apt-key add /var/nv-tensorrt-repo-cuda10.0-trt7.0.0.11-ga-20191216/7fa2af80.pub

RUN rm /etc/apt/sources.list.d/nvidia-ml.list

RUN apt-get update && \
    apt-get install -y tensorrt

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

RUN apt-get install -y python-pip && \
    pip install catkin_tools

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
RUN mkdir -p /usr/local/Installers/CMake
WORKDIR /usr/local/Installers/CMake
RUN --mount=type=bind,source=Installers/CMake/,target=/usr/local/Installers/CMake/ \
    sh ./install_cmake.sh
WORKDIR /usr/local

ENV PATH=/opt/cmake/bin${PATH:+:${PATH}}

# OpenCV
RUN mkdir -p /usr/local/Installers/OpenCV
WORKDIR /usr/local/Installers/OpenCV
RUN --mount=type=bind,source=Installers/OpenCV/,target=/usr/local/Installers/OpenCV/,rw \
    sh ./opencv_build.sh
WORKDIR /usr/local

# Cleanup
RUN rm -r Installers
