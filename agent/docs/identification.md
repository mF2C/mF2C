# IDENTIFICATION

Responsible of acquiring and sharing with other modules both, the IDKey and deviceID.

## Usage

### API

- Endpoint `http://localhost:46060/api/v1/resource-management/identification/`
- POST `/registerDevice` -> acquire the IDKey and deviceID from the cloud agent web service. Returns operation status and error/success message
- GET `/requestID` -> returns the CIMIUsrID, IDKey and deviceID formatted as json

#### Examples

registering a new device:  
 ```  
    POST /registerDevice  
 ``` 

### Troubleshooting

## CHANGELOG

### v2 / ARMv2 (15.09.19)

#### Added

 - The incorporation of the mF2C_User and mF2C_Pass variables in the identification section allows to provide users with a more generic docker-compose file. Likewise, avoid including any information that refers to a specific user of the system, which allows to expand the distribution channels of the file, beyond the dashboard.

#### Changed

 - For a successful registration, the device must meet two requirements: i) before executing the agent for the first time, export the variables usr and pwd. The first will store the username registered in the system and the second the password associated with that username. ii) The device must be connected to the internet.
 Example:
 ```
export usr=your_username
export pwd=your_password
 ```
 - The user resource ID is not used to register devices anymore but the user credentials.
 - Fixed some minor errors.
