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





