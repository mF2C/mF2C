#!/usr/bin/env bash

user_id=$(curl \
--insecure \
--header "Content-type: application/json" \
--header "slipstream-authn-info: super ADMIN" \
--request POST \
--data '{
    "userTemplate": {
        "href": "user-template/self-registration",
        "password": "testpassword",
        "passwordRepeat" : "testpassword",
        "emailAddress": "test@gmail.com",
        "username": "carpio"
    }
}' \
https://localhost/api/user | jq -r '.["resource-id"]')

service_id=$(curl \
--insecure \
--header "Content-type: application/json" \
--header "slipstream-authn-info: super ADMIN" \
--request POST \
--data '{
    "name": "compss-hello-world",
    "exec": "mf2c/compss-test:it2",
    "exec_type": "compss",
    "agent_type": "normal"
}' \
https://localhost/api/service | jq -r '.["resource-id"]')

agreement_id=$(curl \
--insecure \
--header "Content-type: application/json" \
--header "slipstream-authn-info: super ADMIN" \
--request POST \
--data '{
    "name": "compss-hello-world",
    "state": "started",
    "details":{
        "id": "a02",
        "type": "agreement",
        "name": "compss-hello-world",
        "provider": { "id": "mf2c", "name": "mF2C Platform" },
        "client": { "id": "c02", "name": "A client" },
        "creation": "2018-01-16T17:09:45.01Z",
        "expiration": "2019-01-17T17:09:45.01Z",
        "guarantees": [
            {
                "name": "TestGuarantee",
                "constraint": "execution_time < 10"
            }
        ]
    }
}' \
https://localhost/api/agreement | jq -r '.["resource-id"]')

service_instance=$(curl \
--insecure \
--header "Content-type: application/json" \
--request POST \
--data '{"service_id": "'"$service_id"'", "agreement_id": "'"$agreement_id"'", "user_id": "'"$user_id"'"}' \
http://localhost:46000/api/v2/lm/service | jq -r .message)

echo "User submitted: $user_id"
echo "Service submitted: $service_id"
echo "Agreement submitted: $agreement_id"
echo "$service_instance"