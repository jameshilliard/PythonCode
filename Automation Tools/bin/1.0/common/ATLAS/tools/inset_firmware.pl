#!/usr/bin/perl -w
#-----------------------------------------------------------------
# inset_firmware.pl
# Name: Hugo
# Contact: shqa@actiontec.com
# Description: insert data into table firmware in ATLAS
# 
# Options:
#          -p product name
#          -v fw version
#          -d database ip address
#          -r remove
#
# Copyright @ Actiontec Ltd.
#----------------------------------------------------------------
use DBI;
use Getopt::Long;
use strict;

my $isLocal = 'false';
my $usage = "Usage:\t-p <produt name> e.g. bhr2e bhr2f\n\t-v <fw version> e.g. 20.13.2\n\t-d <database ipaddress>\n\t-r <remove the entry in database>
e.g.
perl inset_firmware.pl -p bhr2e -v 20.13.2 -d 192.168.10.238
perl inset_firmware.pl -p bhr2e -v 20.13.2 -d 192.168.10.238 -r";
my %userInput = ( "productName" => 'NULL',
	"fwVersion" => 'NULL',
	"ipAddress" => '127.0.0.1',
	"removeFW" => 0,
	);
GetOptions ( "h|help" => \$userInput{help},
	"p=s"=> \$userInput{productName},
	"v=s" => \$userInput{fwVersion},
	"d=s" => \$userInput{ipAddress},
	"r" => \$userInput{removeFW},
	);
if ($userInput{help}) {
   print "$usage\n\n";
   exit 0;
}
if ($userInput{productName} eq 'NULL') {
   print "$usage \n\n";
   exit 0;
}
if ($userInput{fwVersion} eq 'NULL') {
   print "$usage \n\n";
   exit 0;
}
if ($userInput{ipAddress} eq '127.0.0.1') {
   print "\n\tAre you sure database is running on local system(y/n)?";
   while (defined (my $line = <STDIN>)) {
        chomp($line);
	if ($line =~ /^y/) {
	    $isLocal = 'true';
            last;
	} elsif ($line =~ /^n/) {
            print "$usage\n\n";
            exit 0;
	}
   print "\tAre you sure database is running on local system(y/n)?";	
   }
}

my $dsn;
if ($isLocal eq 'true') {
    $dsn = "DBI:mysql:database=ATLAS";
} elsif ($isLocal eq 'false') {
    $dsn = "DBI:mysql:database=ATLAS;host=$userInput{ipAddress}";
}

my $dbh = DBI->connect( $dsn, 'actiontec', 'actiontec', 
               { RaiseError =>1, PrintError => 0 });
my $preState_fw = "insert into firmware value";
print "\n\n\tDO NOT CANNCEL IT!\n";
SWITCH: {
    $userInput{productName} eq 'bhr2e' && do {last;};
    $userInput{productName} eq 'bhr2f' && do {last;};
    print "\n\n\tProduct name - $userInput{productName} is NOT CORRECT!\n";
    print "\t$usage\n";
    exit 0;
	}
# insert or delete firmware
my $statement_fw;
if ($userInput{removeFW}) {
  print "\tDeleting table - firmware ";
  $statement_fw = "delete from firmware where FWVersion="."'$userInput{fwVersion}'";
  $dbh->do($statement_fw);
} else {
  print "\tInserting table - firmware ";
  $statement_fw = $preState_fw."('$userInput{fwVersion}', '$userInput{productName}', 'MI424WR-GEN2.rmt', '')";
  $dbh->do($statement_fw);
}
print "\n\tOK! Done\n";
$dbh->disconnect;
