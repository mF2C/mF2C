# mF2C Agent

insert description

## Prerequisites

- Ubuntu/Debian based distribution (Others may work as well).
- `docker` and `docker-compose` installed.
    - How to install [docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce).
    - How to install [docker-compose](https://docs.docker.com/compose/install/).
- Additional packages are required to run the installation and test scripts:
    - `iw`: Tool for configuring Linux wireless devices. More info [here](https://wireless.wiki.kernel.org/en/users/Documentation/iw).
    - `jq`: Command-line JSON processor. More info [here](https://stedolan.github.io/jq/download/).
    - `git`: Version control system. More info [here](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- An Internet connection.
- Ports `80`, `443`, `1034`, `46000`, `46300`, `46040`, `46020`, `8086`, `8181`, `7474`, and `9001` must be free.

## mF2C Agent installation

### Installation script

1. Clone the main mF2C repository and enter into the directory

    ```bash
    git clone https://github.com/mF2C/mF2C
    cd mF2C/agent    
    ```
2. Register a new user [here](http://dashboard.mf2c-project.eu:800/main.html). (Omitted if already registered. One user can have multiple agents.)
3. Execute the `install.sh` script:
   
   ```bash
   ./install.sh
   ```
    
    *type `install.sh -L` if you want to deploy a Leader Agent or `install.sh -C` to deploy a Cloud Agent*

    - Follow the instructions inside the script.
4. Once installation is completed, wait until all components are healthy
    ```bash
    ./install.sh -s
    ```
    
    **NOTE: Running an Agent with an unhealthy component may cause unexpected errors in the whole stack.**

5. To test if the installation has been successful, run the `hello-world.sh` test.

    ```bash
    ./hello-world.sh
    ```
    
    *add `--include-tests` argument to run all the component tests automatically.*
    

### Manual install
**NOTE:** Manual installation does not configure the wireless interface. 

1. Clone the main mF2C repository and enter into the directory

    ```bash
    git clone https://github.com/mF2C/mF2C
    cd mF2C/agent    
    ```
2. Register a new user [here](http://dashboard.mf2c-project.eu:800/main.html). (Omitted if already registered. One user can have multiple agents.)
3. Create a new `.env` file:

    ```bash
    isLeader=False
    isCloud=False
    MF2C_CLOUD_AGENT="213.205.14.15"
    PHY=
    WIFI_DEV_FLAG=
    usr="<username>"
    pwd="<password>"
    ``` 
    - Replace `<username>` and `<password>` with your mF2C credentials (from step 2).
    - Set `isLeader=True` to deploy a Leader or `isCloud=True` to deploy a Cloud Agent.
4. Launch the agent.

    ```bash
    docker-compose pull    # To get the updated version of the mF2C components.
    docker-compose -p mf2c up -d
    ```
5. Wait until all components are healthy.

    ```bash
    docker-compose -p mf2c ps
    ```
    **NOTE: Running an Agent with an unhealthy component may cause unexpected errors in the whole stack.**

6. To test if the installation has been successful, run the `hello-world.sh` test.

    ```bash
    ./hello-world.sh
    ```
    
    *add `--include-tests` argument to run all the component tests automatically.* 
 
 
## Uninstall the mF2C Agent

### Installation script

1. Inside the `mF2C/agent` directory, run the `install.sh` script with the following arguments:
 
    ```bash
    ./install.sh -S
    ```  
2. Check if the `.env` file has been removed, the script finished without errors, and all the component containers are stopped

    ```bash
    ./install.sh -s
    ```
    
### Manual uninstall

1. Inside the `mF2C/agent` directory, run the following command:

    ```bash
    docker-compose -p mf2c down -v
    ```
2. Check if the mF2C agent has been successfully uninstalled, and all the component containers are stopped

    ```bash
    docker-compose -p mf2c ps
    ```

### Clean-up

The mF2C stack uses a considerable amount of resources, specially disk and RAM. Once the agent is unistalled, is highly recommended to remove the downloaded docker images. More information [here](https://docs.docker.com/config/pruning/). 

```bash
docker image prune -a
```

## Troubleshooting

- **Unhealthy components**: Some components may be unhealthy due to issues during the installation, bad configuration, or other issues. This can happen at any time and provides an easy mechanism to detect uncontrolled behaviours. Please check the documentation for the afected component to see possible causes and solutions.

- **Uninstall failure**: Sometimes, docker-compose deprovisioning fails due to containers attached to the mf2c docker network that are not stopped automatically.
    - run `./install.sh -s`, `docker-compose -p mf2c ps`, or `docker ps` and for each container displayed, run `docker stop <id>`, where `<id>` is the container ID.
    - When no container is displayed, try again to uninstall the agent.
    - Disregard the warning or error message regarding the WiFi detach if the installation is not successful.
 
- **Docker non-privileged**: If the current unix user is not in the `docker` group, the `ERROR: Couldn't connect to Docker daemon at http+docker://localhost - is it running?` message will appear on installing the agent.
    - run `sudo usermod -aG docker your-user` and replace `your-user` with your unix user. More info [here](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-convenience-script).
    - reboot the system to apply changes and try to install again.
    - another way is to execute the `install.sh` or `docker-compose` with **root** privileges.