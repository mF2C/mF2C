#!/bin/bash -e
# Credits: https://github.com/fgg89/docker-ap/blob/master/docker_ap

function log {
    text="$2"
    if [[ $1 == "OK" ]]
    then
        printf '\e[0;33m %-15s \e[32m SUCCESS:\e[0m %s \n' [mF2CInstaller] "$text"
    elif [[ $1 == "IF" ]]
    then
        printf '\e[0;33m %-15s \e[34m INFO:\e[0m %s \n' [mF2CInstaller] "$text"
    elif [[ $1 == "WR" ]]
    then
        printf '\e[0;33m %-15s \e[93m WARNING:\e[0m %s \n' [mF2CInstaller] "$text"
    else
        printf '\e[0;33m %-15s \e[0;31m FAILED:\e[0m %s \n' [mF2CInstaller] "$text"
    fi
}

function cleanup {
    log "IF" "Shutting down this mF2C agent..."
    docker-compose -p mf2c down -v || log "ER" "Failed to deprovision docker-compose"
    rm -f .env
    [ -d mF2C ] && rm -f docker-compose.yml
    [ -d mF2C ] && rm -rf prop
    [ -d mF2C ] && rm -rf traefik
    [ -d mF2C ] && rm -rf ls_log
    [ -d mF2C ] && rm -f *.cfg *.conf
    [ -d mF2C ] && rm -rf mF2C
    log "IF" "Shutdown finished"
    exit 1
}
trap cleanup ERR

PROJECT=mf2c
DOCKER_NAME_DISCOVERY="discovery"
IS_LEADER=False

progress() {
    # $1 is the current percentage, from 0 to 100
    # $2 onwards, is the text to appear in front of the progress bar
    char=""
    for i in $(seq 1 $(($1/2)))
    do
        char=$char'#'
    done
    printf "\r\e[K|%-*s| %3d%% %s\n" "50" "$char" "$1" "${@:2}";
}

write_compose_file() {  # TODO: update this with latest image tags + correct environment variables
    cat > docker-compose.yml <<EOF
version: '3.4'
services:
  ####################### Proxy  ######################
  proxy:
    image: traefik:1.7.14
    restart: unless-stopped
    command: --web --docker --docker.exposedByDefault=false --loglevel=info
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik/traefik.toml:/traefik.toml
      - ./traefik/cert:/ssl:ro
    ports:
      - "80:80"
      - "443:443"
  ######################################################

  ######################## CIMI  #######################
  cimi:
    image: mf2c/cimi-server:2.27
    restart: on-failure
    depends_on:
      - logicmodule1
      - dcproxy
    environment:
      - DC_HOST=dcproxy
      - DC_PORT=6472
      - EPHEMERAL_DB_BINDING_NS=com.sixsq.slipstream.db.dataclay.loader
      - PERSISTENT_DB_BINDING_NS=com.sixsq.slipstream.db.dataclay.loader
    expose:
      - "8201"
    labels:
      - "traefik.enable=true"
      - "traefik.backend=cimi"
      - "traefik.frontend.rule=PathPrefix:/api"
    volumes:
      - ringcontainer:/opt/slipstream/ring-container
      - ringcontainerexample:/opt/slipstream/ring-example
    healthcheck:
      start_period: 30s
      retries: 5
      test: ["CMD", "wget", "--spider", "http://localhost:8201/api/cloud-entry-point"]

  rc:
    image: sixsq/ring-container:3.52
    expose:
      - "5000"
    volumes:
      - ringcontainer:/opt/slipstream/ring-container
      - ringcontainerexample:/opt/slipstream/ring-example
    command: sh

  #################### Dataclay  #######################
  dcproxy:
    image: mf2c/dataclay-proxy:2.23
    depends_on:
      - logicmodule1
      - ds1java1
    expose:
      - "6472"

  logicmodule1:
    image: mf2c/dataclay-logicmodule:2.23
    ports:
      - "1034:1034"
    environment:
      - DATACLAY_ADMIN_USER=admin
      - DATACLAY_ADMIN_PASSWORD=admin
      - LOGICMODULE_PORT_TCP=1034
      - LOGICMODULE_HOST=logicmodule1
    volumes:
      - ./prop/global.properties:/usr/src/dataclay/cfgfiles/global.properties:ro
      - ./prop/log4j2.xml:/usr/src/dataclay/log4j2.xml:ro

  ds1java1:
    image: mf2c/dataclay-dsjava:2.23
    depends_on:
      - logicmodule1
    environment:
      - DATASERVICE_NAME=DS1
      - DATASERVICE_HOST=ds1java1
      - DATASERVICE_JAVA_PORT_TCP=2127
      - LOGICMODULE_PORT_TCP=1034
      - LOGICMODULE_HOST=logicmodule1
    volumes:
      - ./prop/global.properties:/usr/src/dataclay/cfgfiles/global.properties:ro
      - ./prop/log4j2.xml:/usr/src/dataclay/log4j2.xml:ro
  #####################################################

  ################### Event Manager ###################
  event-manager:
    image: mf2c/cimi-server-events:1.0
    depends_on:
      - cimi
    expose:
      - 8000
    restart: unless-stopped
  ######################################################

  ################## Service Manager ###################
  service-manager:
    image: mf2c/service-manager:1.8.3
    restart: unless-stopped
    depends_on:
      - cimi
    expose:
      - 46200
    labels:
      - "traefik.enable=true"
      - "traefik.frontend.rule=PathPrefixStrip:/sm"
      - "traefik.port=46200"
    environment:
      - JAVA_OPTS=-Xms32m -Xmx256m
    healthcheck:
      start_period: 30s
      retries: 5
      test: ["CMD", "wget", "--spider", "http://localhost:46200/api"]
  ######################################################

  ########## Lifecycle Manager + User Manager ##########
  lm-um:
    image: mf2c/lifecycle-usermngt:1.2.6
    restart: on-failure
    depends_on:
      - cimi
      - resource-categorization
      - analytics-engine
      - landscaper
    expose:
      - "46300"
      - "46000"
    ports:
      - "46000:46000"
      - "46300:46300"
    environment:
      - HOST_IP=192.168.252.41
      - WORKING_DIR_VOLUME=/tmp/mf2c/compose_files
      - UM_WORKING_DIR_VOLUME=/tmp/mf2c/um/
      - LM_WORKING_DIR_VOLUME=/tmp/mf2c/lm/
      - SERVICE_CONSUMER=true
      - RESOURCE_CONTRIBUTOR=true
      - MAX_APPS=3
    volumes:
      - /tmp/mf2c/compose_files:/tmp/mf2c/compose_files
      - /tmp/mf2c/um:/tmp/mf2c/um
      - /tmp/mf2c/lm:/tmp/mf2c/lm
      - /var/run/docker.sock:/var/run/docker.sock
  ######################################################

  #################### SLA Manager #####################
  slalite:
    image: mf2c/sla-management:0.8.1
    restart: on-failure
    expose:
      - "46030"
    healthcheck:
      start_period: 30s
      retries: 5
      test: ["CMD", "wget", "--spider", "http://localhost:46030"]
  ######################################################

  ############ Resource Manager + Security #############
  policies:
     image: mf2c/policies:2.0.5
     restart: on-failure
     depends_on:
       - cimi
     ports:
       - "46050"
     labels:
       - "traefik.enable=true"
       - "traefik.frontend.rule=PathPrefix:/rm"
       - "traefik.port=46050"
     environment:
       - "DEBUG=True"
       - "MF2C=True"
       - "isLeader=\${isLeader}"
       - "WIFI_DEV_FLAG=\${WIFI_DEV_FLAG}"

  discovery:
     image: mf2c/discovery:1.4
     restart: on-failure
     depends_on:
       - cimi
     network_mode: "host"
     ports:
     - "46040:46040"
     cap_add:
       - NET_ADMIN

  identification:
     image: mf2c/identification:v2
     restart: on-failure
     volumes:
       - mydata:/data
     expose:
       - 46060
     environment:
       - mF2C_User=\${usr}
       - mF2C_Pass=\${pwd}

  cau-client:
     image: mf2c/cau-client-it2:v2.1
     depends_on:
       - policies
     volumes:
       - pkidata:/pkidata
     expose:
       - 46065
     #using the cloud cau for the moment
     environment:
       - CCAU_URL=213.205.14.13:55443
       - CAU_URL=213.205.14.13:55443

  aclib:
     image: mf2c/aclib:v1.0
     depends_on:
       - cau-client
     volumes:
       - pkidata:/pkidata
     expose:
       - 46080
     environment:
       - ACLIB_PORT=46080
       - CAUCLIENT_PORT=46065

  resource-categorization:
     image: mf2c/resource-categorization:latest-V2.0.20
     hostname: IRILD039
     restart: on-failure
     depends_on:
       - policies
     expose:
       - 46070
     privileged: true
     volumes:
       - /var/run/docker.sock:/var/run/docker.sock

  ##### Analytics Engine + Recomender + Landscaper #####
  analytics-engine:
    image: mf2c/analytics-engine:0.5.5
    expose:
      - "46020"
    ports:
      - "46020:46020"
    depends_on:
      - influxdb
    volumes:
      - ./analytics_engine.conf:/root/analytics_engine/analytics_engine.conf
    labels:
      - "traefik.enable=true"
      - "traefik.port=46020"
      - "traefik.frontend.rule=PathPrefixStrip:/analytics-engine"

  landscaper:
    image: mf2c/landscaper:0.6.11
    volumes:
    - landscaper:/landscaper/data
    - ./landscaper.cfg:/landscaper/landscaper.cfg
    - ./ls_log:/landscaper/logs
    - /var/run/docker.sock:/var/run/docker.sock
    depends_on: ["cimi", "neo4j", "proxy"]
    environment:
      - OS_TENANT_NAME=
      - OS_PROJECT_NAME=
      - OS_TENANT_ID=
      - OS_USERNAME=
      - OS_PASSWORD=
      - OS_AUTH_URL=
    command: ["./start.sh", "http://neo4j:7474"]

  telem_start:
    image: mf2c/telem_start:0.1
    command: sh /download.sh
    environment:
      - HOSTNAME
    depends_on:
      - snap

  influxdb:
    image: influxdb
    expose:
      - "8086"
    ports:
      - "8086:8086"
    volumes:
      - influx:/var/lib/influxdb
    environment:
      - INFLUXDB_DB=snap
      - INFLUXDB_USER=snap
      - INFLUXDB_USER_PASSWORD=snap
      - INFLUXDB_ADMIN_USER=admin
      - INFLUXDB_ADMIN_USER_PASSWORD=admin
      - INFLUXDB_HTTP_LOG_ENABLED=false
  snap:
    image: intelsdi/snap:xenial
    hostname: snap
    ports:
      - "8181:8181"
    volumes: ['/proc:/proc_host', '/sys/fs/cgroup:/sys/fs/cgroup', '/var/run/docker.sock:/var/run/docker.sock']
    depends_on:
      - influxdb
    environment:
      - SNAP_VERSION=2.0.0
      - SNAP_LOG_LEVEL=2

  neo4j:
    image: neo4j:2.3.12
    privileged: true
    volumes:
      - neo4j:/data
    ports:
      - "7475:7474" # expose the port for the console ui
    environment:
      - NEO4J_AUTH=neo4j/password # neo4j requires change from default password, should reflect landscape.cfg

  web:
    image: mf2c/landscaper:0.6.5
    environment:
    - PYTHONPATH=/landscaper
    volumes:
      - ./landscaper.cfg:/landscaper/landscaper.cfg
      - ./ls_log:/collector_log
    ports:
      - "9001:9001"
    depends_on:
      - neo4j
      - landscaper
    command: ["/usr/local/bin/gunicorn", "-b", "0.0.0.0:9001", "-w", "2", "--chdir", "/landscaper/landscaper/web", "application:APP"]

  vpnclient:
    image: mf2c/vpnclient:1.1.0
    depends_on:
      - cau-client
    network_mode: "host"
    extra_hosts:
      - "vpnserver:213.205.14.13"
    environment:
      - VPN_DAEMON=FALSE
    cap_add:
      - NET_ADMIN
    volumes:
      - pkidata:/pkidata

  resource-bootstrap:
    image: mf2c/resource-bootstrap:1.0.0
    restart: "no"
    environment:
      - CIMI_HOST=proxy
      - CIMI_PORT=80
    depends_on:
      - proxy
      - cimi

######################################################

volumes:
  mydata: {}
  influx: {}
  influx-analytics: {}
  neo4j: {}
  landscaper: {}
  ringcontainer: {}
  ringcontainerexample: {}
  pkidata: {}

EOF
}

usage='Usage:
'$0' [OPTIONS]

OPTIONS:
\n -S --shutdown
\t Shutdown and delete the running mF2C deployment
\n -s --status
\t Display the actual mF2C docker container status
\n -L --isLeader
\t Installs the mF2C system as a leader. This option is ignored when used together with --shutdown
'

while [ "$1" != "" ]; do
  case $1 in
    --shutdown | -S )          DELETE_MODE=True;
    ;;
    --isLeader | -L )          IS_LEADER=True;
    ;;
    -h )        echo -e "${usage}"
    exit 1
    ;;
    --status | -s )  docker-compose -p ${PROJECT} ps
    exit 1
    ;;
    * )         echo -e "Invalid option $1 \n\n${usage}"
    exit 0
  esac
  shift
done

if [[ ! -z $DELETE_MODE ]]
then
    cleanup
fi

echo '''
==============================================================
|                                                            |
|                     88888888888  ad888888b,    ,ad8888ba,  |
|                     88          d8"     "88   d8"     `"8b |
|                     88                  a8P  d8            |
| 88,dPYba,,adPYba,   88aaaaa          ,d8P"   88            |
| 88P    "88"    "8a  88"""""        a8P"      88            |
| 88      88      88  88           a8P         Y8,           |
| 88      88      88  88          d8"           Y8a.    .a8P |
| 88      88      88  88          88888888888    `"Y8888Y"   |
|                                                            |
==============================================================

'''

progress "0" "Preparing to install mF2C"

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

progress "5" "Checking OS compatibility"

#Find inet name
if [[ "$machine" == "Mac" ]]
then
    WIFI_DEV=$(networksetup -listallhardwareports | grep -1 "Wi-Fi" | awk '$1=="Device:"{print $2}')
    IN_USE=$(route -n get default | awk '$1=="interface:"{print $2}')
    echo "ERR: compatibility for Mac is not fully supported yet. Exit..."
    read -p "Do you wish to continue? [y/n]" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
elif [[ "$machine" == "Linux" ]]
then
    WIFI_DEV=$(iw dev | awk '$1=="Interface"{print $2}')
    IN_USE=$(ip r | grep default | cut -d " " -f5)
    #find corresponding phy name
    if [[ $WIFI_DEV != "" ]]; then
        PHY=$(cat /sys/class/net/"$WIFI_DEV"/phy80211/name)
    else
        if [[ $(docker-compose -p $PROJECT ps 2>/dev/null | wc -l) -gt 2  ]]; then
            log "WR" "Agent currently running. Interface cannot be attached to the mF2C agent. Shutdown required."
        else
            log "ER" "No WiFi interface dettected."
        fi
        exit 2
    fi

    log "IF" "WIFI_DEV=${WIFI_DEV}, IN_USE=${IN_USE}, PHY=${PHY}"
else
    echo "ERR: the mF2C system is not compatible with your OS: $machine. Exit..."
    exit 1
fi

progress "10" "Cloning mF2C"

[ ! -f docker-compose.yml ] && git clone https://github.com/mF2C/mF2C.git

progress "15" "Checking networking conflicts"

# Check that the given interface is not used by the host as the default route
if [[ "$IN_USE" == "$WIFI_DEV" ]]
then
    echo -e "${BLUE}[INFO]${NC} The selected interface is configured as the default route, if you use it you will lose internet connectivity"
    while true;
    do
        read -p "Do you wish to continue? [y/n]" yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
fi

progress "25" "User credentials"
read -p "Enter your mF2C Username: " MF2C_USER
read -s -p "Enter your mF2C Password: " MF2C_PASS
echo
#MF2C_USER="test1234"
#MF2C_PASS="12345678"

progress "25" "Setup environment"

# Write env file to be used by docker-compose
cp mF2C/docker-compose/.env .env 2>/dev/null || cat > .env <<EOF
isLeader=${IS_LEADER}
PHY=${PHY}
WIFI_DEV_FLAG=${WIFI_DEV}
usr=${MF2C_USER}
pwd=${MF2C_PASS}
EOF

progress "30" "Deploying docker-compose services"

([ ! -f docker-compose.yml ] && cp mF2C/docker-compose/docker-compose.yml .) || ([ ! -f docker-compose.yml ] && write_compose_file) || log "OK" "docker-compose found!"

# Copy configuration files
[ -d "mF2C/docker-compose" ] && cp mF2C/docker-compose/*.c* .

# Copy directories
[ -d "mF2C/docker-compose/prop" ] && cp -r mF2C/docker-compose/prop/ .
[ -d "mF2C/docker-compose/traefik" ] && cp -r mF2C/docker-compose/traefik/ .

progress "35" "Checking for agents running on the system"
if [[ $(docker-compose -p $PROJECT ps | wc -l) -gt 2 ]]; then
    log "WR" "Agent running dettected."
    while true;
    do
        read -p "Do you wish to stop the current agent and continue? [y/n]" yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
    docker-compose -p $PROJECT down -v || exit 0
fi

progress "40" "Pulling mF2C agent modules"
docker-compose pull

progress "50" "Deploy mF2C agent"
docker-compose -p $PROJECT up -d

progress "70" "Waiting for discovery to be up and running"

#Monitor whether the discovery container has been created and get container name
while true
do
  if [[ $(docker ps -f "name=$DOCKER_NAME_DISCOVERY" --format '{{.Names}}' | wc -l) -gt 0 ]]
  then
    container_name=$(docker ps -f "name=$DOCKER_NAME_DISCOVERY" --format '{{.Names}}')
    break
  fi
done

progress "90" "Binding wireless interface with discovery container"

#Bind inet to discovery

pid=$(docker inspect -f '{{.State.Pid}}' $container_name)
# Assign phy wireless interface to the container
if [[ "$machine" != "Mac" ]]
then
    #Bring the wireless interface up
    ip addr flush dev "$WIFI_DEV"

    docker exec -d "$container_name" ifconfig "${WIFI_DEV}" up

    if [[ "$IS_LEADER" == "True" ]]; then
        #Define the characteristics of the network that will be used by the leader
        SUBNET="192.168.7"
        IP_AP="192.168.7.1"
        NETMASK="/24"
        ### Assign an IP to the wifi interface
        echo "Configuring interface with IP address"
        ip addr flush dev "${WIFI_DEV}"
        ip link set "${WIFI_DEV}" down
        ip link set "${WIFI_DEV}" up
        ip addr add "$IP_AP$NETMASK" dev "${WIFI_DEV}"

        ### iptables rules for NAT
        echo "Adding natting rule to iptables (container)"
        iptables -t nat -A POSTROUTING -s $SUBNET.0$NETMASK ! -d $SUBNET.0$NETMASK -j MASQUERADE

        ### Enable IP forwarding
        echo "Enabling IP forwarding (container)"
        echo 1 > /proc/sys/net/ipv4/ip_forward
    fi
fi

progress "100" "Installation complete!"
