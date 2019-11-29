
# Discovery

The discovery component is part of the Resource Management block in the mF2C agent controller. Its main role is to allow a leader to advertise its presence using custom 802.11 beacons so that nearby agents can detect it.
## Usage

### API

The discovery component provides the following endpoints:

 - POST `/api/v1/resource-management/discovery/broadcast/` , DATA `{"broadcast_frequency":100, "interface_name":"wlan0", "config_file":"mF2C-VSIE.conf", "leader_id":"the_leader_ID"}` -> Start broadcasting

- PUT `/api/v1/resource-management/discovery/broadcast/` -> Stop broadcasting

- GET `/api/v1/resource-management/discovery/watch/` -> Start watching on leader side

- PUT `/api/v1/resource-management/discovery/watch/` -> Stop watching on leader side

- GET `/api/v1/resource-management/discovery/scan/<interface_name>` -> Get scan results

- POST `/api/v1/resource-management/discovery/join/` , DATA `{"interface":"wlan0" , "bssid":"aa:bb:cc:dd:ee:ff"}` -> Allow agent to associate with leader

- PUT `/api/v1/resource-management/discovery/join/` -> Allow agent to disassociate from leader

- GET `/api/v1/resource-management/discovery/watch_agent_side/` -> Start watching association to leader on the agent side

- GET `/api/v1/resource-management/discovery/my_ip/` -> Retrieve the IP address of the device

- POST `/api/v1/resource-management/discovery/dhcp/` ,  DATA `{"interface_name":"wlan0"}` -> Start the DCHP server on the leader side

- PUT `/api/v1/resource-management/discovery/dhcp/` -> Stop the DHCP server on the leader side

#### Examples



    "GET /api/v1/resource-management/discovery/my_ip/"

   Response:

     {'IP_address': '192.168.7.1'}

### Troubleshooting

## Known issues

- The Join operation (performed using wpa_supplicant) always outputs the following message: `Failed to connect to non-global ctrl_ifname: wlan0  error: No such file or directory` . This does not indicate an error. 

## CHANGELOG

### 1.7 (29/11/2019)

#### Added

 - Added retrieval of interface name from env variable for get_ip REST call.

### 1.6 (28/11/2019)

#### Added

 - Disabled pushing of default gateway from the leader side.

### 1.5 (23/9/2019)

#### Added

 - Added REST call to stop DHCP server

#### Changed

 - Changed base image in Dockerfile from debian:Jessie to python:3.7-slim-buster to improve the reliability of the service status check command used in the discovery code.

### 1.4 (18/9/2019)
#### Added

-   Added real leader ID in the beacon

#### Changed
 - Changed CIMI call in Watcher.py to deal with the fact that the discovery container is run with host network mode.
 
### 1.3 (10/9/2019)
#### Added 
-   Added get IP feature
-   Added DHCP feature
-   Added apt-get install firmware-ralink in Dockerfile (to make the WiFi dongle used in the testbed work)
#### Changed
### 1.2 (25/7/2019)
#### Added 
- Added GET REST call that returns an empty IP
#### Changed
### 1.1 (8/7/2019)
#### Added 
-   Added feature of updating status in device-dynamic
#### Changed
