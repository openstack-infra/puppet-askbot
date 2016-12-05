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

  # gzip old jetty logs
  cron { 'jetty-log-gzip':
    user        =>  'root',
    hours       =>  '1',
    minute      =>  '0',
    # Jetty just outputs to a log file YYYY_mm_dd.log, thus
    # we do not want to touch the current days log as that is active
    command     => "find /var/log/jetty ! -name \"$(date +%Y_%m_%d)*.log\" -name '*.log' -execdir gzip {} \\;",
    environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin'
  }

  # gzip old jetty logs
  cron { 'jetty-log-gzip':
    user        =>  'root',
    hours       =>  '1',
    minute      =>  '30',
    # because we're gzipping logs behind jetty's back, remove the old
    # logs after a period.
    command     => "find /var/log/jetty -name '*.log.gz' -mtime +7  -execdir rm {} \\;",
    environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin'
  }

}
