#!/usr/bin/perl -w
#-------------------------------------------------------------------
# Name: Joe Nguyen
# Description:
#---------------- 
#--------------
#--------------------------------------------------------------------
use strict;
use warnings;
use diagnostics;
use Expect;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
my $op;
my $temp;
my $file;
my $NOFUNCTION="NOTDEFINED";
my %userInput = (
    "filename"=>$NOFUNCTION,
    "negative"=>0,
    "operation"=>$NOFUNCTION,
		 "debug"=>0,
    );
my @commands;
my @incommands;
my $usage ="Usage: searchoperation.pl -n(egative test to return good result if not found) -e <name of operation> .. -i <inclusive/specific op>  -f <filename where operations should be searched>\n"; 
my $rc = GetOptions( "h|help"=>\$userInput{help}, 
		     "f=s"=>\$userInput{filename}, 
		     "n"=>\$userInput{negative},
#		     "e=s"=>\$userInput{operation},
		     "e=s"=>sub { if ( exists $commands[0] ) { push (@commands,$_[1]); } else {$commands[0]=$_[1]; } } ,
		     "i=s"=>sub { if ( exists $incommands[0] ) { push (@incommands,$_[1]); } else {$incommands[0]=$_[1]; } } ,
		     "x=s"=>\$userInput{debug},
    );



if ( $userInput{help} ) {
    print $usage;
    exit 0;
}
$file = $userInput{filename};
my $limit = @commands;
if ($limit != 0 ) {
    $temp="";
    foreach my $line (  @commands) { 
	printf "Search for: $line \n";
	$temp .= " -e "."\"$line\""; 
    } 
    $userInput{operation}=$temp." ".$file;
};

$limit = @incommands;
if ($limit != 0 ) {
    $temp=$userInput{operation}. " | grep ";
    foreach my $line (  @incommands) { 
	printf "Search for inclusive: $line \n";
	$temp .= " -e "."\"$line\""; 
    } 
    $userInput{operation}=$temp;
};


if ( $userInput{filename} =~ /$NOFUNCTION\b/ ) {
    $temp=$userInput{filename};
    printf ( "Error:Please provide missing FILENAME ($temp)\n$usage");
    exit 1;
}



if ( !( -e $userInput{filename}) ) {
    $temp=$userInput{filename};
    print ( "Error: FILENAME ($temp) is not found\n$usage");
    exit 1;
}

if ( $userInput{operation} =~ /$NOFUNCTION\b/ ) {
    $temp=$userInput{operation};
    print ( "Error:Please provide missing OPERATION NAME($temp)  \n$usage");
    exit 1;
}




$op = $userInput{operation};
print ("\ncmd = grep $op\n");
$rc = `grep $op`;
$rc =~ s/\n//;
$rc =~ s/\r//;
#test positive
if ( $userInput{negative} == 0 ) { 
    print ( " Positive testing : Searching for \[$op\] \nRC=$rc\n") if ( $userInput{debug} > 2 ) ;
    if ( $rc =~ /^\s*$/) {
	print ( "AT_ERROR : Failed: string \[$op\] is not found from $file -- positive test\n");
	exit 1;
    }
    print ( "Passed : string \[$op\] is found as expected  from $file -- positive test \n$rc\n");
    exit 0;
}
#test negative
print ( " Negative  testing : Searching for \[$op\] \nRC=$rc\n") if ( $userInput{debug} > 2 ) ;
if ( $rc =~ /^\s*$/) {
    print ( "Passed: string \[$op\] is not found as expected from $file -- negative test\n");
    exit 0;
}
print ( "AT_ERROR : Failed: string \[$op\] is found from $file -- negative test\n$rc\n");
#print ( " Failed: string $op is found from $file -- negative test\n\n");
exit 1;
1;
