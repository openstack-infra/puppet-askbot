# == Class: askbot::site::http
# This class describes the http server configuration
class askbot::site::http (
  $site_root,
  $site_name,
  $site_template = 'askbot/askbot.vhost.erb',
) {
  httpd::vhost { $site_name:
    port     => 80,
    priority => 10,
    docroot  => $site_root,
    template => $site_template,
  }
}
