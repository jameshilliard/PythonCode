#!/usr/bin/perl -w
#---------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to upload Q1000 firmware 

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
use LWP::UserAgent;	 
use URI;
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
    "cmd"=>$NOTDEFINED,
    "outputfile"=>$NOTDEFINED,
    "dutip"=>$NOTDEFINED,
    "user"=>"admin",
    "password"=>"admin",
    "port"=>80,
    "https"=>0,
    "screenoff"=>0,
    "logoff"=>0,
    "logger"=>"",
    "action"=>{ "rmtgui"=>{ "enable"=>{"data"=>1,"key"=>"serCtlHttp"},"user"=>{"data"=>"admin","key"=>"adminUserName"},
			    ,"pwd"=>{"data"=>"admin","key"=>"adminPassword"},"tmo"=>{"data"=>"0","key"=>"remGuiTimeout"},
			    "port"=>{"data"=>443,"key"=>"remGuiPort"},"reject"=>{"data"=>0,"key"=>"nothankyou"},
			    "callback"=>$NOFUNCTION,"url"=>"advancedsetup_remotegui.cgi","desc"=>"Remote GUI"},
		"rstdefault"=>{ 
		    "reject"=>{"data"=>1,"key"=>"noThankyou"},
		    "callback"=>$NOFUNCTION,"url"=>"restoreinfo.cgi","desc"=>"Reset to Default "},
    },
    "commands"=>[],
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
# Get name 
#-------------------------------------------
sub parseData{
    my ( $profFile, $junk) = @_;
    my $rc = $PASS;
    my $msg ="Successfully post Firmware";
    my $log = $profFile->{logger};
    my $dut = $profFile->{dutip};
    my $filename = $profFile->{filename};
    my $ua = LWP::UserAgent->new;
    my $basename= getBaseName($filename);
    my $temp;
    my $user=$profFile->{user};;
    my $pwd=$profFile->{password};
    my $output = $profFile->{outputfile};
    my $lim = $#{$profFile->{commands}};
    my $count;
    my @buff;
    my ($line,$found,$index,$bi,$bilim,$action,$key,$value);
    my $string="";
    my $keyword;
    for ($index=0;$index<=$lim;$index++){
	$line = $profFile->{commands}[$index];
	foreach $action ( sort keys %{$profFile->{action}}) {
	    if ( $line =~ /$action\b/ ) {
		$found =1;
		$string=$action;
		#split data
		@buff=split(":",$line);		
		$bilim=$#buff;
		for ( $bi=0;$bi<= $bilim;$bi++) {
		    next if ( $buff[$bi]=~ /($action|callback|url|desc)/);
		    $log->info("\[$bi\]=$buff[$bi]") if ( $profFile->{debug} > 1) ;;
		    ($key,$value)=split("=",$buff[$bi]);
		    $key= lc $key;
		    if ( defined $profFile->{action}{$action}{$key}) {
			$profFile->{action}{$action}{$key}{data}=$value;
			$keyword=$profFile->{action}{$action}{$key}{key};
			$log->info(" keypair\[$keyword=$value\]") if ( $profFile->{debug} > 1) ;;
		    } else {
			$string = "Error: $key is not recognized";
			$log->info($string);
			$rc=$FAIL;
			last;
		    }
		}
		last;
	    }
	}
	if ( ! $found ) {
	    return($FAIL,$string);
	}
    }
    return ($rc,$string);
}



#************************************************************
# Upload FW software 
#************************************************************
sub postGUI {
    my ( $profFile, $junk) = @_;
    my $rc = $PASS;
    my $msg ="Successfully post Firmware";
    my $log = $profFile->{logger};
    my $dut = $profFile->{dutip};
    my $filename = $profFile->{filename};
    my $ua = LWP::UserAgent->new;
    my $basename= getBaseName($filename);
    my $temp;
    my $user=$profFile->{user};;
    my $pwd=$profFile->{password};
    my $output = $profFile->{outputfile};
    my $port = $profFile->{port};
    my $disable = $profFile->{disable};
    my $lim = $#{$profFile->{commands}};
    my $count;
    my @buff=();
    my $request; 
    my $url="http://".$dut."/";
    if ($profFile->{https} ) {
	$url="https://".$dut.":$port/";
    }
    my $response;
    my ($link,$keyword,$action,$key,$value,$ptr);
    
    $ua->timeout(10);
    $ua->env_proxy;
    

    ($rc,$action)=parseData($profFile);
    if ( $rc == $FAIL) { return ($rc,$action); }
    $log->info("action=$action");

    $ptr=\%{$profFile->{action}{$action}};
    $link = $url;
    $request = HTTP::Request->new(GET=>$link);
    $request->authorization_basic($user,$pwd);
    $response = $ua->request($request);
    $msg=$response->content();
    $log->info( "$user:$pwd\n$msg");
    if ($response->is_success) {
	$msg="Link $link is legal ---".$response->decoded_content;
#	$log->info( "$msg");
    } else { 
	$rc=$FAIL;
	$msg="Error:Link $link is not found--".$response->status_line;  
#	$log->info( "$msg");
	return($rc,$msg);
    }  
    $temp=$ptr->{url};
    if ( $profFile->{https} ) {
	$link=  URI->new(  "https://$user:$pwd\@$dut/$temp");    
	if ( $port != 80 ) {
	    $link=  URI->new(  "https://$user:$pwd\@$dut:$port/$temp");    
	}
    } else {
	$link=  URI->new(  "http://$user:$pwd\@$dut:$port/$temp");    
    }
    foreach $key ( sort keys %{$ptr} ) {

	next if ( $key =~ /($action|callback|url|desc)/);
	$value = $ptr->{$key}{data};
	$keyword = $ptr->{$key}{key};
	push (@buff,$keyword);
	push (@buff,$value);
    }
    $log->info( "URI BUFFER=@buff\n") if ( $profFile->{debug} > 1) ;

    $link->query_form(@buff);

    $ua->credentials(
	"$dut:$port",
	"basic",
   	"$user"=>"$pwd"
	);
    $response= $ua->get("$link");
        $log->info( "LINK=$link\n") if ( $profFile->{debug} > 1) ;
    if ($response->is_success) {
	$msg="Successfully post $action --";
	open ( OUTPUT,">> $output") or die " could not write to $output";
	print OUTPUT $response->decoded_content;
	close OUTPUT;
#	$log->info( "$msg");
    } else { 
	$rc=$FAIL;
	$msg="Error:post $action failed--".$response->status_line;  
	return($rc,$msg);
#	$log->info( "$msg");
    }

    return($rc,$msg);
}
#************************************************************
# Main Routine
#************************************************************
MAIN:
my $rc =0;
my $temp;
my $msg;
my ($key,$value,$count);
my $logdir;
my $globalRc = 0;
my ($option_h,$option_man,$option_p,$ptr,$action)=0;
my $junk =0;
$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man, 
		  "l=s"=>\$userInput{logdir},
		  "d=s"=>\$userInput{dutip},
		  "f=s"=>\$userInput{filename},
		  "u=s"=>\$userInput{user},
		  "p=s"=>\$userInput{password},
		  "o=s"=>\$userInput{outputfile},
		  "s"=>\$userInput{https},
		  "i=s"=>\$userInput{port},
		  "n"=>\$option_p,
		  "v=s"=>sub { push (@{$userInput{commands}},$_[1]); } 
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
if ($option_p) {
    print "**********************   GUI OPTION *********************************** \n";
    print " Note that all options do not need to be entered except action key, any missed option will be set by default value as shown\n\n";
    $ptr=\%{$userInput{action}};
    $count=0;
    foreach $action ( keys %{$ptr}) {
	$msg=$ptr->{$action}{desc}."= action=$action";
	foreach $key ( keys %{$ptr->{$action}}) {
	    next if ( $key =~ /(url|callback|desc)/ );
	    $value = $ptr->{$action}{$key}{data};
	    $msg .= ":$key=$value";
	}
	print ("\[$count\]$msg\n");
	$count++;
    }
    exit 0;
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

my $outputfile=$userInput{outputfile},;
if ( $outputfile =~ /$NOTDEFINED/ ) {
    $temp = "cfggui_html_response";
    $outputfile = $dir."/$temp\.log";
    $userInput{outputfile} = $outputfile;
} else {
    $outputfile = $dir."/".$outputfile;
    $userInput{outputfile} = $outputfile;
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
my $limit = $#{$userInput{commands}};
my $line;
if ($limit > -1  ) {
    $junk =" ";
    foreach $line (  @{$userInput{commands}}) { 
	$junk .="-v $line "; 
    }
    $junk = $userInput{scriptname}.".pl -l ".$userInput{logdir}.$junk;
    $userInput{logger}->info("\n Executing command=$junk\n\n");
}

($rc,$msg)=postGUI(\%userInput);


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

cfgGui.pl - is a utility to post paramters to  Q1000 dut

=head1 SYNOPSIS

=over 12

=item B<uploadfw.pl>
[B<-help|-h>]
[B<-man>]
[B<-l> I<log file path>]
[B<-d> I<DUT IP >]
[B<-u> I<DUT logon userid>]
[B<-p> I<DUT logon password>]
[B<-o> I<Output file >]
[B<-n> I<List all GUI options>]
[B<-i> I<specify the port number>]
[B<-s> I<specify to use https instead of http>]
[B<-x> I<debug level>]
[B<-v> I<parameters>]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-l >

Redirect stdout to the /path/cfggui_html_response.log

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

=item B<-o>

Outputfile Default is cfggui_html_response.log


=item B<-f>

Filename to contain xml entry

=item B<-n>

List all GUI options

=item B<-v>

Parameters



=back

=head1 EXAMPLES

1. The following command is used to set up rmtgui to dut 

    perl cfgGui.pl -d 192.168.0.1 -l /tmp/ -u admin -p admin -v "action=rmtgui:enable=1:user=admin:pwd=aloha" 

1. The following command is used to set up rmtgui to dut with https
perl cfgGui.pl -s -i 443 -d 10.10.10.254 -l /tmp/ -u admin -p admin1 -v "action=rmtgui:enable=1:user=admin:pwd=aloha"

=head1 AUTHOR

Please report bugs using L<http://budz/>

JoeNguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut
