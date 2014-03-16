#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
# verifyiperf.pl
# Name: Hugo
# Contact: shqa@actiontec.com
# Description: This perl script is to check the interface information gotten by 
#              ifconfig shell command.
# Options:
#
# Copyright @ Actiontec Ltd.
#-------------------------------------------------------------------------------

use strict;
use warnings;
use diagnostics;
use Getopt::Long;
use FileHandle;
use Data::Dumper;

# Local variables
my $rc;
my $iCount;
my @junk;
my @LogBuffer;
my $globalRc;
my $temp;
my $key;
my $NOFUNCTION="NOTDEFINED";
my $LOGDIR=`pwd`;
my $usage ="Usage: verifyiperf.pl -n(negative test) -f <Log file with full path> -ptype <udp/tcp>\n";
my %userInput = ( "filename"=>$NOFUNCTION,
                  "negative"=>0,
		  "proto_type"=>'tcp',
    );
		          
my @expectedResult = ("inet addr", "inet6 addr");

# ---------------------- Begin ----------------------------- 
# Get the option
$rc = GetOptions(  
          "h|help" => \$userInput{help},
	  "f=s"=>\$userInput{filename}, 
	  "n"=>\$userInput{negative},
	  "ptype=s"=>\$userInput{proto_type}
	   );

if ( $userInput{help} )
{
  print "$usage\n\n";
  exit 0;
}		            
# Check the log file exists.
if ( !( -e $userInput{"filename"}) )
{
  $temp=$userInput{"filename"};
  printf ( "Error: FILENAME ($temp) is not found\n");
  exit 1;
}
# ------------------------ End -----------------------------
sub check_tcp {
    for($iCount=0;$iCount <= $#LogBuffer; $iCount ++)
    {
    
      # negative test, 0 bandwidth is expected
      if (( $LogBuffer[$iCount] =~ m/Bytes\b/ ) && ( $userInput{"negative"} == 1 ))
      {
        if ( $LogBuffer[$iCount] =~ m/0\.00/ )
        {
    	printf ("TCP: Negative test Pass \n");
            close LOGFILE;
            exit 0;
        }
        else
        {
    	printf ("TCP: Negative test fail \n");
            close LOGFILE;
            exit 1;
        }
      }
    
      # non-negative test 
      if (( $LogBuffer[$iCount] =~ m/Bytes\b/ ) && ( $userInput{"negative"} == 0 ))
      {
        if ( $LogBuffer[$iCount] =~ m/0\.00/ )
        {
    	printf ("TCP: Fail \n");
            close LOGFILE;
            exit 1;
        }
        else
        {
    	printf ("TCP: Pass \n");
            close LOGFILE;
            exit 0;
        }
      }
    
    }
}

sub check_udp {
    for($iCount=0;$iCount <= $#LogBuffer; $iCount ++)
    {
      # negative test, WARNING is expected
      if ( $LogBuffer[$iCount] =~ m/WARNING\b/ )
      {
	    if ( $userInput{"negative"} == 1 )
	    {
      	      printf ("UDP: Negative test Pass \n");
      	      close LOGFILE;
      	      exit 0;
      	    }
      	    else
      	    {
      	      printf ("UDP: Test fail \n");
      	      close LOGFILE;
      	      exit 1;
      	    }
      }
    }

    if ( $userInput{"negative"} == 1 )
    {
        # negative test 
	printf ("UDP: There are traffic, Negative test fail \n");
	close LOGFILE;
	exit 1;
    }
    else
    {
	# non-negative test 
	printf ("UDP: Test Pass \n");
	close LOGFILE;
	exit 0;
    }
      
}

# ---------------------- Begin -----------------------------
# Parsing the log file
$rc = open(LOGFILE, $userInput{"filename"});
if ( $rc != 1 ) 
{
  print("\nCould not read the Log file\n");
  exit 1;
}

@LogBuffer = <LOGFILE>;
print("\nLog file content:\n");
print(@LogBuffer);

#Travel this array and find out the keyword.
SWITCH: {
    $userInput{"proto_type"} eq 'tcp' && do { check_tcp; last SWITCH;};
    $userInput{"proto_type"} eq 'udp' && do { check_udp; last SWITCH;};
}


close LOGFILE;
printf ("End Fail \n");
exit 1;

# ------------------------ End -----------------------------

__END__


