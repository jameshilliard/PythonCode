#!/usr/bin/perl -w
#--------------------------------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to generate testcase extracted from xml testcase description and reindex the testcase step 
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
my $PASS=1;
my $FAIL=0;
my $NOPATH="noPathGiven";
my $NOTDEFINED="notdefined";
my @junk = split( /\//, $0);
@junk = split( '\.',$junk[$#junk]);
my $scriptFn = $junk[0];
my %userInput = ( "debug"=>0,
		  "logdir"=>$NOTDEFINED,
		  "filename"=>$NOTDEFINED,		  
		  "outputfile"=>$NOTDEFINED,
		  "logger"=>$NOTDEFINED,
		  "screenOff"=> 0,
		  "logOff"=> 1,
		  "reindex"=>0,
		  "indexincr"=>1,
		  "summary"=>0,
		  "noexecution"=>0,
		  "scriptname"=>$scriptFn,
		  "testsetup"=>"\tPlease see the setup Section\n",
		  "testexec"=>"\tThe test execution is described in the following step(s):\n",
		  "expectresult"=>"\tAny failure detected during the test execution renders the test failed\n",
		  "testheader"=>"Deprecated: 0\nTest Type: Functional\nAutomatable: 1\nTest Description:\n",
    );
#---------------------------------------------------------
# This routine is used to initialize the log feature
#---------------------------------------------------------
sub initLogger {
    my ( $profFile, $junk) = @_;
    my $rc = $PASS;
    my $msg ="Successfully Set Logger";
    #--------------------
    # initialize logger
    #---------------------
    my $temp = $profFile->{scriptname};
    my $localLog = $profFile->{logdir}."/$temp.log";
    my $clobberLog = $profFile->{logdir}."/$temp\_clobber.log";
    if ( -e $localLog ) {
	$temp = `rm -f $localLog`;
    }
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

#************************************************************

#************************************************************

sub getBaseName {
    my ($path,$junk)=@_;
    my @temp = split("/",$path);
    $junk = $temp[$#temp];
    return $junk;
}
#
sub generateoutput {
    my ($profFile,$inputFile,$tc_index)=@_;
    my $rc=$PASS;
    my $msg;
    my $FN=$profFile->{resultFN};
    my $xml = new XML::Simple;
    my $log = $profFile->{logger};
#    my $inputFile = $profFile->{filename};
    my $testSetup = $profFile->{testsetup};
    my $testExec = $profFile->{testexec};
    my $expectResult = $profFile->{expectresult};
    my $testheader = $profFile->{testheader};
    my @buff=();
    my $reIndex= $profFile->{reindex};
    my $indexIncr= $profFile->{indexincr};
    my ($key,$count);
    @buff= split("/",$inputFile);
    my $data;
    my ($result,$temp,$msg2);
    #read in xml file 
    $log->info( " --------- Parsing $inputFile    ------------ " ); # if ($profFile->{debug} > 2 );
    if ( $profFile->{debug} < 5 ) { 
	eval { $data = $xml->XMLin("$inputFile") };
    } else {
	$data = $xml->XMLin("$inputFile");
    }
    if ( !defined $data ) {
	$log->info( " --------- PLEASE READ WARNING BAD XML    ------------ " );
	$msg = `xmllint $inputFile`;
	$msg = "Error:\n".$msg;
	return ($FAIL,$msg);
    }

    if ( $reIndex ) {
	($rc,$msg2) = reindexStep ($profFile,$inputFile,$indexIncr);
	($rc,$msg2) = beautifyXML ($profFile,$inputFile);
    }
    $temp = Dumper($data);
    $log->info($temp)  if ($profFile->{debug} > 2 );
#    $msg= "$buff[$#buff]\n";
    if ( $profFile->{summary} == 1) {
	$msg =$tc_index.";".$data->{emaildesc}.";".$data->{name}.";";
	print $FN $msg;
	$msg = "Succefully generate test case docs to $profFile->{outputfile}";
	return ( $PASS,$msg);
    }
    if ( $profFile->{summary} == 2) {
	# item| description| Firmware | Result | Comments | Tester | Date
	$msg =$data->{name}.";".$data->{description}.";".";".";".";".";";
	print $FN $msg;
	$msg = "Succefully generate test case docs to $profFile->{outputfile}";
	return ( $PASS,$msg);
    }
    if ( $profFile->{summary} == 3) {
	# item| description| Firmware | Result | Comments | Tester | Date
	$msg =$data->{name}.";".$data->{emaildesc}.";".";".";".";".";";
	print $FN $msg;
	$msg = "Succefully generate test case docs to $profFile->{outputfile}";
	return ( $PASS,$msg);
    }


    if ( $profFile->{noexecution} ) {
	$msg ="Testcase name: ".$data->{name}."\n";
	print $FN $msg;
	#Get Description:
	$msg = $data->{description}."\n";
	print $FN  $msg;
	$msg = "Succefully generate test case docs to $profFile->{outputfile}";
	return ( $PASS,$msg);
    }
    $msg ="Testcase name: ".$data->{name}."\n";
    $msg .="Title: ".$data->{emaildesc}."\n";
    $msg .=$testheader;

    print $FN $msg;
    #Get Description:
    $msg = $data->{description}."\n";
    $msg.="Initial Environment:\n".$testSetup;
    $msg.="Test Execution:\n";
    $msg.=$testExec;
    #read in all descriptions of each step 
    $count = 0;
    if ( !defined ( $data->{stage}{step}{name} ) ) {
	foreach $key ( sort {$a<=>$b} keys %{$data->{stage}{step}}) {
	    $count++;
	    $temp = $data->{stage}{step} {$key} {desc};
	    $msg .= "\t$count\. $temp\n";
	}
    } else {
	    $count++;
	    $temp = $data->{stage}{step} {desc};
	    $msg .= "\t$count\. $temp\n";
    }
    if ( defined ($data->{expectedresult}) ) {
	$msg.="Expected Result:\n".$data->{expectedresult};
    } else {
	$msg.="Expected Result:\n".$expectResult;
    }
    print $FN  $msg;
    $msg = "Succefully generate test case docs to $profFile->{outputfile}";
    return ( $PASS,$msg);
}
sub generateOUTPUTS {
    my ($profFile,$inputFile)=@_;
    my $rc=$PASS;
    my $msg;
    my $line;
    my @buff;
    my $count=1;
    my $log = $profFile->{logger};
    printf ("$inputFile\n");
    my $FN=$profFile->{resultFN};
    my $cmd ="ls -1X $inputFile";
    $line=`$cmd`;
    
    $log->info ("cmd\n$line\n") if ( $profFile->{debug} > 1 );
    @buff=split("\n",$line);
    foreach $line ( @buff ) {
	$line=~ s/\n//;
	($rc,$msg)= generateoutput($profFile,$line,$count);
	printf $FN "\n";
	$count++;
    }
    $msg = "Succefully generate test case docs to $profFile->{outputfile}";
    return($PASS,$msg);
}
#************************************************************
#  This routine is used to reindex xml file  
#************************************************************
sub reindexStep {
    my ($profFile,$inputFile,$stepIncr)=@_;
    my $rc=$PASS;
    my $msg="Successfully reindex $inputFile";
    my $json;
    my @buff;
    my $pStruct;
    my $count =0;
    my $line;
    my $stepIndex;
    my $start;
    my $cmd;
    my $log = $profFile->{logger};
    my $type=$profFile->{type};
    my $tempFile = $inputFile."\.temp";
    open(INPUT, "< $inputFile" ) or die " Could not read $inputFile";
    open(TEMPFD, "> $tempFile" ) or die " Could not write $tempFile";
    @buff=<INPUT>;
    close INPUT;
    $start = 0;
    $stepIndex = 0;

    for ( $count=0 ; $count <= $#buff; $count ++ ) {
	$line = $buff[$count];
	if ($line =~ /^\s*$/ ) {
#	    print TEMPFD $line;
	    next;
	}
	if ( $start == 0 ) {
	    if ( $line =~ /\<step\>/ ) {
		$start = 1;
		$log->info("$start -- $line ") if ( $profFile->{debug} > 5 );
	    }
	    $log->info("$count:$line" ) if ( $profFile->{debug} > 5 );
	    print TEMPFD $line;
	    next;
	}
	$log->info("##$count:$line" ) if ( $profFile->{debug} > 5 );
	if ( $line =~ /\<\/step\>/ ) {
	    $start = 0;
	    $log->info("$start -- $line" ) if ( $profFile->{debug} > 5 );
	    print TEMPFD $line;

	    next;
	}
	if ( $start < 2 ) {
	    if ( $line=~ /<name>/ ) {
		$start++;
		if ( $line =~ /\<\/name\>/ ) {
		    # replace the step index ??
		    $start++;
		    $log->info("$start -- $line" ) if ( $profFile->{debug} > 5 );
            $line =~ /<name>(\d+)<\/name>/;
		    $line="<name>".$stepIndex."<\/name>\n" if ($1<1000);
		    $stepIndex += $stepIncr;


		} else {
		    if ( $line=~ /[0-9]/ ) {
			# replace the step index ??	
			$log->info("$start -- $line" ) if ( $profFile->{debug} > 5 );
			$line="<name>".$stepIndex;
			$stepIndex += $stepIncr;
		    }
		}
	    }
	    $log->info("$start -- $line" ) if ( $profFile->{debug} > 5 );
	    print TEMPFD $line;
	    next;
	}
	if ( $start == 2 ) {
	    if ( $line =~ /<\/name>/ ) {
		$start++;
		# replace the step index ??
		$log->info("$start -- $line" ) if ( $profFile->{debug} > 5 );
		$line = $stepIndex."<\/name>\n";
		$stepIndex += $stepIncr;
	    } else {
		# replace the step index ??
		$log->info("$start -- $line" ) if ( $profFile->{debug} > 5 );
		$line = $stepIndex;
		$stepIndex += $stepIncr;
	    }
	    $log->info("$start -- $line" ) if ( $profFile->{debug} > 5 );
	    print TEMPFD $line;
	    next;
	}
	if ( $start > 2 ) {
	    print TEMPFD $line;
	    if ( $line =~ /<\/name>/ ) {
		$start++;
	    } 
	    next;
	}
    }
    close TEMPFD;
    $cmd = "mv $tempFile $inputFile";
    $rc = `$cmd`;
    $msg= " Successfully reindex $inputFile ";
    if ( $profFile->{debug} < 1 ) {
	#remove temp file 
	$rc = `rm -f $tempFile`;
    }
    return($PASS,$msg);
}

#********************************************************************
#  This routine is used to beautify xml file 
#*******************************************************************
sub beautifyXML {
    my ($profFile,$inputFile)=@_;
    my $rc=$PASS;
    my $msg="Successfully Parsing Json Header";
    my $json;
    my @buff;
    my $pStruct;
    my $log = $profFile->{logger};
    my $count =0;
    my $line;
    my ($t1,$t2);
    my ($temp,$cmd);
    my $tempFile = $inputFile."\.temp";
    open(INPUT, "< $inputFile" ) or die " Could not read $inputFile";
    open(TEMPFD, "> $tempFile" ) or die " Could not write $tempFile";
    @buff=<INPUT>;
    close INPUT;
    my $indent = -1;
    for ( $count=0 ; $count <= $#buff; $count ++ ) {
	$line = $buff[$count];
	if ($line =~ /^\s*$/ ) {
	    print TEMPFD $line;
	    next;
	}
	if ( $line =~ /<[^\/]*>/ ) {
	    $indent++;
	    $log->info(" \[$count\] $indent -- $line ") if ( $profFile->{debug} > 5 );
	    $temp = "    "x$indent;
	    $t1= index ($line,"<");
	    if ( $t1 > -1 ) {
		$line=substr($line,$t1);
	    }
	    print TEMPFD $temp.$line;
	    $indent-- if ( $line =~ /<\/.*>/ ) ;
	    next;
	}
	if ( $line =~ /<\/.*>/ ) {
	    $log->info(" \[$count\] $indent -- $line ") if ( $profFile->{debug} > 5 );
	    $temp = "    "x$indent;
	    $t1= index ($line,"<");
	    if ( $t1 > -1 ) {
		$line=substr($line,$t1);
	    }
	    print TEMPFD $temp.$line;
	    $indent--;
	    next;
	}
	    $log->info("==> \[$count\] $indent -- $line ") if ( $profFile->{debug} > 5 );

	$temp = "    "x$indent;
    $temp = "    ".$temp;
    $line =~ s/^\s*//;
	print TEMPFD $temp.$line;
    }
    close TEMPFD;
    $cmd = "mv $tempFile $inputFile";
    $rc = `$cmd`;
    $msg= " Successfully indent $inputFile ";
    if ( $profFile->{debug} < 1 ) {
	#remove temp file 
	$rc = `rm -f $tempFile`;
    }
    return($PASS,$msg);
}


#************************************************************
# Main Routine
#************************************************************
MAIN:
my @buff;
my ($x,$h);
my $option_h;
my $option_man = 0;
my $rc = 0;
my $msg;
my $key;
my $current;
my $limit;
my ($index,$temp);
my $example = "Example: ";
my $usage="Usage: generate testcase documents.txt  \n\t\tgenerate_tcdocs.pl -f <filename> -o <optional filename> -l <directory where new files will be saved>";
my @commands = ();

$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man,
		  "cd"=>sub { $userInput{summary}=2 },		  
		  "cm"=>sub { $userInput{summary}=3 },		  
		  "l=s"=>\$userInput{logdir},		  
		  "f=s"=>\$userInput{filename},		  
		  "n"=>\$userInput{noexecution},		  
		  "o=s"=>\$userInput{outputfile},		  
		  "d"=>\$userInput{display},
		  "r"=>\$userInput{reindex},
		  "t"=>sub { $userInput{summary} = 1 },
		  "s=s"=>\$userInput{indexincr},
		  "z"=>sub { $userInput{logOff} = 0 },
		  "w"=>\$userInput{wildcard},
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
($rc,$msg) = initLogger(\%userInput, 0);
if ( $rc != 1) {
    printf ("RC$rc $msg\n");
    exit 1;
} 
my $fn = $userInput{filename};
my $outputfile = $userInput{outputfile};

if ( ($fn =~ /$NOTDEFINED/ ) ) {

   $userInput{logger}->info( "Error = please fill in the missing operand = filename($fn)");
    pod2usage(1);
    exit 1;
}


#check file is wild card
@buff = split ('/',$fn);
$temp = getBaseName($fn);
$userInput{logger}->info( "Input file = $temp -- $fn");
if ( $temp =~ /\*/ )  {
    $userInput{wildcard}=1;
#    $userInput{logger}->info( "Generate Doc from wild card testcases ");
}



if ( ! $userInput{wildcard} ) {
    $fn = `ls $fn`;
    $fn =~ s/\n//;
    if ( $fn =~ /No such/ ) {
	$fn = $userInput{filename};
	$userInput{logger}->info( "Error = $fn file is not found "); 
	pod2usage(1);
	exit 1;
    }
    $userInput{logger}->info( " file = $fn \n ");
    $userInput{filename} = $fn;
    if ( $outputfile =~ /$NOTDEFINED/ ) {
	$temp = $buff[$#buff];
	$temp=~ s/\./_/g;
	$outputfile = $dir."/$temp\.txt";
	$userInput{outputfile} = $outputfile;
    }
} else {
    if ( $outputfile =~ /$NOTDEFINED/ ) {
	$temp = $buff[$#buff];
	$temp=~ s/\*/_buck_/g;
	$outputfile = $dir."/$temp\.txt";
	$userInput{outputfile} = $outputfile;
    }
}
if ( $userInput {wildcard} ) {   
    $userInput{logger}->info( "Generate Doc from wild card testcases ");
    open(FD,">$outputfile") or die " could not create $outputfile";
    $userInput{resultFN}=*FD;
    if ( $userInput{summary} == 1) {
	$msg ="Index;Description;TestCases\n";
	print FD $msg;
    }
    if (( $userInput{summary} == 2) || ( $userInput{summary} == 3)) {
	# item| description| Firmware | Result | Comments | Tester | Date
	$msg =" Item ; Description ; Firmware ; Result ; Comments ; Tester ; Date\n";
	print FD $msg;
    }

    ($rc,$msg)=generateOUTPUTS(\%userInput,$userInput{filename});

} else {
    open(FD,">$outputfile") or die " could not create $outputfile";
    $userInput{resultFN}=*FD;
    if ( $userInput{summary} == 1) {
	$msg ="Index;Description;TestCases\n";
	print FD $msg;
    }
    if (( $userInput{summary} == 2) || ( $userInput{summary} == 3)) {
	# item| description| Firmware | Result | Comments | Tester | Date
	$msg =" Item ; Description ; Firmware ; Result ; Comments ; Tester ; Date\n";
	print FD $msg;
    }
    ($rc,$msg)=generateoutput(\%userInput,$userInput{filename},1);
}
close FD;
$userInput{logger}->info($msg);
if ($userInput{display}) {
    $msg = `cat $userInput{outputfile}`;
    $userInput{logger}->info($msg);
}
exit 0 if ($rc == $PASS ) ;
exit 1;
1;

=head1 NAME

generate_tcdocs.pl - used to create a docs file from xml. 

=head1 SYNOPSIS

=over

=item B<generate_tcdocs.pl>
[B<-help|-h>]
[B<-man>]
[B<-f> I< XML file>]
[B<-l> I<log file directory>]
[B<-n> I<no execution section>]
[B<-r> I< reindex all steps >]
[B<-s> I< specified increment step>]
[B<-t> I< generate test summary list>]
[B<-cm> I< generate test summary list as CE lab by using Email field>]
[B<-cd> I< generate test summary list as CE lab by using Description field>]

[B<-ce> I< generate test summary list under ce lab format>]

=back

=head1 OPTIONS AND ARGUMENTS

=over


=item B<-f>

XML File 

=item B<-l >

Redirect stdout to the /path/xmlxxx.log


=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-x>

Set debug to different level . ( more debug messages with higher number)

=item B<-n>

No display of the execution section

=item B<-r>

Reindex all steps

=item B<-s>

Increment all steps. Default is was set to 1

=item B<-t>

Generate Summary Test List in csv

=item B<-cm>

Generate test summary list as CE lab by using Email field

=item B<-cd>

Generate test summary list as CE lab by using Description field


=back


=head1 EXAMPLES

=over

1. This command is used to generate a document file from  an  xml file and 
    output was saved to test123_xml.txt
    generate_tcdocs -f test123.xml

2. This command is used to generate a document file from  an  xml file and display to the screen 
    generate_tcdocs -f test123.xml  -d

3. This command is used to generate a document file from  an  xml file and reindex all steps with increment of 4 
    generate_tcdocs -f test123.xml  -r -s 4




=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut
