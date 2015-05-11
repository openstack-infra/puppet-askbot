# == Class: askbot::site::celeryd
# This class describes the askbot celery daemon configuration
class askbot::site::celeryd (
  $site_root            = undef,
) {
  file { '/etc/init/askbot-celeryd.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('askbot/celeryd.upstart.conf.erb'),
    require => Exec['askbot-migrate'],
  }

  service { 'askbot-celeryd':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => File['/etc/init/askbot-celeryd.conf'],
    subscribe  => [ Exec['askbot-migrate'], File["${site_root}/config/settings.py"] ]
  }
}
