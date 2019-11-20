# mF2C Agent

.

## Prerequisites

- Ubuntu/Debian based distribution (Others may work as well).
- More than `8GB` of RAM and `20GB` of available disk.
- `docker` and `docker-compose` installed.
    - How to install [docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce).
    - How to install [docker-compose](https://docs.docker.com/compose/install/).
- Additional packages are required to run the installation and test scripts:
    - `iw`: Tool for configuring Linux wireless devices. More info [here](https://wireless.wiki.kernel.org/en/users/Documentation/iw).
    - `jq`: Command-line JSON processor. More info [here](https://stedolan.github.io/jq/download/).
    - `git`: Version control system. More info [here](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- An Internet connection.
- Ports `80`, `443`, `1034`, `46000`, `46300`, `46040`, `46020`, `8086`, `8181`, `7474`, and `9001` must be free.
- Disable the `network-manager` service or tag the wireless NIC as unmanaged. More info [here](https://github.com/mF2C/ResourceManagement/tree/master/Discovery#prerequisites-1).

## mF2C Agent installation

Before the installation, to run the mF2C Agent is necessary to be registered as a valid mF2C User. Register a new user [here](http://dashboard.mf2c-project.eu:800/main.html). Validate the registration on the validation mail sent to the specified email. 

This step can be omitted if you are already registered. One user can have multiple agents registered. 

### Installation script

1. Clone the main mF2C repository and enter into the directory

    ```bash
    git clone https://github.com/mF2C/mF2C
    cd mF2C/agent    
    ```
2. Execute the `install.sh` script:
   
   ```bash
   ./install.sh
   ```
    
    *type `install.sh -L` if you want to deploy a Leader Agent or `install.sh -C` to deploy a Cloud Agent*

    - Follow the instructions inside the script.
3. Once installation is completed, wait until all components are healthy
    ```bash
    ./install.sh -s
    ```
    
    **NOTE: Running an Agent with an unhealthy component may cause unexpected errors in the whole stack.**

4. To test if the installation has been successful, run the `hello-world.sh` test.

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
2. Create a new `.env` file:

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
3. Launch the agent.

    ```bash
    docker-compose pull    # To get the updated version of the mF2C components.
    docker-compose -p mf2c up -d
    ```
4. Wait until all components are healthy.

    ```bash
    docker-compose -p mf2c ps
    ```
    **NOTE: Running an Agent with an unhealthy component may cause unexpected errors in the whole stack.**

5. To test if the installation has been successful, run the `hello-world.sh` test.

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

The mF2C stack uses a considerable amount of resources, specially disk and RAM. Once the agent is uninstalled, is highly recommended to remove the downloaded docker images. More information [here](https://docs.docker.com/config/pruning/). 

```bash
docker image prune -a
```

## Topology formation

The mF2C agent automatically build the topology (connect to the Leader/Cloud Agent, resource information sync, leave detection, etc...) using primarily the [Discovery](https://github.com/mF2C/ResourceManagement/tree/master/Discovery#mf2c-discovery) mechanism. 

However, if the device does not have a Wireless NIC or a Leader is not detected, a secondary mechanism is used to connect the agent to the Cloud Agent. This connection is done by joining to the mF2C [VPN](https://github.com/mF2C/vpn#establishing-credentials-for-authentication) using the mF2C user credentials.

Both mechanisms are automatically triggered at the agent installation, except for the Cloud Agent.

### Manual topology

Additionally, the mF2C agent also allow to introduce an static topology, by specifying the IPs in each agent.

To create the static topology, in each device modify the `docker-compose.yml` file as follows:

- Inside the file, at the `policies` service definition, add two environment variables:
    ```yaml
    - "leaderIP=192.168.4.44"
    - "deviceIP=192.168.4.4"
    ``` 
    - Replace both IPs with the Leader IP and the device own IP for the Agent. The Leader will automatically connect to the specified Cloud IP at the installation (if VPN is available).

Static variables will only be active if `Discovery` has failed or Leader is not detected. If static variables are not set, VPN is used.

Be careful, IPs must be numerical and valid. If a wrong IP is specified, the topology may fail as well.

## Troubleshooting

- **Unhealthy components**: Some components may be unhealthy due to issues during the installation, bad configuration, or other issues. This can happen at any time and provides an easy mechanism to detect uncontrolled behaviours. Please check the documentation for the affected component to see possible causes and solutions.
    - To check the healthcheck output from a specific component run this command:
    ```bash
    docker inspect <container_name> | jq -e ".[0].State.Health"
    ```
    *replace `<container_name>` with the container name or ID of the desired component (e.g. `mf2c_policies_1`).*

- **Uninstall failure**: Sometimes, docker-compose deprovision fails due to containers attached to the mf2c docker network that are not stopped automatically.
    - run `./install.sh -s`, `docker-compose -p mf2c ps`, or `docker ps` and for each container displayed, run `docker stop <id>`, where `<id>` is the container ID.
    - When no container is displayed, try again to uninstall the agent.
    - Disregard the warning or error message regarding the WiFi detach if the installation is not successful.
 
- **Docker non-privileged**: If the current unix user is not in the `docker` group, the `ERROR: Couldn't connect to Docker daemon at http+docker://localhost - is it running?` message will appear on installing the agent.
    - run `sudo usermod -aG docker your-user` and replace `your-user` with your unix user. More info [here](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-convenience-script).
    - reboot the system to apply changes and try to install again.
    - another way is to execute the `install.sh` or `docker-compose` with **root** privileges.
    
- **Validation email not received**: Some email servers filter the validation email as spam or even block the message.
    - normally it takes from 1 to 3 minutes to receive the email.
    - `Gmail` domain has been tested and works most of the time.