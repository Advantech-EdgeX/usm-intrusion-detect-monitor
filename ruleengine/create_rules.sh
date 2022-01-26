#!/bin/bash

declare -a ruleName=("person_detection" "person_detection_alert")

delete_rules(){
    echo
    echo "Delete the existing rules."
    curl -X DELETE \
    http://172.17.0.1:48075/streams/demo

    echo
    curl -X DELETE \
    http://172.17.0.1:48075/streams/mqtts

    for i in "${ruleName[@]}"
    do
        echo
        curl -X DELETE \
        http://172.17.0.1:48075/rules/$i
        echo
    done
}

create_rules(){
    echo "Create the rule stream 1 with EdgeX."
    curl -X POST \
    http://172.17.0.1:48075/streams \
    -H 'Content-Type: application/json' \
    -d '{"sql": "create stream demo() WITH (FORMAT=\"JSON\", TYPE=\"edgex\")"}'
    echo

    echo "Create the rule stream 2 with EdgeX."
    curl -X POST \
    http://172.17.0.1:48075/streams \
    -H 'Content-Type: application/json' \
    -d '{"sql": "create stream mqtts() WITH (DATASOURCE=\"AnalyticsData\", FORMAT=\"JSON\", TYPE=\"mqtt\")"}'
    echo

    echo "Create the new rules for person detection."
    curl -X POST \
    http://172.17.0.1:48075/rules \
    -H 'Content-Type: application/json' \
    -d '{
    "id": "'${ruleName[0]}'",
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

    echo "Create the new rules for person detection alert."
    curl -X POST \
    http://172.17.0.1:48075/rules \
    -H 'Content-Type: application/json' \
    -d '{
    "id": "'${ruleName[1]}'",
    "sql": "SELECT reason, camtype, camurl FROM mqtts",
    "actions": [
        {
        "rest": {
            "dataTemplate": "{\"device\":\"RulesEngine\",\"readings\": [{\"name\":\"RulesEngine_ClassName\",\"value\":\"{{.reason}}\"},{\"name\":\"RulesEngine_NodeName\",\"value\":\"{{.camtype}}\"},{\"name\":\"RulesEngine_Value\",\"value\":\"{{.camurl}}\"},{\"name\":\"RulesEngine_EventTime\",\"value\":\"1641800683\"}]}",
            "method": "POST",
            "retryInterval": "-1",
            "sendSingle": true,
            "url": "http://172.22.24.255:48080/api/v1/event"
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
}

delete_rules
create_rules
