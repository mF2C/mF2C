# mF2C Agent

Set of all modules composing the mF2C agent

### Components Build Status

[![CircleCI](https://circleci.com/gh/mF2C/cimi/tree/master.svg?style=svg)](https://circleci.com/gh/mF2C/cimi/tree/master) 
[cimi](https://github.com/mF2C/cimi) 

[![CircleCI](https://circleci.com/gh/mF2C/service-manager.svg?style=svg)](https://circleci.com/gh/mF2C/service-manager)
[service-manager](https://github.com/mF2C/service-manager) 

[![CircleCI](https://circleci.com/gh/mF2C/SlaManagement.svg?style=svg)](https://circleci.com/gh/mF2C/SlaManagement)
[sla-management](https://github.com/mF2C/SlaManagement) 

## Prerequisites 

 - Ubuntu based distribution.
 - `docker` and `docker-compose` (https://docs.docker.com/compose/install/).
 - Run Docker in swarm mode.
 - Wireless network interface card.
 
### Deploy

1. clone the main mF2C repository:
      
    ```
    git clone https://github.com/mF2C/mF2C
    cd mF2C/agent    
    ```

2. deploy the agent by running:
    
    `mf2c.sh`
    
    *use `mf2c.sh -L` if the node is a leader or `mf2c.sh -C` if the node is a Cloud Agent*
    
3. wait until all components are healthy

    `mf2c.sh -s`
    
    **NOTE: Running an Agent with an unhealthy component may cause unexpected errors in the whole stack.** 

4. run the hello-world test
    
    `./hello-world.sh --include-tests`

6. to shutdown the agent:

    `./mf2c.sh -S`

# Docs

 - [ACLib](agent/docs/aclib.md)
 - [CIMI](agent/docs/cimi.md)
 - [Analytics Engine](agent/docs/analytics_engine.md)
 - [CAU Client](agent/docs/cau_client.md)
 - [DCProxy](agent/docs/dcproxy.md)
 - [ds1java1](agent/docs/ds1java1.md)
 - [Identification](agent/docs/identification.md)
 - [Landscaper](agent/docs/landscaper.md)
 - [Logicmodule](agent/docs/logicmodule1.md)
 - [mF2C Agent](agent/docs/mf2c_agent.md)
 - [Policies](agent/docs/policies.md)
 - [Resource Categorization](agent/docs/resource-categorization.md)
 - [Resource Bootstrap](agent/docs/resource-bootstrap.md)
 - [Service Manager](agent/docs/service_manager.md)
 - [SLA Management](agent/docs/sla_management.md)
 - [SLA Management UI](agent/docs/sla_management_ui.md)
 - [VPN client](agent/docs/vpnclient.md)


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




