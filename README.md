# mF2C
Towards an Open, Secure, Decentralized and Coordinated Fog-to-Cloud Management Ecosystem.

[![CI](https://img.shields.io/travis/com/mF2C/mF2C?style=for-the-badge&logo=travis-ci&logoColor=white)](https://travis-ci.com/mF2C/mF2C)

### Components Build Status

[cimi](https://github.com/mF2C/cimi) [![CircleCI](https://circleci.com/gh/mF2C/cimi/tree/master.svg?style=svg)](https://circleci.com/gh/mF2C/cimi/tree/master) 
[service-manager](https://github.com/mF2C/service-manager) [![CircleCI](https://circleci.com/gh/mF2C/service-manager.svg?style=svg)](https://circleci.com/gh/mF2C/service-manager)
[sla-management](https://github.com/mF2C/SlaManagement) [![CircleCI](https://circleci.com/gh/mF2C/SlaManagement.svg?style=svg)](https://circleci.com/gh/mF2C/SlaManagement)

### Deploying mF2C
In this repository you'll find the recipes and files necessary to deploy the mF2C system in your device.


1. install Docker, by following the instructions at https://docs.docker.com/install/

2. clone the main mF2C repository:
      
    ````````
    git clone https://github.com/mF2C/mF2C
    cd mF2C/docker-compose    
3. deploy the agent using docker-compose:
    
    ```````
    docker-compose -p mf2c up -d

4. run the hello-world test
    ````
    ./hello-world.sh
