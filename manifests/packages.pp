class linux_base::packages {

   package {
      [
       'cifs-utils',
       'screen',
       'bash-completion',
       'wget',
       'traceroute',
       'tmpwatch',
       'vim-enhanced',
       'policycoreutils-python',
       'rsync',
       'crontabs',
       'logwatch'
      ]:
      ensure => 'latest',
   }

}
