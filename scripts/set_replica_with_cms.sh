#!/bin/bash
# If puppet is running, wait
sudo /vagrant/scripts/wait_for_puppet.sh &&
# Proceed. Provision replica
sudo /opt/puppetlabs/puppet/bin/puppet infrastructure provision replica replica.lmacchi.vm  &&
# PuppetDB needs to sync, give it some time
sudo /vagrant/scripts/wait_for_puppetdb_sync.sh &&
# If puppet is running, wait
sudo /vagrant/scripts/wait_for_puppet.sh &&
# Proceed. Enable replica
sudo /opt/puppetlabs/puppet/bin/puppet infrastructure enable -y --topology mono-with-compile \
  --agent-server-urls lb.lmacchi.vm:8140 \
  --infra-agent-server-urls master.lmacchi.vm:8140,replica.lmacchi.vm:8140 \
  --classifier-termini master.lmacchi.vm:4433,replica.lmacchi.vm:4433 \
  --puppetdb-termini master.lmacchi.vm:8081,replica.lmacchi.vm:8081 \
  --pcp-brokers master.lmacchi.vm:4433,replica.lmacchi.vm:4433 \
  replica replica.lmacchi.vm &&
# Run puppet in all the infrastructure
sudo /opt/puppetlabs/puppet/bin/puppet job run --no-enforce-environment --query 'nodes {deactivated is null and expired is null}'
