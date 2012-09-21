define yum::plugin ( $ensure = 'present') {
  case $::operatingsystem {
    redhat, centos: {
      # Dirty hack because redhat doesn't follow conventions
      if ( $title == 'rhn-plugin' ) {
        $pluginname = 'yum-rhn-plugin'
      } else {
        $pluginname = $::operatingsystemrelease ? {
          /5.*/ => "yum-${title}",
          /6.*/ => "yum-plugin-${title}",
        }
      }
    }
    default: { fail("${::operatingsystem} is not yet supported") }
  }

  if $ensure in [ present, absent, purged ] {
    $ensure_real = $ensure
  } else {
    fail("Yum::Plugin[${title}]: parameter ensure must be present, absent or purged")
  }

  package { $pluginname:
    ensure => $ensure_real,
  }
}
