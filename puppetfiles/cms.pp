include node_manager

Node_group {
  provider => 'https',
}

node_group { 'Compile Masters':
  ensure               => 'present',
  classes              => {'role::puppet::cm' => {}},
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
