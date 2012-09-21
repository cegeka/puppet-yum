yum::plugin { 'rhn-plugin':
  ensure      => absent,
}
yum::plugin { 'fastestmirrors':
  ensure      => absent,
}
