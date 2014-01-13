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
my $usage = "Usage:\t-d <database ipaddress>\n
e.g.
perl inset_tcase_v2.pl -d 192.168.10.238 
";
my %userInput = ( 
	"ipAddress" => '127.0.0.1',
	"removeTC" => 0,
	);
GetOptions ( "h|help" => \$userInput{help},
	"d=s" => \$userInput{ipAddress},
	"r" => \$userInput{removeTC},
	);
if ($userInput{help}) {
   print "$usage\n\n";
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
my $preState = "insert into testcase(TcaseID, TcaseName, Description, Content) values";
print "\n\n\tDO NOT CANNCEL IT!\n";
if ($userInput{removeTS}) {
     print "\tDeleting table - Testcase ";
} else {
     print "\tInserting table - Testcase ";
}

    my $txtfile = "./txtfile/tmp.txt";
    print "\n$txtfile\n";
    open(FILEHANDLE, $txtfile) || die "Cannot open the file";
    while (<FILEHANDLE>) {
	  chomp;
          my @tcDes = split />/, $_;
	  my $TcaseID = $tcDes[0];
	  my $TcaseName = $TcaseID.".xml";
	  my $Des = $tcDes[1];
          my $statement = $preState." ('$TcaseID','$TcaseName', '$Des', '')";
          $dbh->do($statement);
          my $thr = threads->new(\&outscreen);
          $thr->join();
    }    
    close FILEHANDLE;

print "\n\tOK! Done\n";
$dbh->disconnect;
