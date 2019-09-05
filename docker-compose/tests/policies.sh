#!/bin/bash -e

printf '\e[0;33m %-15s \e[0m Starting...\n' [PoliciesTests]

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

BASE_API_URL=`echo ${BASE_API_URL:="http://localhost:46050"} | tr -d '"'`
CIMI_API_URL=`echo ${CIMI_API_URL:="https://localhost/api"} | tr -d '"'`



#### Policies Tests ####
# 1. Policies API
( [[ $(curl -I "${BASE_API_URL}" -ksS | head -n1 | cut -d" " -f2) -eq 200 ]] > /dev/null 2>&1 && \
    log "OK" "Policies API working properly") || \
    log "NO" "Policies API not working properly"

# 2. Policies role
LEADERINFO=$(curl -XGET "${BASE_API_URL}/api/v2/resource-management/policies/leaderinfo" -ksS 2>&1 )
ISLEADER=$(echo "${LEADERINFO}" | jq -r ".imLeader")
ISBACKUP=$(echo "${LEADERINFO}" | jq -r ".imBackup")
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
