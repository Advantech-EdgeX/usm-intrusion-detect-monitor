#!/bin/sh

mqttTopic="edgex/person_detection_alert"

echo "Subscribe MQTT topic: $mqttTopic" 

mosquitto_sub -h 172.17.0.1 -t $mqttTopic