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

  package { 'libjpeg-dev':
    ensure => present,
  }

  class { 'python':
    dev     => 'present',
  }

  python::virtualenv { '/usr/askbot-env':
    ensure  => present,
#    version => '2',
    owner   => 'root',
    group   => 'root',
    timeout => 0,
  }

  case $db_provider {
    'mysql': {
      package { 'libmysqlclient-dev':
        ensure => present,
      }

      python::pip { 'MySQL-python':
        ensure     => '1.2.3',
        pkgname    => 'MySQL-python',
        virtualenv => '/usr/askbot-env',
        require    => [ Package['libmysqlclient-dev'], Python::Virtualenv['/usr/askbot-env'] ],
      }
    }
    'pgsql': {
      package { 'libpq-dev':
        ensure => present,
      }

      python::pip { 'psycopg2':
        ensure     => '2.4.5',
        pkgname    => 'psycopg2',
        virtualenv => '/usr/askbot-env',
        require    => [ Package['libpq-dev'], Python::Virtualenv['/usr/askbot-env'] ],
      }
    }
    default: {
      fail("Unsupported database provider: ${db_provider}")
    }
  }

  python::pip { 'captcha':
    pkgname    => 'captcha',
    ensure     => '0.2.1',
    virtualenv => '/usr/askbot-env',
    require    => Python::Virtualenv['/usr/askbot-env'],
  }

  if $redis_enabled {
    python::pip { 'redis':
      ensure     => '1.3.0',
      pkgname    => 'django-redis-cache',
      virtualenv => '/usr/askbot-env',
      require    => Python::Virtualenv['/usr/askbot-env'],
    }
  }

  if $solr_enabled {
    python::pip { 'django-haystack':
      ensure     => '2.3.1',
      pkgname    => 'django-haystack',
      virtualenv => '/usr/askbot-env',
      require    => Python::Virtualenv['/usr/askbot-env'],
    }

    python::pip { 'pysolr':
      ensure     => '3.3.0',
      pkgname    => 'pysolr',
      virtualenv => '/usr/askbot-env',
      require    => Python::Virtualenv['/usr/askbot-env'],
    }
  }

  exec { 'pip-requirements-install':
    path        => [ '/bin', '/sbin' , '/usr/bin', '/usr/sbin', '/usr/local/bin' ],
    command     => "/usr/askbot-env/bin/pip install -r ${dist_root}/askbot/askbot_requirements.txt",
    cwd         => "${dist_root}/askbot",
    logoutput   => true,
    subscribe   => Git['askbot'],
    refreshonly => true,
    require     => Python::Virtualenv['/usr/askbot-env'],
  }

  python::pip { 'stopforumspam':
    ensure     => '1.4.2',
    pkgname    => 'stopforumspam',
    virtualenv => '/usr/askbot-env',
    require    => Exec[ 'pip-requirements-install' ],
  }

  # six 1.11.0 fails with this old django,
  # use an earlier one; see
  #  https://github.com/benjaminp/six/issues/210
  python::pip { 'six':
    ensure     => '1.10.0',
    pkgname    => 'six',
    virtualenv => '/usr/askbot-env',
    require    => Python::Virtualenv['/usr/askbot-env'],
  }

  include ::httpd::mod::wsgi

  exec { 'askbot-install':
    path        => [ '/bin', '/sbin' , '/usr/bin', '/usr/sbin', '/usr/local/bin' ],
    cwd         => "${dist_root}/askbot",
    command     => '/usr/askbot-env/bin/python setup.py -q install',
    logoutput   => on_failure,
    subscribe   => Git['askbot'],
    refreshonly => true,
    require     => [
                    Python::Virtualenv['/usr/askbot-env'],
                    Exec[ 'pip-requirements-install' ],
                    Python::Pip[ 'six' ],
                    Python::Pip[ 'stopforumspam' ],
                    Python::Pip[ 'captcha' ],
                   ],
  }

}
