#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
# generateCase.pl
# Name: Aleon
# Contact: shqa@actiontec.com
# Description: This perl script is used to generate tr069 test case for Jacks tools 
#              
# Copyright @ Actiontec Ltd.
#
# Sample: 
# GPV:  generateCase.pl -s 10.10.10.47 -l f562afcc-ba37-486c-87df-52d34b9a3e74 -u actiontec -p actiontec \
#					-n InternetGatewayDevice.IPPingDiagnostics.Host -t GPV -d $G_CURRENTLOG
#
# SPV:  generateCase.pl -s 10.10.10.47 -l f562afcc-ba37-486c-87df-52d34b9a3e74 -u actiontec -p actiontec \
#					-n InternetGatewayDevice.IPPingDiagnostics.Host -v 10.10.10.47 -t SPV -d $G_CURRENTLOG
#
# GPA:  generateCase.pl -s 10.10.10.47 -l f562afcc-ba37-486c-87df-52d34b9a3e74 -u actiontec -p actiontec \
#					-n InternetGatewayDevice.IPPingDiagnostics.Host -t GPA -d $G_CURRENTLOG
#
# SPA:  generateCase.pl -s 10.10.10.47 -l f562afcc-ba37-486c-87df-52d34b9a3e74 -u actiontec -p actiontec \
#					-n InternetGatewayDevice.IPPingDiagnostics.Host -v 1 -t SPA -d $G_CURRENTLOG
#
# RPC:  generateCase.pl -s 10.10.10.47 -l f562afcc-ba37-486c-87df-52d34b9a3e74 -u actiontec -p actiontec \
#					-n cwmp:FactoryReset -v cwmp:FactoryReset -t RPC -d $G_CURRENTLOG
#-------------------------------------------------------------------------------

use strict;
use warnings;
use diagnostics;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use Data::Dumper;

# Local variables
my $rc;
my $iCount;
my @junk;
my $temp;
my $NOFUNCTION="NOTDEFINED";
my $usage ="Usage: generateCase.pl -s <server address> -l <sub url> -u <user name> -p <password> -n <node> -v <set value> -t <operator> -d <file directory> -e <Designate sub name>\n";
#
####   -v <set value> : The value is for SPV, SPA and RPC;
#

my %userInput = ( "node"=>$NOFUNCTION,
		  "server"=>$NOFUNCTION,
		  "suburl"=>$NOFUNCTION,
		  "username"=>$NOFUNCTION,
		  "passwd"=>$NOFUNCTION,
		  "operator"=>$NOFUNCTION,
		  "value"=>$NOFUNCTION,
		  "dir"=>$NOFUNCTION,
		  "subname"=>$NOFUNCTION,
		);
		          
# ---------------------- Begin ----------------------------- 
# Get the option and check the input.
# --------------------------------------------------- 

# Get the option
$rc = GetOptions( "h|help"=>\$userInput{help}, 
		    "n=s"=>\$userInput{"node"}, 
		    "s=s"=>\$userInput{"server"},  
		    "l=s"=>\$userInput{"suburl"},
		    "u=s"=>\$userInput{"username"},
		    "v=s"=>\$userInput{"value"},
		    "t=s"=>\$userInput{"operator"},
		    "p=s"=>\$userInput{"passwd"},
		    "d=s"=>\$userInput{"dir"},
		    "e=s"=>\$userInput{"subname"},
		);
		            
# If "help", print the help information
if ( $userInput{help} ) 
{
    print $usage;
    exit 0;
}

# Check server address for input parameters.
if ( $userInput{"server"} =~ /$NOFUNCTION\b/ )
{
    $temp=$userInput{"server"};
    printf ( "Error:Please provide missing server ($temp)\n$usage");
    exit 1;
}

# Check the sub-url for input parameters.
if ( $userInput{"suburl"} =~ /$NOFUNCTION\b/ )
{
    $temp=$userInput{"suburl"};
    printf ( "Error: FILENAME suburl ($temp) is not found\n$usage");
    exit 1;
}

# check user name for input parameters.
if ( $userInput{"username"} =~ /$NOFUNCTION\b/ )
{
    $temp=$userInput{"username"};
    printf ( "Error: FILENAME username ($temp) is not found\n$usage");
    exit 1;
}
# check password for input parameters.
if ( $userInput{"passwd"} =~ /$NOFUNCTION\b/ )
{
    $temp=$userInput{"passwd"};
    printf ( "Error: FILENAME passwd ($temp) is not found\n$usage");
    exit 1;
}
# check directory for input parameters.
if ( $userInput{"dir"} =~ /$NOFUNCTION\b/ )
{
    $temp=$userInput{"dir"};
    printf ( "Error: FILENAME directory ($temp) is not found\n$usage");
    exit 1;
}
# check node for input parameters.
if ( $userInput{"node"} =~ /$NOFUNCTION\b/ )
{
    $temp=$userInput{"node"};
    printf ( "Error: FILENAME node ($temp) is not found\n$usage");
    exit 1;
}
# check operator for input parameters.
if ( $userInput{"operator"} =~ /$NOFUNCTION\b/ )
{
    $temp=$userInput{"operator"};
    printf ( "Error: FILENAME operator ($temp) is not found\n$usage");
    exit 1;
}

#------------------------------------------------------
# Set case file.
#------------------------------------------------------

    my $connect;
    my $getParams = "";
    my $setValueParams = "";
    my $setAttributeParams = "";
    my $getAttribParams = "";
    my $setRpc = "";
    my $caseFile;
    my $x;
    my $h;
    
    # set the file name of cases.
    if ( $userInput{"subname"} =~ /$NOFUNCTION\b/ ) 
    {
	$caseFile = $userInput{"dir"}."/".$userInput{"operator"}."_".$userInput{"node"}."\.tc";
    } else {
	$caseFile = $userInput{"dir"}."/".$userInput{"operator"}."_".$userInput{"node"}."_".$userInput{"subname"}."\.tc";
    }
    $rc = open(FID,">".$caseFile);
    if( $rc != 1 ) 
    {
	print("\nCould not write case file, please check it again.\n");
	exit 1;
    }

    # Chomp the netmask of server.
    ($x,$h) =split ('\/',$userInput{"server"});
    $userInput{"server"} = $x;

    # Out put the parameters.
    print "\nSetting parameters as below:\n-------------------\n";
    print "The server is :$userInput{\"server\"}\n";
    print "The subURL is :$userInput{\"suburl\"}\n";
    print "The operator is :$userInput{\"operator\"}\n";
    print "The node is :$userInput{\"node\"}\n";
    print "The value is :$userInput{\"value\"}\n";
    print "username is :$userInput{\"username\"}\n";
    print "The passwd is :$userInput{\"passwd\"}\n";
    print "The directory is :$userInput{\"dir\"}\n\n";

    $connect = "connect http://$userInput{\"server\"}:4567/$userInput{\"suburl\"} $userInput{\"username\"} $userInput{\"passwd\"} NONE";
    $getParams = "get_params $userInput{\"node\"}"; 
    $setValueParams = "set_params $userInput{\"node\"}=$userInput{\"value\"}";
    $getAttribParams = "get_attribs $userInput{\"node\"}"; 
    $setAttributeParams = "set_attribs $userInput{\"node\"} true 1 $userInput{\"value\"} \"None\"";
    $setRpc = "rpc $userInput{\"value\"}";
    chomp($connect);
    chomp($getParams);
    chomp($setValueParams);
    chomp($setAttributeParams);

    #print "$connect\n";
    #print "$params\n";
    for ($userInput{"operator"}) {
	/GPV/ && do {
	    print "\n-----\nlisten 1234\n$connect\nwait\nrpc InformResponse MaxEnvelopes=1\nwait\n$getParams\nwait\nrpc0\nwait\nquit\n-----\n";
	    print FID "listen 1234\n$connect\nwait\nrpc InformResponse MaxEnvelopes=1\nwait\n$getParams\nwait\nrpc0\nwait\nquit\n";
	    last;
	};
	/SPV/m && do {
	    print "\n-----\nlisten 1234\n$connect\nwait\nrpc InformResponse MaxEnvelopes=1\nwait\n$setValueParams\nwait\nrpc0\nwait\nquit\n-----\n";
	    print FID "listen 1234\n$connect\nwait\nrpc InformResponse MaxEnvelopes=1\nwait\n$setValueParams\nwait\nrpc0\nwait\nquit\n";
	    last;
	};
	/GPA/ && do {
	    print "\n-----\nlisten 1234\n$connect\nwait\nrpc InformResponse MaxEnvelopes=1\nwait\n$getAttribParams\nwait\nrpc0\nwait\nquit\n-----\n";
	    print FID "listen 1234\n$connect\nwait\nrpc InformResponse MaxEnvelopes=1\nwait\n$getAttribParams\nwait\nrpc0\nwait\nquit\n";
	    last;
	};

	/SPA/m && do {
	    print "\n-----\nlisten 1234\n$connect\nwait\nrpc InformResponse MaxEnvelopes=1\nwait\n$setAttributeParams\nwait\nrpc0\nwait\nquit\n-----\n";
	    print FID "listen 1234\n$connect\nwait\nrpc InformResponse MaxEnvelopes=1\nwait\n$setAttributeParams\nwait\nrpc0\nwait\nquit\n";
	    last;
	};
	/RPC/m && do {
	    print "\n-----\nlisten 1234\n$connect\nwait\nrpc InformResponse MaxEnvelopes=1\nwait\n$setRpc\nwait\nrpc0\nwait\nquit\n-----\n";
	    print FID "listen 1234\n$connect\nwait\nrpc InformResponse MaxEnvelopes=1\nwait\n$setRpc\nwait\nrpc0\nwait\nquit\n";
	    last;
	};
	die "WORN -- Unknow operator for setting.\n";

    }

    close(FID);
 
exit (0);
1;


