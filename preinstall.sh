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

sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu `lsb_release -cs` test"
sudo apt update

sudo apt install -y docker.io
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

# Add the connected user "$USER" to the docker group.
sudo gpasswd -a $USER docker

# Clone Intel/OpenVINO/video-analytics-inference project from github Advantech-EdgeX
PROJECT=vaserving
echo "Try to clone $PROJECT project..."
if [ -d "$PROJECT" ]; then
	echo "!!! The ${PROJECT}/ directory exist! Skip git clone !!!"
else
	git clone https://github.com/Advantech-Edgex/video-analytics-serving.git -b feature-full "$PROJECT"
fi

# Clone jsmpeg project from github Advantech-EdgeX
PROJECT=jsmpeg
echo "Try to clone $PROJECT project..."
if [ -d "$PROJECT" ]; then
	echo "!!! The ${PROJECT}/ directory exist! Skip git clone !!!"
else
	git clone https://github.com/Advantech-Edgex/jsmpeg.git -b develop "$PROJECT"
fi

# Clone edgex-scripts.git project from github Advantech-EdgeX
PROJECT=edgex-scripts
echo "Try to clone $PROJECT project..."
if [ -d "$PROJECT" ]; then
	echo "!!! The ${PROJECT}/ directory exist! Skip git clone !!!"
else
	git clone https://github.com/Advantech-EdgeX/edgex-scripts.git -b master "$PROJECT"
	if [ "$?" = 0 ] && [ -d "patch" ] && [ -f "patch/edgex-scripts_0001-fix-mailhog-no-receive-image.patch" ]; then
		cat "patch/edgex-scripts_0001-fix-mailhog-no-receive-image.patch" | patch -p1 -d "$PROJECT"
	fi
fi
