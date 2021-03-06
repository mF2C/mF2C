# dataClay (ds1java1)

The mF2C system uses dataClay to store, distribute and synchronize infrastructure resources.

dataClay is a distributed data store that enables applications to store and access objects in the same format they have in memory, and executes object methods within the data store. These two main features accelerate both the development of applications and their execution. 

In addition, dataClay enables the execution of code next to the data. By moving computation close to the data, dataClay reduces the amount and size of data transfers between the application and the data store, thus improving performance of applications.

More documentation about dataClay can be found at 
<https://www.bsc.es/dataClay>

For mF2c infrastructure we have defined three components for dataClay dcproxy, logicmodule1, ds1java1

It is very important to have same versions in all sub-components.


## The ds1java1 component

dataClay architecture is based on multiple Data Services. A Data Service is deployed as a set of multiple backends. Any of these backends handles a subset of objects as well as the execution requests aiming to them. 

For mF2C system we have created a docker image with already registered model. 

## Usage

### API

dataClay API can be found at
<https://www.bsc.es/sites/default/files/public/bscw2/content/software-app/technical-documentation/dataclay-1.0_0.pdf>

### Troubleshooting

## CHANGELOG

### 2.29 (02.12.2019)

#### Changed

 - Modified exception checking during propagation of updates

### 2.28 (21.11.2019)

#### Changed

 - Removed control to check if an IP in Agent resource children IPs field is reachable

### 2.27 (21.10.2019)

#### Added

 - ServiceContainerMetric is replicated and field stop_time is synchronized 

### 2.26 (18.10.2019)

#### Changed

 - Service-operation-report 'operation_id' field is now synchronized

### 2.25 (17.10.2019)

#### Added

 - Service-operation-report is replicated and synchronized in leaders

### 2.24 (27.09.2019)

#### Added

 - Healthcheck
 - Implemented secure inter-dataClay communication through traefik

#### Changed





