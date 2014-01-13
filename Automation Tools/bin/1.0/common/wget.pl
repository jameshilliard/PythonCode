#!/usr/bin/perl -w
#---------------------------------
#Name: Rubingsheng(Robin)
#Description: 
# This script is used to run wget and paser results
#
#--------------------------------

use strict;
use warnings;
use Pod::Usage;
use Getopt::Long;
use FileHandle;

my $FAIL=0;
my $PASS=1;

#-----------------------------------------------------------
# This routine is used to execute wget and paser result
#-----------------------------------------------------------
sub verifyTarget {
	my ($userInput,@jj) = @_;
	my $rc = $FAIL;
	my $URL = $userInput->{URL};
	my $msg = " $URL is under test";
	my $cmd = `wget $URL 1>&2 2>./temp`;
	$cmd = `cat ./temp`;
	printf " \n $cmd \n";
	@jj = split ("\n",$cmd);
	my $limit= $#jj;
    my $found = 0;
    my $match ="Keyword Filter";
    foreach ( my $i=0 ; $i <= $limit; $i++) {
	if ( $jj[$i] =~ m/$match/ ) {
	    $found = 1;
	    last;
	}  
    }


    
  SWITCH_VERIFYTARGET: for ($found ) {
      /0/ && do {
	  if ( !$userInput->{negative} ) {
	      $rc = $PASS;
	      $msg = "Positive test passed -- $URL is accesable";
	  } else {
	      $rc = $FAIL;
	      $msg = "Negative test failed -- $URL is accesable";
	  } 
	  last;
      };
      /1/ && do {
	  if ( !$userInput->{negative} ) {
	      $rc = $FAIL;
	      $msg = "Positive test failed -- $URL is blocked";
	  } else {
	      $rc = $PASS;
	      $msg = "Negative test passed -- $URL is blocked";

	  }
	  last;
      };
      die "verifyTarget: unrecognize error code $found \n"; 
  }
    return($rc,$msg);    
}
#------------------------------------------------------------
# main routine
#------------------------------------------------------------
MAIN:
    my ($rc,$msg);
my %userInput = ( 
       "URL"=>"www.actiontec.com",
       "negative"=>0,
       "debug"=>0,
);
my @commands = ();
my $logdir;
my ($option_h,$option_man);

$rc = GetOptions( "x"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man, 
		  "d=s"=>\$userInput{URL},
		  "n"=>\$userInput{negative},
		  "l=s"=>sub {  $logdir = `cd $_[1];pwd`;$logdir=~ s/\n//; $userInput{logdir} = $logdir },
		  "v=s"=>sub { if ( exists $commands[0] ) { push (@commands,$_[1]); } else {$commands[0]=$_[1]; } } ,
		  );

#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);

($rc,$msg) = verifyTarget(\%userInput,0);
printf ("\n $msg \n");
if ( $rc != $PASS ) {
    exit 1;
}
exit 0;
1;
__END__
=head1 NAME

wget.pl - execute wget and interpret PASS/FAIL

=head1 SYNOPSIS

=over 12

=item B<ping.pl>
[B<-help|-h>]
[B<-man>]
[B<-d > I<URL address>]
[B<-l> I<log file path>]
[B<-v> I<cli command> [-v I<cli command>] ...]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-d>

Specify a URL address ( default = "www.actiontec.com")

=item B<-l >

Redirect stdout to the /path/clicfg.log if user uses "-v" parameters or "cli text file".log   

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.


=head1 DESCRIPTION

B<wget.pl> will allow user to execute wget


=head1 EXAMPLES

1. The following command is used to get www.google.cn
         perl wget.pl -d www.google.cn

=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Rubingsheng(Robin)  E<lt>bru@actiontec.comE<gt>

=cut