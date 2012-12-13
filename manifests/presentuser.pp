class pxp_ssh_authorized_key::presentuser( $present_accounts = ['root'], $absent_accounts = [] ){

  pxp_ssh_authorized_key { 
   'presentkey' :
     key_comment       => 'presentuser',
     key_type          => 'ssh-rsa',
     key_options       => ['from="localhost"', 'aaa="bbb"', 'ccc="eee"'],
     present_accounts  => $present_accounts,
     absent_accounts   => $absent_accounts
  }

}

