#!/bin/sh

#########################
# Version: 1.0.0
#########################

Enable="true"
# NodeID="cc36ad47-59d8-43f6-93d3-2234cb57dc19"
# AccessKey="5c42ef522c2dea7670cf944799698bje"
# APIURL="https://api-dccs-ensaas.sa.wise-paas.com/"
DeviceNames="WISE-4012, FATEKPLC, Alert"
ResourceWritable="FATEKPLC=Pump"

NodeID="45316a9a-014e-49b3-8471-f16ae5922524"
AccessKey="64abf2de2910644da62456f0470bealb"
APIURL="https://api-dccs-ensaas.hz.wise-paas.com.cn/"
# DeviceNames="MQTTAnalyticservice, Random-Integer-Generator01"
# ResourceWritable="WISE-4012=Pump, WISE-4012=WaterLevel

#########################
Host=wise-export-service
ExportFile=wise_export_register.sh
#########################

#########################
# Check curl
#########################
echo -n "Check curl..."
curl --help > /dev/null
RES=$?
if [ ${RES} != 0 ]; then
    echo "Install curl"
    sudo apt-get -y install curl
else
    echo "OK"
fi

echo "--------------------------------------------------"
echo "Enable: ${Enable}"
echo "NodeID: ${NodeID}"
echo "AccessKey: ${AccessKey}"
echo "APIURL: ${APIURL}"
echo "DeviceNames: ${DeviceNames}"
echo "ResourceWritable: ${ResourceWritable}"
echo "--------------------------------------------------"
#==================================================
#For EdgeX Fuji
#==================================================
CONSUL_SETTING_URL=http://172.17.0.1:8500/v1/kv/edgex/appservices/1.0/WISEExport/ApplicationSettings
sudo docker images | grep -q advantech1234/docker-app-functions-wise
RES=$?
if [ ${RES} = 0 ]; then
    echo "Create ${ExportFile} & configuration.toml..."
########### configuration.toml ###########
echo "[Writable]
LogLevel = 'DEBUG'
[Writable.StoreAndForward]
Enabled = false
RetryInterval = '5m'
MaxRetryCount = 10

[Service]
BootTimeout = '30s'
ClientMonitor = '15s'
CheckInterval = '10s'
Host = '${Host}'
Port = 48099
Protocol = 'http'
ReadMaxLimit = 100
StartupMsg = 'WISE Export Service'
Timeout = '30s'

[Registry]
Host = 'edgex-core-consul'
Port = 8500
Type = 'consul'

[Logging]
EnableRemote = false
File = ''

# Database is require when Store and Forward is enabled
[Database]
Type = 'redisdb'
Host = 'localhost'
Port = 6379
Timeout = '30s'
Username = ''
Password = ''

# SecretStore is required when Store and Forward is enabled and running with security
# so Databse credentails can be pulled from Vault.
[SecretStore]
Host = 'localhost'
Port = 8200
Path = '/v1/secret/edgex/application-service/'
Protocol = 'https'

[SecretStore.Authentication]
  AuthType = 'X-Vault-Token'
  AuthToken = 'edgex'

[Clients]
  [Clients.CoreData]
    Protocol = 'http'
    Host = 'edgex-core-data'
    Port = 48080

  [Clients.Logging]
    Protocol = 'http'
    Host = 'edgex-support-logging'
    Port = 48061

[MessageBus]
  Type = 'zero'
    [MessageBus.PublishHost]
        Host = '*'
        Port = 5564
        Protocol = 'tcp'
    [MessageBus.SubscribeHost]
        Host = 'edgex-core-data'
        Port = 5563
        Protocol = 'tcp'

# Choose either an HTTP trigger or MessageBus trigger (aka Binding)

#[Binding]
#Type="http"

[Binding]
Type='messagebus'
SubscribeTopic='events'
PublishTopic='somewhere'

[ApplicationSettings]
DeviceNames    = \"${DeviceNames}\"
ResourceWritable  = \"${ResourceWritable}\"
Enable         = \"${Enable}\"
NodeID         = \"${NodeID}\"
AccessKey      = \"${AccessKey}\"
APIURL         = \"${APIURL}"\" > configuration.toml
########### configuration.toml end ###########

echo "#!/bin/sh
echo \"Copy configuration.toml to ${Host}.\"
sudo docker cp configuration.toml ${Host}:/res/
echo \"Register to EdgeX...\"
sudo curl -X PUT -d \"${Enable}\" $CONSUL_SETTING_URL/Enable
sudo curl -X PUT -d \"${DeviceNames}\" $CONSUL_SETTING_URL/DeviceNames
sudo curl -X PUT -d \"${ResourceWritable}\" $CONSUL_SETTING_URL/ResourceWritable
sudo curl -X PUT -d \"${NodeID}\" $CONSUL_SETTING_URL/NodeID
sudo curl -X PUT -d \"${AccessKey}\" $CONSUL_SETTING_URL/AccessKey
sudo curl -X PUT -d \"${APIURL}\" $CONSUL_SETTING_URL/APIURL
echo \"Restart ${Host}...\"
sudo docker restart ${Host}" > ${ExportFile}
chmod +x ${ExportFile}
./${ExportFile}
else
    echo "${Host} not found."
fi
