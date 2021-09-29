# /*******************************************************************************
#  * Copyright 2021 Advantech
#  *
#  * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
#  * in compliance with the License. You may obtain a copy of the License at
#  *
#  * http://www.apache.org/licenses/LICENSE-2.0
#  *
#  * Unless required by applicable law or agreed to in writing, software distributed under the License
#  * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
#  * or implied. See the License for the specific language governing permissions and limitations under
#  * the License.
#  *
#  *******************************************************************************/
SHELL := /bin/bash

.PHONY: help install deploy run edgex-rule edgex-notifications wise-export simulator video-inference stop clean
.SILENT: help install deploy run edgex-rule edgex-notifications wise-export simulator video-inference stop clean

help:
	echo "Refer to README.md"

install:
	./preinstall.sh

deploy: run edgex-rule edgex-notifications wise-export video-inference

run:
	sudo docker-compose -f docker-compose-edgex-china-challenge.yml up -d
	sudo docker restart edgex-wrapper
	sudo docker restart edgex-device-mqtt
	sudo docker pull 'advantech1234/video-analytics-serving-gstreamer:latest'
	sudo docker tag 'advantech1234/video-analytics-serving-gstreamer:latest' 'video-analytics-serving-gstreamer:latest'
	-sudo docker stop video-analytics-serving-gstreamer

edgex-rule:
	cd ruleengine && ./create_rules.sh

edgex-notifications:
	cd notifications && ./create_notifications.sh

wise-export:
	cd wise-export && sudo ./create_wise_datahub_edgex_fuji.sh

simulator:
	cd modbus/simulator && ./run_simulator.sh

video-inference:
	cd video-inference && ./run.sh

stop:
	sudo ./stop-dockers.sh

clean: stop
	sudo ./reset-dockers.sh -f docker-compose-edgex-china-challenge.yml