#!/bin/bash

# Just a quick script to setup lxc gui containers based on this guide
# https://blog.simos.info/how-to-easily-run-graphics-accelerated-gui-apps-in-lxd-containers-on-your-ubuntu-desktop/
# For deb based ubuntu installs only
# run 'xhost +local:' to allow it to display on host

# install lxd
sudo apt install lxd
# might need to add some stuff here for managing lxd groups

echo "root:$UID:1" | sudo tee -a /etc/subuid /etc/subgid

# create lxc gui profile for X11 :0 display
lxc profile create gui
cat lxcgui | lxc profile edit gui

# create and launch an lxc gui container by name lxc-gui
lxc launch --profile default --profile gui ubuntu:18.04 lxc-gui

