# CAU-Client

## Description

This application supports the agent registration and other security processes like the creation/extraction/validation of message and identity tokens.  The CAU client is an internal block of an Agent and is deployed as part of the Agent.  It communicates with the other Agent blocks over private Docker network and with the external CAU middleware via HTTPs.

## Usage:

### API

The CAU-client runs a TCP server at <host>:46065

### Examples

The CAU-client offers two functions:

* get Agent certificate - during the Agent initialisation phase, the Policy block (in a full Agent) or the initialisation script (in a micro Agent) uses this function to obtain an Agent certificate from the mF2C Trusted CA service.  The function takes in three arguments: 

	- the new Agent's device ID, 
	- the detected Leader's device ID and 
	- the ID Key of the human owner of the device hosting the new Agent.  
	
Here is an example request message which needs to be UTF-8 encoded and terminates with a \n:

	detectedLeaderID=0f848d8fb78cbe5615507ef5a198f660ac89a3ae03b95e79d4ebfb3466c20d54e9a5d9b9c41f88c782d1f67b32231d31b4fada8d2f9dd31a4d884681b784ec5a,deviceID=c6968d75a7df20e2d2f81f87fe69bf0b7dd14f4a22cca5f15ffc645cb4d45944bfdc7a7a970a9e13a331161e304a3094d8e6e362e88bd7df0d7b5473b6d2aa80,IDkey=12345

The CAU-Client generates an RSA keypair (2048 length) and uses it to build a Certificate Signing Request (CSR) which it sends to the CAU together with the three arguments.  The CAU first validates the IDKey against the mF2C Cloud CIMI instance before getting the CA to sign the CSR.  The CAU-Client, on receiving the signed certificate, stores this locally within the Agent before returning an 'OK' message to the caller.  The Agent certificate is used by other Agent blocks as a credential, e.g. as the server certificate by Traefik, for SSL handshake by the VPN-client.

* get Agent public key - The public key associated with the Agent's certificate is used by the [ACLib](https://github.com/mF2C/aclib) block to implement policy based data security and to create/validate identity token for authenticating an Agent's identity.  The function takes in an Agent's device ID which the CAU-Client sends to the CAU middleware to get the associated public key.  Here is an example request message which needs to be UTF-8 encoded and terminates with an \n:

	getpubkey=3b95e79d4ebfb3466c20d54e5615507ef5a198f660ac89a3ae03b95e79d4ebfb3466c20d54e9a5d9b9c41f88c782d1f67b32231d31b4fada8d2f9dd31a4d8846df0d7b5473b6d2aa80
	
The retrieved public key is in PEM format and here is an example:

	-----BEGIN RSA PUBLIC KEY-----
	MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAre9dOvFbyVqX5zDNxsn5
	XYWI4FTXlGjWEViqN41HDYK7f41VibuRYYWqjdUqKsSmNFJaIw05ZI7l7/aXp/6A
	iDfd9xiO6e4tMaF4H0BczDtRUUzFgReCqkkZjOQSDTbuqSOoT4JqOaE3S9npfY2S
	x45/LaRNVCQaycgCKve/A/ajeq9boFu/bPLhzHdrSiO+CsY094p5219Km99wpfXq
	J8JS/AelU9zpsNbbWzt9OV9Xi6tTnL6CwDhp5JS3d4K0rwzA6JFlqyWQAC1bTGUf
	nC43tDAacp8h31xsx1ux1CQfm6ADK6dg6vdVd8C9+OJof0x/05gI0zhX4oeuv+Aw
	tQIDAQAB
	-----END RSA PUBLIC KEY-----

## How to run:

For the IT2 demo, the CAU-client socket server runs on port 46065.  Both the Cloud CAU and local CAU ip:port are expected to be passed in as application arguments on launching the application. The agent's private key and X509 certificate are written to the shared file volume pkidata.  Both Traefik and VPN-Client will pick up the credentials and use the certificate for SSL.

	java -jar cau-client.jar 127.0.0.1:46400 127.0.0.1:46410 

The CAU client is bundled with the Fog and Untrusted CA certificates which are used as appropriate in the certificate path for the newly signed certificates.  The Fog CA issues certificates to mF2C components like the CAU and the Untrusted CA issues certificates to mF2C Agents. 

### Troubleshooting

Make sure you send a EOL signal, e.g. '\n' to the server to indicates end of transmission.

## CHANGELOG

### 2.0 (29/07/2019)

Rewritten from IT1 version.  CAU-Client now runs a TCP-server to listen to requests from other blocks in the Agent. 

#### Added

 - The get public key function to support ACLib operations.

#### Changed

 - The get certificate function now takes in 3 arguments: deviceID, detectedLeaderID, IDkey.
 - The Agent's device ID, signed certificate and private key is written to /pkidata 
 
### 2.1 (28/08/2019)

#### Changed
 - removed the IDKey parameter for the get cert operation.  Identification block validates this IDKey upstream.
 - removed commented out redundant code
 - updated code comments for Javadoc

