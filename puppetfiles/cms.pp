include node_manager
package { 'gem_puppetclassify':
  ensure   => present,
  provider => 'puppet_gem',
}

node_group { 'Compile Masters':
  ensure               => 'present',
  classes              => {'profile::compile_master' => {}},
  environment          => 'production',
  override_environment => false,
  parent               => 'All Nodes',
  rule                 => ['~', 'name', 'cm\d.lmacchi.vm'],
  require              => Package['puppetclassify'],
}

node_group { 'PE Master':
  ensure  => 'present',
  rule    => ['or', ['and', ['~', 'name', 'cm\d.lmacchi.vm']], ['=', 'name', 'master.lmacchi.vm']],
  require => Package['puppetclassify'],
}
