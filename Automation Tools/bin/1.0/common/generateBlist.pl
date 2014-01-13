#!/usr/bin/perl -w
#----------------------------------
#Author: Alex_dai
#
#Description: find all files in a directory,then output the filename 
#	      list which contains the filename in specified file
#
#Input parameters:
#		$directory   : the directory you want to find
#		$filename    : the file which contains the content you want to find 
#		$outputfile  : output file used to save the result
#		$logdir      :
#
#Usage: ./generateBlist.pl -d $directory -f $filename -o $outputfile  [-l $logdir]
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
#-----<<<----------------
my $FAIL=1;
my $PASS=0;
my $NODEFINE="none";
my @junk = split( /\//, $0);
@junk = split('\.',$junk[$#junk]);
my $scriptFn = $junk[0];
my $logdir = `pwd`;
$logdir=~ s/\n//;
my %diffResult;
my $LocalDirA;
my $LocalDirB;
my @LocalDirA ;
my @LocalDirB ;
my @pathA ;
my @pathB ;
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

#--------------------------------------------------------
#
#find files contained the black name list
#
#--------------------------------------------------------
sub FindProcess{
	my ($profFile) = @_;
	my $rc = $PASS;
	my $msg = "find file list successfully!";
	my $log = $profFile->{logger};
	my @Blist = ();
	my $cmd;
	my $output = $profFile->{outputfile};
	my $path = $profFile->{directory};
	my $result = "no";
	my %temp;

	open BLIST1,"< $profFile->{filename}";
	while(<BLIST1>){
		if(/^(\w\S+)\s/){
			push @Blist,$1;
		}
	}
	close BLIST1;

	system("rm -f $output");
	system("touch $output");
	foreach my $filename (@Blist){
		$cmd = "find $path -depth | xargs grep '$filename' -l >> $output";
		$rc = system($cmd);
		if($rc == 0){
			$rc = $PASS;
			$msg = "find file list successfully!";
			$result = "yes";
		}
	}
	open BLIST2,"< $output";
	while(<BLIST2>){
		$temp{$_} = "";
	}
	close BLIST2;
	open BLIST2,"> $output";
	print "\n-----------find result------------\n";
	foreach my $key (sort keys %temp){
		$key =~ s/.*\///;
		print $key;
		print BLIST2 $key;
	}
	close BLIST2;
	if($result !~ /yes/){
		$msg = "nothing finded";
	#	print "$msg\n";
	}
#	$log->info($msg);
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
    "outputfile"=>$NODEFINE,
    "scriptname"=> $scriptFn,
    "screenOff"=> 0,
    "filename"=>$NODEFINE,
    "directory"=>$NODEFINE,
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
		  "f=s"=>\$userInput{filename},
		  "d=s"=>\$userInput{directory},
		  "o=s"=>\$userInput{outputfile},
		  "l=s"=>sub {  $userInput{logdir} = $_[1];},
		  "n"=>sub { $userInput{noprint} = 0},
		  );
#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);
if ( $userInput{filename} =~ $NODEFINE || 
     $userInput{directory} =~ $NODEFINE || 
     $userInput{outputfile} =~ $NODEFINE) {
    print ("\n==>Error Missing Version param\n");
    pod2usage(1);
    exit 1;
}

($rc,$msg) = initLogger(\%userInput, 0);
if ( $rc == $FAIL) {
    print ("RC$rc $msg\n");
    exit 1;
} 
if ( $globalRc == $FAIL) {
    $userInput{logger}->info("$msg");
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

($rc,$msg)= FindProcess(\%userInput);
goto fail if($rc == $FAIL);


if ( $userInput{noprint} ) {
    $userInput{logger}->info("$msg");
}
fail:
if ( $rc == $FAIL) {
    $userInput{logger}->info("==> $userInput{scriptname}  failed");
    exit 1;
}
pass:
$userInput{logger}->info("==> $userInput{scriptname} passed");
exit (0);
1;
__END__


=head1 NAME
generateBlist.pl is used to find all files in a directory,then output the filename list which contains the filename in specified file 

=head1 SYNOPSIS

=over

=item B<generateBlist.pl>
[B<-help|-h>]
[B<-man>]
[B<-d> I<directory>]
[B<-f> I<filename>]
[B<-o> I<output file to save result >]
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

=item B<-d >

Directory to be finded

=item B<f>

Filename containing the content to be finded

=item B<-o>

Output file where the output of generateBlist.pl will be stored

=item B<-l >

Redirect stdout to the /path/generateBlist.log

=item B<-x>

Set debug to different level . ( more debug messages with higher number)

=item B<-i>
Insert text file at the beginning of the text file 

=item B<-n>
Suppress the debug message 


=back


=head1 EXAMPLES

=over

1. The following command is used to find all files in the $directory,then save the blacklist which contains the filename in specified file $filename to $outputfile
         perl generateBlist.pl -d $directory -f $filename -o $outputfile  [-l $logdir]

=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut
