#!/usr/bin/perl -w
#---------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to generate NAT policies 
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
    "wanip"=>"10.10.10.1",
    "lanip"=>"192.168.1.2",
    "numofnat"=>1,
    "outputfile"=>$NOTDEFINED,
    "user"=>"admin",
    "pwd"=>"admin1",
    "portnat"=>"0",
    "gateway"=>"0.0.0.0",
    "screenoff"=>0,
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
# Generate NAT policy
#-------------------------------------------
sub generate_policy{
    my ($profFile,$junk) = @_;
    my $rc=$PASS;
    my $msg="Successfully Parsing Json Header";
    my $json;
    my @buff;
    my $log = $profFile->{logger};
    my ($temp,$cmd);
    my $outputfile = $profFile->{outputfile};
    my $wanip = $profFile->{wanip};
    my $lanip = $profFile->{lanip};
    my $numOfNat = $profFile->{numofnat};
    my $user = $profFile->{user};
    my $pwd = $profFile->{pwd};
    my ($count);
    open( OUTPUT,">$outputfile") or die "Could not generate $outputfile";
    #--------------------
    # Generate login 
    #--------------------
    print OUTPUT "\{\n";
    print OUTPUT "\"0000_login\" :  \{\n";
    print OUTPUT "\t\"section\" : \"login\",\n";
    print OUTPUT "\t\"action\" : \"set\",\n";
    print OUTPUT "\t\"protocol\" : \"http\",\n";
    print OUTPUT "\t\"address\" : \"192.168.1.1\",\n";
    print OUTPUT "\t\"port\" : \"80\",\n";
    print OUTPUT "\t\"username\" : \"$user\",\n";
    print OUTPUT "\t\"password\" : \"$pwd\"\n";
    print OUTPUT "\},\n";

    print OUTPUT "\"0001_removenat\" :  \{\n";
    print OUTPUT "\t\"section\" : \"cleanup\",\n";
    print OUTPUT "\t\"cleaner\" : \"static nat\",\n";
    print OUTPUT "\t\"remove\" : \"all\"\n";
    print OUTPUT "\},\n";

    for ( $count=0; $count < $numOfNat ; $count++) {
	print OUTPUT "\"$count\_static_nat\" :  \{\n";
	print OUTPUT "\t\"section\" : \"firewall-static_nat\",\n";
	print OUTPUT "\t\"serviceName\" : \"sn_nopf_tc_$count\",\n";
	print OUTPUT "\t\"publicIP\" : \"$wanip\",\n";
	print OUTPUT "\t\"host\" : \"specify: $lanip\",\n";
	print OUTPUT "\t\"services\" : \"Any\"\n";
#	print OUTPUT "\t\"services\" : \"User Defined\",\n";
#	print OUTPUT "\t\"serviceName\" : \"Some Name - you can leave this out if wanted\",\n";
#	print OUTPUT "\t\"ports\" : \"TCP:source,destination;UDP:source,destination;TCP:any,80;UDP:9090,8080\",\n";

	print OUTPUT "\},\n";
	#--------------------------
	# Increment IP
	#-------------------------
	$wanip = ipIncr($profFile,$wanip,1); 
	$lanip = ipIncr($profFile,$lanip,1); 
    }
  
    print OUTPUT "\"9999_logout\" :  \{\n";
    print OUTPUT "\t\"section\" : \"logout\"\n";
    print OUTPUT "\}\n";
    print OUTPUT "\}\n";

    close OUTPUT;
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
		  "w=s"=>\$userInput{wanip},
		  "i=s"=>\$userInput{lanip},
		  "g=s"=>\$userInput{gateway},
		  "n=s"=>\$userInput{numofnat},
		  "o=s"=>\$userInput{outputfile},
		  "u=s"=>\$userInput{user},
		  "p=s"=>\$userInput{pwd},
		  "r"=>\$userInput{portnat},
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
    $temp = "nat_cfg";
    $outputfile = $dir."/$temp\.json";
    $userInput{outputfile} = $outputfile;
} else {
    $outputfile = $dir."/".$outputfile;
    $userInput{outputfile} = $outputfile;
}
$userInput{logger}->info("NAT policy is saved in $outputfile");

($rc,$msg)=generate_policy(\%userInput);

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

gen_nat.pl - is a utility to generate a json file which contains the number of Static NAT entries to be applied to DUT. This file must be called from config.rb 

=head1 SYNOPSIS

=over 12

=item B<gen_nat.pl>
[B<-help|-h>]
[B<-man>]
[B<-l> I<log file path>]
[B<-w> I<starting WAN IP >]
[B<-i> I<starting LAN IP >]
[B<-n> I<number of NAT policy>]
[B<-u> I<DUT logon userid>]
[B<-p> I<DUT logon password >]
[B<-g> I<DUT ip >]
[B<-o> I<output file , by default = snat_cfg.json>]
[B<-x> I<debug level>]


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

=item B<-w>

Starting WAN IP address.

=item B<-i>

Starting LAN IP address.

=item B<-u>

DUT login userid.

=item B<-p>

DUT password userid.

=item B<-g>

DUT IP gateway.

=item B<-n>

Set Number of NAT policy



=back


=head1 EXAMPLES

1. The following command is used to create 20 STATIC NAT addresses  and save entries to /tmp/test_cfg.json
    perl gen_nat.pl -u admin -p admin1 -w 10.10.10.1 -i 192.168.1.1 -n 20 -l /tmp -o test_cfg.json -g 192.168.1.1

2. The following command is used to create 20 STATIC NAT addresses  and save entries to default file /tmp/nat_cfg.json
    perl gen_nat.pl -u admin -p admin1 -g 192.168.1.1 -w 10.10.10.1 -i 192.168.1.1 -n 20 -l /tmp 


=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut
