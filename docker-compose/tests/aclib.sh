# !/bin/bash
# Script to test aclib running as part of an agent.
# The tests only work after the Agent has obtained its certificate
# as they need to use the deviceID and the RSA keypair
# associated with the mF2C certificate to sign/encrypt/verify
# the tokens.
# Author: Shirley Crompton, UKRI-STFC
# Last modified: 13 Aug 2019

printf '\e[0;33m %-15s \e[0m \n' "Tester needs privilege to run Docker commands..."
printf '\e[0;33m %-15s \e[0m \n' "Tests will be aborted if Agent does not have the necessary mF2C cedentials..."
printf '\e[0;33m %-15s \e[0m Starting...\n' "[ACLibTests]"

function log {
    text="$2"
    if [[ $1 == "OK" ]]; then
        printf '\e[0;33m %-15s \e[32m SUCCESS:\e[0m %s \n' "[ACLibTests]" "${text}"
    else
        printf '\e[0;33m %-15s \e[0;31m FAILED:\e[0m %s \n' "[ACLibTests]" "${text}"
    fi
}

# Set aclib port
port=46080

# find the container id
echo "Extracting container id ...."
cid=$(docker ps | grep "mf2c/aclib:" | cut -d " " -f1)
if [ -z "${cid}" ]; then
        log "Failed" "Failed to extract container id.  Cannot proceed!"
    exit 1
#else
#       echo "aclib container id : ${cid}"
fi

#test preliminaries, check if we got Agent credentials
function fe {
    f=$1
    cmd=" [ -e $f ] && echo -n Found || echo NotFound"
    msg="docker exec -it ${cid} sh -c \"${cmd}\""
    res=$(eval ${msg})
#   echo :${res}:
    if [ "${res}" != "Found" ]; then
        log "Failed" "No $f file, cannot proceed!"
        exit 1
#    else
        echo "$f exists"
    fi
}

echo "Checking if agent credentials exist...."
fe "/pkidata/deviceid.txt"
fe "/pkidata/server.crt"
fe "/pkidata/server.key"

# Now set the host IP
echo "Setting ACLib IP..."

#find ip of the aclib container
###################for standalone container
#host=$(docker inspect "{$cid}" -f ip='{{ .NetworkSettings.IPAddress }} ')

###################for running as part of an agent with docker-compose
#first find the network name
net=$(docker inspect "${cid}" --format='{{ .HostConfig.NetworkMode }}')

if [ -z "${net}" ]; then
    log "Failed" "Cannot obtain docker network id using inspect! Cannot continue!"
    exit 1
else
    echo "network id: ${net}"
fi
#now get the ip
host=$(docker inspect "${cid}" -f ip='{{ .NetworkSettings.Networks.'"${net}"'.IPAddress }}')

if [ -z "${host}" ]; then
    log "Failed" "Cannot obtain container IP using inspect! Cannot continue!" 
    exit 1
#else
#    echo "IP : ${host} "
fi

host_ip=${host:3}
echo "ALib host ip set to ${host_ip}"
#now get the device id
did=$(docker exec -it "${cid}" sh -c "more /pkidata/deviceid.txt")

if [ -z "${did}" ]; then
    log "Failed" "Cannot obtain device id from container! Cannot continue!"
    exit 1
#else
    #note, no whitespace at end of the token
#    echo "DeviceId : ${did}"
fi

#jwt : 
#create request
jwt_req="{\"typ\":\"jwt\",\"recs\":[\"${did}\"]}"
#echo "JWT request : ${jwt_req}"
jwt=$(echo ${jwt_req} | nc ${host_ip} ${port})
if [ -z "${jwt}" ]; then
	log "FAILED" "Failed to get JWT from ACLib" 
else
	log "OK" "Got JWT from ACLib"
fi

#######
### CIMI integration test
#######

cat > session-template-jwt.json <<EOF
{
    "method": "jwt",
    "instance": "jwt",
    "name": "JWT Authentication",
    "description": "External Authentication with JWT",
    "token": "provide-valid-authentication-token",
    "acl": {
        "owner":{"principal":"ADMIN","type":"ROLE"},
        "rules":[{"principal":"ADMIN","type":"ROLE","right":"ALL"},
                 {"principal":"ANON","type":"ROLE","right":"VIEW"},
                 {"principal":"USER","type":"ROLE","right":"VIEW"}]
    }
}
EOF

export JWT="${jwt}"

cat > session-login-jwt.json <<EOF
{
    "name": "test-jwt",
    "description": "session create document to test jwt authentication",
    "sessionTemplate": {
        "href": "session-template/jwt",
        "token": "${JWT}"
    }
}
EOF

(curl -XGET "https://localhost/api/cloud-entry-point" -ksS | jq -e 'select(.baseURI != null)' > /dev/null 2>&1 && \
    log "OK" " [CIMI] cloud-entry-point exists" && exit 0) || \
        (log "NO" " [CIMI] unable to get cloud-entry-point" && exit 1)

if [ $? -eq 0 ]
then
	# insert the session template that allows JWT authentication
	curl -ksS -XPOST -d @session-template-jwt.json -H content-type:application/json -H 'slipstream-authn-info:internal ADMIN USER ANON' https://localhost/api/session-template | jq -e 'select(.status == 201)' > /dev/null 2>&1
        if [ $? -eq 0 ]
        then
                cleanUp=1
                log "OK" " [CIMI] successfully pushed new session template for JWT tokens"
        else
                log "FAILED" " [CIMI] failed to add new session template for JWT tokens"
        fi

	# remove any existing cookies
	rm -f ~/cookies

	# try authenticating with JWT
	curl -ksS  --cookie-jar ~/cookies -b ~/cookies -XPOST -d @session-login-jwt.json -H content-type:application/json https://localhost/api/session | jq -e 'select(.status == 201)' > /dev/null 2>&1
        if [ $? -eq 0 ]
        then
                log "OK" " [CIMI] successful login with JWT token"
        else
                log "FAILED" " [CIMI] failed to login with CIMI using JWT"
        fi

	# clean up
	if [ ! -z $cleanUp ]
	then
		curl -ksS -XDELETE -H 'slipstream-authn-info:internal ADMIN USER ANON' https://localhost/api/session-template/jwt | jq -e 'select(.status == 200)' > /dev/null 2>&1
		if [ $? -eq 0 ]
        	then
                	log "OK" " [CIMI] deleted JWT session template"
        	else
                	log "FAILED" " [CIMI] failed to delete JWT session template"
 	        fi
	fi
	rm -f session-login-jwt.json
	rm -f session-template-jwt.json
fi


#
#echo "JWT : ${jwt}"
#verify the token
vjwt_req="{\"typ\":\"jwt\",\"token\":\"${jwt}\"}"
#echo "Verify JWT request : ${vjwt_req}"
#
vjwt_res=$(echo ${vjwt_req} | nc ${host_ip} ${port})
#echo "Verify JWT returned: ${vjwt_res}"
if [ -z  "${vjwt_res}" ] || [ ${vjwt_res} != "OK" ]; then
	log "FAILED" "ACLib failed to verify JWT..."
else
	log "OK" "JWT verified by ACLib"
fi

#
#jws :
#create reqeust
payload="a top secret message!"
echo "The payload: ${payload}"
#
jws_req="{\"typ\":\"jws\",\"comp\":\"f\",\"payload\":\"${payload}\",\"sec\":\"pro\"}"
#echo "JWS request: ${jws_req}"
jws=$(echo ${jws_req} | nc ${host_ip} ${port})
#echo "ACLib returned JWS : ${jws}"
if [ -z  "${jws}" ] || [ "${jws:0:2}" == "err" ] ; then
    log "FAILED" "ACLib failed to create JWS..."
else
    log "OK" "JWS created by ACLib"
fi

#verify jws
vjws_req="{\"typ\":\"jws\",\"token\":\"${jws}\"}"
jws_payload=$(echo ${vjws_req} | nc ${host_ip} ${port})
echo "verified JWS payload: ${jws_payload}"
#
if [ "${jws_payload}" == "${payload}" ]; then
    log "OK" "JWS verfied by ACLib"
else
    log "FAILED" "ACLIB failed to verify JWS..."
fi

#jwe :
#create request
#
jwe_req="{\"recs\":[\"${did}\"],\"typ\":\"jwe\",\"comp\":\"t\",\"payload\":\"${payload}\",\"sec\":\"pri\"}"
#echo "${jwe_req}"
jwe=$(echo ${jwe_req} | nc ${host_ip} ${port})
if  [ -z  "${jwe}" ] || [ "${jwe:0:2}" == "err" ] ; then
    log "FAILED" "ACLib failed to create JWE with payload compression..."
else
    log "OK" "JWE with payload compression created by ACLib"
fi
#verify jew:
vjwe_req="{\"typ\":\"jwe\",\"token\":\"${jwe}\"}"
jwe_payload=$(echo ${vjwe_req} | nc ${host_ip} ${port})
echo "verified JWE payload: ${jwe_payload}"
#
if [ "${jwe_payload}" == "${payload}" ]; then
    log "OK" "JWE with payload compression verfied by ACLib"
else
    log "FAILED" "ACLIB failed to verify JWE with payload compression..."
fi
#

echo "End of ACLib Tests....."
exit 0
