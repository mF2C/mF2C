#!/bin/bash -e

printf '\e[0;33m %-15s \e[0m Starting...\n' [SerivceManagerTests]

function log {
    text="$2"
    if [[ $1 == "OK" ]]
    then
        printf '\e[0;33m %-15s \e[32m SUCCESS:\e[0m %s \n' [SerivceManagerTests] "$text"
    else
        printf '\e[0;33m %-15s \e[0;31m FAILED:\e[0m %s \n' [SerivceManagerTests] "$text"
    fi
}

# Create new service in cimi
SERVICE_ID=$(curl -XPOST "https://localhost/api/service" -ksS -H 'content-type: application/json' -H 'slipstream-authn-info: super ADMIN' -d '{
    "name": "compss-hello-world",
    "description": "hello world example",
    "exec": "mf2c/compss-test:it2",
    "exec_type": "compss",
    "exec_ports": [8080, 8081],
    "agent_type": "normal",
    "num_agents": 1,
    "cpu_arch": "x86-64",
    "os": "linux",
    "storage_min": 0,
    "req_resource": ["sensor_1"],
    "opt_resource": ["sensor_2"]
}' | jq -e '.["resource-id"]') && \
    log "OK" "service $SERVICE_ID created successfully" || \
        log "NO" "failed to create new service $SERVICE_ID"

# Check category of the service
SERVICE_ID=`echo $SERVICE_ID | tr -d '"'`
CATEGORY=$(curl -XGET "https://localhost/api/${SERVICE_ID}" -ksS -H 'content-type: application/json' -H 'slipstream-authn-info: super ADMIN' \
| jq -e '.["category"]') && \
    log "OK" "service $SERVICE_ID has category $CATEGORY" || \
        log "NO" "service $SERVICE_ID is not categorized"

# Launch new service instance
SERVICE_INSTANCE=$(curl -XPOST "http://localhost:46000/api/v2/lm/service" -ksS -H 'content-type: application/json' -d '{
    "service_id": "'$SERVICE_ID'"
}' | jq -r .service_instance) && \
    log "OK" "service instance $( jq -r '.id'<<< "${SERVICE_INSTANCE}") launched successfully" || \
        log "NO" "failed to launch service instance $( jq -r '.id'<<< "${SERVICE_INSTANCE}")"

# Check QoS
SERVICE_INSTANCE_ID=$( jq -r '.id'<<< "${SERVICE_INSTANCE}")
(curl -XGET "https://localhost/sm/api/${SERVICE_INSTANCE_ID}" -ksS \
 | jq -e 'select(.status == 200)') > /dev/null 2>&1 && \
    log "OK" "QoS for service instance $SERVICE_INSTANCE_ID checked successfully" || \
        log "NO" "failed to check QoS for service instance $SERVICE_INSTANCE_ID"

# Check if QoS model was added
AGREEMENT_ID=$(jq -r '.agreement'<<< "${SERVICE_INSTANCE}")
QOS_MODEL_ID=$(curl -XGET 'https://localhost/api/qos-model?$filter=service/href="'$SERVICE_ID'"&$filter=agreement/href="'$AGREEMENT_ID'"' \
-ksS -H 'content-type: application/json' -H 'slipstream-authn-info: super ADMIN' \
| jq -e '.["qos-models"][0].id') && \
    log "OK" "QoS model $QOS_MODEL_ID for agreement $AGREEMENT_ID was created successfully" || \
        log "NO" "QoS model for agreement $AGREEMENT_ID does not exist"