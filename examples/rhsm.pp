$::operatingsystem = 'redhat'
$::operatingsystemrelease = '6.3'

class { 'yum::rhsm':
  enable_repo => 'false'
}
