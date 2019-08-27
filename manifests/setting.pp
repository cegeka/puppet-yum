# == Definition: yum::setting
#
# Manages settings in the main section of the yum configuration file
#
# === Parameters:
#
# [*title*] The name of the setting (no default).
#           - Required: yes
#           - Content: String
#
# [*ensure*] The desired state for the setting (default: 'present').
#            - Required: no
#            - Content: 'present' | 'absent'
#
# [*value*] The desired value of the setting (no default).
#           - Required: yes
#           - Content: String | Integer
#
# === Sample Usage:
#
# Yum settings can be managed using:
#
#   yum::setting { 'plugins': value => '1' }
#
# Removing an existing setting:
#
#   yum::setting { 'cachedir': ensure => 'absent' }
#
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
            if versioncmp($::operatingsystemmajrelease, '7') < 0 { #use augeas for rhel systems <= 6
              augeas { "yum::setting::${title}":
                changes => "set ${title} ${value}",
                onlyif  => "match ${title}[. = ${value}] size == 0",
              }
            } else {
              ini_setting { "yum::setting::${title}": #in rhel7 augeas is broken for yum.conf, ini_setting is required
                ensure            => present,
                path              => '/etc/yum.conf',
                section           => 'main',
                setting           => $title,
                value             => $value,
                key_val_separator => '='
              }
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
