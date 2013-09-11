define yum::plugin ($ensure = 'present', $enable = true) {
  case $::osfamily {
    redhat: {
      # Dirty hack because redhat doesn't follow conventions
      if ( $title == 'rhn-plugin' ) {
        $packagename = 'yum-rhn-plugin'
      } else {
        $packagename = $::operatingsystemrelease ? {
          /5.*/ => "yum-${title}",
          /6.*/ => "yum-plugin-${title}",
        }
      }
    }
    default: { fail("only supported on osfamily RedHat") }
  }

  if $ensure in [ present, absent, purged ] {
    $ensure_real = $ensure
  } else {
    fail("Yum::Plugin[${title}]: parameter ensure must be present, absent or purged")
  }

  case $enable {
    true: {
      $_enable = '1'
    }
    false: {
      $_enable = '0'
    }
    default: {
      fail("Yum::Plugin[${title}]: parameter enable must be true or false")
    }
  }

  package { $packagename:
    ensure => $ensure_real,
  }

  if $ensure_real == 'present' {
    augeas { "yum-plugin-${title}-enable":
      incl    => "/etc/yum/pluginconf.d/${title}.conf",
      lens    => 'Yum.lns',
      context => "/files/etc/yum/pluginconf.d/${title}.conf/main",
      changes => "set enabled ${_enable}",
      onlyif  => "match size enabled[. = '${_enable}'] == 0"
    }
  }
}
