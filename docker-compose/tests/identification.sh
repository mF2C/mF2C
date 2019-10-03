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
ans=`curl -s -GET ${endpoint} | jq -r '.status'`
if [[ ${ans} -eq 200 ]]; then
    log "OK" "The device is registered"
    registered="OK"
else
    log "NO" "Device isn't registered yet"
    registered="NO"
fi

# Get the stored IDkey and deviceID
if [[ ${registered} == "OK" ]]; then
    IDKey=`curl -s -GET ${endpoint} | jq -r '.IDKey'`
    IDKey=${IDKey:0:8}
    deviceID=`curl -s -GET ${endpoint} | jq -r '.deviceID'`
    deviceID=${deviceID:0:8}
    printf '\e[0;33m %-15s \e[0;36m INFO:\e[0m %s \n' [Identification-Test] "The truncated IDKey string is ${IDKey} and the truncated deviceID string is ${deviceID}"
fi