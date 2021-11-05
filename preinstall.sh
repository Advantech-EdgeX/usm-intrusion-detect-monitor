#!/bin/bash

sudo apt-get update

# Install docker-ce
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    git \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt install -y docker-ce docker-ce-cli containerd.io

# Install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# For video inference
sudo apt install -y \
    python3-pip

sudo pip3 install paho-mqtt opencv-python

# Required library and tools
sudo apt install -y \
    default-jre \
    librxtx-java \
    jq \
    net-tools \
    mosquitto-clients

# Clone Intel/OpenVINO/video-analytics-inference project from github Advantech-EdgeX
echo "Try to clone Intel/OpenVINO/video-analytics-inference project..."
if [ -d "video-inference" ]; then
	echo "!!! The video-inference/ directory exist! Skip clone Intel/OpenVINO/video-analytics-inference project!!!"
else
	git clone https://github.com/Advantech-Edgex/video-analytics-serving.git -b feature-full video-inference
fi

# Clone jsmpeg project from github Advantech-EdgeX
echo "Try to clone JSMpeg project..."
if [ -d "jsmpeg" ]; then
	echo "!!! The jsmpeg/ directory exist! Skip clone JSMpeg project!!!"
else
	git clone https://github.com/Advantech-Edgex/jsmpeg.git -b develop jsmpeg
fi
