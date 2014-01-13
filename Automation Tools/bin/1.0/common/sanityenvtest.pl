#!/usr/bin/perl -w
#----------------------------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to test the sanity of the installation
# of Perl and Staf modules
#
#
#---------------------------------------------------
use strict;
use warnings;
use diagnostics;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
#use Data::Dumper;
use POSIX ':signal_h';
use Log::Log4perl;

my $NO_FILE= "No File specified";
my $ON=1;
my $OFF=0;
my $PASS=1;
my $FAIL=0;
my $NOFUNCTION="none";
my @junk = split( /\//, $0);
@junk = split('\.',$junk[$#junk]);
my $scriptFn = $junk[0];
my $USER= "root,gomain03";
my $MYWORKDIR="/svn/svnroot/QA/automation";
#----------<<------
my $TB_TYPE="G_TBTYPE";
#-----<<<----------------
my $STAFCMD = "/usr/local/staf/bin/staf";
if (! (-e $STAFCMD) ) {
    printf ("Error: $0 depends on the availability of $STAFCMD\n");
    exit 1;
}
my %envTbl = (
    'SQAROOT'=>'/svn/svnroot/QA/automation/',
    'G_LIBVERSION'=>'1\.0',
    'G_BINVERSION'=>'1\.0',
    'G_CFGVERSION'=>'1\.0',
    'G_PFVERSION'=>'1\.0',
    'G_FTP_SERVER'=>'coke',
    'LD_LIBRARY_PATH'=>'/usr/local/staf/lib',
    'CLASSPATH'=>'/usr/local/staf/lib/JSTAF.jar:/usr/local/staf/samples/demo/STAFDemo.jar',
    'STAFCONVDIR'=>'/usr/local/staf/codepage',
    'STAFCODEPAGE'=>'LATIN_1',
    'PERLLIB'=>'/usr/local/staf/bin:/usr/local/staf/lib/perl58',
    );


my %stafTrustTbl = (
    'hummingbird'=>5,          
    'venus'=>5,
    'local'=>5,
    );


my %perlModule= (
    'lwp'=>'LWP',
    'xml'=>'XML::Simple',    
    'log'=>'Log::Log4perl',    
    'expect'=>'Expect',    
    'dbi'=>'DBI',
    'cgi'=>'CGI',
    );



my %userInput = (
    "debug" => "0",
    "logdir"=>"./",
    "scriptname"=> $scriptFn,
    "screenOff"=> 0,
    "logOff"=> 0,
    "gcov"=>{}, # associative array which is indexed by subroutine name
    "env"=>{'G_DISPSERVER'=>$NOFUNCTION,'G_FTP_SERVER'=>$NOFUNCTION,},
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
# Check if all Perl Module is On
#---------------------------------------------------
sub checkEnvironment {
    my ($profFile,$tbName)=@_;
    my $rc=$PASS;
    my $logdir = $profFile->{logdir};
    my $msg ="\n -------- Check TestBed Environment ----------- \n";
    my $log = $profFile->{logger};
    my $outputLog = $logdir."/".$profFile->{scriptname}."_output.junk";;
    my $localrc = 0;
    my $value;
    my $temp;
    my $localpath= '/usr/local/staf/bin:';
    $temp = $ENV{'PATH'};
    if ($temp !~ /$localpath/ ) {
	$msg=$msg."Error: $temp does NOT  contain \[$localpath\]\n";
	$rc = $FAIL;
    } else {
	$msg=$msg."\[$localpath\] -- valid ... $temp\n";
    }
    foreach my $key ( sort keys %envTbl ) {
	$value = $envTbl{$key};
	$temp = $ENV{$key};
        if ( not defined $temp ) {
	    $msg = $msg."Error: $key=$value -- missing\n";
	    $rc = $FAIL;
	} else {
	    if ( $temp =~ /$value/) {
		$msg = $msg."$key=$value -- valid\n"; 
	    } else {
		$msg = $msg."Error: Actual value $key=$temp -- not MATCHED  with expected value $key=$value\n"; 
	    }
	}
    }
    

    return ($rc,$msg);
}



#---------------------------------------------------
# Check if all Perl Module is On
#---------------------------------------------------
sub checkPerlModule {
    my ($profFile,$tbName)=@_;
    my $rc=$PASS;
    my $logdir = $profFile->{logdir};
    my $msg ="\n -------- Check Perl Module ----------- \n";
    my $log = $profFile->{logger};
    my $outputLog ;
    my $localrc = 0;
    my $value;
    my $cmd;
    my $errmsg ="Can't locate"; 
    my $temp;
    foreach my $key ( sort keys %perlModule ) {
	$value = $perlModule{$key};
	$outputLog = $logdir."/".$profFile->{scriptname}."_$key"."_output.junk";;
	$cmd="/usr/bin/perl -MCPAN -M$value -e \"print holla\" 2> $outputLog";
	$temp=`$cmd`;
	$log->info("execute $cmd");
	sleep 1;
	open (FD,"< $outputLog") ;
	$temp = <FD>;
	close FD;
        if ( defined $temp ) {
	    $msg = $msg."\[$key\]$value module  is not found -- $temp";
	    $rc = $FAIL;
	} else {
	    $msg = $msg."\[$key\]$value module  is available \n"; 
	}
    }
    return ($rc,$msg);
}
#---------------------------------------------------
# Check Staf trust level
#---------------------------------------------------
sub checkStafTrustSetup {
    my ($profFile,$tbName)=@_;
    my $rc=$FAIL;
    my $log = $profFile->{logger};
    my $msg = "";
    my $stringMsg="\n --- Result for Trust Level -----\n";
    my $cmd = "/usr/local/staf/bin/staf $tbName trust list";
    my $temp = `$cmd`;
    my $key;
    my $value;
    my $localrc;
    $log->info("isTbStatAvail:cmd($cmd)\n$temp") if ($profFile->{debug} > 2 );
    my @buffer = split("\n",$temp);
    my $line;
    my $gName = "checkStafTrustSetup";
    if ( defined $profFile->{gcov}{$gName} ) {
	$profFile->{gcov}{$gName} += 1;
    } else {
	$profFile->{gcov}{$gName} = 1;
    }
    foreach $line (@buffer) {
	# if error occurs then STAF is not running
	if ( $line =~ /Error submitting*/i ) {
	    $rc=$FAIL;
	    $msg = "$tbName Staf is not running";
	    return($rc,$msg);
	}
	if ( $line =~ /Response/i) {
	    last;
	}
    }
    $rc = $PASS;
    foreach $key ( sort keys %stafTrustTbl ) {
	$value = $stafTrustTbl{$key};
	$msg = "Could not found trust for $key\n";
	$localrc = $FAIL;
	foreach $line ( @buffer) {
	    # if error occurs then STAF is not running
	    if ( $line =~ /Machine/ ) {
		if ( $line =~ /$key/i ) {
		    if ( $line =~ /$value/ ) {
			$msg = "Trust for $key with level $value is found\n";
			$localrc = $PASS;
			last;
		    } else {
			$msg = "Trust for $key with different level $value is found -- $line\n";
			last;
		    }
		}
	    }
	}
	$log->info($msg);
	$rc=$FAIL if ( $localrc == $FAIL );
	$stringMsg = $stringMsg.$msg
    }
    return($rc,$stringMsg);
}


#---------------------------------------------------
# Check if STAF process is turned on
#---------------------------------------------------
sub isTbStafAvail {
    my ($profFile,$tbName)=@_;
    my $rc=$FAIL;
    my $log = $profFile->{logger};
    my $msg = "\n ---- Check Staf availability ---------\n";
    my $cmd = "/usr/local/staf/bin/staf $tbName ping ping";
    my $temp = `$cmd`;
    $log->info("isTbStatAvail:cmd($cmd)\n$temp") if ($profFile->{debug} > 2 );
    my @buffer = split("\n",$temp);
    my $line;
    my $gName = "isTbStafAvail";
    if ( defined $profFile->{gcov}{$gName} ) {
	$profFile->{gcov}{$gName} += 1;
    } else {
	$profFile->{gcov}{$gName} = 1;
    }
    foreach $line (@buffer) {
	# if error occurs then STAF is not running
	if ( $line =~ /Error submitting*/i ) {
	    #testbed is not available
	    $rc=$FAIL;
	    $msg = $msg."$tbName Staf is not running";
	    return($rc,$msg);
	}
	if ( $line =~ /Response/i) {
	    next;
	}
	$msg=$msg."STAF on $tbName is running";
	return($PASS,$msg);
    }
    #testbed is not available
    $rc = $FAIL;
    $msg = $msg." could not identify Staf Status ";
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
my $rc2 =0;
my $msg;
my $msg2;
my $key;
my $localrc;
my $logdir;
my @commands = ();
my $globalRc = 0;
my $option_man = 0;
my $jobid =0 ;
$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man, 
		  "l=s"=>sub {  $userInput{logdir} = $_[1]; $logdir = $_[1]},
		  );
#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);
#printf("--------------- Input Parameters  ---------------\n") if $userInput{debug} ;
printf("--------------- $scriptFn  Input Parameters  ---------------\n");
foreach $key ( keys %userInput ) {
#    printf (" $key = $userInput{$key} :: " ) if $userInput{debug} ;
    printf (" $key = $userInput{$key} :: " );
}
#---------------------------------------------
# Initialize Logger 
#---------------------------------------------
($rc,$msg) = initLogger(\%userInput, );
if ( $rc != 1) {
    printf ("RC$rc $msg\n");
    exit 1;
} 
$rc = $PASS;
#---------------
($localrc,$msg) = isTbStafAvail (\%userInput,"localhost");
$userInput{logger}->info("\[Status:$localrc\]:$msg");
$rc=$FAIL if ($localrc == $FAIL);
($localrc,$msg) = checkStafTrustSetup (\%userInput,"localhost");
$userInput{logger}->info("\[Status:$localrc\]:$msg");
$rc=$FAIL if ($localrc == $FAIL);
($localrc,$msg) = checkPerlModule (\%userInput,"localhost");
$userInput{logger}->info("\[Status:$localrc\]:$msg");
$rc=$FAIL if ($localrc == $FAIL);
($localrc,$msg) = checkEnvironment (\%userInput,"localhost");
$userInput{logger}->info("\[Status:$localrc\]:$msg");
$rc=$FAIL if ($localrc == $FAIL);
#---------------------
if ( $rc == $FAIL) {
    $userInput{logger}->info("==> $userInput{scriptname}  failed");
    exit 1;
}
$userInput{logger}->info("==> $userInput{scriptname} passed");
exit (0);
1;
__END__

=head1 NAME

sanityenvtest.pl - is used to check out the TESTBED configuration uptodate 

=head1 SYNOPSIS

=over 12

=item B<sanityenvtest.pl>
[B<-help|-h>]
[B<-man>]
[B<-l> I<log file path>]
[B<-x> I<debug level>]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-l>

Redirect stdout to the /path/sanityenvtest.log

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-x>

Set debug to different level . ( more debug messages with higher number)


=head1 DESCRIPTION

B<sanityenvtest.pl> will allow user to verify if TESTBED contains basic Perl modules, STAF modules. 


=head1 EXAMPLES

1. The following command is used to check the TB local configuration 
    perl sanityenvtest.pl 


2. The following command is used to check the TB local configuration and save logs to /tmp directory
        perl sanityenvtest.pl -l /tmp

=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut

