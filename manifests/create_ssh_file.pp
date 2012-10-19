define pxp_ssh_authorized_key::create_ssh_file  {
  if $name == "root" {
    $home_dir = "/root"
  } else {
    $home_dir = "/home/${name}"
  }

  file {
    "${home_dir}/.ssh/" :
      path    => "${home_dir}/.ssh/",
      ensure  => directory,
      mode    => 700,
      owner   => $name,
      group   => $name;
    "${home_dir}/.ssh/authorized_keys":
      ensure  => present,
      path    => "${home_dir}/.ssh/authorized_keys",
      mode    => 600,
      owner   => $name,
      group   => $name;
  }

}

