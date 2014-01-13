#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
# VerifyDNS.pl
# Name: Su He
# Contact: shqa@actiontec.com
# Description: This perl script checking the DNS Server using nslookup to verify
#              the ads configuration.
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
my $usage ="Usage: VerifyDNS.pl -n(egative test) -f <json file name> -d <DUT IP>\n";
my %userInput = ( "filename"=>$NOFUNCTION,
                  "negative"=>0,
		          "debug"=>0, 
		          "DUTIP"=>$NOFUNCTION);
		          
my %expectedResult = ( "Name"=>$NOFUNCTION,
                       "Address"=>$NOFUNCTION );
                       
my %realResult = ( "Name"=>$NOFUNCTION,
                   "Address"=>$NOFUNCTION );

# Step One: Get the option and check the input.
# ---------------------- Begin ----------------------------- 

# Get the option
$rc = GetOptions( "h|help"=>\$userInput{help}, 
		          "f=s"=>\$userInput{filename}, 
		          "n"=>\$userInput{negative},
		          "x=s"=>\$userInput{debug},  
		          "d=s"=>\$userInput{"DUTIP"},);
		            
		            
# If "help", print the help information
if ( $userInput{help} ) 
{
    print $usage;
    exit 0;
}

# Check the input json filename.
if ( $userInput{"filename"} =~ /$NOFUNCTION\b/ ) 
{
    $temp=$userInput{"filename"};
    printf ( "Error:Please provide missing json file name ($temp)\n$usage");
    exit 1;
}

# Check the input DUT IP.
if ( $userInput{"DUTIP"} =~ /$NOFUNCTION\b/ )
{
    $temp=$userInput{"DUTIP"};
    printf ( "Error:Please provide missing DUT IP ($temp)\n$usage");
    exit 1;
}

# Check the path.
if ( !( -e $userInput{"filename"}) )
{
    $temp=$userInput{"filename"};
    printf ( "Error: FILENAME $temp is not found\n$usage");
    exit 1;
}

($userInput{"DUTIP"},$rc) = split(/\//,$userInput{"DUTIP"});

# ------------------------ End -----------------------------

# Step Two: Get configured ala parameter from json file.
# ---------------------- Begin -----------------------------

# Parsing the json file.
$rc = open(JSFD,$userInput{"filename"});

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
	# Name.
	if($jsonBuffer[$iCount] =~ /Host Name/)
	{
		($rc,$expectedResult{"Name"}) = split(/:/,$jsonBuffer[$iCount]);
		$expectedResult{"Name"} =~ s/"//g;
		$expectedResult{"Name"} = substr( $expectedResult{"Name"},1,length($expectedResult{"Name"})-3 );
		print("Name:");
		print($expectedResult{"Name"});
		print("\n");
	}
	
	# IP Address.
	if($jsonBuffer[$iCount] =~ /IP Address/)
	{
		($rc,$expectedResult{"IP Address"}) = split(/:/,$jsonBuffer[$iCount]);
		$expectedResult{"IP Address"} =~ s/"//g;
		$expectedResult{"IP Address"} = substr( $expectedResult{"IP Address"},1,length($expectedResult{"IP Address"})-3 );
		print("IP Address:");
		print($expectedResult{"IP Address"});
		print("\n");
	}	
}

# ------------------------ End -----------------------------



# Step Three: Get the real ala parameter.
# ---------------------- Begin -----------------------------

# Get the DUT IP.
@junk = split ("/",$userInput{"DUTIP"});
$userInput{"DUTIP"} = $junk[0];
print("\nDUT IP: $userInput{DUTIP}\n\n");

# Ping to the DUT
print("Ping to the DUT...\n");
my $pingCMD = `ping $userInput{DUTIP} -w 2 -c 2`;
print("$pingCMD\n\n");

# Using nslookup to check the domain name.
print("Using nslookup to check the domain name....\n");

my $nslookupCMD = `nslookup $expectedResult{"Name"}`;
print("$nslookupCMD\n\n");

# Parse the nmap result.

$nslookupCMD =~ s/\n//g;
$nslookupCMD =~ s/\r//g;
$nslookupCMD =~ s/\s//g;

$realResult{"Name"} = $expectedResult{"Name"};
@junk = split(/:/,$nslookupCMD);
$realResult{"IP Address"} = pop(@junk);

print("Real results:\n");
print("$realResult{\"Name\"}\n");
print("$realResult{\"IP Address\"}\n");

# ------------------------ End -----------------------------

# Step Four: Check the configuration result and output.
# ---------------------- Begin -----------------------------
if( $expectedResult{"Name"} =~ /$realResult{"Name"}/ &&
    $expectedResult{"IP Address"} =~ /$realResult{"IP Address"}/ )
{
 	print("\nVerifying DNS Result: Passed!\n\n");
}
else
{
	print("\nVerifying DNS Result: Failed!\n\n");
}
    
    
# ------------------------ End -----------------------------

printf("Script VerifyDNS.pl run over!\n\n");
exit 0;

1;
__END__

$usage \n
