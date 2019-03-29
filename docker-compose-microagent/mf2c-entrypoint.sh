#!/bin/sh
set -e

display_usage() {
  echo
  echo "Usage: $0"
  echo
  echo " -h, --help   Display usage instructions"
  echo " --vpn        Use VPN instead of Wireless discovery"
  echo
}

while [[ $# -gt 0 ]]
do
arg="$1"

case $arg in
    --vpn)
    VPN=1
    shift
    ;;
    *)
    echo "Unknown argument ${arg}"
    display_usage
    shift
    ;;
esac
done


