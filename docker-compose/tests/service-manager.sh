#!/bin/bash -e

function log() {
  text="$2"
  tests="$3"
  if [[ $1 == "OK" ]]; then
    printf '\e[0;33m %-23s \e[32m SUCCESS:\e[0m %s \n' "$tests" "$text"
  elif [[ $1 == "INFO" ]]; then
    printf '\e[0;33m %-23s \e[1;34m INFO:\e[0m %s \n' "$tests" "$text"
  else
    printf '\e[0;33m %-23s \e[0;31m FAILED:\e[0m %s \n' "$tests" "$text"
  fi
}

log "INFO" "Starting..." [ServiceManagerTests]

# 1. submit sla-template before submitting a service
SLA_TEMPLATE_ID=$(curl -XPOST "https://localhost/api/sla-template" -ksS -H 'content-type: application/json' -H 'slipstream-authn-info: super ADMIN' -d '{
    "name": "compss-hello-world",
    "state": "started",
    "details":{
        "type": "template",
        "name": "compss-hello-world",
        "provider": { "id": "mf2c", "name": "mF2C Platform" },
        "client": { "id": "test1234", "name": "A client" },
        "creation": "2018-01-16T17:09:45.01Z",
        "guarantees": [
            {
                "name": "TestGuarantee",
                "constraint": "execution_time < 1000"
            }
        ]
    }
}' | jq -res 'if . == [] then null else .[] | .["resource-id"] end') &&
  log "OK" "sla-template $SLA_TEMPLATE_ID created successfully" [SLAManager] ||
  log "NO" "failed to create new sla-template $SLA_TEMPLATE_ID" [SLAManager]

# 2. submit hello-world service
SERVICE_ID=$(curl -XPOST "https://localhost/api/service" -ksS -H 'content-type: application/json' -H 'slipstream-authn-info: super ADMIN' -d '{
    "name": "compss-hello-world",
    "description": "hello world example",
    "exec": "mf2c/compss-test:it2.9",
    "exec_type": "compss",
    "sla_templates": ["'"$SLA_TEMPLATE_ID"'"],
    "agent_type": "normal",
    "num_agents": 1,
    "cpu_arch": "x86-64",
    "os": "linux",
    "storage_min": 0,
    "req_resource": ["sensor_1"],
    "opt_resource": ["sensor_2"]
}' | jq -es 'if . == [] then null else .[] | .["resource-id"] end') &&
  log "OK" "service $SERVICE_ID created successfully" [ServiceManager] ||
  log "NO" "failed to create new service $SERVICE_ID" [ServiceManager]

# 3. check if service is categorized
SERVICE_ID=`echo $SERVICE_ID | tr -d '"'`
CATEGORY=$(curl -XGET "https://localhost/api/${SERVICE_ID}" -ksS -H 'content-type: application/json' -H 'slipstream-authn-info: super ADMIN' |
  jq -es 'if . == [] then null else .[] | .["category"] end') &&
  log "OK" "service $SERVICE_ID was categorized as $CATEGORY" [Categorizer] ||
  log "NO" "service $SERVICE_ID is not categorized" [Categorizer]

# 4. submit service-instance
LM_OUTPUT=$(curl -XPOST "http://localhost:46000/api/v2/lm/service" -ksS -H 'content-type: application/json' -d '{ "service_id": "'"$SERVICE_ID"'", "sla_template": "'"$SLA_TEMPLATE_ID"'"}') >/dev/null 2>&1
SERVICE_INSTANCE_IP=$(echo $LM_OUTPUT | jq -e 'if . == [] then null else .service_instance.agents[].url end') > /dev/null 2>&1
SERVICE_INSTANCE_IP=`echo $SERVICE_INSTANCE_IP | tr -d '\n'`
SERVICE_INSTANCE_ID=$(echo "$LM_OUTPUT" | jq -r ".service_instance.id")
if [[ ($SERVICE_INSTANCE_IP != null) && ($SERVICE_INSTANCE_IP != "") ]]; then
  log "OK" "service-instance launched in $SERVICE_INSTANCE_IP successfully" [LifecycleManager]
else
  log "NO" "failed to launch service-instance" [LifecycleManager]
fi

# 5. check QoS (provider) from service-instance
(curl -XGET "https://localhost/sm/api/${SERVICE_INSTANCE_ID}" -ksS |
  jq -es 'if . == [] then null else .[] | select(.status == 200) end') >/dev/null 2>&1 &&
  log "OK" "QoS provider checked service-instance $SERVICE_INSTANCE_ID successfully" [QoSProvider] ||
  log "NO" "QoS provider failed to check service-instance $SERVICE_INSTANCE_ID" [QoSProvider]

# 6. check if sla-agreement is created
SI_STATUS="created-not-initialized"
while [ "$SI_STATUS" = "created-not-initialized" ]; do
  sleep 5
  SERVICE_INSTANCE=$(curl "https://localhost/api/$SERVICE_INSTANCE_ID" -ksS -H 'content-type: application/json' -H 'slipstream-authn-info: super ADMIN')
  SI_STATUS=$(echo "$SERVICE_INSTANCE" | jq -re ".status")
  log "INFO" "service instance status = $SI_STATUS..." [LifecycleManager]
done
AGREEMENT_ID=$(echo "$SERVICE_INSTANCE" | jq -re ".agreement")
if [[ -n "$AGREEMENT_ID" && "$AGREEMENT_ID" =~ ^agreement/.*$ ]]; then
  log "OK" "agreement created successfully" [SLAManager]
else
  log "NO" "failed to create agreement" [SLAManager]
fi

# 7. check if qos-model (provider) is added
QOS_MODEL_ID=$(curl -XGET 'https://localhost/api/qos-model?$filter=service/href="'$SERVICE_ID'"' \
  -ksS -H 'content-type: application/json' -H 'slipstream-authn-info: super ADMIN' |
  jq -es 'if . == [] then null else .[] | .["qos-models"][0].id end') &&
  log "OK" "qos-model $QOS_MODEL_ID was created successfully" [QoSProvider] ||
  log "NO" "qos-model does not exist" [QoSProvider]

# 8. check COMPSs agent availability
log INFO "waiting for compps agent to boot..." [COMPSs]
sleep 25
COMPSs_AGENTS=$(curl "https://localhost/api/${SERVICE_INSTANCE_ID}" -ksS -H 'slipstream-authn-info: super ADMIN' | jq '.agents[] | (.url+":"+ (.ports[0]|tostring))' | tr -d '"')
for agent in ${COMPSs_AGENTS}; do
  curl -XGET http://${agent}/COMPSs/test 2>/dev/null &&
    log OK "agent ${agent} tested successfully" [COMPSs] ||
    log ERROR "failed to reach agent ${agent}" [COMPSs]
done

# 9. start an operation during 60 seconds
SHORT_SERVICE_INSTANCE_ID=$(echo "${SERVICE_INSTANCE_ID}" | cut -d '/' -f 2)
LM_OUTPUT=$(curl -XPUT "http://localhost:46000/api/v2/lm/service-instances/${SHORT_SERVICE_INSTANCE_ID}/der" -ksS -H 'content-type: application/json' -d '{
    "operation":"start-job",
    "ceiClass":"es.bsc.compss.agent.test.TestItf",
    "className":"es.bsc.compss.agent.test.Test",
    "hasResult":false,
    "methodName":"main",
    "parameters":"<params paramId=\"0\"><direction>IN</direction><stream>UNSPECIFIED</stream><type>OBJECT_T</type><array paramId=\"0\"><componentClassname>java.lang.String</componentClassname><values><element paramId=\"0\"><className>java.lang.String</className><value xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xsi:type=\"xs:string\">60</value></element></values></array></params>"
}')
if [[ ! $(echo "${LM_OUTPUT}" | jq -r ".error" 2>/dev/null) == "false" ]]; then
  log "NO" "failed to launch compss operation" [LifecycleManager]
else
  log "OK" "operation started successfully" [LifecycleManager]
fi

# 10. check if there are new service-operations-reports
REPORT_EXIST="false"
ATTEMPTS=1
while [ "$REPORT_EXIST" = "false" ]; do
  SERVICE_OPERATION_REPORTS=$(curl "https://localhost/api/service-operation-report" -ksS -H 'content-type: application/json' -H 'slipstream-authn-info: super ADMIN' | jq -es 'if . == [] then null else .[].serviceOperationReports | length end') >/dev/null 2>&1
  if ((SERVICE_OPERATION_REPORTS > 0)); then
    REPORT_EXIST="true"
    break
  fi
  log "INFO" "no service operation reports created yet" [COMPSs]
  ATTEMPTS=$ATTEMPTS+1
  if ((ATTEMPTS > 10)); then
    break
  fi
  sleep 1
done
if [[ $REPORT_EXIST == "true" ]]; then
  log "OK" "service operation reports created successfully" [COMPSs]
else
  log "No" "no service operation reports were created" [COMPSs]
fi

# 11. check if new agents are added to the service-instance by QoS enforcement
AGENTS_ADDED="false"
ATTEMPTS=1
while [ "$AGENTS_ADDED" = "false" ]; do
  NUM_AGENTS=$(curl "https://localhost/api/$SERVICE_INSTANCE_ID" -ksS -H 'content-type: application/json' -H 'slipstream-authn-info: super ADMIN' | jq -es 'if . == [] then null else .[].agents | length end') >/dev/null 2>&1
  if ((NUM_AGENTS > 1)); then
    AGENTS_ADDED="true"
    break
  fi
  log "INFO" "no agents added yet" [QoSEnforcement]
  ATTEMPTS=$ATTEMPTS+1
  if ((ATTEMPTS > 20)); then
    break
  fi
  sleep 1
done
if [[ $AGENTS_ADDED == "true" ]]; then
  log "OK" "agents added to service-instance successfully" [QoSEnforcement]
else
  log "No" "no agents were added" [QoSEnforcement]
fi

log "INFO" "Finished." [ServiceManagerTests]
