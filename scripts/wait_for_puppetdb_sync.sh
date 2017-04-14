#!/bin/bash
while [ `sudo /opt/puppetlabs/puppet/bin/puppet infrastructure status --host replica.lmacchi.vm --service puppetdb | grep '0 of 1' 2>&1 > /dev/null; echo $?` -eq 0 ];
do
  echo "PuppetDB is syncing, please wait"
  sleep 5
done
echo "PuppetDB sync complete"
exit 0
