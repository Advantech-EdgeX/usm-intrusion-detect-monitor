#!/bin/bash
host="172.17.0.1"
port="25"

CONSUL_SETTING_URL=http://172.17.0.1:8500/v1/kv/edgex/core/1.0/edgex-support-notifications/Smtp
sudo curl -X PUT -d ${host} $CONSUL_SETTING_URL/Host
sudo curl -X PUT -d ${port} $CONSUL_SETTING_URL/Port
sudo curl -X PUT -d "" $CONSUL_SETTING_URL/Username
sudo curl -X PUT -d "" $CONSUL_SETTING_URL/Password
sudo curl -X PUT -d "admin@edgex.foundry" $CONSUL_SETTING_URL/Sender
sudo curl -X PUT -d "EdgeX Notification" $CONSUL_SETTING_URL/Subject
sudo docker restart edgex-support-notifications
