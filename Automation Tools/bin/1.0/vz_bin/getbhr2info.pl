#!/usr/bin/perl -w
#---------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to Get BHR2 info throught telnet
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
#use XML::Simple;
use Data::Dumper;
my $PASS=1;
my $FAIL=0;
my $NOTDIR="notdirectory";
my $NOTDEFINED="notdefined:";
my $DEFAULT_CMD="ifconfig";
my $DIRNOTDEFINED="DIRECTORY_notdefined:";
my $NOSUCH="No such file or directory";
my @junk = split( /\//, $0);
@junk = split( '\.',$junk[$#junk]);
my $scriptFn = $junk[0];
my %userInput = ( "debug"=>0,
		  "logdir"=>$NOTDEFINED,
		  "srcfile"=>$NOTDEFINED,		  
		  "dstfile"=>$NOTDEFINED,		  
		  "pwdfile"=>$NOTDEFINED,		  
		  "outputfile"=>$NOTDEFINED,
		  "report"=>0,
		  "logger"=>$NOTDEFINED,
		  "actiontype"=>$DEFAULT_CMD,
		  "srcdir"=>{ },
		  "dstdir"=>{ },
		  "negative"=>0,
		  "screenOff"=> 0,
		  "logOff"=> 0,
		  "scriptname"=>$scriptFn,
		  "action"=>{
		      $DEFAULT_CMD=>\&getIfconfig,
		  },
		  "ifconfig"=>[],
		  "commands"=>[],
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
#    $profFile->{logger}->info("--> Log initialized <--");
    return($rc,$msg);

}

#************************************************************
# Filter all unwanted line from ls -al
#************************************************************
sub filterArray{
    my ($profFile,$bufPtr)=@_;
    my $rc =$PASS;
    my $msg = "Successfully filter the buffered";
    my @lBuff=();
    my $index;
    my $line;
    my $lim = $#{$bufPtr};
    for ( $index =0;$index <= $lim; $index++) {
	$line = $bufPtr->[$index];
	next if ( $line =~ /^\s$/ ) ;
	next if ( $line =~ /^#.*$/ ) ;
	next if ( $line =~ /$NOSUCH/ ) ;
	next if ( $line =~ /preCIS/ ) ;
	next if ( $line =~ /postCIS/ ) ;
	push (@lBuff,$line);
    }
    @{$bufPtr}=();
    $lim = $#lBuff;
    for ( $index =0;$index <= $lim; $index++) {
	$bufPtr->[$index] = $lBuff[$index];
    }
    return ($rc,$msg);
}

#************************************************************

#************************************************************

sub getBaseName {
    my ($path,$junk)=@_;
    my @temp = split("/",$path);
    $junk = $temp[$#temp];
    return $junk;
}
#************************************************************
#Device ath0 (0x120634600) -
#    type=86(Wireless 802.11g Access Point)state=running
#    changed=0 is_sync=1 has_ip=0 metric=4 MTU=1500 max_mss=1460 MAC=00:1f:90:d9:31:d4
#    depend_on_list=wifi0(0x1206375e0)
#    next=ppp0(0x120634840)

#Device ppp0 (0x120634840) -
#    type=29(PPPoE)state=disabled
#    changed=0 is_sync=0 has_ip=1 metric=1 MTU=1492
#    depend_on_list=eth1(0x120636990)
#    next=ppp1(0x120634b70)
#    ip=0.0.0.0,netmask=0.0.0.0
#
#************************************************************

sub initEntry {
    my ($ptr) =$_;
    $ptr->{type}=$NOTDEFINED;
    $ptr->{changed}=$NOTDEFINED;
    $ptr->{depend_on_list}=$NOTDEFINED;
    $ptr->{next}=$NOTDEFINED;
    $ptr->{ip}=$NOTDEFINED;
    return ($PASS);
}
#-----------------------------------------------------
# This routine is used to parse the net ifconfig file
#----------------------------------------------------
sub parseIfconfig{
    my ($profFile,$junk)=@_;
    my $filename = $profFile->{srcfile};
    my $ptrDevice= $profFile->{ifconfig};
    my ($key,$count,$line,$start,@junk);
    my $log=$profFile->{logger};
    my $index = 0;
    $log->info("Filename = $filename" ) if ( $profFile->{debug} > 3 );
    my $rc = open(INPUT,$filename);
    my @buff=<INPUT>;
    close INPUT;
    
    if ( $rc == 0 ) {
	return($FAIL,"Error Could no open file $filename");
    }
    $start = 0;
    $index = 0;
    for ( $count=0 ; $count <= $#buff; $count ++ ) {
	$line = $buff[$count];
	#check for keyword device
	if ( $start == 0 ) {
	    if ( $line =~ /^Device\b/ ) {
		$start = 1;
		$log->info("($index ) $start -- $line ") if ( $profFile->{debug} > 5 );
		$ptrDevice->[$index]={};
		$ptrDevice->[$index]{device}="$line";
		$rc = initEntry ( \%{$ptrDevice->[$count]} );
	    }
	    $log->info("$count:$line" ) if ( $profFile->{debug} > 5 );
	    next;
	}
#	$log->info("## ($index)  $count:$line" ) if ( $profFile->{debug} > 5 );
	#check for blank line"
	if ( $line =~ /^\s*$/ ) {
	    if ( $start >= 1 ) {
		$start = 0;
		$index ++;
	    }
	    $log->info("($index)  $start -- $line" ) if ( $profFile->{debug} > 4 );
	    next;
	}
	#fill up data
	if ( $start == 1 ) {
	    ($key,@junk)=split("=",$line);
	    $key =~ s/\s//g;
#	    $line =~ s/\./\\./g;
	    $ptrDevice->[$index]{$key}=$line;    
	    $log->info("($index) (key=$key)-- $line" ) if ( $profFile->{debug} > 3 );
	    next;
	}
    }
    $key = Dumper($ptrDevice);
    $log->info($key) if ( $profFile->{debug} > 2 );



    return ($PASS,"Successfully parse $filename");
}

#-----------------------------------------------------
# This routine is used to parse the net ifconfig file
#----------------------------------------------------
sub getIpMac{
    my ($profFile,$ip)=@_;
    my $log = $profFile->{logger};
    my $filename = $profFile->{srcfile};
    my $ptrDevice= $profFile->{ifconfig};
    my ($key,$count,$line,$start,@junk,$t1,$t2,@buff);
    for ( $count=0 ; $count <= $#{$ptrDevice}; $count ++ ) {
	next if ( not defined  $ptrDevice->[$count]{ip});
	if( $ptrDevice->[$count]{ip} =~ /$ip/ ) {
	    #changed=0 is_sync=1 has_ip=0 metric=4 MTU=1500 max_mss=1460 MAC=00:1f:90:d9:31:d4
	    @junk = split ('\s',$ptrDevice->[$count]{changed} );
	    for ( $t1=0; $t1 <= $#junk; $t1++) {
#		$line =  $junk[$t1];
#		$log->info( "===> ($t1) data = $line");
		if ( $junk[$t1]=~ /MAC/ ) {
		    @buff=split("=",$junk[$t1]);
		    return ($PASS,$buff[1]);
		}
	    }
	}
    }
    return ($FAIL,"Could not find MAC address for IP ($ip)");
}

sub getIfconfig {
    my ($profFile,$typeaction)=@_;
    my $filename = $profFile->{srcfile};
    my ($count,$key,$data,$rc,$msg,$line,$temp);
    my $log = $profFile->{logger};
    $key = $NOTDEFINED;
    $data = $NOTDEFINED;
    ($rc,$msg)=parseIfconfig($profFile,$typeaction);
    if ( $rc == $FAIL ) { return ($rc,$msg); }
    for ( $count =0; $count <= $#{$profFile->{commands}} ;$count++) {
	$line=$profFile->{commands}[$count];
	($key,$temp)=split ("=",$line);
	# $log->info( "$count = $line ");
	$key = lc $key;
	if ( $key =~ /ip/ ) {
	    $temp=~ s/\n//g;
	    ($data,$temp)= split ('\/',$temp);
	    ($rc,$msg)=getIpMac($profFile,$data);
	    return($rc,$msg);
	}
    }
   
    return ($FAIL,"Could not find key=$key and data=$data");
}


#************************************************************
# Main Routine
#checkpermfile.pl -n -s $G_CURRENTLOG/orgdirbackup.txt -d $G_CURRENTLOG/testdirbackup.txt -l $G_CURRENTLOG 
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
my $count;
my $found;
$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man,
		  "s=s"=>\$userInput{srcfile},		  
		  "r"=>\$userInput{report},		  
		  "l=s"=>\$userInput{logdir},		  
		  "o=s"=>\$userInput{outputfile},		  
		  "t=s"=>\$userInput{actiontype},		  
		  "n"=>\$userInput{negative},		  
		  "v=s"=>sub { if ( exists $userInput{commands}[0] ) { push (@{$userInput{commands}},$_[1]); } else {$userInput{commands}[0]=$_[1]; } } ,
		  );
#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);
my $dir = $userInput{logdir};
if ( $dir =~ $NOTDEFINED ) {
    $dir=`pwd`;
    $dir=~ s/\n//;    $userInput{logdir} = $dir;
    printf ( "DIR = $dir \n");
}

if (!(-d $dir) ) {
    $msg = "Error: Directory $dir is not found"; 
    $userInput{logger}->info($msg);
    pod2usage(1);
    exit 1;
}

($rc,$msg) = initLogger(\%userInput, 0);
if ( $rc != 1) {
    printf ("RC$rc $msg\n");
    exit 1;
} 
my $srcfn = $userInput{srcfile};
my $dstfn = $userInput{dstfile};


my $outputfile = $userInput{outputfile};

if  ($srcfn =~ /$NOTDEFINED/ )  {
   $userInput{logger}->info( "Error = please fill in the missing operand = source file ($srcfn) ");
    pod2usage(1);
    exit 1;
}
if ( !(-e $srcfn) ) {
    $msg = "Error: Source file $srcfn is not found"; 
    $userInput{logger}->info($msg);
    pod2usage(1);
    exit 1;
}
if ($outputfile =~ /$NOTDEFINED/ )  {
    $count =0;
    $found =1;
    while ( $found ) {
	$outputfile = $dir."/".$userInput{scriptname}."_diffresult_$count.txt";
	if ( !(-e $outputfile) ) {
     
	    $found =0;
	    last;
	}
	$count ++;
    }
    $userInput{outputfile} =$outputfile ;
}
my $typeaction=lc ( $userInput{actiontype});
$userInput{logger}->info("ACTION=$typeaction") if ( $userInput{debug} > 1 ) ;
if ( !defined( $userInput{action} {$typeaction} ) ) {
    $msg = "Error:action type = $userInput{actiontype} is not supported";
    $userInput{logger}->info($msg);
    pod2usage(1);
    exit 1;
}
$limit = @{$userInput{commands}};
my $line;
if ( $userInput{debug} > 1 )  { if ($limit != 0 ) {foreach $line (  @{$userInput{commands}}) { print "$line \n"; } };
}
($rc,$msg)=$userInput{action}{$typeaction}(\%userInput,$typeaction);
$userInput{logger}->info($msg) if ( $userInput{debug} > 1 ) ;
print $msg;
if ($userInput{report}) {
    $msg=`cat $outputfile`;
    $userInput{logger}->info($msg);
}
exit 0 if ($rc == $PASS ) ;
exit 1;
1;
__END__


=head1 NAME



=head1 SYNOPSIS

=over

=item B<getbhr2info.pl>
[B<-help|-h>]
[B<-man>]
[B<-s> I<source file which contain output obtained from BHR2 thru telnet >]
[B<-d> I<destination file >]
[B<-l> I<log file directory>]
[B<-n> I<negative check. If data are identical then flag as failed>]
[B<-o> I<optional result outputfile>]
[B<-t> I<action type>]
[B<-x> I<set debug>]

=back

=head1 OPTIONS AND ARGUMENTS

=over

=item B<-n>

Negative check to make sure that permission file are different. Flag the comparison as failed if data are identical

=item B<-s>

Source file which is output obtained from telnet


=item B<-l >

Redirect stdout to the /path/getbhr2info

=item B<-o >

Send result to a specified result file. Default is checkpermfile_diff_result.txt

=item B<-t >

Type for action  ( default="ifconfig" )

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-x>

Set debug to different level . ( more debug messages with higher number)

=item B<-r>

Display the result (optional) 

=back


=head1 EXAMPLES

=over

1. The following command 
and all logs to /tmp/checkreport_xx.log
    checkreport.pl -n -s orgdirbackup.txt -d testdirbackup.txt -l /tmp -p etc_password.txt 
2. The following command check the  permission of 2 files which contain the "ls -alt <dir>/<file>" and store in junk/yourfile_diff.txt and 
all logs to /tmp/checkreport_xx.log
    getbhr2info.pl  -s bhr2info.txt  -t ifconfig   -l /tmp -o junk123.txt -v IP=10.10.10.254

=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>jnguyen@hytrust.comE<gt>

=cut
