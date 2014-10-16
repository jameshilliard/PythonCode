#!/usr/bin/perl -w
#---------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to get IP address from q1000
#perl -pi -e "s/dumpcfg//" qwest_cfg.xml
#perl -pi -e "s/@//" qwest_cfg.xml
#dos2unix qwest_cfg.xml
#perl -pi -e "s/<?xml version="1.0"?>//" qwest_cfg.xml
#<script>ruby $U_Q1000/configure.rb --dut_interface `echo ${G_PROD_IP_ETH0_0_0%/*}` --wan_ip_address static,$G_PROD_IP_ETH1_0_0:$G_PROD_GW_ETH1_0_0 --broadband_settings PTM,Multimode,121</script>
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
my $ETHER="ether";
my $COAX="hspn";

#-----<<<----------------

my %userInput = (
    "debug" => "0",
    "scriptname"=>$scriptFn,
    "logdir"=>$NOTDEFINED,
    "filename"=>$NOTDEFINED,
    "cmd"=>$NOTDEFINED,
    "dutip"=>$NOTDEFINED,
    "wanip"=>$NOTDEFINED,
    "wannm"=>"255.255.255.0",
    "wangw"=>$NOTDEFINED,
    "host"=>$NOTDEFINED,
    "domain"=>"qa.actiontec.com",
    "bbsetting"=>"PTM,Multimode,121",
    "user"=>"admin",
    "pwd"=>"QwestM0dem",
    "dhcp"=>0,
    "hwtype"=>"q1000",
    "dns"=>$NOTDEFINED,
    "interface"=>$DSL,
    "outputfile"=>$NOTDEFINED,
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
# Set up Ethernet interface
#-------------------------------------------
sub setupEther{
    my ($profFile,@junk) = @_;
    my $rc=$PASS;
    my $msg="Successfully Set up WAN interface ";
    my $log = $profFile->{logger};
    my ($temp);
    my $outputfile = $profFile->{outputfile};
    my $wanip = $profFile->{wanip};
    my $wangw = $profFile->{wangw};
    my $wannm = $profFile->{wannm};
    my $dut = $profFile->{dutip};
    my $user = $profFile->{user};
    my $pwd = $profFile->{pwd};
    my $cmd = $profFile->{cmd};
    my $host = $profFile->{host};
    my $domain = $profFile->{domain};
    my $bbsetting = $profFile->{bbsetting};
    my $dns = $profFile->{dns};
    ($dut,@junk)=split('\/',$dut);


    if ( ($profFile->{dhcp} ) ) {
	# force to use dhcp
	$wanip = $NOTDEFINED; 
    }
    
    for ( $wanip ) {
      dhcp:
	/$NOTDEFINED/ && do {
	    if ( $profFile->{hwtype} eq "q1000" ) {
		$temp= "ruby $cmd --dut_interface $dut  --wan_ip_address dhcp,$host:$domain --broadband_settings $bbsetting";
	    } else {
		$temp= "ruby $cmd --dut_interface $dut  --wan_ip_address dhcp,$host:$domain --wan_ethernet_settings disable";
	}
	    $log->info($cmd) if ($profFile->{debug} > 1 );

	    $rc=system ($temp);
	    $log->info("$temp");
	    $rc = $rc >> 8;
	    if ( $rc > 0) {
		$msg="Failed to set up DHCP IP on WAN Ethernet  interface" ;
		$rc=$FAIL;
	    } else {
		$rc=$PASS;
	    }
	    last;
	};
      static:
	if ( $wangw =~ /$NOTDEFINED/ ) {
	    $rc=$FAIL;
	    $msg="Error: WAN IP Gateway is missing";
	    last;
	}
	if ( $wanip !~ /\// ) { 
	    $wanip = $wanip."\/".$wannm;
	}
	if ( $profFile->{hwtype} eq "q1000" ) {
	    $temp="ruby $cmd --dut_interface $dut  --wan_ip_address static,$wanip:$wangw --broadband_settings $bbsetting --wan_ip_address_dns $dns ";
	} else {
	    $temp="ruby $cmd --dut_interface $dut  --wan_ip_address static,$wanip:$wangw --wan_ethernet_settings disable  --wan_ip_address_dns $dns ";
	}
	$log->info($cmd) if ($profFile->{debug} > 1 );
	$rc=system ($temp);
	$log->info("$temp");
	$rc = $rc >> 8;
	if ( $rc > 0) {
	    $msg="Failed to set up STATIC IP  on WAN DSL interface" ;
		$rc=$FAIL;
	} else {
	    $rc=$PASS;
	}
	last;
    } 

    return ($rc,$msg);
}


#-------------------------------------------
# Set up DSL interface
#-------------------------------------------
sub setupDsl{
    my ($profFile,@junk) = @_;
    my $rc=$PASS;
    my $msg="Successfully Set up WAN interface ";
    my $log = $profFile->{logger};
    my ($temp);
    my $outputfile = $profFile->{outputfile};
    my $wanip = $profFile->{wanip};
    my $wangw = $profFile->{wangw};
    my $wannm = $profFile->{wannm};
    my $dut = $profFile->{dutip};
    my $user = $profFile->{user};
    my $pwd = $profFile->{pwd};
    my $cmd = $profFile->{cmd};
    my $host = $profFile->{host};
    my $domain = $profFile->{domain};
    my $bbsetting = $profFile->{bbsetting};
    ($dut,@junk)=split('\/',$dut);


    if ( $profFile->{dhcp} ) {
	# force to use dhcp
	$wanip = $NOTDEFINED; 
    }
    
    for ( $wanip ) {
      dhcp:
	/$NOTDEFINED/ && do {
	    $temp= "ruby $cmd --dut_interface $dut  --wan_ip_address dhcp,$host:$domain --broadband_settings $bbsetting";
	    $rc=system ($temp);
	    $log->info("$temp");
	    $rc = $rc >> 8;
	    if ( $rc > 0) {
		$msg="Failed to set up DHCP IP on WAN DSL interface" ;
		$rc=$FAIL;
	    } else {
		$rc=$PASS;
	    }
	    last;
	};
      static:
	if ( $wangw =~ /$NOTDEFINED/ ) {
	    $rc=$FAIL;
	    $msg="Error: WAN IP Gateway is missing";
	    last;
	}
	if ( $wanip !~ /\// ) {
	    $wanip = $wanip."\/".$wannm;
	}
	$temp="ruby $cmd --dut_interface $dut  --wan_ip_address static,$wanip:$wangw --broadband_settings $bbsetting";
	$rc=system ($temp);
	$log->info("$temp");
	$rc = $rc >> 8;
	if ( $rc > 0) {
	    $msg="Failed to set up STATIC IP  on WAN DSL interface" ;
		$rc=$FAIL;
	} else {
	    $rc=$PASS;
	}
	last;
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
		  "w=s"=>\$userInput{wanip},
		  "n=s"=>\$userInput{wannm},
		  "g=s"=>\$userInput{wangw},
		  "b=s"=>\$userInput{bbsetting},
		  "o=s"=>\$userInput{outputfile},
		  "u=s"=>\$userInput{user},
		  "p=s"=>\$userInput{pwd},
		  "dhcp"=>\$userInput{dhcp},
		  "i=s"=>\$userInput{interface},
		  "c=s"=>\$userInput{cmd},
		  "s=s"=>\$userInput{dns},
		  "t=s"=>\$userInput{hwtype},
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

if ( $userInput{cmd} =~ /$NOTDEFINED/ ) {
    $userInput{logger}->info("Error: Command to configure DUT is missing ");
    exit (1);
}  

if ( $userInput{dns} =~ /$NOTDEFINED/ ) {
    $userInput{logger}->info("DNS ( 10.10.10.1,4.2.2.2) was used as default");
    $userInput{dns} = "10.10.10.1,4.2.2.2";
}  

my $outputfile=$userInput{outputfile},;
if ( $outputfile =~ /$NOTDEFINED/ ) {
    $temp = "setupWanIf";
    $outputfile = $dir."/$temp\.log";
    $userInput{outputfile} = $outputfile;
} else {
    $outputfile = $dir."/".$outputfile;
    $userInput{outputfile} = $outputfile;
}
#$userInput{logger}->info("Setup WAN interface Log  is saved in $outputfile");

$userInput{interface} = lc $userInput{interface} ;

for ( $userInput{interface} ) {
    /$DSL\b/ && do {
	($rc,$msg)=setupDsl(\%userInput);
	last;
    };
    /$ETHER\b/ && do {
	($rc,$msg)=setupEther(\%userInput);
	last;
    };
    /$COAX\b/ && do {
	($rc,$msg)=setupCoax(\%userInput);
	last;
    };
    $rc=$FAIL;
    $msg="Interface $userInput{interface} is not recognized ";
    last;
}




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

setupWanIf.pl - is a utility to set up WAN Q1000 interface 

=head1 SYNOPSIS

=over 12

=item B<setupWanIf.pl>
[B<-help|-h>]
[B<-man>]
[B<-l> I<log file path>]
[B<-w> I<WANIP/NetMask>]
[B<-g> I<WANIP gateway>]
[B<-d> I<DUT IP >]
[B<-b> I<broadband setting defined in config.rb>]
[B<-i> I<Interface:dsl|ether|coax>]
[B<-u> I<DUT logon userid>]
[B<-p> I<DUT logon password >]
[B<-g> I<DUT ip >]
[B<-x> I<debug level>]
[B<-c> I<utility to config q1000>]
[B<dhcp> I<Force DHCP to be used>]
[B<-s> I<dns for static IP>]
[B<-t> I<Command is used for hardware type >]

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

=item B<-w>

WAN IP address. Syntax ( IP/Netmask(16,24,etc) or IP with default=255.255.255.0 ). If IP address is omitted, dhcp will be used

=item B<-g>

WAN IP gateway address.

=item B<-d>

DUT IP address.

=item B<-u>

DUT login userid.

=item B<-p>

DUT password userid.

=item B<-b>

Broadcast Setting parameter as defined from config.rb

=item B<-i>

Select WAN Interface dsl|ether|coax. By default it was set to DSL

=item B<-y>

Force DHCP to be used. By default it was off 

=item B<-s>

Set DNS field  to be used for static IP. By default, it was set to 10.10.10.1,4.2.2.2

=item B<-t>

Set hardware type to different one. Default is was set q1000


=back

=head1 EXAMPLES

1. The following command is used to set up DSL through DHCP and save output log to /tmp/ directory
    perl setupWanIf.pl  -c "../q1000/configure.rb" -d 192.168.0.1 -l /tmp/ 
2. The following command is used to set up DSL through static IP and save output log to  /tmp/ directory
    perl setupWanIf.pl  -c "../q1000/configure.rb" -d 192.168.0.1  -w 172.18.14.32/24 -g 172.18.14.1  -l /tmp 
   

=head1 AUTHOR

Please report bugs using L<http://budz/>

JoeNguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut
