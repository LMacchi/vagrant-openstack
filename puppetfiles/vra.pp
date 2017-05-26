include node_manager

Node_group {
  provider => 'https',
}

node_group { 'vRA Integration':
  ensure               => 'present',
  classes              => {'profile::vra_config' => {}},
  environment          => 'production',
  override_environment => false,
  parent               => 'PE Infrastructure',
  rule                 => ['=', 'name', 'master.lmacchi.vm'],
}
