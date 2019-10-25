#!/bin/sh

# Author jens.jensen@stfc.ac.uk
# for the mF2C project (www.mf2c-project.eu)
# August 2019.

# BEGIN PORTABILITY NOTE

# This code is written to also run on alpine; so it does not use bash
# which is not available on alpine out of the box.  We also use awk,
# and there are limitations of the one on alpine (compared to, say,
# gawk), notably on the busybox awk on alpine, lshift(1,32)==0.

# END PORTABILITY NOTE

# BEGIN USER SERVICABLE PARTS

# Delay for waiting for TUN device if it's not already present (in
# seconds).  This is because there is a dependency on cau-client which
# needs to establish the credential before the VPN client can connect.

ALLOW_DEVICE_DELAY=180

# END USER SERVICABLE PARTS


# Using this line from cimi.sh to get similar output format
printf '\e[0;33m %-15s \e[0m Starting...\n' [VPNclientTests]


NUM_TEST=0
NUM_OK=0


# Since the change in setup which has only parts of the clients
# connection route over the VPN (viz, the private subnet managed by
# the server), *and* it is exported to the hosts's network, testing
# now becomes ridiculously easy, as long as we are on that network.

# TEST1 Client should always use tun0; however, the host would not
# generally have a tun *device* since it's inside the container;
# but it *would* have a tun interface...

# NUM_TEST=`expr $NUM_TEST + 1`
# if [ -c /dev/net/tun0 ]; then
#     NUM_OK=`expr $NUM_OK + 1`
#     log "OK" "tun device configured"
# else
#     log "NO" "tun device missing (fatal)"
#     final
# fi


# TEST2 tun device should be configured as a network device We
# actually do not check whether it is up or down, only whether it is
# configured.

NUM_TEST=`expr $NUM_TEST + 1`
while [ ${NUM_TEST} -ne ${NUM_OK} ] && [ ${ALLOW_DEVICE_DELAY} -gt 0 ]
do  if ifconfig tun0 >/dev/null 2>&1 ; then
	NUM_OK=`expr $NUM_OK + 1`
	printf '\e[0;33m %-15s \e[32m SUCCESS:\e[0m %s \n' [VPNclientTests] "TUN device exists"
    else
	ALLOW_DEVICE_DELAY=`expr ${ALLOW_DEVICE_DELAY} - 1`
	sleep 1
    fi
done

if [ ${NUM_TEST} -gt ${NUM_OK} ] ; then
    printf '\e[0;33m %-15s \e[0;31m FAILED:\e[0m %s \n' [VPNclientTests] "Timeout waiting for TUN device to appear, no TUN device"
    exit 1
fi



# The ip addr command seems to have more consistent output across the
# different platforms

M=`ip addr show tun0`

# TEST3 check if interface is down (for some reason)

NUM_TEST=`expr $NUM_TEST + 1`
if echo $M | grep -q ',UP,' ; then
    NUM_OK=`expr $NUM_OK + 1`
    printf '\e[0;33m %-15s \e[32m SUCCESS:\e[0m %s \n' [VPNclientTests] "TUN device is up"
else
    printf '\e[0;33m %-15s \e[0;31m FAILED:\e[0m %s \n' [VPNclientTests] "TUN device is NOT up"
    exit 1
fi



# TEST4 see if we can ping the server which sits on XXX.XXX.XXX.1
# where the Xes denote the mask.  Note that this test only works on
# IPv6.  There are several failure modes in this, single, test.

NUM_TEST=`expr $NUM_TEST + 1`

# Extract the IP address out of the ifconfig output.  This should not
# fail, unless perhaps the format of the output of ifconfig is
# different (ie the sed does not strip what it needs to) or we are
# running in a weird environment with no sed or awk available.  Note
# that alpine by default has awk but it is a busybox version, not
# (say) an alias to gawk.

# Of course a lazy programmer would gleefully have assumed a static IP
# for the server on its VPN subnet (it is always on .1), but the
# actual private subnet is dictated by the server.

IP=`echo $M|sed 's/^.* inet //'|awk -F" " '{print $1}'`

if [ $? -gt 0 ]; then
    printf '\e[0;33m %-15s \e[0;31m FAILED:\e[0m %s \n' [VPNclientTests] "Failed to get IP address for tun0 device (sed or awk missing?)"
    exit 1
fi

# Here, IP should be of the CIDR form XXX.XXX.XXX.XXX/NN, even if
# XXX.XXX.XXX.XXX is the full IP address.  NN gives us the number of
# (most significant) bits in the netmask.  Note that with the current
# setup we only support IPv4 addresses.

if [ "x" = "x${IP}" ] ; then
    printf '\e[0;33m %-15s \e[0;31m FAILED:\e[0m %s \n' [VPNclientTests] "Failed to extract IP address (format error?)"
    exit 1
fi

SERVER=`echo $IP | awk '
ipnm=$1

function itoa(i) {
    o[1] = and(rshift(i,24),0xFF)
    o[2] = and(rshift(i,16),0xFF)
    o[3] = and(rshift(i,8),0xFF)
    o[4] = and(i,0xFF)
    return o[1]"."o[2]"."o[3]"."o[4]
}


# We check the pattern - twice!  Can also be used for the script to
# match other patterns, e.g. IPv6, or different ways of passing the
# netmask  to the script.

/^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+\/[[:digit:]]+/ {
								      
    if ( patsplit(ipnm,a,"[[:digit:]]+",sep) != 5 ) {
        printf "Parse error: Expected five numbers in \"%s\"\n", ipnm > "/dev/stderr"
        exit 1
    }

    if ( sep[1] != "." || sep[2] != "." || sep[3] != "." || sep[4] != "/" ) {
        printf "Parse error: expected input in IPv4/CIDR format, got %s\n", ipnm > "/dev/stderr"
        exit 1
    }

    # 32 bit unsigned integers are OK on all awks...
    client=or(lshift(a[1],24), lshift(a[2],16), lshift(a[3],8), a[4])

    # Number of least significant zero bits in netmask
    nmzbits=32-a[5]

    # Clear the lower bits and add 1
    server=or(lshift(rshift(client,nmzbits),nmzbits),1)

    print itoa(server)
}'`

# The extra awk call above is because the main script by default
# outputs both the input and the output.

if [ $? -gt 0 ] || [ "x${SERVER}" = "x" ] ; then
    printf '\e[0;33m %-15s \e[0;31m FAILED:\e[0m %s \n' [VPNclientTests] "Failed to calculate server address"
    exit 1
fi

# The main script outputs both the input and the output... we only
# need the output
SERVER=`echo $SERVER|awk -F" " '{print $2}'`


if ping -c 1 -q ${SERVER} >/dev/null 2>&1 ; then
    NUM_OK=`expr $NUM_OK + 1`
    printf '\e[0;33m %-15s \e[32m SUCCESS:\e[0m %s \n' [VPNclientTests] "Successful ping to server"
else
    printf '\e[0;33m %-15s \e[0;31m FAILED:\e[0m %s (%s) \n' [VPNclientTests] "Failed to ping" "${SERVER}"
fi


# Exit, pursued by another test

if [ $NUM_TEST -eq $NUM_OK ] ; then
    ret=0
    col='\e[32m';
else
    ret=1
    col='\e[0;31m'
fi
printf "\\e[0;33m %-15s \\e[0m ...Finished ${col}(${NUM_OK}/${NUM_TEST})\\e[0m\\n" [VPNclientTests]
exit $ret
