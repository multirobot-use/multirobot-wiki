## Get path to script
#SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"
#WORKSPACE_PATH="$( cd .. ; pwd -P )"

cd ~

# Utils
sudo apt update
sudo apt -y upgrade
sudo apt install -y vim build-essential valgrind git make tmux tmuxinator htop curl wgetpython-pip net-tools
pip install gitman

## .tmux.conf examples
echo "set -g mouse on" >>  ~/.tmux.conf
echo "setw -g mode-keys vi" >>  ~/.tmux.conf
echo "set -g default-terminal \"xterm-256color\"" >>  ~/.tmux.conf
echo "#set -g default-command /usr/bin/bash" >>  ~/.tmux.conf

# Change swap size for NUCs (Normally necessary. If not, comment it)
sudo swapoff -a
sudo dd if=/dev/zero of=/swapfile bs=1GB count=15
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

echo " " >> ~/.bashrc
echo "# Source Workspaces" >> ~/.bashrc



# ROS Noetic installation
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
sudo apt update
sudo apt install -y ros-melodic-desktop-full
echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
source ~/.bashrc
sudo apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential
sudo rosdep init
rosdep update

## Catkin tools
sudo sh \
    -c 'echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" \
        > /etc/apt/sources.list.d/ros-latest.list'
wget http://packages.ros.org/ros.key -O - | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y python-catkin-tools


# Install necessary packages
sudo apt install -y libeigen3-dev ros-melodic-geodesy ros-melodic-joy ros-melodic-multimaster-fkie
pip install pynput
sudo apt install -y xz-utils


# Creating a ROS Workspace
mkdir -p ~/your_ws/src
cd ~/your_ws/
catkin build -DPYTHON_EXECUTABLE=/usr/bin/python
source devel/setup.bash
echo "source $HOME/your_ws/devel/setup.bash" >> ~/.bashrc

## Clone packages
echo "Cloning necessary packages"
cd ~/your_ws/src/

git clone https://github.com/ctu-mrs/aerialcore_simulation.git
git clone https://github.com/grvcTeam/aerialcore_planning.git
git clone https://github.com/Angel-M-Montes/path_planner.git
git clone https://github.com/grvcTeam/grvc-ual.git
git clone https://github.com/grvcTeam/grvc-utils.git

# IGNORE some packages
touch ~/your_ws/src/aerialcore_planning/large_scale_inspection_planner/CATKIN_IGNORE
touch ~/your_ws/src/grvc-utils/mission_lib/CATKIN_IGNORE

## BehaviorTree compile
sudo apt-get install -y libzmq3-dev libboost-dev
sudo apt-get install -y ros-melodic-behaviortree-cpp-v3

## Groot
cd ~/your_ws/src/
sudo apt install -y qtbase5-dev libqt5svg5-dev libzmq3-dev libdw-dev
git clone https://github.com/BehaviorTree/Groot.git
touch ~/your_ws/src/Groot/CATKIN_IGNORE
cd ..
rosdep install --from-paths src --ignore-src
catkin build

## Install and configure UAL. Only MAVROS needed. Dependencies
echo "Installing and configuring UAL. Only MAVROS needed. Install dependencies"
cd ~/your_ws/src/grvc-ual
./configure.py

## Install MAVROS packages
echo "Installing MAVROS necessary packages"
sudo apt install -y ros-melodic-mavros ros-melodic-mavros-extras
sudo geographiclib-get-geoids egm96-5
sudo usermod -a -G dialout $USER
sudo apt remove modemmanager

## Install RealSense plugins for real-life execution
sudo apt install -y ros-melodic-realsense2-camera ros-melodic-realsense2-description

## IMPORTANT: Giving permissions to read the data from the RealSense camera
sudo cp 99-realsense-libusb.rules /etc/udev/rules.d/99-realsense-libusb.rules

## Install PX4 for SITL simulations
echo "Installing PX4 for SITL simulations"
sudo apt install -y libgstreamer1.0-dev python-jinja2 python-pip
pip install numpy toml
cd ~/your_ws/src/
git clone https://github.com/PX4/Firmware.git
cd Firmware
git checkout v1.10.2
git submodule update --init --recursive
make
make px4_sitl_default gazebo

# IST Autolanding
mkdir -p ~/autonomous_landing_workspace/src && cd ~/autonomous_landing_workspace/src
git clone https://github.com/durable-ist/autonomous_landing_uav.git
git clone https://github.com/UbiquityRobotics/fiducials.git
cd ~/autonomous_landing_workspace
catkin init
cp ~/autonomous_landing_workspace/src/autonomous_landing_uav/aruco_detect3.launch ~/autonomous_landing_workspace/src/fiducials/aruco_detect/launch/aruco_detect3.launch
cd ~/autonomous_landing_workspace
catkin config --extend ~/your_ws/devel
cd ~/autonomous_landing_workspace
sudo apt install ros-melodic-vision-msgs
catkin build
echo "source $HOME/autonomous_landing_workspace/devel/setup.bash" >> ~/.bashrc
