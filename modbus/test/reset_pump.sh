#!/bin/sh

echo "Turn off Pump"

curl -X PUT \
http://172.17.0.1:49991/api/v1/device/name/FATEKPLC/Pump \
-H 'Content-Type: application/json' \
-d '{"Pump":"false"}'