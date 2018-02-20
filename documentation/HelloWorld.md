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

<a name="dataclay"></a>
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
***Remaining issues with Hello People:***
* How to restart the deployment after stop without data loss. With ***docker-compose rm*** we reset the state to no data and users in dataClay but with only ***docker-compose up*** we want to create already existing environments, which causes the docker services to crash.
* When trying the same with ***python***, we get ***Error Code: NAMESPACE_NOT_EXIST*** for step 8. While for Java it is created at that time. Also tried to run the prepared mf2c_model python files (they should be needed for the demo to run, rgiht?), but no success till now. Is there something else needed to be done for python classes?
* No documentation about ***global.properties***
* We will need dataClay to be compatible with rPi (***ARM arhitecture***). Currently the avaible docker images are probably just for x86-64 arhitectures due to previous development needs. The docker-compose succeds only with postgress images on rPi (orchestration_ds1postgres_1 and orchestration_lmpostgres_1), while the remainder finishes with errors and exit 1 codes (, orchestration_ds1java_1, orchestration_logicmodule_1, orchestration_ds1pythonee_1)

***Other issues:***
* Is it possible to set up two dataclay dockers and configure sync between this? For example, one docker on agent and one in cloud.

#### DataClay developer team answers and comments:

Please note down the answers into the readme, not just into slack.

* I think it was said, that all issuses are already documented and just not yet in focus
* 2 dockers issue: ATM to test that you will need to orchestrate as usual in one place, and then set up DS2 + its Postgres in another place, when you boot all those dockers, the LogicModule will track both DS (DataServices) and data could be accessed from clients either in the cloud or in the agent. We don't have documentation on deployments (yet).main idea is: docker-compose.yml has, right now, a deployment with: [logicmodule, lmpostgres, ds1postgres, ds1java, ds1pythonee]

<a name="compss"></a>
### Installing and configuring COMPSs to the Edge and Cloud

Testing COMPSs docker iamge was straightforward, since the [Readme](https://github.com/mF2C/COMPSs/blob/master/README.md) was quite clear. We also succeded deploying "new" code and creating custom image. For testing we used the Java [samples from BCS](http://compss.bsc.es/projects/bar/wiki/Applications)).

#### Single container deployment

This are the steps were we succeeded making a new image with minimal changes to the docker image. If there is a more elegant way to do it or if we are doing sthg wrong, please note it down.

```
0. Prepare 2 bash shells (1st for execution and 2nd for distribution of our files)

1. Go to 1st  bash shell

2. Donwload and run the COMPSs matmul image (basic COMPSs installation + matrix multiplication example):
    docker run -it -p 8888:8080 albertbsc/compss-matmul;

3. Start the SSH server. COMPSs needs to ssh to a node to execute the tasks.
    /etc/init.d/ssh start;

4. We need to install some missing components (for admin activites)
    apt update;
    apt-get install sudo;

5. Prepare java paths:
    export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/;

6. Go to 2nd bash shell

7. For simplification save running container id
    export CONT_ID=$(sudo docker container ps -qf "ancestor=albertbsc/compss-matmul")

8. Go to folder with prepared Java sourcecode
    cd $HOME/tutorial_apps/java;
    mkdir jar;

9. Copy the compatible compss-engine.jar from inside the running container + add it to classpath
    docker cp $CONT_ID:/opt/COMPSs/Runtime/compss-engine.jar compss-engine.jar;
    export CLASSPATH=$CLASSPATH:$PWD/compss-engine.jar

10. If not yet - install same version of JDK as in container and set it as the default java version
    sudo apt-get install openjdk-8-jdk;
    sudo update-alternatives --config java;

11. Compile source code to jar (each sample has a Readme for easier build). See HelloWorld example:
    javac hello/src/main/java/hello/*.java;
    cd hello/src/main/java/;
    jar cf hello.jar hello/;
    cd ../../../../;
    mv hello/src/main/java/hello.jar jar/;

12. Transfer the compiled JARs and any other files (e.q. test files) to the running container
    docker cp jar/. $CONT_ID:/project_folder/;

13. Return to 1st  bash shell (container TTY) and go to projet folder
    cd project_folder;

14. Start the COMPSs monitor for observation
    /etc/init.d/compss-monitor start

15. Execute the program using the runcompss command as a test
    runcompss -m -d hello.Hello

16. Go to 2nd bash shell after test finishes

17. Save running docker state as new image
    sudo docker commit $CONT_ID xlab/hellocompss

18. Close container and test new image
    docker container kill $CONT_ID
    docker run -it -p 8888:8080 xlab/hellocompss
    Repeat steps 3 and 5

19. Monitor the execution of COMPSs in your browser:
    http://localhost:8888/compss-monitor/
```
***Remaining issues with our approach:***
* JARs have to be in separate folders or COMPSS crashes
* Is there a way to do everthing in 1 bash shell - for making a script


#### COMPSs developer team answers and comments:

Please note down the answers into the readme, not just into slack.

### Deploying the application, configuration



