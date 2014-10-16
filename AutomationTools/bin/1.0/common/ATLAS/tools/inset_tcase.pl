#!/usr/bin/perl -w
#-----------------------------------------------------------------
# inset_tcase.pl
# Name: Hugo
# Contact: shqa@actiontec.com
# Description: insert data into table testcase in ATLAS
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
my $usage = "Usage:\t-p <produt name> e.g. bhr2e bhr2f\n\t-v <fw version> e.g. 20.13.2\n\t-d <database ipaddress>\n\t-t <tsuite name> e.g. nhoe or all\n\t-r <remove tcase description in database>\n
\tnc
\tnhoe_ether
\tnhoe_leasetime
\tard_ether
\tarr_ether
\tacf
\tpc_ether
\tadt
\tau
\tarp
\tbcc_all
\tbcc_leasetime
\tbcc_auto2pc
\tbce_all
\tbce_leasetime
\taipad_lan_ether
\twppp
\twppp2_all
\taddns_ether
\tasys_2pc
\tasys_4pc
\tasys_syslog
\tads
\tala
\tamc_ether
\tamc_coax
\tara_ether
\tara_coax
\tad_ether
\tad_coax\n
e.g.
perl inset_tcase.pl -p bhr2e -v 20.10.3 -d 192.168.10.238 -t all
perl inset_tcase.pl -p bhr2f -v 20.10.3 -d 192.168.10.238 -t nhoe
perl inset_tcase.pl -p bhr2f -v 20.10.3 -d 192.168.10.238 -t nhoe -r
";
my %userInput = ( "productName" => 'NULL',
	"fwVersion" => 'NULL',
	"ipAddress" => '127.0.0.1',
	"tSuite" => 'NULL',
	"removeTC" => 0,
	);
GetOptions ( "h|help" => \$userInput{help},
	"p=s"=> \$userInput{productName},
	"v=s" => \$userInput{fwVersion},
	"d=s" => \$userInput{ipAddress},
	"t=s" => \$userInput{tSuite},
	"r" => \$userInput{removeTC},
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
if ($userInput{tSuite} eq 'NULL') {
   print "$usage \n\n";
   exit 0;
}

my @arrayTs;
if ($userInput{tSuite} eq 'all') {
     @arrayTs = (
        'sh_nc_all'          ,
        'sh_nhoe_ether_0'    ,
        'sh_nhoe_leasetime'  ,
        'sh_ard_ether_0'     ,
        'sh_arr_ether_0'     ,
        'sh_acf_all'         ,
        'sh_pc_ether_0'      ,
        'sh_adt_ether_0'     ,
        'sh_au_ether_0'      ,
        'sh_arp_ether_0'     ,
        'sh_bcc_all'         ,
        'sh_bcc_leasetime'   ,
        'sh_bcc_auto2pc'     ,
        'sh_bce_all'         ,
        'sh_bce_leasetime'   ,
        'sh_aipad_lan_ether' ,
        'sh_wppp_all'        ,
        'sh_wppp2_all'       ,
        'sh_addns_ether_0'   ,
        'sh_addns_coax_0'    ,
        'sh_asys_syslog'     ,
        'sh_asys_2pc'        ,
        'sh_asys_4pc'        ,
        'sh_ads_ether_0'     ,
        'sh_ala_ether_0'     ,
        'sh_amc_ether_0'     ,
        'sh_amc_coax_0'      ,
        'sh_ara_ether_0'     ,
        'sh_ara_coax_0'     ,
        'sh_ad_ether_0'      ,
        'sh_ad_coax_0'       
	);
} else {
   SWITCH: {
       $userInput{tSuite} eq 'nc' && do { @arrayTs = ('sh_nc_all'); last;};
       $userInput{tSuite} eq 'nhoe_ether' && do { @arrayTs = ('sh_nhoe_ether_0'); last;};
       $userInput{tSuite} eq 'nhoe_leasetime' && do { @arrayTs = ('sh_nhoe_leasetime'); last;};
       $userInput{tSuite} eq 'ard_ether' && do { @arrayTs = ('sh_ard_ether_0'); last;};
       $userInput{tSuite} eq 'arr_ether' && do { @arrayTs = ('sh_arr_ether_0'); last;};
       $userInput{tSuite} eq 'acf' && do { @arrayTs = ('sh_acf_all'); last;};
       $userInput{tSuite} eq 'pc_ether' && do { @arrayTs = ('sh_pc_ether_0'); last;};
       $userInput{tSuite} eq 'adt' && do { @arrayTs = ('sh_adt_ether_0'); last;};
       $userInput{tSuite} eq 'au' && do { @arrayTs = ('sh_au_ether_0'); last;};
       $userInput{tSuite} eq 'arp' && do { @arrayTs = ('sh_arp_ether_0'); last;};
       $userInput{tSuite} eq 'bcc_all' && do { @arrayTs = ('sh_bcc_all'); last;};
       $userInput{tSuite} eq 'bcc_leasetime' && do { @arrayTs = ('sh_bcc_leasetime'); last;};
       $userInput{tSuite} eq 'bcc_auto2pc' && do { @arrayTs = ('sh_bcc_auto2pc'); last;};
       $userInput{tSuite} eq 'bce_all' && do { @arrayTs = ('sh_bce_all'); last;};
       $userInput{tSuite} eq 'bce_leasetime' && do { @arrayTs = ('sh_bce_leasetime'); last;};
       $userInput{tSuite} eq 'aipad_lan_ether' && do { @arrayTs = ('sh_aipad_lan_ether'); last;};
       $userInput{tSuite} eq 'wppp' && do { @arrayTs = ('sh_wppp_all'); last;};
       $userInput{tSuite} eq 'wppp2_all' && do { @arrayTs = ('sh_wppp2_all'); last;};
       $userInput{tSuite} eq 'addns_ether' && do { @arrayTs = ('sh_addns_ether_0'); last;};
       $userInput{tSuite} eq 'addns_coax' && do { @arrayTs = ('sh_addns_coax_0'); last;};
       $userInput{tSuite} eq 'asys_2pc' && do { @arrayTs = ('sh_asys_2pc'); last;};
       $userInput{tSuite} eq 'asys_4pc' && do { @arrayTs = ('sh_asys_4pc'); last;};
       $userInput{tSuite} eq 'asys_syslog' && do { @arrayTs = ('sh_asys_syslog'); last;};
       $userInput{tSuite} eq 'ads' && do { @arrayTs = ('sh_ads_ether_0'); last;};
       $userInput{tSuite} eq 'ala' && do { @arrayTs = ('sh_ala_ether_0'); last;};
       $userInput{tSuite} eq 'amc_ether' && do { @arrayTs = ('sh_amc_ether_0'); last;};
       $userInput{tSuite} eq 'amc_coax' && do { @arrayTs = ('sh_amc_coax_0'); last;};
       $userInput{tSuite} eq 'ara_ether' && do { @arrayTs = ('sh_ara_ether_0'); last;};
       $userInput{tSuite} eq 'ara_coax' && do { @arrayTs = ('sh_ara_coax_0'); last;};
       $userInput{tSuite} eq 'ad_ether' && do { @arrayTs = ('sh_ad_ether_0'); last;};
       $userInput{tSuite} eq 'ad_coax' && do { @arrayTs = ('sh_ad_coax_0'); last;};
       print "\n\n no testsuite - $userInput{tSuite} \n";
       exit 0;
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
my $preState = "insert into testcase value";
print "\n\n\tDO NOT CANNCEL IT!\n";
if ($userInput{removeTS}) {
     print "\tDeleting table - Testcase ";
} else {
     print "\tInserting table - Testcase ";
}

SWITCH: {
    $userInput{productName} eq 'bhr2e' && do {last;};
    $userInput{productName} eq 'bhr2f' && do {last;};
    print "\n\n\tProduct name - $userInput{productName} is NOT CORRECT!\n";
    print "\t$usage\n";
    exit 0;
	}

foreach (@arrayTs) {
    my $TcaseID;
    my $SuiteID = "$userInput{productName}"."-"."$userInput{fwVersion}"."-"."$_";
    my $TcaseName;
    my $Des;
    my @ntsuite_stack = split /sh_/, $_;
    my $txtfile = "./txtfile/"."$ntsuite_stack[1]".".tst";
    print "\n$txtfile\n";
    open(FILEHANDLE, $txtfile) || die "Cannot open the file";
    while (<FILEHANDLE>) {
	  chomp;
          my @tcDes = split /\s+<emaildesc>/, $_;
	  my @tcDesTMP = split /\./, $tcDes[0];
	  $tcDes[0] = $tcDesTMP[0];
          $TcaseID = $tcDes[0];
          $TcaseName = $TcaseID;
	  $Des = $tcDes[1];
          my $statement;
	  if ($userInput{removeTC}) {
              $statement = "delete from testcase where SuiteID="."'$SuiteID'";
              $dbh->do($statement);
              my $thr = threads->new(\&outscreen);
              $thr->join();

	  } else {
              $statement = $preState."('$TcaseID','$SuiteID','$TcaseName', '$Des', '')";
              $dbh->do($statement);
              my $thr = threads->new(\&outscreen);
              $thr->join();
	  }
    }    
    close FILEHANDLE;
}

print "\n\tOK! Done\n";
$dbh->disconnect;
