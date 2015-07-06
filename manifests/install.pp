# == Class: askbot::install
# This class installs the required packages for askbot
class askbot::install (
  $db_provider     = 'mysql',
  $dist_root       = '/srv/dist',
  $askbot_repo     = 'https://github.com/ASKBOT/askbot-devel.git',
  $askbot_revision = 'master',
  $redis_enabled   = false,
  $solr_enabled    = false,
) {

  if !defined(Package['git']) {
    package { 'git':
      ensure => present,
    }
  }

  if !defined(Package['python-pip']) {
    package { 'python-pip':
      ensure => present,
    }
  }

  if !defined(Package['python-dev']) {
    package { 'python-dev':
      ensure => present,
    }
  }

  case $db_provider {
    'mysql': {
      $db_provider_package = 'python-mysqldb'
    }
    'pgsql': {
      $db_provider_package = 'python-psycopg2'
    }
    default: {
      fail("Unsupported database provider: ${db_provider}")
    }
  }
  if ! defined(Package[$db_provider_package]) {
    package { $db_provider_package:
      ensure => present,
    }
  }

  if $redis_enabled {
    package { 'django-redis-cache':
      ensure   => present,
      provider => 'pip',
    }
  }

  include httpd::mod::wsgi

  if $solr_enabled {
    package { [ 'django-haystack', 'pysolr' ]:
      ensure   => present,
      provider => 'pip',
    }
  }

  package { 'stopforumspam':
    ensure   => present,
    provider => 'pip',
    before   => Exec['askbot-install'],
  }

  exec { 'pip-requirements-install':
    path        => [ '/bin', '/sbin' , '/usr/bin', '/usr/sbin', '/usr/local/bin' ],
    command     => "pip install -q -r ${dist_root}/askbot/askbot_requirements.txt",
    cwd         => "${dist_root}/askbot",
    logoutput   => on_failure,
    subscribe   => Vcsrepo["${dist_root}/askbot"],
    refreshonly => true,
  }

  exec { 'askbot-install':
    path        => [ '/bin', '/sbin' , '/usr/bin', '/usr/sbin', '/usr/local/bin' ],
    cwd         => "${dist_root}/askbot",
    command     => 'python setup.py -q install',
    logoutput   => on_failure,
    subscribe   => Vcsrepo["${dist_root}/askbot"],
    refreshonly => true,
  }

}
