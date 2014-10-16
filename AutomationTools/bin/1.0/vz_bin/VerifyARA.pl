#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
# VerifyARA.pl
# Name: Su He
# Contact: shqa@actiontec.com
# Description: This perl script checking the port using nmap to verify the ara
#              configuration.
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
my $usage ="Usage: VerifyARA.pl -n(egative test) -f <json file name> -p <DUT IP>\n";
my %userInput = ( "filename"=>$NOFUNCTION,
                  "negative"=>0,
		          "debug"=>0, 
		          "WanHost"=>$NOFUNCTION,
		          "DUTIP"=>$NOFUNCTION,
		          "user"=>$NOFUNCTION,
		          "password"=>$NOFUNCTION);
		          
my %expectedResult = ( "Using Primary Telnet Port"=>$NOFUNCTION,
                       "Using Secondary Telnet Port"=>$NOFUNCTION,
                       "Using Secure Telnet over SSL Port"=>$NOFUNCTION,
                       "Using Primary HTTP Port"=>$NOFUNCTION,
                       "Using Secondary HTTP Port"=>$NOFUNCTION,
                       "Using Primary HTTPS Port"=>$NOFUNCTION,
                       "Using Secondary HTTPS Port"=>$NOFUNCTION,
                       "Allow Incoming WAN ICMP Echo Requests"=>$NOFUNCTION,
                       "Allow Incoming WAN UDP Traceroute Queries"=>$NOFUNCTION );
                       
my %realResult = ( "Using Primary Telnet Port"=>$NOFUNCTION,
                   "Using Secondary Telnet Port"=>$NOFUNCTION,
                   "Using Secure Telnet over SSL Port"=>$NOFUNCTION,
                   "Using Primary HTTP Port"=>$NOFUNCTION,
                   "Using Secondary HTTP Port"=>$NOFUNCTION,
                   "Using Primary HTTPS Port"=>$NOFUNCTION,
                   "Using Secondary HTTPS Port"=>$NOFUNCTION,
                   "Allow Incoming WAN ICMP Echo Requests"=>$NOFUNCTION,
                   "Allow Incoming WAN UDP Traceroute Queries"=>$NOFUNCTION );

# Step One: Get the option and check the input.
# ---------------------- Begin ----------------------------- 

# Get the option
$rc = GetOptions( "h|help"=>\$userInput{help}, 
		          "f=s"=>\$userInput{filename}, 
		          "n"=>\$userInput{negative},
		          "x=s"=>\$userInput{debug},  
		          "d=s"=>\$userInput{"DUTIP"},
		          "r=s"=>\$userInput{"WanHost"},
		          "u=s"=>\$userInput{"user"},
		          "p=s"=>\$userInput{"password"},);
		            
		            
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

# Check the input DUT IP.
if ( $userInput{"WanHost"} =~ /$NOFUNCTION\b/ )
{
    $temp=$userInput{"WanHost"};
    printf ( "Error:Please provide Wan Host IP ($temp)\n$usage");
    exit 1;
}

# Check the path.
if ( !( -e $userInput{"filename"}) )
{
    $temp=$userInput{"filename"};
    printf ( "Error: FILENAME ($temp) is not found\n$usage");
    exit 1;
}

($userInput{"DUTIP"},$rc) = split(/\//,$userInput{"DUTIP"});
($userInput{"WanHost"},$rc) = split(/\//,$userInput{"WanHost"});

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
	# Port 23.
	if($jsonBuffer[$iCount] =~ /Using Primary Telnet Port/)
	{
		($rc,$expectedResult{"Using Primary Telnet Port"}) = split(/:/,$jsonBuffer[$iCount]);
		$expectedResult{"Using Primary Telnet Port"} =~ s/"//g;
		print("Using Primary Telnet Port:");
		print($expectedResult{"Using Primary Telnet Port"});
	}
	
	# Port 8023.
	if($jsonBuffer[$iCount] =~ /Using Secondary Telnet Port/)
	{
		($rc,$expectedResult{"Using Secondary Telnet Port"}) = split(/:/,$jsonBuffer[$iCount]);
		$expectedResult{"Using Secondary Telnet Port"} =~ s/"//g;
		print("Using Secondary Telnet Port:");
		print($expectedResult{"Using Secondary Telnet Port"});
	}	
	
	# Port 992.
	if($jsonBuffer[$iCount] =~ /Using Secure Telnet over SSL Port/)
	{
		($rc,$expectedResult{"Using Secure Telnet over SSL Port"}) = split(/:/,$jsonBuffer[$iCount]);
		$expectedResult{"Using Secure Telnet over SSL Port"} =~ s/"//g;
		print("Using Secure Telnet over SSL Port:");
		print($expectedResult{"Using Secure Telnet over SSL Port"});
	}	
	
	# Port 80.
	if($jsonBuffer[$iCount] =~ /Using Primary HTTP Port/)
	{
		($rc,$expectedResult{"Using Primary HTTP Port"}) = split(/:/,$jsonBuffer[$iCount]);
		$expectedResult{"Using Primary HTTP Port"} =~ s/"//g;
		print("Using Primary HTTP Port:");
		print($expectedResult{"Using Primary HTTP Port"});
	}
	
	# Port 8080.
	if($jsonBuffer[$iCount] =~ /Using Secondary HTTP Port/)
	{
		($rc,$expectedResult{"Using Secondary HTTP Port"}) = split(/:/,$jsonBuffer[$iCount]);
		$expectedResult{"Using Secondary HTTP Port"} =~ s/"//g;
		print("Using Secondary HTTP Port:");
		print($expectedResult{"Using Secondary HTTP Port"});
	}	
	
	# Port 443.
	if($jsonBuffer[$iCount] =~ /Using Primary HTTPS Port/)
	{
		($rc,$expectedResult{"Using Primary HTTPS Port"}) = split(/:/,$jsonBuffer[$iCount]);
		$expectedResult{"Using Primary HTTPS Port"} =~ s/"//g;
		print("Using Primary HTTPS Port:");
		print($expectedResult{"Using Primary HTTPS Port"});
	}	
	
	# Port 8443.
	if($jsonBuffer[$iCount] =~ /Using Secondary HTTPS Port/)
	{
		($rc,$expectedResult{"Using Secondary HTTPS Port"}) = split(/:/,$jsonBuffer[$iCount]);
		$expectedResult{"Using Secondary HTTPS Port"} =~ s/"//g;
		print("Using Secondary HTTPS Port:");
		print($expectedResult{"Using Secondary HTTPS Port"});
	}		
}

# ------------------------ End -----------------------------



# Step Three: Get the real ala parameter.
# ---------------------- Begin -----------------------------

# Get the DUT IP.
@junk = split ("/",$userInput{"DUTIP"});
$userInput{"DUTIP"} = $junk[0];
print("DUT IP: $userInput{DUTIP}\n\n");

# Ping to the DUT
print("Ping to the DUT...\n");
my $pingCMD = `ping $userInput{DUTIP} -w 2 -c 2`;
print("$pingCMD\n\n");

# NMAP to the DUT
print("NMAP to the DUT...\n");
print("Launching sshcli.pl\n");

my $nmapCMD = `sshcli.pl -l \$G_CURRENTLOG -u $userInput{"user"} -p $userInput{"password"} -d $userInput{"WanHost"} -v "nmap -p 23,8023,992,80,8080,443,8443 $userInput{DUTIP}"`;
print("$nmapCMD\n\n");

# Parse the nmap result.

$nmapCMD =~ s/\n//g;
$nmapCMD =~ s/\r//g;
$nmapCMD =~ s/\s//g;

print("Real results:\n");

# Port 23
if($nmapCMD=~/23\/tcpopentelnet/)
{
	$realResult{"Using Primary Telnet Port"} = "on";
	print("Primary Telnet Port (23): $realResult{\"Using Primary Telnet Port\"}\n");	
}
elsif($nmapCMD=~/23\/tcpclosedtelnet/ or $nmapCMD=~/23\/tcpfilteredtelnet/)
{
	$realResult{"Using Primary Telnet Port"} = "off";
	print("Primary Telnet Port (23): $realResult{\"Using Primary Telnet Port\"}\n");	
}

# Port 8023
if($nmapCMD=~/8023\/tcpopen/)
{
	$realResult{"Using Secondary Telnet Port"} = "on";
	print("Secondary Telnet Port (8023): $realResult{\"Using Secondary Telnet Port\"}\n");	
}
elsif($nmapCMD=~/8023\/tcpclosed/ or $nmapCMD=~/8023\/tcpfiltered/)
{
	$realResult{"Using Secondary Telnet Port"} = "off";
	print("Secondary Telnet Port (8023): $realResult{\"Using Secondary Telnet Port\"}\n");	
}

# Port 992
if($nmapCMD=~/992\/tcpopen/)
{
	$realResult{"Using Secure Telnet over SSL Port"} = "on";
	print("Secure Telnet over SSL Port (992): $realResult{\"Using Secure Telnet over SSL Port\"}\n");	
}
elsif($nmapCMD=~/992\/tcpclosed/ or $nmapCMD=~/992\/tcpfiltered/)
{
	$realResult{"Using Secure Telnet over SSL Port"} = "off";
	print("Secure Telnet over SSL Port (992): $realResult{\"Using Secure Telnet over SSL Port\"}\n");	
}

# Port 80
if($nmapCMD=~/telnet80\/tcpopenhttp/)
{
	$realResult{"Using Primary HTTP Port"} = "on";
	print("Primary HTTP Port (80): $realResult{\"Using Primary HTTP Port\"}\n");	
}
elsif($nmapCMD=~/telnet80\/tcpclosedhttp/ or $nmapCMD=~/telnet80\/tcpfilteredhttp/)
{
	$realResult{"Using Primary HTTP Port"} = "off";
	print("Primary HTTP Port (80): $realResult{\"Using Primary HTTP Port\"}\n");	
}

# Port 8080
if($nmapCMD=~/8080\/tcpopen/)
{
	$realResult{"Using Secondary HTTP Port"} = "on";
	print("Secondary HTTP Port (8080): $realResult{\"Using Secondary HTTP Port\"}\n");	
}
elsif($nmapCMD=~/8080\/tcpclosed/ or $nmapCMD=~/8080\/tcpfiltered/)
{
	$realResult{"Using Secondary HTTP Port"} = "off";
	print("Secondary HTTP Port (8080): $realResult{\"Using Secondary HTTP Port\"}\n");	
}

# Port 443
if($nmapCMD=~/http443\/tcpopenhttps/)
{
	$realResult{"Using Primary HTTPS Port"} = "on";
	print("Primary HTTPS Port (443): $realResult{\"Using Primary HTTPS Port\"}\n");	
}
elsif($nmapCMD=~/http443\/tcpclosedhttps/ or $nmapCMD=~/http443\/tcpfilteredhttps/)
{
	$realResult{"Using Primary HTTPS Port"} = "off";
	print("Primary HTTPS Port (443): $realResult{\"Using Primary HTTPS Port\"}\n");	
}

# Port 8443
if($nmapCMD=~/8443\/tcpopen/)
{
	$realResult{"Using Secondary HTTPS Port"} = "on";
	print("Secondary HTTPS Port (8443): $realResult{\"Using Secondary HTTPS Port\"}\n");	
}
elsif($nmapCMD=~/8443\/tcpclosed/ or $nmapCMD=~/8443\/tcpfiltered/)
{
	$realResult{"Using Secondary HTTPS Port"} = "off";
	print("Secondary HTTPS Port (8443): $realResult{\"Using Secondary HTTPS Port\"}\n");	
}

# ------------------------ End -----------------------------

# Step Four: Check the configuration result and output.
# ---------------------- Begin -----------------------------
if( $expectedResult{"Using Primary Telnet Port"} =~ /$realResult{"Using Primary Telnet Port"}/ &&
    $expectedResult{"Using Secondary Telnet Port"} =~ /$realResult{"Using Secondary Telnet Port"}/ &&
    $expectedResult{"Using Secure Telnet over SSL Port"} =~ /$realResult{"Using Secure Telnet over SSL Port"}/ &&
    $expectedResult{"Using Primary HTTP Port"} =~ /$realResult{"Using Primary HTTP Port"}/ &&
    $expectedResult{"Using Secondary HTTP Port"} =~ /$realResult{"Using Secondary HTTP Port"}/ &&
    $expectedResult{"Using Primary HTTPS Port"} =~ /$realResult{"Using Primary HTTPS Port"}/ &&
    $expectedResult{"Using Secondary HTTPS Port"} =~ /$realResult{"Using Secondary HTTPS Port"}/ )
{
 	print("\nVerifying Advanced Remote Administration Result: Passed!\n\n");
        printf("Script VerifyARA run over!\n\n");
        exit 0;

}
else
{
	print("\nVerifying Advanced Remote Administration Result: Failed!\n\n");
        printf("Script VerifyARA run over!\n\n");
        exit 1;
}
    
    
# ------------------------ End -----------------------------

printf("Script VerifyARA run over!\n\n");
exit 0;

1;
__END__

$usage \n
