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
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use Log::Log4perl;

my $temp;
my $rc;
my $NOTDEFINED="NOTDEFINED";
my $usage="Usage: VerifyNumOfPkt.pl -n(egative) -f <packets file> -s <number of packets> -h <help>\n";

my %userInput = ( "pktFile"=>$NOTDEFINED,
		  "negative"=>0,
		  "number"=>$NOTDEFINED
    );

#-------------Get the option------------------
$rc = GetOptions( "s=s"=>\$userInput{number}, 
		  "help|h"=>\$userInput{help}, 
		  "f=s"=>\$userInput{pktFile},		  
		  "n"=>\$userInput{negative},		  
		  );

# If "help", print the help infomation.
if ( $userInput{help} )
{
    print $usage;
    exit 0;
}

# check package file.
if ( $userInput{pktFile} =~ /$NOTDEFINED\b/ )
{
    $temp=$userInput{pktFile};
    printf "ERROR: please provide missing packets file ($temp)\n$usage";
    exit 1;
}

# check number of packets.
if ( $userInput{number} =~ /$NOTDEFINED\b/ )
{
    $temp=$userInput{pktFile};
    printf "ERROR: please provide missing packets file ($temp)\n$usage";
    exit 1;
}

#--------------------------------------
# main
#--------------------------------------
my @test;
my $iCount;
my $pkts=0;

@test=`tshark -r $userInput{pktFile} -V`;
#print (@test);
if( !@test )
{
 	print "\n-|----------------------------------#\n";
        print("-| Could not find package file\n");
        print("-| Please check the file path and authority.\n");
 	print "-|----------------------------------#\n\n";
        exit 1;
}

for ($iCount=0;$iCount <= $#test;$iCount ++)
{
    # Filter the number of packets;
    if($test[$iCount] =~ /Frame Number/)
    {
	$pkts = $pkts + 1;
    }
}
print "\n-| Total packets of capture is : $pkts\n";

if ($pkts == $userInput{number})
{
    print "-|------------------------------#\n";
    print "-| PASS: The number of packets is correct;\n";
    print "-|------------------------------#\n";
    exit 0;
} else {
    print "-|------------------------------#\n";
    print "-| FAIL: The number of packets is NOT correct;\n";
    print "-|------------------------------#\n";
    exit 1;
}



