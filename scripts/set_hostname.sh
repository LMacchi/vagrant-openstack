#!/bin/bash
# Script that gets public IP and sets hostname based on it
PUBLIC_IP=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
SHORT_HOST=`echo ${PUBLIC_IP//\./-}`
FULL_HOST="${SHORT_HOST}.rfc1918.puppetlabs.net"
CLOUD_FILE='/etc/cloud/cloud.cfg.d/99_hostname.cfg'

echo "Setting hostname to ${FULL_HOST}"

hostnamectl set-hostname ${FULL_HOST}
if [[ $? -ne 0 ]]; then
  echo "Hostname change failed"
  exit 2
fi

# Build Cloud file so Openstack stops changing my servername
echo "hostname: ${SHORT_HOST}" > $CLOUD_FILE
echo "fqdn: ${FULL_HOST}" >> $CLOUD_FILE

