# Deploying the mF2C System with Docker Swarm

## Prerequisites 

Users that have `docker` and `docker-compose installed on Mac, 
Windows or Linux systems. 

## Installing

Using the version 3 Compose file in this folder, users can deploy the mF2C cloud agent in 2 steps - first the core engine: 

```bash
docker-compose -f docker-compose-core.yml -p mf2c up
```

**Note** that this will only deploy the core services for mF2C (user registration, interface, and database). If you want to deploy the remaining services, make sure to add the proper credentials to `.env` and run:

```bash
docker-compose -f docker-compose-components.yml -p mf2c up
```

_The full installation might take a few minutes, depending on 
the user's local Docker images and network connection_ 


### Adding container monitoring to the cloud agent

To add container monitoring simply run:

`docker run   --volume=/:/rootfs:ro   --volume=/var/run:/var/run:rw   --volume=/sys:/sys:ro   --volume=/var/lib/docker/:/var/lib/docker:ro   --volume=/dev/disk/:/dev/disk:ro   --publish=8080:8080   --detach=true   --name=cadvisor   google/cadvisor:latest`

**Note** that this monitoring page will be publicly available in port 8080. 