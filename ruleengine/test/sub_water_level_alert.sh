#!/bin/sh

mqttTopic="edgex/water_level_alert"

echo "Subscribe MQTT topic: $mqttTopic" 

mosquitto_sub -h 172.17.0.1 -t $mqttTopic