define yum::repo(
                  $scheme,
                  $host,
                  $repo_root,
                  $ensure = present,
                  $descr = undef,
                  $enabled = '1',
                  $gpgcheck = '1',
                  $sslverify = 'False',
                  $sslcacert = undef,
                  $sslclientcert = undef,
                  $sslclientkey = undef,
                  $metadata_expire = undef
                ) {

  if $ensure in [ present, absent ] {
    $ensure_real = $ensure
  }
  else {
    fail("Yum::Repo[${title}]: parameter ensure must be present or absent")
  }

  case $ensure_real {
    'absent':
      {
        file { "/etc/yum.repos.d/${title}.repo":
          ensure => absent
        }
      }
    'present':
      {
        $baseurl = "${scheme}://${host}/${repo_root}"

        yumrepo { $title:
          baseurl         => $baseurl,
          descr           => $descr,
          enabled         => $enabled,
          gpgcheck        => $gpgcheck,
          sslverify       => $sslverify,
          sslcacert       => $sslcacert,
          sslclientcert   => $sslclientcert,
          sslclientkey    => $sslclientkey,
          metadata_expire => $metadata_expire,
        }
      }
    default: { notice('The given ensure parameter is not supported') }
  }
}
