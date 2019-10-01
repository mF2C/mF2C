#!/bin/bash -e
#Script to test the integration between the dashboard and the identification module in the mF2C Project
#

printf '\e[0;33m %-15s \e[0m \n' "The installation of the jq package is a prerequisite to run the test"
printf '\e[0;33m %-15s \e[0m \n' "ALERT: During the testing, it is assumed that the mf2c/identification:latest is already in execution"
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

# Create a new user in the System
endpoint="http://dashboard.mf2c-project.eu:8000/ResourceManagement/Identification/registerUserTest"
ans=`curl -GET "${endpoint}" -s`
if [[ ${ans} -eq 200 ]]; then
    log "OK" "Created new user account"
elif [[ ${ans} -eq 400 ]]; then
    log "NO" "Failed to create new user account"
fi

# Register new device
endpoint="http://localhost:46060/api/v1/resource-management/identification/registerDevice"
ans=`curl -s -XPOST ${endpoint} | jq -r '.status'`
if [[ ${ans} -eq 201 ]]; then
    log "OK" "New device has been registered"
else
    log "NO" "Failed to register new device"
fi

# Get new device ID
endpoint="http://localhost:46060/api/v1/resource-management/identification/requestID"
ans=`curl -s -GET ${endpoint} | jq -r '.status'`
if [[ ${ans} -eq 200 ]]; then
    log "OK" "Device ID has been successfully obtained"
else
    log "NO" "Failed to obtain the device ID"
fi

# Delete created user
endpoint="http://dashboard.mf2c-project.eu:8000/ResourceManagement/Identification/deleteUserTest"
ans=`curl -GET "${endpoint}" -s`
if [[ ${ans} -eq 200 ]]; then
    log "OK" "Deleted the created user account"
elif [[ ${ans} -eq 400 ]]; then
    log "NO" "Failed to deleted the created user account"
fi