#!/usr/bin/perl -w
#---------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used send result through email to request user
#
#--------------------------------
use strict;
use warnings;
use diagnostics;
use Expect;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
my $NOPATH="noPathGiven";
my %userInput = ( "debug"=>0,
		  "pathdir"=>$NOPATH,
    );
sub getBaseName {
    my ($path,$junk)=@_;
    my @temp = split("/",$path);
    $junk = $temp[$#temp];
    return $junk;
}

#************************************************************
# Main Routine
#************************************************************
MAIN:
my @junk = split( /\//, $0);
my $scriptFn = $junk[$#junk];
my @buff;
my ($x,$h);
my $option_h;
my $option_man = 0;
my $rc = 0;
my $msg;
my $key;
my $current;
my $limit;
my $index;
my $usage="Usage: Create the latest directory as current directory\n\t\tmakecurrent.pl -p <pathname>\n";
my @commands = ();

$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man, 
		  "p=s"=>\$userInput{pathdir},
		  "v=s"=>sub { if ( exists $commands[0] ) { push (@commands,$_[1]); } else {$commands[0]=$_[1]; } } ,
		  );

if ( $option_h ) {
    printf $usage;
    exit 0;
}
if ( $userInput{pathdir} =~ /$NOPATH/ ) {
    printf "Error: Please enter directory path\n$usage ";
    exit 1;
}
if ( !(-d $userInput{pathdir}) ) {
    printf ( "Error:Directory $userInput{pathdir} is not found\n");
    exit 1;
}
$current = $userInput{pathdir}."/current";
printf ( " CURRENT: $current\n  ");
$rc=`rm -f $current`;
$rc = `ls -1t  $userInput{pathdir}`;
printf "\n--\n$rc\n--\n";
@buff=split("\n",$rc);
$limit = @buff;
for ( $index = 0 ; $index < $limit ; $index++) {
#    next if ( $buff[$index] == /^\.+$/ );
#    next if ( $buff[$index] !~ /^svnrepo-.*/ );
    next if ( $buff[$index] !~ /^[a-zA-Z].*/ );
    $key = $buff[$index];
    printf ( "$key found \n");
    last;
} 
printf ( "KEY = $key \n");
#$key = shift (@buff); 
$key = $userInput{pathdir}."/$key";
$rc = `ln -s $key $current`;
$rc = `ls -alt $userInput{pathdir}`;
printf ($rc);
exit 0;
1;

