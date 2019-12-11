# Resource Bootstrap

The resource bootstrap container performs non-trivial actions needed at initial deploy, such as provisioning
users and services.


## Usage

No action necessary, the container performs actions without user intervention. 


## CHANGELOG

### 2.8.5 (2019-12-11)

#### Added

 - Submit SLA templates instead of agreements when bootstrapping.

### 2.7.5 (2019-12-10)

#### Added

 - Add a default SLA template to all services.

### 2.7.4 (2019-12-10)

#### Added

 - Add the `isCloud` environment variable to allow toggling bootstrapping operations.

### 2.7.3 (2019-12-05)

#### Added

 - Bootstrap the video analysis service for the microagent.

### 1.4.1 (2019-10-24)

#### Added

 - Force-enable the initial user.


### 1.3.0 (2019-10-03)

#### Added

 - Bootstrap an initial user if one doesn't exist.
 - Provision the JWT session template.


### 1.0.0 (2019-07-18)

#### Added

 - Provision the sensor-manager and emmy-server services.
