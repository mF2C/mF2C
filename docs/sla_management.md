# SLA Management

The SLA Management is a lightweight implementation of an SLA system, inspired by the
WS-Agreement standard. It evaluates the QoS of the services deployed in mF2C.

## Usage

SLA Management evaluates services by means of an SLA document, a JSON file that declares
the type of service and the guarantees that the service offer to the client.

In mF2C, two metrics are supported:

* Availability (%). The availability is measured as the percentage where at least 
  one of the containers executing the service is alive.
* ExecutionTime (ms). It is the response time of requests to services deployed on
  mF2C. COMPSs services are supported automatically, while non-COMPSs services must
  write a ServiceOperationReport to record the execution time of a request.

In a complete lifecycle, a service be associated to or more SLA templates. When launching
a service, the request may contain the ID of a template, which will be used as a base
to generate an agreement; i.e., the agreement is quite similar to the template, 
but (at least) filling the client field with the user executing the service.

For the SLA Management to evaluate an agreement correctly, the guarantees must comply with
the following:

- Maximum one guarantee on the availability. The variable in the constraint must be named
  `availability`. There must be an entry in the variables array specifying the period
  (in seconds) to calculate the availability. In the example below, availabilities are 
  calculated over period of 10 minutes.
- One guarantee for each operation to be evaluated its execution time. The variable
  in the constraint must be named `execution_time` and the name of the guarantee must 
  match the operationName used in the ServiceOperationReport. For COMPSs services,
  COMPSs writes ServiceOperationReports using the fully qualified classname plus the 
  method name.

Example: 

```
{
    "name": "Agreement-Test",
    "state": "started",
    "details":{
        "id": "agreement-test",
        "type": "agreement",
        "name": "Agreement-Test",
        "provider": { "id": "mf2c", "name": "mF2C Platform" },
        "client": { "id": "c02", "name": "A client" },
        "creation": "2019-01-16T17:09:45.01Z",
        "variables": [
            {
                "name": "availability",
                "aggregation": {
                    "window": 600,
                    "type": "average"
                }
            }
        ],
        "guarantees": [
            {
                "name": "availability",
                "constraint": "availability > 90"
            },
            {
                "name": "es.bsc.compss.agent.test.Test.main",
                "constraint": "execution_time < 100"
            }
        ]
    }
}

```

### API

API description provided here : [API Readme](https://github.com/mF2C/SlaManagement/blob/master/README.md#usage)

#### Examples

Please see README above for examples. For a mF2C lifecycle example, 
check the [hello-world script](https://github.com/mF2C/mF2C/blob/master/docker-compose/hello-world.sh).

### Troubleshooting


## CHANGELOG

### v0.8.1 - 2019-08-09

#### Changed

* Fix assessment panic due to CIMI deleting empty maps

### v0.8.0 - 2019-07-19

#### Changed

* Refactor agreement model and assessment to allow richer metrics definition

#### Added

* Calculation of availability

