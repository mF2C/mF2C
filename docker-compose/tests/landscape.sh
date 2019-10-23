#!/bin/bash -e

printf '\e[0;33m %-15s \e[0m Starting...\n' [LandscaperTests]

function log {
    text="$2"
    if [[ $1 == "OK" ]]
    then
        printf '\e[0;33m %-15s \e[32m SUCCESS:\e[0m %s \n' [LandscaperTests] "$text"
    else
        printf '\e[0;33m %-15s \e[0;31m FAILED:\e[0m %s \n' [LandscaperTests] "$text"
    fi
}

BASE_API_URL=`echo ${BASE_API_URL:="http://localhost:9001/"} | tr -d '"'`

HOSTNAME_SYSFS="/proc/sys/kernel/hostname"

read HOSTNAME < $HOSTNAME_SYSFS



### Test Landscpae operations
# test if graph contains hostname data 
(curl -XGET "${BASE_API_URL}/graph" -ksS | jq -e '.nodes | tostring| contains("'$HOSTNAME'")' | grep -q true > /dev/null 2>&1 && \
    log "OK" "host metadata exist in landscape") || \
        log "NO" "host metadata dosn't exist in landscape" 

#test if mf2c device id is populated 
(curl -XGET "${BASE_API_URL}/graph" -ksS | jq -e '.nodes | tostring| contains("mf2c_device_id")' | grep -q true  > /dev/null 2>&1 && \
    log "OK" "mf2c_device_id is populated in landscape") || \
        log "NO" "mf2c_device_id is not populated in landscape" 


#test if docker metadata is stored in lanscape 
(curl -XGET "${BASE_API_URL}/graph" -ksS | jq -e '.nodes | tostring| contains("docker_container")' | grep -q true  > /dev/null 2>&1 && \
    log "OK" "docker metadata is stored in landscape") || \
        log "NO" "docker metadata is not stored in landscape" 
