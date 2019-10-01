#!/bin/bash -e
#Script to test the integration between the dashboard and the identification module in the mF2C Project
#

printf '\e[0;33m %-15s \e[0m \n' "The installation of the jq package is a prerequisite to run the test"
printf '\e[0;33m %-15s \e[0m Starting...\n' [Identification-Test]

function log
{
    text="$2"
    if [[ $1 == "OK" ]]
    then
        printf '\e[0;33m %-15s \e[32m SUCCESS:\e[0m %s \n' [Identification-Test] "$text"
    else
        printf '\e[0;33m %-15s \e[0;31m FAILED:\e[0m %s \n' [Identification-Test] "$text"
    fi
}

endpoint="http://localhost:46060/api/v1/resource-management/identification/requestID"


# Is the device already registered?
ans=`curl -s -XGET ${endpoint} | jq -r '.status'`
if [[ ${ans} -eq 412 ]]; then
    log "NO" "Device isn't registered yet"
else
    log "OK" "The device is registered"
fi

# Get new device ID
ans=`curl -s -GET ${endpoint} | jq -r '.status'`
if [[ ${ans} -eq 200 ]]; then
    log "OK" "Device ID has been successfully obtained"
else
    log "NO" "Failed to obtain the device ID"
fi