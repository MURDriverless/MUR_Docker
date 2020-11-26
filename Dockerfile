FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

ARG DEBIAN_FRONTEND=noninteractive
ARG UBUNTU_RELEASE=bionic

WORKDIR /usr/local

COPY Installers Installers/

# TensorRT
RUN dpkg -i Installers/nv-tensorrt-repo-ubuntu1804-cuda10.0-trt7.0.0.11-ga-20191216_1-1_amd64.deb
RUN apt-key add /var/nv-tensorrt-repo-cuda10.0-trt7.0.0.11-ga-20191216/7fa2af80.pub

RUN rm /etc/apt/sources.list.d/nvidia-ml.list

RUN apt-get update && \
    apt-get install -y tensorrt

# ROS
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $UBUNTU_RELEASE main" > /etc/apt/sources.list.d/ros-latest.list'

RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN apt-get update && \
    apt-get install -y ros-melodic-desktop-full

RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc

RUN apt-get install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential && \
    rosdep init && \
    rosdep update

RUN apt-get install -y python-pip && \
    pip install catkin_tools

# Gazebo Update
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable $UBUNTU_RELEASE main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN curl https://packages.osrfoundation.org/gazebo.key | apt-key add
RUN apt-get update && \
    apt-get install -y gazebo9

# MISC ROS
RUN apt-get upgrade -y libignition-math2
RUN apt-get install -y ros-melodic-tf2-sensor-msgs libgoogle-glog-dev ros-melodic-effort-controllers ros-melodic-position-controllers

# CMake
WORKDIR /usr/local/Installers/CMake
RUN sh ./install_cmake.sh
WORKDIR /usr/local

ENV PATH=/opt/cmake/bin${PATH:+:${PATH}}

# OpenCV
WORKDIR /usr/local/Installers/OpenCV
RUN rm ./opencv_build.sh
ADD temp.sh ./
RUN sh ./temp.sh
WORKDIR /usr/local

# Cleanup
RUN rm -r Installers
