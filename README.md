SSH authorized key management for puppet
========================================

Copyright
---------

Copyright (C) 2012 Wunderman PXP GmbH  
Lukas Hetzenecker <lukas.hetzenecker@wunderman.com>

Introduction
------------

This module was created because the "ssh_authorized_key" resource of Puppet has some
shortcomings, which were inadmissible for our SSH key management.

These shortcomings are:
 - It is not possible to have an identical user (a identical ssh key comment and fingerprint)
   in multiple local accounts (authorized_key files) on the same host.  
   A possible workarounds for this is available in the section below.

 - The unique identifier for a SSH key is the comment, not the fingerprint.  
   This means that keys are treated equal if the comment matches.  
   The implementation of this module uses the SSH key fingerprint as resource identifier
   and an unique comment is only optionally enforced.

 - The user and target attributes do not accept arrays.  
   So it is not possible to have the same SSH key (comment and fingerprint) in multiple files.  
   This is releated to issue (1).

This module should fix the issues mentioned in Puppet Bug #1531 (http://projects.puppetlabs.com/issues/1531).

Source Code
-----------

The source code for this tool is available online at
http://github.com/lukas-hetzenecker/puppet-module-ssh_authorized_key

You can checkout the source code by installing the `git` distributed version
control system and running:

    git clone git://github.com/lukas-hetzenecker/puppet-module-ssh_authorized_key.git

Installation
------------

Rename the git checkout to 'pxp_ssh_authorized_key' and copy it to the module folder of your puppet installation.

Usage
-----

```
class pxp_ssh_authorized_key::absentuser( $accounts = ['root'] ){

  pxp_ssh_authorized_key { 
   'absentkey' :
     ensure      => absent,
     key_comment => 'absentuser',
     key_type    => 'ssh-rsa',
     accounts    => $accounts,
  }

}
```

This requires the manifest/init.pp file that is shipped with this module.

The relevant section is shown here: 

```
pxp_ssh_authorized_key_base {
    $name:
      ensure  => $ensure,
      comment => $key_comment,
      type    => $key_type,
      user    => $accounts,
      options => $key_options,
      uniquecomment => true;
  }
```

Please note that contrary to the 'ssh_authorized_key' from Puppet the
fingerprint is used as resource identifier and the user / target attributes
support arrays.

There is also an uniquecomment attribute that specifies if the key comment
should be unique too.  
This allows you to change the key for one user, without setting the fingerprint
to absent first.

Management of the accounts in Foreman
-------------------------------------

The current git master branch of Foreman support parameterized classes.
If you use the method described in the section above you can easily add 
the SSH user to hosts or host groups in Foreman (and even override the
local user accounts if you want to).

Prior workarounds to support multiple local accounts with the same SSH key
--------------------------------------------------------------------------

(coming soon...)

