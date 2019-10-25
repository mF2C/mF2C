#!/bin/bash -e

printf '\e[0;33m %-15s \e[0m Starting...\n' [RecommenderTests]

function log {
    text="$2"
    if [[ $1 == "OK" ]]
    then
        printf '\e[0;33m %-15s \e[32m SUCCESS:\e[0m %s \n' [RecommenderTests] "$text"
    else
        printf '\e[0;33m %-15s \e[0;31m FAILED:\e[0m %s \n' [RecommenderTests] "$text"
    fi
}

BASE_API_URL=`echo ${BASE_API_URL:="http://localhost:46020/mf2c"} | tr -d '"'`

### Test Recommender operations
# test plugins

# test "trigger optimal for avg test" operation
(curl -XPOST "${BASE_API_URL}/optimal" -ksS -H 'content-type: application/json' -d '{
    "name": "compss-hello-world",
    "description": "hello world example",
    "resourceURI": "/compss-hello-world",
    "exec": "mf2c/compss-test:it2",
    "exec_type": "docker",
    "category": {
        "cpu": 0.0,
        "memory": 0.0,
        "disk": 0.0,
        "network": 0.0,
    }
}'  > /dev/null 2>&1 && \
    log "OK" "optimal triggered successfully") || \
        log "NO" "failed to trigger optimal"

# test "trigger analyse for avg_test" operation
(curl -XPOST "${BASE_API_URL}/analyse" -ksS -H 'content-type: application/json' -d '{
    "service_id": 'compss-hello-world',
    "ts_to": '1522144965',
    "ts_from": '1722144953',
    "analysis_id": '',
}'  > /dev/null 2>&1 && \
    log "OK" "analyse triggered successfully") || \
        log "NO" "failed to trigger analyse"

# test "trigger optimal for 2 parameters from snap" operation
(curl -XPOST "${BASE_API_URL}/optimal" -ksS -H 'content-type: application/json' -d '{
    "name": "test",
    "device_id": "092b7908-69ee-46ee-b2c7-2d9ae23ee298",
    "sort_order": ["memory", "cpu"],
    "telemetry_filter": False,
    "description": "test",
    "project": "mf2c"

}'  > /dev/null 2>&1 && \
    log "OK" "optimal for cpu and memory triggered successfully") || \
        log "NO" "failed to trigger optimali for cpu and memory"
