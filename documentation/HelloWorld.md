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

#### Single container deployment

For now we tested the simple Hello World/People Java example mentioned in the [dataClay manual](https://github.com/mF2C/dataClay/blob/master/manual/dataClay-Manual.pdf). In it we have the model People->Person model with each person having a name and age, while people objects only have a name and the person objects inside it.

The actual steps of deploying it:
```
0. clone dataClay + create a hellopeople file/folder structure inside the repo (cfgfiles, java, stubs)

1. cd $GIT/dataClay/orchestration

2. docker-compose rm

3. docker-compose up # [wait till LANG_PYTHON msg logged]

4. cd $GIT/dataClay/hellopeople

# create user
5. ../tool/dClayTool.sh NewAccount Kogi Password

# as the created user allow yourself access to the dataset peopleDS and create it if needed
6. ../tool/dClayTool.sh NewDataContract Kogi Password peopleDS Kogi

# compile the model first
# compile to other location than application latter on - no confusion between stub and original
7. javac -d stubs java/src/model/*.java

# create the namespace to be used and fill it with the generated models
8. ../tool/dClayTool.sh NewModel Kogi Password peopleSpace ./stubs java

# overwrite the simple models with their stubs - no confusion latter on
9. ../tool/dClayTool.sh GetStubs Kogi Password peopleSpace ./stubs

# compile the application with the client JAR and stubs!
10. javac -d java/bin -cp ./stubs:../tool/lib/dataclayclient.jar java/src/application/HelloPeople.java

# test the app
11. java -cp java/bin:./stubs:../tool/lib/dataclayclient.jar application.HelloPeople XLAB Kogi 18
```

### Installing and configuring COMPSs to the Edge and Cloud

### Deploying the application, configuration



