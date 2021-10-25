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

deploy-sed:
	sed -i "s/.*rtsp_ip=.*/      - rtsp_ip=$$jsmpeg_rtsp_ip/g" "jsmpeg/compose-files/docker-compose$(JSMPEG_DATA_SRC).yml"
	sed -i "s/.*rtsp_port=.*/      - rtsp_port=$$jsmpeg_rtsp_port/g" "jsmpeg/compose-files/docker-compose$(JSMPEG_DATA_SRC).yml"
	sed -i "s/.*rtsp_url_path=.*/      - rtsp_url_path=$$jsmpeg_rtsp_url_path/g" "jsmpeg/compose-files/docker-compose$(JSMPEG_DATA_SRC).yml"

deploy-ipcam: JSMPEG_DATA_SRC=
deploy-ipcam: deploy-sed jsmpeg-up
deploy-ipcam-down: JSMPEG_DATA_SRC=
deploy-ipcam-down: jsmpeg-down

deploy-ov: JSMPEG_DATA_SRC=-ov
deploy-ov: deploy-sed jsmpeg-up mqtt-up video-inference
deploy-ov-debug: deploy-sed jsmpeg-up mqtt-up
deploy-ov-down: JSMPEG_DATA_SRC=-ov
deploy-ov-down: jsmpeg-down mqtt-down video-inference-stop

deploy-nv: JSMPEG_DATA_SRC=-nv
deploy-nv: deploy-sed jsmpeg-up mqtt-up
deploy-nv-down: JSMPEG_DATA_SRC=-nv
deploy-nv-down: jsmpeg-down mqtt-down

mqtt-up:
	docker-compose -f docker-compose-edgex.yml up -d mqtt-broker
mqtt-down:
	docker-compose -f docker-compose-edgex.yml down

jsmpeg-up:
	docker-compose -f "jsmpeg/compose-files/docker-compose$(JSMPEG_DATA_SRC).yml" up -d
jsmpeg-down:
	docker-compose -f "jsmpeg/compose-files/docker-compose$(JSMPEG_DATA_SRC).yml" down

deploy: JSMPEG_DATA_SRC=-ov
deploy: deploy-sed jsmpeg-up run edgex-rule edgex-notifications wise-export video-inference-record-frames

run:
	docker-compose -f docker-compose-edgex.yml up -d
	docker restart edgex-wrapper
	docker restart edgex-device-mqtt
	# docker pull 'video-analytics-serving-gstreamer:v0.6.1-1.0'
	# docker tag 'advantech1234/video-analytics-serving-gstreamer:v0.6.1-1.0' 'video-analytics-serving-gstreamer:v0.6.1-1.0'
	-docker stop video-analytics-serving-gstreamer

deploy-down: JSMPEG_DATA_SRC=-ov
deploy-down: jsmpeg-down video-inference-stop
	docker-compose -f docker-compose-edgex.yml down

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
video-inference-record-frames:
	cd video-inference && ./run.sh record_frames
video-inference-stop:
	cd video-inference && ./run.sh stop
	-python3 kill.py mqtt_client.py

stop:
	sudo ./stop-dockers.sh

clean: stop
	sudo ./reset-dockers.sh -f docker-compose-edgex.yml
