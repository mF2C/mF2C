# mF2C Agent

Set of all modules composing the mF2C agent

## Usage

Run Docker in swarm mode:

        docker swarm init

Run the docker-compose and execute the hello-world test:

        cd docker-compose
        docker-compose -p mf2c up -d
        ./hello-world.sh

### API

 - GUI for executing services locally `https://localhost/sm/index.html`

### Troubleshooting

 - device-dynamic test fails in the hello-world when executed right after the agent is started. The waiting time for no failures is ~2-5 min, depending on the machine.

### Known issues

 - (multi-agent) when executing agent with "isLeader=True" and "leaderIP=", the address registered in `device-dynamic` is not correct.
 - the logs from these components are illegible: `resource-categorization`
 - the `cimi-server-events` job for `service-operation-report` resource is not catching exceptions when no resource is found
 - DCPROXY returns wrong error code when trying to create duplicated resource (like user). 400 instead of 409
 - Error in Landscaper when dynamic data for device has not been set (see logs)
 - Error in Landscaper hwloc/cpuinfo for device (see logs)
 
## CHANGELOG

### 1.0.2 (24.07.19)

#### Changed
 
 -  Updated versions of different components (fixes dataclay errors)

### 1.0.1 (28.06.19)

#### Changed

 - Fixes random failures during the execution of the hello-world (single-agent)

### 1.0 (26.06.19)

#### Added

 - First release running hello-world (single-agent) 

## Tests

#### Error logs (agent version 1.0.2)

        landscaper_1               | [2019-07-24 15:12:23 UTC] [INFO] : Generating hwloc and cpu_info files 
        landscaper_1               | [2019-07-24 15:12:23 UTC] [INFO] : CIMI Connection OK. Devices returned: 0 
        landscaper_1               | [2019-07-24 15:12:38 UTC] [INFO] : Received empty devices list from CIMI. Sleeping for 15 s 
        landscaper_1               | [2019-07-24 15:12:38 UTC] [INFO] : CIMI Connection OK. Devices returned: 0 
        landscaper_1               | [2019-07-24 15:13:08 UTC] [INFO] : Received empty devices list from CIMI. Sleeping for 30 s 
        landscaper_1               | [2019-07-24 15:13:08 UTC] [INFO] : CIMI Connection OK. Devices returned: 1 
        landscaper_1               | [2019-07-24 15:13:08 UTC] [INFO] : Received non empty devices list from CIMI 
        landscaper_1               | [2019-07-24 15:13:08 UTC] [ERROR] : Dynamic data has not been set for this device: device/55fa608f-ff65-4a8f-8ec1-605ed75c6dc7. No dynamic file will be saved. 
        landscaper_1               | [2019-07-24 15:13:08 UTC] [ERROR] : General Error hwloc/cpuinfo for device: device/55fa608f-ff65-4a8f-8ec1-605ed75c6dc7 - Error message: 'NoneType' object has no attribute 'get' 
        landscaper_1               | [2019-07-24 15:13:08 UTC] [INFO] : Adding physical machines to the landscape... 
        landscaper_1               | [2019-07-24 15:13:08 UTC] [INFO] : HWLocCollector - Adding machine: machine-B 
        landscaper_1               | [2019-07-24 15:13:11 UTC] [INFO] : HWLocCollector - Adding machine: machine-A 
        landscaper_1               | [2019-07-24 15:13:12 UTC] [INFO] : Finished adding physical machines to the landscape. 
        landscaper_1               | [2019-07-24 15:13:12 UTC] [INFO] : ContainerCollector - Adding Docker infrastructure components to the landscape. 
        landscaper_1               | [2019-07-24 15:13:12 UTC] [INFO] : ContainerCollector - Docker infrastructure components added. 
        landscaper_1               | [2019-07-24 15:13:12 UTC] [INFO] : Adding Docker components to the landscape. 
        landscaper_1               | [2019-07-24 15:13:12 UTC] [INFO] : [DOCKER] Adding a container node the Graph 






