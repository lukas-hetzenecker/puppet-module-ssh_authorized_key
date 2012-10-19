class pxp_ssh_authorized_key::presentuser( $accounts = ['root'] ){

  pxp_ssh_authorized_key { 
   'presentkey' :
     ensure      => present,
     key_comment => 'presentuser',
     key_type    => 'ssh-rsa',
     key_options => ['from="localhost"', 'aaa="bbb"', 'ccc="eee"'],
     accounts    => $accounts,
  }

}

