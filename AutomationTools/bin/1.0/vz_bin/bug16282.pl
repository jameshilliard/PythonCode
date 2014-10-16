#!/usr/bin/perl -w
#---------------------------------
# Name: Hugo
# Description: 
#
#--------------------------------
use strict;
use warnings;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use Net::Ping;

#----------------------------------
#
#----------------------------------
MAIN:
my @junk;
my $rc;
my $option_h;
my $option_man;
my $tsIp;
my $pktcount;
my $temp;
my $numEx = 1;
my $numLoop = 0;
my %userInput = (
           "tsIp" => "0.0.0.0",
           "pktcount" => 2,
     );

$rc = GetOptions( "help|h" => \$option_h,
            "man" => \$option_man,
            "d=s" => \$userInput {tsIp},
      );

pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man );
@junk = split ("/", $userInput{tsIp});
$userInput{tsIp} = $junk[0];

my $cmd = " ping $userInput{tsIp} -c $userInput{pktcount} ";
$a = Net::Ping->new("icmp");
while ( $numLoop < 3600 ) {
#while ( $numLoop < 5 ) {
   if ($a->ping($userInput{tsIp}, 2)) {   
     print "Excute ($numLoop) = $cmd \n";
     sleep 2;
     $numLoop++;
   }   
   else {  
     print " Excute = $cmd - Unreachable \n";
     $numEx++;   
   }
   if ( $numEx == 5 ) {
     print "DUT looks unreachable\n";
     print "Please check if DUT catches any crash refer to bug16282 \n";
     exit 1;
   }

}

__END__

=head1 NAME

=over

=item bug16282.pl is used to verify DUT still can be reachable during a piece of time

=item For more details, Please search bug16282 in sirid

=item http://www.sirid.com

=back

=head1 SYNOPSIS

=over

=item B<bug16282.pl>
[B<-help|-h>]
[B<-man>]
[B<-d> I<target address>]

=back

=head1 OPTIONS AND ARGUMENTS

=over

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-d>

Specify a Terminal Server ip address

=back

=head1 AUTHOR

=over

Please report bugs using L<http://budz/> 

Hugo E<lt>xgong@actiontec.comE<gt>

=back

=cut

