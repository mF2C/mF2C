#!/bin/bash -e

printf '\e[0;33m %-15s \e[0m Starting...\n' [ServiceManagerTests]

function log {
    text="$2"
    if [[ $1 == "OK" ]]
    then
        printf '\e[0;33m %-15s \e[32m SUCCESS:\e[0m %s \n' [ServiceManagerTests] "$text"
    else
        printf '\e[0;33m %-15s \e[0;31m FAILED:\e[0m %s \n' [ServiceManagerTests] "$text"
    fi
}

# 1. submit sla-template before submitting a service
SLA_TEMPLATE_ID=$(curl -XPOST "https://localhost/api/sla-template" -ksS -H 'content-type: application/json' -H 'slipstream-authn-info: super ADMIN' -d '{
    "name": "compss-hello-world",
    "state": "started",
    "details":{
        "type": "template",
        "name": "compss-hello-world",
        "provider": { "id": "mf2c", "name": "mF2C Platform" },
        "client": { "id": "c02", "name": "A client" },
        "creation": "2018-01-16T17:09:45.01Z",
        "guarantees": [
            {
                "name": "TestGuarantee",
                "constraint": "execution_time < 10"
            }
        ]
    }
}' | jq -res 'if . == [] then null else .[] | .["resource-id"] end') && \
    log "OK" "sla-template $SLA_TEMPLATE_ID created successfully" [SLAManager] || \
        log "NO" "failed to create new sla-template $SLA_TEMPLATE_ID" [SLAManager]


# 2. submit hello-world service
SERVICE_ID=$(curl -XPOST "https://localhost/api/service" -ksS -H 'content-type: application/json' -H 'slipstream-authn-info: super ADMIN' -d '{
    "name": "compss-hello-world",
    "description": "hello world example",
    "exec": "mf2c/compss-test:it2",
    "exec_type": "compss",
    "sla_templates": ["'"$SLA_TEMPLATE_ID"'"],
    "agent_type": "normal",
    "num_agents": 1,
    "cpu_arch": "x86-64",
    "os": "linux",
    "storage_min": 0,
    "req_resource": ["sensor_1"],
    "opt_resource": ["sensor_2"]
}' | jq -es 'if . == [] then null else .[] | .["resource-id"] end') && \
    log "OK" "service $SERVICE_ID created successfully" || \
        log "NO" "failed to create new service $SERVICE_ID"

# 3. check if service is categorized
SERVICE_ID=`echo $SERVICE_ID | tr -d '"'`
CATEGORY=$(curl -XGET "https://localhost/api/${SERVICE_ID}" -ksS -H 'content-type: application/json' -H 'slipstream-authn-info: super ADMIN' \
| jq -es 'if . == [] then null else .[] | .["category"] end') && \
    log "OK" "service $SERVICE_ID was categorized as $CATEGORY" || \
        log "NO" "service $SERVICE_ID is not categorized"

# 4. submit service-instance before checking QoS
SERVICE_INSTANCE=$(curl -XPOST "http://localhost:46000/api/v2/lm/service" -ksS -H 'content-type: application/json' -d '{
    "service_id": "'$SERVICE_ID'"
}' | jq -es 'if . == [] then null else .[] | .service_instance end') && \
    log "OK" "service-instance $( jq -r '.id'<<< "${SERVICE_INSTANCE}") launched successfully" || \
        log "NO" "failed to launch service-instance $( jq -r '.id'<<< "${SERVICE_INSTANCE}")"

# 5. check QoS (provider) from service-instance
SERVICE_INSTANCE_ID=$( jq -r '.id'<<< "${SERVICE_INSTANCE}")
(curl -XGET "https://localhost/sm/api/${SERVICE_INSTANCE_ID}" -ksS \
 | jq -es 'if . == [] then null else .[] | select(.status == 200) end') > /dev/null 2>&1 && \
    log "OK" "QoS for service instance $SERVICE_INSTANCE_ID checked successfully" || \
        log "NO" "failed to check QoS for service instance $SERVICE_INSTANCE_ID"

# 6. check if qos-model (provider) is added
AGREEMENT_ID=$(jq -r '.agreement'<<< "${SERVICE_INSTANCE}")
QOS_MODEL_ID=$(curl -XGET 'https://localhost/api/qos-model?$filter=service/href="'$SERVICE_ID'"&$filter=agreement/href="'$AGREEMENT_ID'"' \
-ksS -H 'content-type: application/json' -H 'slipstream-authn-info: super ADMIN' \
 | jq -es 'if . == [] then null else .[] | .["qos-models"][0].id end') && \
    log "OK" "qos-model $QOS_MODEL_ID for agreement $AGREEMENT_ID was created successfully" || \
        log "NO" "qos-model for agreement $AGREEMENT_ID does not exist"


# 7. create service-operations-reports


# 8. check if new agents are added to the service-instance

