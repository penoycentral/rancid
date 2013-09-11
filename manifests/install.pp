class rancid::install inherits rancid::init {

  $pkg_install = ['git', 'automake', 'gcc', 'gcc-c++', 'make', 'expect', 'rsh', 'telnet',
                  'subversion', 'httpd', 'mod_dav_svn', 'wget', 'php', 'php-pear', 'openssl', 'mod_ssl', 'pam_ldap', 'mod_authz_ldap', 'openldap-clients' ]

  $rancid_dir = ['/var/lib/rancid', '/var/log/rancid', '/etc/rancid']

  package { $pkg_install:
    ensure => 'installed',
    before => [ Vcsrepo['/root/rancid-git'], Exec['rancid-install'] ],
  }

  service { 'httpd':
    ensure  => running,
    enable  => true,
    require => Package[$pkg_install],
  }

  vcsrepo { '/root/rancid-git':
    source   => 'git://github.com/dotwaffle/rancid-git',
    ensure   => 'present',
    provider => 'git',
    revision => 'master',
    before   => Exec['rancid-install'],
  }

  exec {
    "rancid-install":
      provider => 'shell',
      cwd      => '/root',
      command     => "cd /root/rancid-git && /usr/bin/aclocal && /usr/bin/autoheader && /usr/bin/automake && /usr/bin/autoconf &&
          ./configure --prefix=/var/lib/rancid --localstatedir=/var/lib/rancid/ --sysconfdir=/etc/rancid --with-svn && /usr/bin/make && /usr/bin/make install",
      refreshonly => "true",
      timeout      => 0,
      require      => Vcsrepo['/root/rancid-git'],
  }

  user {'rancid':
    ensure => 'present',
    home   => '/var/lib/rancid',
    shell  => '/bin/bash',
  }

  file { $rancid_dir:
    ensure => 'directory',
    owner  => 'rancid',
    group  => 'rancid',
    recurse => true,
  }

  exec { 'create_initial_devices_svn':
    command => '/var/lib/rancid/bin/rancid-cvs',
    user    => 'rancid',
    require => [ User['rancid'], Exec['rancid-install']],
    before  => File['/var/lib/rancid/svn'],
  }

  file { '/var/lib/rancid/svn':
    ensure  => directory,
    owner   => 'rancid',
    group   => 'apache',
    recurse => true,
    require => Exec['create_initial_devices_svn'],
  }

  exec { 'svn_permission_hack':
    command => "/bin/chmod g+w -R /var/lib/rancid/svn",
    onlyif  => "/usr/bin/test -d /var/lib/rancid/svn",
  }

  Exec['create_initial_devices_svn'] -> Exec['svn_permission_hack']


  file {'/etc/profile.d/rancid.sh':
    ensure  => 'present',
    content => 'export PATH=$PATH:/var/lib/rancid/bin',
    mode    => '0755',
  }

  file {'/etc/rancid/rancid.conf':
    ensure  => 'present',
    content => template("rancid/rancid.conf.erb"),
  }

  file { '/var/lib/rancid/.cloginrc':
    ensure => present,
    source => 'puppet:///modules/rancid/cloginrc',
    owner  => 'rancid',
    group  => 'rancid',
  }



}
