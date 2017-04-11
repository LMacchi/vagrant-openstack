## Vagrant environment with Openstack
This environment creates CentOS 7 machines in Openstack

### Requirements
- Configure openstack CLI tools. Vagrantfile reads variables from the user environment.
- Vagrant plugins used: vagrant-hostmanager, vagrant-openstack-provider, vagrant-triggers

### Customization
## Openstack
- ssh_path: Path to your private SSH key in your host machine
- ssh_user: User to access newly provisioned nodes
- ssh_keypair: Openstack key pair to access machines
- floating_ip_pool: Openstack floating ip pool
- image: OS image hosted in Openstack used to provision boxes

## Project
- domain: Boxes get named as master.#{domain} and agentx.#{domain}.
- cms: How many compile masters to create. Set to 0 to not create cms.
- agents: How many agents to create. Set to 0 to not create agents.
- install_replica: Do you want to create a server to use as a replica? (Note replica is not provisioned)
- install_lb: Do you want to set up a haproxy load balancer?
- install_gitlab: Do you want a gitlab server? (TO DO)

## Puppet
- puppetver: Puppet Enterprise version, x.y.z. Ex: '2015.3.3'
- url: Vagrant will use this URL to download the PE installer

### Usage
Run

```
vagrant up
```

And go grab a cup of coffee. It will take quite a while. 
After all boxes are provisioned, some tasks are pending. They are automated in a script:

```
sudo /vagrant/scripts/after_install.sh
```

Finally, even though there is a replica machine, the replica has not yet been provisioned. If you're feeling brave:

```
sudo /vagrant/scripts/set_replica.sh
```

Notice that my domain is hardcoded on that last one.
