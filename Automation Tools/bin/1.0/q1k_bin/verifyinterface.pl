#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
# verifyinterface.pl
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
my $usage ="Usage: verifyinterface.pl -n(negative test) -v6 <ipv6 mode> -f <Log file with full path> -a <expected ipaddress>\n";
my %userInput = ( "filename"=>$NOFUNCTION,
                  "negative"=>0,
                  "ipv6"=>0,
		  "expip"=>$NOFUNCTION,
    );
		          
my @expectedResult = ("inet addr", "inet6 addr");

# ---------------------- Begin ----------------------------- 
# Get the option
$rc = GetOptions( 
	  "h|help" => \$userInput{help},
	  "f=s"=>\$userInput{filename}, 
	  "n"=>\$userInput{negative},
	  "v6"=>\$userInput{ipv6},
	   );
		            
# Check the log file exists.
if ( $userInput{help} )
{
  print "$usage\n\n";
  exit 0;
}
if ( !( -e $userInput{"filename"}) )
{
  $temp=$userInput{"filename"};
  printf ( "Error: FILENAME ($temp) is not found\n");
  exit 1;
}

# ------------------------ End -----------------------------

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

# Travel this array and find out the keyword.
for($iCount=0;$iCount <= $#LogBuffer; $iCount ++)
{
  # negative test, no ip acquired is expected
  if ( $userInput{"negative"} == 1 )
  {
    if ( $userInput{"ipv6"} == 0 )
    {
      if($LogBuffer[$iCount] =~ m/$expectedResult[0]/)
      {
        printf ( "Failed: there is a ipv4 address accquired\n" );
        exit 1;
      }
    }
    else
    {
      if($LogBuffer[$iCount] =~ m/$expectedResult[1]/)
      {
        printf ( "Failed: there is a ipv6 address accquired\n" );
        exit 1;
      }    
    }
  }
  
  # normal test, ip address acquired is expected
  else
  {
    if ( $userInput{"ipv6"} == 0 )
    {
      if($LogBuffer[$iCount] =~ m/$expectedResult[0]/)
      {
        printf ( "Succeed: there is a ipv4 address accquired\n" );
        exit 0;
      }
    }
    else
    {
      if($LogBuffer[$iCount] =~ m/$expectedResult[1]/)
      {
        printf ( "Succeed: there is a ipv6 address accquired\n" );
        exit 0;
      }    
    }  
  
  }
}

if ( $userInput{"negative"} == 1 )
{
  printf ("Succeed: there is no ipv4 address accquired\n");
  exit 0;
}
else
{
  printf ("Failed: there is no ip address accquired\n");
  exit 1;
}

# ------------------------ End -----------------------------

close LOGFILE;

__END__


