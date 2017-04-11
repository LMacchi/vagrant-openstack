#!/bin/bash
# Run commands after everything is up
# Run puppet in all nodes
sudo /opt/puppetlabs/client-tools/bin/puppet-job run --no-enforce-environment --query 'nodes {deactivated is null and expired is null}'
# Sign CMs certificates
OUTPUT=`sudo /opt/puppetlabs/puppet/bin/puppet cert list`
if [[ ! -z $OUTPUT ]]; then
  CMD=`echo $OUTPUT | awk '{print "sudo /opt/puppetlabs/puppet/bin/puppet cert sign --allow-dns-alt-names " $1}'`
  eval $CMD
fi
echo "Run puppet in the compile masters"
read -n1 -r -p "Press any key to continue..." key
# Run puppet in the CMs
sudo /opt/puppetlabs/client-tools/bin/puppet-job run --no-enforce-environment --query 'nodes { certname ~ "cm" }'
# Run puppet in the master
sudo /opt/puppetlabs/puppet/bin/puppet agent -t
# Run puppet globally
sudo /opt/puppetlabs/client-tools/bin/puppet-job run --no-enforce-environment --query 'nodes {deactivated is null and expired is null}'
