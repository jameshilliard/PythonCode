#!/usr/bin/perl -w
#--------------------------------------------------------
#Name: Tong
#Description: 
# This script is used to convert a txt to xls file 
#
#-------------------------------------------------------
#use strict;
use warnings;
use diagnostics;
use Expect;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use Log::Log4perl;
use XML::Simple;
use Data::Dumper;
use Spreadsheet::WriteExcel;
my $PASS=1;
my $FAIL=0;
my $NOTDEFINED="notdefined";
my @junk = split( /\//, $0);
my $scriptFn = $junk[0];
my %userInput = ( "debug"=>0,
		  "scriptname"=>$scriptFn,
		  "logdir"=>$NOTDEFINED,
		  "filename"=>$NOTDEFINED,		  
		  "outputfile"=>$NOTDEFINED,
		  "separator"=>";",
		  "logger"=>$NOTDEFINED,
		  "screenOff"=> 0,
		  "logOff"=> 1,
		  "reindex"=>0,
		  "indexincr"=>1,
		  "summary"=>0,
		  "noexecution"=>0,

    );
 
#***********************************************************************************
sub init_testcaseCSV(); {
    my $testcaseCSV = "testcase.csv";
    if ( -e $testcaseCSV) {
	$rc = `rm -f $testcaseCSV`;
    } else {
	$rc = `touch $testcaseCSV`;
    }
    my $resHdr = "Num ; Test Case ID ; Test Case Name ; Priority ; Firmware ; Result ; Bug ID ; Notes ; ";
    $rc = `echo \"Test Suite Title= \" > $testcaseCSV`;
    $rc = `echo \"$resHdr\" >> $testcaseCSV`;
    
}

#***********************************************************************************
sub getName {
    my ($path,$junk)=@_;
    my @temp = split(":",$path);
    $junk = $temp[$#temp];
    $junk =~ s/\;/./;
    $junk =~ s/\s+//;
    chomp $junk;
    return $junk;
}



#***********************************************************************************
sub convert2Cvs {

    my ($profFile,$junl) =@_;
    my $rc = $PASS;

    my $inputfile=$profFile->{filename};
    my $outputfile=$profFile->{logdir}."/".$profFile->{outputfile};
    my $msg="Successfully convert $inputfile to $outputfile";

    my $testcase_ID = "ID";
    my $testcase_name ="name";
    my $test_priority = "priority";
    my @temp;

    open (TestcaseFile,$inputfile) || die "can't open ",$inputfile," file:$!";
    open (FileCSV,">>testcase.csv") || die "can't open testcase.csv file:$!";

    $count = 0;


     while ( <TestcaseFile> ) {  
	 $read_line = $_;
#         chomp $read_line;

	 if ($read_line =~ /^Test Case ID:./){
                   $count++;
 #                  $testcase_ID = getName($read_line)."$count";
                 $testcase_ID = getName($read_line);
		print "===",$testcase_ID,"====\n";
	 } elsif ($read_line =~ /^Test Case Name:./) {
                       $testcase_name = getName($read_line); 
         } elsif (index($read_line,"Priority") == 0 ) {
			$test_priority = getName($read_line);
		       $msgRes= "$count".";".$testcase_ID.";".$testcase_name.";".$test_priority;
		       print "-----",$msgRes,"---------\n";
 	               print FileCSV `echo \"$msgRes\"`;

	 }
    }
   print FileCSV `echo "\n\n"`;
   close (TestcaseFile) || die "couldn't close testcase file: $!";
   return ($rc,$msg);
}

#***********************************************************************************
sub convert2Xls{
    my ($profFile,$junl) =@_;
    my $rc = $PASS;

    my $inputfile=$profFile->{filename};
    my $outputfile=$profFile->{logdir}."/".$profFile->{outputfile};
    my $msg="Successfully convert $inputfile to $outputfile";
    my $workbook  = Spreadsheet::WriteExcel->new($outputfile);
    my $worksheet = $workbook->add_worksheet("testcase");
    $worksheet->set_column(0,0,18);
    $worksheet->set_column(1,0,25);
    $worksheet->set_column(2,0,25);
    my $format_red=$workbook->add_format;
    $format_red->set_color('red');
    $format_red->set_border();
    my $format_blue=$workbook->add_format;
    $format_blue->set_color('blue');
    $format_blue->set_border;
    my $format_bold=$workbook->add_format;
    $format_bold->set_bold();
    $format_bold->set_border();
    my $format_norm=$workbook->add_format;
    $format_norm->set_border();
    my $separator=$profFile->{separator};
    my $row=0;
    my @f;
    my $dataFormat;
    open(CSV, $inputfile ) or die "Could not open CSV $inputfile: $!\n";
    my $start = 0;
    while(<CSV>) {
	@f=split/$separator/;
	if ( $start  == 0 ) {
	    $dataFormat = $format_bold;
	}
	for(my $col=0; $col<=$#f; $col++) {
	    $dataFormat=$format_red if ( $f[$col]=~ /FAIL/i) ;
	    $dataFormat=$format_blue if ($f[$col]=~ /pass/i);
	    $worksheet->write($row,$col,$f[$col],$dataFormat);
	    $dataFormat = $format_norm if ( $start == 1 );
	}
	$start = 1;
	$row++;
	$dataFormat=$format_norm;
    }
    close(CSV);
    return ($rc,$msg);
}
#-------------------------------------------
# Get Base name excluding directory path
#-------------------------------------------
sub getBaseName{
    my ($path,$junk) = @_;
    my @t1;
    @t1=split("/",$path );
    $junk = $t1[$#t1];
    return ($junk);
}

#-----------------
#main
#------------------
my ($rc,$msg,$option_h,$option_man,$temp);
my @commands;
$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man,
		  "l=s"=>\$userInput{logdir},		  
		  "f=s"=>\$userInput{filename},  
		  "s=s"=>\$userInput{separator},		  
		  "o=s"=>\$userInput{outputfile},		  
		  "v=s"=>sub { if ( exists $commands[0] ) { push (@commands,$_[1]); } else {$commands[0]=$_[1]; } } ,
		  );

#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);
my $dir = $userInput{logdir};
if ( $dir =~ $NOTDEFINED ) {
    $dir=`pwd`;
    $dir=~ s/\n//;
    $userInput{logdir} = $dir;
    printf ( "DIR = $dir \n");
}
my $fn = $userInput{filename};
if ( ($fn =~ /$NOTDEFINED/ ) ) {
    print ( "Error = please fill in the missing operand = filename($fn)");
    pod2usage(1);
    exit 1;
}
my $outFn = $userInput{outputfile};
if ( ($outFn =~ /$NOTDEFINED/ ) ) {
    $temp=getBaseName($fn);
    ($outFn,$junk[0]) = split ('\.',$temp);
    $outFn = $outFn."\.txt";
    $userInput{outputfile} = $outFn;
}

($rc,$msg)=convert2Cvs(\%userInput);

$userInput{filename} = "testcase.csv";
$outFn =~ s/.txt//;
$outFn = $outFn."\.xls";
$userInput{outputfile} = $outFn;
($rc,$msg)=convert2Xls(\%userInput);
print $msg."\n";
exit 0 if ($rc == $PASS ) ;
exit 1;

=head1 NAME

csv2xls.pl - used to create convert a csv to xls file

=head1 SYNOPSIS

=over







