#!/bin/bash -e
AGENT_IP=$(ip route get 1.2.3.4 | awk '{print $7}' | head -n 1)
SERVICE_NAME="COMPSs-test"
SERVICE_IMAGE="mf2c/compss-test:it2.8"

BASE_API_URL=`echo ${BASE_API_URL:="https://localhost/api"} | tr -d '"'`
LM_API_URL="http://localhost:46000/api/v2/lm"

function ctrl_c() {
    shutdown
}

function log {
    text="$2"
    if [[ $1 == "OK" ]]
    then
        printf '\e[0;33m %-23s \e[32m SUCCESS:\e[0m %s \n' "[COMPSsTest]" "$text"
    elif [[ $1 == "INFO" ]]; then
        printf '\e[0;33m %-23s \e[1;34m INFO:   \e[0m %s \n' "[COMPSsTest]" "$text"
    else
        printf '\e[0;33m %-23s \e[0;31m FAILED: \e[0m %s \n' "[COMPSsTest]" "$text"
    fi
}

function shutdown { 

    if [ ! -z ${SERVICE_INSTANCE_ID} ]; then
        log INFO "Terminating service ${SERVICE_INSTANCE_ID}"
        TERMINATE_SERVICE_INSTANCE_ID=$(curl -XDELETE "${LM_API_URL}/service-instances/${SHORT_SERVICE_INSTANCE_ID}" -ksS) && \
            log OK "Service terminated" || \
            log FAILURE 'Error terminating the service
        '"${TERMINATE_SERVICE_INSTANCE_ID}"
    fi

    exit 127
}

trap ctrl_c INT

##### Wait for mF2C Platform to be up and running
log INFO "Waiting until mf2c platform is totally deployed..."

DEVICE_COUNT=0
while [ "${DEVICE_COUNT}" = "0" ]; do
    sleep 1
    DEVICE_COUNT=$(curl -k -H 'slipstream-authn-info:internal ADMIN' -H 'content-type:application/json' ${BASE_API_URL}/sharing-model 2>/dev/null | jq -re ".count" 2>/dev/null|| echo "0") 
done
log INFO "    Sharing model already loaded."

while [ "${DEVICE_COUNT}" = "0" ]; do
    sleep 1
    DEVICE_COUNT=$(curl -k -H 'slipstream-authn-info:internal ADMIN' -H 'content-type:application/json' ${BASE_API_URL}/user-profile 2>/dev/null | jq -re ".count" 2>/dev/null|| echo "0") 
done
log INFO "    User profile already loaded."

log INFO "Starting test execution..."
##### SERVICE CREATION
# Create SLA template
log INFO "Creating a new SLA Template ..."
SLA_TEMPLATE_ID=$(curl -XPOST "${BASE_API_URL}/sla-template" -ksS -H 'content-type: application/json' -H 'slipstream-authn-info: super ADMIN' -d '{
    "name": "compss-hello-world",
    "state": "started",
    "details":{
        "type": "template",
        "name": "compss-hello-world",
        "provider": { "id": "mf2c", "name": "mF2C Platform" },
        "client": { "id": "c02", "name": "A client" },
        "creation": "2018-01-16T17:09:45.01Z",
        "guarantees": [
            {
                "name": "es.bsc.compss.agent.test.Test.main",
                "constraint": "execution_time < 10"
            }
        ]
    }
}' | jq -res 'if . == [] then null else .[] | .["resource-id"] end') && \
    log "OK" "sla template $SLA_TEMPLATE_ID created successfully" || \
        (log "NO" "failed to create new service SLA $SLA_TEMPLATE_ID" && shutdown)

# Create service
log INFO "Creating a new Service ..."

SERVICE_ID=$(curl -XPOST "${BASE_API_URL}/service" -ksS -H 'content-type: application/json' -H 'slipstream-authn-info: super ADMIN' -d '{
    "name": "'${SERVICE_NAME}'",
    "description": "Service to validate COMPSs integration with other mF2C components",
    "exec": "'${SERVICE_IMAGE}'",
    "exec_type": "compss",
    "sla_templates": ["'${SLA_TEMPLATE_ID}'"],
    "agent_type": "normal",
    "num_agents": "1",
    "cpu_arch": "x86-64",
    "memory_min": "1000", 
    "storage_min": "100",
    "os": "linux",
    "req_resource": [],
    "opt_resource": []
}'  | jq -es 'if . == [] then null else .[] | .["resource-id"] end' | tr -d '"') && \
    log "OK" "service $SERVICE_ID created successfully" || \
        (log "NO" "failed to create new service $SERVICE_ID" && shutdown)

# Deploy service
log INFO "Deploying service ..."
LM_OUTPUT=$(curl -XPOST "${LM_API_URL}/service" -ksS -H 'content-type: application/json' -d '{
     "service_id": "'"$SERVICE_ID"'",
     "sla_template": "'"$SLA_TEMPLATE_ID"'",
     "agents_list": [{"agent_ip": "'"${AGENT_IP}"'"}]
}') >/dev/null 2>&1 
if [[ $(echo "${LM_OUTPUT}" | jq -r ".error" 2>/dev/null) == "true" ]]; then
    log "NO" 'Failed to create new deployment 
'"${LM_OUTPUT}"
    shutdown
fi

log "OK" "New deployment created successfully"

SERVICE_INSTANCE_ID=$(echo "${LM_OUTPUT}" | jq -r ".service_instance.id")
SHORT_SERVICE_INSTANCE_ID=$(echo "${SERVICE_INSTANCE_ID}" | cut -d '/' -f 2)
SERVICE_INSTANCE_IP=$(echo ${LM_OUTPUT} | jq -e 'if . == [] then null else .service_instance.agents[].url end' | tr -d '"') > /dev/null 2>&1

log INFO "Service Instance ID ${SERVICE_INSTANCE_ID}"
log INFO "Service Instance IP ${SERVICE_INSTANCE_IP}"

SI_STATUS="created-not-initialized"
while [ "$SI_STATUS" = "created-not-initialized" ]; do
	sleep 1
	SERVICE_INSTANCE=$(curl "${BASE_API_URL}/${SERVICE_INSTANCE_ID}" -ksS -H 'content-type: application/json' -H 'slipstream-authn-info: super ADMIN')
	SI_STATUS=$(echo "${SERVICE_INSTANCE}" | jq -re ".status")
	log INFO "Service instance status = $SI_STATUS..."
done



# Verify COMPSs agent availability
log INFO "Waiting for agent to boot"
sleep 20

COMPSs_AGENTS=$(curl "${BASE_API_URL}/${SERVICE_INSTANCE_ID}" -ksS  -H 'slipstream-authn-info: super ADMIN' | jq '.agents[] | (.url+":"+ (.ports[0]|tostring))' | tr -d '"')
for agent in ${COMPSs_AGENTS}; do 
    curl -XGET http://${agent}/COMPSs/test 2>/dev/null && \
        log OK "Successfully contacted agent ${agent}"|| \
        log ERROR "Could not reach agent ${agent}"
done




log INFO "Starting operation with ${LM_API_URL}/service-instances/${SHORT_SERVICE_INSTANCE_ID}/der"

# Start operation
LM_OUTPUT=$(curl -XPUT "${LM_API_URL}/service-instances/${SHORT_SERVICE_INSTANCE_ID}/der" -ksS -H 'content-type: application/json' -d '{
    "operation":"start-job",
    "ceiClass":"es.bsc.compss.agent.test.TestItf",
    "className":"es.bsc.compss.agent.test.Test",
    "hasResult":false,
    "methodName":"main",
    "parameters":"<params paramId=\"0\"><direction>IN</direction><stream>UNSPECIFIED</stream><type>OBJECT_T</type><array paramId=\"0\"><componentClassname>java.lang.String</componentClassname><values><element paramId=\"0\"><className>java.lang.String</className><value xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xsi:type=\"xs:string\">20</value></element></values></array></params>" 
}')
if [[ ! $(echo "${LM_OUTPUT}" | jq -r ".error" 2>/dev/null) == "false" ]]; then
    log ERROR 'Error launching compss operation 
'"${LM_OUTPUT}"
    shutdown
fi
log OK "Operation successfully launched."




FINISHED_OPERATION="false"
while [ ! ${FINISHED_OPERATION} == "true" ]; do
    sleep 1

    # CHECK OPERATION REPORT
    LM_OUTPUT=$(curl -XGET "${LM_API_URL}/service-instances/${SHORT_SERVICE_INSTANCE_ID}/report" -ksS -H 'content-type: application/json')
    if [[ ! $(echo "${LM_OUTPUT}" | jq -r ".error" 2>/dev/null) == "false" ]]; then
        log ERROR 'Error obtaining report 
    '"${LM_OUTPUT}"
    fi

    EXECUTION_LENGTH=$(echo "${LM_OUTPUT}" | jq -r ".report.execution_length" 2>/dev/null || echo "0")
    if [ "${EXECUTION_LENGTH}" == "0" ]; then
        EXPECTED_END=$(echo "${LM_OUTPUT}" | jq -r ".report.expected_end_time" 2>/dev/null)
        echo ${EXPECTED_END}
    else
        FINISHED_OPERATION="true"
        END_TIME=$(echo "${LM_OUTPUT}" | jq -r ".report.expected_end_time" 2>/dev/null)
        echo ${END_TIME}
    fi
done



shutdown
