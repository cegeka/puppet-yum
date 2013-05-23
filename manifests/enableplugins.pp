define yum:enableplugins (ensure = 'present') {
  case $::operatingsystem {
    redhat: {
      augeas {"enable_plugins":
        changes =>  [ "set /files/etc/yum.conf/plugins true"],
    }
  }
}
