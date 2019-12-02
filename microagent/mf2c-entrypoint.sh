#!/bin/sh

if [ -z ${MF2C_USER} ] || [ -z ${MF2C_PWD} ]
then
  echo "Missing MF2C_USER/MF2C_PWD credentials. Please export those"
  exit 1
fi

set -x

containers=''

containers_to_clean='mf2c_micro_lifecycle mf2c_micro_resource-categorization mf2c_micro_discovery mf2c_micro_cau-client mf2c_micro_identification'

docker run -d --rm --name mf2c_micro_cleaner \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -e PARENT=$(hostname) \
        -e CHILD="${containers_to_clean}" \
        sixsq/wrapper-cleaner:master

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

get_id='curl -X GET http://localhost:46060/api/v1/resource-management/identification/requestID'
while [[ "$deviceID" != "null" ]]
do
  deviceID=$(docker exec mf2c_micro_identification sh -c "${get_id}" | jq -r .deviceID)
  sleep 2
done

register_cmd='curl -X POST http://localhost:46060/api/v1/resource-management/identification/registerDevice/'
docker exec mf2c_micro_identification sh -c "${register_cmd}"
while [ $? -ne 0 ]
do
  sleep 3
  docker exec mf2c_micro_identification sh -c "${register_cmd}"
done

while [[ "$deviceID" == "null" ]]
do
  deviceID=$(docker exec mf2c_micro_identification sh -c "${get_id}" | jq -r .deviceID)
  sleep 3
done


# variable coming from Nuvla
export detectedLeaderID=${LEADER_ID:-$deviceID}

docker exec mf2c_micro_cau-client sh -c "echo getpubkey=1233211234567 | nc localhost 46065"
while [ $? -ne 0 ]
do
  sleep 5
  docker exec mf2c_micro_cau-client sh -c "echo getpubkey=1233211234567 | nc localhost 46065"
done

cau_registration="echo detectedLeaderID=${detectedLeaderID},deviceID=${deviceID} | nc localhost 46065"
docker exec mf2c_micro_cau-client sh -c "${cau_registration}"

docker run -d --network="host" \
        --cap-add=NET_ADMIN \
        -v /var/run/docker.sock:/var/run/docker.sock \
        --name mf2c_micro_discovery \
        --label "PRODUCT=MF2C" \
        mf2c/discovery-microagent:4.9

docker run -d --hostname=IRILD039 --privileged \
        -e LEADER_ENDPOINT="https://dashboard.mf2c-project.eu" \
        -e agentType=3 \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /etc/hostname:/etc/hostname \
        -v vpninfo:/vpninfo \
        --name mf2c_micro_resource-categorization \
        --label "PRODUCT=MF2C" \
        mf2c/resource-categorization:resCatlatest-V2.0.28-arm

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
  sleep 2
  docker exec mf2c_micro_resource-categorization sh -c "${trigger_cat}"
done

cat>>env.list <<EOF
HOST_IP=192.168.252.41
WORKING_DIR_VOLUME=/tmp/mf2c/compose_files
UM_WORKING_DIR_VOLUME=/tmp/mf2c/um/
LM_WORKING_DIR_VOLUME=/tmp/mf2c/lm/
SERVICE_CONSUMER=true
RESOURCE_CONTRIBUTOR=true
MAX_APPS=3
EOF

docker run --rm -p 46300:46300 -p 46000:46000 --env-file env.list \
        -v /tmp/mf2c/compose_files:/tmp/mf2c/compose_files \
        -v /tmp/mf2c/um:/tmp/mf2c/um \
        -v /tmp/mf2c/lm:/tmp/mf2c/lm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        --name mf2c_micro_lifecycle \
        --label "PRODUCT=MF2C" \
        mf2c/lifecycle:1.0.7-arm

containers='mf2c_micro_lifecycle mf2c_micro_resource-categorization mf2c_micro_discovery mf2c_micro_cau-client mf2c_micro_identification'
self=`hostname`

cat>cleaner.sh <<EOF
#!/bin/bash
docker wait $parent

docker rm -f "$mf2c_containers"
EOF

#docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/cleaner.sh:/cleaner.sh docker sh /cleaner.sh

