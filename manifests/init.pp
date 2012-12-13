# SSH authorized key management for puppet
#
# Copyright (C) 2012 Wunderman PXP GmbH
# Lukas Hetzenecker <lukas.hetzenecker@wunderman.com>

define ssh (
  $key_fingerprint,
  $key_comment,
  $key_type = 'ssh-rsa',
  $key_options = [],
  $present_accounts = ['root'],
  $absent_accounts = []
){

  #ssh::create_ssh_file {
  #  $accounts:
  #}

  pxp_ssh_authorized_key_base {
    $name:
      ensure      => "present",
      fingerprint => $key_fingerprint,
      comment     => $key_comment,
      type        => $key_type,
      user        => $present_accounts,
      options     => $key_options,
      uniquecomment => true;
  }

  pxp_ssh_authorized_key_base {
    "$name absent":
      ensure      => absent,
      fingerprint => $key_fingerprint,
      comment     => $key_comment,
      type        => $key_type,
      user        => $absent_accounts,
      options     => $key_options,
      uniquecomment => true;
  }

  #User[ $name ] -> File["{home_dir}/.ssh/"] -> File["{home_dir}/.ssh/authorized_keys"] -> Ssh_authorized_key["${key_user} -> ${name}"]

}

