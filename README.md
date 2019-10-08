# mF2C
Towards an Open, Secure, Decentralized and Coordinated Fog-to-Cloud Management Ecosystem.

[![CI](https://img.shields.io/travis/com/mF2C/mF2C?style=for-the-badge&logo=travis-ci&logoColor=white)](https://travis-ci.com/mF2C/mF2C)

### Components Build Status

[![CircleCI](https://circleci.com/gh/mF2C/cimi/tree/master.svg?style=svg)](https://circleci.com/gh/mF2C/cimi/tree/master) 
[cimi](https://github.com/mF2C/cimi) 

[![CircleCI](https://circleci.com/gh/mF2C/service-manager.svg?style=svg)](https://circleci.com/gh/mF2C/service-manager)
[service-manager](https://github.com/mF2C/service-manager) 

[![CircleCI](https://circleci.com/gh/mF2C/SlaManagement.svg?style=svg)](https://circleci.com/gh/mF2C/SlaManagement)
[sla-management](https://github.com/mF2C/SlaManagement) 

### Deploying mF2C
In this repository you'll find the recipes and files necessary to deploy the mF2C system in your device.


1. install Docker, by following the instructions at https://docs.docker.com/install/

2. clone the main mF2C repository:
      
    ```
    git clone https://github.com/mF2C/mF2C
    cd mF2C/docker-compose    
    ```

3. deploy the agent by running:
    
    `install.sh    # use -L if the node is a leader`
    
4. wait until all components are healthy

    `install.sh -s`
    
    **NOTE: Running an Agent with an unhealthy component may cause unexpected errors in the whole stack.** 

5. run the hello-world test
    
    `./hello-world.sh --include-tests`

6. to shutdown the agent:

    `./install.sh -S`

# Docs

 - [ACLib](./docs/aclib.md)
 - [CIMI](./docs/cimi.md)
 - [Analytics Engine](./docs/analytics_engine.md)
 - [CAU Client](./docs/cau_client.md)
 - [DCProxy](./docs/dcproxy.md)
 - [ds1java1](./docs/ds1java1.md)
 - [Identification](./docs/identification.md)
 - [Landscaper](./docs/landscaper.md)
 - [Logicmodule](./docs/logicmodule1.md)
 - [mF2C Agent](./docs/mf2c_agent.md)
 - [Policies](./docs/policies.md)
 - [Resource Categorization](./docs/resource-categorization.md)
 - [Service Manager](./docs/service_manager.md)
 - [SLA Management](./docs/sla_management.md)
 - [VPN client](./docs/vpnclient.md)

