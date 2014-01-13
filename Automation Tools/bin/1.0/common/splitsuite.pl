#!/usr/bin/perl -w
#---------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to truncate number of testcases in number of testsuite
#
#--------------------------------
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
use JSON;
#use JSON::XS;
#use Test::JSON;
#use Config::JSON;


my $PASS=1;
my $FAIL=0;
my $NOPATH="noPathGiven";
my $NOTDEFINED="notdefined";
my @junk = split( /\//, $0);
@junk = split( '\.',$junk[$#junk]);
my $scriptFn = $junk[0];
my %userInput = ( "debug"=>0,
		  "logdir"=>$NOTDEFINED,
		  "filename"=>$NOTDEFINED,		  
		  "outputfile"=>$NOTDEFINED,
		  "logger"=>$NOTDEFINED,
		  "screenOff"=> 0,
		  "logOff"=> 1,
		  "scriptname"=>$scriptFn,
		  "first"=>$NOTDEFINED,
		  "second"=>$NOTDEFINED,
		  "testcase"=>$NOTDEFINED,

		  "testsetup"=>"\tPlease see the setup Section\n",
		  "testexec"=>"\tThe test execution is described in the following step(s):\n",
		  "expectresult"=>"\tAny failure detected during the test execution renders the test failed\n",
		  "testheader"=>"Deprecated: 0\nTest Type: Functional\nAutomatable: 1\nTest Description:\n",
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
# Get base name 
#**********************************************************

sub getBaseName {
    my ($path,$junk)=@_;
    my @temp = split("/",$path);
    $junk = $temp[$#temp];
    return $junk;
}
#************************************************************
# Get base path
#**********************************************************
sub getBasePath {
    my ($path,$junk)=@_;
    my @temp = split("/",$path);
    $junk ="";
    for ( my $count=0; $count < $#temp ; $count++) {
	if ( $count ==0 ) {
	    $junk .= $temp[$count];
	} else {
	    $junk .= "/".$temp[$count];
	}
    }
    return $junk;
}

#************************************************************
# The following routine is used to generate test case  
# 
#************************************************************
sub generatetestsuite {
    my ($profFile,$inputFile)=@_;
    my $rc=$PASS;
    my $msg;
    my $line;
    my @buff;
    my $outputFile;
    my $pStruct;
    my $basename;
    my $log = $profFile->{logger};
    ($rc,$msg) = createTestSuite($profFile,$inputFile);
    if ($rc == $FAIL ) {
	$msg="Error: Could not create $outputFile testsuite  file from $inputFile input file";
	return($FAIL,$msg);
    }
    return ( $PASS,$msg);
}
#************************************************************
#  This routine is used to create number of test suite
#  based on testcase input ( option -t )
#************************************************************
sub createTestSuite {
    my ($profFile,$inputFile)=@_;
    my $rc=$PASS;
    my $msg="Successfully Create testsuite from $inputFile and the new testsuites are created as the following:\n";
    my $json;
    my @buff;
    my $count =0;
    my $key;
    my $line;
    my $first = $profFile->{first};
    my $second = $profFile->{second};
    my $entry = "\n";
    my $outFile;
    my ($x,$y,$z);
    my $output = $profFile->{outputfile};
    my $log = $profFile->{logger};
    my $tcNum = $profFile->{testcase};
    my $cmd = "split --verbose -l $tcNum $inputFile";
    $key=`$cmd`;
    @buff=split("\n",$key);
    $log->info("$key") if ( $profFile->{debug} > 2 ) ;
    $first = "" if ( $first =~ /$NOTDEFINED/) ;
    $second = "" if ( $second =~ /$NOTDEFINED/) ;
    foreach ( $count =0 ; $count <= $#buff; $count++) {
	$line = $buff[$count];
	$line =~ s/\n//;
	($x,$y,$z) = split (" ",$line);
	$outFile = $output."_".$count."\.tst";
	$entry .= $outFile ."\n";
	$z=~ s/\`//;
	$z=~ s/\'//;
	$cmd = "cat $first $z $second > $outFile";
	$log->info("$cmd") if ( $profFile->{debug} > 2 ) ;
	$key = `$cmd`;
	if ( $profFile->{debug} < 1 ) {
	    $key = `rm -f $z`;
	}
    }
    $msg .=$entry;
    return($PASS,$msg);
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

my @commands = ();

$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man,
		  "l=s"=>\$userInput{logdir},		  
		  "f=s"=>\$userInput{filename},		  
		  "a=s"=>\$userInput{first},		  
		  "b=s"=>\$userInput{second},		  
		  "o=s"=>\$userInput{outputfile},
		  "t=s"=>\$userInput{testcase},
		  "d"=>\$userInput{display},
		  "z"=> sub { $userInput{logOff} = 0 } ,
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
my $fn = $userInput{filename};
$userInput{logger}->info( "         FILE NAME  -- \[$fn\] \n\n");
my $outputfile = $userInput{outputfile};
my $testcaseNum = $userInput{testcase};
if ( $testcaseNum =~ /$NOTDEFINED/ )  {
    $testcaseNum=`wc -l $fn`;
    ($x,$h)  = split (" ",$testcaseNum);
    $userInput{testcase} = $x;
    $userInput{logger}->info( "Number of testcases ($x) per testsuite were created as default. You could change the number of testcases by using option -t");
}   

if ( ($fn =~ /$NOTDEFINED/ ) ) {
   $userInput{logger}->info( "Error = please fill in the missing operand = filename($fn)");
    pod2usage(1);
    exit 1;
}

#create test suite file 
if ( $outputfile =~ /$NOTDEFINED/ ) {
    $temp= "testsuite";
    $outputfile = $dir."/$temp";
    $userInput{outputfile} = $outputfile;
} else {
    $temp=getBaseName($outputfile);
    ($x,$h) = split ( '\.',$temp);
    $outputfile = getBasePath($outputfile)."/"."$x";
}

($rc,$msg)=generatetestsuite(\%userInput,$userInput{filename});
$userInput{logger}->info($msg);
if ($userInput{display}) {
    $msg ="\n#-----------------\n#Output of $userInput{outputfile}\n#---------------------------\n";
    $msg .= `cat $userInput{outputfile}`;
    $userInput{logger}->info($msg);
}
exit 0 if ($rc == $PASS ) ;
exit 1;
1;

=head1 NAME

splitsuite.pl - used to create testsuites based on file containing testcases and number of testcases per testsuite specified by user. 

=head1 SYNOPSIS

=over

=item B<jsoncvt.pl>
[B<-help|-h>]
[B<-man>]
[B<-f> I< testcase file>]
[B<-l> I<log file directory>]
[B<-z> I<turn on LOGINFO >]
[B<-o> I<name of the testsuite >]
[B<-a> I<files variables to be inserted before testcase file >]
[B<-b> I<files with variables to be inserted after testcase file >]
[B<-t> I<number of testcases per file  >]

=back

=head1 OPTIONS AND ARGUMENTS

=over


=item B<-f>

File contains all testcase names 

=item B<-l >

Redirect stdout to the /path/xmlxxx.log

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-x>

Set debug to different level . ( more debug messages with higher number)

=item B<-z >

Turn ON LOG INFO logs

=item B<-o>

Output name prefix which will be appended with "<number>.tst".

=item B<-a>

File contains testcases  inserted before main testcase file ( optional ).

=item B<-b>

File contains testcases  followed after main testcase file  ( optional ).

=item B<-t>

number of testcases per testsuite.

=back


=head1 EXAMPLES

=over

1. This command is used to generate a number of testsuite with 200 testcases per testsuites 

splitsuite.pl -f /root/actiontec/automation/platform/1.0/verizon/testcases/bcc/tcases/testsuite.tst -a bccheader.tst -b bcctail.tst -t 200 -o jungle

DIR = /root/actiontec/automation/testsuites/1.0/common/bcc 
INFO - --> Log initialized <--
INFO -          FILE NAME  -- [/root/actiontec/automation/platform/1.0/verizon/testcases/bcc/tcases/testsuite.tst] 


INFO - Successfully Create testsuite from /root/actiontec/automation/platform/1.0/verizon/testcases/bcc/tcases/testsuite.tst and the new testsuites are created as the following:

jungle_0.tst
jungle_1.tst
jungle_2.tst
jungle_3.tst
jungle_4.tst


 
=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut
