#!/bin/bash -e

printf '\e[0;33m %-15s \e[0m Starting...\n' [PoliciesTests]
DOCKER_NAME_POLICIES="policies"

function log {
    text="$2"
    if [[ $1 == "OK" ]]
    then
        printf '\e[0;33m %-15s \e[32m SUCCESS:\e[0m %s \n' [PoliciesTests] "$text"
    elif [[ $1 == "IF" ]]
    then
        printf '\e[0;33m %-15s \e[34m INFO:\e[0m %s \n' [PoliciesTests] "$text"
    else
        printf '\e[0;33m %-15s \e[0;31m FAILED:\e[0m %s \n' [PoliciesTests] "$text"
    fi
}

function exec_docker {
    container_name=$(docker ps -f "name=$DOCKER_NAME_POLICIES" --format '{{.Names}}')
    exec_res=$(docker exec "${container_name}" /bin/bash -c "$1"  2>/dev/null)
}

BASE_API_URL=`echo ${BASE_API_URL:="http://localhost:46050"} | tr -d '"'`
CIMI_API_URL=`echo ${CIMI_API_URL:="https://localhost/api"} | tr -d '"'`

#### Policies Tests ####
# 1. Policies API
exec_docker "curl -I \"${BASE_API_URL}\" -ksS | head -n1 | cut -d\" \" -f2"
( [[ ${exec_res} -eq 200 ]] > /dev/null 2>&1 && \
    log "OK" "Policies API working properly") || \
    log "NO" "Policies API not working properly"

# 2. Policies role
exec_docker "curl -XGET \"${BASE_API_URL}/api/v2/resource-management/policies/leaderinfo\" -ksS"
LEADERINFO=${exec_res}
ISLEADER=$(echo "${LEADERINFO}" | jq -r ".imLeader" 2>/dev/null)
ISBACKUP=$(echo "${LEADERINFO}" | jq -r ".imBackup" 2>/dev/null)
log "IF" "imLeader=${ISLEADER}, imBackup=${ISBACKUP}"
( [[ $ISLEADER == "false" || $ISLEADER == "true" ]] && \
    log "OK" "Policies leader role successfully received" ) || \
    log "NO" "Policies leader role not correct"

( [[ $ISBACKUP == "true" || $ISBACKUP == "false" ]] && \
    log "OK" "Policies backup role successfully received" ) || \
    log "NO" "Policies backup role not correct"


# 3. Resource Created
(curl -XGET "${CIMI_API_URL}/agent" -ksS -H 'slipstream-authn-info: internal ADMIN' | jq -e 'select(.count >= 1)' > /dev/null 2>&1 && \
    log "OK" "Agent resource created") || \
    log "NO" "Agent resource not created"

# 4. Agent Started Successfully (Identification, Discovery, CAU client, Categorization)
exec_docker "curl -XGET \"${BASE_API_URL}/rm/components\" -ksS"
RMINFO=${exec_res}
IDENTIFICATION=$(echo "${RMINFO}" | jq -r ".identification" 2>/dev/null)
DISCOVERY=$(echo "${RMINFO}" | jq -r ".discovery" 2>/dev/null)
CAU_CLIENT=$(echo "${RMINFO}" | jq -r ".cau_client" 2>/dev/null)
RES_CAT=$(echo "${RMINFO}" | jq -r ".categorization" 2>/dev/null)
STARTED=$(echo "${RMINFO}" | jq -r ".started" 2>/dev/null)

( [[ ${STARTED} == "true" ]]  && \
    log "OK" "Agent Start workflow successfully started.") || \
    log "NO" "Agent Start workflow not started."
( [[ ${IDENTIFICATION} == "true" ]]  && \
    log "OK" "Identification successfully triggered.") || \
    log "NO" "Identification trigger failed."
( [[ ${DISCOVERY} == "true" ]]  && \
    log "OK" "Discovery successfully triggered.") || \
    log "NO" "Discovery trigger failed."

if [[ ${ISLEADER} == "false" ]]; then
    ( [[  ${CAU_CLIENT} == "true" ]]  && \
    log "OK" "CAU client successfully triggered.") || \
    log "NO" "CAU client trigger failed."
else
    log "IF" "CAU client test skip."
fi

( [[ ${RES_CAT} == "true" ]]  && \
    log "OK" "Resource Categorization successfully triggered.") || \
    log "NO" "Resource Categorization trigger failed."