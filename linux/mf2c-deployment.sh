#!/bin/bash -e
# Credits: https://github.com/fgg89/docker-ap/blob/master/docker_ap

function cleanup {
    echo "WARN: Shutting down this mF2C agent..."
    docker-compose -p mf2c down -v || echo "ERR: failed to deprovision docker-compose" 
    rm .env || echo "ERR: .env not found"
    rm docker-compose.yml || echo "ERR: compose file not found"
    rm -rf mF2C || echo "ERR: cloned mF2C repository not found"
    rm *.cfg *.conf || echo "ERR: configuration files not found"
    echo "INFO: Shutdown finished"
    exit 1
}
trap cleanup ERR

PROJECT=mf2c

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

write_compose_file() {
    cat > docker-compose.yml <<EOF
version: '3'
services:
  proxy:
    image: traefik
    restart: unless-stopped
    command: --web --docker --docker.exposedByDefault=false --loglevel=info
    volumes:
     - /var/run/docker.sock:/var/run/docker.sock:ro
     - ./traefik/traefik.toml:/traefik.toml
    ports:
     - "80:80"
     - "443:443"
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:5.5.0
    restart: unless-stopped
    environment:
     - cluster.name=elasticsearch
     - xpack.security.enabled=false
     - discovery.type=single-node
     - "ES_JAVA_OPTS=-Xms2048m -Xmx2048m"
  cimi:
    image: mf2c/cimi-server:latest
    expose:
     - "8201"
    restart: unless-stopped
    labels:
     - "traefik.enable=true"
     - "traefik.backend=cimi"
     - "traefik.frontend.rule=PathPrefix:/,/"
  COMPSs:
    image: mf2c/compss-mf2c:1.0
    expose: 
     - 8080
    restart: unless-stopped
  service-manager:
    image: mf2c/service-manager:latest
    restart: unless-stopped
    depends_on:
      - cimi
    expose:
      - 46200
    ports:
      - 46200:46200
  discovery:
    image: mf2c/discovery:latest
    depends_on:
      - cimi
    networks:
      - host
    expose: 
      - 46040
    cap_add:
      - NET_ADMIN
  policies:
    image: mf2c/policies:latest
    depends_on:
      - discovery
    # container_name: policies
    ports:
      - "46050"
      - "46051:46051"
      - "46052:46052"
  cau-client:
    image: mf2c/cau-client:latest
    depends_on:
#   assuming cau and leader cau are bootstrapped elsewhere
      - policies
    # container_name: cau-client
    expose:
      - 46065
#   please provide ip:port params for CAU and leader CAU
    environment:
      - CAU_URL=127.0.0.1:46400
      - LCAU_URL=127.0.0.1:46410
  identification:
    image: mf2c/identification:latest
    volumes:
      - mydata:/data
    expose:
      - 46060
  user-management:
    image: mf2c/user-management:latest
    expose:
      - "46300"
    environment:
      - CIMI_URL=
  lifecycle:
    image: mf2c/lifecycle
    expose:
      - "46000"
    ports:
      - "46000:46000"
    environment:
      - CIMI_URL=
      - STANDALONE_MODE=False
      - HOST_IP=
      - WORKING_DIR_VOLUME=/tmp/compose_files
    volumes:
      - /tmp/compose_files:/tmp/compose_files
      - /var/run/docker.sock:/var/run/docker.sock  
  resouce-categorization:
    image: mf2c/resource-categorization:latest
    depends_on:
      - cimi
    expose:
      - 46070
    privileged: true
  snaptemp:
    image: mf2c/snaptemp:latest
    command: sh /download.sh
    depends_on:
      - snap
  influxdb:
    image: influxdb
    volumes: 
      - influx:/var/lib/influxdb
    environment:
      - INFLUXDB_DB=snap
      - INFLUXDB_USER=snap
      - INFLUXDB_USER_PASSWORD=snap
      - INFLUXDB_ADMIN_USER=admin
      - INFLUXDB_ADMIN_USER_PASSWORD=admin
  snap:
    image: intelsdi/snap:precise
    ports:
      - "8181:8181"
    volumes: ['/proc:/proc_host', '/sys/fs/cgroup:/sys/fs/cgroup', '/var/run/docker.sock:/var/run/docker.sock']
    depends_on:
      - influxdb
    environment:
      - SNAP_VERSION=2.0.0
      - SNAP_LOG_LEVEL=2
  influxdb-analytics:
    image: influxdb:latest
    environment:
      - ADMIN_USER=analytics_engine
      - INFLUX_INIT_PWD=analytics_engine
      - PRE_CREATE_DB=analytics_engine_development
    volumes:
      # Data persistency
      - influx-analytics:/var/lib/influxdb
  analytics_engine:
    image: mf2c/analytics-engine:latest
    expose:
      - "46020"
    depends_on:
      - influxdb-analytics
    volumes:
      - ./analytics_engine.conf:/analytics_engine/analytics_engine.conf
  neo4j:
    image: neo4j:2.3.12
    volumes:
    - neo4j:/data
    ports:
    - "7475:7474" # expose the port for the console ui
    environment:
    - NEO4J_AUTH=neo4j/password # neo4j requires change from default password, should reflect landscape.cfg
  landscaper:
    image: mf2c/landscaper:latest
    volumes:
    - landscaper:/landscaper/data
    - ./landscaper.cfg:/landscaper/landscaper.cfg
    depends_on:
      - "neo4j"
    environment:
      - OS_TENANT_NAME=
      - OS_PROJECT_NAME=
      - OS_TENANT_ID=
      - OS_USERNAME=
      - OS_PASSWORD=
      - OS_AUTH_URL=
    command: ["/start.sh", "http://neo4j:7474"]
  web:
    image: mf2c/landscaper-api:latest
    volumes:
      - ./landscaper.cfg:/landscaper/landscaper.cfg
    ports:
      - "9001:9001"
    depends_on:
      - neo4j
      - landscaper

volumes:
  mydata: {}
  influx: {}
  influx-analytics: {}
  neo4j: {}
  landscaper: {}
EOF
}

usage='Usage:
'$0' [OPTIONS]

OPTIONS:
\n --shutdown
\t Shutdown and delete the running mF2C deployment
\n --isLeader
\t Installs the mF2C system as a leader. This option is ignored when used together with --shutdown
'

IS_LEADER=False
while [ "$1" != "" ]; do
  case $1 in
    --shutdown )          DELETE_MODE=True;
    ;;
    --isLeader )          IS_LEADER=True;
    ;;
    -h )        echo -e "${usage}"
    exit 1
    ;;
    * )         echo -e "Invalid option $1 \n\n${usage}"
    exit 1
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
    PHY=$(cat /sys/class/net/"$WIFI_DEV"/phy80211/name)
else
    echo "ERR: the mF2C system is not compatible with your OS: $machine. Exit..."
    exit 1
fi

progress "10" "Cloning mF2C"

git clone https://github.com/mF2C/mF2C.git

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

progress "25" "Setup environment"

# Write env file to be used by docker-compose
cp mF2C/docker-compose/.env .env || cat > .env <<EOF
IDKey=
MF2C=True
WIFI_DEV=
JAVA_OPTS=
isLeader=$IS_LEADER
PHY=$PHY
EOF

progress "40" "Deploying docker-compose services"

cp mF2C/docker-compose/docker-compose.yml . ||  write_compose_file

# Copy configuration files
cp mF2C/docker-compose/*.c* .

#Deploy compose
docker-compose -p $PROJECT up -d

progress "70" "Waiting for discovery to be up and running"

#Monitor whether the discovery container has been created 
DOCKER_NAME_DISCOVERY="${PROJECT}_discovery_1"
while true
do
  if [[ $(docker ps -f "name=$DOCKER_NAME_DISCOVERY" --format '{{.Names}}') == $DOCKER_NAME_DISCOVERY ]] 
  then break
  fi
done

progress "90" "Binding wireless interface with discovery container"

#Bind inet to discovery

pid=$(docker inspect -f '{{.State.Pid}}' $DOCKER_NAME_DISCOVERY)
# Assign phy wireless interface to the container 
if [[ "$machine" != "Mac" ]]
then
  mkdir -p /var/run/netns
  ln -s /proc/"$pid"/ns/net /var/run/netns/"$pid"
  iw phy "$PHY" set netns "$pid"
  #Bring the wireless interface up
  docker exec -d "$DOCKER_NAME_DISCOVERY" ifconfig "$WIFI_DEV" up
fi

progress "100" "Installation complete!"

