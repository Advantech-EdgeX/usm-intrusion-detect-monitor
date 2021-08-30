#!/bin/sh

rkey=$(date +"%T")

curl -X POST \
http://172.17.0.1:48060/api/v1/notification \
-H 'Content-Type: application/json' \
-d '{"slug":"edgex-admin-'$rkey'",
     "sender": "System Management",
     "category": "SECURITY",
     "severity": "CRITICAL",
     "contentType": "text/plain",
     "content": "123",
     "labels": ["PersonDetection"]}'