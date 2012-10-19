class pxp_ssh_authorized_key::absentuser( $accounts = ['root'] ){

  pxp_ssh_authorized_key { 
   'absentkey' :
     ensure      => absent,
     key_comment => 'absentuser',
     key_type    => 'ssh-rsa',
     accounts    => $accounts,
  }

}

