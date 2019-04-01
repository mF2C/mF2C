#!/bin/sh
set -e

CLOUD_URL="https://dashboard.mf2c-project.eu"

display_usage() {
  echo
  echo "Usage: $0"
  echo
  echo " -h, --help                              Display usage instructions"
  echo " --ovpn=<base64 ovpn client conf>        Use VPN instead of Wireless discovery"
  echo
}


while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            display_usage
            exit
            ;;
        --vpn)
            OVPN=$VALUE
            ;;
        --cloud-agent)
            CLOUD_URL=$VALUE
            ;;
        --user)
            USER=$VALUE
            ;;
        --password)
            PASSWORD=$VALUE
            ;;
        *)
            echo "Unknown argument ${1}"
            display_usage
            exit 1
            ;;
    esac
    shift
done

API="${CLOUD_URL}/api"

docker run -rm -d --device=/dev/net/tun --cap-add=NET_ADMIN --net host -e OVPN=$OVPN \
           --name cris mjenz/rpi-openvpn bash -c 'bash -c echo $OVPN | base64 -d > /tmp/client1.ovpn; openvpn /tmp/client1.ovpn'


VPN_IP=`docker run --rm --net host mjenz/rpi-openvpn ifconfig tun0 | grep 'inet addr:' | cut -d: -f2| cut -d' ' -f1`

if [ -z $USER ] || [ -z $PASSWORD ]
then
    device='{
            "deviceID": "placeholder",
            "isLeader": true,
            "os": "raspbian",
            "arch": "arm",
            "cpuManufacturer": "nan",
            "physicalCores": 1,
            "logicalCores": 1,
            "cpuClockSpeed": "nan",
            "memory": 512.0,
            "storage": 16.0,
            "powerPlugged": true,
            "agentType": "micro",
            "actuatorInfo": "nan",
            "networkingStandards": "nan",
            "ethernetAddress": "'$VPN_IP'",
            "wifiAddress": "'$VPN_IP'"
            }'
fi