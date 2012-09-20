define yum::plugin( $ensure = undef ) {
  include yum::params

  if $ensure in [ present, absent ] {
    $ensure_real = $ensure
  }
  else {
    fail("Yum::Plugin[${title}]: parameter ensure must be present or absent")
  }

  package { $yum::params::pluginname:
    ensure => $ensure_real,
  }
}
