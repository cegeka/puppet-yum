yum::plugin { 'rhn-plugin':
  ensure      => absent,
}
yum::plugin { 'fastestmirror':
  ensure      => absent,
}
