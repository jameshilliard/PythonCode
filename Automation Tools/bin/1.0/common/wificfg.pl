#!/usr/bin/perl -w
#--------------------------------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to generate testcase extracted from xml testcase description and reindex the testcase step 
#
#-------------------------------------------------------
use strict;
use warnings;
use diagnostics;
use Expect;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use Log::Log4perl;
use XML::Simple;
use Data::Dumper;
my $PASS=1;
my $FAIL=0;
my $NOPATH="noPathGiven";
my $NOTDEFINED="notdefined";
my @junk = split( /\//, $0);
@junk = split( '\.',$junk[$#junk]);
my $scriptFn = $junk[0];
my %userInput = ( "debug"=>0,
		  "logdir"=>$NOTDEFINED,
		  "scriptname"=>$scriptFn,
		  "outputfile"=>$NOTDEFINED,
		  "algo"=>$NOTDEFINED,
		  "encrypt"=>"none",
		  "ssid"=>$NOTDEFINED,
		  "key"=>$NOTDEFINED,
		  "interface"=>$NOTDEFINED,
		  "hex"=>0,
		  "screenOff"=> 0,
		  "logOff"=> 1,

    );
#---------------------------------------------------------
# This routine is used to initialize the log feature
#---------------------------------------------------------
sub initLogger {
    my ( $profFile, $junk) = @_;
    my $rc = $PASS;
    my $msg ="Successfully Set Logger";
    #--------------------
    # initialize logger
    #---------------------
    my $temp = $profFile->{scriptname};
    my $localLog = $profFile->{logdir}."/$temp.log";
    my $clobberLog = $profFile->{logdir}."/$temp\_clobber.log";
    if ( -e $localLog ) {
	$temp = `rm -f $localLog`;
    }
    if ( -e $clobberLog ) {
	$temp = `rm -f $clobberLog`;
    }
    # layout: date-module + line mumber -(info,debug,warn,error,fatal)> message +  new line 
    my $layout = Log::Log4perl::Layout::PatternLayout->new("%d--%F{1}:%L--%M--%p> %m%n");
    my $gName = "initLogger";
    if ( defined $profFile->{gcov}{$gName} ) {
	$profFile->{gcov}{$gName} += 1;
    } else {
	$profFile->{gcov}{$gName} = 1;
    }

    $profFile->{logger}= Log::Log4perl->get_logger();
    
    if ( $profFile->{screenOff} == 0 ) {
	my $screen = Log::Log4perl::Appender->new("Log::Log4perl::Appender::Screen",
						  stderr => 0);	
	$profFile->{logger}->add_appender($screen);
    }
    if ( $profFile->{logOff} == 0 ) {
	my $appender = Log::Log4perl::Appender->new("Log::Log4perl::Appender::File",
						    filename => $localLog,
						    mode => "append");
	my $writer = Log::Log4perl::Appender->new("Log::Log4perl::Appender::File",
						  filename => $clobberLog,
						  mode => "clobber");
	$appender->layout($layout);	
	$profFile->{logger}->add_appender($appender);
	$profFile->{logger}->add_appender($writer);
    }
    $profFile->{logger}->info("--> Log initialized <--");
    return($rc,$msg);

}

#************************************************************

#************************************************************

sub getBaseName {
    my ($path,$junk)=@_;
    my @temp = split("/",$path);
    $junk = $temp[$#temp];
    return $junk;
}

#--------------------------------
# Using iwconfig
#--------------------------------
sub generateoutput2 {
    my ($profFile,$inputFile,$tc_index)=@_;
    my $rc=$PASS;
    my $msg;
    my $algo = $profFile->{algo};    
    my $encr = $profFile->{encrypt}; # WPA, WPA2, WEP
    my $ssid = $profFile->{ssid};
    my $key = $profFile->{key};
    my $output = $profFile->{outputfile};
    my $intf = $profFile->{interface};

    open ( FN,">$output") or die "Could not create $output";
    $msg="service NetworkManager stop\nifconfig $intf down\n";
    print FN  $msg;
    if ( $encr =~ /wep/i ) {
	$msg="iwconfig $intf essid $ssid key $key  ap auto\nifconfig $intf up\niwlist $intf scan\n";
	print FN  $msg;
    } else {
	
	$msg="iwconfig $intf essid $ssid  ap auto\nifconfig $intf up\niwlist $intf scan\n";	
	print FN  $msg;
	$msg="wpa_passphrase $ssid $key > /tmp/tempwpa1.txt\n";
	print FN  $msg;
	$msg="echo \"ctrl_interface=/var/run/wpa_supplicant\" > /tmp/tempwpa2.txt\n";
	print FN  $msg;
 	$msg="echo \"ctrl_interface_group=0\" >> /tmp/tempwpa2.txt\n"; 
	print FN  $msg;
	$msg= "cat /tmp/tempwpa2.txt /tmp/tempwpa1.txt /etc/wpa_supplicant/wpa_supplicant.conf\n"; 
	print FN  $msg;
# Need to generate WPA _SUPPLICANT
	$msg = "\#xterm -e wpa_supplicant -i$intf -c/etc/wpa_supplicant/wpa_supplicant.conf &\n"; 
	print FN  $msg;
	$msg = "dhclient -r $intf\n";
	print FN  $msg;
    }

    $msg = "Succefully generate test case docs to $profFile->{outputfile}";
    return ( $PASS,$msg);
}
#--------------------------------
# Using cnetmanager
#--------------------------------
sub generateoutput {
    my ($profFile,$inputFile,$tc_index)=@_;
    my $rc=$PASS;
    my $msg;
    my $algo = $profFile->{algo};    
    my $encr = $profFile->{encrypt}; # WPA, WPA2, WEP
    my $ssid = $profFile->{ssid};
    my $key = $profFile->{key};
    my $hex = $profFile->{hex};
    my $output = $profFile->{outputfile};
    my $intf = $profFile->{interface};

    open ( FN,">$output") or die "Could not create $output";
    $msg="service NetworkManager stop\ncnetworkmanager -n\n";
    print FN  $msg;
    if ( $encr =~ /wep/i ) {
	$msg="cnetworkmanager  -w 1 -C $ssid --wep-hex=$key &\n"; 
	if ( $hex == 0 ){
	    $msg="cnetworkmanager  -w 1-C $ssid --wep-pass=$key &\n"; 
	} 
	print FN  $msg;
    } 
    if ( $encr =~ /wpa/i ) {
	$msg="cnetworkmanager  -w 1 -C $ssid --wpa-hex=$key &\n"; 
	if ( $hex == 0 ){
	    $msg="cnetworkmanager  -w 1 -C $ssid --wpa-pass=$key &\n"; 
	} 
	print FN  $msg;
    }
    if ( $encr =~ /none/i ) {
	$msg="cnetworkmanager  -w 1 -C $ssid --unprotected &\n"; 
	print FN  $msg;
    }

    $msg = "Succefully generate test case docs to $profFile->{outputfile}";
    return ( $PASS,$msg);
}






#************************************************************
# Main Routine
#************************************************************
MAIN:
my @buff;
my ($x,$h);
my $option_h;
my $option_man = 0;
my $rc = 0;
my $msg;
my $key;
my $current;
my $limit;
my ($index,$temp);
my $example = "Example: ";
my $usage="Usage: generate testcase documents.txt  \n\t\tgenerate_tcdocs.pl -f <filename> -o <optional filename> -l <directory where new files will be saved>";
my @commands = ();

$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man,
		  "l=s"=>\$userInput{logdir},		  
		  "o=s"=>\$userInput{outputfile},
		  "a=s"=>\$userInput{algo},		  
		  "e=s"=>\$userInput{encrypt},
		  "i=s"=>\$userInput{ssid},
		  "k=s"=>\$userInput{key},
		  "t=s"=>\$userInput{interface},
		  "x"=>\$userInput{hex},
		  "z"=>sub { $userInput{logOff} = 0 },
		  "v=s"=>sub { if ( exists $commands[0] ) { push (@commands,$_[1]); } else {$commands[0]=$_[1]; } } ,
		  );
#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);
my $dir = $userInput{logdir};
if ( $dir =~ $NOTDEFINED ) {
    $dir=`pwd`;
    $dir=~ s/\n//;
    $userInput{logdir} = $dir;
    printf ( "DIR = $dir \n");
}
($rc,$msg) = initLogger(\%userInput, 0);
if ( $rc != 1) {
    printf ("RC$rc $msg\n");
    exit 1;
} 

my $outputfile = $userInput{outputfile};

if ( ($outputfile =~ /$NOTDEFINED/ ) ) {
    $outputfile = $userInput{logdir}."/wificfg_file.txt"; 
    $userInput{logger}->info( "By default , outputfile will be saved to $outputfile");
    $userInput{outputfile} = $outputfile;
} else {
    $userInput{logger}->info( "Output file will be saved to $outputfile");
}



($rc,$msg)=generateoutput(\%userInput);
$userInput{logger}->info($msg);
if ($userInput{display}) {
    $msg = `cat $userInput{outputfile}`;
    $userInput{logger}->info($msg);
}
exit 0 if ($rc == $PASS ) ;
exit 1;
1;

=head1 NAME

wificfg.pl  - used to create file to enable wifi interface. The output file will be used in conjunction with clicfg.pl 

=head1 SYNOPSIS

=over

=item B<wificfg.pl>
[B<-help|-h>]
[B<-man>]
[B<-l> I<log file directory>]
[B<-a> I<agorithm>]
[B<-e> I<encryption as wpa, wep , or wpa2>]
[B<-i> I<SSID>]
[B<-k> I< password or hex key>]
[B<-t> I< interface where the cnetmanage will bind to >]
[B<-x> I< hex key will be used>]

[B<-ce> I< generate test summary list under ce lab format>]

=back

=head1 OPTIONS AND ARGUMENTS

=over


=item B<-o>

Output File. By default, "wificfg_file.txt" will be created  

=item B<-l >

Redirect stdout to the /path/xmlxxx.log

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-x>

set password key  as hex

=item B<-a>

Algorism as AES or TKIP

=item B<-e>

Encryption as wep,wpa or wpa2

=item B<-i>

SSID

=item B<-t>

Wireless interface ( e.g: wlan0 wlan1 etc ... )



=back


=head1 EXAMPLES

=over

1. This command is used to generate a wep wifi configuration file with hex key 
    wificfg.pl -e wep -i auto-qa1 -k 1234567890 -t wlan0 -x 

1. This command is used to generate a wep wifi configuration file with hex key 
    wificfg.pl -a aes -e wpa -i auto-qa1  -t wlan0  -k helloworld 




=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut
