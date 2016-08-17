define yum::gpgkey (
  $ensure = present,
  $path = undef,
  $source = undef,
  $owner = undef,
  $group = undef,
  $mode = undef
) {

  if $ensure in [ present, absent ] {
    $ensure_real = $ensure
  }
  else {
    fail("Yum::Gpgkey[${title}]: parameter ensure must be present or absent")
  }

  case $ensure_real {
    'absent': {
      file { $path :
        ensure => absent
      }
    }
    'present': {
      file { $path :
        owner  => $owner,
        group  => $group,
        mode   => $mode,
        source => $source
      }
    }
    default: {}
  }
}
