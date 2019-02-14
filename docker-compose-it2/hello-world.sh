curl \
--insecure \
--header "Content-type: application/json" \
--header "slipstream-authn-info: super ADMIN" \
--request POST \
--data '{
    "deviceID": "id2",
    "isLeader": false,
    "os": "Linux-4.13.0-38-generic-x86_64-with-debian-8.10",
    "arch": "x86_64",
    "cpuManufacturer": "Intel(R) Core(TM) i7-8550U CPU @ 1.80GHz",
    "physicalCores": 4,
    "logicalCores": 8,
    "cpuClockSpeed": "1.8000 GHz",
    "memory": 7874.2109375,
    "storage": 234549.5078125,
    "powerPlugged": true,
    "networkingStandards": "['eth0', 'lo']",
    "ethernetAddress": "[snic(family=<AddressFamily.AF_INET: 2>, address='127.0.0.1', netmask='255.255.255.0', broadcast='192.168.1.255', ptp=None), snic(family=<AddressFamily.AF_PACKET: 17>, address='02:42:ac:11:00:03', netmask=None, broadcast='ff:ff:ff:ff:ff:ff', ptp=None)]",
    "wifiAddress": "Empty",
    "agentType": "normal",
    "actuatorInfo": "test"
}' \
https://localhost/api/device

curl \
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
https://localhost/api/user

curl \
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
https://localhost/api/service

curl \
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
https://localhost/api/agreement


