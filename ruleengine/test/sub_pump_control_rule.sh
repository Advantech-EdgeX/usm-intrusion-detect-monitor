#!/bin/sh

mqttTopic="edgex/pump_control"

echo "Subscribe MQTT topic: $mqttTopic" 

mosquitto_sub -h 172.17.0.1 -t $mqttTopic