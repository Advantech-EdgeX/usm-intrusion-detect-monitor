#!/bin/sh

defaultValue=20

currentValue=$(curl -s -X GET \
http://172.17.0.1:49991/api/v1/device/name/WISE-4012/WaterLevel | jq '.readings[0].value | tonumber')
status=$?
if [ 0 -ne $status ]; then
     echo "Query Modbus device service failed, pls check hardware connection."
     exit 1
fi

newValue=$1
if [ -z "$newValue" ]; then
     echo "The input parameter was empty, use default setting: $defaultValue"
     newValue=$defaultValue
fi
echo "Generated change event for water-level:" $currentValue "->" $newValue

curl -X POST \
http://172.17.0.1:48080/api/v1/event \
-H 'Content-Type: application/json' \
-d '{"device":"WISE-4012","readings":[{"device":"WISE-4012","name":"WaterLevel","value":"'$newValue'"}]}'