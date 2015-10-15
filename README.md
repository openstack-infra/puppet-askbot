# OpenStack Askbot

Marton Kiss <marton.kiss@gmail.com>

This module manages and installs Askbot with an optional custom Sass based
theme.

# Quick Start

    class { 'askbot':
      db_provider          => 'pgsql',
      require              => Postgresql::Server::Db[$db_name],
    }

    askbot::site { 'ask.example.com':
      db_name                      => 'askbotdb',
      db_user                      => 'askbot',
      db_password                  => 'changeme',
      require                      => [ Class['redis'], Class['askbot'] ],
    }
  }

# Configuration

The Askbot puppet module is separated into individual components which Askbot
needs to run.

## ::askbot

A module that installs a standalone Askbot application with dependencies based
on configuration settings. This class synchronize and install the database
schema, configure the askbot-celeryd daemon required for scheduled tasks, and
finally apply a proper log rotation.

The source of deployement is a git repository defined in askbot_repo and
askbot_revision parameters.

  class { 'askbot':
      dist_root                    => '/srv/dist',
      site_root                    => '/srv/askbot-site',
      askbot_branch                => 'master',
      askbot_repo                  => 'https://github.com/ASKBOT/askbot-devel.git',
      www_user                     => 'www-data',
      www_group                    => 'www-data',
      site_name                    => undef,
      # custom theme
      custom_theme_enabled         => false,
      custom_theme_name            => undef,
      # debug settings
      askbot_debug                 => false,
      # redis cache configuration
      redis_enabled                => false,
      redis_prefix                 => 'askbot',
      redis_port                   => undef,
      redis_max_memory             => undef,
      redis_bind                   => undef,
      redis_password               => undef,
      # site ssl configuration
      site_ssl_enabled             => false,
      site_ssl_cert_file_contents  => undef,
      site_ssl_key_file_contents   => undef,
      site_ssl_chain_file_contents => undef,
      site_ssl_cert_file           => '',
      site_ssl_key_file            => '',
      site_ssl_chain_file          => '',
      # smtp settings
      smtp_host                    => 'localhost',
      smtp_port                    => '25',
      # database connection parameters
      db_provider                  => 'mysql',
      db_name                      => undef,
      db_user                      => undef,
      db_password                  => undef,
      db_host                      => 'localhost',
    }

## ::askbot::compass

A helper module to compile the Sass style sheets for a custom theme. As
OpenStack Askbot theme contains pure Sass files in the repository, for a
production deployment those files must be compiled into css.

 askbot::theme::compass { 'os':
   require => Git['askbot-theme'],
   before => Exec['askbot-static-generate'],
 }
