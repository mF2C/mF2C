# Resource Bootstrap

The resource bootstrap container performs non-trivial actions needed at initial deploy, such as provisioning
users and services.


## Usage

No action necessary, the container performs actions without user intervention. 


## CHANGELOG

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
