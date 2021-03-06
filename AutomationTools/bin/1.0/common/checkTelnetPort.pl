#!/usr/bin/perl -w
#----------------------------------
#Author: Alex_dai
#
#Description: Auto execute the operation of telnet to 
#	      verify the function of telnet
#
#Input parameters:
#		host:telnet ip_address
#		user :login username
#		password:login password
#		port:port-setting
#		logfile:the file used for saving logger
#
#Usage: ./checkTelnetPort.pl -d 192.168.0.1 -u admin -p QwestM0dem -e 23
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
    if ( $profFile->{outputfile} =~ /$NODEFINE/) {
    while ( $found ) {
	$localLog = $profFile->{logdir}."/".$profFile->{scriptname}."_output_$count.log";
	if ( !(-e $localLog)){
	    $found=0;
	    next;
	}
	$count++;
    }
    }else{
	$localLog = $profFile->{logdir}."/".$profFile->{outputfile};
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

#-------------------------------------------------------
# Set up Child Process
# !!!!NOTE that the return code of this routine
# is exceptional. The return code is generated by external script
#--------------------------------------------------------
sub executeCmdProcess {
    my ( $profFile)=@_;
    my $tmo = $profFile->{timeout};
    my $temp = 0;
    my $rc = $PASS;
    my $log = $profFile->{logger};
    my $cmd ="";
    my $server  = $profFile->{server};
    my $user = $profFile->{user};
    my $psw = $profFile->{password};
    my $try= 0;
    my $msg;

    $cmd = "telnet $server $profFile->{port}";
    if ( $profFile->{debug} > 2 ) {  $log->info( "stepCmdProcess: cmd($cmd) ") };
    if ( $profFile->{noprint} ) { $log->info("stepCmdProcess with TMO($tmo):cmd($cmd)")};
    my $exp=Expect->spawn("$cmd");
    if ( defined $exp ) {
there:
	while (1) {
	    $exp->expect($tmo,
	    		 [
			  timeout =>
			  sub {
			      $log->info("stepCmdExecute:$cmd is TimeOUT ");
			      $rc = $FAIL; #failed
			      $msg = " TIMEOUT ";
			      last there;
			  }
			 ],
			 [
			  "No route to host",
			  sub {
			      $rc =$FAIL;
			      $msg = "No route to host";
			      last there;
			  }
			 ], 
			 [
			  "Connection refused",
			  sub {
			      $rc =$FAIL;
			      $msg = "Connection refused";
			      last there;
			  }
			 ],
			 [
			  "[L|l]ogin:",
			  sub {
			      my $fh = shift;			      
			      $rc = $PASS;			      
			      $msg = "send username:$user to telnet server:$server.";
			      $fh->send("$user\n");
			      return;		      
			  }
			 ],
			 [
			  "[P|p]assword:",
			  sub {	
			      my $fh = shift;		      
			      $rc = $PASS;			      
			      $msg = "send password:$psw to telnet server:$server.";
			      $fh->send("$psw\n");
			      return;
			      		      
			  }
			 ],
			 [
			 "Login incorrect",
			 sub {
			     $rc = $FAIL;
			     $msg = "login failed--username or password error.";
			     last there;
			  }
			 ],
			 [
			 ">",
			 sub {
			     my $fh = shift;
			     $rc = $PASS;
			     $msg = "telnet to $server success.";
			     $fh->send("exit\n");
			     return;
			  }
			 ],
			 [
			 "Bye bye.",
			 sub {
			     $rc = $PASS;
			     $msg = "telnet to $server success.";
			     last there;
			  }
			 ],
			 [ eof => 
			   sub { 
			       
#			       $log->info ("==>EOF \n"); 
			       $rc = $FAIL ;
			       $msg = "==>EOF \n";
			   }
			 ],	 	
		);
	}
	$log->info("$msg");
	$exp->hard_close();
    }
	if ($rc == $FAIL) {
	    $msg = "Failed to execute $cmd due to $msg" ;
	} else { 
	    $rc = $PASS;
	    $msg = "Successfully execute --  $cmd" ;
	}  
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
    "server"=>$NODEFINE,
    "username"=>$NODEFINE,
    "password"=>$NODEFINE,
    "port"=>$NODEFINE,
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
		  "d=s"=>\$userInput{server},
		  "u=s"=>\$userInput{user},
		  "p=s"=>\$userInput{password},
		  "e=s"=>\$userInput{port},
		  "t=s"=>\$userInput{timeout},
		  "n"=>sub { $userInput{noprint} = 0},
		  );
#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);
if ( $userInput{server} =~ $NODEFINE || 
     $userInput{user} =~ $NODEFINE || 
     $userInput{password} =~ $NODEFINE ||
     $userInput{port} =~ $NODEFINE) {
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

if ( ($userInput{server} =~ /$NODEFINE/) ||  ($userInput{server} =~ /^\s*$/ )   ) {
    print ("\n==>Error Missing Destination IP address\n");
    pod2usage(1);
    exit 1;
}


#printf("--------------- Input Parameters  ---------------\n") if $userInput{debug} ;

if ( $userInput{ noprint } ) { 
print("--------------- $scriptFn  Input Parameters  ---------------\n");
    foreach $key ( keys %userInput ) {
#    printf (" $key = $userInput{$key} :: " ) if $userInput{debug} ;
	print (" $key = $userInput{$key} :: \n" );
    }
}

#-------------------------------------------------
#Parsing input file from Management Frame Work  
#-------------------------------------------------
    
($rc,$msg) = executeCmdProcess(\%userInput);
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
checkTelnetPort.pl is used to Auto execute the operation of telnet to verify the function of telnet

=head1 SYNOPSIS

=over

=item B<checkTelnetPort.pl>
[B<-help|-h>]
[B<-man>]
[B<-o> I<output file to save file >]
[B<-l> I<log file directory>]
[B<-t> I<time out for each command executed by checkTelnetPort.pl >]
[B<-u> I<user loggin name>]
[B<-p> I<user password>]
[B<-d> I<server address>]
[B<-i> I<insert header title(optional)>]
[B<-n> I<not to print out debug message>]


=back

=head1 OPTIONS AND ARGUMENTS

=over

=item B<-o>

Output file where the output of ssh will be stored

=item B<-l >

Redirect stdout to the /path/checkTelnetPort.log

=item B<-d >

Server address

=item B<-u >

User loggin name

=item B<-p>

User password

=item B<-e>

Port number

=item B<-t >

Set timeout in seconds for each command ( default = 60 seconds)

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-x>

Set debug to different level . ( more debug messages with higher number)

=item B<-i>
Insert text file at the beginning of the text file 

=item B<-v>
linux command line 

=item B<-n>
Suppress the debug message 


=back


=head1 EXAMPLES

=over

1. The following command is used to telnet to address 192.168.0.1 through port 23 to verify the function of telnet
         perl checkTelnetPort.pl -d 192.168.0.1 -u admin -p QwestM0dem -e 23 

=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut
