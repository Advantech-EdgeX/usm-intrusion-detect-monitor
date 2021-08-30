#!/bin/bash

waterLevelThreshold=20

declare -a ruleName=("pump_control" "person_detection" "water_level_alert" "person_detection_alert")

delete_rules(){
    echo
    echo "Delete the existing rules."
    curl -X DELETE \
    http://172.17.0.1:48075/streams/demo

    for i in "${ruleName[@]}"
    do
        echo
        curl -X DELETE \
        http://172.17.0.1:48075/rules/$i
        echo
    done
}

create_rules(){
    echo "Create the rule stream with EdgeX."
    curl -X POST \
    http://172.17.0.1:48075/streams \
    -H 'Content-Type: application/json' \
    -d '{"sql": "create stream demo() WITH (FORMAT=\"JSON\", TYPE=\"edgex\")"}'
    echo

    echo "Create the new rules for pump control."
    echo "The rule will be triggered if the waterLevelThreshold <= "$1
    curl -X POST \
    http://172.17.0.1:48075/rules \
    -H 'Content-Type: application/json' \
    -d '{
    "id": "'${ruleName[0]}'",
    "sql": "SELECT WaterLevel FROM demo WHERE meta(device) = \"WISE-4012\" AND WaterLevel <= '$1'",
    "actions": [
        {
        "rest": {
            "url": "http://172.17.0.1:49991/api/v1/device/name/FATEKPLC/Pump",
            "method": "put",
            "dataTemplate": "{\"Pump\":\"true\"}",
            "sendSingle": true
        },
        "mqtt": {
            "server": "172.17.0.1:1883",
            "topic": "edgex/'${ruleName[0]}'",
            "sendSingle": true
        }
        },
        {
        "log":{}
        }
    ]
    }'
    echo

    echo "Create the new rules for person detection."
    curl -X POST \
    http://172.17.0.1:48075/rules \
    -H 'Content-Type: application/json' \
    -d '{
    "id": "'${ruleName[1]}'",
    "sql": "SELECT rand() as rkey, json as base64 FROM demo WHERE meta(device) = \"sample-json\" GROUP BY SLIDINGWINDOW(ss, 5) HAVING COUNT(*) = 1",
    "actions": [
        {
        "rest": {
            "url": "http://172.17.0.1:48060/api/v1/notification",
            "method": "post",
            "dataTemplate": "{\"slug\":\"edgex-admin-{{.rkey}}\",\"sender\": \"System Management\",\"category\": \"SECURITY\",\"severity\": \"CRITICAL\",\"contentType\": \"text/html\",\"content\": \"You have to take action for this alert:<br><img src=data:image/jpeg;base64,{{.base64}} />\",\"labels\": [\"PersonDetection\"]}",
            "sendSingle": true
        },
        "mqtt": {
            "server": "172.17.0.1:1883",
            "topic": "edgex/'${ruleName[1]}'",
            "sendSingle": true
        }
        },
        {
        "log":{}
        }
    ]
    }'
    echo

    echo "Create the new rules for water level alert."
    curl -X POST \
    http://172.17.0.1:48075/rules \
    -H 'Content-Type: application/json' \
    -d '{
    "id": "'${ruleName[2]}'",
    "sql": "SELECT WaterLevel FROM demo WHERE meta(device) = \"WISE-4012\" AND WaterLevel <= '$1' GROUP BY SLIDINGWINDOW(ss, 5) HAVING COUNT(*) = 1",
    "actions": [
        {
        "rest": {
            "url": "http://172.17.0.1:48080/api/v1/event",
            "method": "post",
            "dataTemplate": "{\"device\":\"Alert\",\"readings\":[{\"device\":\"Alert\",\"name\":\"Message_ID\",\"value\":\"2\"}]}",
            "sendSingle": true
        },
        "mqtt": {
            "server": "172.17.0.1:1883",
            "topic": "edgex/'${ruleName[2]}'",
            "sendSingle": true
        }
        },
        {
        "log":{}
        }
    ]
    }'
    echo

    echo "Create the new rules for person detection alert."
    curl -X POST \
    http://172.17.0.1:48075/rules \
    -H 'Content-Type: application/json' \
    -d '{
    "id": "'${ruleName[3]}'",
    "sql": "SELECT AnalyticsData FROM demo WHERE meta(device) = \"MQTTAnalyticservice\" GROUP BY SLIDINGWINDOW(ss, 5) HAVING COUNT(*) = 1",
    "actions": [
        {
        "rest": {
            "url": "http://172.17.0.1:48080/api/v1/event",
            "method": "post",
            "dataTemplate": "{\"device\":\"Alert\",\"readings\":[{\"device\":\"Alert\",\"name\":\"Message_ID\",\"value\":\"1\"}]}",
            "sendSingle": true
        },
        "mqtt": {
            "server": "172.17.0.1:1883",
            "topic": "edgex/'${ruleName[3]}'",
            "sendSingle": true
        }
        },
        {
        "log":{}
        }
    ]
    }'
    echo
}

delete_rules
create_rules $waterLevelThreshold
