# Define: askbot::theme::compass
#
# This class installs the Ruby based bundler command and compiles
# the Sass files of a custom theme. The theme must contain a
# proper Gemfile to define compass version and dependencies.
#
# Actions:
#   - Install Ruby / Compass
#   - Compile Sass files into Css stylesheets
#
define askbot::theme::compass(
) {
  if $::operatingsystem == 'Ubuntu' and $::lsbdistrelease == '12.04' {
    # add ruby, bundler packages if not defined somewhere else
    if ! defined(Package['rubygems']) {
      package { 'rubygems':
        ensure => present,
      }
    }

    if ! defined(Package['bundler']) {
      package { 'bundler':
        ensure   => latest,
        provider => gem,
        require  => Package['rubygems'],
      }
    }
  } else {
    # add bundler as a debian package
    package { 'bundler':
      ensure   => latest,
    }
  }

  # install bundle requirements in Gemfiles, compile Sass
  exec { "theme-bundle-install-${name}":
    cwd         => '/srv/askbot-site/themes',
    path        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin', '/usr/local/bin'],
    logoutput   => on_failure,
    command     => 'bundle install',
    require     => Package['bundler'],
    refreshonly => true,
  }

  exec { "theme-bundle-compile-${name}":
    cwd         => '/srv/askbot-site/themes',
    path        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin', '/usr/local/bin'],
    logoutput   => on_failure,
    command     => 'bundle exec compass compile',
    require     => Exec["theme-bundle-install-${name}"],
    refreshonly => true,
    # notify      => Exec["askbot-static-generate-${name}"],
  }

}
