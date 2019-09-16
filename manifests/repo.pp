define yum::repo(
  $ensure = present,
  $baseurl = undef,
  $descr = undef,
  $enabled = true,
  $gpgcheck = true,
  $gpgkey = undef,
  $sslverify = 'false',
  $sslcacert = undef,
  $sslclientcert = undef,
  $sslclientkey = undef,
  $metadata_expire = undef,
  $exclude = undef
) {

  if $ensure in [ present, absent ] {
    $ensure_real = $ensure
  }
  else {
    fail("Yum::Repo[${title}]: parameter ensure must be present or absent")
  }

  case $ensure_real {
    'absent': {
      file { "/etc/yum.repos.d/${title}.repo":
        ensure => absent
      }
    }
    'present': {
      if $baseurl == undef { fail("Yum::Repo['baseurl']: parameter must be defined") }

      yumrepo { $title:
        baseurl         => $baseurl,
        descr           => $descr,
        enabled         => $enabled,
        gpgcheck        => $gpgcheck,
        gpgkey          => $gpgkey,
        sslverify       => $sslverify,
        sslcacert       => $sslcacert,
        sslclientcert   => $sslclientcert,
        sslclientkey    => $sslclientkey,
        metadata_expire => $metadata_expire,
        exclude         => $exclude
      }
    }
    default: { notice("Yum::Repo[${title}]: parameter ensure must be present or absent") }
  }

}
