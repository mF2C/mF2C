#!/bin/bash -e

printf '\e[0;33m %-15s \e[0m Starting...\n' [TelemetryTests]

function log {
    text="$2"
    if [[ $1 == "OK" ]]
    then
        printf '\e[0;33m %-15s \e[32m SUCCESS:\e[0m %s \n' [TelemetryTests] "$text"
    else
        printf '\e[0;33m %-15s \e[0;31m FAILED:\e[0m %s \n' [TelemetryTests] "$text"
    fi
}

BASE_API_URL=`echo ${BASE_API_URL:="http://localhost:8181/v2"} | tr -d '"'`

### Test Telemetry operations
# test plugins
(curl -XGET "${BASE_API_URL}/plugins" -ksS | jq -e 'select(.plugins | length)' | grep -q 7 > /dev/null 2>&1 && \
    log "OK" "plugins entry exists") || \
        log "NO" "unable to get telemetry plugins entry" 

# test metricss
(curl -XGET "${BASE_API_URL}/metrics" -ksS | jq -e 'select(.metrics | length)' | grep -q 4 > /dev/null 2>&1 && \
    log "OK" "metrics entry exists") || \
        log "NO" "unable to get telemetry metrics entry" 

# test "create task" operation
(curl -XPOST "${BASE_API_URL}/user" -ksS -H 'content-type: application/json' -d '{
  "version": 1,
  "schedule": {
    "type": "simple",
    "interval": "1s"
  },
  "workflow": {
    "collect": {
      "metrics": {
        "/intel/psutil/load/load1": {},
      },
      "publish": [
        {
          "plugin_name": "file",
          "config": {
            "file": "/tmp/published_psutil"
          }
        }
      ],
      "publish": null
    }
  }
}'  > /dev/null 2>&1 && \
    log "OK" "task created successfully") || \
        log "NO" "failed to create new task"

