#!/bin/bash 

# yum install packages


# perl packages,others by CPAN
yum -y  install perl-Expect
yum -y  install perl-CPAN*

# python packages
yum -y install pexpect

# ruby packages
yum -y  install ruby rubygems ruby-libs ruby-mode ruby-rdoc ruby-irb ruby-ri ruby-docs ruby-dev*



#yum -y install emacs*
# database packages
#yum -y install mysql
#yum -y install mysql-devel*
#yum -y install perl-DBD-MySQL.i386


yum -y install wine
yum -y install git-client
yum -y install sendmail-cf

# install program tools
yum -y install gvim
yum -y install geany

# install common tools
yum -y install gftp leafpad iperf
yum -y install nmap wireshark*
yum -y install isic
yum -y install vnc*

