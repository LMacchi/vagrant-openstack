node_group { 'Proxy Server':
  ensure               => 'present',
  classes              => {'profile::proxy' => {}},
  environment          => 'production',
  override_environment => false,
  parent               => 'All Nodes',
  rule                 => ['=', 'name', 'lb.lmacchi.vm'],
}
