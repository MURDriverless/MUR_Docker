#!/bin/bash

wget https://github.com/Kitware/CMake/releases/download/v3.18.2/cmake-3.18.2-Linux-x86_64.sh
cp cmake-*.sh /opt/
cd /opt
sh ./cmake-* --skip-license --include-subdir
rm cmake-*.sh
ln -s cmake-* cmake
