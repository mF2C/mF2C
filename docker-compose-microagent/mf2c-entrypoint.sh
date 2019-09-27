#!/bin/sh

set -x

docker run -d --restart=on-failure \
        -e mF2C_User=${MF2C_USER} \
        -e mF2C_Pass=${MF2C_PWD} \
        --name mf2c_micro_identification \
        --label "PRODUCT=MF2C" \
        mf2c/identification:ARMlatest

docker run -d --restart=on-failure \
        -v pkidata:/pkidata \
        -e CCAU_URL=213.205.14.13:55443 \
        -e CAU_URL=213.205.14.13:55443 \
        --name mf2c_micro_cau-client \
        --label "PRODUCT=MF2C" \
        mf2c/cau-client-it2-arm


register_cmd='curl -X POST http://localhost:46060/api/v1/resource-management/identification/registerDevice/'
docker exec mf2c_micro_identification sh -c "${register_cmd}"
while [ $? -ne 0 ]
do
  sleep 1
  docker exec mf2c_micro_identification sh -c "${register_cmd}"
done

get_id='curl -X GET http://localhost:46060/api/v1/resource-management/identification/requestID'
while [ -z $deviceID ] || [[ "$deviceID" == "null" ]]
do
  deviceID=$(docker exec mf2c_micro_identification sh -c "${get_id}" | jq -r .deviceID)
  sleep 1
done

# variable coming from Nuvla
export detectedLeaderID=${LEADER_ID:-$deviceID}

docker exec mf2c_micro_cau-client sh -c "echo getpubkey=1233211234567 | nc localhost 46065"
while [ $? -ne 0 ]
do
  sleep 1
  docker exec mf2c_micro_cau-client sh -c "echo getpubkey=1233211234567 | nc localhost 46065"
done

cau_registration="echo detectedLeaderID=${detectedLeaderID},deviceID=${deviceID} | nc localhost 46065"
docker exec mf2c_micro_cau-client sh -c "${cau_registration}"

docker run -d --network="host" \
        --cap-add=NET_ADMIN \
        -v /var/run/docker.sock:/var/run/docker.sock \
        --name mf2c_micro_discovery \
        --label "PRODUCT=MF2C" \
        mf2c/discovery-microagent:latest

docker run -d --hostname=IRILD039 --privileged \
        -e LEADER_ENDPOINT="https://dashboard.mf2c-project.eu" \
        -v /var/run/docker.sock:/var/run/docker.sock \
        --name mf2c_micro_resource-categorization \
        --label "PRODUCT=MF2C" \
        mf2c/resource-categorization:latest-V2.0.20-arm

trigger_cat_payload='{
"deviceID":"'${deviceID}'",
"detectedLeaderID":"'${detectedLeaderID}'",
"isLeader":false
}'
trigger_cat="curl -X POST http://localhost:46070/api/v1/resource-management/categorization/start/ -H 'content-type:application/json' -d '${trigger_cat_payload}'"

docker exec mf2c_micro_resource-categorization apk add curl
docker exec mf2c_micro_resource-categorization sh -c "${trigger_cat}"
while [ $? -ne 0 ]
do
  sleep 1
  docker exec mf2c_micro_resource-categorization sh -c "${trigger_cat}"
done

#
#display_usage() {
#  echo
#  echo "Usage: $0"
#  echo
#  echo " -h, --help                              Display usage instructions"
#  echo " --ovpn=<base64 ovpn client conf>        Use VPN instead of Wireless discovery"
#  echo " --cloud-agent=<url>                     Cloud agent endpoint. Default is ${CLOUD_URL}"
#  echo " --user=<username>                       mF2C username"
#  echo " --password=<password>                   mF2C password"
#  echo
#}
#
#
#while [ "$1" != "" ]; do
#    PARAM=`echo $1 | cut -d '=' -f 1`
#    VALUE=`echo $1 | cut -d '=' -f 2-`
#    case $PARAM in
#        -h | --help)
#            display_usage
#            exit
#            ;;
#        --ovpn)
#            OVPN=$VALUE
#            ;;
#        --cloud-agent)
#            CLOUD_URL=$VALUE
#            ;;
#        --user)
#            USER=$VALUE
#            ;;
#        --password)
#            PASSWORD=$VALUE
#            ;;
#        *)
#            echo "Unknown argument ${1}"
#            display_usage
#            exit 1
#            ;;
#    esac
#    shift
#done
#
#API="${CLOUD_URL}/api"
#
#openvpn_container_id=`docker run --rm -d --device=/dev/net/tun --cap-add=NET_ADMIN --net host -e OVPN=$OVPN \
#            mjenz/rpi-openvpn bash -c 'echo $OVPN | base64 -d > /tmp/client1.ovpn; openvpn /tmp/client1.ovpn'`
#
#function cleanup {
#    # re-start service
#    docker rm -f $openvpn_container_id
#    exit 0
#}
#trap cleanup EXIT
#
#VPN_IP=`timeout -t 30 docker run --rm --net host mjenz/rpi-openvpn bash -c \
#        'while ! ifconfig tun0 > /dev/null 2>&1; do sleep 1; done; ifconfig tun0' | grep 'inet addr:' | cut -d: -f2| cut -d' ' -f1`
#
#logical_cores=`grep -c proc /proc/cpuinfo`
#clock_speed=`lshw -c cpu | grep capacity | tail -1 | awk -F' ' '{print $2}'`
#mem=`free -m | grep Mem  | awk -F' ' '{print $2}'`
#storage=`df -h / | grep "/" | awk -F' ' '{print $2}' | tr -d 'G'`
#
#device='{
#        "deviceID": "placeholder",
#        "isLeader": true,
#        "os": "raspbian",
#        "arch": "arm",
#        "cpuManufacturer": "Broadcom",
#        "physicalCores": 1,
#        "logicalCores": '$logical_cores',
#        "cpuClockSpeed": "'$clock_speed'",
#        "memory": '$mem'.0,
#        "storage": '$storage',
#        "powerPlugged": true,
#        "agentType": "micro",
#        "actuatorInfo": "nan",
#        "networkingStandards": "nan",
#        "ethernetAddress": "'$VPN_IP'",
#        "wifiAddress": "'$VPN_IP'"
#}'
#
#headers=" -H content-type:application/json"
#
#if [ ! -z $USER ] && [ ! -z $PASSWORD ]
#then
#    data='{
#    "sessionTemplate": {
#		"href": "session-template/internal",
#		"username": "'$USER'",
#		"password": "'$PASSWORD'"
#	}
#}'
#    cookies=' -b cookies -c cookies '
#    curl -XPOST -k $headers $cookies ${API}/session -d "${data}"
#    device_id=$(curl -XPOST -k ${headers} ${cookies} ${API}/device -d "${device}" | jq --raw-output '.["resource-id"]')
#else
#    device_id=$(curl -XPOST -k ${headers} -H "slipstream-authn-info: internal ADMIN" ${API}/device -d "${device}" | jq --raw-output '.["resource-id"]')
#fi
#
#mem_free=`free -m | grep Mem  | awk -F' ' '{print $4}'`
#mem_free_percent=$((mem_free*100 / mem))
#storage_free=`df -h / | grep "/" | awk -F' ' '{print $4}' | tr -d 'G'`
#storage_free_percent=$(echo "$storage_free * 100 / $storage" | bc)
#
#device_dynamic='{
#        "device": {"href": "'$device_id'"},
#        "ramFree": '$mem_free'.0,
#        "ramFreePercent": '$mem_free_percent'.0,
#        "storageFree": '$storage_free',
#        "storageFreePercent": '$storage_free_percent'.0,
#        "cpuFreePercent": 50.0,
#        "powerRemainingStatus": "100%",
#        "powerRemainingStatusSeconds": "99999999",
#        "ethernetAddress": "'$VPN_IP'",
#        "wifiAddress": "'$VPN_IP'",
#        "ethernetThroughputInfo": [],
#        "wifiThroughputInfo": [],
#        "sensorType": [],
#        "sensorModel": [],
#        "sensorConnection": [],
#        "myLeaderID": {"href": "'$CLOUD_URL'"}
#}'
#
#if [ ! -z $USER ] && [ ! -z $PASSWORD ]
#then
#    cookies=' -b cookies -c cookies '
#    curl -XPOST -k ${headers} ${cookies} ${API}/device-dynamic -d "${device_dynamic}"
#else
#    curl -XPOST -k ${headers} -H "slipstream-authn-info: internal ADMIN" ${API}/device-dynamic -d "${device_dynamic}"
#fi
#
#lm_id=`docker run --rm -d -p 46000:46000 mf2c/lifecycle:1.0.6-arm`
#
#function shutdown {
#    # re-start service
#    docker rm -f $lm_id
#    cleanup
#}
#trap shutdown INT
#trap shutdown EXIT
#
#while true; do :; done