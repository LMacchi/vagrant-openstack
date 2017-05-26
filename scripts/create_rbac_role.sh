#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/group/data/file.json"
  exit 1
fi

DATA=$1
CERT=$(/opt/puppetlabs/puppet/bin/puppet config print hostcert)
KEY=$(/opt/puppetlabs/puppet/bin/puppet config print hostprivkey) 
CACERT=$(/opt/puppetlabs/puppet/bin/puppet config print localcacert) 
MASTER=$(/opt/puppetlabs/puppet/bin/puppet config print certname)

curl -s -X POST --data @$DATA -H "Content-Type: application/json" --cert $CERT --key $KEY --cacert $CACERT https://${MASTER}:4433/rbac-api/v1/roles

