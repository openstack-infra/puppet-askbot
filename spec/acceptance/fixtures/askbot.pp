class { 'postgresql::server': }

postgresql::server::db { 'askdb':
  user     => 'ask',
  password => 'password',
}

class { 'askbot':
  askbot_revision  => '87086ebcefc5be29e80d3228e465e6bec4523fcf',
  db_provider      => 'pgsql',
  db_name          => 'askdb',
  db_user          => 'ask',
  db_password      => 'password',
  redis_enabled    => false,
  site_name        => 'ask.openstack.org',
  solr_enabled     => false,
  site_ssl_enabled => false,
}
