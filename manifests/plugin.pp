define yum::plugin( $ensure = undef ) {
  if $ensure in [ present, absent ] {
    $ensure_real = $ensure
  }
  else {
    fail("Yum::Plugin[${title}]: parameter ensure must be present or absent")
  }
  case $::operatingsystem {
    redhat, centos: {
      $pluginname = $::operatingsystemrelease ? {
        /5.*/ => "yum-${title}",
        /6.*/ => "yum-plugin-${title}",
      }
    }
    default: { fail("${::operatingsystem} is not yet supported") }
  }

  package { $pluginname:
    ensure => $ensure_real,
  }
}
