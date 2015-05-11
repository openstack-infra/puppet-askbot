# == Class: askbot::site::cron
# This class describes the askbot scheduled tasks
class askbot::site::cron (
  $site_root,
) {
  file { "${site_root}/cron":
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File[$site_root],
  }

  file { "${site_root}/cron/send_email_alerts.sh":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('askbot/cron/send_email_alerts.sh.erb'),
    require => File["${site_root}/cron"],
  }

  file { "${site_root}/cron/clean_session.sh":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('askbot/cron/clean_session.sh.erb'),
    require => File["${site_root}/cron"],
  }

  # 0 3 * * *
  cron { 'askbot-send-email-alerts':
    name    => 'askbot-send-mail-alerts.cron',
    command => "/bin/bash ${site_root}/cron/send_email_alerts.sh",
    user    => root,
    minute  => '0',
    hour    => '3',
    require => [
      File["${site_root}/cron/send_email_alerts.sh"],
      ]
  }

  # 10 * * * *
  cron { 'askbot-clean-session':
    name    => 'askbot-clean-session.cron',
    command => "/bin/bash ${site_root}/cron/clean_session.sh",
    user    => root,
    minute  => '10',
    require => [
      File["${site_root}/cron/clean_session.sh"],
      ]
  }
}
