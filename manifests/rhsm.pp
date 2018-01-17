# Class: yum
#
# This module manages yum
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class yum::rhsm ($ensure = 'present', $enable_repo = 'false') {

  case $::operatingsystem {
    'RedHat': {
      case $::operatingsystemrelease {
          /5.*/: {
            $certsource = $::architecture ? {
              /i386/    => "/usr/share/rhsm/product/RHEL-5/Server-Server-i386-ba236be3b27a-69.pem",
              /x86_64/  => "/usr/share/rhsm/product/RHEL-5/Server-Server-x86_64-dfb340743a6e-69.pem",
            }
          }
          /6.*/: {
            $certsource = $::architecture ? {
              /i386/    => "/usr/share/rhsm/product/RHEL-6/Server-Server-i386-22b9cd3d84b0-69.pem",
              /x86_64/  => "/usr/share/rhsm/product/RHEL-6/Server-Server-x86_64-6f455e15aed9-69.pem",
            }
          }
      }
    }
    default: { fail("${::operatingsystem} does not support redhat subscription manager") }
  }

  case $enable_repo {
    true: {
      $_enable_repo = '1'
    }
    false: {
      $_enable_repo = '0'
    }
    default: {
      fail("Yum::Rhsm['enable_repo']: parameter enable must be true or false")
    }
  }

  if $ensure in [ present, absent, purged ] {
    $ensure_real = $ensure
  } else {
    fail("Yum::rhsm[${title}]: parameter ensure must be present, absent or purged")
  }

  file { '/etc/pki/product/69.pem':
    ensure => $ensure_real,
    source => $certsource,
  }

  augeas { 'rhsm-enable':
      incl    => '/etc/yum/pluginconf.d/subscription-manager.conf',
      lens    => 'Yum.lns',
      context => '/files/etc/yum/pluginconf.d/subscription-manager.conf/main',
      changes => "set enabled ${_enable_repo}",
  }
}
