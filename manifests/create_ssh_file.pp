define ssh::create_ssh_file  {
  if $name == "root" {
    $home_dir = "/root"
  } else {
    $home_dir = "/home/${name}"
  }

  if !defined(User[$name]) {
    user {
      $name:
        ensure => present,
        managehome => true;
    }
  }

  if !defined(File['${home_dir}/.ssh/']) {
    file {
      "${home_dir}/.ssh/" :
        path    => "${home_dir}/.ssh/",
        ensure  => directory,
        mode    => 700,
        owner   => $name,
        group   => $name;
    }
  }

  if !defined(File['${home_dir}/.ssh/']) {
    file {
      "${home_dir}/.ssh/authorized_keys":
        ensure  => present,
        path    => "${home_dir}/.ssh/authorized_keys",
        mode    => 600,
        owner   => $name,
        group   => $name;
    }
  }

}

