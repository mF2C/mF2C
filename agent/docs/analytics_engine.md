# ANALYTICS ENGINE (RECOMMENDER)

Analytics Engine provides an analysis of telemetry data and resource utlilization data

## Usage

### API

API description provided here : [Web API Readme](https://github.com/mF2C/analytics_engine/blob/master/analytics_engine/heuristics/sinks/mf2c/README.md)

#### Examples

Please see above referred document for examples 

### Troubleshooting

If incorrect telemetry data is returned or errors, please check and make sure the host name is exported as HOSTNAME environment variable.

## CHANGELOG

### Version 0.3.5

### 10.05.2019 

#### Added

 - None

#### Changed

 - Bugfix : /mf2c/optimal endpoint output modified to remove NaN values. Issue reported by SLA Manager
 - Change : service name in docker-compose.yml changed from analytics_engine to analytics-engine. Issue reported by SLA Manager

#### Tests done

  - Curl command as below : 
  
		curl -H "Content-Type: application/json" -d '{"name":"test"}' -X POST http://localhost:46020/mf2c/optimal

  - Output expected in the below format : 
  
        [
            {"type": "machine", 
             "network saturation": 0.0, 
             "node_name": "IRILD039", 
             "network utilization": 0.0, 
             "disk utilization": 0.0009194394604156363, 
             "compute utilization": 0.07513952833753562, 
             "memory saturation": 0.0, 
             "compute saturation": 0.0, 
             "memory utilization": 0.0925959453062668, 
             "ipaddress": "172.22.0.20", 
             "disk saturation": 0.0}
         ]
        
### Version 0.4.0

### 15.05.2019 

#### Added

 - None

#### Changed

 - Change : Telemetry queries minimized to fetch only the data required for optimal api endpoint.

#### Tests done

  - Curl command as below : 
  
		curl -H "Content-Type: application/json" -d '{"name":"test"}' -X POST http://localhost:46020/mf2c/optimal

  - Output below : 
  
        [
            {"type": "machine", 
             "network saturation": 0.0, 
             "node_name": "IRILD039", 
             "network utilization": 0.0, 
             "disk utilization": 0.0010896216047079803, 
             "compute utilization": 0.09896875356737661, 
             "memory saturation": 0.0, 
             "compute saturation": 0.0, 
             "memory utilization": 0.1067928541914066, 
             "ipaddress": "172.27.0.19", 
             "disk saturation": 0.0}
         ]

 - Execute hello-world.sh
 
 - Output below :
 
		iolie@IRILD039:~/mf2c/mf2c/docker-compose-it2$ ./hello-world.sh 

	    Use --include-tests to run all scripts in the 'tests' folder    

		% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
		100   684  100   166  100   518   2273   7095 --:--:-- --:--:-- --:--:--  9369
 		% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
		100   359  100   156  100   203    305    397 --:--:-- --:--:-- --:--:--   701
		% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
		100  1331  100  1263  100    68   2896    155 --:--:-- --:--:-- --:--:--  3052
		SLA template: sla-template/0c7b96c3-0fce-4930-9d4f-f583785bcdf7
		Service: service/bfdcb739-5ca4-46ad-818b-ba51301207c2
		Service instance: Service deployment operation is being processed...
		
### Version 0.4.5

### 23.05.2019 

#### Added

 - None

#### Changed

 - Change : Updating service definition as per changes in cimi for required resources (cpu_recommended, memory_recommended etc).

#### Tests done

  - Curl command as below : 
  
		curl -H "Content-Type: application/json" -d '{"name":"test"}' -X POST http://localhost:46020/mf2c/optimal

  - Output below : 
  
        [
            {"type": "machine", 
             "network saturation": 0.0, 
             "node_name": "IRILD039", 
             "network utilization": 0.0, 
             "disk utilization": 0.0010896216047079803, 
             "compute utilization": 0.09896875356737661, 
             "memory saturation": 0.0, 
             "compute saturation": 0.0, 
             "memory utilization": 0.1067928541914066, 
             "ipaddress": "172.27.0.19", 
             "disk saturation": 0.0}
         ]
