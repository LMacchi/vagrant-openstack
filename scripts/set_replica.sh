#!/bin/bash
sudo /opt/puppetlabs/puppet/bin/puppet infrastructure provision replica replica.lmacchi.vm &&
# PuppetDB needs to sync, give it some time
wait 20 &&
sudo /opt/puppetlabs/puppet/bin/puppet infrastructure enable -y --topology mono-with-compile --infra-agent-server-urls lb.lmacchi.vm:8140 replica replica.lmacchi.vm &&
sudo /opt/puppetlabs/puppet/bin/puppet job run --no-enforce-environment --query 'nodes {deactivated is null and expired is null}'
