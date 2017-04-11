node_group { 'Version Control Server':
  ensure               => 'present',
  classes              => { 'profile::gitlab' => {}},
  environment          => 'production',
  override_environment => false,
  parent               => 'All Nodes',
  rule                 => ['~', 'name', 'gitlab'],
}
