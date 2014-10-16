#!/usr/bin/perl -w
#---------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to generate traffic
#
#
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
use POSIX ':signal_h';
my $OUTPUTLOG_SIZE=40 * 1024;

my $TBLOCKFILE = "/tmp/tblockfile.txt";
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
#-----<<<----------------

my %userInput = (
    "debug" => "0",
    "scriptname"=>$scriptFn,
    "logdir"=>$NOTDEFINED,
    "filename"=>$NOTDEFINED,
    "destip"=>"127.0.0.1",
    "srcip"=>$NOTDEFINED,
    "numofip"=>1,
    "thread"=>1,
    "outputfile"=>$NOTDEFINED,
    "user"=>"admin",
    "pwd"=>"admin1",
    "traffictype"=>"ftp",
    "screenoff"=>0,
    "iteration"=>0,
    "logoff"=>0,

    );
#************************************************************
# This routine is used to increase the ipaddress/netmask
# or ipaddress alone 
#************************************************************
sub ipIncr {
    my ($profFile,$ipOrg, $incr)=@_;
    my $log = $profFile->{logger};
    my ($ip,$mask)=split('/',$ipOrg);
    my @add = split('\.',$ip);
    my $temp = @add;
    my $mod = 0;
    my $nextCount =0;
    my $i;
    if ( defined $mask ) {
	$log->info(" Increment $ip -- mask= $mask -- IP fields=$temp") if ($profFile->{debug} > 3 ) ;
    } else {
	$log->info(" Increment $ip -- NO mask -- IP fields=$temp ") if ($profFile->{debug} > 3 ) ;
    }
    if ( $temp != 4) { return $ipOrg ;}
#    $log->info("Start IP(3) = $add[3]");
    $add[3] +=$incr;
    for ( $i = 3 ; $i >= 0; $i-- ) {
#	$log->info("IP($i) = $add[$i]");
	$add[$i] += $nextCount;
	if ( $add[$i] > 254) {
	    $nextCount = 1;
	    $add[$i] = $add[$i] % 255;
	} else {
	    $nextCount = 0;
	}
#	$log->info("MOD IP($i) = $add[$i]");
	if (($add[$i] == 0 ) && ($i == 3 )) {
	    $add[$i]++;
	}
    }
    $ip = join('.',@add);
    if ( defined $mask ) { 
	$ip = join('/',$ip,$mask);
    }
    return($ip);
}

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
#-------------------------------------------
#  Launch wget
#-------------------------------------------
sub launch_wget{
    my ($profFile,$junk) = @_;
    my $rc=$PASS;
    my $msg="Successfully Parsing Json Header";
    my $log = $profFile->{logger};
    my ($temp,$cmd);
    my $outputfile = $profFile->{outputfile};
    my $destip = $profFile->{destip};
    my $srcip = $profFile->{srcip};
    my $numOfIp = 0;
    my $numOfThread = $profFile->{thread};
    my $user = $profFile->{user};
    my $pwd = $profFile->{pwd};
    my $dir = $profFile->{logdir};
    my $filename = $profFile->{filename};
    my ($count,$httplog,$ftplog);
    my $type = $profFile->{traffictype};
   
    for ( $count = 0 ; $count < $numOfThread; $count++) {
	$log->info( "==>Thread:$count ");
	$httplog = $dir."/http_".$count."\.log";
	$ftplog = $dir."/ftp_".$count."\.log";
	if ( $srcip =~ /$NOTDEFINED/) {
	    if ( $type =~ /http/ ) {
		$msg = system("wget http://$destip/$filename -O $httplog & ");
	    } else {
		$msg = system("wget ftp://$user:$pwd\@$destip/$filename -O $ftplog & ");
	    }
	} else {
	    if ( $type =~ /http/ ) {
		$msg = system ("wget http://$destip/$filename --bind-address=$srcip  -O $httplog & ");
	    } else {
		$msg = system("wget ftp://$user:$pwd\@$destip/$filename --bind-address=$srcip  -O $ftplog & ");
	    }
	}
	$numOfIp++;
	if ( $numOfIp >=  $profFile->{numofip} ){
	    $numOfIp = 0;
	    $destip = $profFile->{destip};
	    $srcip = $profFile->{srcip};		
	} else {
	    $destip = ipIncr($profFile,$destip,1);
	    $srcip = ipIncr($profFile,$srcip,1) if ( $srcip !~ /$NOTDEFINED/) 
	}
    }
    $log->info( "=> SLEEP FOR 3 SEC ");
    sleep 3;
    $httplog = $dir."/http_".$count."\.log";
    if ( $srcip =~ /$NOTDEFINED/) {
	if ( $type =~ /http/ ) {
	    $msg = `wget http://$destip/$filename -O $httplog `;
	} else {
	    $msg = `wget ftp://$user:$pwd\@$destip/$filename -O $ftplog `;
	}
    } else {
	if ( $type =~ /http/ ) {
	    $msg = `wget http://$destip/$filename --bind-address=$srcip  -O $httplog `;
	} else {
	    $msg = `wget ftp://$user:$pwd\@$destip/$filename --bind-address=$srcip  -O $ftplog `;
	}
    }

    $rc=$FAIL;
    if ( $rc =~ /saved / ) {
	$rc=$PASS;
    }
    return ($rc,$msg);
}

#-------------------------------------------
# Generate http traffic
#-------------------------------------------
sub generate_http_ftp{
    my ($profFile,$junk) = @_;
    my $rc=$PASS;
    my $msg="Successfully Parsing Json Header";
    my $log = $profFile->{logger};
    my ($temp,$cmd);
    my $outputfile = $profFile->{outputfile};
    my $destip = $profFile->{destip};
    my $srcip = $profFile->{srcip};
    my $numOfIp = $profFile->{numofip};
    my $user = $profFile->{user};
    my $pwd = $profFile->{pwd};
    my $iteration = $profFile->{iteration};
    my ($count);
    if ( $iteration != 0 ) {
	$count = 0;
	for ( $temp = $iteration ; $temp > 1; $temp--) {
	    $log->info("\n*****************\nIteration: $count\n*****************\n");
	    ($rc,$msg)=launch_wget($profFile);
	    $count ++;
	}
    } else {
	$count = 0;
	while ( $iteration == 0 ) {
	    $log->info("\n*****************\nIteration: $count\n*****************\n");
	    ($rc,$msg)=launch_wget($profFile);
	    $count++;
	}
    }
    return ($rc,$msg);
}
#-------------------------------------------
# Generate traffic
#-------------------------------------------
sub generate_traffic {
    my ($profFile,$junk) = @_;
    my $rc=$PASS;
    my $type = $profFile->{traffictype};
    my $msg="Successfully generate traffic";
    my $log = $profFile->{logger};
    ($rc,$msg)=generate_http_ftp($profFile);
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
my @buff;
$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h,
		  "w"=>sub {$userInput{traffictype}="http";},
		  "man"=>\$option_man, 
		  "f=s"=>\$userInput{filename},
		  "l=s"=>\$userInput{logdir},
		  "d=s"=>sub { @buff=split("/",$_[1]);$userInput{destip}=$buff[0]; }, 
		  "i=s"=>sub { $userInput{iteration}=$_[1]+1 },
		  "s=s"=>sub { @buff=split("/",$_[1]);$userInput{srcip}=$buff[0]; },
		  "m=s"=>\$userInput{numofip},
		  "n=s"=>\$userInput{thread},
		  "o=s"=>\$userInput{outputfile},
		  "u=s"=>\$userInput{user},
		  "p=s"=>\$userInput{pwd},
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

if ( $userInput{filename} =~ /$NOTDEFINED/ ) {
    print "Error: Please enter download filename for http or ftp\n";
    exit (1);
}


#---------------------------------------------
# Initialize Logger 
#---------------------------------------------
($rc,$msg) = initLogger(\%userInput, );
if ( $rc != 1) {
    printf ("RC$rc $msg\n");
    exit 1;
} 

#printf("--------------- Input Parameters  ---------------\n") if $userInput{debug} ;
$userInput{logger}->info("------------------ $scriptFn  Input Parameters  ------------------\n");
$junk ="";
foreach $key ( keys %userInput ) {
    $junk .= " $key = $userInput{$key} :: " ;
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
my $outputfile=$userInput{outputfile},;
if ( $outputfile =~ /$NOTDEFINED/ ) {
    $temp = "traffic";
    $outputfile = $dir."/$temp\.log";
    $userInput{outputfile} = $outputfile;
} else {
    $outputfile = $dir."/".$outputfile;
    $userInput{outputfile} = $outputfile;
}
$userInput{logger}->info("Log file  is saved in $outputfile");

($rc,$msg)=generate_traffic(\%userInput);

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

gen_traffic.pl - is a utility to generate HTTP/FTP traffic  

=head1 SYNOPSIS

=over 12

=item B<gen_traffic.pl>
[B<-help|-h>]
[B<-man>]
[B<-l> I<log file path>]
[B<-i> I<Iteration >]
[B<-d> I<Destination IP >]
[B<-s> I<Source IP >]
[B<-n> I<number of ip>]
[B<-f> I<Http/ftp filename>]
[B<-w> I<select HTTP>]
[B<-u> I<DUT logon userid>]
[B<-p> I<DUT logon password >]
[B<-o> I<output file>]
[B<-x> I<debug level>]
[B<-n> I<number of thread>]


=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-l >

Redirect stdout to the /path/gen_snat.log

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-x>

Set debug to different level . ( more debug messages with higher number)

=item B<-d>

Destination IP address.

=item B<-s>

Source IP address.

=item B<-u>

DUT login userid.

=item B<-p>

DUT password userid.

=item B<-m>

Set Number of IP addresses. By default it was set to 1

=item B<-n>

Set Number of thread. By default, n was set to 1

=item B<-i>

Number of iteration. By default, 0=forever is set . 

=item B<-w>

Select http . By default ftp was selected

=item B<-o>

Output log file . By default file was saved to traffic.log

=back


=head1 EXAMPLES

1. The following command is used to generate http traffic to (10.10.10.1 -- 10.10.10.10 ) with 20 thread
    perl gen_traffic.pl  -u admin -p admin1 -d 10.10.10.1  -m 10 -l /tmp  -n 20

2. The following command is used to generate http traffic from ( 192.168.1.1 -- 192.168.1.10 ) to (10.10.10.1 -- 10.10.10.10 )
    perl gen_traffic.pl -u admin -p admin1 -d 10.10.10.1 -s 192.168.1.1 -m 10 -l /tmp -o test123.log  -n 20 




=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>



=cut
