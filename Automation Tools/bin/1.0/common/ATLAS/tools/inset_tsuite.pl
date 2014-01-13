#!/usr/bin/perl -w
#-----------------------------------------------------------------
# inset_tsuite.pl
# Name: Hugo
# Contact: shqa@actiontec.com
# Description: insert data into table testsuite in ATLAS
# 
# Options:
#          -p product name
#          -v fw version
#          -d database ip address
#
# Copyright @ Actiontec Ltd.
#----------------------------------------------------------------
use DBI;
use Getopt::Long;
use threads;
use strict;

sub outscreen {
   print "=> ";
}

my $isLocal = 'false';
my $usage = "Usage:\t-p <produt name> e.g. bhr2e bhr2f\n\t-v <fw version> e.g. 20.13.2\n\t-d <database ipaddress>\n\t-r <remove the entry in database>
e.g.
perl inset_tsuite.pl -p bhr2e -v 20.13.2 -d 192.168.10.238
perl inset_tsuite.pl -p bhr2e -v 20.13.2 -d 192.168.10.238 -r
";
my %userInput = ( "productName" => 'NULL',
	"fwVersion" => 'NULL',
	"ipAddress" => '127.0.0.1',
	"removeTS" => 0,
	);
GetOptions ( "h|help" => \$userInput{help},
	"p=s"=> \$userInput{productName},
	"v=s" => \$userInput{fwVersion},
	"d=s" => \$userInput{ipAddress},
	"r" => \$userInput{removeTS},
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

my @arrayTs = (
	'sh_nc_all',
	'sh_nhoe_ether_0',
	'sh_nhoe_leasetime',
	'sh_mtu_laneth_to_wancoax',
	'sh_mtu_lancoax_to_waneth',
	'sh_pc_ether_0',
	'sh_bcc_all',
	'sh_bcc_leasetime',
	'sh_bcc_auto2pc',
	'sh_bce_all',
	'sh_bce_leasetime',
	'sh_wppp_all',
	'sh_wppp2_all',
	'sh_ads_ether_2pc',
	'sh_ads_coax_2pc',
	'sh_ala_ether_2pc',
	'sh_ala_coax_2pc',
	'sh_amc_ether_2pc',
	'sh_amc_coax_2pc',
	'sh_ara_ether_2pc',
	'sh_ara_coax_2pc',
	'sh_ad_ether_2pc',
	'sh_ad_coax_2pc',
	'sh_ard_ether_2pc',
	'sh_ard_coax_2pc',
	'sh_arr_ether_2pc',
	'sh_arr_coax_2pc',
	'sh_acf_ether_2pc',
	'sh_acf_coax_2pc',
	'sh_adt_ether_2pc',
	'sh_adt_coax_2pc',
	'sh_au_ether_2pc',
	'sh_au_coax_2pc',
	'sh_aipad_lan_ether',
	'sh_aipad_staticdhcp',
	'sh_addns_ether_2pc',
	'sh_addns_coax_2pc',
	'sh_asys_2pc',
	'sh_asys_4pc',
	'sh_arp_ether_4pc'
	);
my $dsn;
if ($isLocal eq 'true') {
    $dsn = "DBI:mysql:database=ATLAS";
} elsif ($isLocal eq 'false') {
    $dsn = "DBI:mysql:database=ATLAS;host=$userInput{ipAddress}";
}

my $dbh = DBI->connect( $dsn, 'actiontec', 'actiontec', 
               { RaiseError =>1, PrintError => 0 });
my $preState = "insert into testsuite value";
print "\n\n\tDO NOT CANNCEL IT!\n";
if ($userInput{removeTS}) {
     print "\tDeleting table - Testsuite ";
} else {
     print "\tInserting table - Testsuite ";
}
SWITCH: {
    $userInput{productName} eq 'bhr2e' && do {last;};
    $userInput{productName} eq 'bhr2f' && do {last;};
    print "\n\n\tProduct name - $userInput{productName} is NOT CORRECT!\n";
    print "\t$usage\n";
    exit 0;
	}
foreach (@arrayTs) {
     my $statement;
     if ($userInput{removeTS}) {
         $statement = "delete from testsuite where FWVersion="."'$userInput{fwVersion}'";
         $dbh->do($statement);
         my $thr = threads->new(\&outscreen);
         $thr->join();
     } else {
         $statement = $preState."('$_', '$userInput{productName}', '$userInput{fwVersion}', '')";
         $dbh->do($statement);
         my $thr = threads->new(\&outscreen);
         $thr->join();
     }
}
print "\n\tOK! Done\n";
$dbh->disconnect;
