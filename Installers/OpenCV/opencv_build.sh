#!/bin/bash

git clone --depth 1 --branch 4.1.1 https://github.com/opencv/opencv.git
git clone --depth 1 --branch 4.1.1 https://github.com/opencv/opencv_contrib.git
cd opencv
mkdir build
cd build
cmake -D BUILD_EXAMPLES=OFF \
	-D BUILD_DOCS=OFF \
	-D BUILD_PERF_TESTS=OFF \
	-D BUILD_TESTS=OFF \
        -D BUILD_opencv_python2=OFF \
        -D BUILD_opencv_python3=OFF \
        -D CMAKE_BUILD_TYPE=RELEASE \
        -D CUDA_ARCH_PTX= \
        -D CUDA_FAST_MATH=ON \
        -D EIGEN_INCLUDE_PATH=/usr/include/eigen3  \
        -D OPENCV_DNN_CUDA=ON \
        -D OPENCV_ENABLE_NONFREE=ON \
        -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
        -D OPENCV_GENERATE_PKGCONFIG=ON \
        -D WITH_CUBLAS=ON \
        -D WITH_CUDA=ON \
        -D WITH_CUDNN=ON \
        -D WITH_GSTREAMER=ON \
        -D WITH_LIBV4L=ON \
        -D WITH_TBB=ON \
        -D WITH_OPENGL=ON \
	..
make -j$(nproc)
make install
