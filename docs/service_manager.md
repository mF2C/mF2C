# SERVICE MANAGER

Responsible of categorizing services into the system and improving QoS before and during the execution of a service

## Usage

### API

- Endpoint `http://localhost:46200`
- GET `/api/sm` -> returns the list of all services
- GET `/api/sm/<service_id>` -> returns the specified service
- POST `/api/sm`, DATA `service` -> submit new service
- GET `/api/sm/{service_instance_id}` -> check QoS and returns the specified service instance

The rest of actions can be performed through the GUI `https://localhost/sm/index.html`

#### Examples

submitting a new service:

    POST /api/sm
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

### 1.8.0 (14.05.19)

#### Added

 - Now QoS enforcement supports subscription to the Event Manager
 - Added a new call to Lifecycle when the expected execution time of a service is longer than the one specified in the agreement

#### Changed

 - updated service definition
 - shortened api endpoints





