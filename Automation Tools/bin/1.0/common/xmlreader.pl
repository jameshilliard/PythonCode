#!/usr/bin/perl -w
#-------------------------------------------------------------------
# Name: Joe Nguyen
# Description:
#---------------- 
#   This script is used to send all VM Control perl tool kit
#   - with filename contains VM commands with optional parameters: user,password and server IP address
#   - programmable parameters with 
# Things To Do:
#--------------
#  -- Collect all ProcID for killAllProcess
#--------------------------------------------------------------------
use strict;
use warnings;
use diagnostics;
use Expect;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use XML::Simple;
use Data::Dumper;
use Log::Log4perl;
use Expect;
#use Net::LDAP;
use POSIX ":sys_wait_h";
#use IO::Handle;
use POSIX ':signal_h';

#default timeout for each command
my $CMD_TMO = 60; 
my $SAVE_TBL = 1;
my $DISPLAY_ALL="display_all";
my $NOTREQ = "not_required";
my $REQ = "required";
#-----<<<----------------
my $PREFIXJOB="job";
my $NO_FILE= "No_File_specified";
my $ON=1;
my $OFF=0;
my $PASS=1;
my $FAIL=0;
my $verbose = 0;
my $NOFUNCTION="none";
my @junk = split( /\//, $0);
@junk = split('\.',$junk[$#junk]);
my $scriptFn = $junk[0];
my $DUMMY= "dummy";
my $OUTPUTLOG_SIZE=40 * 1024;
my $binver = $ENV{'G_BINVERSION'};


my %userInput = (
    "debug" => "0",
    "logdir"=>"./",
    "winadip"=>$NOFUNCTION,
    "winadport"=>"389",
    "htip"=>$NOFUNCTION,
    "htport"=>"10389",
    "filename"=>$NO_FILE,
    "cmdfile"=>$NO_FILE,
    "resultfile"=>$NO_FILE,
    "template"=>$NO_FILE,
    "timeout"=>$CMD_TMO,
    "authfilename"=>$NO_FILE,
    "scriptname"=> $scriptFn,
    "screenOff"=> 0,
    "concurrent"=> 0,
    "keeppassword"=> 0,
    "logOff"=> 1,
    "ldapptr"=> "",
    "testfinalPtr"=> "",
    "signal"=>$NOFUNCTION,
    "commands"=>[],
    "htcmd"=>{},
    "ip"=>{},
    "resulthandle"=>0,
    "policy"=>{},
    "rule"=>{},
    "role"=>{},
    "user"=>{},
    "env"=> {
#User Related
	"G_NUMOFUSR"=>{ "value"=>"1" , "req"=>$NOTREQ},
	"G_USRNAME"=>{ "value"=>"administrator" , "req"=>$NOTREQ},
	"G_USRPWD"=>{ "value"=>"password" , "req"=>$NOTREQ},
	"G_USR_INC"=>{ "value"=>"1" , "req"=>$NOTREQ},
#Server Related
	"G_NUMOFSRV"=>{ "value"=>"1" , "req"=>$NOTREQ},
	"G_SRVIP"=>{ "value"=>$NOFUNCTION , "req"=>$REQ},
	"G_SRVIP_INC"=>{ "value"=>"1" , "req"=>$NOTREQ},
    },
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
sub displayXml {
    my ($profFile,$junk)=@_;
    my $rc=$PASS;
    my $xml = new XML::Simple;
    my $log = $profFile->{logger};
    my $dirName = $profFile->{logdir};
    my $seed = $profFile->{seed};
    my $outputFile = $dirName."/".$profFile->{scriptname}."_output.xml";
    my $inputFile = $profFile->{filename};
    my @buff;
    my $data;
    my ($result,$temp);
    $inputFile = `ls $inputFile`;
    $inputFile =~ s/\n//;
    printf " file = $inputFile ";
    my  $msg="Display: $inputFile";
    if ( $inputFile =~ /No such/ ) {
	return ( $FAIL, $inputFile );
    }
    if ( $profFile->{debug} < 5 ) {
	eval { $data = $xml->XMLin("$inputFile")};
    } else {
	$data = $xml->XMLin("$inputFile");
    }
    if ( !defined $data) {
	$msg =`xmllint $inputFile`;
	return($FAIL,$msg);
    }
    $temp = Dumper($data);
    $log->info($temp);
 #   $data = $profFile->{ip};
    my $output = $xml->XMLout($data);
    open(OUTFD,">$outputFile") or die " could not create $outputFile ";
    print OUTFD $output;
    close OUTFD;
    return ( $PASS,$msg);

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
my $msg;
my $key;
my $logdir;
my $globalRc = $PASS;
my $option_man = 0;
my $jobid =0 ;
my $temp;
#---------------------------------------------
# Initialize Logger 
#---------------------------------------------
$userInput{seed}=int(rand(1000));



$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man, 
		  "l=s"=>sub {  $userInput{logdir} = $_[1]; $logdir = $_[1]},
		  "f=s"=>\$userInput{filename},
		  "z"=>sub { $userInput{logOff} = 0 },
		  "v=s"=>sub { if ( exists $userInput{commands}[0] ) { push (@{$userInput{commands}},$_[1]); } else {$userInput{commands}[0]=$_[1]; } } ,
		  );
#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);
($rc,$msg) = initLogger(\%userInput, 0);
if ( $rc != 1) {
    printf ("RC$rc $msg\n");
    exit 1;
} 
if ( $userInput{filename} =~ /$NO_FILE/) {
    $userInput{logger}->info("Error: please enter the filename");
    exit 1;
}
if ( !(-e $userInput{filename}) ) {
    $userInput{logger}->info("Error: filename $userInput{filename} is NOT found ");
    exit 1;
}


($rc,$msg) = displayXml (\%userInput);

exit (0);
1;
__END__


=head1 NAME

xmlreader.pl - used to read in the xml file and create an output xml file. This utility is used to test xml file

=head1 SYNOPSIS

=over

=item B<xmlreader.pl>
[B<-help|-h>]
[B<-man>]
[B<-c> I<test definition command file>]
[B<-f> I< XML file>]
[B<-l> I<log file directory>]

=back

=head1 OPTIONS AND ARGUMENTS

=over


=item B<-f>

XML File 

=item B<-l >

Redirect stdout to the /path/policyqueryxxx.log


=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-x>

Set debug to different level . ( more debug messages with higher number)


=back


=head1 EXAMPLES

=over

1. This command is used to read in a  xml file and created a xmlreader_output.xml
    xmlreader.pl -f test123.xml

=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut
