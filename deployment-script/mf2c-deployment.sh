#!/bin/bash
#Credits: https://github.com/fgg89/docker-ap/blob/master/docker_ap
#Find inet name
WIFI_DEV=$(iw dev | awk '$1=="Interface"{print $2}')
 # Check that the given interface is not used by the host as the default route
 if [[ $(ip r | grep default | cut -d " " -f5) == "$WIFI_DEV" ]]
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

#find corresponding phy name
PHY=$(cat /sys/class/net/"$WIFI_DEV"/phy80211/name)
#Deploy compose
docker-compose up &
#give it some time to spin up the containers
sleep 20
#Bind inet to discovery
DOCKER_NAME="demo_discovery_1"

pid=$(docker inspect -f '{{.State.Pid}}' $DOCKER_NAME)
# Assign phy wireless interface to the container 
mkdir -p /var/run/netns
ln -s /proc/"$pid"/ns/net /var/run/netns/"$pid"
iw phy "$PHY" set netns "$pid"
#Bring the wireless interface up
ifconfig "$WIFI_DEV" up
