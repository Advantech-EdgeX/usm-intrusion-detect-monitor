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
     "content": "<img src=\"https://i1.kknews.cc/SIG=4ducgg/52s00003o8n5549r52o.jpg\"/>",
     "labels": ["PersonDetection"]}'