# mF2C Microagent

Set of all modules composing the mF2C Microagent

## Prerequisites 

 - Raspberry Pi 3
 - `docker` and `docker-compose` (https://docs.docker.com/compose/install/).
 
## Deploy

1. clone the main mF2C repository:
      
    ```
    git clone https://github.com/mF2C/mF2C
    cd mF2C/microagent    
    ```
2. deploy the microagent by running:

    `docker-compose up`
    
    or
    
    `docker stack deploy --compose-file docker-compose.yml mf2c`
