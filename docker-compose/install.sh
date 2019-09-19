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
[ -f docker-compose.yml ] && git pull

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

([ ! -f docker-compose.yml ] && cp mF2C/docker-compose/docker-compose.yml .) || log "OK" "docker-compose found!"

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
