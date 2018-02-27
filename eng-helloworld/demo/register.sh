# create user
../tool/dClayTool.sh NewAccount helloworld password #usecasetre 3esacesu

# create dataset and allow access to user
../tool/dClayTool.sh NewDataContract helloworld password helloworldds helloworld

# create namespace and fill it with the previous generated models
../tool/dClayTool.sh NewModel helloworld password helloworldns model/ java

# create directories for libs and stubs
mkdir app/stubs
mkdir app/lib

# generate stubs
../tool/dClayTool.sh GetStubs helloworld password helloworldns app/stubs

# copy dataClay lib 
cp ../tool/lib/dataclayclient.jar app/lib/
