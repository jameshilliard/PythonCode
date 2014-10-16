#!/usr/bin/perl -w	
#----------------------------------
#Author: Alex_dai
#
#Description: Replace all the variables in inputfile to the value in %ENV if it is defined,then save to outputfile.
#	      
#
#Input parameters:
#		inputfile  :
#		outputfile :
#		logdir     :log file directory
#
#Usage: ./env2file.pl -i inputfile -o outputfile -l logdir 
#
#-----------------------------------

use strict;
use warnings;
use diagnostics;
use Log::Log4perl;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use Data::Dumper;
use Expect;
#default timeout for each command
my $CMD_TMO = 60; 
#-----<<<----------------
my $FAIL=1;
my $PASS=0;
my $NODEFINE="none";
my @junk = split( /\//, $0);
@junk = split('\.',$junk[$#junk]);
my $scriptFn = $junk[0];
my $logdir = `pwd`;
$logdir=~ s/\n//;
#---------------------------------------------------------
# This routine is used to initialize the log feature
#---------------------------------------------------------
sub initLogger {
    my ( $profFile, $junk) = @_;
    my $rc = $PASS;
    my $msg ="Successfully Set Logger";
    my $found=1;
    my $count=0;
    my $localLog;
    #--------------------
    # initialize logger
    #---------------------
    my $temp = $profFile->{scriptname}."_$profFile->{seed}";
    
    while ( $found ) {
	$localLog = $profFile->{logdir}."/".$profFile->{scriptname}."_output_$count.log";
	if ( !(-e $localLog)){
	    $found=0;
	    next;
	}
	$count++;
    }
    
    my $clobberLog = $profFile->{logdir}."/".$profFile->{scriptname}."_clobber_$count.log";
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
#	my $writer = Log::Log4perl::Appender->new("Log::Log4perl::Appender::File",
#						  filename => $clobberLog,
#						  mode => "clobber");
	$appender->layout($layout);	
	$profFile->{logger}->add_appender($appender);
#	$profFile->{logger}->add_appender($writer);
    }
    if ( $profFile -> {noprint} ) {
	$profFile->{logger}->info("--> Log initialized <--");
    }
    return($rc,$msg);

}

sub stringReplace{
	my ($profFile) = @_;
	my $rc = $PASS;
    my $msg="String replacement has been completed.";
    my $line;
    my $temp="";
    my $temp1="";
    my $key;
	my $log=$profFile->{logger};
	my $message;

	if(! open INPUTFILE,"< $profFile->{inputfile}" ){
		$rc = $FAIL;
		$msg = "Cannot open file: $profFile->{inputfile}";
		return($rc,$msg);
	}
	if(! open OUTPUTFILE,"> $profFile->{outputfile}" ){
		$rc = $FAIL;
		$msg = "Cannot open file: $profFile->{outputfile}";
		return($rc,$msg);
	}

	while($line = <INPUTFILE>){
		while($line =~ /\$/){
			$temp1 = "";
			foreach $key (keys %ENV){
				$temp = $key;
				if($line =~ /\$$temp/ and ($temp1 lt $temp)){
					$temp1 = $temp;
				}
			}
			if($temp1){
				$line =~ s/\$$temp1/$ENV{$temp1}/;
				$message = "\$$temp1 has been replaced by  $ENV{$temp1}";
				$log->info($message);
			}else {
				last;
			}
		}
		print OUTPUTFILE $line;
	}
	close OUTPUTFILE;
	close INPUTFILE;

    if(! open OUTPUTFILE,"< $profFile->{outputfile}" ){
		$rc = $FAIL;
		$msg = "Cannot open file: $profFile->{outputfile}";
		return($rc,$msg);
	}
	while($line = <OUTPUTFILE>){
        if($line =~ /\$/){
            $rc = 1;
            $msg = "There are still variables not be replaced !";
            close OUTPUTFILE;
            last;
        }
    }
    close OUTPUTFILE;

    return ($rc,$msg);
}

#************************************************************
# Main Routine
#************************************************************
MAIN:
my $TRUE=1;
my $FALSE=0;
my $option_h;
my $rc =0;
my $msg;
my $count = 0;
my $globalRc = $PASS;
my $option_man = 0;
my $temp;
my $found =0;
my $key;
my %userInput = (
    "debug" => "0",
    "logdir"=>$logdir,
    "inputfile"=>$NODEFINE,
    "outputfile"=>$NODEFINE,
    "timeout"=>$CMD_TMO,
    "scriptname"=> $scriptFn,
    "screenOff"=> 0,
    "logOff"=> 0,
    "noprint"=> 1,
    "errtable"=>[ "Login failed due to a bad username or password",
		  "parser error :",
    ],
    );

#---------------------------------------------
# Initialize Logger 
#---------------------------------------------
$userInput{seed}="0";
$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man, 
		  "l=s"=>sub {  $userInput{logdir} = $_[1];},
		  "o=s"=>\$userInput{outputfile},
		  "i=s"=>\$userInput{inputfile},
		  "t=s"=>\$userInput{timeout},
		  "n"=>sub { $userInput{noprint} = 0},
		  );
#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);
($rc,$msg) = initLogger(\%userInput, 0);
if ( $rc == $FAIL) {
    print ("RC$rc $msg\n");
    exit 1;
} 
if ( $globalRc == $FAIL) {
    $userInput{logger}->info("$msg");
    exit 1;
}

if ( ($userInput{inputfile} =~ /$NODEFINE/) ||  ($userInput{outputfile} =~ /^\s*$/ )   ) {
    print ("\n==>Error Missing Destination IP address\n");
    pod2usage(1);
    exit 1;
}


#printf("--------------- Input Parameters  ---------------\n") if $userInput{debug} ;

if ( $userInput{ noprint } ) { 
print("--------------- $scriptFn  Input Parameters  ---------------\n");
    foreach $key ( keys %userInput ) {
#    printf (" $key = $userInput{$key} :: " ) if $userInput{debug} ;
	print (" $key = $userInput{$key} ::\n" );
    }
}


#-------------------------------------------------
#Parsing input file from Management Frame Work  
#-------------------------------------------------
    
($rc,$msg) = stringReplace(\%userInput);
if ( $userInput{noprint} ) {
    $userInput{logger}->info("$msg");
}
if ( $rc == $FAIL) {
    $userInput{logger}->info("==> $userInput{scriptname}  failed");
    exit 1;
}
$userInput{logger}->info("==> $userInput{scriptname} passed");
exit (0);
1;
__END__


=head1 NAME
env2file.pl is used to replace all the variables in inputfile to the value in %ENV if it is defined,then save to outputfile.

=head1 SYNOPSIS

=over

=item B<env2file.pl>
[B<-help|-h>]
[B<-man>]
[B<-i> I<input file>]
[B<-o> I<output file to save result>]
[B<-l> I<log file directory>]
[B<-i> I<insert header title(optional)>]
[B<-n> I<not to print out debug message>]


=back

=head1 OPTIONS AND ARGUMENTS

=over

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-i>

Input file

=item B<-o>

Output file where the result will be stored

=item B<-l >

Redirect stdout to the /path/env2file.log

=item B<-x>

Set debug to different level . ( more debug messages with higher number)

=item B<-i>

Insert text file at the beginning of the text file 

=item B<-n>

Suppress the debug message 


=back


=head1 EXAMPLES

=over

1. The following command is used to replace all the variables in inputfile to the value in %ENV if it is defined,then save to outputfile.
         perl env2file.pl -i inputfile -o outputfile -l logdir

=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut
