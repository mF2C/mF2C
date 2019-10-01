# Polices

> Policies - Resource Management
> CRAAX - UPC, 2019
> The Policies module is a component of the European Project mF2C.

Policies module is responsible for: 

- Define the resilience and clustering policies.
- Enforce the protection of the area (Leader and Backup).
- Definition and Execution of the Leader Election Algorithm.
- Orchestration of the Resource Manager Block.

## Usage

The Policies module can be run ussing the dockerized version or directly from source.

#### Docker

Last build version from docker hub: `docker run --rm mf2c/policies:<version>`

Replace *<version>* with a valid uploaded version [here](https://cloud.docker.com/u/mf2c/repository/docker/mf2c/policies/tags).

#### Source

`Python 3.7.x` is required to execute this code.

1. Clone the repository with Git. It's hightly recomended to create a Python virtual environment.
2. Install all the library dependencies: `pip3 install -r requirements.txt`
2. Execute the following command: `python3 main.py`


### Environment variables

To run policies module along other mF2C components, is necessary to specify the following environment variables:

```yaml
- "MF2C=True"
```

##### The interface used by discovery is specified in:

```yaml
- "WIFI_DEV_FLAG="
```

**NOTE**: Specific configurations are required in Discovery to attach the interface. This parameter is only used to inform Discovery at the startup.

##### To modify the role of the agent (normal/leader): 

```yaml
- "isLeader=False"
```

##### To specify static leader and device IPs:

```yaml
- "leaderIP="
- "deviceIP="
```

**NOTE**: Only used when Discovery cannot detect a nearby Leader. These variables should only be used for testing purposes and internal mF2C procedures may fail if they are modified.


### API

All the API calls are made via REST. The endpoints and required parameters can be consulted on [http://{policies_address}:46050/](http://localhost:46050/)

**Note:** Replace *policies_address* with the real address of the container or device where the code is running.

#### Resource Manager Status

Get resource manager module start status and errors on triggers.

- **GET**  /rm/components

```bash
curl -X GET "http://localhost/rm/components" -H "accept: application/json"
```

- **RESPONSES**
    - **200** - Success
    - **Response Payload:** 
    ```json
    {
  "started": true,                              // The agent is started
  "running": true,                              // The agent is currently running
  "modules": [                                  // List of modules that are triggered on starting
    "string"
  ],
  "discovery": true,                            // Discovery module is started
  "identification": true,                       // Identification module is started
  "cau_client": true,                           // CAUClient module is started
  "categorization": true,                       // Categorization module is started
  "policies": true,                             // Area Resilience module is started
  "discovery_description": "string",            // Discovery module description / parameters received
  "identification_description": "string",       // Identification module description / parameters received
  "categorization_description": "string",       // Categorization module description / parameters received
  "policies_description": "string",             // Policies module description / parameters received
  "cau_client_description": "string"            // CAUClient module description / parameters received
    }
    ```

#### Keepalive

Keepalive entrypoint for Leader. Backups send message to this address and check if the Leader is alive. Only registered backups are allowed to send keepalives, others will be rejected.

- **POST** /api/v2/resource-management/policies/keepalive
- **PAYLOAD**  `{"deviceID": "agent/1234"}`

```bash
curl -X POST "http://localhost/api/v2/resource-management/policies/keepalive" -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"deviceID\": \"agent/1234\"}"
```

- **RESPONSES**
    - **200** - Success
    - **403** - Agent not authorized
    - **405** - Device is not a Leader
    - **Response Payload:** `{
  "deviceID": "leader/1234",
  "backupPriority": 0
}` 

#### Leader Info

Check if the agent is a Leader or Backup.

- **GET** /api/v2/resource-management/policies/leaderinfo

```bash
curl -X GET "http://localhost/api/v2/resource-management/policies/leaderinfo" -H "accept: application/json"
```

- **RESPONSES**
    - **200** - Success
    - **Response Payload:** `{
  "imLeader": false,
  "imBackup": false
}`

#### Reelection

Send a message to trigger the reelection process. The specified agent will be the reelected leader if it accepts.

- **POST** /api/v2/resource-management/policies/reelection
- **PAYLOAD** `{
  "deviceID": "agent/1234"
}`

```bash
curl -X POST "http://localhost/api/v2/resource-management/policies/reelection" -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"deviceID\": \"agent/1234\"}"
```

- **RESPONSES**
    - **200** - Reelection Successful
    - **401** - The Agent is not authorized to trigger the reelection
    - **403** - Reelection failed
    - **404** - Device not found or IP not available
    - **Response Payload:** `{
  "imLeader": false,
  "imBackup": false
}`

#### Start Area Resilience

Starts the Area Resilience submodule (in charge of the Leader Protection)

- **GET** /api/v2/resource-management/policies/startAreaResilience

```bash
curl -X GET "http://localhost/api/v2/resource-management/policies/startAreaResilience" -H "accept: application/json"
```

- **RESPONSES**
    - **200** - Started
    - **403** - Already Started
    
#### Start Agent

Start the agent (start as Leader or Normal agent + Discovery, CAU Client and Categorization Triggers)

- **GET** /api/v2/resource-management/policies/policiesstartAgent

```bash
curl -X GET "http://localhost/api/v2/resource-management/policiesstartAgent" -H "accept: application/json"
```

- **RESPONSES**
    - **200** - Started
    - **403** - Already Started

    
#### Role Change

Change the agent from current role to specified one (leader, backup or agent).

- **GET** /api/v2/resource-management/policies/roleChange/{role}

```bash
curl -X GET "http://localhost/api/v2/resource-management/policies/roleChange/agent" -H "accept: application/json"
curl -X GET "http://localhost/api/v2/resource-management/policies/roleChange/backup" -H "accept: application/json"
curl -X GET "http://localhost/api/v2/resource-management/policies/roleChange/leader" -H "accept: application/json"
```

- **RESPONSES**
    - **200** - Successful
    - **403** - Not Successful
    - **404** - Role not found
    


#### 

### Troubleshooting

### Known Issues

    + Leader will fail to find available backups as Topology is not coded to be received/generated.

## CHANGELOG

### 2.0.7 (01/10/2019)

#### Added

    + CAU client is triggered from the Leader

#### Changed

    * Reduced the amount of logs from backups
    * Area Resilience get the topology from childrenIPs
    * Minor change in message syntax for keepalive messages

### 2.0.6 (23/09/2019)

#### Added

    + Static configuration for deviceIP and leaderIP restored for custom testing purposes.
    
#### Changed

    * Timeout added on discovery JOIN and MYIP triggers to avoid infinite loops.

### 2.0.5 (18/09/2019)

#### Changed

    * Discovery is now outside the docker-compose network. Policies get automatically the IP

### 2.0.4 (10/09/2019)

#### Added

    + Discovery Triggers: JOIN and DHCP

#### Changed
    
    * Discovery triggers are now more verbose on debug mode.
    * Identification trigger updated
    * CAU client trigger updated
    * BUG: When identification doesn't provide a valid deviceID, CAU client fails, crashing the Agent CIMI resource.
     

### 2.0.3 (04/07/2019)

#### Changed

    * BUG: Agent resource not created correctly on Leader due isAuth and connected values.
    * Incremented the amount of registration attempts to avoid errors on slower machines.


### 2.0.2 (20/05/2019)

#### Added

    + LeaderIP environment variable added.

#### Changed

    * Agent resource include Leader IP if specified in env. variable.

### 2.0.1 (15/05/2019)

#### Added

    + Create/Modify Agent Resource
    + Documentation Added

#### Changed

    * README updated
    
    
### 2.0.0 (17/04/2019)

#### Added

    + Leader Election PLE, ALE implemented
    + Leader Protection (AR and LR) implemented
    + LICENSE added
    + logging implemented

#### Changed

    * Agent to Leader and Leader to Agent reusable procedure
    * CIMI and Identification availability scan before start
    * AR REST protocol
    * AgentStart code reviewed
    * REST API documented
    * Dockerfile redefinition
    * README updated
    
#### Removed

    - Old deprecated and test files deleted
    
