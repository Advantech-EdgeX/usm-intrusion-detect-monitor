#!/bin/sh

rkey=$(date +"%T")

curl -X POST \
http://172.17.0.1:48060/api/v1/notification \
-H 'Content-Type: application/json' \
-d '{"slug":"edgex-admin-'$rkey'",
     "sender": "System Management",
     "category": "SECURITY",
     "severity": "CRITICAL",
     "contentType": "text/html",
     "content": "<img src=\"data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==\"/>",
     "labels": ["PersonDetection"]}'