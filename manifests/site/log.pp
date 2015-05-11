# == Class: askbot::site::log
# This class describes the askbot site log files
class askbot::site::log (
  $site_root = undef,
  $www_group = undef,
) {

  file { "${site_root}/log":
    ensure  => directory,
    owner   => 'root',
    group   => $www_group,
    mode    => '0775',
    require => File[$site_root],
  }

  file { "${site_root}/log/askbot.log":
    ensure  => present,
    replace => 'no',
    owner   => 'root',
    group   => $www_group,
    mode    => '0664',
    require => File["${site_root}/log"],
  }

  include logrotate
  logrotate::file { 'askbot':
    log     => "${site_root}/log/askbot.log",
    options => [
      'compress',
      'copytruncate',
      'missingok',
      'rotate 7',
      'daily',
      'notifempty',
    ],
    require => File["${site_root}/log/askbot.log"],
  }
}
