#!/bin/sh
echo "Copy configuration.toml to wise-export-service."
sudo docker cp configuration.toml wise-export-service:/res/
echo "Register to EdgeX..."
sudo curl -X PUT -d "true" http://172.17.0.1:8500/v1/kv/edgex/appservices/1.0/WISEExport/ApplicationSettings/Enable
sudo curl -X PUT -d "WISE-4012, FATEKPLC, Alert" http://172.17.0.1:8500/v1/kv/edgex/appservices/1.0/WISEExport/ApplicationSettings/DeviceNames
sudo curl -X PUT -d "FATEKPLC=Pump" http://172.17.0.1:8500/v1/kv/edgex/appservices/1.0/WISEExport/ApplicationSettings/ResourceWritable
sudo curl -X PUT -d "cc36ad47-59d8-43f6-93d3-2234cb57dc19" http://172.17.0.1:8500/v1/kv/edgex/appservices/1.0/WISEExport/ApplicationSettings/NodeID
sudo curl -X PUT -d "5c42ef522c2dea7670cf944799698bje" http://172.17.0.1:8500/v1/kv/edgex/appservices/1.0/WISEExport/ApplicationSettings/AccessKey
sudo curl -X PUT -d "https://api-dccs-ensaas.sa.wise-paas.com/" http://172.17.0.1:8500/v1/kv/edgex/appservices/1.0/WISEExport/ApplicationSettings/APIURL
echo "Restart wise-export-service..."
sudo docker restart wise-export-service
