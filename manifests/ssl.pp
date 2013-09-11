class rancid::ssl inherits rancid::init {

  file { '/etc/httpd/ssl':
    ensure => 'directory',
    require => Exec['rancid-install'],
  }

  exec {'generate-ssl-key':
    command => "/usr/bin/openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/httpd/ssl/rancid.key -out /etc/httpd/ssl/rancid.crt -subj \"${key_dname}\"",
    require => File['/etc/httpd/ssl'],
    unless    => "/usr/bin/test -f  /etc/httpd/ssl/rancid.key",
  }

}
