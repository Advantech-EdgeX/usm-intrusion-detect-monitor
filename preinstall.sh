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

sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
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

sudo pip3 install paho-mqtt opencv-python pillow

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
	mkdir "$PROJECT"
	pushd "$PROJECT"
	git init
	git remote add origin https://github.com/Advantech-Edgex/video-analytics-serving.git
	git fetch --depth=1 origin b6498739caccaed5a54896d9ecd58601001d10fd
	git reset --hard FETCH_HEAD
	popd
fi

# Clone jsmpeg project from github Advantech-EdgeX
PROJECT=jsmpeg
echo "Try to clone $PROJECT project..."
if [ -d "$PROJECT" ]; then
	echo "!!! The ${PROJECT}/ directory exist! Skip git clone !!!"
else
	mkdir "$PROJECT"
	pushd "$PROJECT"
	git init
	git remote add origin https://github.com/Advantech-Edgex/jsmpeg.git
	git fetch --depth=1 origin 0b131b808c4645e1422585b0a203091e55a46409
	git reset --hard FETCH_HEAD
	popd
fi

# Clone edgex-scripts.git project from github Advantech-EdgeX
PROJECT=edgex-scripts
echo "Try to clone $PROJECT project..."
if [ -d "$PROJECT" ]; then
	echo "!!! The ${PROJECT}/ directory exist! Skip git clone !!!"
else
	mkdir "$PROJECT"
	pushd "$PROJECT"
	git init
	git remote add origin https://github.com/Advantech-EdgeX/edgex-scripts.git
	git fetch --depth=1 origin b9f1cf731bdf21bd62d7b0105373a57e1b5db748
	git reset --hard FETCH_HEAD
	if [ -d "../patch" ]; then
		git am ../patch/*.patch
	fi
	popd
fi

echo "Copy eKuiper config folder for docker volume mounting"
if [ -d "kuiper" ]; then
	cp -a kuiper "$PROJECT"/compose-files
else
	echo "The eKuiper config folder does not exist"
fi
