#!/bin/bash
# Run commands after everything is up
# Run puppet in all nodes
sudo /opt/puppetlabs/client-tools/bin/puppet-job run --no-enforce-environment --query 'nodes {deactivated is null and expired is null}'
# Sign CMs certificates
sudo /opt/puppetlabs/puppet/bin/puppet cert sign --allow-dns-alt-names --all
# Run puppet in the CMs
sudo /opt/puppetlabs/client-tools/bin/puppet-job run --no-enforce-environment --query 'nodes { certname ~ \"cm\" }'
# Run puppet in the master
sudo /opt/puppetlabs/puppet/bin/puppet agent -t
# Run puppet globally
sudo /opt/puppetlabs/client-tools/bin/puppet-job run --no-enforce-environment --query 'nodes {deactivated is null and expired is null}'
