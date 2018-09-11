#!/bin/bash

if [ $# -ne 3 ]; then
  echo "Usage: $0 domain role autosign_pwd"
  echo "Example: $0 lmacchi.vm agent changeme"
  exit 2
fi

DOMAIN=$1
ROLE=$2
PWD=$3

setenforce 0
/vagrant/scripts/set_hostname.sh

# Install puppet
/usr/local/bin/puppet --version 2&> /dev/null
if [ $? -ne 0 ]; then
  curl -s -k https://master.$DOMAIN:8140/packages/current/install.bash | bash -s main:dns_alt_names=puppet,puppet.$DOMAIN,lb,lb.$DOMAIN extension_requests:pp_role=$ROLE custom_attributes:challengePassword=$PWD
fi
/usr/local/bin/puppet agent -t || :
exit 0
