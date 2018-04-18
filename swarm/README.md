# Deploying the mF2C System with Docker Swarm

## Prerequisites 

Users that have `docker` installed on Mac, 
Windows or Linux systems. A single node Docker Swarm should also be running - `docker swarm init`.

## Installing

Using the version 3 Compose file in this folder, users can deploy a service stack into the single node Swarm: 

```bash
docker-compose -f docker-compose-core.yml up
```

**Note** that this will only deploy the core services for mF2C (user registration, interface, and database). If you want to deploy the remaining services, make sure to add the proper credentials to `.env` and run:

```bash
docker-compose -f docker-compose-components.yml up
```

_The full installation might take a few minutes, depending on 
the user's local Docker images and network connection_ 