#!/bin/bash

docker run --gpus all \
    -v /tmp/.X11-unix/:/tmp/.X11-unix/:ro \
    -e DISPLAY=$(echo $DISPLAY) \
    --device=/dev/bus \
    -it \
    murauto/mur_dev_stack