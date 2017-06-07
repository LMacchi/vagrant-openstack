#!/bin/bash
# Script that gets public IP and sets hostname based on it
PUBLIC_IP=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
HOSTNAME=`echo ${PUBLIC_IP//\./-}.rfc1918.puppetlabs.net`

echo "Setting hostname to ${HOSTNAME}"

hostnamectl set-hostname ${HOSTNAME}
if [[ $? -ne 0 ]]; then
  echo "Hostname change failed"
fi
