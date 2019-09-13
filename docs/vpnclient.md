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

The VPN client connects its private network into the host's network,
so the host can route packets over the private network, and
specifically to any other client connected to the VPN.  Therefore, any
standard network API is available.  The client is configured to use
the device `tun0`.

### Troubleshooting

If the client credential is not available, the VPN client will
sleep-loop waiting for credentials to become available; these are
traditionally obtained by `cau-client` and stored in the `pkidata`
volume.  In this release, it sleep-loops forever, without timing out.

#### Troubleshooting 1: VPN server

Check the VPN server is running and the name `vpnserver` should
resolve to the IP address of the server inside the VPN client
container.  When starting a container manually, it may be necessary to
use `--add-hosts` to make the address available.

#### Troubleshooting 2: Client credentials

Inspect the volume containing the client credentials (and mounted on
`/pkidata` in the VPN client.)  It should contain at least two files,
`server.crt` and `server.key`, with the former containing a
certificate issued by the fog CA (aka "untrusted"), and the latter
should contain an unencrypted private key.

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

### 1.1.0 (25/07/19)

#### Added

 - delay loop waiting for credentials, resolving race with `cau-client`
 - even more credentials sanity checks

### 1.0.0 (13/06/19)

#### Changed

 - key generation on server re-engineered.
 - updated the tests (as run by the docker-compose file in the [vpn repo](https://github.com/mF2C/vpn)









