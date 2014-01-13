#!/usr/bin/perl -w
#--------------------------------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to convert a csv to xls file 
#
#-------------------------------------------------------
use strict;
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
 
sub convertToXls{
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
    $outFn = $outFn."\.xls";
    $userInput{outputfile} = $outFn;
}

($rc,$msg)=convertToXls(\%userInput);
print $msg."\n";
exit 0 if ($rc == $PASS ) ;
exit 1;

=head1 NAME

csv2xls.pl - used to create convert a csv to xls file

=head1 SYNOPSIS

=over

=item B<csv2xls.pl>
[B<-help|-h>]
[B<-man>]
[B<-f> I< csv  file>]
[B<-l> I<log file directory>]
[B<-s> I<separator>]

=back

=head1 OPTIONS AND ARGUMENTS

=over

=item B<-f>

CSV input File 

=item B<-l >

Redirect stdout to the /path/xmlxxx.log

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-x>

Set debug to different level . ( more debug messages with higher number)

=item B<-s>

Change the separator ( used as column for xls ) -- default set to ";" 


=back

=head1 EXAMPLES

=over

1. This command is used to convert a csv file  and output was saved to test123.xls 
    csv2xls.pl -f result.csv -o test123.xls 

2. This command is used to convert a csv file  and output was saved to /tmp/test123.xls 
    csv2xls.pl -f result.csv -o test123.xls  -l /tmp

=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut
