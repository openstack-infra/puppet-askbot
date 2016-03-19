# == Class: askbot::site::ssl
# This class describes the http server's SSL configuration
class askbot::site::ssl (
  $site_name,
  $site_ssl_cert_file           = '/etc/ssl/certs/ssl-cert-snakeoil.pem',
  $site_ssl_cert_file_contents  = undef,
  $site_ssl_chain_file          = undef,
  $site_ssl_chain_file_contents = undef,
  $site_ssl_key_file            = '/etc/ssl/private/ssl-cert-snakeoil.key',
  $site_ssl_key_file_contents   = undef,
) {
  include ::httpd::ssl

  # site x509 certificate
  if $site_ssl_cert_file_contents != undef {
    file { $site_ssl_cert_file:
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => $site_ssl_cert_file_contents,
      before  => Httpd::Vhost[$site_name],
    }
  }

  # site ssl key
  if $site_ssl_key_file_contents != undef {
    file { $site_ssl_key_file:
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => $site_ssl_key_file_contents,
      before  => Httpd::Vhost[$site_name],
    }
  }

  # site ca certificates file
  if $site_ssl_chain_file_contents != undef {
    file { $site_ssl_chain_file:
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => $site_ssl_chain_file_contents,
      before  => Httpd::Vhost[$site_name],
    }
  }
}
