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

#-----<<<----------------

my %userInput = (
    "debug" => "0",
    "scriptname"=>$scriptFn,
    "ip"=>$NOTDEFINED,
    "step"=>1,
    "mask"=>$NOTDEFINED,
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
		  "i=s"=>\$userInput{ip},
		  "s=s"=>\$userInput{step},
		  "v=s"=>sub { if ( exists $commands[0] ) { push (@commands,$_[1]); } else {$commands[0]=$_[1]; } } ,
		  );
#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);
my $ip=ipIncr(\%userInput,$userInput{ip}, $userInput{step});
print $ip;
exit (0);
1;
__END__

=head1 NAME

incrip.pl - is a utility to increase ip address

=head1 SYNOPSIS

=over 12

=item B<incrip.pl>
[B<-help|-h>]
[B<-man>]
[B<-i> I<Source IP >]
[B<-i> I<Incremental step >]
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

=item B<-i>

Source IP address.

=item B<-s>

Incremental step. By default it was set to 1 and IP address will be incremented by 1.

=back


=head1 EXAMPLES

1. The following command is used to increase ip
    perl incrip.pl -s admin 



=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>



=cut
