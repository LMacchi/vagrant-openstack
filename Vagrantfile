# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Vagrant environment that creates a puppet master, gitlab and $agents agents
#
#
require 'vagrant-openstack-provider'

# Variables
## Flavors
master_flavor = 'vol.xlarge'
lb_flavor = 'vol.small'
gitlab_flavor = 'vol.medium'
jenkins_flavor = 'vol.medium'
docker_flavor = 'vol.xlarge'
cm_flavor = 'vol.medium'
agent_flavor = 'vol.small'

## Infrastructure
domain = 'lmacchi.vm'
cms = 0
agents = 1
install_replica = false
install_lb = false
install_gitlab = false
install_jenkins = false
install_docker = false
autosign_pwd = 'S3cr3tP@ssw0rd!'

## Puppet
pe_ver = ENV['PE_VERSION'] || 'latest'
url = "https://pm.puppetlabs.com/cgi-bin/download.cgi?dist=el&rel=7&arch=x86_64&ver=#{pe_ver}"

Vagrant.configure(2) do |config|
  # Global configurations
  config.ssh.username = 'centos'
  config.ssh.private_key_path = '/Users/lmacchi/.ssh/id_rsa'
  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false

  config.vm.provider 'openstack' do |os|
    os.openstack_auth_url   = ENV['OS_AUTH_URL']
    os.username             = ENV['OS_USERNAME']
    os.password             = ENV['OS_PASSWORD']
    os.domain_name          = ENV['OS_USER_DOMAIN_NAME']
    os.project_name         = ENV['OS_PROJECT_NAME']
    os.identity_api_version = ENV['OS_IDENTITY_API_VERSION']
    os.floating_ip_pool     = 'external'
    os.security_groups      = ['default']
    os.keypair_name         = 'puppet_laptop'
    # Override inside specific VM
    os.image                = 'centos_7_x86_64'
  end

  # Master 
  config.vm.define 'master' do |master|
    master.vm.hostname = "master.#{domain}"
    master.vm.provider :openstack
    master.vm.provider :openstack do |os|
      os.flavor = master_flavor
    end
    master.vm.provision 'shell' do |s|
      s.privileged = true 
      s.path = 'scripts/provision_master.sh'
      s.args = [url, pe_ver]
    end
  end

  # Replica
  if install_replica
    config.vm.define 'replica' do |replica|
      replica.vm.hostname = "replica.#{domain}"
      replica.vm.provider :openstack do |os|
        os.flavor = master_flavor
      end
      replica.vm.provision 'shell' do |s|
        s.privileged = true
        s.path = 'scripts/install_puppet.sh'
        s.args = [domain, 'replica', autosign_pwd]
      end
    end
  end

  # Load Balancer
  if install_lb
    config.vm.define 'lb' do |lb|
      lb.vm.hostname = "lb.#{domain}"
      lb.vm.provider :openstack do |os|
        os.flavor = lb_flavor
      end
      lb.vm.provision 'shell' do |s|
        s.privileged = true
        s.path = 'scripts/install_puppet.sh'
        s.args = [domain, 'lb', autosign_pwd]
      end
    end
  end

  # Gitlab
  if install_gitlab
    config.vm.define 'gitlab' do |gitlab|
      gitlab.vm.hostname = "gitlab.#{domain}"
      gitlab.vm.provider :openstack do |os|
        os.flavor = gitlab_flavor
      end
      gitlab.vm.provision 'shell' do |s|
        s.privileged = true
        s.path = 'scripts/install_puppet.sh'
        s.args = [domain, 'vcs', autosign_pwd]
      end
    end
  end

  # Jenkins
  if install_jenkins
    config.vm.define 'jenkins' do |jenkins|
      jenkins.vm.hostname = "jenkins.#{domain}"
      jenkins.vm.provider :openstack do |os|
        os.flavor = jenkins_flavor
      end
      jenkins.vm.provision 'shell' do |s|
        s.privileged = true
        s.path = 'scripts/install_puppet.sh'
        s.args = [domain, 'ci', autosign_pwd]
      end
    end
  end


  # Compile Masters
  if cms > 0
    (1..cms).each do |i|
      config.vm.define "cm#{i}" do |cm|
        cm.vm.hostname = "cm#{i}.#{domain}"
        cm.vm.provider :openstack do |os|
          os.flavor = cm_flavor
        end
        cm.vm.provision 'shell' do |s|
          s.privileged = true
          s.path = 'scripts/install_puppet_cm.sh'
          s.args = [domain, 'puppet::cm', autosign_pwd]
        end
      end
    end
  end

  # Docker
  if install_docker
    config.vm.define 'docker' do |docker|
      docker.vm.hostname = "docker.#{domain}"
      docker.vm.provider :openstack do |os|
        os.flavor = docker_flavor
      end
      docker.vm.provision 'shell' do |s|
        s.privileged = true
        s.path = 'scripts/install_puppet.sh'
        s.args = [domain, 'docker', autosign_pwd]
      end
    end
  end

  # Agents
  if agents > 0
    (1..agents).each do |i|
      config.vm.define "agent#{i}" do |agent|
        agent.vm.hostname = "agent#{i}.#{domain}"
        agent.vm.provider :openstack do |os|
          os.flavor = agent_flavor
        end
        agent.vm.provision "shell" do |s|
          s.privileged = true
          s.path = 'scripts/install_puppet.sh'
          s.args = [domain, "agent#{i}", autosign_pwd]
        end
      end
    end
  end
end
