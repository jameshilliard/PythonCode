#!/usr/bin/perl -w
#---------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to create testcases from json file
#
#--------------------------------
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
use JSON;
#use JSON::XS;
#use Test::JSON;
#use Config::JSON;


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
		  "scriptname"=>$scriptFn,
		  "first"=>$NOTDEFINED,
		  "second"=>$NOTDEFINED,
		  "type"=>$NOTDEFINED,
		  "tctype"=>$NOTDEFINED,
		  "vz"=>{ "desc"=>[ "<desc>Configure  Dut with", 
				    " json file with type ",
				    "</desc>\n"],
			  "script"=>["<script> ruby  \$U_RUBYBIN/Main.rb \$G_DUMMY -l \$G_CURRENTLOG/result_json.log -f  \$U_TESTPATH/",
				     "-d \$U_DEBUG -p ",
				     "-u \$U_USER -a \$U_PWD -t \$G_PROD_IP_ETH0_0_0 </script>\n"]
		  },
		  "vz2"=>{ "desc"=>["<desc>Configure  Dut with", 
				    "json file  </desc>\n"],
			   "script"=>["<script>ruby  \$U_MI424/configDevice.rb \$G_DUMMY -o \$G_CURRENTLOG/configdevice_rs.log -f  \$U_TESTPATH/",
				      " -d \$U_DEBUG  -u \$U_USER -p \$U_PWD -i \$G_PROD_IP_ETH0_0_0 --generate-test-file \$G_CURRENTLOG/testsystem.json  --override \`ruby -e \'print \"\\\"host=specify:192.168.1.\#\{rand(49)+1\}\\\"\"\'\`</script>"]

		  },
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
 # Get base name 
 #**********************************************************

 sub getBaseName {
     my ($path,$junk)=@_;
     my @temp = split("/",$path);
     $junk = $temp[$#temp];
     return $junk;
 }
 #************************************************************
 # Get base path
 #**********************************************************
 sub getBasePath {
     my ($path,$junk)=@_;
     my @temp = split("/",$path);
     $junk ="";
     for ( my $count=0; $count < $#temp ; $count++) {
	 if ( $count ==0 ) {
	     $junk .= $temp[$count];
	 } else {
	     $junk .= "/".$temp[$count];
	 }
     }
     return $junk;
 }

 #************************************************************
 # The following routine is used to generate test case  
 # 
 #************************************************************
 sub generatetestcase {
     my ($profFile,$inputFile)=@_;
     my $rc=$PASS;
     my $msg;
     my $line;
     my @buff;
     my $outputFile;
     my $pStruct;
     my $basename;
     my $log = $profFile->{logger};
     my ($head,$path) = split("platform",$inputFile);


     my $FN=$profFile->{resultFN};
     # Parse Jason File 
     ($rc,$pStruct) = jsonParsing($profFile,$inputFile);
     if ($rc == $FAIL ) {
	 $msg="Error: $inputFile has bad Jason File -- $pStruct ";
	 return($FAIL,$msg);
     }
     ($rc,$outputFile) = createXmlTestcase($profFile,$pStruct,$inputFile);
     if ($rc == $FAIL ) {
	 $msg="Error: Could not create $outputFile XML file from $inputFile input file";
	 return($FAIL,$msg);
     }
     ($rc,$msg) = checkXmlFormat($profFile,$outputFile);
     if ($rc == $FAIL ) {
	 $msg .= "Error: XML malformed ";
	 return($FAIL,$msg);
     }
     ($rc,$msg) = reindexStep ($profFile,$outputFile);
     if ($rc == $FAIL ) {
	 $msg .= "Error: XML malformed ";
	 return($FAIL,$msg);
     }

     ($rc,$msg) = beautifyXML ($profFile,$outputFile);
     if ($rc == $FAIL ) {
	 $msg .= "Error: XML malformed ";
	 return($FAIL,$msg);
     }

     $msg = "Successfully create:\nXML file: $outputFile \ninput json file: from $inputFile\n"; 
     $basename=getBaseName($outputFile);
     # Get the test directory name 
     # Note that call 2 times to get rid of json directory + filename "
     $path = getBasePath($path);
     $path = getBasePath($path);
     $line = "-tc \$SQAROOT/platform"."$path/tcases/".$basename."\n";
     print $FN "$line";
     return ( $PASS,$msg);
 }
 #************************************************************
 # The following routine is used to generate test case  
 # 
 #************************************************************
 sub generateTESTCASES {
     my ($profFile,$inputFile)=@_;
     my $rc=$PASS;
     my $msg;
     my $msg2;
     my $line;
     my @buff;
     my $log = $profFile->{logger};
     printf ("$inputFile\n");
     my $FN=$profFile->{resultFN};
     my $cmd ="ls -1X $inputFile";
     $line=`$cmd`;

     $log->info ("cmd\n$line\n") if ( $profFile->{debug} > 1 );
     @buff=split("\n",$line);
     foreach $line ( @buff ) {
	 $line=~ s/\n//;
	 ($rc,$msg2)= generatetestcase($profFile,$line);
     }
     $msg = "Succefully generate test cases from  $inputFile \n";
     return($PASS,$msg);
 }
 #********************************************************************
 #  This routine is used to check XML format 
 #*******************************************************************
 sub checkXmlFormat {
     my ($profFile,$inputFile)=@_;
     my $rc=$PASS;
     my $msg="Successfully Checking XML $inputFile Format";
     my $json;
     my @buff;
     my $pStruct;
     my $count =0;
     my $log = $profFile->{logger};
     my $temp;
     my $data;
     my $xml = new XML::Simple;
     my $type=$profFile->{type};
     eval { $data = $xml->XMLin("$inputFile")};
     if ( !defined $data) {
	 $msg =`xmllint $inputFile`;
	 return($FAIL,$msg);
     }
     $temp = Dumper($data);
     $log->info($temp) if ( $profFile->{debug} > 2 );
 #    my $output = $xml->XMLout($data);
 #    open(OUTFD,">$outputFile") or die " could not create $outputFile ";
 #    print OUTFD $output;
 #    close OUTFD;
     return ( $PASS,$msg);
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
 #  This routine is used to reindex xml file  
 #************************************************************
 sub reindexStep {
     my ($profFile,$inputFile)=@_;
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
     my $stepIncr = 2;
     for ( $count=0 ; $count <= $#buff; $count ++ ) {
	 $line = $buff[$count];
	 if ($line =~ /^\s*$/ ) {
	     print TEMPFD $line;
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
		     $line="<name>".$stepIndex."<\/name>\n";
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
 #************************************************************
 #  This routine is used to extract header of the jason file
 #  and generate description for XML test case header
 #************************************************************
 sub createXmlTestcase {
     my ($profFile,$pStruct,$inputFile)=@_;
     my $rc=$PASS;
     my $msg="Successfully Parsing Json Header";
     my $json;
     my @buff;
     my $count =0;
     my $key;
     my $line;
     my $lim;
     my $first = $profFile->{first};
     my $second = $profFile->{second};
     my $entry;
     my $type=$profFile->{type};
     my $log = $profFile->{logger};
     my $baseName= getBaseName($inputFile);
     my $tctype= $profFile->{tctype};
     my ($page,$alias) = split('\.',$baseName);
     $log->info(" ==== > $baseName , $page ,$alias " );  #if ( $profFile->{debug} > 2 );
     
     my $filename ;
     $filename = $page."\.xml";
     if ( $tctype =~ /vz\b/i  ) {
	 $filename = "tc_".$page."\.xml";
     }
     my $orgpage = $page;
     # Need to get the name base of INPUTFILE ????
     my $outputFile = $profFile->{logdir} ."/".$filename;
     if ( !defined $profFile->{$tctype} ) {
	 $msg = " $tctype type is not recognized"; 
	 return($FAIL,$msg);
     }


     open(OUTFN,">$outputFile") or die " could not open file $outputFile ";
     print OUTFN "\<testcase\>\n";
     print OUTFN "<name>$filename</name>\n";


     foreach $key ( keys %{$pStruct} )  {
	 $log->info($key) if ( $profFile->{debug} > 2 );
	 next if ( $key =~ /login/ );
	 next if ( $key =~ /logout/);
	 ($page,$alias) = split ("_",$key);
	 print OUTFN "<emaildesc>Test page \[$orgpage\]: $page -- $alias</emaildesc>\n<description>\n";
	 print OUTFN "The field of $page page was tested with the following data:\n";
	 foreach $entry ( sort keys %{$pStruct->{$key}}) {
	     $line = $pStruct->{$key}{$entry};
	     print OUTFN "\t$entry = $line \n";
	 }
	 last;
     }
     printf OUTFN "</description>\n<id>\n<manual>1234</manual>\n<auto>3456</auto>\n<code>\n</code>\n</id>\n";
     printf OUTFN "<stage>\n";
     #insert first part
     if ( $first !~ /$NOTDEFINED/ ) {
	 open(INPUT, "< $first" ) or die " Could not read $first";
	 @buff=<INPUT>;
	 close INPUT;
	 for ( $count=0 ; $count <= $#buff; $count ++ ) {
	     print OUTFN "$buff[$count]";
	 }
     }
     #insert Main part 
     print OUTFN "<step>\n<name>8</name>\n";


     $line="";
    $lim = @{$profFile->{$tctype}{desc}};
    for ( $count =0; $count < $lim ; $count++) {
	if ( $count == 0)  {
	    $line .= $profFile->{$tctype}{desc}[$count].$filename." ";
	}
	if ( $count == 1)  {
	    $line .= $profFile->{$tctype}{desc}[$count]." ".$type." ";
	}
	if ( $count > 1 ) {
	    $line .= $profFile->{$tctype}{desc}[$count];
	}
    }
    print OUTFN $line;
    $lim = @{$profFile->{$tctype}{script}};
    $line="";
    for ( $count =0; $count < $lim ; $count++) {
	if ( $count == 0)  {
	    $line .= $profFile->{$tctype}{script}[$count].$baseName." ";
	}
	if ( $count == 1)  {
	    $line .= $profFile->{$tctype}{script}[$count]." ".$type." ";
	}
	if ( $count > 1 ) {
	    $line .= $profFile->{$tctype}{script}[$count];
	}

    }
    print OUTFN $line;
#    print OUTFN "<script> ruby  \$U_RUBYBIN/Main.rb \$G_DUMMY -l \$G_CURRENTLOG/result_json.log -f  \$U_TESTPATH/$baseName -d \$U_DEBUG -p $type -u \$U_USER -a \$U_PWD -t \$G_PROD_IP_ETH0_0_0 </script>\n";
    
    print OUTFN "<passed></passed>\n<failed></failed>\n</step>\n";
    #insert second part
    if ( $second !~ /NOTDEFINED/ ) {
	open(INPUT, "< $second" ) or die " Could not read $first";
	@buff=<INPUT>;
	close INPUT;
	for ( $count=0 ; $count <= $#buff; $count ++ ) {
	    print OUTFN "$buff[$count]";
	}
    }
    printf OUTFN "</stage>\n</testcase>\n";
    close OUTFN;
    return($PASS,$outputFile);

}

#************************************************************
#  This routine is used to parse Jason file and return
#  the pointer of the perl structure if parsing is ok
#************************************************************
sub jsonParsing {
    my ($profFile,$inputFile)=@_;
    my $rc=$PASS;
    my $msg="Successfully Parsing Json Header";
    my $json;
    my @buff;
    my $pStruct;
    my $count =0;
    my $log = $profFile->{logger};
    printf ("$inputFile\n");
    my $FN=$profFile->{resultFN};
    $rc = open(JSFD,"<  $inputFile") ;
    if ( $rc != 1 ) { 
	$msg= "could not read  $inputFile";
	 die "could not read  $inputFile" if ( $profFile->{debug} > 4 ) ; # for testing
	return($FAIL,$msg);
    }
    @buff=<JSFD>;
    close JSFD;
    $json = "";
    for ( $count=0; $count <= $#buff; $count ++) {
	if ( $buff[$count] =~ /^\/\/*/  ) {
	    $buff[$count]=~ s/\/\//\#/;
	    $buff[$count]=~ s/\n/" ,"/;
	    next;
	}
	$buff[$count]=~ s/\n//g;
	$buff[$count]=~ s/\r//g;
	$json .=$buff[$count];
    }
    print Dumper($json) if ( $profFile->{debug} > 2 ) ;  
    $json=~ s/,\}/\}/g;
    $pStruct = from_json($json);
    print Dumper($pStruct) if ( $profFile->{debug} > 2 ) ;  
    return($PASS,$pStruct);

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

my @commands = ();

$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man,
		  "p=s"=>\$userInput{tctype},	  
		  "l=s"=>\$userInput{logdir},		  
		  "f=s"=>\$userInput{filename},		  
		  "a=s"=>\$userInput{first},		  
		  "b=s"=>\$userInput{second},		  
		  "o=s"=>\$userInput{outputfile},
		  "d"=>\$userInput{display},
		  "t=s"=>\$userInput{type},
		  "w"=>\$userInput{wildcard},
		  "z"=> sub { $userInput{logOff} = 0 } ,
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
$userInput{logger}->info( "         FILE NAME  -- \[$fn\] \n\n");
my $outputfile = $userInput{outputfile};
my $type = $userInput{type};
if ( $userInput{tctype} =~ /vz\b/i ) {	  
    if ( $type =~ /$NOTDEFINED/ )  {
	$userInput{logger}->info( "Error = please enter type : W ,M ");
	pod2usage(1);
	exit 1;
    }   
}

if ( ($fn =~ /$NOTDEFINED/ ) ) {
   $userInput{logger}->info( "Error = please fill in the missing operand = filename($fn)");
    pod2usage(1);
    exit 1;
}
if ( $userInput{tctype} =~ /$NOTDEFINED/ )  {
    $userInput{logger}->info( "Error = please enter type : vz or vz2 ");
    pod2usage(1);
    exit 1;
}   

$userInput{tctype} = lc $userInput{tctype};



#check file is wild card
$temp = getBaseName($fn);
$userInput{logger}->info( "===> Input file = \[$temp\] -- \[$fn\]");
if ( $temp =~ /\*/ ) {
    $userInput{wildcard}=1;
    $userInput{logger}->info( "Generate testcases  from wild card configuration files ");
}
#create test suite file 
if ( $outputfile =~ /$NOTDEFINED/ ) {
    $temp= "testsuite";
    $outputfile = $dir."/$temp\.tst";
    $userInput{outputfile} = $outputfile;
}

open(FD,">$outputfile") or die " could not create $outputfile";
$userInput{resultFN}=*FD;
if ( $userInput {wildcard} ) {
    $temp = getBaseName($fn);
    ($x,$h)= split('\.',$temp);
    $temp=getBasePath($fn)."/\*\."."$h";    
    $userInput{filename} = $temp;
    $userInput{logger}->info( "===> Input file = \[$temp\] -- \[$fn\]");
    ($rc,$msg)=generateTESTCASES(\%userInput,$userInput{filename});
} else {
    ($rc,$msg)=generatetestcase(\%userInput,$userInput{filename});
}
close FD;
$msg .="and testcase names were saved in $userInput{outputfile}\n";
$userInput{logger}->info($msg);
if ($userInput{display}) {
    $msg ="\n#-----------------\n#Output of $userInput{outputfile}\n#---------------------------\n";
    $msg .= `cat $userInput{outputfile}`;
    $userInput{logger}->info($msg);
}
exit 0 if ($rc == $PASS ) ;
exit 1;
1;

=head1 NAME

jsoncvt.pl - used to create a XML testcase  from json file. 

=head1 SYNOPSIS

=over

=item B<jsoncvt.pl>
[B<-help|-h>]
[B<-man>]
[B<-f> I< jason file>]
[B<-l> I<log file directory>]
[B<-z> I<turn on LOGINFO >]
[B<-o> I<output of testsuite>]
[B<-a> I<first step(s) inserted before configuration step>]
[B<-b> I<step(s) followed after configuration step>]
[B<-w> I<force wildcard files >]

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

=item B<-z >

Turn ON LOG INFO logs

=item B<-o>

Print a brief help message and exit.

=item B<-a>

File contains Step inserted before configuration step ( optional ).

=item B<-b>

File contains Step followed after configuration step ( optional ).

=item B<-w>

Force input as wildcard json file ( THERE IS A BUG -- must be used with bashshell )

=back


=head1 EXAMPLES

=over

1. This command is used to generate a testcase  from  a json file 
    
  #!/bin/bash
  t0=/root/actiontec/automation/platform/1.0/verizon/testcases/bcc/json/03006000456.json 
  t1=/root/actiontec/automation/platform/1.0/verizon/testcases/bcc/tcases/tcheader.xml
  t2=/root/actiontec/automation/platform/1.0/verizon/testcases/bcc/tcases/tctail.xml
  log=/root/actiontec/automation/platform/1.0/verizon/testcases/bcc/tcases
  jsoncvt.pl -x 1 -f $t0 -a $t1 -b $t2 -l $log -t M


1. This command is used to generate testcases from  wildcard json file 
    
  #!/bin/bash
  t0=/root/actiontec/automation/platform/1.0/verizon/testcases/bcc/json/03006000456.json 
  t1=/root/actiontec/automation/platform/1.0/verizon/testcases/bcc/tcases/tcheader.xml
  t2=/root/actiontec/automation/platform/1.0/verizon/testcases/bcc/tcases/tctail.xml
  log=/root/actiontec/automation/platform/1.0/verizon/testcases/bcc/tcases
  jsoncvt.pl -w -x 1 -f $t0 -a $t1 -b $t2 -l $log -t M




 
=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut
