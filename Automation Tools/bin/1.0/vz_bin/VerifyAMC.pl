#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
# VerifyAMC.pl
# Name: Su He
# Contact: shqa@actiontec.com
# Description: This perl script check the AMC result using arp in remote PC to 
#              verify the amc configuration.
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
my $usage ="Usage: VerifyAMC.pl -n(egative test) -f <json file name> -d <ARP log>\n";
my %userInput = ( "filename"=>$NOFUNCTION,
                  "negative"=>0,
		          "debug"=>0, 
		          "arplog"=>$NOFUNCTION,
		          "localeth"=>$NOFUNCTION,
		          "factorymac"=>$NOFUNCTION,);
		          
my %expectedResult = ( "mac"=>$NOFUNCTION );
                       
my %realResult = ( "mac"=>$NOFUNCTION );

# Step One: Get the option and check the input.
# ---------------------- Begin ----------------------------- 

# Get the option
$rc = GetOptions( "h|help"=>\$userInput{help}, 
		          "f=s"=>\$userInput{"filename"}, 
		          "n"=>\$userInput{"negative"},
		          "x=s"=>\$userInput{"debug"},  
		          "m=s"=>\$userInput{"localeth"},
		          "a=s"=>\$userInput{"factorymac"},
		          "d=s"=>\$userInput{"arplog"},);
		            
		            
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

# Check the input arp log from WAN.
if ( $userInput{"arplog"} =~ /$NOFUNCTION\b/ )
{
    $temp=$userInput{"arplog"};
    printf ( "Error:Please provide missing arp log ($temp)\n$usage");
    exit 1;
}

# Check the path.
if ( !( -e $userInput{"filename"}) )
{
    $temp=$userInput{"filename"};
    printf ( "Error: FILENAME $temp is not found\n$usage");
    exit 1;
}

if ( !( -e $userInput{"arplog"}) )
{
    $temp=$userInput{"arplog"};
    printf ( "Error: FILENAME $temp is not found\n$usage");
    exit 1;
}

# ------------------------ End -----------------------------

# Step Two: Get configured amc parameter from json file.
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
	# mac.
	if($jsonBuffer[$iCount] =~ /To Physical Address/)
	{
		($rc,$expectedResult{"mac"}) = split(/": "/,$jsonBuffer[$iCount]);
		$expectedResult{"mac"} =~ s/"//g;
		$expectedResult{"mac"} = substr( $expectedResult{"mac"},0,length($expectedResult{"mac"})-2 );
		print("mac:");
		print($expectedResult{"mac"});
		print("\n");
		
		last;
	}	
	
	# Clone my MAC address.
	if($jsonBuffer[$iCount] =~ /"Clone my MAC address": "on"/)
	{	
		# Get the local Mac address.
		print("\nGett the local machine's MAC...\n"); 
		
		# Awk the mac address from local PC.		
		$expectedResult{"mac"} = `ifconfig $userInput{"localeth"}|grep HWaddr|awk '{print \$5}'`;
		
		$expectedResult{"mac"} = substr( $expectedResult{"mac"},0,17);
		
		$expectedResult{"mac"} = lc($expectedResult{"mac"});
		$expectedResult{"mac"} =~ s/\n//g;
		$expectedResult{"mac"} =~ s/\r//g;
		$expectedResult{"mac"} =~ s/\s//g;
		
			
		print("mac:");
		print($expectedResult{"mac"});
		print("\n\n");
		
		last;
	}
	
	# Restore Factory MAC Address.
	if($jsonBuffer[$iCount] =~ /"Restore Factory MAC Addresss": "on"/)
	{	
		# Get the factory Mac address.
		print("\nGet the factory MAC address...\n");
		$expectedResult{"mac"} = $userInput{"factorymac"};		
		
		$expectedResult{"mac"} = lc($expectedResult{"mac"});
		$expectedResult{"mac"} =~ s/\n//g;
		$expectedResult{"mac"} =~ s/\r//g;
		$expectedResult{"mac"} =~ s/\s//g;
			
		print("mac:");
		print($expectedResult{"mac"});
		print("\n\n");
		
		last;
	}	
}

# ------------------------ End -----------------------------

# Step Three: Check the configuration result and output.
# ---------------------- Begin -----------------------------
print("\nArp Log:\n");
print("$userInput{\"arplog\"}\n\n");

print("Grep the mac address from  WAN PC arp log.\n");
my $grepResult = `grep $expectedResult{"mac"} $userInput{"arplog"}`;
print("$grepResult\n\n");
if( $? )
{
 	print("\nVerifying AMC Result: Failed!\n\n");
 	printf("Script VerifyAMC.pl run over!\n\n");
 	exit 1;
}
else
{
	print("\nVerifying AMC Result: Passed!\n\n");
	printf("Script VerifyAMC.pl run over!\n\n");
	exit 0;
}
        
# ------------------------ End -----------------------------

printf("Script VerifyAMC.pl run over!\n\n");
exit 0;

1;
__END__

$usage \n
