Node_group {
  provider => 'https',
}

node_group { 'Proxy Server':
  ensure               => 'present',
  classes              => {'role::ci' => {}},
  environment          => 'production',
  override_environment => false,
  parent               => 'All Nodes',
  rule                 => ['=', 'name', 'lb.lmacchi.vm'],
}
