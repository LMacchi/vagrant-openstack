# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Vagrant environment that creates a puppet master, gitlab and $agents agents
#
#
require 'vagrant-openstack-provider'

# Variables
## Openstack
ssh_path = '/Users/lmacchi/.ssh/id_rsa'
ssh_user = 'centos'
ssh_keypair = 'Laptop'
floating_ip_pool = 'ext-net-pdx1-opdx1'
image = 'laura_centos_7_x86_64'

## Project
domain = 'lmacchi.vm'
cms = 0
agents = 2
install_replica = false
install_lb = false
install_gitlab = false
install_jenkins = true

## Puppet
pe_ver = "2017.1.1"
url = "https://pm.puppetlabs.com/cgi-bin/download.cgi?dist=el&rel=7&arch=x86_64&ver=#{pe_ver}"

Vagrant.configure(2) do |config|
  # Global configurations
  config.ssh.username = ssh_user
  config.ssh.private_key_path = ssh_path
  #config.ssh.pty = true
  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false

  # Master 
  config.vm.define "master" do |master|
    master.vm.hostname = "master.#{domain}"
    master.hostmanager.aliases = %W(master)
    master.vm.provider :openstack do |os|
      os.openstack_auth_url   = ENV['OS_AUTH_URL']
      os.username             = ENV['OS_USERNAME']
      os.password             = ENV['OS_PASSWORD']
      os.domain_name          = ENV['OS_USER_DOMAIN_NAME']
      os.project_name         = ENV['OS_PROJECT_NAME']
      os.identity_api_version = ENV['OS_IDENTITY_API_VERSION']
      os.flavor               = 'g1.xlarge'
      os.image                = image
      os.floating_ip_pool     = floating_ip_pool
      os.keypair_name         = ssh_keypair
      os.security_groups      = ['sg0']
    end
    master.vm.provision "shell", privileged: true, inline: <<-SHELL
      sudo setenforce 0
      sudo hostnamectl set-hostname master.#{domain} --static
      sudo yum -y install vim wget
      sudo /usr/local/bin/puppet --version 2&> /dev/null
      if [ $? -ne 0 ]; then
        # Download tar
        echo "Download URL: #{url}"
        echo "Downloading Puppet Enterprise, this may take a few minutes"
        sudo wget --quiet --progress=bar:force --content-disposition "#{url}"
        # Extract tar to /root
        sudo tar xzvf puppet-enterprise-*.tar* -C /root
        # Install PE from answers file
        echo "Ready to install Puppet Enterprise #{pe_ver}"
        sudo /root/puppet-enterprise-*/puppet-enterprise-installer -c /vagrant/puppetfiles/custom-pe.conf -y
        # Clean up
        sudo rm -fr /root/puppet-enterprise-*
        # Add an autosign condition
        sudo echo "*.#{domain}" > /etc/puppetlabs/puppet/autosign.conf
        echo "Running puppet for the first time"
        sudo /opt/puppetlabs/puppet/bin/puppet agent -t
        echo "Running Puppet again"
        sudo /opt/puppetlabs/puppet/bin/puppet agent -t
        #echo "Running Puppet again"
        #sudo /opt/puppetlabs/puppet/bin/puppet agent -t
        # Create deploy token with admin, so replica can be provisioned
        echo "puppetlabs" | sudo /opt/puppetlabs/bin/puppet-access login admin --lifetime 90d
        # Deploy code
        echo "Deploying puppet code from version control server"
        sudo /vagrant/scripts/deploy_code.sh
        # Clear environments cache
        echo "Clearing environments cache"
        sudo /vagrant/scripts/update_environments.sh
        # Update classes in console
        echo "Clearing classifier cache"
        sudo /vagrant/scripts/update_classes.sh
        # Add Compile Masters to PE Master group and create CM group to export LB Member
        sudo /opt/puppetlabs/puppet/bin/puppet apply /vagrant/puppetfiles/cms.pp
        # Add Load Balancer group to the console
        sudo /opt/puppetlabs/puppet/bin/puppet apply /vagrant/puppetfiles/proxy_group.pp
        # Add Gitlab group to the console
        sudo /opt/puppetlabs/puppet/bin/puppet apply /vagrant/puppetfiles/vcs_group.pp
        # Add Jenkins group to the console
        sudo /opt/puppetlabs/puppet/bin/puppet apply /vagrant/puppetfiles/jenkins_group.pp
      else
        sudo /usr/local/bin/puppet agent -t | true
      fi
    SHELL
  end

  # Replica
  if install_replica
    config.vm.define "replica" do |replica|
      replica.vm.hostname = "replica.#{domain}"
      replica.hostmanager.aliases = %W(replica)
      replica.vm.provider :openstack do |os|
        os.openstack_auth_url   = ENV['OS_AUTH_URL']
        os.username             = ENV['OS_USERNAME']
        os.password             = ENV['OS_PASSWORD']
        os.domain_name          = ENV['OS_USER_DOMAIN_NAME']
        os.project_name         = ENV['OS_PROJECT_NAME']
        os.identity_api_version = ENV['OS_IDENTITY_API_VERSION']
        os.flavor               = 'g1.xlarge'
        os.image                = image
        os.floating_ip_pool     = floating_ip_pool
        os.keypair_name         = ssh_keypair
        os.security_groups      = ['sg0']
      end
      replica.vm.provision "shell", inline: <<-SHELL
      sudo setenforce 0
      sudo hostnamectl set-hostname replica.#{domain} --static
      # Install puppet
      /usr/local/bin/puppet --version 2&> /dev/null
      if [ $? -ne 0 ]; then
        curl -s -k https://master.#{domain}:8140/packages/current/install.bash | sudo bash
      fi 
      sudo /usr/local/bin/puppet agent -t | true
      SHELL
    end
  end

  # Load Balancer
  if install_lb
    config.vm.define "lb" do |lb|
      lb.vm.hostname = "lb.#{domain}"
      lb.hostmanager.aliases = %W(lb)
      lb.vm.provider :openstack do |os|
        os.openstack_auth_url   = ENV['OS_AUTH_URL']
        os.username             = ENV['OS_USERNAME']
        os.password             = ENV['OS_PASSWORD']
        os.domain_name          = ENV['OS_USER_DOMAIN_NAME']
        os.project_name         = ENV['OS_PROJECT_NAME']
        os.identity_api_version = ENV['OS_IDENTITY_API_VERSION']
        os.flavor               = 'g1.medium'
        os.image                = image
        os.floating_ip_pool     = floating_ip_pool
        os.keypair_name         = ssh_keypair
        os.security_groups      = ['sg0']
      end
      lb.vm.provision "shell", inline: <<-SHELL
        sudo setenforce 0
        sudo hostnamectl set-hostname lb.#{domain} --static
        # Install puppet
        /usr/local/bin/puppet --version 2&> /dev/null
        if [ $? -ne 0 ]; then
          curl -s -k https://master.#{domain}:8140/packages/current/install.bash | sudo bash
        fi 
        sudo /usr/local/bin/puppet agent -t | true
        SHELL
    end
  end

  # Gitlab
  if install_gitlab
    config.vm.define "gitlab" do |gitlab|
      gitlab.vm.hostname = "gitlab.#{domain}"
      gitlab.hostmanager.aliases = %W(gitlab)
      gitlab.vm.provider :openstack do |os|
        os.openstack_auth_url   = ENV['OS_AUTH_URL']
        os.username             = ENV['OS_USERNAME']
        os.password             = ENV['OS_PASSWORD']
        os.domain_name          = ENV['OS_USER_DOMAIN_NAME']
        os.project_name         = ENV['OS_PROJECT_NAME']
        os.identity_api_version = ENV['OS_IDENTITY_API_VERSION']
        os.flavor               = 'g1.medium'
        os.image                = image
        os.floating_ip_pool     = floating_ip_pool
        os.keypair_name         = ssh_keypair
        os.security_groups      = ['sg0']
      end
      gitlab.vm.provision "shell", inline: <<-SHELL
        sudo setenforce 0
        sudo hostnamectl set-hostname gitlab.#{domain} --static
        # Install puppet
        /usr/local/bin/puppet --version 2&> /dev/null
        if [ $? -ne 0 ]; then
          curl -s -k https://master.#{domain}:8140/packages/current/install.bash | sudo bash
        fi
        sudo /usr/local/bin/puppet agent -t | true
      SHELL
    end
  end

  # Jenkins
  if install_jenkins
    config.vm.define "jenkins" do |jenkins|
      jenkins.vm.hostname = "jenkins.#{domain}"
      jenkins.hostmanager.aliases = %W(jenkins)
      jenkins.vm.provider :openstack do |os|
        os.openstack_auth_url   = ENV['OS_AUTH_URL']
        os.username             = ENV['OS_USERNAME']
        os.password             = ENV['OS_PASSWORD']
        os.domain_name          = ENV['OS_USER_DOMAIN_NAME']
        os.project_name         = ENV['OS_PROJECT_NAME']
        os.identity_api_version = ENV['OS_IDENTITY_API_VERSION']
        os.flavor               = 'g1.medium'
        os.image                = image
        os.floating_ip_pool     = floating_ip_pool
        os.keypair_name         = ssh_keypair
        os.security_groups      = ['sg0']
      end
      jenkins.vm.provision "shell", inline: <<-SHELL
        sudo setenforce 0
        sudo hostnamectl set-hostname jenkins.#{domain} --static
        # Install puppet
        /usr/local/bin/puppet --version 2&> /dev/null
        if [ $? -ne 0 ]; then
          curl -s -k https://master.#{domain}:8140/packages/current/install.bash | sudo bash
        fi 
        sudo /usr/local/bin/puppet agent -t | true
        SHELL
    end
  end


  # Compile Masters
  if cms > 0
    (1..cms).each do |i|
      config.vm.define "cm#{i}" do |cm|
        cm.vm.hostname = "cm#{i}.#{domain}"
        cm.hostmanager.aliases = %W(cm#{i})
        cm.vm.provider :openstack do |os|
          os.openstack_auth_url   = ENV['OS_AUTH_URL']
          os.username             = ENV['OS_USERNAME']
          os.password             = ENV['OS_PASSWORD']
          os.domain_name          = ENV['OS_USER_DOMAIN_NAME']
          os.project_name         = ENV['OS_PROJECT_NAME']
          os.identity_api_version = ENV['OS_IDENTITY_API_VERSION']
          os.flavor               = 'm1.medium'
          os.image                = image
          os.floating_ip_pool     = floating_ip_pool
          os.keypair_name         = ssh_keypair
          os.security_groups      = ['sg0']
        end
        cm.vm.provision "shell", inline: <<-SHELL
          sudo setenforce 0
          sudo hostnamectl set-hostname cm#{i}.#{domain} --static
          # Install puppet
          /usr/local/bin/puppet --version 2&> /dev/null
          if [ $? -ne 0 ]; then
            curl -s -k https://master.#{domain}:8140/packages/current/install.bash | sudo bash -s main:dns_alt_names=puppet,puppet.#{domain},lb,lb.#{domain}
          else
            sudo /usr/local/bin/puppet agent -t | true
          fi
        SHELL
      end
    end
  end


  # Agents
  if agents > 0
    (1..agents).each do |i|
      config.vm.define "agent#{i}" do |agent|
        agent.vm.hostname = "agent#{i}.#{domain}"
        agent.hostmanager.aliases = %W(agent#{i})
        agent.vm.provider :openstack do |os|
          os.openstack_auth_url   = ENV['OS_AUTH_URL']
          os.username             = ENV['OS_USERNAME']
          os.password             = ENV['OS_PASSWORD']
          os.domain_name          = ENV['OS_USER_DOMAIN_NAME']
          os.project_name         = ENV['OS_PROJECT_NAME']
          os.identity_api_version = ENV['OS_IDENTITY_API_VERSION']
          os.flavor               = 'g1.small'
          os.image                = image
          os.floating_ip_pool     = floating_ip_pool
          os.keypair_name         = ssh_keypair
          os.security_groups      = ['sg0']
        end
        agent.vm.provision "shell", inline: <<-SHELL
          sudo setenforce 0
          sudo hostnamectl set-hostname agent#{i}.#{domain} --static
          # Install puppet
          /usr/local/bin/puppet --version 2&> /dev/null
          if [ $? -ne 0 ]; then
            curl -s -k https://master.#{domain}:8140/packages/current/install.bash | sudo bash
          fi
          sudo /usr/local/bin/puppet agent -t | true
        SHELL
      end
    end
  end
end
