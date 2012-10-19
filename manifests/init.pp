define pxp_ssh_authorized_key (
  $key_comment,
  $key_type = 'ssh-rsa',
  $key_options = [],
  $accounts = ['root'],
  $ensure = 'present',
){

#  user { 
#    $accounts: 
#      ensure => present,
#      managehome => true;
#  }

#  pxp_ssh_authorized_key::create_ssh_file {
#    $accounts:
#  }

  pxp_ssh_authorized_key_base {
    $name:
      ensure  => $ensure,
      comment => $key_comment,
      type    => $key_type,
      user    => $accounts,
      options => $key_options,
      uniquecomment => true;
  }

  #User[ $name ] -> File["{home_dir}/.ssh/"] -> File["{home_dir}/.ssh/authorized_keys"] -> Ssh_authorized_key["${key_user} -> ${name}"]

}

