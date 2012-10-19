class pxp_ssh_authorized_key::test() {
   class {'pxp_ssh_authorized_key::absentuser' : accounts => ['aaa', 'bbb'] }
   class {'pxp_ssh_authorized_key::presentuser' : accounts => ['aaa', 'bbb', 'ccc'] }
}
