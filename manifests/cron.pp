class rancid::cron {

  cron {
    "run rancid every 10 mins past the hour":
      command =>"/var/lib/rancid/bin/rancid-run",
      month => "*",
      monthday => "*",
      hour => "*",
      minute => "10",
  }

  cron {
    "at 23:45 every night clear out the logs":
      command => '/usr/bin/find /var/lib/rancid/logs -type f -mtime +2 -exec rm {} \;',
      month => "*",
      monthday => "*",
      hour => "23",
      minute => "45",
  }

}
