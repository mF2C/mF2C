# LANDSCAPER

Landscaper tracks and provides data about the system landscape

## Usage

Documentation provided here : [Landscaper Readme](https://github.com/mF2C/landscaper/blob/master/README.md)

#### Examples

Please see above referred document for examples 

### Troubleshooting

Check the landscaper log located in the logs.

### Version 0.6.14

### 26.09.2019

#### Added

 - Added wifiAddress field to the device dynamic parser 

#### Changed

 - None

## CHANGELOG

### Version 0.6.13

### 25.09.2019

#### Added

 - None

#### Changed

 - Fixed generate_files() logic by making device dynamic optional 

### Version 0.6.11

### 04.09.2019

#### Added

 - None

#### Changed

 - Fixed functionality to store and update container metrics in Cimi

### Version 0.6.9

### 01.08.2019 

#### Added

 - None

#### Changed

 - Docker collector will bootstrap swarm if node is not part of swarm cluster

### Version 0.6.5

### 23.05.2019 

#### Added

 - None

#### Changed

 - IP Address parsing : Logic added to IP address parsing from hwloc string.

#### Tests done

  - Curl command as below : 
  
		curl http://localhost:9001/graph

  - Output expected in the below format : 
  
	       {"directed": true, "graph": {}, "nodes": [{"CpuPeriod": 0, .....}, .... {...}], "links": [{"target": 31, "to": 1924905600,....}, .... {....}], "multigraph": false}
