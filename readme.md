# MUR Docker
Dockerfile repo for MUR's dev env docker image

## Features
Base image: `nvidia/cudagl:10.0-devel-ubuntu18.04`
 - CUDA 10.0
 - OpenGL (glvnd 1.2)
 - cuDNN 7.6.5
 - TensorRT 7.0
 - ROS Melodic
 - Gazebo 9.15.0
 - CMake 3.18
 - OpenCV 4.1.1 (With CUDA/cuDNN)
 - Pylon 6.1.1
 - tkDNN v0.5

## Instructions to get Docker and MURsim running
# 0) Make sure you are running on an NVIDIA GPU and have enough space on Ubuntu (at least 85GB)
If you don’t have enough space, please allocate/get more space.

If you're using dual boot with Windows:
1. Disk Management to shrink Windows Volume
   - If you’re facing issues while shrinking, https://www.winhelponline.com/blog/you-cannot-shrink-volume-beyond-point-disk-mgmt/?fbclid=IwAR2yXPd_RQhAVZplS2mzlSXEOtv-hrGCqICEZGgSrhtawZwSMEfaIvcGhUM
2. Use trial Ubuntu from Ubuntu boot iso to repartition extra space into your existing Ubuntu with GParted

## 1) Get Docker
1. Follow steps here: https://docs.docker.com/engine/install/ubuntu/
2. Test if it works running `sudo docker run hello-world`

## 2) Building MURauto Docker Image
1. Clone this folder to a folder for Docker https://github.com/MURDriverless/MUR_Docker
2. Google and retrive the missing binaries and place it in `Installers` as such,
```
Installers/
├─ CMake/
│  ├─ cmake-3.18.2-Linux-x86_64.sh
│  └─ install_cmake.sh
├─ Nvidia/
│  ├─ nv-tensorrt-repo-ubuntu1804-cuda10.0-trt7.0.0.11-ga-20191216_1-1_amd64.deb`
│  ├─ libcudnn7_7.6.5.32-1+cuda10.0_amd64.deb
│  └─ libcudnn7-dev_7.6.5.32-1+cuda10.0_amd64.deb
├─ OpenCV/
│  └─ opencv_build.sh
├─ Pylon/
│  └─ pylon_6.1.1.19861-deb0_amd64.deb
├─ tkDNN/
│  └─ install_tkDNN.sh
└─ readme.md
```
3. Run `sudo make` to build
4. As the docker image is based off of Nvidia's CUDA/cuDNN images, an Nvidia GPU is required as well as the latest GPU driver and the [Nvidia docker toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker).
5. Allow X clients from any hosts to connect with, by running `xhost +`

<sup>This allows **any** one to connect your host machine's X11 server, technically a security fault</sup>

6. Launch the docker image with `sudo ./run.sh`, which runs the following lines
```bash
docker run --gpus all \
    -v /tmp/.X11-unix/:/tmp/.X11-unix/:ro \
    -e DISPLAY=$(echo $DISPLAY) \
    --device=/dev/bus \
    -it \
    murauto/mur_dev_stack
```
7. You should now be in docker already and get something like
```
randomalphanum
non-network local connections...
root@randomalphanum: /usr/local#
```

The randomalphanum at the top is the long UUID identifier for the docker container, while the short version is the one beside `root@`. You'll need the identifier if you would like to run multiple instance of docker, by running the following 
```
docker exec -it container_UUID bash
```
8. Exit Docker for now with Ctrl+D or run `exit`

## 3) Easier way to run docker
1. Clone https://github.com/MURDriverless/mur_docker_launcher to the Docker folder in 2)
2. Follow instructions under Usage
3. You should now be able to launch docker with `sudo mdock`

## 4) Getting MURsim on Docker
1. Make a folder that’s designated as the MUR workspace folder, it’ll be called MURworkspace
2. Make a src folder (/MURworkspace/src/), and then make a simulation folder in src (/MURworkspace/src/simulation)
   - src is the source folder, you’ll be putting packages you want to build there
   - simulation folder will hold all the mursim stuff
3. Get mur_init.sh from https://github.com/MURDriverless/mursim_init, put it in the simulation folder (/MURworkspace/src/simulation)
4. Run `sudo mdock` on the workspace folder you designated for MUR workspace (/MURworkspace/)
5. Run `cd /workspace` to get into the workspace folder on docker, it should show the path to /MURworkspace/
6. Run `cd src/simulation/` to get into the simulation folder
7. Run `sudo ./mur_init.sh`, you may run into two issues here
   - Command not found error
     - Run `chmod +x mur_init.sh` to give it executable permission
   - Permission denied (publickey) error when its cloning the required packages
     - Follow this and do the next steps until you add the SSH key to your github account https://docs.github.com/en/github/authenticating-to-github/checking-for-existing-ssh-keys
     - Its probably good to not put a passphrase for now, since it'll keep asking for your passphrase when you do the next step, you can always change it and add later https://docs.github.com/en/github/authenticating-to-github/working-with-ssh-key-passphrases
8. Once that is done, run “cd ../..” to get back to /MURworkspace/
9. Please run `catkin build` ONLY when you no longer need access to the laptop and can keep it powered for half an hour or more. It may hang, just leave it and let it do its thing. It may fail, doesn’t matter, just run “catkin build” again until it succeeds.

## 5) Run MURsim Slow Lap
1. Run `source devel/setup.bash` to source the setup file
2. Run `roslaunch mursim_gazebo slow_lap.launch`
3. Voila! 

### Meaning of the flags for 2.6)
 - `--gpus all` enable pass through of all physical gpus
 - `-v /tmp/.X11-unix/:/tmp/.X11-unix/:ro` mount host's `/tmp/.X11-unix/` to the image's `/tmp/.X11-unix/` with read-only (`:ro`)
 - `-e DISPLAY=$(echo $DISPLAY)` export the `DISPLAY` env variable in the image to point to the host's display
 - `--device=/dev/bus` allows the container access to `/dev/bus` (USB/Serial device access)
 - `-it` Enable interactive terminal

## TODO
 - [x] Find a way to share compiled image (Docker HUB?)
    - Using Docker hub
 - [ ] Use `XAuth` alternative to `xhost`
 - [x] Put OpenCV in (Test if opencv is installed properly)
    - Clean up bandaids
 - [x] Split up `Installers` folder
 - [ ] VSCode integration tutorial
 - [ ] Exposing Ports and forwarding ros packets to remote machines
 - [ ] Missing Utilities
    - ifconfig
    - ping
    - vim
 - [ ] Install gtk and gtk3 module for lidar_dev `sudo apt install libcanberra-gtk-module libcanberra-gtk3-module`
