#!/usr/bin/perl -w
#---------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to upload Q1000 firmware 

#-------------------------------- 


use strict;
use warnings;
use diagnostics;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use XML::Simple;
use Data::Dumper;
use Log::Log4perl;
use LWP::UserAgent;	 

use POSIX ':signal_h';
my $OUTPUTLOG_SIZE=40 * 1024;


my $NO_FILE= "No File specified";
my $ON=1;
my $OFF=0;
my $PASS=1;
my $FAIL=0;
my $SETUP_IF_TMO = 5 * 60; # 5 minutes
my $NOFUNCTION="Nofunction";
my $NOTDEFINED="not_defined";
my @junk = split( /\//, $0);
@junk = split('\.',$junk[$#junk]);
my $scriptFn = $junk[0];
my $USER= "root,password";
my $DSL="dsl";
my $DHCP="dhcp";
my $ETHER="ethernet";
my $COAX="hspn";

#-----<<<----------------

my %userInput = (
    "debug" => "0",
    "scriptname"=>$scriptFn,
    "logdir"=>$NOTDEFINED,
    "filename"=>$NOTDEFINED,
    "cmd"=>$NOTDEFINED,
    "outputfile"=>$NOTDEFINED,
    "dutip"=>$NOTDEFINED,
    "user"=>"admin",
    "pwd"=>"QwestM0dem",
    "screenoff"=>0,
    "logoff"=>0,
    "logger"=>"",
    );

#---------------------------------------------------------
# This routine is used to initialize the log feature
#---------------------------------------------------------
sub initLogger {
    my ( $profFile, $junk) = @_;
    my $rc = $PASS;
    my $rc2 = $PASS;
    my $msg ="Successfully Set Logger";
    #--------------------
    # initialize logger
    #---------------------
    my $temp = $profFile->{scriptname};
    my $localLog = $profFile->{logdir}."/$temp.log";
    my $localLog2 = $profFile->{logdir}."/$temp\2.log";
    my $clobberLog = $profFile->{logdir}."/$temp\_clobber.log";
    my $clobberLog2 = $profFile->{logdir}."/$temp\_clobber2.log";
    if ( -e $localLog ) {
	$temp = -s "$localLog";
	if ( $temp > $OUTPUTLOG_SIZE ) {
	    $rc2 =`mv -f $localLog $localLog2`;
	} 
    }
    if ( -e $clobberLog ) {
	$temp = -s $clobberLog;
	if ( $temp > $OUTPUTLOG_SIZE ) {
	    $rc2 =`mv -f $clobberLog $clobberLog2`;
	} 
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
    
    if ( $profFile->{screenoff} == $OFF ) {
	my $screen = Log::Log4perl::Appender->new("Log::Log4perl::Appender::Screen",
						  stderr => 0);	
	$profFile->{logger}->add_appender($screen);
    }
    if ( $profFile->{logoff} == $OFF ) {
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
#-------------------------------------------
# Get name 
#-------------------------------------------
sub getBaseName{
    my ($path,$junk) = @_;
    my @t1;
    @t1=split("/",$path );
    $junk = $t1[$#t1];
    return ($junk);
}
#************************************************************
# Upload FW software 
#************************************************************
sub postFW {
    my ( $profFile, $junk) = @_;
    my $rc = $PASS;
    my $msg ="Successfully post Firmware";
    my $log = $profFile->{logger};
    my $dut = $profFile->{dutip};
    my $filename = $profFile->{filename};
    my $ua = LWP::UserAgent->new;
    my $basename= getBaseName($filename);
    my $temp;
    my $output = $profFile->{outputfile};
    $ua->timeout(10);
    $ua->env_proxy;

    my $url="http://".$dut."/images/btn_browse_static.png";
    my $response;
    $response = $ua->get($url);
    if ($response->is_success) {
	$msg="Link $url is legal ---".$response->decoded_content;
#	$log->info( "$msg");
    } else { 
	$rc=$FAIL;
	$msg="Error:Link $url is not found--".$response->status_line;  
#	$log->info( "$msg");
	return($rc,$msg);
    }

    $url= "http://$dut/upload.cgi";
    my $i;
    $ua->timeout(100);
    for ($i=0;$i<3;$i++) {
	$log->info("$i: upload iteration");
	
	$response= $ua->post("$url",
			     'Content-Type'=> "multipart/form-data",
			     'Referer'=> "http://$dut/utilities_upgradefirmware_real.html",
			     'Content'=>[ 
				 'upfile'=>["$filename"],
			     ],
	    );
	if ($response->is_success) {
	    
	    $msg="Successfully upload $filename--";
	    open ( OUTPUT,"> $output") or die " could not write to $output";
	    print OUTPUT $response->decoded_content;
	    close OUTPUT;
#	$log->info( "$msg");
	} else { 
	    $rc=$FAIL;
	    $msg="Error:upload $filename failed--".$response->status_line;  
	    return($rc,$msg);
#	$log->info( "$msg");
	}
	sleep 15;
	# ADD PING HERE
	$temp=system( "ping $dut -w 4 -c 4");
	last if ($temp >0 );
 
    }
    return($rc,$msg);
}
#************************************************************
# Main Routine
#************************************************************
MAIN:
my $exp;
my $TRUE=1;
my $FALSE=0;
my @userTemp;
my ($x,$h);
my $option_h;
my $rc =0;
my ($len,$len1);
my $temp;
my $msg;
my $key;
my $logdir;
my $TESTSUITE_VERSION="1.0";
my @commands = ();
my $globalRc = 0;
my $option_man = 0;
my $junk =0;
my $value;
$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man, 
		  "l=s"=>\$userInput{logdir},
		  "d=s"=>\$userInput{dutip},
		  "f=s"=>\$userInput{filename},
		  "u=s"=>\$userInput{user},
		  "p=s"=>\$userInput{pwd},
		  "o=s"=>\$userInput{outputfile},
		  "v=s"=>sub { if ( exists $commands[0] ) { push (@commands,$_[1]); } else {$commands[0]=$_[1]; } } ,
		  );
#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);
my $dir = $userInput{logdir};

if ( $dir =~ /$NOTDEFINED/ ) {
    $dir=`pwd`;
    $dir=~ s/\n//;
    $userInput{logdir} = $dir;
}
printf ( "DIR = $dir \n");
#---------------------------------------------
# Initialize Logger 
#---------------------------------------------
($rc,$msg) = initLogger(\%userInput, );
if ( $rc != 1) {
    printf ("RC$rc $msg\n");
    exit 1;
} 

my $outputfile=$userInput{outputfile},;
if ( $outputfile =~ /$NOTDEFINED/ ) {
    $temp = "update_html_respond";
    $outputfile = $dir."/$temp\.log";
    $userInput{outputfile} = $outputfile;
} else {
    $outputfile = $dir."/".$outputfile;
    $userInput{outputfile} = $outputfile;
}




#printf("--------------- Input Parameters  ---------------\n") if $userInput{debug} ;
$userInput{logger}->info("------------------ $scriptFn  Input Parameters  ------------------\n");
$junk ="";
foreach $key ( keys %userInput ) {
    $junk .= " $key = $userInput{$key} :: " ;
}
if ( defined $ENV{"G_TESTBED"} ) {
    $userInput{host}=$ENV{G_TESTBED}."_dut";
}

$userInput{logger}->info("\n$junk" );
my $limit = @commands;
my $line;
if ($limit > -1  ) {
    $junk =" ";
    foreach $line (  @commands) { 
	$junk .="-v $line "; 
    }
    $junk = $userInput{scriptname}.".pl -l ".$userInput{logdir}.$junk;
    $userInput{logger}->info("\n Executing command=$junk\n\n");
}

($rc,$msg)=postFW(\%userInput);


$userInput{logger}->info("$msg");
if ( $rc == $FAIL) {
    $userInput{logger}->info("==> $userInput{scriptname}  failed");
    exit (1);
} 
$userInput{logger}->info("==> $userInput{scriptname} passed");

exit (0);
1;
__END__

=head1 NAME

uploadfw.pl - is a utility to upload Q1000 firmware

=head1 SYNOPSIS

=over 12

=item B<uploadfw.pl>
[B<-help|-h>]
[B<-man>]
[B<-l> I<log file path>]
[B<-d> I<DUT IP >]
[B<-u> I<DUT logon userid optional >]
[B<-p> I<DUT logon password optional>]
[B<-x> I<debug level>]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-l >

Redirect stdout to the /path/uploadfw.log

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-x>

Set debug to different level . ( more debug messages with higher number)

=item B<-d>

DUT IP address.

=item B<-u>

DUT login userid.

=item B<-p>

DUT password userid.

=item B<-f>

Firmware filename 


=back

=head1 EXAMPLES

1. The following command is used to upload bcm.cfe.fs.kernel.091117-QAQ01-31.10L.17-QWEST.img to dut 
    perl uploadfw.pl -f download/bcm.cfe.fs.kernel.091117-QAQ01-31.10L.17-QWEST.img -d 192.168.0.1 -l /tmp/ 

=head1 AUTHOR

Please report bugs using L<http://budz/>

JoeNguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut
