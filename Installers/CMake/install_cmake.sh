#!/bin/bash

cp cmake-*.sh /opt/
cd /opt
sh ./cmake-* --skip-license --include-subdir
rm cmake-*.sh
ln -s cmake-* cmake
