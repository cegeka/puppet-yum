class yum::params {
  case $::operatingsystem {
    redhat, centos: {
      # Dirty hack because redhat doesn't follow conventions
      if ($title == 'rhn-plugin') {
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
}
