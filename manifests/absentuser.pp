class pxp_ssh_authorized_key::absentuser( $present_accounts = [], absent_accounts = ['root'] ){

  pxp_ssh_authorized_key { 
   'absentkey' :
     key_comment       => 'absentuser',
     key_type          => 'ssh-rsa',
     present_accounts  => $present_accounts,
     absent_accounts   => $absent_accounts
  }

}

