#!/bin/bash -e
# mF2C Installation Script
# version: 1.6

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
    WIFI_DEV_RESULT=$(cat .env | grep "WIFI_DEV_FLAG" | cut -d'=' -f2)
    if [[ -f .env &&  ${WIFI_DEV_RESULT} != "" ]]; then
        sudo ip link set $(cat .env | grep "WIFI_DEV_FLAG" | cut -d'=' -f2) down 2>/dev/null
        log "OK" "${WIFI_DEV_RESULT} iface successfully set down."
    fi
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
IS_CLOUD=False

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

usage='Usage:
'$0' [OPTION]

OPTIONS:
[Only one option is allowed]
\n -S --shutdown
\t Shutdown and delete the running mF2C deployment
\n -s --status
\t Display the actual mF2C docker container status
\n -L --isLeader
\t Installs the mF2C system as a leader.
\n -C --isCloud
\t Installs the mF2C system as Cloud.
\n\t Only one option is allowed.
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
    --isCloud | -C )              IS_CLOUD=True;
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

if [[ ${IS_CLOUD} != "True" ]]; then
    if [[ ${MF2C_CLOUD_AGENT} == "" ]]; then
        MF2C_CLOUD_AGENT="dashboard.mf2c-project.eu"
        MF2C_CLOUD_AGENT="213.205.14.15"
        read -p "Enter the mF2C Cloud provider address (ENTER for default) [${MF2C_CLOUD_AGENT}]: " input_cloud
        if [[ "$input_cloud" == "" ]]; then
            log "IF" "Using default provider address: ${MF2C_CLOUD_AGENT}"
        else
            MF2C_CLOUD_AGENT=${input_cloud}
            log "IF" "Cloud provider address: ${MF2C_CLOUD_AGENT}"
        fi
    else
        log "IF" "mF2C Cloud provider ${MF2C_CLOUD_AGENT} detected as env variable"
    fi
    AGENT_TYPE="2"
else
    AGENT_TYPE="1"
fi

progress "5" "Checking OS compatibility"

if [[ "${IS_CLOUD}" != "True" ]]; then
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
        WIFI_DEV=$(/sbin/iw dev | awk '$1=="Interface"{print $2}')
        IN_USE=$(ip r | grep default | cut -d " " -f5)

        if [[ $WIFI_DEV == "" && ${IS_CLOUD} != "True" ]]; then
            log "IF" "WiFi interface not detected. VPN connection to cloud will be used."
        fi

        log "IF" "WIFI_DEV=${WIFI_DEV}, IN_USE=${IN_USE}"
    else
        echo "ERR: the mF2C system is not compatible with your OS: $machine. Exit..."
        exit 1
    fi
else
    log "IF" "Cloud Agent deployment does not configure any WiFi interface."
fi

progress "10" "Cloning mF2C"

[ ! -f docker-compose.yml ] && git clone https://github.com/mF2C/mF2C.git
[ -f docker-compose.yml ] && [ -d ../.git ] && git pull

progress "15" "Checking networking conflicts"

# Check that the given interface is not used by the host as the default route
if [[ "$IN_USE" == "$WIFI_DEV" && ${IS_CLOUD} != "True" ]]
then
    log "IF" "The selected interface is configured as the default route, if you use it you will lose internet connectivity"
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
if [[ "${IS_CLOUD}" == "True" ]]; then
    MF2C_USER="admincloud"
    MF2C_PASS=$(cat /proc/sys/kernel/random/uuid)
    log "IF" "Default MF2C User for Cloud Agent: ${MF2C_USER}"
    log "IF" "MF2C Generated password for Cloud Agent: ${MF2C_PASS}"
else
    read -p "Enter your mF2C Username: " MF2C_USER
    read -s -p "Enter your mF2C Password: " MF2C_PASS
    echo
fi

progress "25" "Setup environment"

# Load configuration form setup.json if exists
if [[ -f setup.json ]]; then
    DEVICE_ACTUATORS=$(cat setup.json | tr "\'" "\"" | jq -e ".Actuators")
    DEVICE_SENSORS=$(cat setup.json | tr "\'" "\"" | jq -e ".Sensors")
fi

# Write env file to be used by docker-compose
if [[ ! -f .env ]]; then
    cp mF2C/agent/.env .env 2>/dev/null || cat > .env <<EOF
isLeader=${IS_LEADER}
isCloud=${IS_CLOUD}
MF2C_CLOUD_AGENT=${MF2C_CLOUD_AGENT}
WIFI_DEV_FLAG=${WIFI_DEV}
usr=${MF2C_USER}
pwd=${MF2C_PASS}
agentType=${AGENT_TYPE}
targetDeviceActuator=${DEVICE_ACTUATORS}
targetDeviceSensor=${DEVICE_SENSORS}
EOF
    log "OK" "New .env file created"
else
    log "IF" "Using existing .env file in the directory"
fi

progress "30" "Deploying docker-compose services"

([ ! -f docker-compose.yml ] && cp mF2C/agent/docker-compose.yml .) || log "OK" "docker-compose found!"

# Copy configuration files
[ -d "mF2C/agent" ] && cp mF2C/agent/*.c* .

# Copy directories
[ -d "mF2C/agent/prop" ] && cp -r mF2C/agent/prop/ .
[ -d "mF2C/agent/traefik" ] && cp -r mF2C/agent/traefik/ .

progress "35" "Checking for agents running on the system"
if [[ $(docker-compose -p $PROJECT ps | wc -l) -gt 2 ]]; then
    log "WR" "Agent running detected."
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

pid=$(docker inspect -f '{{.State.Pid}}' $container_name)

if [[ ("$machine" != "Mac") && (${WIFI_DEV} != "") ]]
then
    #Bring the wireless interface up
    sudo ip addr flush dev "$WIFI_DEV"

    docker exec -d "$container_name" ifconfig "${WIFI_DEV}" up

    if [[ "$IS_LEADER" == "True" ]]; then
        #Define the characteristics of the network that will be used by the leader
        log "IF" "Configuring WiFi device as mF2C Leader"
        SUBNET="192.168.7"
        IP_AP="192.168.7.1"
        NETMASK="/24"
        ### Assign an IP to the wifi interface
        echo "Configuring interface with IP address"
        sudo ip addr flush dev "${WIFI_DEV}"
        sudo ip link set "${WIFI_DEV}" down
        sudo ip link set "${WIFI_DEV}" up
        sudo ip addr add "$IP_AP$NETMASK" dev "${WIFI_DEV}"

        ### iptables rules for NAT
        echo "Adding natting rule to iptables (container)"
        sudo iptables -t nat -A POSTROUTING -s $SUBNET.0$NETMASK ! -d $SUBNET.0$NETMASK -j MASQUERADE

        ### Enable IP forwarding
        echo "Enabling IP forwarding (container)"
        sudo su -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
    fi
fi

progress "100" "Installation complete!"
