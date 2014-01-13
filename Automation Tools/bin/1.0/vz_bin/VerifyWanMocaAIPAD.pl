#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
# VerifyAIPAD.pl
# Name: Su He
# Contact: kindaxe@actiontec.com
# Description: This perl script check the AIPAD result.
# Copyright @ Actiontec Ltd.
#-------------------------------------------------------------------------------

use strict;
use warnings;
use diagnostics;
use Expect;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use JSON;
use Data::Dumper;

# Local variables
my $rc;
my $iCount;
my @junk;
my @jsonBuffer;
my $temp;
my $NOFUNCTION="NOTDEFINED";
my $usage ="Usage: VerifyAIPAD.pl -n(egative test) -f <json file name> -d <DHCP log>\n";
my %userInput = ( "jsonlog"=>$NOFUNCTION,
                  "negative"=>0,
		          "debug"=>0, 
		          "dhcplog"=>$NOFUNCTION,
		          "mode"=>$NOFUNCTION,);

# "enable" is the default mode.		          
$userInput{"mode"} = "enable";		          
		          
my %expectedResult = ( "ipmin"=>$NOFUNCTION,
                       "ipmax"=>$NOFUNCTION, );
                       
my %realResult = ( "ip"=>$NOFUNCTION );

# Step One: Get the option and check the input.
# ---------------------- Begin ----------------------------- 

# Get the option
$rc = GetOptions( "h|help"=>\$userInput{help}, 
		          "f=s"=>\$userInput{"jsonlog"}, 
		          "n"=>\$userInput{"negative"},
		          "x=s"=>\$userInput{"debug"},  
		          "d=s"=>\$userInput{"dhcplog"},
		          "m=s"=>\$userInput{"mode"},);
		            
		            
# If "help", print the help information
if ( $userInput{help} ) 
{
    print $usage;
    exit 0;
}

# Check the input json filename.
if ( $userInput{"jsonlog"} =~ /$NOFUNCTION\b/ ) 
{
    $temp=$userInput{"jsonlog"};
    printf ( "Error:Please provide missing json file name ($temp)\n$usage");
    exit 1;
}

# Check the input dhcp log from WAN.
if ( $userInput{"dhcplog"} =~ /$NOFUNCTION\b/ )
{
    $temp=$userInput{"dhcplog"};
    printf ( "Error:Please provide missing dhcp log ($temp)\n$usage");
    exit 1;
}

# Check the path.
if ( !( -e $userInput{"jsonlog"}) )
{
    $temp=$userInput{"jsonlog"};
    printf ( "Error: FILENAME $temp is not found\n$usage");
    exit 1;
}

if ( !( -e $userInput{"dhcplog"}) )
{
    $temp=$userInput{"dhcplog"};
    printf ( "Error: FILENAME $temp is not found\n$usage");
    exit 1;
}

# ------------------------ End -----------------------------

# Step Two: Get configured aipad parameter from json file.
# ---------------------- Begin -----------------------------

# Parsing the json file.
$rc = open(JSFD,$userInput{"jsonlog"});

if( $rc != 1 ) 
{
	print("\nCould not read the json file\n");
	print("Please check the file path and authority.\n\n");
	exit 1;
}

@jsonBuffer = <JSFD>;
print("\njson file content:\n");
print(@jsonBuffer);

# Travail this array and find out the keyword.
print("\n\nExpected Results:\n");
for($iCount=0;$iCount <= $#jsonBuffer; $iCount ++)
{
	# ipmin.
	if($jsonBuffer[$iCount] =~ /Start IP Address/)
	{
		($rc,$expectedResult{"ipmin"}) = split(/": "/,$jsonBuffer[$iCount]);
		$expectedResult{"ipmin"} =~ s/"//g;
		$expectedResult{"ipmin"} = substr( $expectedResult{"ipmin"},0,length($expectedResult{"ipmin"})-2 );
		print("ipmin:");
		print($expectedResult{"ipmin"});
		print("\n");
		
		next;
	}	
	
	# ipmax.
	if($jsonBuffer[$iCount] =~ /End IP Address/)
	{
		($rc,$expectedResult{"ipmax"}) = split(/": "/,$jsonBuffer[$iCount]);
		$expectedResult{"ipmax"} =~ s/"//g;
		$expectedResult{"ipmax"} = substr( $expectedResult{"ipmax"},0,length($expectedResult{"ipmax"})-2 );
		print("ipmax:");
		print($expectedResult{"ipmax"});
		print("\n");
		
		next;
	}		
}

# ------------------------ End -----------------------------

# Step Three: Check the configuration result and output.
# ---------------------- Begin -----------------------------
print("\nDHCP Log:\n");
print($userInput{"dhcplog"});
print("\n\n");

print("Grep the New IP address from dhcp log in WAN PC.\n");
my $grepResult = `grep "New IP" $userInput{"dhcplog"} -A 2|grep "inet addr"|awk {'print \$2'}|tr -d " addr:\n"`;
print("$grepResult\n\n");

print("Real Result:\n");
$realResult{"ip"} = $grepResult;
print("$realResult{\"ip\"}\n");

$expectedResult{"ipmax"} =~ s/.//g;
$expectedResult{"ipmin"} =~ s/.//g;
$realResult{"ip"} =~ s/.//g;

# In disable mode, you can't get IP address.
if($userInput{"mode"} =~ /disable/)
{
	# in disable mode
	print("\nDHCP server disabled!\n");
	
	# Get the ip?
	if(length($realResult{"ip"}) == 0)
	{
		print("Can't get the IP.");
		print("\nVerifying AIPAD WAN MOCA Result: Passed!\n\n");
	    printf("Script VerifyWanMocaAIPAD.pl run over!\n\n");
	    exit 0;		
	}
	else
	{
		print("\nVerifying AIPAD WAN MOCA Result: Failed!\n\n");
	    printf("Script VerifyWanMocaAIPAD.pl run over!\n\n");
	    exit 1;
	}
}

if( ord($realResult{"ip"}) <= ord($expectedResult{"ipmax"}) and
    ord($realResult{"ip"}) >= ord($expectedResult{"ipmin"}) )
{
 	print("\nVerifying AIPAD WAN MOCA Result: Passed!\n\n");
 	printf("Script VerifyWanMocaAIPAD.pl run over!\n\n");
 	exit 0;
}
else
{
	print("\nVerifying AIPAD WAN MOCA Result: Failed!\n\n");
	printf("Script VerifyWanMocaAIPAD.pl run over!\n\n");
	exit 1;
}
        
# ------------------------ End -----------------------------

printf("Script VerifyWanMocaAIPAD.pl run over!\n\n");
exit 0;

1;
__END__

$usage \n
