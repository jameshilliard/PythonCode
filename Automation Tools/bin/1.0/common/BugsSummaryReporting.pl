#!/usr/bin/perl  -w
#-------------------------------------------------------------------
# Name: Joseph K. Nguyen, MBA
# August 28th, 2009
# Description: Bugs Summary Reporting
#---------------- 
#   This script is used to parse automation_coverage.xls(csv) and report number of test cases failed over 
#   number of totals of all for a particular categories:
#   i.e.: "Self Diag", "GUI", "Automation", "HURL", TR69, TR069, "IGMP", Parental Control,
#         Limit, Advanced Automation, Self-Diagnostics, Verizon, BHR2, WAN
#
#
#   Example of usage: 
#                      perl BugsSummaryReporting.pl -f automation_coverage_JKN.csv -b 1 -s 1 -o testModOut5.csv
#
#
#
# Things To Do:
#--------------
# NOTHING!!!
#--------------------------------------------------------------------
#use strict;
use warnings;
use diagnostics;
use Log::Log4perl;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use Data::Dumper;
use Expect;
use Time::gmtime;
use Date::Simple ('date', 'today');

my $date_string = today();

#printf ("Today's date is: %s\n", $date_string);

my $now = "";  #Time now

#default timeout for each command
my $CMD_TMO = 300; 
#-----<<<----------------
my $FAIL=1;
my $PASS=0;
my $NOFUNCTION="none";
my @junk = split( /\//, $0);
@junk = split('\.',$junk[$#junk]);
my $scriptFn = $junk[0];
my $logdir = `pwd`;
$logdir=~ s/\n//;
my %userInput = (
    "debug" => "0",
    "logdir"=>$logdir,
    "server"=>$NOFUNCTION,
    "bugID"=> "0",
    "displayOutput" => "0",
    "user"=>$NOFUNCTION,
    "password"=>$NOFUNCTION,
    "inputfile"=>$NOFUNCTION,
    "outputfile"=>$NOFUNCTION,
    "timeout"=>$CMD_TMO,
    "scriptname"=> $scriptFn,
    "screenOff"=> 0,
    "commands"=> [],
    "insert"=> [],
    "logOff"=> 0,
    "errtable"=>[ "Login failed due to a bad username or password",
		  "parser error :",
    ],
    );

#---------------------------------------------------------
# This routine is used to initialize the log feature
#---------------------------------------------------------
sub initLogger {
    my ( $profFile, $junk) = @_;
    my $rc = $PASS;
    my $msg ="Successfully Set Logger";
    my $found=1;
    my $count=$profFile->{seed};
    #--------------------
    # initialize logger
    #---------------------
    my $temp = $profFile->{scriptname}."_$profFile->{seed}";
    my $localLog = $profFile->{logdir}."/$temp.log";
    my $clobberLog = $profFile->{logdir}."/$temp\_clobber.log";
    while ( $found ) {
	$temp = $profFile->{scriptname}."_$count";
	$localLog = $profFile->{logdir}."/$temp.log";
	if (!( -e $localLog )) {
	    $profFile->{seed} = $count;
	    $found = 0;
	    next;
	}
	$count++;
    }
    $clobberLog = $profFile->{logdir}."/$temp\_clobber.log";
    if ( -e $clobberLog ) {
	$temp = `rm -f $clobberLog`;
    }
    # layout: date-module + line mumber -(info,debug,warn,error,fatal)> message +  new line 
    my $layout = Log::Log4perl::Layout::PatternLayout->new("%d--%F{1}:%L--%M--%p> %m%n");
    my $gName = "initLogger";
    if ( defined $profFile->{gcov}{$gName} ) {
	$profFile->{gcov}{$gName} += 1;
    } else {
	$profFile->{gcov}{$gName} = 1;
    }

    $profFile->{logger}= Log::Log4perl->get_logger();
    
    if ( $profFile->{screenOff} == 0 ) {
	my $screen = Log::Log4perl::Appender->new("Log::Log4perl::Appender::Screen",
  						  stderr => 0);	
	$profFile->{logger}->add_appender($screen);
    }
    if ( $profFile->{logOff} == 0 ) {
	my $appender = Log::Log4perl::Appender->new("Log::Log4perl::Appender::File",
						    filename => $localLog,
						    mode => "append");
	my $writer = Log::Log4perl::Appender->new("Log::Log4perl::Appender::File",
						  filename => $clobberLog,
						  mode => "clobber");
	$appender->layout($layout);	
	$profFile->{logger}->add_appender($appender);
	$profFile->{logger}->add_appender($writer);
    }
    $profFile->{logger}->info("--> Log initialized <--");
    return($rc,$msg);
}

my $TRUE=1;
my $FALSE=0;
my $option_h;
my $rc =0;
my $msg;
my $count = 0;
my $globalRc = $PASS;
my $option_man = 0;
my $temp;
my $found =0;
my $key;
my $inputFileToRead = "";
my $testFile = "automation_coverage_JKN.csv";

#---------------------------------------------
# Initialize Logger 
#---------------------------------------------
$userInput{seed}="0";
$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man, 
		  "l=s"=>sub {  $userInput{logdir} = $_[1];},
		  "b=i"=>\$userInput{bugID},
		  "s=i"=>\$userInput{displayOutput},
		  "t=s"=>\$userInput{timeout},
		  "f=s"=>\$userInput{inputfile},
		  "o=s"=>\$userInput{outputfile},
		  "u=s"=>\$userInput{user},
		  "p=s"=>\$userInput{password},
		  "d=s"=>\$userInput{server},
		  "v=s"=>sub { if ( exists $userInput{commands}[0] ) { push (@{$userInput{commands}},$_[1]); } else {$userInput{commands}[0]=$_[1]; } } ,
		  "i=s"=>sub { if ( exists $userInput{insert}[0] ) { push (@{$userInput{insert}},$_[1]); } else {$userInput{insert}[0]=$_[1]; } } ,
		  );
#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);
($rc,$msg) = initLogger(\%userInput, 0);
if ( $rc == $FAIL) {
    print ("RC$rc $msg\n");
    exit 1;
} 
if ( $globalRc == $FAIL) {
    $userInput{logger}->info("$msg");
    exit 1;
}
($key,$temp) = split ('\/',$userInput{server});
$userInput{server} = $key;

if($userInput{inputfile} ne "")
{
    $inputFileToRead = $userInput{inputfile};
}
else
{
    pod2usage(1);
    exit 1;
}

#printf("--------------- Input Parameters  ---------------\n") if $userInput{debug} ;
print("--------------- $scriptFn  Input Parameters  ---------------\n");
foreach $key ( keys %userInput ) {
#    printf (" $key = $userInput{$key} :: " ) if $userInput{debug} ;
    print (" $key = $userInput{$key} :: " );
}

$temp = $userInput{outputfile};
if ( $userInput{outputfile} =~ /$NOFUNCTION/) {
#    $userInput{outputfile} = $userInput{logdir}."/".$userInput{scriptname}."_output_$count.txt"
    $found = 1;
    $count=0 ;
    while ( $found ) {
	$temp= $userInput{logdir}."/".$userInput{scriptname}."_output_$count.txt";
	if ( !(-e $temp)){
	    $found=0;
	    next;
	}
	$count++;
    }
}
$userInput{outputfile} = $temp;


my $limit = @{$userInput{commands}};
my $line;
if ($limit != 0 ) {foreach $line (  @{$userInput{commands}}) { print "$line \n"; } };


#************************************************************************************#
#GLOBAL VARIABLES:
my $lineCount = 0;
my @lineArray = ();
my $test = $lineArray[0];
my %categories = ();  #dynamically 
my $headerLineCount = 0;
my $keyFound = 0;    #More specific to each category
my $totalKeysFound =0;  #Global for all of categories
my @notFoundList = ();  #Array to store those that aren't found.
my $notFound = 0;

#Candidates of possible categories to search for:

#my @candidatesArray = ("Advanced", "BHR", "Critical", "DUT", "Firewall", "GUI", "HURL", "IGMP", "Limit", "Manual", "MOCA", \
#		       "My Network", "Parental", "Port", "TR", "Self", "Upgrade","Value", "VZ", "WAN", "WEP", "Wireless");  

my @candidatesArray = ("Advanced", "Firewall", "HURL", "Main", "My", "Parental", "Port", "TR", "Self", "System", "Wireless");  

#my @candidatesArray = ("TR-069", "Wireless", "Self Diag", "My Network", "GUI", "Firewall", "IGMP", "Advanced", "Parenta#l Control" );  


#example:
#my %bugReport = 
#(
# totalDefects => 0,   
#  testQA1 => {   #cat
# 	       Count => 99,    #catfield
# 	       Percentage => 0.69,
# 	       Bugs => {   #bugs
# 		            9999 => "Test Category 1:1",
# 			    1111 => "Test Categroy 1:2",
			    
# 	                }
#              Count_Auto_Bugs => 0;
#              Count_Manual_Bugs => 0;
#         
#  },
#  testQA2 => {   #cat
# 	       Count => 5555,  
# 	       Percentage => 0.85,
# 	       Bugs => {   #bugs
# 		            69 => "Test Category 1:2",
# 			    911 => "Test Category 2:2",
# 			    6161616 => "Test Category 3:2",
			    
#                       }
#              Count_Auto_Bugs => 0;
#              Count_Manual_Bugs => 0;
#  },
#);

my %bugReport = ();  #Dynamic  hash.
my %foundNotFound = (); #Hash to store status of found or not found 1= Found, 0=Not Found;

#Definition of Fields from Header for future expansion:
########################################################################################################################################
#Data format
# , ,"ID" ," "  ,"Title"                                           ,"Added"  ,"Status","Last modified","Firmware" ,,"E19:E394",,,
#", ,15587,\' \',\'Wireless channel change pop-up not implemented\',6/30/2009,\'Fixed\',7/29/2009     ,\'20.9.15\',,          ,,,";
#0,1,    2,    3,                                                 4,        5,        6,        7     ,          8,,        10,,,";
##########################################################################################################################################
eval
{

#MAIN:

#########################################################################################################################################
#Start reading file in and parsing it

my $IFH = new FileHandle($inputFileToRead, "r");

my $notFoundCount = 0;
if(defined($IFH))
{
    while((my $bugLine = <$IFH>))
    {
	chomp ($bugLine);
	@lineArray = split(/,/, $bugLine);

	$test = (defined($lineArray[2]) ? $lineArray[2]:"");  #Bug ID#

	#if 5th item is not date, user must of have commas inside bug description string...
	#assuming two commas, not just one being used.
	if($lineArray[5] !~ m/\d+\/\d+\/\d+/)
	{
	  $lineArray[4] .=$lineArray[5].$lineArray[6];  #Handles rejoining after 2 commas
	}
	
	if($test ne "")
	{
	    $lineCount++;
	    
	    if($test eq "\"ID\"")   #Parse for Header
	    { 
		$headerLineCount = $lineCount;
	    }
	    elsif ($test =~ /^\d+/)
	    {
		$bugReport{totalDefects}++;
		foreach (@candidatesArray)
		{
		    my $testCat = lc($_);
		    
		    $test = lc($lineArray[4]);  #reusing variable for description item in array
	 	 
		    #If found already, we don't count it again in different category by recounting
		    if (($test =~ m/^.*$testCat.*/i) && ($foundNotFound{$lineArray[2]}[0] != 1))  #Newly Improved and more Reliable!!! #570, 186
		    {
			++$totalKeysFound;
			$foundNotFound{$lineArray[2]}[0]= 1;  #Set Found flag for that bug to TRUE
		
			if (defined($categories{$testCat}))  #if the not the first time for this category
			{
			    loadHashArray($testCat, \@lineArray, \%bugReport);
			}
			else
			{   #if first time for this category, initialize count to 0
			    $categories{$testCat}->{Count} = 1; #$test
			    loadHashArray($testCat, \@lineArray, \%bugReport);
			}#else
		    }#if
		    else
		    {  #Not Found or already found in our list of categories
			next;
		    }
		}#foreach
		#If still no match after all categories then we need to set it to ZERO for no match
		if (!defined($foundNotFound{$lineArray[2]}) || ($foundNotFound{$lineArray[2]}[0] != 1))
		{
		    $foundNotFound{$lineArray[2]}[0] = 0;  #Flag as not found
		    $foundNotFound{$lineArray[2]}[1] = $lineArray[4];   #Input Bug description
		    $notFoundCount++;
		}

 	    }#elseif
	    else
	    {  
		next;
	    }
	}#if $test ne
	else
	{
	    #Don't process it, but still increment line counter.
	    $lineCount++;
	    next;
	} #Else
    }#While
    $foundNotFound{Count} = $notFoundCount;  #TotalNotFound

close($IFH); 
}

#testHash(\%foundNotFound);  #For testing of hash loading only

#Summary reporting:
##################################################################################
#Have to call update after parsing to get new percentile after total is calculated.
updateCategoriesPercentiles(\%bugReport);

#If user asked to write to file, do it.
my $outputFileToWrite = "";

#Calculate Auto Vs. Manual per categories and update Hash accordingly
calAutoManual(\%bugReport);

#Processing Output File if selected:
if($userInput{outputfile} ne "")
{
    $outputFileToWrite = $userInput{outputfile};
    
    #Check if 0 item exists and remove
    check0IndexItem(0, \%foundNotFound);  #Hash to keep track of Found or not found
    check0IndexItem("totalDefects", \%bugReport);  #Has to generate our output structure

    my $OFH = writeReportToFile($outputFileToWrite,\%foundNotFound, \%bugReport);
}

#Does user want to see output on screen?
if ($userInput{displayOutput})
{
   printHashArray(\%bugReport);  #Bug when printing to screen!!!
}

##################################################################################
sub check0IndexItem
{
    my ($defectCount) = shift @_;
    my ($hashRef) = shift @_;

    if(defined($hashRef->{0}))
    {
	delete $hashRef->{0};  #Delete 0 item if any
	if($defectCount !=0)
	{
	    $hashRef->{$defectCount}--;  #Decrement Defect count
	}
    }
}
##################################################################################

sub testHash
{
    my ($refHash) = shift @_;
    
    foreach (sort keys %$refHash)
    {
	if ($refHash->{$_}[0] != 1)
	{
	    printf("Loaded value at key: \"%d\" Flag is:\"%d\" \t is:\"%s\"  \n", $_, $refHash->{$_}[0], $refHash->{$_}[1]);
	}
    }
}



##################################################################################

#Write out to file as CSV:
sub  writeReportToFile
{
    my ($outFile) = shift @_;
    my ($foundHashRef) = shift @_;
    my ($hashRef) = shift @_;
    my ($cat, $catField) = ""; 
    my ($bugID, $value) = 0;
    my $varStr = "";
    
    #Remove existing out file if exists
    if ( -e $outFile)
    {
	unlink $outFile;
    }

    my $OFH = FileHandle->new($outFile, ">>") or die "Can't open file for write: $!, $outFile\n";

    print $OFH ",,,*************** BUGS SUMMARY REPORT BY CATEGORIES *************** \n";
    my $now = "";
    $now = gmctime();
    $varStr = sprintf(",,,Timestamp is in \(UTC\) \: %s \n\n", $now);
    print $OFH $varStr;
    
    foreach $cat (sort keys %{$hashRef})  #sort keys
    {
	print $OFH  "$cat:{\n";  #Start of category printout
	
	if($cat ne "totalDefects") 
	{
	    for $catField (sort keys %{$hashRef->{$cat}})  #sort keys	
	    {
		if ($catField =~ /^\bBugs\b$/i)
		{
		    print $OFH ",Bugs:{\n";  #Bugs ID section for each cats
		    if ($userInput{bugID})   #Only process if user set bugID option to true
		    {
               #	foreach $bugID ( sort keys %{$hashRef->{$cat}{$catField}}) 
			foreach $bugID ( sort keys %{$hashRef->{$cat}{$catField}}) 
			{
			    $value = $hashRef->{$cat}{$catField}{$bugID};
			    $value =~ s/","//g;  #Get rid of commas in message so they do not Screw up our CSV output
			#printf ("VALUE is:%s\n", $value);
			    my $varStr = sprintf(",,%s,%s \n", $bugID, $value);
			    print $OFH $varStr;
			}
		    }
		    print $OFH ",}\n";   #End of Bugs ID section
		}
		else  # (($catField !~ /^\bBugs\b$/i) && ($catField != 0))
		{   #Print out Counts & Percentage for each category section
		    if (defined($hashRef->{$cat}{$catField}))
		    {
			$varStr = "";
			if ($catField eq "Count_Auto_Bugs")
			{
			    $varStr = sprintf("%s,%d \n", $catField,$hashRef->{$cat}{$catField});
			}
			elsif ($catField eq "Count_Manual_Bugs")
			{	
			    $varStr = sprintf("%s,%d \n", $catField,$hashRef->{$cat}{$catField});
			}
			elsif ($catField eq "Count")
			{
			    $varStr = sprintf("%s,%s \n", $catField,$hashRef->{$cat}{$catField});
			}
			elsif ($catField eq "Percentage")
			{	
			    $varStr = sprintf("%s,%3.2f, %s  \n", $catField,$hashRef->{$cat}{$catField},"\%");
			}
			else
			{
			   next;  #Just to handle garbage...
			}
			print $OFH $varStr;
		    }
		   # else { next;}
		}
		#else { next; }
	    }#for
	}
	else
	{
	    next;  #Skip total defects for now.
	}
	#print $OFH "}\n\n";
    }#foreach
    print $OFH "}\n\n";

$varStr = sprintf("Total Bugs Count is: %d \n", $hashRef->{totalDefects});
print $OFH $varStr;

#Get total not found/not categorized
my $foundCount = countTotalCategorized(\%foundNotFound); #$foundHashRef);
$varStr = sprintf("Total Categorized Bugs Count is: %d \n",  $foundCount);
print $OFH $varStr;

my $notFoundCount = $hashRef->{totalDefects} - $foundCount;
$varStr = sprintf("Total NOT Categorized Bugs Count is: %d \n",  $notFoundCount);
print $OFH $varStr;

$varStr = sprintf("The following bugs were not categorized into any bins: \n\n");
print $OFH $varStr;


#Print out to file the Hash Array structure for Not Found
foreach (sort keys %$foundHashRef)
{
    if($foundHashRef->{$_}[0] == 0)
    {
	$varStr = sprintf(",,%d,%s \n", $_,$foundHashRef->{$_}[1]);
	print $OFH $varStr;
    }
}

reportNonCategorized($OFH, \%foundNotFound);

close($OFH); 

}
##################################################################################
#
sub countTotalCategorized
{
    my ($foundHashRef) = shift @_;
    my $count = 0;
    printf "Inside Count Total Cat\n";
    #my $bugID = 0;
    foreach  (sort keys %$foundHashRef)
    {
       if ($foundHashRef->{$_}[0] != 0)
       {
	   $count++;
       }
    }
    return $count;
}

##################################################################################
#Works, use it as guide for proper syntax
sub loadHashArray 
{
    my $cat = shift;  #Key for category
    my $arrayRef = shift; #Ref to rest of array for this bug
    my $hashRef = shift @_; #Ref to hash.

    $hashRef->{$cat}{Bugs}{@$arrayRef[2]} =  @$arrayRef[4];   #Bugs ID and Description
    $hashRef->{$cat}{Count} = (defined( $hashRef->{$cat}{Count}) ? ++($hashRef->{$cat}{Count}) : 1);  #Bugs Count
    $hashRef->{$cat}{Percentage}= (defined( $hashRef->{$cat}{Percentage}) ?($hashRef->{$cat}{Count}) /($hashRef->{totalDefects}): 0.00);   #Bugs Percentage
    
}

##################################################################################
#Works, use it as guide for proper syntax
sub printHashArray 
{
    my ($hashRef) = shift @_;
    my ($cat, $catField) = ""; 
    my ($bugID, $value) = 0;

    foreach $cat (sort keys %{$hashRef})  #sort keys
    {
	print "$cat:{\n";
	
	if($cat ne "totalDefects") 
	{
	    #   for $catField (sort keys %{$hashRef->{$cat}})  #sort keys	
	    for $catField (sort keys %{$hashRef->{$cat}})  #sort keys	
	    {
		if ($catField =~ /^\bBugs\b$/i)
		{
		    if ($userInput{bugID})   #Only process if user set bugID option to true
		    {
			print "\tBugs:{\n";
			foreach $bugID ( sort keys %{$hashRef->{$cat}{$catField}}) 
			{
			    $value= $hashRef->{$cat}{$catField}{$bugID};
			    printf ( "\t\tID=>value are: %s = %s \n", $bugID, $value);
			}
		    }
		    print "\t}\n";
		}
		else
		{
		    if (defined($hashRef->{$cat}{$catField}))
		    {
			printf ("\t\t%s=%3.2f\n", $catField,$hashRef->{$cat}{$catField});
		    }
		}#Else
	    }#for
	    
	}
	else
	{
	    next;  #Skip total defects for now.
	}
    }#foreach
    print "}\n";
}

##################################################################################
#Call updates only once all defects have been process to up-todate correct Percentiles
sub updateCategoriesPercentiles
{
    my $hashRef = shift @_;

    my $totalDefects = $hashRef->{totalDefects};  #Get global defects count

    my $cat = "";
    foreach $cat (keys %{$hashRef})
    {
	next if ($cat eq "totalDefects");  #Skip if not hashes
        $hashRef->{$cat}{Percentage}= (100 * (($hashRef->{$cat}{Count}) /$hashRef->{totalDefects}));   #Bugs Percentage
    }
}

##################################################################################
#Calculate Automation bugs or manual bugs per categories and update the fields accordingly
sub calAutoManual
{
    my ($hashRef) = shift @_;
    my ($cat, $catField, $bugID, $test) = "";
    my ($autoBCount, $manBCount) = 0; #Auto and Manual bug accumulator 

    foreach $cat (sort keys %{$hashRef})  #sort keys
    {
	if($cat ne "totalDefects")   #Must be the test categories if not totalDefects.
	{
	    #   for $catField (sort keys %{$hashRef->{$cat}})  #sort keys	
	    for $catField (sort keys %{$hashRef->{$cat}})  #sort keys	
	    {
		if ($catField =~ /Bugs\b$/i)
		{
		    foreach $bugID ( sort keys %{$hashRef->{$cat}{$catField}}) 
		    {
			$test= lc($hashRef->{$cat}{$catField}{$bugID});
		        if ( $test =~ m/^.*automation.*/i)
			{
			    $autoBCount++;
			}
		    }
		    #Calculate and update hash fields with Auto & Manual counts for each categories
		    $hashRef->{$cat}{Count_Auto_Bugs} = $autoBCount;
		    $manBCount =  $hashRef->{$cat}{Count} - $autoBCount;
		    $hashRef->{$cat}{Count_Manual_Bugs} = $manBCount;
		}
	    }
	
	#Reset counters for Auto and Manual
	$autoBCount = 0;
	$manBCount = 0;	
	}
	else
	{ next;}
    }#foreach cat
}

##################################################################################
sub reportNonCategorized
{
    my $FilePointer = shift (@_);
    my $hashRef = shift @_;

    my ($nonCatCount, $bugID, $autoBCount, $manBCount) = 0;
    my ($varStr, $test) = "";
 
   # $nonCatCount = keys(%{$hashRef});  #Size of hash, otherwise the number of defects not categorized

    $nonCatCount = $hashRef->{Count};

    $varStr = sprintf("Count,%d\n", $nonCatCount);
    print $FilePointer $varStr;

    foreach $bugID ( sort keys %{$hashRef}) 
    {
	$test= lc($hashRef->{$bugID}[1]);
	if ( $test =~ m/^.*automation.*/i)
	{
	    $autoBCount++;
	}
    }
    #Calculate and update hash fields with Auto & Manual counts for each categories
    $manBCount =  $nonCatCount - $autoBCount;

    $varStr = sprintf("Count_Auto_Bugs,%d\n",$autoBCount);
    print $FilePointer $varStr;


    $varStr = sprintf("Count_Manual_Bugs,%d\n", $manBCount);
    print $FilePointer $varStr;
   
}

##################################################################################
}; #End of Eval!

if ($@) 
{
   printf("The following errors were not handled in the usual sense: $@!\n");
}
##################################################################################
1;
__END__


=head1 NAME
BugsSummaryReporting is used to verify if the dut is reacheable after reboot applied

=head1 SYNOPSIS

=over

=item B<BugsSummaryReporting>
[B<-help|-h>]
[B<-man>]
[B<-b>] I<print Bug ID with Categories 1|0>]
[B<-f>] I<input file to read in csv for parsing>]
[B<-o> I<output file to save file >]
[B<-l> I<log file directory>]
[B<-t> I<timeout>]
[B<-d> I<target address>]


=back

=head1 OPTIONS AND ARGUMENTS

=over

=item B<-f>

Input file from Bug SpreadSheet saved as *.csv file

=item B<-b>

List Bug IDs with each categories


=item B<-s>

Show list of Bug IDs Report to Screen

=item B<-o>

Output file where the output will be stored

=item B<-l >

Redirect stdout to the /path/checkdut.log


=item B<-t >

Set timeout in seconds for each command ( default = 300 seconds)

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-x>

Set debug to different level . ( more debug messages with higher number)



=back


=head1 EXAMPLES

=over

1. Typical usage: perl BugsSummaryReporting.pl -f automation_coverage_JKN.csv -b 1 -s 1 -o testModOut5.csv

=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joseph K. Nguyen, MBA  E<lt>jnguyen_95127@yahoo.comE<gt>

=cut
