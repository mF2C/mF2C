#!/usr/bin/env bash

agent_type_arg="normal"
exec_arg="mf2c/compss-test:it2.9"
exec_type_arg="compss"

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
  --num-agents)
    num_agents_arg="$2"
    shift # past argument
    shift # past value
    ;;
  --micro)
    agent_type_arg="micro"
    exec_arg="hello-world"
    exec_type_arg="docker"
    shift # past argument
    shift # past value
    ;;
  --include-tests)
    include_tests_arg=yes
    shift # past argument
    ;;
  *) # unknown option
    shift # past argument
    ;;
  esac
done

if [[ "$include_tests_arg" == "yes" ]]; then
  tests_folder="./tests/"
  tests=$(ls $tests_folder)
  for tester in $tests; do
    echo "Current test: ${tester}..."
    eval $tests_folder$tester
  done
else
  echo -e "\n    Use --include-tests to run all scripts in the 'tests' folder    \n"
fi

command -v jq >/dev/null 2>&1 || {
  echo >&2 "Error: Please, first install jq in order to proceed with the tests."
  exit 1
}

printf '\e[0;33m %-15s \e[0m Starting...\n' [HelloWorldTest]

function log() {
  text="$2"
  tests="$3"
  if [[ $1 == "OK" ]]; then
    printf '\e[0;33m %-23s \e[32m SUCCESS:\e[0m %s \n' "$tests" "$text"
  elif [[ $1 == "INFO" ]]; then
    printf '\e[0;33m %-23s \e[1;34m INFO:   \e[0m %s \n' "$tests" "$text"
  else
    printf '\e[0;33m %-23s \e[0;31m FAILED: \e[0m %s \n' "$tests" "$text"
  fi
}

# 1. check device-dynamic
DEVICE_DYNAMIC_ID=$(curl -XGET "https://localhost/api/device-dynamic" -ksS -H 'content-type: application/json' -H 'slipstream-authn-info: super ADMIN' |
  jq -es 'if . == [] then null else .[] | .["deviceDynamics"][0].id end') &&
  log "OK" "device dynamic $DEVICE_DYNAMIC_ID was created successfully" [ResourceCategorization] ||
  log "NO" "no device dynamic was added" [ResourceCategorization]

# 2. submit sla-template
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
                "name": "es.bsc.compss.agent.test.Test.main",
                "constraint": "execution_time < 10"
            }
        ]
    }
}' | jq -res 'if . == [] then null else .[] | .["resource-id"] end') &&
  log "OK" "sla-template $SLA_TEMPLATE_ID created successfully" [SLAManager] ||
  log "NO" "failed to create new sla-template $SLA_TEMPLATE_ID" [SLAManager]

# 3. submit hello-world service
SERVICE_ID=$(curl -XPOST "https://localhost/api/service" -ksS -H 'content-type: application/json' -H 'slipstream-authn-info: super ADMIN' -d '{
    "name": "hello-world",
    "description": "hello world test",
    "exec": "'"$exec_arg"'",
    "exec_type": "'"$exec_type_arg"'",
    "sla_templates": ["'"$SLA_TEMPLATE_ID"'"],
    "agent_type": "'"$agent_type_arg"'",
    "num_agents": "'"$num_agents_arg"'"
}' | jq -es 'if . == [] then null else .[] | .["resource-id"] end') &&
  log "OK" "service $SERVICE_ID created successfully" [ServiceManager] ||
  log "NO" "failed to create new service $SERVICE_ID" [ServiceManager]

# 4. ask analytics for the list of agents
ANALYTICS_IP_ADDRESS=$(curl -XPOST "http://localhost:46020/mf2c/optimal" -ksS -H 'content-type: application/json' -d '{"name": "compss-hello-world"}' |
  jq -e 'if . == [] then null else .[].ipaddress end') >/dev/null 2>&1
ANALYTICS_IP_ADDRESS=$(echo $ANALYTICS_IP_ADDRESS | tr -d '\n')
if [[ ($ANALYTICS_IP_ADDRESS != null) && ($ANALYTICS_IP_ADDRESS != "") ]]; then
  log "OK" "ip $ANALYTICS_IP_ADDRESS returned successfully" [Analytics]
else
  log "NO" "failed to return list of ip addresses" [Analytics]
fi

# 5. launch hello-world service-instance
SERVICE_ID=$(echo $SERVICE_ID | tr -d '"')
LM_OUTPUT=$(curl -XPOST "http://localhost:46000/api/v2/lm/service" -ksS -H 'content-type: application/json' -d '{ "service_id": "'"$SERVICE_ID"'", "sla_template": "'"$SLA_TEMPLATE_ID"'"}') >/dev/null 2>&1
SERVICE_INSTANCE_IP=$(echo $LM_OUTPUT | jq -e 'if . == [] then null else .service_instance.agents[].url end') >/dev/null 2>&1
SERVICE_INSTANCE_IP=$(echo $SERVICE_INSTANCE_IP | tr -d '\n')
SERVICE_INSTANCE_ID=$(echo "$LM_OUTPUT" | jq -r ".service_instance.id")
if [[ ($SERVICE_INSTANCE_IP != null) && ($SERVICE_INSTANCE_IP != "") ]]; then
  log "OK" "service-instance launched in $SERVICE_INSTANCE_IP successfully" [LifecycleManager]
else
  log "NO" "failed to launch service-instance" [LifecycleManager]
fi

# 6. check if sla agreement is created
SI_STATUS="created-not-initialized"
while [ "$SI_STATUS" = "created-not-initialized" ]; do
  sleep 5
  SERVICE_INSTANCE=$(curl "https://localhost/api/$SERVICE_INSTANCE_ID" -ksS -H 'content-type: application/json' -H 'slipstream-authn-info: super ADMIN')
  SI_STATUS=$(echo "$SERVICE_INSTANCE" | jq -re ".status")
  log "INFO" "service instance status = $SI_STATUS..." [LifecycleManager]
done
AGREEMENT_ID=$(echo "$SERVICE_INSTANCE" | jq -re ".agreement")
if [[ -n "$AGREEMENT_ID" && "$AGREEMENT_ID" =~ ^agreement/.*$ ]]; then
  log "OK" "agreement created successfully" [SlaManagement]
else
  log "NO" "failed to create agreement" [SlaManagement]
fi
