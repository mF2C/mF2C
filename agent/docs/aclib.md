# AC Library

## Usage
The library provides utility functions to implement the mF2C data security policy and for the processing of identity token.  

The mF2C data security policy defines three different message security levels:

*public* - for data not requiring protection

*protected* - for data which needs to be integrity protected but is not confidential

*private* - for data which needs both integrity and confidentiality protection

The library uses a consistent data packaging structure to encapsulate messages and supporting metadata.  It leverages existing mF2C PKI and the CAU security middleware to provide credentials for signing and encrypting the message payloads according to the security level specified by caller.  The library adopts the Json Web Signature (JWS - [RFC 7515](https://tools.ietf.org/html/rfc7515)) specification for signing Protected messages and the Json Web Encryption (JWE - [RFC 7516](https://tools.ietf.org/html/rfc7516)) one for encrypting Private confidential messages.  Encrypted message tokens protect data payload confidentiality beyond the communication endpoints (as in TLS) as a recipient needs to use its Private Key issued by mF2C PKI to decrypt a token's content encryption key before it can successfully retrieve the message payload.  For consistency purposes, the library also provides a method to encapsulate public messages as unsigned JWSs.  Callers may optionally compress the payload to optimise its size.

In addition to the above, the library also provides functionalities for creating and verifying Agent self-signed identity Json Web Tokens (JWT - [RFC 7519](https://tools.ietf.org/html/rfc7519)).  An Agent asserts its own identity to another Agent by presenting a JWS with JWT claims in the payload.  The JWS is signed using the issuing Agent's Private Key associated with its mF2C X.509 certificate.  The receiving Agent (audience) can authenticate the claims by validating the signature using the Public Key retrieved from the CAU middleware and comparing the asserted deviceID (claim) against the issuer's deviceID.

The AC library is deployed as an Agent block and runs an TCP socket server to listen to calls for creating a message/identity token and extracting message payload from/verifying a provided token from other blocks within the same Agent. (Please see the AC Lib.pdf in the resources folder for a presentation on its features and usages.) The library in turn uses the local [CAU-client](https://github.com/mF2C/cau-client) block as an entry point the the CAU middleware for retrieving senders' and recipients' public keys.

## Building the Java library

The library is packaged with a self-contained fat jar with all depended libraries.  The jar is located in the target folder and the javadoc in the target\site\apidocs folder.  You can use Maven to build a fat jar with all dependencies using:

		package javadoc:javadoc -Dmaven.test.skip=true

It is recommended that you select the skip test option as the tests may not run correctly in your own environment. 


## Building the Docker container

This project provides a self-contained fat jar with all depended libraries.  It is assumed that you have [Docker](https://docs.docker.com/) installed on your platform.  Build the Docker file to create the image and container for running the AC Lib TCP server.  The Docker file contains default values which you may optionally over-ride to match your deployment environment:
  
*aclib server port* - The port that AC Lib TCP server listens at, default value is 46080

*cau-client port* - the port that the Agent's CAU-Client listens at, default value is 46065.  The CAU-client should run in the same network as the AC Lib as it is just another block of the same Agent.

The Docker file exposes port 46080 on the host for the acLib server port.  If the latter is changed, please also update this parameter.

## Running

You can run the library from the command line

	java -jar mf2c-aclib-jar-with-dependencies.jar [port] [cau-client port]

You can override all two parameters or just the cau-client port.  The application accepts 0 (using all default values), 1 (overriding cau-client port value) or 2 (over-riding all two values) arguments.


### API
 
ACLib runs a TCP server which listens at port 46080 for requests.

#### Examples

See AC Lib.pdf under the resources folder for more details.  Or use this [on-line version](https://github.com/mF2C/aclib/blob/master/src/main/resources/AC%20Lib.pdf).


### Troubleshooting

## CHANGELOG

### 1.0 (29/07/2019) first release

#### Added

#### Changed