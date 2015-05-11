# == Class: askbot::config
# This class sets up askbot install
#
# == Parameters
#
# == Actions
class askbot::config (
  $site_root                    = undef,
  $dist_root                    = undef,
  $www_group                    = undef,
  $db_provider                  = undef,
  $db_name                      = undef,
  $db_user                      = undef,
  $db_password                  = undef,
  $db_host                      = undef,
  $askbot_debug                 = undef,
  $redis_enabled                = undef,
  $redis_prefix                 = undef,
  $redis_port                   = undef,
  $redis_max_memory             = undef,
  $redis_bind                   = undef,
  $redis_password               = undef,
  $site_ssl_enabled             = undef,
  $site_ssl_cert_file_contents  = undef,
  $site_ssl_key_file_contents   = undef,
  $site_ssl_chain_file_contents = undef,
  $site_ssl_cert_file           = undef,
  $site_ssl_key_file            = undef,
  $site_ssl_chain_file          = undef,
  $site_name                    = undef,
  $custom_theme_enabled         = undef,
  $custom_theme_name            = undef,
  $solr_enabled                 = undef,
  $smtp_port                    = undef,
  $smtp_host                    = undef,
) {
  file { $site_root:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { "${site_root}/upfiles":
    ensure  => directory,
    owner   => 'root',
    group   => $www_group,
    mode    => '0775',
    require => File[$site_root],
  }

  if $site_ssl_enabled {
    class { 'askbot::site::ssl':
      site_ssl_cert_file_contents  => $site_ssl_cert_file_contents,
      site_ssl_key_file_contents   => $site_ssl_key_file_contents,
      site_ssl_chain_file_contents => $site_ssl_chain_file_contents,
      site_ssl_cert_file           => $site_ssl_cert_file,
      site_ssl_key_file            => $site_ssl_key_file,
      site_ssl_chain_file          => $site_ssl_chain_file,
    }
  }

  class { 'askbot::site::http':
    site_root => $site_root,
    site_name => $site_name,
  }

  class { 'askbot::site::celeryd':
    site_root => $site_root,
  }

  class { 'askbot::site::config':
    site_root            => $site_root,
    dist_root            => $dist_root,
    db_provider          => $db_provider,
    db_name              => $db_name,
    db_user              => $db_user,
    db_password          => $db_password,
    db_host              => $db_host,
    askbot_debug         => $askbot_debug,
    smtp_port            => $smtp_host,
    smtp_host            => $smtp_port,
    redis_enabled        => $redis_enabled,
    redis_prefix         => $redis_prefix,
    redis_port           => $redis_port,
    redis_max_memory     => $redis_max_memory,
    redis_bind           => $redis_bind,
    redis_password       => $redis_password,
    custom_theme_enabled => $custom_theme_enabled,
    custom_theme_name    => $custom_theme_name,
    solr_enabled         => $solr_enabled,
  }

  class { 'askbot::site::static':
    site_root => $site_root,
  }

  class { 'askbot::site::log':
    site_root => $site_root,
    www_group => $www_group,
  }

  class { 'askbot::site::cron':
    site_root => $site_root,
  }

}
