# mF2C Microagent

The mF2C Microagent is an IoT ready distribution of the mF2C Agent. This software stack has been simplified and optimized to be executed in small singleboard ARM devices like the Raspberry Pi.

## Connectivity

When installed for the first time, the microagent requires an internet connection so that the device can be validated with mF2C.

After that, if there are no other mF2C Agents in the vicinity that can act as leaders, **the microagent will default its leader to the mF2C Cloud Agent**.

**_Microagents cannot be leaders!_**


## Installation

### From [nuvla.io](https://nuvla.io)

 1. go to [nuvla](https://nuvla.io)
 2. create an account and login
 3. confirm that you can see your Docker Swarm infrastructure from Nuvla
     1. if your Raspberry Pi is running on Swarm mode, then you can add it and see it from the [Infrastructures](https://nuvla.io/ui/infrastructures) tab, or
     2. if your Raspberry Pi is already a NuvlaBox, then you can see it (or transform it into one) from the [Edge](https://nuvla.io/ui/edge) panel.
 4. go to the [App Store](https://nuvla.io/ui/apps) and search for "mF2C Microagent"
 5. click **launch** and select the corresponding credential for your infrastructure
 6. set your mF2C username and password in the environment variables
 7. click **launch** and wait for the application to be ready
 
 
### Manually

 1. `ssh` into your Raspberry Pi
 2. make sure you have [Docker](https://docs.docker.com/install/linux/docker-ce/debian/) and Docker Compose installed 
 3. download the latest microagent compose file from https://github.com/mF2C/mF2C/blob/master/microagent/docker-compose.yml
 4. set your mF2C credentials as environment variables: `export MF2C_USER=<youruser>` and `export MF2C_PWD=<yourpassword>`
 4. in the same directory as the downloaded compose file, run `docker-compose up -d`
 5. wait a few minutes. The Microagent will be ready once you can access http://localhost:46000/api/v2/lm.html
 
 
## Uninstall

### From [nuvla.io](https://nuvla.io)

 1. go to [nuvla](nuvla.io)
 2. go to the [dashboard](https://nuvla.io/ui/dashboard)
 3. find the Microagent you want to uninstall and click stop
 
### Manually
 
 1. `ssh` into your Microagent's device
 2. find the installation folder, where your original compose file is
 3. run `docker-compose down -v`
 
 
## Troubleshooting

 - **installation time**: if it is the first time you're installing the mF2C Microagent in a device, it might happen that it will take up to 10 minutes to finish the installation. Just keep checking for `docker ps`, until you see the `mf2c_micro_lifecycle` container running
 
 - **installation stuck**: sometimes, the installation might look to be taking longer that expected, in that case, do the following:
   - run `docker-compose logs` (from the same directory as the installation), and make sure there are no uncaught exceptions causing the installation to wait forever. If that's the case, please report the issue as a [GitHub ticket](https://github.com/mF2C/mF2C)
   - if there are no exceptions and the logs simply say that it is waiting for `deviceID`, then most likely you have not passed your mF2C credentials, and the microagent is just waiting for that user to be created in the system (through the Cloud Agent). Make sure you pass a valid mF2C user to the installation (see above)
  
 - **vpn client constantly rebooting**: if this happens, it means you won't be able to establish a connection to the mF2C VPN network, thus taking the risk of having an unusable device whenver there are no leaders in the vicinity. This issue usually happens when you are installating the microagent in a device that already had this software in the past. If that's the case, please make sure you clean up any old artifacts from the previous installations with `docker-compose down -v` (from the installation folder)