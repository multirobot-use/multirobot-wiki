sudo sh -c "echo 1 >/proc/sys/net/ipv4/ip_forward"
sudo sh -c "echo 0 >/proc/sys/net/ipv4/icmp_echo_ignore_broadcasts"
sudo ufw disable

#sudo service procps restart
#netstat -g

# Assuming that the package where multimaster.launch is located is called "your_package"
# and you have already set a environmental variable called UAV_ID for distributed execution purposes:
roslaunch your_package multimaster.launch __ns:=uav$UAV_ID
