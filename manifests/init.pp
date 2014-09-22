
# base components that will be instal on all linux hosts
class linux_base {
   
   include 'linux_base::groups'
   include 'linux_base::packages'
   include 'linux_base::sudoerss'
   include 'linux_base::users'
   class {'sshd': allowgroups => 'sysadmin'}
   include 'linux_base::snmpp'
   include 'linux_base::resolve'
   include 'linux_base::authconfigg'
   include 'linux_base::nagioss'
   include 'iptables'
   class {'linux_base::aliases': root => 'someone@somedomain'}
   class {'epel':}

}




class linux_base::nagioss {


}

class linux_base::nagioss {
   include 'nagios::nrpe'
   include 'nagios::export'

}


class linux_base::authconfigg {

   package {'samba-winbind':
      ensure => latest,
   }

   class { 'authconfig' :
      cache       => true,
      winbind     => true,
      winbindauth => true,
      smbsecurity => 'ads',
      smbservers  => ['infra01.somedomain.com','infra02.somedomain.com'],
      smbrealm    => 'somedomain.com',
      winbindjoin => 'joindomain@somedomain.com%Password',
      require => Package["samba-winbind"],
   }
}

class linux_base::resolve {

   import "resolver"

   resolv_conf { "somedomain.com":
      domainname  => "somedomain.com",
      searchpath  => ['somedomain.com', 'somedomain.net'],
      nameservers => ['192.168.0.1', '192.168.0.2', '8.8.8.8'],
   }

}


class linux_base::snmpp {

    class {'snmp':
      ro_community => 'readonly',
      contact => 'someone@somedomain',
      location => 'Sydney, Australia',
   }
   
   
   firewall { '100 allow SNMP access':
      port   => [161],
      proto  => udp,
      action => accept,
   }


}

class linux_base::aliases 
   ($root = 'root@localhost')
 {
   file_line { '/etc/aliases':
     ensure => present,
     path => '/etc/aliases',
     match => '^root:.*$',
     line => "root: $root",
   }

   exec { newaliases:
     path        => ["/usr/bin", "/usr/sbin"],
     subscribe   => File_line['/etc/aliases'],
     refreshonly => true
   }
 }



# USERS
class linux_base::users {
  
   user { 'root':
     ensure           => 'present',
     comment          => 'root',
     gid              => '0',
     home             => '/root',
     password         => '<hidden>',
     password_max_age => '99999',
     password_min_age => '0',
     shell            => '/bin/bash',
     uid              => '0',
     managehome       => 'true',
   }

   user { 'admin':
     ensure           => 'present',
     comment          => 'Admin User',
     home             => '/home/admin',
     password         => '<hidden>',
     password_max_age => '99999',
     password_min_age => '0',
     shell            => '/bin/bash',
     managehome       => 'true',
     groups           => 'sysadmin',
   }

}




define sudoers
(
   $filename,
   $content,
) 
{
   package { 'sudo':
     ensure => 'latest',
   }

   file { "/etc/sudoers.d/$filename":
       owner   => root,
       group   => root,
       mode    => 440,
       content => "$content",
       require => Package["sudo"],
   }
}


# SUDOERS
class linux_base::sudoerss {


   package { 'sudo':
     ensure => 'latest',
   }

   #file { "/etc/sudoers.d/domainadmins":
   #    owner   => root,
   #    group   => root,
   #    mode    => 440,
   #    content => "%DOMAIN\\\\domain\ admins   ALL=(ALL)  ALL",
   #    require => Package["sudo"],
   #}

   sudoers {'sysadmin':
      filename => 'sysadmin',
      content  => "%sysadmin        ALL=(ALL)  ALL",
   }

   sudoers {'domainadmins': 
      filename => 'domainadmins',
      content  => "%DOMAIN\\\\domain\ admins   ALL=(ALL)  ALL",
   }

   #file { "/etc/sudoers.d/sysadmin":
   #    owner   => root,
   #    group   => root,
   #    mode    => 440,
   #    content => "%sysadmin        ALL=(ALL)  ALL",
   #    require => Package["sudo"],
   #}

}

# GROUPS
class linux_base::groups {

   group { 'sysadmin':
     ensure => 'present',
     gid    => '10000',
   }
}


