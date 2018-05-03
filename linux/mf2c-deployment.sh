#!/bin/bash -e
# Credits: https://github.com/fgg89/docker-ap/blob/master/docker_ap

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
    image: mf2c/service-manager
    depends_on:
      - cimi
    expose:
      - "46200"
  discovery:
    image: mf2c/discovery:latest
    depends_on:
      - cimi
    expose: 
      - 46040
    cap_add:
      - NET_ADMIN
  policies:
    image: mf2c/policies:latest
    depends_on:
      - discovery
    container_name: policies
    expose:
      - 46050
      - 46051
      - 46052
  identification:
    image: mf2c/identification
    volumes:
      - mydata:/data
    expose:
      - 46060

volumes:
  mydata: {}

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
  echo "WARN: Shutting down this mF2C agent..."
  docker-compose -p mf2c down -v || echo "ERR: failed to deprovision docker-compose" 
  rm .env || echo "ERR: .env not found"
  rm docker-compose.yml || echo "ERR: compose file not found"
  echo "INFO: Shutdown finished"
  exit 1
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
    exit 1
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
cat > .env <<EOF
IDKey=
MF2C=True
WIFI_DEV=
JAVA_OPTS=
isLeader=$IS_LEADER
PHY=$PHY
EOF

progress "40" "Deploying docker-compose services"

write_compose_file
#Deploy compose
docker-compose up &

progress "70" "Waiting for services to be up and running"

#give it some time to spin up the containers
sleep 20

progress "90" "Binding wireless interface with discovery container"

#Bind inet to discovery
DOCKER_NAME_DISCOVERY="demo_discovery_1"
pid=$(docker inspect -f '{{.State.Pid}}' $DOCKER_NAME_DISCOVERY)
# Assign phy wireless interface to the container 
mkdir -p /var/run/netns
ln -s /proc/"$pid"/ns/net /var/run/netns/"$pid"
iw phy "$PHY" set netns "$pid"
#Bring the wireless interface up
ifconfig "$WIFI_DEV" up

progress "100" "Installation complete!"

