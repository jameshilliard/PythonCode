#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
# VerifyALA.pl
# Name: Su He (Sorrento)
# Contact: shqa@actiontec.com
# Description: This perl script checking the port using nmap to verify the rar
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
my $globalRc;
my $temp;
my $key;
my $expPort;
my $NOFUNCTION="NOTDEFINED";
my $LOGDIR=`pwd`;
my $usage ="Usage: VerifyALA.pl -n(egative test) -f <json file name> -d <DUT IP> -u user -p password -l <logdir>\n";
my %userInput = ( "filename"=>$NOFUNCTION,
                  "negative"=>0,
		  "debug"=>0, 
                  "user"=>$NOFUNCTION,
		  "password"=>$NOFUNCTION,
                  "perlcmd"=>$NOFUNCTION,
		  "DUTIP"=>$NOFUNCTION,
		  "logdir"=>$LOGDIR,
    );
		          
my %expectedResult = ( "Using Primary Telnet Port"=>{ "result"=>$NOFUNCTION,"port"=>"23"},
                       "Using Secondary Telnet Port"=>{ "result"=>$NOFUNCTION,"port"=>"8023"},
                       "Using Secure Telnet over SSL Port"=>{ "result"=>$NOFUNCTION,"port"=>"992"},
    );
                       
my %realResult = ( "Using Primary Telnet Port"=>{ "result"=>$NOFUNCTION,"port"=>"23"},
                   "Using Secondary Telnet Port"=>{ "result"=>$NOFUNCTION,"port"=>"8023"},
                   "Using Secure Telnet over SSL Port"=>{ "result"=>$NOFUNCTION,"port"=>"992"},
    );
# Step One: Get the option and check the input.
# ---------------------- Begin ----------------------------- 
		   
# Get the option
		   $rc = GetOptions( "h|help"=>\$userInput{help}, 
		  "f=s"=>\$userInput{filename}, 
		  "n"=>\$userInput{negative},
		  "c=s"=>\$userInput{perlcmd},
		  "x=s"=>\$userInput{debug},  
		  "u=s"=>\$userInput{user},  
		  "p=s"=>\$userInput{password},  
		  "l=s"=>\$userInput{logdir},  
		  "d=s"=>\$userInput{DUTIP},
		   );
		            
		            
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
    printf ( "Error: FILENAME ($temp) is not found\n$usage");
    exit 1;
}

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
my ($t1,$t2);
for($iCount=0;$iCount <= $#jsonBuffer; $iCount ++)
{
    foreach $key ( sort keys %expectedResult) {

	 if($jsonBuffer[$iCount] =~ /$key/)  {
	     ($rc,$expectedResult{$key}{result}) = split(/:/,$jsonBuffer[$iCount]);
	     $expectedResult{$key}{result} =~ s/"//g;
	     $expectedResult{$key}{result} =~ s/\n//g;
	     $expectedResult{$key}{result} =~ s/,//g;
	     $expectedResult{$key}{result} =~ s/\s//g;
	     printf("Expected $key = %s\n",$expectedResult{$key}{result});
	}
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
my $nmapCMD = `nmap -p 23,8023,992 $userInput{DUTIP}`;
print("$nmapCMD\n\n");
my @buffer = split ("\n",$nmapCMD);
my ( $port,$state,$service);
print("Actual results:\n");
for($iCount=0;$iCount <= $#buffer; $iCount ++)
{
    next if ( $buffer[$iCount] =~ /^\s*$/ );
    next if ( $buffer[$iCount] !~ /\/tcp/ );
    #print("$iCount = $buffer[$iCount]\n");    
    ($port,$state,$service) = split (" ",$buffer[$iCount]);
    foreach $key ( sort keys %realResult) {
	($port,$temp) = split ('\/',$port);
	$expPort=$realResult{$key}{port};
	if ( $port =~ /^$expPort\b/ ) {
	    if ( $state =~ /open/ ) {
		$realResult{$key}{result}= "on";
		print("$key ($expPort): on\n");	
	    } 
	    if ( $state =~ /closed/ ) {
		$realResult{$key}{result}= "off";
		print("$key ($expPort): off\n");	
	    } 
	}
    }

}



$globalRc=0;
# -----------------------------------------------------
# Step Four: Check the NMAP result and the json config file
# ---------------------- Begin -----------------------------
my ($exp,$actual);
foreach $key ( sort keys %expectedResult ) {
    $exp = $expectedResult{$key} {result};
    $actual = $realResult{$key} {result};
    if( $exp =~ /$actual/ ){
	print( "$key: actual($actual) is matched with Expected ($exp)  \n");
    } else {
	# remove FAILED keyword,by Aleon;
	print( "$key: actual($actual) NOT matched with Expected ($exp) \n");
	$globalRc=1;
    }
}
    

# ----------------------------------------------------------------------
# Step Five: Based on the config, check the implementation of 
# ---------------------- Begin -----------------------------------------
my  ($dut,$usr,$pwd,$log,$cmd);
my $result;
foreach $key ( sort keys  %expectedResult ) {
    $exp = $expectedResult{$key} {result};
    $port = $expectedResult{$key} {port};
    $dut = $userInput{"DUTIP"};
    $usr= $userInput{user};
    $pwd= $userInput{password};
    $log = $userInput{logdir};
    $cmd=$userInput{perlcmd};
    $temp = "$cmd -l $log -d $dut -i $port -u $usr -p $pwd -v \"help\" -m \"Wireless Broadband Router> \" > $log/verifyala_$port\.testlog";
    printf ( " Execute CMD \n ---------------\n$temp \n------------------\n");
    $result = system($temp);
    $result = $result >> 8;
#    print ("RC = $result \n");
    if ( $result == 1 ) {
	if ( $exp =~ /on/ ) {
	    print ( "Local Access through telnet $dut $port ($exp) : FAILED \n");
	    $globalRc = 1;
	} else {
	    print ( "Local Access through telnet $dut $port ($exp) : passed \n");
            # re-define the value of globalRc; by aleon
	    $globalRc = 0;
	}
    }
    if ( $result == 0 ) {
	if ( $exp =~ /on/ ) {
	    print ( "Local Access through telnet $dut $port($exp) : passed \n");
	    # re-define the value of globalRc; by aleon
            $globalRc = 0;
	} else {
	    print ( "Local Access through telnet $dut $port($exp) : FAILED \n");
	    $globalRc = 1;
	}
    }
}

if ( $globalRc != 0) {
    print ( "Test failed \n");
    exit 1;
}
    print ( "Test passed \n");
exit 0;
1;
__END__


