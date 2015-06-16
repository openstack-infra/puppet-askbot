# == Class: askbot::site::ssl
# This class describes the http server's SSL configuration
class askbot::site::ssl (
  $site_ssl_cert_file_contents  = '',
  $site_ssl_key_file_contents   = '',
  $site_ssl_chain_file_contents = '',
  $site_ssl_cert_file           = '',
  $site_ssl_key_file            = '',
  $site_ssl_chain_file          = '',
) {
  include apache::ssl

  # site x509 certificate
  if $site_ssl_cert_file_contents != '' {
    file { $site_ssl_cert_file:
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => $site_ssl_cert_file_contents,
      before  => Apache::Vhost[$name],
    }
  }

  # site ssl key
  if $site_ssl_key_file_contents != '' {
    file { $site_ssl_key_file:
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => $site_ssl_key_file_contents,
      before  => Apache::Vhost[$name],
    }
  }

  # site ca certificates file
  if $site_ssl_chain_file_contents != '' {
    file { $site_ssl_chain_file:
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => $site_ssl_chain_file_contents,
      before  => Apache::Vhost[$name],
    }
  }
}
