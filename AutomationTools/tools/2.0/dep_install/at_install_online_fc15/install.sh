#!/bin/bash
############################ yum install
bash yum_install.sh
########################### gem install packages
bash gem_install.sh
########################### firefox plugin
### Discard now
###bash firefox_setup.sh
############################ cpan install 
bash cpan_install.sh
############################ local packages
# install python packages
bash tar_install.sh
############################ git clone
### for developer
#bash git_install.sh

############################# mail setting
### not use 
#echo 'Please do mail_setting.sh after git clone'
###bash mail_setting.sh

