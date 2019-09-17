#!/bin/bash -e
#Script to test the integration between the dashboard and the identification module in the mF2C Project
#

printf '\e[0;33m %-15s \e[0m \n' "Tester needs privilege to run Docker commands"
printf '\e[0;33m %-15s \e[0m \n' "The installation of the jq package is a prerequisite to run the test"
printf '\e[0;33m %-15s \e[0m \n' "WARNING: During the testing, the identification component will be permanently stopped, thus, manual starting will be required"
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

# Start the mf2c/identification:latest docker image
ans=`docker ps -q  --filter ancestor=mf2c/identification:latest | grep -q . && echo true || echo false`
container=""
if [ ${ans} == true ]; then
    container=`docker ps | grep "mf2c/identification:latest" | awk '{ print $1 }'`
    stopped=`docker stop ${container}`
    printf '\e[0;33m %-15s \e[0;36m ALERT:\e[0m %s \n' [Identification-Test] "The mf2c/identification container has been stopped"
fi
usr="alejandro" # The new created account needs to be activated, so I will use this credentials to continue with the test
pwd="12345678"
ans=`docker run -d -e mF2C_User=${usr} -e mF2C_Pass=${pwd} --publish=0.0.0.0:46060:46060 mf2c/identification:latest`
printf '\e[0;33m %-15s \e[0;36m ALERT:\e[0m %s \n' [Identification-Test] "The mf2c/identification container has been initialized"

# Sleep 30 seconds  
seconds=30
printf '\e[0;33m %-15s \e[0;36m ALERT:\e[0m %s \n' [Identification-Test] "Waiting 30 seconds until the identification module is ready"
until [ "$seconds" -le 0 ]
do
    sleep 10s
    seconds=$(( $seconds - 10 ))
    if [ "$seconds" -ne "0" ]; then
        printf '\e[0;33m %-15s \e[0;36m ALERT:\e[0m %s \n' [Identification-Test] "Waiting ${seconds} seconds until the identification module is ready"
    fi
done

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

# Stop the mf2c/identification:latest docker image
ans=`docker ps -q  --filter ancestor=mf2c/identification:latest | grep -q . && echo true || echo false`
container=""
if [ ${ans} == true ]; then
    container=`docker ps | grep "mf2c/identification:latest" | awk '{ print $1 }'`
    stopped=`docker stop ${container}`
    printf '\e[0;33m %-15s \e[0;36m ALERT:\e[0m %s \n' [Identification-Test] "The mf2c/identification container has been stopped"
fi

# Delete created user
endpoint="http://dashboard.mf2c-project.eu:8000/ResourceManagement/Identification/deleteUserTest"
ans=`curl -GET "${endpoint}" -s`
if [[ ${ans} -eq 200 ]]; then
    log "OK" "Deleted the created user account"
elif [[ ${ans} -eq 400 ]]; then
    log "NO" "Failed to deleted the created user account"
fi