#!/usr/bin/env bash

printf '\e[0;33m %-15s \e[0m Starting...\n' [ResourceCategorizationTests]

function log {
    text="$2"
    if [[ $1 == "OK" ]]
    then
        printf '\e[0;33m %-15s \e[32m SUCCESS:\e[0m %s \n' [ResourceCategorizationTests] "$text"
    elif [[ $1 == "IF" ]]
    then
        printf '\e[0;33m %-15s \e[34m INFO:\e[0m %s \n' [ResourceCategorizationTests] "$text"
    else
        printf '\e[0;33m %-15s \e[0;31m FAILED:\e[0m %s \n' [ResourceCategoriationTests] "$text"
    fi
}

BASE_API_URL=`echo ${BASE_API_URL:="http://localhost:46070"} | tr -d '"'`
CIMI_API_URL=`echo ${CIMI_API_URL:="https://localhost/api"} | tr -d '"'`

# Checking the device_static information
(curl -XGET "${CIMI_API_URL}/device" -ksS -H 'slipstream-authn-info: internal ADMIN' | jq -e 'select(.count >= 1)' > /dev/null 2>&1 && \
    log "OK" "Device resource created") || \
    log "NO" "Device resource not created"


# Checking the device_dynamic information
(curl -XGET "${CIMI_API_URL}/device-dynamic" -ksS -H 'slipstream-authn-info: internal ADMIN' | jq -e 'select(.count >= 1)' > /dev/null 2>&1 && \
    log "OK" "Device-dynamic resource created") || \
    log "NO" "Device-dynamic resource not created"



# test "retrieve device IP" operation
DeviceIP=$(curl -XGET "${CIMI_API_URL}/agent" -ksS -H 'slipstream-authn-info: internal ADMIN' | jq -r ".agents[0]" | jq -r ".device_ip" > /dev/null 2>&1)

( [[ ${DeviceIP} != "None" || ${DeviceIP} != "" ]] && \
    log "OK" "Successful to get device IP") || \
    log "NO" "failed to get device IP"

