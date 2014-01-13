#--------------------------------------------------------------------
#  Get_Firmware.pm
#  Name: Hugo
#  Contact: shqa@actiontec.com
#  Description: Normally, the ip address of ftp server is same as
#         LogServer, however, it's better use its private ip in case 
#         the network consume is lower. For how the interfaces defined
#         in LogServer, please refer to the topology.
#  Options:
#         ftphost	ftp server ip address
#         ftpuser	ftp login user name
#         ftppasswd	ftp login password
#         firmfile	the file name
#
#  Copyright @ Actiontec Ltd.
#--------------------------------------------------------------------
package Get_Firmware;

use Net::FTP;
use strict;

sub get_firmware {
  shift @_;
  my ($ftphost, $ftpuser, $ftppasswd, $ftpdir, $firmfile) = @_;
  my $localdir = $ENV{'SQAROOT'};
  $localdir = $localdir.'/'.'download'.'/'; 

  my $ftp = Net::FTP->new($ftphost) or return 'false';
  $ftp->login($ftpuser, $ftppasswd) or return 'false';
  $ftp->cwd($ftpdir) or return 'false';
  $ftp->get($firmfile, $localdir.$firmfile) or return 'false';
  $ftp->quit;
  warn "File retrieved: $firmfile\n";
  return 'true';
}

1;
