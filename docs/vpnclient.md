# VPNCLIENT

The VPN client, as the name suggests, is a container that runs a VPN
client, connecting to an existing VPN server.

## Usage

When the container starts, it checks the client credential in the
volume usually called `pkidata` which, by default, is mounted on
`/pkidata`, but locations etc can be customised through environment
variables; see the [mF2C VPN repo](https://github.com/mF2C/vpn) for
details.

### API

The VPN client provides a status API on port 1999 (as of 1.1.2).  A
HTTP query to `/api/get_vpn_ip` returns a JSON structure of the form:

```
{
   "ip" : "192.168.255.2",
   "status" : "connected",
   "stats" : {
       "total" : "3",
       "good" : "3",
       "error" : "0",
       "noconn" : "0"
    },
    "server" : "192.168.255.1",
    "lastUpdate" : "20190927 09:46:07+0000"
}
					  
```

Here, `ip` denotes the client's IP address in the VPN (only available
when the client is connected); similarly for `server` (the client IP
is called `ip` for backward compatibility).  Also included is a
timestamp of when the status was last updated, plus statistics.
`good` is how many pings were successful; `noconn` are those where the
client could not reach the server on the VPN network, and `error` is a
count of the number of internal errors.  If errors is non-zero, the
client is likely to be in a bad state.

Additional information about the status field is available in the VPN
repository.

### Troubleshooting

If the client credential is not available, the VPN client will
sleep-loop waiting for credentials to become available; these are
traditionally obtained by `cau-client` and stored in the `pkidata`
volume.  In this release, it sleep-loops forever, without timing out.

#### Troubleshooting 1: VPN server

First call the API; if entries are unpopulated but status is not
either `connected` or `failed` then it is most likely the VPN client
is waiting for something - that its credentials repository is updated,
or it is waiting for the server to connect it.

If the entrypoint script has exited, the exit code indicates the type
of error that occurred.

1. An exit code of 1 indicates a basic systems permissions error
2. An exit code of 2 indicates a PKI credentials error
3. Exit code 3 indicates an error with the VPN client credentials (ovpn)
4. Exit code 4 is currently not used
5. Exit code 5 is an error of launching and connecting the VPN client.

#### Troubleshooting 2: Client credentials

Inspect the volume containing the client credentials (and mounted on
`/pkidata` in the VPN client.)  It should contain at least two files,
`server.crt` and `server.key`, with the former containing a
certificate issued by the fog CA (aka "untrusted"), and the latter
should contain an unencrypted private key.

#### Troubleshooting 3: API

If the API for some reason is not available but the container has not
exited, it is conceivable (but very unlikely) that the web service
endpoint has not launched, or (more likely) you are talking to the
wrong port or the wrong hostname (e.g. `localhost` instead of the
hostname).  On the host, one can check for availability of the `tun0`
device.

IF A CLIENT IS NOT WORKING, DO NOT JUST LAUNCH ANOTHER CLIENT.  IT
WILL NOT WORK AND MIGHT MAKE THINGS WORSE.

#### Logs

When connected successfully, the container should eventually provide a
log message saying that the client is connected.  If it keeps
producing output, it is a sign that it is either waiting for
credentials to appear, or there is a networking error.

### Security Considerations

Apart from the usual considerations regarding the availability of mF2C
fog credentials, note that the client does not alter the host's
routing table.  Although the VPN connection is encrypted, the VPN
offers no protection for host or container traffic routed outside the
VPN.

## CHANGELOG

### 1.1.2

#### Changed

 - moved API port to 1999 rather than 80, so is more likely to coexist on host network
 - API now provides timestamps, and ongoing status updates, e.g. if connection to server is lost
 - API also provides stats, how many checks (pings) are good and how many failed

### 1.1.1

#### Added

 - API (described above) added on port 80, endpoint `/api/get_vpn_ip`

### 1.1.0 (25/07/19)

#### Added

 - delay loop waiting for credentials, resolving race with `cau-client`
 - even more credentials sanity checks

### 1.0.0 (13/06/19)

#### Changed

 - key generation on server re-engineered.
 - updated the tests (as run by the docker-compose file in the [vpn repo](https://github.com/mF2C/vpn)









