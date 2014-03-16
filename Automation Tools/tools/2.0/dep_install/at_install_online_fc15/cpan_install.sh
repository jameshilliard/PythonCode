#!/bin/bash

# perl cpan install packages
perl -MCPAN -e"force install Expect"
perl -MCPAN -e"force install autobundle"
perl -MCPAN -e"force install Test::More"
perl -MCPAN -e"force install Bundle::CPAN"
#perl -MCPAN -e"force install Log::Log4perl"
perl -MCPAN -e"force install XML::Simple"
perl -MCPAN -e"force install XML::Parser"
perl -MCPAN -e"force install XML::SAX::Expat"
perl -MCPAN -e"force install XML::SAX"
perl -MCPAN -e"force install Net::LDAP"
#perl -MCPAN -e"force install JSON"
#in Eclipse debug mode, this package can get detail of user variable 
perl -MCPAN -e"force install PadWalker"
#perl -MCPAN -MLog::Log4perl -MExpect -MXML::Simple -e "print holla"
perl -MCPAN -e"force install Proc::ProcessTable"
#perl -MCPAN -e"force install DBI"
#perl -MCPAN -e"force install DBD::mysql"

