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

### Test Landscpae operations
# test if graph contains compss-test 
(curl -XGET "${BASE_API_URL}/graph" -ksS | jq -e '.nodes | tostring| contains("compss-test")' | grep -q true > /dev/null 2>&1 && \
    log "OK" "compss-test docker container exist in landscape") || \
        log "NO" "compss-test docker container dosn't exist in landscape" 

#test if mf2c device id is populated 
(curl -XGET "${BASE_API_URL}/graph" -ksS | jq -e '.nodes | tostring| contains("mf2c_device_id")' | grep -q true  > /dev/null 2>&1 && \
    log "OK" "mf2c_device_id is populated in landscape") || \
        log "NO" "mf2c_device_id is not populated in landscape" 


#test if mf2c network is stored in lanscape 
(curl -XGET "${BASE_API_URL}/graph" -ksS | jq -e '.nodes | tostring| contains("mf2c_default")' | grep -q true  > /dev/null 2>&1 && \
    log "OK" "mf2c_default network is stored in landscape") || \
        log "NO" "mf2c_default network is not stored in landscape" 
