# LANDSCAPER

Landscaper tracks and provides data about the system landscape

## Usage

Documentation provided here : [Landscaper Readme](https://github.com/mF2C/landscaper/blob/master/README.md)

#### Examples

Please see above referred document for examples 

### Troubleshooting

Check the landscaper log located in the logs.

## CHANGELOG

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