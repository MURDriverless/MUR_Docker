#!/bin/bash

git clone --depth 1 --branch v0.5 https://github.com/ceccocats/tkDNN.git
mkdir -p tkDNN/build
cd tkDNN/build
cmake \
    -D CMAKE_BUILD_TYPE=RELEASE \
    ..
make -j$(nproc)
make install
