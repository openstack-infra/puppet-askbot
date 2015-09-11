# == Class: askbot
# This class sets up an askbot site
#
# == Parameters
#   - $www_group: group name for web writeable directories like upfiles and log
#   - $www_user: user name for web process
#   - $askbot_debug: set to true to enable askbot debug mode
#   - $dist_root: root directory of distribution releases
#   - $site_root: root directory of site config and assets
#   - $site_name: fqdn of askbot site
#
#   Source repository:
#   - askbot_repo: git repository of askbot source files
#   - askbot_revision: branch of askbot repo used for deployment
#
#   Custom askbot theme settings:
#   - $custom_theme_enabled: set to true to enable custom themes, default: false
#   - $custom_theme_name: name of custom theme set to default
#
#   Redis configuration:
#   - $redis_enabled: set to true to use redis as cache backend
#   - $redis_prefix: redis key prefix (required for multi-site setups)
#   - $redis_port: port of redis service
#   - $redis_max_memory: memory allocation for redis
#   - $redis_bind: bind address of redis service
#   - $redis_password: password required for redis connection
#
#   SSL Settings:
#   - $site_ssl_enabled: set to true for SSL based vhost
#   - $site_ssl_cert_file_contents: x509 certificate in pem format
#   - $site_ssl_key_file_contents: the key of site certificate in pem format
#   - $site_ssl_chain_file_contents: the issuer certs of site cert (optional)
#   - $site_ssl_cert_file: file name of site certificate
#   - $site_ssl_key_file: file name of the site certificate's key file
#   - $site_ssl_chain_file: file name of the issuer certificates
#
#   Email configuration:
#   - $smtp_host: hostname of smtp service used for email sending
#   - $smtp_port: port of smtp service
#
#   Database provider and connection details:
#   - $db_provider: database provider (mysql or pgsql)
#   - $db_name: database name
#   - $db_user: user name required for db connection
#   - $db_password: password required for db connection
#   - $db_host: database host
#
#   Solr support:
#   - solr_enabled: set true to use solr as a search indexing engine
#
# == Actions
#
class askbot (
  $db_password,
  $redis_password,
  $dist_root                    = '/srv/dist',
  $site_root                    = '/srv/askbot-site',
  $askbot_revision              = 'master',
  $askbot_repo                  = 'https://github.com/ASKBOT/askbot-devel.git',
  $www_group                    = 'www-data',
  $www_user                     = 'www-data',
  $db_provider                  = 'mysql',
  $db_name                      = 'askbotdb',
  $db_user                      = 'askbot',
  $db_host                      = 'localhost',
  $askbot_debug                 = false,
  $redis_enabled                = false,
  $redis_prefix                 = 'askbot',
  $redis_port                   = 6378,
  $redis_max_memory             = '256m',
  $redis_bind                   = '127.0.0.1',
  $site_ssl_enabled             = false,
  $site_ssl_cert_file_contents  = undef,
  $site_ssl_key_file_contents   = undef,
  $site_ssl_chain_file_contents = undef,
  $site_ssl_cert_file           = '/etc/ssl/certs/ssl-cert-snakeoil.pem',
  $site_ssl_key_file            = '/etc/ssl/private/ssl-cert-snakeoil.key',
  $site_ssl_chain_file          = undef,
  $site_name                    = 'askbot',
  $custom_theme_enabled         = false,
  $custom_theme_name            = undef,
  $solr_enabled                 = false,
  $smtp_port                    = '25',
  $smtp_host                    = 'localhost',
  $askbot_ensure                = 'present',
) {

  class { '::askbot::install':
    db_provider     => $db_provider,
    dist_root       => $dist_root,
    askbot_repo     => $askbot_repo,
    askbot_revision => $askbot_revision,
    redis_enabled   => $redis_enabled,
    solr_enabled    => $solr_enabled,
  }

  if !defined(File[$dist_root]) {
    file { $dist_root:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  vcsrepo { "${dist_root}/askbot":
    ensure   => $askbot_ensure,
    provider => git,
    revision => $askbot_revision,
    source   => $askbot_repo,
    require  => [ File[$dist_root], Package['git'] ],
  }

  class { '::askbot::config':
    site_root                    => $site_root,
    dist_root                    => $dist_root,
    www_group                    => $www_group,
    db_provider                  => $db_provider,
    db_name                      => $db_name,
    db_user                      => $db_user,
    db_password                  => $db_password,
    db_host                      => $db_host,
    askbot_debug                 => $askbot_debug,
    redis_enabled                => $redis_enabled,
    redis_prefix                 => $redis_prefix,
    redis_port                   => $redis_port,
    redis_max_memory             => $redis_max_memory,
    redis_bind                   => $redis_bind,
    redis_password               => $redis_password,
    site_ssl_enabled             => $site_ssl_enabled,
    site_ssl_cert_file_contents  => $site_ssl_cert_file_contents,
    site_ssl_key_file_contents   => $site_ssl_key_file_contents,
    site_ssl_chain_file_contents => $site_ssl_chain_file_contents,
    site_ssl_cert_file           => $site_ssl_cert_file,
    site_ssl_key_file            => $site_ssl_key_file,
    site_ssl_chain_file          => $site_ssl_chain_file,
    site_name                    => $site_name,
    custom_theme_enabled         => $custom_theme_enabled,
    custom_theme_name            => $custom_theme_name,
    solr_enabled                 => $solr_enabled,
    smtp_port                    => $smtp_port,
    smtp_host                    => $smtp_host,
    require                      => [ Vcsrepo["${dist_root}/askbot"], Class['askbot::install'] ],
  }
}
