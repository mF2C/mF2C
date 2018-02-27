# mF2C (another) hello world example
This document will provide the documentation to set up the minimal set of tools to run mF2C.
More details about mF2C project can be found [here](http://www.mf2c-project.eu/)

### The goal of the hello world example
The goal of this hello world demo application is to drive developers on how they can use COMPSs together with dataClay, which are the most basic tools of mF2C applications.
Applications in mF2C can be deployed both on fog and/or cloud environments. 

This example is composed by: 
- a docker running a dataClay instance
- a docker running a COMPSs instance, in which is installed the hello world demo application.

This demo application, written in Java, computes the distances between a given point Px and a map of fixed points P1...Pn in a plane. In this example n = 10.
The result of the application will be the set of fixed points for which the distance from Px is less than a given distance, so called threshold distance

To summarize, the inputs of the application are: 
- coordinates x,y of each fixed point P1.. Pn in the map
- coordinates x,y of the point Px
- the threshold distance 

The application will use:
- dataClay to store the coordinates of fixed and reference points, and the result of computation.
- COMPSs to create the computation tasks

For now, this example application has been succesfully installed on x86-64 machines.

The application steps are summarized as follows:
1. load and store the fixed points map into dataClay
2. store the point Px into dataClay
3. invoke COMPSs tasks to perform computation 
4. show the result (printed by COMPSs application)

### Preliminary requirements
Some preliminary requirements for this hello world application:

- docker installation, see instructions [here](https://docs.docker.com/install/)
- docker proxy configuration if needed, see instructions [here](https://docs.docker.com/config/daemon/systemd/#httphttps-proxy)
- docker compose installation, see instructions [here](https://docs.docker.com/compose/install/)
- git installation in order to clone dataClay from repository, see instructions [here](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- Java 8

All installation steps in the following assume root privileges

### Installation and configuration of DataClay
The following steps will deploy dataClay (more details and useful info about dataClay installation are found [here](https://github.com/mF2C/dataClay/blob/master/README.md))

1. clone dataClay repository with the command "git clone https://github.com/mF2C/dataClay.git"
2. cd $GIT/dataClay/orchestration
3. docker-compose rm  # to clean the previous containers, if exist
4. docker-compose up  # wait for "LOGICMODULE Registered ExecutionEnvironment EE/172.19.0.2:2127 for language `LANG_JAVA`" or similar message is shown

At this point, the dataClay docker is running

### Installation and configuration of COMPSs
The following steps are required to install and run a COMPSs instance:

0. open a new shell
1. donwload and run the COMPSs matmul image (basic COMPSs installation + matrix multiplication example) with the command:
  docker run -it --name compss-test --network orchestration_ds -p 8888:8080 albertbsc/compss-matmul bash
2. inside the COMPSs docker, do some admin tasks:
  apt update
  apt-get install sudo
3. if not yet, install jdk and set it as the default java version 
  apt-get install openjdk-8-jdk
  update-java-alternatives --set java-1.8.0-openjdk-amd64
4. exit from docker shell

### Deployment and configuration of the application
Prepare dataClay model 

1. in a new (host) shell, go to dataClay installation directory
  cd $GIT/dataClay
2. create a new directory named "helloworld", and move there
  mkdir helloworld
  cd helloworld
3. copy the content of demo folder in the helloworld directory
4. compile java model classes 
  javac model/mf2c/helloworld/model/*.java 
5. launch register.sh. This file performs the registration on dataClay and prepare directories for the application ecxecution. You also modify register.sh to change settings like user, password, etc. 
  ./register.sh
6. to avoid confusion, clean unnecessary files and directories:
  rm -Rf cfgfiles/ model/ register.sh
7. move to app directory
  cd app
8. compile the sources of the compss application and create a jar
  find src -name "*.java" -print | xargs -I {} javac -sourcepath src -classpath lib/dataclayclient.jar:lib/compss-engine.jar:stubs/ {}
  cd src
  jar cvf ../helloworld.jar mf2c 
9. to clean sources, use the command (optional):
  rm -rf src
10. modify the file cfgfiles/client.properties: set HOST with the ip of running dataclay instance. This is necessary in order to allow application to connect to dataclay docker instance
11. move to main helloworld directory and copy app folder content to compss docker instance in the "/root/apps" directory
   cd ..
   export CONT_ID=$(docker container ps -aqf "ancestor=albertbsc/compss-matmul")
   docker cp app/ $CONT_ID:/root/apps/helloworld
12. save the docker image with a new name, for futher use.
   docker commit $CONT_ID eng/helloworld 
13. to clean environment, remove unnecessary files, folders, docker images (optional)
   docker rm $CONT_ID 
   docker rmi albertbsc/compss-matmul
   cd ../../
   rm -rf dataClay/
14. run the new compss docker instance just created, and enter in the shell
   docker run -it --name eng-helloworld --network orchestration_ds -p 8888:8080 eng/helloworld bash 
15. once in the compss docker, run following commands to setup environment
   /etc/init.d/ssh start
   export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
   /etc/init.d/compss-monitor start	# to start monitor
   6. Monitor the execution of COMPSs in your browser:	http://localhost:8888/compss-monitor/

### Launch demo application 
1. move to helloworld directory
  cd /root/apps/helloworld 
2. run the class to load and store the fixed points map into dataClay
  java -classpath lib/dataclayclient.jar:lib/compss-engine.jar:helloworld.jar:stubs/ mf2c.helloworld.dataclay.ReferencePointsMap
3. run the class to store the point Px into dataClay (in the following command set point Px to x=10,y=10. You can change with other x y coordinates
  java -classpath lib/dataclayclient.jar:lib/compss-engine.jar:helloworld.jar:stubs/ mf2c.helloworld.dataclay.SavePoint 10 10 
4. invoke COMPSs application to perform computation. In the following example, the threshold distance is 10. Change it.
  runcompss -d --classpath=lib/dataclayclient.jar:lib/compss-engine.jar:helloworld.jar:stubs/ mf2c.helloworld.IntersectionPoint 50 
5. after some logs, check that a list of points is shown, as follows (list can be different due to different settings of Px and threshold distance)
  Point: 
   x: 0.0 y: 0.0

