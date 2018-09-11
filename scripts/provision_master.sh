#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 install_url PE_version"
  echo "Example: $0 http://download.puppet.com latest"
  exit 2
end

URL=$1
PE_VER=$2

setenforce 0
/vagrant/scripts/set_hostname.sh
yum -y install vim wget git
/usr/local/bin/puppet --version 2&> /dev/null
if [ $? -ne 0 ]; then
  # Download tar
  echo "Download URL: ${URL}"
  echo "Downloading Puppet Enterprise, this may take a few minutes"
  wget --quiet --progress=bar:force --content-disposition "${URL}"
  if [ $? -ne 0 ]; then
    echo "Puppet failed to download"
    exit 2
  fi
  # Extract tar to /root
  tar xzvf puppet-enterprise-*.tar* -C /root
  if [ $? -ne 0 ]; then
    echo "Puppet failed to extract"
    exit 2
  fi
  # Add the SSH key for Code Manager, public is in my control-repo
  if [ ! -d "/etc/puppetlabs/puppetserver/ssh" ]; then
    mkdir -p /etc/puppetlabs/puppetserver/ssh
    chmod 700 /etc/puppetlabs/puppetserver/ssh
    cp /vagrant/files/keys/id-control_repo.rsa* /etc/puppetlabs/puppetserver/ssh
  fi
  if [ ! -d "/etc/puppetlabs/puppet" ]; then
    mkdir -p /etc/puppetlabs/puppet
    cp /vagrant/puppetfiles/csr_attributes.yaml /etc/puppetlabs/puppet/csr_attributes.yaml
  fi
  # Install PE from answers file
  echo "Ready to install Puppet Enterprise ${PE_VER}"
  /root/puppet-enterprise-*/puppet-enterprise-installer -c /vagrant/puppetfiles/custom-pe.conf -y
  # Clean up
  rm -fr /root/puppet-enterprise-*
  # Now that pe-puppet exists, change permissions for keys and config
  chown -R pe-puppet: /etc/puppetlabs/puppetserver/ssh
  # Run puppet
  echo "Running puppet for the first time"
  /opt/puppetlabs/puppet/bin/puppet agent -t
  echo "Running Puppet again"
  /opt/puppetlabs/puppet/bin/puppet agent -t
  # Create deploy token with admin, so replica can be provisioned
  echo "puppetlabs" | /opt/puppetlabs/bin/puppet-access login admin --lifetime 90d
  # Deploy code
  echo "Deploying puppet code from version control server"
  /vagrant/scripts/deploy_code.sh
  # Clear environments cache
  echo "Clearing environments cache"
  /vagrant/scripts/update_environments.sh
  # Update classes in console
  echo "Clearing classifier cache"
  /vagrant/scripts/update_classes.sh
  # Create Classification
  /opt/puppetlabs/puppet/bin/puppet apply /vagrant/puppetfiles/classification.pp
  # Clear environments cache
  echo "Clearing environments cache"
  /vagrant/scripts/update_environments.sh
  # Update classes in console
  echo "Clearing classifier cache"
  /vagrant/scripts/update_classes.sh
  /usr/local/bin/puppet agent -t || :
else
  /usr/local/bin/puppet agent -t || :
fi
exit 0
