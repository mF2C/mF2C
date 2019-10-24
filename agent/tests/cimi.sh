#!/bin/bash -e

printf '\e[0;33m %-15s \e[0m Starting...\n' [CIMITests]

function log {
    text="$2"
    if [[ $1 == "OK" ]]
    then
        printf '\e[0;33m %-15s \e[32m SUCCESS:\e[0m %s \n' [CIMITests] "$text"
    elif [[ $1 == "WARN" ]]
    then
        printf '\e[0;33m %-15s \e[33m WARNING:\e[0m %s \n' [CIMITests] "$text"

    else
        printf '\e[0;33m %-15s \e[0;31m FAILED:\e[0m %s \n' [CIMITests] "$text"
    fi
}

BASE_API_URL=`echo ${BASE_API_URL:="https://localhost/api"} | tr -d '"'`

### Test CIMI operations
# test CEP
(curl -XGET "${BASE_API_URL}/cloud-entry-point" -ksS | jq -e 'select(.baseURI != null)' > /dev/null 2>&1 && \
    log "OK" "cloud-entry-point exists") || \
        log "NO" "unable to get cloud-entry-point" 

# test 403 operation
(curl -XGET "${BASE_API_URL}/credential" -ksS | jq -e 'select(.status == 403)' > /dev/null 2>&1 && \
    log "OK" "user authorization working properly") || \
        log "NO" "user authorization not working: public access to restricted resource"

# test 405 for invalid collection
(curl -XGET "${BASE_API_URL}/invalid-collection" -ksS | jq -e 'select(.status == 405)' > /dev/null 2>&1 && \
    log "OK" "correct 405 on invalid resource collection") || \
        log "NO" "incorrect response: did not receive 405 for invalid resource collection"

# test 404 for invalid resource
(curl -XGET "${BASE_API_URL}/user/unknown" -ksS -H 'slipstream-authn-info: internal ADMIN' | jq -e 'select(.status == 404)' > /dev/null 2>&1 && \
    log "OK" "correct 404 for non-existent user") || \
        log "NO" "incorrect response: did not receive 404 for non-existent user"

USER=$(export LC_CTYPE=C; cat /dev/urandom | tr -dc "[:alpha:]" | head -c 8)
# test "create user" operation
(curl -XPOST "${BASE_API_URL}/user" -ksS -H 'content-type: application/json' -d '{
    "userTemplate": {
        "href": "user-template/self-registration",
        "password": "testpassword",
        "passwordRepeat" : "testpassword",
        "emailAddress": "testuser@testemail.com",
        "username": "'$USER'"
    }
}' | jq -e 'select(.status == 201)' > /dev/null 2>&1 && \
    log "OK" "user $USER created successfully") || \
        log "NO" "failed to create new user $USER"

# verify creating same user results in conflict (409)
response=$(curl -XPOST "${BASE_API_URL}/user" -ksS -H 'content-type: application/json' -d '{
    "userTemplate": {
        "href": "user-template/self-registration",
        "password": "testpassword",
        "passwordRepeat" : "testpassword",
        "emailAddress": "testuser@testemail.com",
        "username": "'$USER'"
    }
}')

(echo "$response" | jq -e 'select(.status == 409)' > /dev/null 2>&1 && \
    log "OK" "user $USER cannot be created a second time") || \
        (echo "$response" | jq -e 'select(.status == 400)' > /dev/null 2>&1 && \
            log "WARN" "user $USER cannot be created a seconds time, but got the wrong HTTP error") || \
        log "NO" "no error or wrong error when trying to create $USER a second time"

# test "create resource" operation
ID=`curl -XPOST "${BASE_API_URL}/user-profile" -ksS -H 'slipstream-authn-info: internal ADMIN' -H 'content-type: application/json' -d '{
    "service_consumer": true,
    "resource_contributor": false,
    "device_id": "some-device"
}' | jq -e -r '.["resource-id"]'` && \
    log "OK" "created new resource $ID successfully" || \
        log "NO" "failed to create new resource"

# test "retrieve resource" operation
(curl -XGET "${BASE_API_URL}/user/${USER}" -ksS -H 'slipstream-authn-info: internal ADMIN' | jq -e "select(.id == \"user/$USER\")" > /dev/null 2>&1 && \
    log "OK" "successfully retrieved resource by ID") || \
        log "NO" "failed to get resource by ID"

# test "query with filter" operation
(curl -XGET ${BASE_API_URL}'/user?$filter=id="user/nonExistent"' -ksS -H 'slipstream-authn-info: internal ADMIN' | jq -e "select(.count == 0)" > /dev/null 2>&1 && \
    log "OK" "resource filtering is working") || \
        log "NO" "failed perform a query with filters"

# test "update resource" operation
(curl -XPUT "${BASE_API_URL}/${ID}" -ksS -H 'slipstream-authn-info: internal ADMIN' -H 'content-type: application/json' -d '{
    "service_consumer": false,
    "resource_contributor": true,
    "device_id": "some-device"
}' --fail > /dev/null 2>&1 && \
    log "OK" "resource $ID update successfully") || \
        log "NO" "failed to update resource"

# test "delete resource" operation
(curl -XDELETE "${BASE_API_URL}/user/$USER" -ksS -H 'slipstream-authn-info: internal ADMIN' | jq -e 'select(.status == 200)' > /dev/null 2>&1 && \
    log "OK" "user $USER deleted successfully") || \
        log "NO" "failed to delete user $USER"

