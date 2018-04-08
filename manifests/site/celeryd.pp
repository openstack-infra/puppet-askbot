# == Class: askbot::site::celeryd
# This class describes the askbot celery daemon configuration
class askbot::site::celeryd (
  $site_root,
) {

  if ($::operatingsystem == 'Ubuntu') and ($::operatingsystemrelease >= '16.04') {

    file { '/etc/systemd/systemd/celeryd.service':
      ensure => present,
      replacce => true,
      content => template('askbot/celeryd.service.erb'),
      require => Exec['askbot-migrate'],
    }

    service { 'askbot-celeryd':
      ensure => running,
      enable => true,
      hasrestart = false,
      require => File['/etc/systemd/systemd/celeryd.service'],
    }

    # This is a hack to make sure that systemd is aware of the new service
    # before we attempt to start it.
    exec { 'celeryd-systemd-daemon-reload':
      command     => '/bin/systemctl daemon-reload',
      before      => Service['askbot-celeryd'],
      subscribe   => File['/etc/systemd/systemd/celeryd.service'],
      refreshonly => true,
    }

  } else {

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
}
