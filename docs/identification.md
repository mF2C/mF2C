# IDENTIFICATION

Responsible of acquiring and sharing with other modules both, the IDKey and deviceID.

## Usage

### API

- Endpoint `http://localhost:46060/api/v1/resource-management/identification/`
- POST `/registerDevice`, DATA -> acquire the IDKey and deviceID from the cloud agent web service. Returns operation status and error/success message
- GET `/requestID` -> returns the CIMIUsrID, IDKey and deviceID formatted as json

#### Examples

registering a new device:  
  
    POST /registerDevice  
    DATA:  
        {  
             "usr": "user_username",  
             "pwd": "user_password"  
        }  
    *Data is optional when the agent has been obtained through the dashboard  

### Troubleshooting

## CHANGELOG

### v2 / ARMv2 (31.07.19)

#### Added

 - In scenarios in which users have obtained the agent through a different method than the dashboard, now they can also register devices using their user credentials.  

#### Changed

 - The IDKey is not used to register devices anymore but the CIMIUsrID or the user credentials.
 - The requestID output now includes the CIMIUsrID.
 - Fixed some minor errors.




