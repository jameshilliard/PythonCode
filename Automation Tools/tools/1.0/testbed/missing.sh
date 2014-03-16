#!/bin/bash
echo "user_pref(\"browser.sessionstore.resume_from_crash\", false);" >> ~/.mozilla/firefox/*.default/prefs.js
echo "user_pref(\"browser.download.manager.showWhenStarting\", false);" >> ~/.mozilla/firefox/*.default/prefs.js
# for sendmail to bypass spam filtering
yum -y install sendmail-cf
cp -f $SQAROOT/tools/1.0/testbed/sendmail/sendmail.mc /etc/mail/.
make -C /etc/mail
cp -f $SQAROOT/tools/1.0/testbed/sendmail/sendmail.cf /etc/mail/.
service sendmail restart
yum -y install nmap
yum -y install isic
yum -y  install ruby ruby-libs ruby-mode ruby-rdoc ruby-irb ruby-ri ruby-docs ruby-dev*
gem install ruby-serialport
gem install firewatir
gem install terminator
gem install json
pushd /usr/lib/ruby/gems/1.8/gems/json-*
ruby install.rb
popd 
# add after 07/09/2009
gem install mechanize
gem install prawn-core
gem install prawn-layout
gem install prawn-format
perl -MCPAN -e"force install JSON"
#in Eclipse debug mode, this package can get detail of user variable 
perl -MCPAN -e"force install PadWalker"

