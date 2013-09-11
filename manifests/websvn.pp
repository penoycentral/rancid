class rancid::websvn inherits rancid::install {

  puppi::netinstall { 'websvn':
    url                 => 'http://websvn.tigris.org/files/documents/1380/49056/websvn-2.3.3.tar.gz',
    destination_dir     => '/var/www/html',
    owner               => 'root',
    group               => 'apache',
    postextract_command => 'ln -s /var/www/html/websvn-* /var/www/html/websvn',
    before              => File['/var/www/html/websvn/include/config.php'],
  }


  file { '/var/www/html/websvn/include/config.php':
    source => "puppet:///modules/rancid/config.php",
    owner  => 'root',
    group  => 'apache',
  }

  file {'/etc/httpd/conf.d/rancid.websvn.conf':
    ensure  => present,
    content => template("rancid.websvn.erb"),
    notify  => Service["httpd"],
  }



}
