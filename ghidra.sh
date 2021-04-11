#!/bin/bash

echo "--> Starting Ghidra Build..."
echo "--> Getting docker"

sudo apt-get remove docker docker-engine docker.io
sudo apt-get install \
apt-transport-https \
ca-certificates \
curl \
software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"

echo "--> Checking for docker group"
if [ ! "$(getent group docker)" ]; then
    echo "--> Creating docker group"
    sudo groupadd docker
    sudo usermod -aG docker $USER
fi

if [ ! -d "ghidra-builder" ]; then
	echo "--> Getting ghidra docker repo"
	git clone https://github.com/dukebarman/ghidra-builder.git
fi

echo "--> Building Ghidra (can take a while)"
# building ghidra with docker according to github instructions
sg docker -c "./ghidra-builder/docker-tpl/run ./ghidra-builder/workdir/build_ghidra.sh"

echo "--> finished building ghidra"

