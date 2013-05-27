define yum::setting( $ensure = 'present', $value = undef ) {

  Augeas {
    incl    => '/etc/yum.conf',
    lens    => 'Yum.lns',
    context => '/files/etc/yum.conf/main',
  }

  case $::osfamily {
    'RedHat': {
      case $ensure {
        'absent': {
          augeas { "yum::setting::${title}":
            changes => "rm ${title}",
            onlyif  => "match ${title} size > 0",
          }
        }
        'present': {
          if ($value == undef) or ! (is_string($value) or is_integer($value)) {
            fail("Yum::Setting[${title}]: required parameter value must be a non-empty string or integer")
          }
          else {
            augeas { "yum::setting::${title}":
              changes => "set ${title} ${value}",
              onlyif  => "match ${title}[. = ${value}] size == 0",
            }
          }
        }
        default: {
          fail("Yum::Setting[${title}]: parameter ensure must be present or absent")
        }
      }


    }
    default: {
      fail("Yum::Setting[${title}]: only supported on osfamily RedHat")
    }
  }
}
