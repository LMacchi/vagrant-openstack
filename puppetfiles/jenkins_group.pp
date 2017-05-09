node_group { 'Jenkins Server':
  ensure               => 'present',
  classes              => {'profile::jenkins' => {}},
  environment          => 'production',
  override_environment => false,
  parent               => 'All Nodes',
  rule                 => ['=', 'name', 'jenkins.lmacchi.vm'],
}
