#!/usr/bin/perl -w
#--------------------------------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to associate a wireless AP with 
# cnetworkmanager
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
my $COUNT_DROP=0;
my $NOPATH="noPathGiven";
my $NOTDEFINED="notdefined";
my @junk = split( /\//, $0);
@junk = split( '\.',$junk[$#junk]);
my $scriptFn = $junk[0];
my $tmo = 24 * 3600;
my %userInput = ( "debug"=>0,
		  "logdir"=>$NOTDEFINED,
		  "scriptname"=>$scriptFn,
		  "outputfile"=>$NOTDEFINED,
		  "algo"=>$NOTDEFINED,
		  "encrypt"=>"none",
		  "timeout"=>$tmo,
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
#---------------------------------------------------
# Launch all jobs and check their status
#---------------------------------------------------
sub jobLaunch {
    my ($profFile,$junk) = @_;
    my $ptrProc;
    my $log = $profFile->{logger};
    my ($rc,$msg,$cmd);
    my $algo = $profFile->{algo};    
    my $encr = $profFile->{encrypt}; # WPA, WPA2, WEP
    my $ssid = $profFile->{ssid};
    my $key = $profFile->{key};
    my $hex = $profFile->{hex};
    my $output = $profFile->{outputfile};
    my $intf = $profFile->{interface};
  
#    my $testLog = $profFile->{logdir}."/$temp\_test.log";
    $cmd="killall nm-applet";
    $log->info("Execute $cmd");
    $rc = `$cmd`;
    $log->info($rc);
    $cmd="service NetworkManager restart";
    $log->info("Execute $cmd");
    $rc = `$cmd`;
    $log->info($rc);
    $cmd="sleep 20;nm-tool";
    $log->info("Execute $cmd");
    $rc = `$cmd`;
    $log->info($rc);

    if ( $encr =~ /wep/i ) {
	$cmd="cnetworkmanager  -w 1 -C $ssid --wep-hex=$key \n"; 
	if ( $hex == 0 ){
	    $msg="cnetworkmanager  -w 1-C $ssid --wep-pass=$key \n"; 
	} 
    } 
    if ( $encr =~ /wpa/i ) {
	$msg="cnetworkmanager  -w 1 -C $ssid --wpa-hex=$key &\n"; 
	if ( $hex == 0 ){
	    $msg="cnetworkmanager  -w 1 -C $ssid --wpa-pass=$key \n"; 
	} 
    }
    if ( $encr =~ /none/i ) {
	$msg="cnetworkmanager  -w 1 -C $ssid --unprotected \n"; 
    }
    $profFile->{process}{script}=$cmd;
    $profFile->{process}{testlog}=$profFile->{outputfile};
    my $loopforever = 0;
    while ( $loopforever < 1) {
	($rc,$msg)=executeCmd ($profFile);
      SWITCH_ERROR_CHECK:
	for ( $msg ) {
	    #time out
	    /5$/ && do {
		$rc=$FAIL;
		$loopforever = 4;
		$msg="Connection timeout";
		last;
	    };
	    #not recognized
	    /6/ && do {
		$rc=$FAIL;
		$loopforever = 4;
		$msg="SSID $ssid is not recognized ";
		last;
	    };
	    #disconnected
	    /7/ && do {
		$rc=$FAIL;
		$msg="Connection is disconnected";
		last;
	    };
	  default:
	    $rc=$FAIL;
	    $loopforever = 4;
	    $msg="Unrecognized error code -- $msg";
	    last;
	}
    }
    return ($rc,$msg);
}


#----------------------------------------
#[root@mygurunet common]# cnetworkmanager -w 1 -C AUTO_QA2 --wep-hex=1234567890
#cnetworkmanager 0.8.4 - Command Line Interface for NetworkManager
#No AP found with SSID AUTO_QA2
#[root@mygurunet common]# cnetworkmanager -w 1 -C actiontec --wep-hex=1234567890
#cnetworkmanager 0.8.4 - Command Line Interface for NetworkManager
#(22:16:13) State: CONNECTING
#(22:16:38) State: DISCONNECTED
#', 'wep-tx-keyidx': 0}}
#Getting secrets: /MyConnection/1
#SECMAP {'802-11-wireless-security': {'key-mgmt': 'none', 'wep-key0': '1234567890', 'wep-tx-keyidx': 0}}
#(14:30:10) State: CONNECTED
#^CLoop exited
# Execute command
#--------------------------------------------------------
sub executeCmd {
    my ( $profFile,$junk)=@_;
    my $cmd = $profFile->{process}{script};
    my $testLog= $profFile->{process}{testlog};
    my $log = $profFile->{logger};
    my $tmo = $profFile->{timeout};
    my $tmo2 = 2 * 60;
    my $temp = 0;
    my $rc = $PASS;
    my $rc2=0 ;
    my $index;
    my $limit;

    my @buff;
    my ($expValue1,$expCmd,$expValue2,$expValue3);
    my $msg = "executeCmdProcess: successfully execute $cmd";
    if ( $profFile->{debug} > 2  ) {  $log->info( "stepCmdProcess: cmd($cmd) ") };
    $log->info("stepCmdProcess with TMO($tmo):cmd($cmd)");

    my $exp=Expect->spawn("$cmd");
# if spawn succeeded 
    if ( defined $exp ) {
	$exp->log_file( "$testLog","w");
	while ( $rc2 < 4 ) {
	    $expValue1 = "No AP found with*";
	    $expValue2 = "DISCONNECTED";
	    $expValue3 = "CONNECTED";
	    $exp->expect($tmo2,
			 [
			  timeout =>
			  sub {
			      $log->info("stepCmdExecute:$cmd is TimeOUT ");
			      $rc2=5;
			      return;
			  }
			 ],
			 [ $expValue1=> sub {   $rc2 = 6 ; return;} ],
			 [ $expValue2=>  sub {$rc2 = 7 ; return;} ],
			 [ $expValue3=> sub {   $rc2 = 8 ; return;} ],
			 [ eof => sub { $log->info ("==>EOF \n"); $rc = $PASS} ],	 	
		);
	}
	$log->info("wifi Network Manager result = $rc2");
      SWITCH_STATUS_CHECK:
	for ( $rc2 ) {
	    #time out
	    /5/ && do {
		$rc=$FAIL;
		$msg="5";
		last;
	    };
	    #not recognized
	    /6/ && do {
		$rc=$FAIL;
		$msg="6";
		last;
	    };
	    #disconnected
	    /7/ && do {
		$rc=$FAIL;
		$msg="7";
		last;
	    };
	    #connected
	    /8/ && do {
		$rc=$FAIL;
		$msg="8";
		$exp->expect($tmo,
			     [
			      timeout =>
			      sub {
				  $log->info("Connected time out:$cmd is TimeOUT ");
				  $msg=9;
				  return;
			      }
			     ],
			     [ $expValue1=>  sub {$msg = 7 ; return;} ],
			     [ eof => sub { $log->info ("==>EOF \n"); $rc = $PASS} ],	 	
		    );
		last;
	    };
	}
	$exp->log_file();    
	$exp->soft_close();
	# clean the log file
	open (CMDFD,"<$testLog") or die " could not write to $testLog ";
	@buff = <CMDFD>;    
	$temp=@buff;
	for ($index=0;$index < $temp;$index++) {
	    # remove Carriage Return
	    $buff[$index]=~ s/\x0d/\n/g;
#	    $buff[$index]=~ s/-/*/g;
	}
	close CMDFD;
    } else {
	$buff[0]="Unrecognized command $cmd\n";
	$buff[1]="Command is aborted\n" ;
	$msg = "127 Error--unregconized command";
    }
    $temp = ("<log>\n<!--@buff-->\n</log>");
    $log->info($temp);
    return ($rc,$msg);
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

$rc = GetOptions( "d=s"=>\$userInput{debug}, 
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
    $outputfile = $userInput{logdir}."/wificfg_file.log"; 
    $userInput{logger}->info( "By default , outputfile will be saved to $outputfile");
    $userInput{outputfile} = $outputfile;
} else {
    $userInput{logger}->info( "Output file will be saved to $outputfile");
}



($rc,$msg)=jobLaunch(\%userInput);
$userInput{logger}->info($msg);
if ($userInput{display}) {
    $msg = `cat $userInput{outputfile}`;
    $userInput{logger}->info($msg);
}
exit 0 if ($rc == $PASS ) ;
exit 1;
1;

=head1 NAME

wifi_nm.pl  - used to accociate to a WIFI AP address. This program will reassociate the wireless if the connection is disconnected

=head1 SYNOPSIS

=over

=item B<wifi_nm.pl>
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

Output Log File. By default, "wifi_nm_log.txt" will be created  

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
    wifi_nm.pl -e wep -i auto-qa1 -k 1234567890 -t wlan0 -x 

1. This command is used to generate a wep wifi configuration file with hex key 
    wifi_nm.pl -a aes -e wpa -i auto-qa1  -t wlan0  -k helloworld 




=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut
