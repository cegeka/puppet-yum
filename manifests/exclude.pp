# == Definition: yum::exclude
#
# Manages the exclusion of packages
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
# [*content*] The desired value of the exclude (no default).
#           - Required: yes
#           - Content: String | Integer
#
# === Sample Usage:
#
# Yum settings can be managed using:
#
#   yum::exclude { 'percona': content => 'Percona-Server-*' }
#
# Removing an existing setting:
#
#   yum::exclude { 'percona': ensure => 'absent' }
#
define yum::exclude ( $ensure = 'present', $content = undef ) {

  ensure_resource('file','/etc/yum/exclude',{ensure => 'directory'})

  file { "/etc/yum/exclude/${title}.conf":
    ensure  => $ensure,
    content => $content
  }

}
