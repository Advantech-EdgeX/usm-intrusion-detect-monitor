 Advantech Video Inference Serving Project
## The Software Architecture
![](doc/images/edgex_video_inference_arch_no_title.png)

## Installation prerequisites
* Ubuntu Linux 20.04 LTS 
* [Install and configure Intel OpenVINO Toolkit Version 2021.4.689 for Linux](https://docs.openvino.ai/latest/openvino_docs_install_guides_installing_openvino_linux.html)
  * [Intel Vision Accelerator Design with Intel Movidius VPUs](https://docs.openvino.ai/2021.4/openvino_docs_install_guides_installing_openvino_linux_ivad_vpu.html)
* A USB webcam
* A IP Camera support RTSP video streaming

## Install required software packages
* Use the below make command to install the required software. E.g. Docker, curl, mosquitto-clients…, it takes time.
 ```bash
 $ make install
 ```
* After installation, please __reboot__ system.

[comment]: <> (add user to docker group)

* Clone video-analytics-inference project from github Advantech-Edgex
 ```bash
 $ git clone https://github.com/Advantech-Edgex/video-analytics-serving.git -b feature-full video-inference
 ```

* Clone jsmpeg project from github Advantech-Edgex
 ```bash
 $ git clone https://github.com/Advantech-Edgex/jsmpeg.git -b develop jsmpeg
 ```

## Deploy Video Streaming

### Deploy IPCam RTSP Video Streaming

1. Suppose IPCam RTSP service URL is __rtsp://admin:admin@172.22.24.42/multimedia/video1__, then use below command to deploy.
 ```bash
 $ make deploy-ipcam jsmpeg_rtsp_ip="admin:admin@172.22.24.42" jsmpeg_rtsp_port="554" jsmpeg_rtsp_url_path="multimedia\/video1"
 ```
2. Use web browser to view IPCam video streaming on **http://localhost:7880/** or **http://${host_ipv4}:7880/**.
3. Stop and clear the service by the command.
 ```bash
 $ make deploy-ipcam-down
 ```

### Deploy NVIDIA Jetson Video Inference

1. Suppose NVIDIA Jetson developer kit have RTSP service on __rtsp://172.22.24.120:8554/ds-test__, then use below command to deploy.
 ```bash
 $ make deploy-nv jsmpeg_rtsp_ip="172.22.24.120" jsmpeg_rtsp_port="8554" jsmpeg_rtsp_url_path="ds-test"
 ```
2. Check the running service by **http://localhost:7880/** or **http://${host_ipv4}:7880/**.
3. Stop and clear the service by the command.
 ```bash
 make deploy-nv-down
 ```

### Deploy OpenVINO Video Analytics Inference

1. Run up service with OpenVINO current configuration __video-inference/run.conf__.
 ```bash
 $ make deploy-ov
 ```
2. Check the running service by **http://localhost:7880/** or **http://${host_ipv4}:7880/**.
3. Stop and clear the service by the command.
 ```bash
 $ make deploy-ov-down
 ```

### Deploy Person Intrusion Service by OpenVINO Video Analytics Inference record_frames sample

* The following tasks involving in the deploy:
  * Edge microservices including EdgeX, video AI service, SMTP server...
  * rule engine
  * alert and notification
  * WISE-PaaS APP service
  * video AI service

1. Run up all services with OpenVINO current record_frames sample configuration.
 ```bash
 $ make deploy
 ```
2. Use web browser to view the inference video on **http://localhost:7880/** or **http://${host_ipv4}:7880/**.
3. Check the intrusion images on MailHog SMTP server web UI **http://localhost/** or **http://${host_ipv4}:7880/**.
4. Stop and clear the service by the command.
 ```bash
 $ make deploy-ov-down
 ```

## OpenVINO Inference Configuration Combination

1. Use **video-inference/run.conf** file to compose different run-time configuration.
2. Hardware accelerator support below devices. Use the variable DEVICE to configure it. Ex. _DEVICE="CPU"_.
    * CPU
    * GPU
    * HDDL

[comment]: <> (multiple devices?)

3. Video Data Source

   3-1. Below types are supported. Choose it with the variable SOURCE_TYPE. Ex. _SOURCE_TYPE="--src-file"_.
  
    * --src-webcam
    * --src-ipcam
    * --src-file
    * --src-http

   3-2. According to SOURCE_TYPE and reference media examples in run.conf comment, to configure MEDIA variable.

4. Deep Learning Models and Gstreamer Pipelines

   There are 4 predefined model and pipeline combination. Choose one of them and comment others out.

    * model: person-vehicle-bike-detection-crossroad-1016
    * model: yolo-v4-tf
    * model: face-detection-retail-0005
    * model: action-recognition-0001-decoder

[comment]: <> (user download?)

## Logs and Debugging

### OpenVINO inference container logs

The container name is __video-analytics-serving-gstreamer__
 ```bash
 $ docker logs video-analytics-serving-gstreamer
 ```

### OpenVINO inference Debugging

Run inference server and client on foreground.

1. Comment run.conf DETACH=...
2. Up services mqtt and jsmpeg
 ```bash
 $ make deploy-ov-debug
 ```
3. Run inference server foreground
 ```bash
 $ cd video-inference; ./run.sh server
 ```
4. Run inference client foreground in another terminal
 ```bash
 $ cd video-inference; ./run.sh client
 ```

[comment]: <> (jsmpeg debug?)

## OpenVINO C++ benchmark_app
[openvino_inference_engine_samples_benchmark_app_README](https://github.com/openvinotoolkit/openvino/tree/master/inference-engine/samples/benchmark_app)

### Purpose
Use the Benchmark C++ Tool to estimate deep learning inference performance on supported devices. Performance can be measured for two inference modes: latency- and throughput-oriented, refer to synchronous and asynchronous modes respectively.

> **NOTE:** This is C++ implementation of the Benchmark Tool usage hint. For the Python implementation, refer to [Benchmark Python Tool](https://github.com/openvinotoolkit/openvino/blob/master/tools/benchmark_tool/README.md).

### How It Works
The benchmark_app is command-line tool which reads parameters and loads a network and inputs (images/binary files) to the specified device.

>  **NOTE**: By default, Inference Engine samples, tools and demos expect input with BGR channels order.
  For more information about the argument, refer to **When to Reverse Input Channels** section of
  [Converting a Model Using General Conversion Parameters](https://github.com/openvinotoolkit/openvino/blob/master/docs/MO_DG/prepare_model/convert_model/Converting_Model_General.md).

Device-specific execution parameters (number of streams, threads, and so on) can be either explicitly specified through the command line or left default. The default configuration usually select the values for the optimal throughput. But it is still may be sub-optimal for some cases, especially for very small networks. More details can read in [Introduction to Performance Topics](https://github.com/openvinotoolkit/openvino/blob/master/docs/IE_DG/Intro_to_Performance.md).

[comment]: <> (-niter and -t)

During the execution, the application calculates latency (if applicable) and overall throughput:

* By default, the median latency value is reported
* Throughput is calculated as overall_inference_time/number_of_processed_requests. Note that the throughput value also depends on batch size.

[comment]: <> (per-layer Performance Measurement PM)
[comment]: <> (-exec_graph_path parameter)


### Run the Tool
The simplest command produces optimal performance for CPU.
   ```bash
   $ ./benchmark_app -m <model> -i <input>
   ```

As explained in the  [Introduction to Performance Topics](https://github.com/openvinotoolkit/openvino/blob/master/docs/IE_DG/Intro_to_Performance.md) section, for all devices, including new [MULTI device](https://github.com/openvinotoolkit/openvino/blob/master/docs/IE_DG/supported_plugins/MULTI.md) it is preferable to use the FP16 IR for the model.

Running the application with the `-h` option yields the usage message, and with the empty list of options yields the same usage message and an error message.

[comment]: <> (one or more inputs)

To run the tool, you can use [public](@ref omz_models_group_public) or [Intel's](@ref omz_models_group_intel) pre-trained models from the Open Model Zoo. The models can be downloaded using the [Model Downloader](@ref omz_tools_downloader).

> **NOTE**: Before running the tool with a trained model, make sure the model is converted to the Inference Engine format (\*.xml + \*.bin) using the [Model Optimizer tool](https://github.com/openvinotoolkit/openvino/blob/master/docs/MO_DG/Deep_Learning_Model_Optimizer_DevGuide.md).
>
> The sample accepts models in ONNX format (.onnx) that do not require preprocessing.


### Examples of Running benchmark_app

This section provides step-by-step instructions on how to run benchmark_app with the `googlenet-v1` public model on CPU, GPU or HDDL devices. As an input, the `car.png` file from the `<INSTALL_DIR>/samples/scripts/` directory is used.

> **NOTE:** The Internet access is required to execute the following steps successfully.

1. Download the model. Go to the the Model Downloader directory and run the `downloader.py` script with specifying the model name and directory to download the model to:
   ```sh
   cd <INSTAL_DIR>/deployment_tools/open_model_zoo/tools/downloader
   ```
   ```sh
   python3 downloader.py --name googlenet-v1 -o <models_dir>
   ```
   * [console log](doc/log/downloader_py_0.log)
   
2. Convert the model to the Inference Engine IR format. Go to the Model Optimizer directory and run the `mo.py` script with specifying the path to the model, model format (which must be FP32 for CPU and FPG) and output directory to generate the IR files:
   ```sh
   cd <INSTALL_DIR>/deployment_tools/model_optimizer
   ```
   ```sh
   python3 mo.py --input_model <models_dir>/public/googlenet-v1/googlenet-v1.caffemodel --data_type FP32 --output_dir <ir_dir>
   ```
   * [console log](doc/log/mo_py_0.log)

3. Run the tool with specifying the `<INSTALL_DIR>/samples/scripts/car.png` file as an input image, the IR of the `googlenet-v1` model and a device to perform inference on. The following commands demonstrate running the Benchmark Tool in the asynchronous mode on devices:

   * On <DEVICE>=CPU,GPU,HDDL:
   ```sh
   ./benchmark_app -m <ir_dir>/googlenet-v1.xml -i <INSTALL_DIR>/samples/scripts/car.png  -d <DEVICE> -api async --progress true
   ```


   The application outputs the number of executed iterations, total duration of execution, latency, and throughput. Additionally, if you set the `-report_type` parameter, the application outputs statistics report. If you set the `-pc` parameter, the application outputs performance counters. If you set `-exec_graph_path`, the application reports executable graph information serialized. All measurements including per-layer PM counters are reported in milliseconds.

   Below are fragments the sample output for CPU and GPU devices:

   * For CPU:
      * [console log](doc/log/benchmark_app_cpu_async_0.log)
   ```
   [Step 10/11] Measuring performance (Start inference asynchronously, 4 inference requests using 4 streams for CPU, limits: 60000 ms duration)
   [ INFO ] First inference took 11.73 ms
   Progress: [....................] 100% done
   
   [Step 11/11] Dumping statistics report
   Count:      10400 iterations
   Duration:   60032.59 ms
   Latency:    22.71 ms
   Throughput: 173.24 FPS
   ```
   
   * For GPU:
      * [console log](doc/log/benchmark_app_gpu_async_0.log)
   ```
   [Step 10/11] Measuring performance (Start inference asynchronously, 4 inference requests using 2 streams for GPU, limits: 60000 ms duration)
   [ INFO ] First inference took 13.64 ms
   Progress: [....................] 100% done
   
   [Step 11/11] Dumping statistics report
   Count:      5488 iterations
   Duration:   60065.45 ms
   Latency:    43.72 ms
   Throughput: 91.37 FPS
   ```

   * For HDDL:
      * [console log](doc/log/benchmark_app_hddl_async_0.log)
   ```
   [Step 10/11] Measuring performance (Start inference asynchronously, 32 inference requests, limits: 60000 ms duration)
   [ INFO ] First inference took 24.27 ms
   Progress: [....................] 100% done
   
   [Step 11/11] Dumping statistics report
   Count:      45152 iterations
   Duration:   60065.52 ms
   Latency:    41.93 ms
   Throughput: 751.71 FPS
   ```

