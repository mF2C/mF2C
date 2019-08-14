#!/bin/bash
#
# Script to test cau-client running as part of an agent.
# In the tests, the cau-client calls the CAU to:
# 1.  get a certificate
# 2.  retrieve a public key
#
# Author: Shirley Crompton, UKRI-STFC
# Last modified: 9 Aug 2019
#
printf '\e[0;33m %-15s \e[0m \n' "Tester needs privilege to run Docker commands..."
printf '\e[0;33m %-15s \e[0m \n' "[CAU-ClientTests]" "Starting..."

function log {
    text="$2"
    if [[ $1 == "OK" ]]
    then
        printf '\e[0;33m %-15s \e[32m SUCCESS:\e[0m %s \n' "[CAU-ClientTests]" "$text"
    else
        printf '\e[0;33m %-15s \e[0;31m FAILED:\e[0m %s \n' "[CAU-ClientTests]" "$text"
    fi
}

#test preliminaries, check if we got Agent credentials
echo "Extracting container id ...."
cid=$(docker ps | grep "mf2c/cau-client-it2:" | cut -d " " -f1)
if [ -z "${cid}" ]; then
	log "Failed" "Failed to extract container id.  Cannot proceed!"
	exit 1
else
	echo "cau-client container id : ${cid}"
fi

#Actually, we cannot call the get certificate method as it has side effects.  The certificate is stored in the keystore and written to the /pkidata file volume
#set up request
#getcert="detectedLeaderID=0f848d8fb78cbe5615507ef5a198f660ac89a3ae03b95e79d4ebfb3466c20d54e9a5d9b9c41f88c782d1f67b32231d31b4fada8d2f9dd31a4d884681b784ec5a,deviceID=c6968d75a7df20e2d2f81f87fe69bf0b7dd14f4a22cca5f15ffc645cb4d45944bfdc7a7a970a9e13a331161e304a3094d8e6e362e88bd7df0d7b5473b6d2aa80,IDkey=888812345"


#cert=$(docker exec -it "${cid}" sh -c "echo -n ${getcert} | nc localhost 46065")
#cau-client returns "OK" if it worked
#echo "get cert returned : ${cert}"
#if [ -z "${cert}" ] || [ "${cert:0:2}" == "err" ]; then
#	log "FAILED" "Failed to get cert from cau-client" 
#else
#	log "OK" "Got cert from cau-client"
#fi
#get public key
getpk="getpubkey=c6968d75a7df20e2d2f81f87fe69bf0b7dd14f4a22cca5f15ffc645cb4d45944bfdc7a7a970a9e13a331161e304a3094d8e6e362e88bd7df0d7b5473b6d2aa80"
pubkey=$(docker exec -it "${cid}" sh -c "echo -n ${getpk} | nc localhost 46065")
echo "the retrieved pubkey: ${pubkey}"
if [ -z "${pubkey}" ] || [ "${pubkey:0:2}" == "err" ] || [ "${pubkey}" == "404" ] ; then
        log "FAILED" "Failed to get public key from cau-client"
else
        log "OK" "Got public key from cau-client"
fi

log "OK" "COMPLETED CAU-CLIENT tests!"
exit 0
