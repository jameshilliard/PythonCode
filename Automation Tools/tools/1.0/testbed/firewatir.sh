mkdir junk
cd junk
wget -q http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz
ls
tar -xvf rubygems-1.3.5.tgz 
cd rubygems-1.3.5
ruby setup.rb
gem install firewatir