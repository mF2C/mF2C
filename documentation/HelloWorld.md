# mF2C hello world example

This document will provide you the documentation to set up the minimal set of tools to run mF2C.

## The concept of Hello World example
mF2C is the Fog to Cloud platform that provide a specific set of tools to the developer. More basic details of the mF2C can be studied [here](http://www.mf2c-project.eu/). The most basic tools that mF2C application developers can use are [COMPSs](https://github.com/mF2C/COMPSs) and [dataClay](https://github.com/mF2C/dataClay). This document will drive you through the installation and configuration of tools that provide mF2C functionalities. 

***A minimal Hello World example is***:

 * ***Store data***: Storing a simple "test string" into the DataClay at the Edge or Cloud level.
 * ***Process the data***: Create a task, that will calculate the length of the "test" string and deploy it to COMPSs
 * ***Store result***: Store the processed data to dataClay
 * ***Visualise***: Use web server in the cloud that retrieves "data" from the Cloud and displays content of the data and lenth of the string.

 The ```python``` representation of the usecase:

 ```
 # Store the data
 data = "test string"

 # Initiate processing job and store
 datalen = len(data)

 #show the data
 print ("The data is " + data + " and its length is "+ datalen+ " characters"  )

 ```


To show all mF2C functionality the minimal configuration of mF2C deployment uses one Edge device (for example rPI) and one Cloud instance. 

### Installing and configuring DataClay to the Edge and Cloud

### Installing and configuring COMPSs to the Edge and Cloud

### Deploying the application, configuration



