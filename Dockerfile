FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

WORKDIR /usr/local

COPY Installers Installers/

RUN dpkg -i Installers/nv-tensorrt-repo-ubuntu1804-cuda10.0-trt7.0.0.11-ga-20191216_1-1_amd64.deb
RUN apt-key add /var/nv-tensorrt-repo-cuda10.0-trt7.0.0.11-ga-20191216/7fa2af80.pub

RUN rm /etc/apt/sources.list.d/nvidia-ml.list

RUN apt-get update && \
    apt-get install -y tensorrt

ARG DEBIAN_FRONTEND=noninteractive

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu bionic main" > /etc/apt/sources.list.d/ros-latest.list'

RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN apt update && \
    apt install -y ros-melodic-desktop-full

WORKDIR /usr/local/Installers/CMake
RUN sh ./install_cmake.sh
WORKDIR /usr/local

ENV PATH=/opt/cmake/bin${PATH:+:${PATH}}

RUN apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential
RUN rosdep init
RUN rosdep update

RUN apt install -y python-pip
RUN pip install catkin_tools

RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc