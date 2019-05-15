#!/usr/bin/env bash

if [[ "$1" == "--include-tests" ]]
then
	tests_folder="./tests/"
	tests=`ls $tests_folder`
	for tester in $tests
	do
		eval $tests_folder$tests
	done
else
	echo -e "\n    Use --include-tests to run all scripts in the 'tests' folder    \n"
fi

sla_template_id=$(curl \
--insecure \
--header "Content-type: application/json" \
--header "slipstream-authn-info: super ADMIN" \
--request POST \
--data '{
    "name": "compss-hello-world",
    "state": "started",
    "details":{
        "type": "template",
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
https://localhost/api/sla-template | jq -r '.["resource-id"]')

service_id=$(curl \
--insecure \
--header "Content-type: application/json" \
--header "slipstream-authn-info: super ADMIN" \
--request POST \
--data '{
    "name": "compss-hello-world",
    "exec": "mf2c/compss-test:it2",
    "exec_type": "compss",
    "agent_type": "normal",
    "sla_templates": ["'"$sla_template_id"'"]
}' \
https://localhost/api/service | jq -r '.["resource-id"]')

service_instance=$(curl \
--insecure \
--header "Content-type: application/json" \
--request POST \
--data '{
    "service_id": "'"$service_id"'"
}' \
http://localhost:46000/api/v2/lm/service | jq -r .message)

echo "SLA template: $sla_template_id"
echo "Service: $service_id"
echo "Service instance: $service_instance"
