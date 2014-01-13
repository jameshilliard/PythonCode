#!/usr/bin/perl -w
#---------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to parse IP from ifconfig log file 
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
use Expect;
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
    "interface"=>$NOTDEFINED,
    "outputfile"=>$NOTDEFINED,
    "user"=>"root",
    "dutip"=>"127.0.0.1",
    "cmd"=>$NOTDEFINED,
    "pwd"=>"actiontec",
    "screenoff"=>0,
    "logoff"=>0,
    "port"=>{},
#    "commands"=>["ifconfig -a | grep -e Link -e \"inet addr:\""], 
    "commands"=>["ifconfig -a ","exit"], 
    "errtable"=>[],
    "insert"=>[],
    "timeout"=>"10",
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
    $profFile->{logger}->info("--> Log initialized <--") if ( $profFile->{debug} >2 );
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

#-------------------------------------------------------
#--------------------------------------------------------
sub accessRmtHost {
    my ( $profFile)=@_;
    my $tmo = $profFile->{timeout};
    my $temp = 0;
    my $rc = $PASS;
    my $rc2 ;
    my $index;
    my $errindex;
    my $errsize;
    my $errkey;
    my $limit;
    my $log = $profFile->{logger};
    my $cmd ="";
    my $user = $profFile->{user};
    my $pwd = $profFile->{pwd};
    my $server  = $profFile->{dutip};
    my $testLog= $profFile->{outputfile};
    my @buff;
    my $junk;
    my $try= 0;
    ($server,$junk) = split ('\/',$server);
    $limit = @{$profFile->{commands}};
    $junk = system("touch $testLog");
    $log->info("NUMBER OF CMD= $limit" )  if ( $profFile->{debug} > 2 );
    
    for ( $index = 0 ; $index < $limit ; $index++) {
	$cmd = $cmd.$profFile->{commands}[$index]." ; ";
    }
    if ( $limit > 0) {
	$cmd = "ssh $user\@$server "." \"$cmd\" > $testLog ";
    } else {
	$cmd = "ssh $user\@$server "." \"echo NULL \" > $testLog ";
    }
    my $msg = "executeCmdProcess: successfully execute $cmd";

    $log->info( "stepCmdProcess: cmd($cmd) ")  if ( $profFile->{debug} > 2  );
    if ( $profFile->{noprint} ) { $log->info("stepCmdProcess with TMO($tmo):cmd($cmd)")};
    my $exp=Expect->spawn("$cmd");
    $limit = 4;
    if ( defined $exp ) {
	while ( $try < $limit ) {
	    $exp->expect($tmo,
			 [
			  timeout =>
			  sub {
			      $log->info("stepCmdExecute:$cmd is TimeOUT ");
			      $rc = $FAIL; #failed
			      $try = 10;
			      $msg = " TIMEOUT ";
			      return;
			  }
			 ],
			 [
			  "Connection refused",
			  sub {
			      my $fh = shift;
			      $rc =$FAIL;
			      $try = 11;
			      $msg = " CONNECTION REFUSED";
			      $log->info("$msg"); 
			      return;
			  }
			 ], 
			 [
			  "Are you sure you want to continue connecting (yes/no)?",
			  sub {
			      my $fh = shift;
#			      print (" SSH \n ====== \n");
			      $fh->send("yes\n");
			      $try = 1;
			      sleep 2;
			  }
			 ],
			 [
			  "[P|p]assword:*",
			  sub {
			      my $fh = shift;
			      $try++;
			      if ( $try >=  $limit ) {
				  $try = 12;
				  $rc=$FAIL;
				  $msg = "UNKNOWN PASSWORD($pwd)";
				  return;
			      }
			      $fh->send("$pwd\n");
			      $try = 12; # 3
			      $rc = $PASS;
			  }
			 ],
			 [ eof => 
			   sub { 
			       
#			       $log->info ("==>EOF \n"); 
			       $rc = $PASS ;
			       $try = 12;
			   }
			 ],	 	
		);
	}
    
	if ( $rc == $PASS ) {
	    $exp->expect($tmo,
			 [
			  timeout =>
			  sub {
			      $log->info("stepCmdExecute:$cmd is TimeOUT ");
			      $rc = $FAIL; #failed
			      $try = 10;
			      $msg = " TIMEOUT ";
			      return;
			  }
			 ],
			 [ eof => 
			   sub { 
			       
#			       $log->info ("==>EOF \n"); 
			       $rc = $PASS ;
			       $try = 12;
			   }
			 ],	 	
		);
	    
	}
    

	#$log->info ("==>try($try) \n"); 
	if ($rc == $FAIL) {
	    $msg = "Failed to execute $cmd due to $msg" ;
	} else { 
	    $rc = $PASS;
	    $msg = "Successfully execute ($try)--  $cmd" ;
	}

    };
    return ($rc,$msg);
}
#-------------------------------------------
# convermask
#-------------------------------------------
sub convertmask {
    my ( $mask ) = shift ;
    my @buff = split ( '\.',$mask);
    my $lim = $#buff;
    my ($index,$i,$result,$lmask);
    return($mask) if ($lim < 2 );
    $lmask = 0;
    for ( $index=0; $index <=$lim; $index++) {
	$result=$buff[$index];
	for ( $i=0; $i < 8 ; $i++ ) {
	    if ( $result & 0x1 ) {
		$lmask++;
	    }
	    $result = $result >> 1;
	}
    }
    return ( $lmask );
}
#-------------------------------------------
# Extract Host IP
#-------------------------------------------
sub extractHostIp{
    my ($profFile,$junk) = @_;
    my $rc=$PASS;
    my $msg="Successfully Set up WAN interface ";
    my $log = $profFile->{logger};
    my ($index,$i,$line);
#    my $outputfile = $profFile->{outputfile};
    my $inputfile = $profFile->{outputfile};
    my $dut = $profFile->{dutip};
    my $user = $profFile->{user};
    my $pwd = $profFile->{pwd};
    my $ptr= \%{$profFile->{port}};
    my (@junk,@junk2,$temp,$key);
    my $curEntry;
    open(INPUT,"<$inputfile") or die ( "Error:Could not open $inputfile ");
    my @buff=<INPUT>;
    close INPUT;
    my $start = 0;
    for ( $index=0;$index<=$#buff;$index++) {
	$line = $buff[$index];
	$line =~ s/\n//g;
	next if ( $line =~ /^\s*$/ );
	if ( $line =~ /Link encap:/ ) {
	    $log->info("start=0=>line:$line") if ( $profFile->{debug} > 1 ); 
	    if ( $start == 1 ) {
		if ( defined $curEntry ) {
		    #initial with fake IP 
		    $curEntry->{ipaddr}="127.8.8.8 ";
		    $curEntry->{mask}=24;
		}
	    }
	    $start=1;
	    @junk=split(" ",$line);
	    $ptr->{$junk[0]} {hwaddr} = $junk[$#junk];
	    if ( $line =~ /hwaddr\b/i ) {
		$ptr->{$junk[0]} {hwaddr} = $junk[$#junk];
	    }
	    $curEntry = \%{$ptr->{$junk[0]}};
	}
	if ( $start == 1 ) {
	    $log->info("start=1=>line:$line") if ( $profFile->{debug} > 1 ); 
	    if ( $line =~ /inet addr:/ ) {
		if ( ! ( defined $curEntry) ) {
		    $msg="Error: internal error curEntry is not defined";
		    $rc=$FAIL;
		    return($rc,$msg);
		}
		$start=0;
		@junk = split(" ",$line);
		for ( $i = 0 ;$i <= $#junk;$i++) {
		    # get ip address
		    $log->info("start=1=>junk($i):$junk[$i]") if ( $profFile->{debug} > 1 ); 
		    if ( $junk[$i]=~ /^addr:/i ) {
			@junk2=split(":",$junk[$i]);
			$curEntry->{ipaddr}=$junk2[1];
		    }
		    # get Mask 
		    if ( $junk[$i]=~ /^mask:/i ) {
			@junk2=split(":",$junk[$i]);
			#convert to number bit mask 
			$junk2[1]=convertmask($junk2[1]);
			$curEntry->{mask}=$junk2[1];
		    }		    
		}
		$curEntry="";
	    } # end of if (inet address)
	}
    }
    $msg="0.0.0.0";
    $ptr= \%{$profFile->{port}};
    $log->info("result:STARTING to grep interface $profFile->{interface} info ") if ( $profFile->{debug} > 1 ); 
    foreach $key ( keys %{$ptr} ) {	
	$log->info("result:compare $profFile->{interface} and $key") if ( $profFile->{debug} > 1 );
#	next if ( strcmp($key,$profFile->{interface}) != 0 ) ;
	if ( $profFile->{interface} eq $key ) {
	    $msg=$ptr->{$key}{ipaddr}."/$ptr->{$key}{mask}";
	    $log->info("result:$msg") if ( $profFile->{debug} > 1 ); 
	    last;
	}
    }
    $rc=$PASS;
    if ( $msg =~ /"0.0.0.0"/ ) {
	$rc =$FAIL;
    }
    if ( $profFile->{debug} > 2 ) {
	$temp = Dumper($ptr);
	$log->info($temp);
    }
    return ($rc,$msg);
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
		  "f=s"=>\$userInput{outputfile},
#		  "o=s"=>\$userInput{outputfile},
		  "u=s"=>\$userInput{user},
		  "p=s"=>\$userInput{pwd},
		  "i=s"=>\$userInput{interface},
		  "c=s"=>\$userInput{cmd},
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
printf ( "DIR = $dir \n") if ($userInput{debug} > 1 ); 
#---------------------------------------------
# Initialize Logger 
#---------------------------------------------
($rc,$msg) = initLogger(\%userInput, );
if ( $rc != 1) {
    printf ("RC$rc $msg\n");
    exit 1;
} 

#printf("--------------- Input Parameters  ---------------\n") if $userInput{debug} ;
$junk =" ";
$temp=Dumper(\%userInput);
$userInput{logger}->info("------------------ $scriptFn  Input Parameters  ------------------\n$temp") if ($userInput{debug} > 1 ) ;

my $limit = @commands;
my $line;
if ($limit > -1  ) {
    $junk =" ";
    foreach $line (  @commands) { 
	$junk .="-v $line "; 
    }
    $junk = $userInput{scriptname}.".pl -l ".$userInput{logdir}.$junk;
#    $userInput{logger}->info("\n Executing command=$junk\n\n");
}
=begin2
if ( $userInput{inputfile} =~ /$NOTDEFINED/ ) {
    $userInput{logger}->info("Error: Need Input file ");
    exit (1);
}  
=cut





#$userInput{interface} = lc $userInput{interface} ;
my $outputfile=$userInput{outputfile};
if ( $userInput{outputfile} =~ /$NOTDEFINED/ ) {
    $temp = "getrmtip_expect";
    $outputfile = $dir."/$temp\.log";
    $userInput{outputfile} = $outputfile;
    ($rc,$msg)=accessRmtHost(\%userInput);
    if ( $rc == $FAIL ) {
#    print ("Failed:$msg");
	exit(1);
    }
    $userInput{logger}->info("Setup WAN interface Log  is saved in $outputfile") if ( $userInput{debug} > 1) ;
}
($rc,$msg)=extractHostIp(\%userInput);


$userInput{logger}->info("$msg") if ( $userInput{debug} > 1) ;
print ($msg);
if ( $rc == $FAIL) {
    $userInput{logger}->info("==> $userInput{scriptname}  failed") if ( $userInput{debug} > 1) ;
    exit (1);
} 
$userInput{logger}->info("==> $userInput{scriptname} passed") if ( $userInput{debug} > 1) ;

exit (0);
1;
__END__

=head1 NAME

getrmtip.pl - is a utility to get a remote Ip based on the interface name. This utility is working with Remote Host having ssh enable. Beside it could parse the input file which has the result  ifconfig format.  

=head1 SYNOPSIS

=over 12

=item B<getrmtip.pl>
[B<-help|-h>]
[B<-man>]
[B<-l> I<log file path>]
[B<-d> I<DUT IP >]
[B<-i> I<eth0|wlan0|eth0:1>]
[B<-u> I<DUT logon userid>]
[B<-p> I<DUT logon password >]
[B<-x> I<debug level>]
[B<-f> I<Input file>]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-l >

Redirect stdout to the /path/setupWanIf.log

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


=item B<-i>

Select WAN Interface eth0|eth2_rename|eth1:10

=item B<-f>

Input file which contain the format of ifconfig 


=back

=head1 EXAMPLES

1. The following command is used to get up eth0 ip from remote host 

perl getrmtip.pl -d 10.1.10.1 -u root -p actiontec -i eth0  

=head1 AUTHOR

Please report bugs using L<http://budz/>

JoeNguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut
