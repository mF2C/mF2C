# SERVICE MANAGER

Responsible of categorizing services into the system and improving QoS before and during the execution of a service

## Usage

### API

- Endpoint `http://localhost:46200`
- GET `/api` -> returns the list of all services
- GET `/api/<service_id>` -> returns the specified service
- POST `/api`, DATA `service` -> submit new service
- GET `/api/{service_instance_id}` -> check QoS and returns the specified service instance

The rest of actions can be performed through the GUI `https://localhost/sm/index.html`

#### Examples

submitting a new service:

    POST /api
    DATA:
        {
             "name": "compss-hello-world",
             "description": "hello world example",
             "exec": "mf2c/compss-test:it2",
             "exec_type": "compss",
             "exec_ports": [8080, 8081],
             "agent_type": "normal",
             "num_agents": 1,
             "cpu_arch": "x86-64",
             "os": "linux",
             "cpu": 0.0,
             "memory": 0.0,
             "disk": 0.0,
             "network": 0.0,
             "storage_min": 0,
             "req_resource": ["sensor_1"],
             "opt_resource": ["sensor_2"]
        }

### Troubleshooting

## CHANGELOG

### 1.10.2 (06.12.19)

 - Added initial values for cpu, memory, disk, network when a service is registered
 
### 1.10.1 (15.11.19)

 - Added the SLA template id when launching a service through the GUI
 
### 1.10.0 (13.11.19)

 - Updated QoS enforcement to consider different guarantees for every service operation
 - Updated SM-LM interface for the GUI

### 1.9.3 (24.10.19)

#### Changed

 - Now QoS enforcement takes into account the number of agents used from service-instance instead from service.
 
### 1.9.2 (21.10.19)

#### Changed

 - Updates logging in the QoS Enforcement.
 - Fixes a bug in QoS enforcement when retrieving a service from a service-instance.
 - Fixes a bug in QoS with SLA constraint parameters

### 1.9.1 (08.10.19)

#### Changed

 - Fixes a bug when updating a `qos-model` into cimi.

### 1.9.0 (07.10.19)

#### Changed

 - QoS Provider updated to work without `agreement` and with `device_id` instead of `url` in the `agent` resource.

### 1.8.4 (03.10.19)

#### Changed

 - Now if a service-instance has no valid agreement and the qos-model cannot be submitted, the QoS Provider returns 404.

### 1.8.3 (16.09.19)

#### Added

 - wget to docker image for health check
 
#### Changed

 - Fixes long strings formatting in the GUI
 
 
### 1.8.2 (16.08.19)

#### Changed

 - New library for the SSE client
 
 
### 1.8.1 (15.08.19)

#### Changed

 - Checks if cimi is up before trying to connect to the event manager
 - Improves the logs
 
### 1.8.0 (14.05.19)

#### Added

 - Now QoS enforcement supports subscription to the Event Manager
 - Added a new call to Lifecycle when the expected execution time of a service is longer than the one specified in the agreement

#### Changed

 - updated service definition
 - shortened api endpoints





