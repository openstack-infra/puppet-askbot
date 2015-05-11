# == Class: askbot::site::static
# This class describes askbot site static files
class askbot::site::static (
  $site_root = undef,
) {
  file { "${site_root}/static":
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File[$site_root],
  }
}
