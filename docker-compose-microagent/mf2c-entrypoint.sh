#!/bin/sh
set -e
set -x

CLOUD_URL="https://dashboard.mf2c-project.eu"

display_usage() {
  echo
  echo "Usage: $0"
  echo
  echo " -h, --help                              Display usage instructions"
  echo " --ovpn=<base64 ovpn client conf>        Use VPN instead of Wireless discovery"
  echo " --cloud-agent=<url>                     Cloud agent endpoint. Default is ${CLOUD_URL}"
  echo " --user=<username>                       mF2C username"
  echo " --password=<password>                   mF2C password"
  echo
}


while [ "$1" != "" ]; do
    PARAM=`echo $1 | cut -d '=' -f 1`
    VALUE=`echo $1 | cut -d '=' -f 2-`
    case $PARAM in
        -h | --help)
            display_usage
            exit
            ;;
        --ovpn)
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

openvpn_container_id=`docker run --rm -d --device=/dev/net/tun --cap-add=NET_ADMIN --net host -e OVPN=$OVPN \
            mjenz/rpi-openvpn bash -c 'echo $OVPN | base64 -d > /tmp/client1.ovpn; openvpn /tmp/client1.ovpn'`

function cleanup {
    # re-start service
    docker rm -f $openvpn_container_id
}
trap cleanup EXIT

VPN_IP=`docker run --rm --net host mjenz/rpi-openvpn bash -c \
        'while ! ifconfig tun0 > /dev/null 2>&1; do sleep 1; done; ifconfig tun0' | grep 'inet addr:' | cut -d: -f2| cut -d' ' -f1`

logical_cores=`grep -c proc /proc/cpuinfo`
clock_speed=`lshw -c cpu | grep capacity | tail -1 | awk -F' ' '{print $2}'`
mem=`free -m | grep Mem  | awk -F' ' '{print $2}'`.0
storage=`df -h / | grep "/" | awk -F' ' '{print $2}' | tr -d 'G'`

device='{
        "deviceID": "placeholder",
        "isLeader": true,
        "os": "raspbian",
        "arch": "arm",
        "cpuManufacturer": "Broadcom",
        "physicalCores": 1,
        "logicalCores": '$logical_cores',
        "cpuClockSpeed": "'$clock_speed'",
        "memory": '$mem',
        "storage": '$storage',
        "powerPlugged": true,
        "agentType": "micro",
        "actuatorInfo": "nan",
        "networkingStandards": "nan",
        "ethernetAddress": "'$VPN_IP'",
        "wifiAddress": "'$VPN_IP'"
}'

headers=" -H content-type:application/json"
cookies=""

if [ ! -z $USER ] && [ ! -z $PASSWORD ]
then
    data='{
    "sessionTemplate": {
		"href": "session-template/internal",
		"username": "'$USER'",
		"password": "'$PASSWORD'"
	}
}'
    cookies=' -b cookies -c cookies '
    curl -XPOST -k $headers $cookies ${API}/session -d $data
else
    headers="${headers} -H 'slipstream-authn-info: internal ADMIN' "
fi

curl -XPOST -k $headers $cookies ${API}/device -d $device

docker run -p 46000:46000 mf2c/lifecycle:1.0.6-arm