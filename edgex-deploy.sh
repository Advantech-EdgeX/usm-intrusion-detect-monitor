#!/bin/bash

DIR=$PWD
CMD=../cmd

sudo docker-compose -f docker-compose-edgex-china-challenge.yml up -d
sudo docker restart edgex-wrapper
sudo docker restart edgex-device-mqtt

sudo docker pull advantech1234/video-analytics-serving-gstreamer:latest
sudo docker tag advantech1234/video-analytics-serving-gstreamer:latest video-analytics-serving-gstreamer:latest
sudo docker stop video-analytics-serving-gstreamer

cd ruleengine
./create_rules.sh
cd $DIR

cd notifications
./create_notifications.sh
cd $DIR

cd wise-export
./create_wise_datahub_edgex_fuji.sh
cd $DIR

# cd modbus/simulator
# ./run_simulator.sh &
# cd $DIR

cd video-inference
./run.sh
cd $DIR