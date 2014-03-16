#!/bin/bash
# for sendmail to bypass spam filtering
echo "user_pref(\"browser.sessionstore.resume_from_crash\", false);" >> ~/.mozilla/firefox/*.default/prefs.js
echo "user_pref(\"browser.download.manager.showWhenStarting\", false);" >> ~/.mozilla/firefox/*.default/prefs.js
yum -y install sendmail-cf
cp -f $SQAROOT/tools/1.0/testbed/sendmail/sendmail.mc /etc/mail/.
make -C /etc/mail
cp -f $SQAROOT/tools/1.0/testbed/sendmail/sendmail.cf /etc/mail/.
service sendmail restart
yum -y install nmap
yum -y install isic
yum -y install wireshark*
yum -y install vnc*
yum -y install emacs*
yum -y install perl-CPAN*
yum -y install ruby ruby-libs ruby-mode ruby-rdoc ruby-irb ruby-ri ruby-docs ruby-dev*
yum -y install mysql
yum -y install mysql-devel*
yum -y install perl-DBD-MySQL.i386

tar -xvf rubygems-1.3.1.tgz 
cd rubygems-1.3.1
ruby setup.rb
cd ..
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



#create a firefox profile 
killall firefox
echo " Make sure enter automation as profile manager"
firefox -ProfileManager
# add jssh
firefox --install-global-extension jssh-20081108-Linux.xpi
# add bypass certificate error
firefox --install-global-extension remember_certificate_exception-0.8.0-fx.xpi
echo " make sure that  /usr/lib/firefox-*/extensions/jssh@extensions.mozilla.org is existed"
ls -al /usr/lib/firefox-*/extensions/jssh@extensions.mozilla.org

perl -MCPAN -e"force install autobundle"
perl -MCPAN -e"force install Test::More"
perl -MCPAN -e"force install Bundle::CPAN"
perl -MCPAN -e"force install Log::Log4perl"
perl -MCPAN -e"force install Expect"
perl -MCPAN -e"force install XML::Simple"
perl -MCPAN -e"force install XML::SAX"
perl -MCPAN -e"force install XML::SAX::Expat"
perl -MCPAN -e"force install Net::LDAP"
perl -MCPAN -e"force install JSON"
#in Eclipse debug mode, this package can get detail of user variable 
perl -MCPAN -e"force install PadWalker"
perl -MCPAN -MLog::Log4perl -MExpect -MXML::Simple -e "print holla"
perl -MCPAN -e"force install Proc::ProcessTable"
perl -MCPAN -e"force install DBI"
perl -MCPAN -e"force install DBD::mysql"
perl -MCPAN -e"force install Spreadsheet::WriteExcel"
perl -MCPAN -e"force install WWW::Selenium"
