#!/bin/sh

email="admin@advantech.com.tw"

delete_notifications(){
    echo "Delete the existing notifications."
    curl -X DELETE \
    http://172.17.0.1:48060/api/v1/subscription/slug/sys-admin
    echo
}

create_notifications(){
    echo "Create the notification for person detection of AI."
    curl -X POST \
    http://172.17.0.1:48060/api/v1/subscription \
    -H 'Content-Type: application/json' \
    -d '{
    "slug": "sys-admin",
    "receiver": "System Administrator",
    "subscribedCategories": [
        "SECURITY"
    ],
    "subscribedLabels": [
        "PersonDetection"
    ],
    "channels": [
        {
            "type": "EMAIL",
            "mailAddresses": [
                "'$1'"
            ]
        }
    ]
    }'
    echo
}

delete_notifications
create_notifications $email
