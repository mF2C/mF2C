# dataClay (dcproxy)

The mF2C system uses dataClay to store, distribute and synchronize infrastructure resources.

dataClay is a distributed data store that enables applications to store and access objects in the same format they have in memory, and executes object methods within the data store. These two main features accelerate both the development of applications and their execution. 

In addition, dataClay enables the execution of code next to the data. By moving computation close to the data, dataClay reduces the amount and size of data transfers between the application and the data store, thus improving performance of applications.

More documentation about dataClay can be found at 
<https://www.bsc.es/dataClay>

For mF2c infrastructure we have defined three components for dataClay dcproxy, logicmodule1, ds1java1

It is very important to have same versions in all sub-components.

## dcproxy component

The dataclay-proxy component is actually an application that uses dataClay to store, retrieve, modify and distribute objects. 

mF2c resources are defined at <https://github.com/mF2C/dataClay/tree/master/data_management/model/src/CIMI>

CIMI component calls dcproxy for each supported acction. 

The dataclay-proxy application is also responsible of registering needed information in dataClay to allow synchronization between agents. This is done through the Agent resource. 

## Usage

### API

Check following wiki to change mF2C resources in dataClay:

<https://github.com/mF2C/dataClay/wiki/dataClay-Mf2c---a-developers-guide-for-modelling-CIMI-resources>

CIMI component calls dcproxy for each supported acction. 


| CIMI action  | dataclay-proxy function |
| ------------- | ------------- |
| Add (create)  | void create(final String type, final String id, final String data)   |
| Read | String read(final String type, final String id)  |
| Edit (update) | String update(final String type, final String id, final String data)  |
| Delete | delete(final String type, final String id)  |

where:
- type: resource type (device, device-dynamic, ...)
- id: resource CIMI id
- data: JSON with CIMI data of the resource 
- String return: JSON data with updated or read resource

Note that resources are JSON objects. 

Agent resource fields used by dataClay:

- device_ip: The dataClay of an agent is identified by provided ip 
- leader_ip: All objects of resources marked as @ReplicateInLeader stored in current agent or current children will be automatically replicated and synchronized in leader agent
- backup_ip:All objects of resources marked as @ReplicateInLeader stored in current agent will be automatically replicated and synchronized in backup agent
- childrenIPs: dataClay uses this field to detect if some agent left.

Any update of those fields will move and synchronize objects automatically. 

### Troubleshooting

## CHANGELOG

### 2.24 (27.09.2019)

#### Added

 - Healthcheck
 - Implemented secure inter-dataClay communication through traefik

#### Changed





