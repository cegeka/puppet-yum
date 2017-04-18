define yum::repo(
  $ensure = present,
  $scheme = undef,
  $host = undef,
  $repo_root = undef,
  $descr = undef,
  $enabled = '1',
  $gpgcheck = '1',
  $gpgkey = undef,
  $sslverify = 'False',
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
      if $scheme == undef { fail("Yum::Repo['scheme']: parameter must be defined") }
      if $host == undef { fail("Yum::Repo['host']: parameter must be defined") }
      if $repo_root == undef { fail("Yum::Repo['repo_root']: parameter must be defined") }

      $baseurl = "${scheme}://${host}/${repo_root}"

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
