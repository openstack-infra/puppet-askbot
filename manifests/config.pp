# == Class: askbot::config
# This class sets up askbot install
#
# == Parameters
#
# == Actions
class askbot::config (
  $db_password,
  $redis_password,
  $akismet_api_key              = undef,
  $askbot_debug                 = false,
  $custom_theme_enabled         = false,
  $custom_theme_name            = undef,
  $db_host                      = 'localhost',
  $db_name                      = 'askbotdb',
  $db_provider                  = 'www-data',
  $db_user                      = 'askbot',
  $dist_root                    = '/srv/dist',
  $redis_enabled                = false,
  $redis_prefix                 = 'askbot',
  $redis_port                   = 6378,
  $redis_max_memory             = '256m',
  $redis_bind                   = '127.0.0.1',
  $site_name                    = 'askbot',
  $site_root                    = '/srv/askbot-site',
  $site_ssl_cert_file           = '/etc/ssl/certs/ssl-cert-snakeoil.pem',
  $site_ssl_cert_file_contents  = undef,
  $site_ssl_chain_file          = undef,
  $site_ssl_chain_file_contents = undef,
  $site_ssl_enabled             = false,
  $site_ssl_key_file_contents   = undef,
  $site_ssl_key_file            = '/etc/ssl/private/ssl-cert-snakeoil.key',
  $solr_enabled                 = false,
  $smtp_host                    = 'localhost',
  $smtp_port                    = 25,
  $template_settings            = 'askbot/settings.py.erb',
  $www_group                    = 'www-data',
) {
  file { $site_root:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { "${site_root}/upfiles":
    ensure  => directory,
    owner   => 'root',
    group   => $www_group,
    mode    => '0775',
    require => File[$site_root],
  }

  if $site_ssl_enabled {
    class { '::askbot::site::ssl':
      site_name                    => $site_name,
      site_ssl_cert_file_contents  => $site_ssl_cert_file_contents,
      site_ssl_key_file_contents   => $site_ssl_key_file_contents,
      site_ssl_chain_file_contents => $site_ssl_chain_file_contents,
      site_ssl_cert_file           => $site_ssl_cert_file,
      site_ssl_key_file            => $site_ssl_key_file,
      site_ssl_chain_file          => $site_ssl_chain_file,
    }
  }

  class { '::askbot::site::http':
    site_root => $site_root,
    site_name => $site_name,
  }

  class { '::askbot::site::celeryd':
    site_root => $site_root,
  }

  class { '::askbot::site::config':
    site_root            => $site_root,
    dist_root            => $dist_root,
    db_provider          => $db_provider,
    db_name              => $db_name,
    db_user              => $db_user,
    db_password          => $db_password,
    db_host              => $db_host,
    askbot_debug         => $askbot_debug,
    smtp_port            => $smtp_port,
    smtp_host            => $smtp_host,
    redis_enabled        => $redis_enabled,
    redis_prefix         => $redis_prefix,
    redis_port           => $redis_port,
    redis_max_memory     => $redis_max_memory,
    redis_bind           => $redis_bind,
    redis_password       => $redis_password,
    custom_theme_enabled => $custom_theme_enabled,
    custom_theme_name    => $custom_theme_name,
    solr_enabled         => $solr_enabled,
    template_settings    => $template_settings,
  }

  class { '::askbot::site::static':
    site_root => $site_root,
  }

  class { '::askbot::site::log':
    site_root => $site_root,
    www_group => $www_group,
  }

  class { '::askbot::site::cron':
    site_root => $site_root,
  }

}
