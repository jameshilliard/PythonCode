#!/usr/bin/perl -w
#----------------------------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to submit job remotely  
# Usage: 
# This utility depends on :
# - G_USER=required 
# - G_FTP_SERVERcould be local or any machine  
# - G_DISPATCHER=could be local or any machine  
# - G_FTP_UPLOADDIR = need to create remote dir 
# - G_FTP_USER_PWD = pair of (login,password) for remote ftp 
# - G_DISP_WORKDIR= location where the remote bin is defined
# - G_GETVERSION= must be set if utils is different (default =$SQAROOTbin/1.0/common/getversion)
#---------------------------------------------------
use strict;
use warnings;
use diagnostics;
use Expect;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use XML::Simple;
use Data::Dumper;
use Log::Log4perl;
use Expect;
use POSIX ':signal_h';
my $NO_FILE= "No File specified";
my $ON=1;
my $OFF=0;
my $PASS=1;
my $FAIL=0;
my $NOFUNCTION="none";
my @junk = split( /\//, $0);
@junk = split('\.',$junk[$#junk]);
my $scriptFn = $junk[0];
my $USER= "root,actiontec";
my $MYWORKDIR="/root/actiontec/automation";
#--->> The Following Macro is used for CLI options

my $TB_JOBDEL="jobdelete";
my $TB_PRIORITY="priority";
my $TB_JOB_SUBMIT="jobs";
my $TB_JOBVIEWLONG="jobviewlong";
my $TB_JOBVIEWSHRT="jobviewshrt";
my $TB_JOBLOGLONG="jobloglong";
my $TB_JOBLOGSHRT="joblogshrt";

my $TB_TBSTATUSSHORT="tbstatusshort";
my $TB_TBSTATUSLONG="tbstatuslong";

my %TBLOPTION = ( 
    "$TB_JOBVIEWLONG"=>"-ql",
    "$TB_JOBVIEWSHRT"=>"-qs",
    "$TB_TBSTATUSSHORT"=>"-ss",
    "$TB_TBSTATUSLONG"=>"-sl",
    "$TB_JOBLOGSHRT"=>"-ls",
    "$TB_JOBLOGLONG"=>"-ll",

    );
#----------<<------
my $TB_TYPE="G_TBTYPE";
#-----<<<----------------
my $SQAROOT = $ENV{'SQAROOT'};
#---->>> Used for Job status
my $JOB_NEW="new_job ";
my $JOB_PENDING="pending_job";
my $JOB_DISP="dispatched_job";
my $JOB_QUEUE="queued_job";
my $JOB_DEL="deleted_job";
#----<<<<
my $OUTPUTLOG_SIZE=40 * 1024;
my $WAIT_PROCESS_TIME = 10; # ten seconds
my $STAFPORT="6600";
my $path = $ENV{'SQAROOT'};
my $binver = $ENV{'G_BINVERSION'};
my $tbProfileFilename = $path."/config/".$binver."/common/tbmaster.xml";
my $STAFCMD = "/usr/local/staf/bin/staf";
if (! (-e $STAFCMD) ) {
    printf ("Error: $0 depends on the availability of $STAFCMD\n");
    exit 1;
}
my $KT_MKIMAGE = $path."bin/1.0/common/getversion";
my $RMTUPLOADDIR = "/tmp/upload";

my %userInput = (
    "debug" => "0",
    "logdir"=>"./",
    "filename"=>$tbProfileFilename,
    "scriptname"=> $scriptFn,
    "screenOff"=> 0,
    "logOff"=> 0,
    "tbchoice"=>$NOFUNCTION,
    "tbtype"=>$NOFUNCTION,
    "action"=>$NOFUNCTION,
#    "ftprmtdir"=>$RMTUPLOADDIR,
    "testbed"=>{}, # associative array which is indexed by testbed name
    "gcov"=>{}, # associative array which is indexed by subroutine name
    "env"=>{'G_DISPSERVER'=>$NOFUNCTION,
	    'G_FTP_SERVER'=>$NOFUNCTION,
#new added
	    'G_FTP_USER_PWD'=>$USER,
	    'G_FTP_UPLOADDIR'=>$RMTUPLOADDIR,
	    'G_DISP_WORKDIR'=>$MYWORKDIR,
	    'G_GETVS_UTIL'=>$KT_MKIMAGE,
    },
    "jobqueue"=>[], # numerical array which is indexed by [0..n]
    );
#------------------------------------------------
# Parse Individual specific Test Bed Config
#-----------------------------------------------
sub parseIndTestbed{
    my ( $profFile,$tbName,$tbfilename) = @_;
    my $kk;
    my $mm;
    my $temp;
    my $index;
    my $rc=$PASS;
    my $log = $profFile->{logger};
    my $msg = "$tbName: Successfully parsing variables of $tbfilename";
    my $ptr= \%{$profFile->{testbed}{$tbName}};
    my $xmlFile = new XML::Simple;
    #Read in XML File
    my $tbData = $xmlFile->XMLin($tbfilename);
    #Import PC hosts variables.
    if ( defined $profFile->{gcov}{parseIndTestbed} ) {
	$profFile->{gcov}{parseTestbed} += 1;
    } else {
	$profFile->{gcov}{parseIndTestbed} = 1;
    }
    if ( ! defined ($tbData->{testbed}{name} ) ) {
	# for multiple testbed name case 
	$msg="$tbName: Individual testbed profile ( $tbfilename )should not have multiple entries/ <testbed> tag is not found ";
	return($FAIL,$msg);
    } else {
	# only process for single tag case 
	if ( ! defined ($tbData->{testbed}{tbtype} {name}) ) {
	    # process for multiple tbtype case
	    foreach $kk ( keys %{$tbData->{testbed}{tbtype} } ) {
		foreach $mm ( keys %{$tbData->{testbed}{tbtype} {$kk} } ) {
		    $temp = $tbData->{testbed}{tbtype}{$kk}{$mm};
		    $ptr->{tbtype}{$kk}{$mm}= $temp;
		}
	    }
	} else {
	    #for single tbtype  case 
	    $kk=$tbData->{testbed}{tbtype} {name};
	    foreach $mm ( keys %{$tbData->{testbed}{tbtype} {$kk} } ) {
		$temp = $tbData->{testbed}{tbtype}{$kk}{$mm};
		$ptr->{tbtype}{$kk}{$mm}= $temp;
	    }
	}
    }	 
    return ($rc,$msg);
}
#------------------------------------------------
# Parse Master Test Bed Config
#-----------------------------------------------
sub parseTestbed{
    my ( $profFile, $data) = @_;
    my $xx;
    my $yy;
    my $kk;
    my $mm;
    my $j;
    my $temp;
    my $index;
    my $limit;
    my $tbfilename;
    my $rc=$PASS;
    my $key ;
    my ($name,$desc);
    my $tbPtr;
    my $log = $profFile->{logger};
    my $msg = "Successfully parsing HOST variables ";
    my $ptr= \%{$profFile->{testbed}};
    #Import PC hosts variables.
    if ( defined $profFile->{gcov}{parseTestbed} ) {
	$profFile->{gcov}{parseTestbed} += 1;
    } else {
	$profFile->{gcov}{parseTestbed} = 1;
    }

    if ( (defined ($data->{testbed} ) )) {
	if ( !(defined ($data->{testbed}{name}) )) {
	    # multiple testbed 
	    foreach $index ( keys %{$data->{testbed}} ) {
		# if testbed is not defined then initialize tb status 
		if ( not defined $ptr->{$index}) {
		    $ptr->{$index}{status} = $NOFUNCTION;
		    $ptr->{$index}{msg} = $NOFUNCTION;
		}
		# Get individual specific testbed profile
		# and fill up the data structure
		$ptr->{$index}{name} = $index;
		$tbfilename = $data->{testbed} {$index} {filename};
		$temp = `ls $tbfilename`;
		$temp=~ s/\n//;
		$log->info("Testbed filename: $temp") if ( $profFile->{debug} > 2 ) ;    
		$tbfilename= $temp;
		if (!( -e $tbfilename) ) {
		    $msg = "ERROR: file $tbfilename could not be found\n";	
		    $ptr->{$index}{status} = $JOB_DEL;
		    $ptr->{$index}{msg} = $msg;
		    next;
		}
		($rc,$msg) = parseIndTestbed ( $profFile,$index,$tbfilename);
		if ($rc == $FAIL ) {
		    $ptr->{$index}{status} = $JOB_DEL;
		    $ptr->{$index}{msg} = $msg;
		} 
	    }
	} else {
	    #single testbed 
	    $index = $data->{testbed}{name};
	    if ( not defined $ptr->{$index}) {
		$ptr->{$index}{status} = $NOFUNCTION;
		$ptr->{$index}{msg} = $NOFUNCTION;
	    }
	    # Get individual specific testbed profile
	    # and fill up the data structure
	    $ptr->{$index}{name} = $index;
	    $tbfilename = $data->{testbed} {$index} {filename};
	    $temp = `ls $tbfilename`;
	    $temp=~ s/\n//;
	    $log->info("Testbed filename: $temp") if ( $profFile->{debug} > 2 ) ;    
	    $tbfilename= $temp;
	    if (!( -e $tbfilename) ) {
		$msg = "ERROR: file $tbfilename could not be found\n";	
		$ptr->{$index}{status} = $JOB_DEL;
		$ptr->{$index}{msg} = $msg;
		next;
	    }
	    ($rc,$msg) = parseIndTestbed ( $profFile,$index,$tbfilename);
	    if ($rc == $FAIL ) {
		$ptr->{$index}{status} = $JOB_DEL;
		$ptr->{$index}{msg} = $msg;
	    } 
	}
    } else {
	$msg="No HOST TAG found";
	return($FAIL,$msg);
    }
    if ( $profFile->{debug} > 2 ) { 
	foreach  $index (keys %{$ptr} ) {
	    $tbPtr = \%{$ptr->{$index}};
	    $name = $tbPtr->{name};
	    $desc = $tbPtr->{desc};
	    $log->info("Testbed($index) -- Description =$desc" );
	    foreach $kk ( keys %{$tbPtr->{tbtype}} ) {
		foreach $mm ( keys %{$tbPtr->{tbtype}{$kk}} ) {
		    $temp = $tbPtr->{tbtype}{$kk} {$mm};
		    $log->info("Testbed type ($kk)-- field($mm)=$temp");
		}
	    }
	}
    }
    return($rc,$msg);
}

#-----------------------------------------------------------
# This routine is used to check if target is recheable
#-----------------------------------------------------------
sub verifyTarget {
    my ($profFile,$tsIp) = @_;
    my $log = $profFile->{logger};
    my $rc = $PASS;
    my $msg = " $tsIp is reachable";
    my @jj;
    my $output = "ping $tsIp -w 5 -c 3";
    $log->info("$output");
    my $cmd=`$output`;
    $cmd =~ s/\%/perc/;

    @jj = split ("\n",$cmd);
    my $limit= $#jj;
    my $found = 0;
    my $match ="packet loss";
    my $gName = "verifyTarget";
    if ( defined $profFile->{gcov}{$gName} ) {
	$profFile->{gcov}{$gName} += 1;
    } else {
	$profFile->{gcov}{$gName} = 1;
    }

    for ( my $i=0 ; $i <= $limit; $i++) {
	if ( $jj[$i] =~ /$match/i ) {
	    $found = 0;
	    if ( $jj[$i] =~ / 0perc/i ) {
		$found = 2;
		last;
	    } 
	    $msg = " Error: $tsIp is not reachable =>".$jj[$i];
	    last;
	    
	}
    }
  SWITCH_VERIFYTARGET: for ($found ) {
      /0/ && do {
	  $rc = $FAIL;
	  $msg = "Error:$tsIp is not reachable";
	  last;
      };
      /1/ && do {
	  $rc = $FAIL;
	  last;
      };
      /2/ && do {
	  $rc = $PASS;
	  last;
      };
      die "verifyTarget: unrecognize error code $found \n"; 
  }
    return($rc,$msg);
    
}


#---------------------------------------------------------
# This routine is used to initialize the log feature
#---------------------------------------------------------
sub initLogger {
    my ( $profFile, $junk) = @_;
    my $rc = $PASS;
    my $msg ="Successfully Set Logger";
    my $err = "rm: cannot remove";
    #--------------------
    # initialize logger
    #---------------------
    my $temp = $profFile->{scriptname};
    my $localLog = $profFile->{logdir}."/$temp.log";
    my $clobberLog = $profFile->{logdir}."/$temp\_clobber.log";
    printf ("create $localLog\n");
    if ( -e $localLog ) {
	$temp = system("rm -f $localLog") >> 8 ;
#	$temp = `rm -f $localLog`;
#	if ( $temp =~ /$err/ ) {
	if ( $temp != 0 ) {
	    $msg = "===>         Error: Could not delete  $localLog  -- $temp";
	    return ( $FAIL,$msg);
	}
    }
    printf ("create $clobberLog\n");
    if ( -e $clobberLog ) {
	$temp = system("rm -f $clobberLog") >> 8 ;
	if ( $temp != 0 ) {
#	if ( $temp =~ /$err/ ) {
	    $msg = "===>         Error: Could not delete  $clobberLog  -- $temp";
	    return ( $FAIL,$msg);
	}
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

#-----------------------------------
# Parsing Xml Testbed profile 
#-----------------------------------
sub parsingXmlTbFile {
    my ($profFile,$junk) = @_;
    my %stageArray=( );
    my $rc = $PASS;
    my $msg = " Parsing XML file succeeded ";
    my $key ;
    my $temp;
    my $log = $profFile->{logger};
    my $xmlFile = new XML::Simple;
    #Read in XML File
    my $data = $xmlFile->XMLin($profFile->{filename});
    #printout output
    my $gName = "parsingXmlTbFile";
    if ( defined $profFile->{gcov}{$gName} ) {
	$profFile->{gcov}{$gName} += 1;
    } else {
	$profFile->{gcov}{$gName} = 1;
    }
    
    if ($profFile->{debug} > 2 ) {
	$temp = Dumper($data) ;
	$log->info( $temp );
    }
    if (defined ($data->{emaildesc})) {
	my $temp = $data->{emaildesc};
	if ( $temp =~ /^\s*$/ ) {
	    $temp = "No tag <id> <manual> " ;
	}
	$log->info("EmailDesc=$temp") if (  $profFile->{debug} > 3 ) ;
    }
    if (defined ($data->{desc})) {
	my $temp = $data->{desc};
	$log->info( "Description:$temp") if (  $profFile->{debug} > 3 ) ;
    }

    if ( (defined ($data->{id} {manual} ) )) {
	my $temp = $data->{id} {manual} ;
	if ( $temp =~ /^\s*$/ ) {
	    $temp = "No tag <id> <manual> " ;
	}
	printf ( " TAG ID $temp\n");
	$log->info("Manual ID:$temp") if (  $profFile->{debug} > 3 ) ;
    } 
    ($rc,$msg)= parseTestbed($profFile,$data);
    if ( $rc == $FAIL ) {
	$log->info($msg);
    }
    return ($rc,$msg);
}
#------------------------------------------------
# Routine used to display the Testbed data structure
#-----------------------------------------------
sub displayTb{
    my ($profFile,$tbPtr) = @_;
    my $log = $profFile->{logger};
    my $rc = $PASS;
    my ($kk,$mm,$i);
    my $temp;
    my ($desc,$alias,$status);
    my $tbName = $tbPtr->{name};
    my $msg = " Successfully display Testbed\[$tbName\]data structure ";
    my $gName = "displayTb";
    my $string;
    if ( defined $profFile->{gcov}{$gName} ) {
	$profFile->{gcov}{$gName} += 1;
    } else {
	$profFile->{gcov}{$gName} = 1;
    }

    $desc = $tbPtr->{desc};
    $alias = $tbPtr->{alias};
    $status = $tbPtr->{status};
#    $log->info("\nTestbed\[$tbName\]:MasterPc($alias):Desc=$desc\nStatus:$status" );
    $string = "\nTestbed\[$tbName\]:MasterPc($alias):Desc=$desc\nStatus:$status\n";
    $i =0;
    foreach $kk ( keys %{$tbPtr->{tbtype}} ) {
#	$log->info("\[$i\]Testbed type:$kk");
	$string = $string."\[$i\]Testbed type:$kk\n";
	foreach $mm ( keys %{$tbPtr->{tbtype}{$kk}} ) {
	    $temp = $tbPtr->{tbtype}{$kk} {$mm};
#	    $log->info("\t\t$mm=$temp");
	    $string = $string."\t\t$mm=$temp\n";
	}
	$i++;
    }
    $log->info($string);
    return ($rc,$msg);


}
#------------------------------------------------
# Parse Test Bed Config
#-----------------------------------------------
sub tbprof{
    my ( $profFile, $data) = @_;
    my $index;
    my $tbPtr;
    my $log = $profFile->{logger};
    my $msg = "Successfully parsing HOST variables ";
    my $rc=$PASS; 
    my $ptr= \%{$profFile->{testbed}};
    my $gName = "tbprof";
    if ( defined $profFile->{gcov}{$gName} ) {
	$profFile->{gcov}{$gName} += 1;
    } else {
	$profFile->{gcov}{$gName} = 1;
    }

    $index = lc($profFile->{tbchoice});
    $log->info(" TESTBED = $index ");
    if ( $profFile->{tbchoice}=~ /$NOFUNCTION/i ) {
	foreach  $index (keys %{$ptr} ) {
	    $tbPtr = \%{$ptr->{$index}};
	    ($rc,$msg)=displayTb($profFile,$tbPtr,$index);
	}
    } else {
	if ( not defined $ptr->{$index} ) {
	    $rc = $FAIL;
	    $msg = "failed to set up the configuration -- testbed $index not found";
	    return($rc,$msg);
	}
	$tbPtr = \%{$ptr->{$index}};
	($rc,$msg)=displayTb($profFile,$tbPtr,$index);
    }
    return($rc,$msg);
}


#************************************************************
# Using cross reference for testbed name
#************************************************************
sub getTbName {
    my ($profFile,$hostname) = @_;
    my $ptr= \%{$profFile->{testbed}};
    my $tb;
    my $log = $profFile->{logger};
    my $gName = "getTbName";
    if ( defined $profFile->{gcov}{$gName} ) {
	$profFile->{gcov}{$gName} += 1;
    } else {
	$profFile->{gcov}{$gName} = 1;
    }

    foreach  $tb (keys %{$ptr} ) {
	$log->info("\n Testbed $tb " );
	if ( $ptr->{$tb}{alias} =~ /$hostname/i) {
	    $log->info("\n Testbed $tb is found " );
	    return ($tb);
	}
    }
    return($NOFUNCTION);
}



#---------------------------------------------------
# Check if STAF process is turned on dispatcher Server
#---------------------------------------------------
sub isTbStafAvail {
    my ($profFile,$tbName)=@_;
    my $rc=$FAIL;
    my $log = $profFile->{logger};
    my $msg = "Failed to reach TB $tbName";
    my $cmd = "/usr/local/staf/bin/staf $tbName ping ping";
    my $temp = `$cmd`;
    $log->info("isTbStatAvail:cmd($cmd)\n$temp") if ($profFile->{debug} > 2 );
    my @buffer = split("\n",$temp);
    my $line;
    my $gName = "isTbStafAvail";
    if ( defined $profFile->{gcov}{$gName} ) {
	$profFile->{gcov}{$gName} += 1;
    } else {
	$profFile->{gcov}{$gName} = 1;
    }
    foreach $line (@buffer) {
	# if error occurs then STAF is not running
	if ( $line =~ /Error submitting*/i ) {
	    #testbed is not available
	    $rc=$FAIL;
	    $msg = "$tbName Staf is not running";
	    return($rc,$msg);
	}
	if ( $line =~ /Response/i) {
	    next;
	}
	$msg="STAF on $tbName is running";
	last;
    }
    #testbed is not available
    $rc = $PASS;
    return($rc,$msg);
}



#---------------------------------------------------
# Check Testbed availability 
#---------------------------------------------------
sub verifyDispatcherServer{
    my ($profFile,$junk)=@_;
    my $rc=$FAIL;
    my $serverIp = $profFile->{env}{G_DISPSERVER};
    my $msg ;
    my $log = $profFile->{logger};
    my $index = 0;
    my $tbName;
    my $alias;
    my $gName = "verifyDispatcherServer";
    if ( defined $profFile->{gcov}{$gName} ) {
	$profFile->{gcov}{$gName} += 1;
    } else {
	$profFile->{gcov}{$gName} = 1;
    }
    # Verify if Dispatcher IP is defined
    if ( $profFile->{env}{G_DISPSERVER} =~ /$NOFUNCTION/) {
	$msg = "User must set the environment G_DISPSERVER=\[ip address/alias of dispatcher server\]";
	return($FAIL,$msg);
    }
    # is it pingeable
    ($rc,$msg) = verifyTarget($profFile,$serverIp); 	
    if ( $rc == $FAIL ) {
	return($FAIL,$msg);
    }
    # Staf service is it on ?
    ($rc,$msg) = isTbStafAvail($profFile,$serverIp);
    if ( $rc == $FAIL ) {
	return($FAIL,$msg);
    }
    $msg = "Dispatcher($serverIp) is available";
    return ($PASS,$msg);
}
#---------------------------------------------------
#  Search for TBtype from a testsuite 
#---------------------------------------------------
sub searchForTBType {
    my ($profFile,$tsuiteName) = @_;
    my $log = $profFile->{logger};
    my $rc=$FAIL;
    my @temp;
    my $msg="Error:could not find G_TBTYPE from file <$tsuiteName>";
    if ( !(-e $tsuiteName)) {
	$msg = "Error:$tsuiteName is not found ";
	return ($FAIL,$msg);
    }
    open(FD,"<$tsuiteName");
    my @buff=<FD>;
    close FD;
    my $limit = $#buff;
    for ( my $i = 0; $i<=$limit;$i++) {
	$log->info("\[$i\]:$buff[$i]") if ( $profFile->{debug} >1 );
	if ( ( $buff[$i] =~ /^-v/ ) && ( $buff[$i] =~ /$TB_TYPE=/ )) {
	    $buff[$i]=~ s/\n//;
	    @temp= split(" ",$buff[$i]);
	    $temp[1] =~ s/ //g;
	    return($PASS,$temp[1]);
	}
    }
    return($rc,$msg);
}


#---------------------------------------------------
#  Search for TBtype from a testsuite 
#---------------------------------------------------
sub stafMsgSend {
    my ($profFile,$content) = @_;
    my $rc=$FAIL;
    my $localDebug=1;
    my $msg;
    my $wdir = $profFile->{env} {G_DISP_WORKDIR};
    my $alias = $profFile->{env} {G_DISPSERVER};
    my $log = $profFile->{logger};
    my $cmd = "$STAFCMD $alias\@$STAFPORT process start COMMAND \"/usr/bin/perl\"";
    my $params = "PARMS \"$wdir/bin/1.0/common/tbdispatcher.pl -j $content\" ";
    my $workDir = "WORKDIR $wdir";
    $cmd = $cmd." ".$params." ".$workDir;
    $log->info("COmmand = $cmd " ) if (  $profFile->{debug} > $localDebug  ) ;
    my $temp = `$cmd`;
    $log->info("Submit Job \[$cmd\] to $alias:$temp") if (  $profFile->{debug} > $localDebug  ) ;
    #parse the output of the result;
    my @buff = split("\n",$temp);
    my $gName = "stafMsgSend";
    if ( defined $profFile->{gcov}{$gName} ) {
	$profFile->{gcov}{$gName} += 1;
    } else {
	$profFile->{gcov}{$gName} = 1;
    }

    #-------------------------------------------------
    # There are 2 response  formats:
    #    Error submitting request, RC: 16 
    #    Additional info
    #    ---------------
    #    STAFConnectionProviderConnect: Error performing test read on connected endpoint: recv() RC=111: 22, Endpoint: tcp://qa16
    #and the right response is 
    #   Response
    #   --------
    #   3
    #-------------------------------------------------
    if ( $buff[0] =~ /Response/i ) {
	$msg = "Successfully Dispatched to Dispatcher Server and JobHandle=$buff[2]\n ContentString=$content";    
	return ($PASS,$msg)
    }
    
    $msg = "Failed to submit Job to dispatcher Server!!!\n\nContentString=$content\n\tResult:$buff[3]";
    return ($FAIL,$msg);
}

#---------------------------------------------------
# Upload File to FTP server 
#---------------------------------------------------
sub uploadFile{
    my ($profFile,$localBuild,$targetBuild) = @_;
    my ($rc,$msg);
    my $msg2;
    my $temp;
    my $ftpuser= $profFile->{env}{G_FTP_USER_PWD};
    my $remoteDir = $profFile->{env}{G_FTP_UPLOADDIR};
    my $image = "cd $remoteDir ; put  $localBuild -o $targetBuild ; exit";    
    my $ftpServer = $profFile->{env}{G_FTP_SERVER};
    #-----------------------------------------
    # Use lftp to upload image 
    #-----------------------------------------
    $temp = system ("lftp -e \"$image\" -u $ftpuser $ftpServer");
    $msg = "upload file $localBuild to $remoteDir";
    if ( $temp != 0 ) {
	$msg = "Fail to ".$msg;
	return($FAIL,$msg);
    
    }
    $rc = $PASS;
    $msg = "Successful ".$msg."\n";
    return($rc,$msg);
}
#---------------------------------------------------
# Upload File to FTP server 
#---------------------------------------------------
sub uploadImage{
    my ($profFile,$localBuild,$targetBuild) = @_;
    my ($rc,$msg);
    my $msg2;
    my $temp;
    my $baseName;
    ($baseName,$temp)= split('\.',$targetBuild);
    my $localdir = $profFile->{logdir};
    my $remoteDir = $profFile->{env} {G_FTP_UPLOADDIR};
    my $md5File = $baseName."\.md5";
    my $localmd5 = $localdir."./".$md5File;
    $temp = `touch $localmd5`;
    $temp = `ls $localmd5`;
    $temp =~ s/\n//;
    $localmd5 = $temp;
    #-----------------------------------------
    # Use lftp to upload image 
    #-----------------------------------------
    ($rc,$msg) = uploadFile($profFile,$localBuild,$targetBuild);
    return($rc,$msg) if ( $rc == $FAIL);
    $msg = "Successfully upload image $localBuild to $remoteDir";
    $temp = `md5sum $localBuild`;
    $temp =~ s/\n//;
    my @buff = split (" ",$temp);
    $temp = `echo $buff[0] > $localmd5`;
    ($rc,$msg2) = uploadFile($profFile,$localmd5,$md5File);
    return($rc,$msg2) if ( $rc == $FAIL);
    $temp =`rm -f $localmd5`;
    $msg .="Successfully ".$msg2."\n";
    return($rc,$msg);
}
#-------------------------------------------
# Get name 
#-------------------------------------------
sub getBaseName{
    my ($path,$junk) = @_;
    my @t1;
    @t1=split("/",$path );
    $junk = $t1[$#t1];
    return ($junk);
}
#-------------------------------------------
# Get Product Type 
#-------------------------------------------
sub checkProdType { 
    my ($profFile,$localBuild) = @_;
    my $rc = $FAIL;
    my $log = $profFile->{logger};
    my $util = $profFile->{env}{G_GETVS_UTIL};
    my $msg = "checkProdType: Error could not find";
    my $temp = `ls $localBuild`;
    my @junk;
    $temp =~ s/\n//;
    if ( !(-e $temp) ) {
	$msg= $msg."file $temp";
	return($FAIL,$msg);
    }
    $temp = `$util -f $temp`;
    my @buff= split ("\n",$temp);
    my $limit =$#buff;
    for ( my $i=0; $i <= $limit; $i++) {
	if ( $buff[$i] =~ /rg_hw:/ ) {
#	    $log->info( "!!!!!!!!!!!version=$buff[$i]" );
	    @junk = split(" ",$buff[$i]);
#	    @junk = split ("_",$junk[1]);
	    $msg = $junk[1];
	    return($PASS,$msg);
	}
    }
    $msg = $msg."Product Type from $temp";
    return($rc,$msg);
}
#---------------------------------------------------
# Submit Jobs through STAF
#---------------------------------------------------
sub jobSubmit {
   my ($profFile,$command)=@_;
   my $rc = $PASS;
   my $msg = "jobSubmit: ";
   my $log = $profFile->{logger};
   my $temp;
   my $len;
   my $localDebug = 1;
   my ($value,$key);
   my $ftpServer = $profFile->{env}{G_FTP_SERVER};
   my $contentString="";
   my $systemString=" ";
   my $targetBuild=$NOFUNCTION;
   my $localBuild=$NOFUNCTION;
   my $tsuiteName=$NOFUNCTION;
   my $targetTsuite=$NOFUNCTION;
   my $entry;
   my $libTsuite =$NOFUNCTION;
   my @buff;
   my @fileName;
   my $gName = "jobSummit";
   if ( defined $profFile->{gcov}{$gName} ) {
       $profFile->{gcov}{$gName} += 1;
   } else {
       $profFile->{gcov}{$gName} = 1;
   }
   $temp = `date +%j%H%M%S`;
   $temp =~ s/\n//;
   my $jobident = $temp;
   my $targetSuffix ="_".$jobident;
   $systemString = " -v ident=$jobident ";
   my $specifiedFtp =0 ;
   my $specifiedTBType =0 ;
   my $specifiedUser =0 ;
   my $specifiedPriority =0 ;
   my $specifiedLibTsuite =0 ;
   my $specifiedProdType = 0 ;
   foreach $entry ( @{$command} ) {
       @buff = split("=",$entry);
       $key = $buff[0];
       $value = $buff[1];
     SWITCH_JOBSUBMIT: for ($key) {
	 /G_USER$/ && do {
	     $specifiedUser=1;
	     $contentString .= $entry.":"; 
	     last;
	 };
	 /G_PROD_TYPE$/ && do {
	     $specifiedProdType = 1 ;
	     $contentString .= $entry.":"; 
	     last;
	 };	   
	 /G_LIB_TSUITE$/ && do {
	     $specifiedLibTsuite = 1 ;
	     $libTsuite=$value;
	     $contentString .= $entry.":"; 
	     last;
	 };	   
	 /G_TSUITE$/ && do {
	     $tsuiteName=$value;
	     $temp =  getBaseName($value);
	     @fileName= split('\.',$temp);
	     $targetTsuite = $fileName[0].$targetSuffix."\.".$fileName[1];
	     last;
	 };	   
	 /G_FTP_UPLOADDIR$/&& do{
	     $profFile->{env}{G_FTP_UPLOADDIR}=$value;
	     last;
	 };
	 /G_TBTYPE$/ && do {
	     $specifiedTBType =1 ;
	     $contentString .= $entry.":"; 
	     last;
	 };	   
	 /G_FTP_SERVER$/ && do {
	     $specifiedFtp =1 ;
	     $profFile->{env}{G_FTP_SERVER}=$value;
	     $contentString .= $entry.":"; 
	     $ftpServer = $profFile->{env}{G_FTP_SERVER};
	     last;
	 };	   
	 
	 /G_BUILD$/ && do {
	     $localBuild=$value;
	     $temp =  getBaseName($value);
	     @fileName= split('\.',$temp);
	     $targetBuild = $fileName[0].$targetSuffix."\.".$fileName[1];
	     $contentString .= "G_BUILD=".$targetBuild.":";
	     last;
	 };	   
	 /G_PRIORITY$/ && do {
	     $systemString .= " -v priority=$value";
	     last;
	 };
	 $contentString .= $entry.":";
	 last;
     }
   }
   #-------------------------------------------------------------------
   # Check Product type
   #-------------------------------------------------------------------
   if ( $specifiedProdType == 0 )  {
       ($rc,$msg)=checkProdType($profFile,$localBuild);
       if ( $rc == $FAIL ) { 
	   $msg = "\nJOBID=$jobident\nSTATUS=".$msg;
	   return ($rc,$msg) ;
       }
       $contentString .= "G_PROD_TYPE=".$msg.":";  
   }
   #-------------------------------------------------------------------
   # Check FTP SERVER
   #-------------------------------------------------------------------

   if ( $specifiedFtp == 0 ) {
       $contentString .= "G_FTP_SERVER=".$profFile->{env}{G_FTP_SERVER}.":";  
   }
   #-------------------------------------------------------------------
   # Check Priority 
   #-------------------------------------------------------------------
   if ( $specifiedPriority == 0 ) {
       $systemString .= " -v priority=200";
   }
   #-------------------------------------------------------------------
   # Check USER is given
   #-------------------------------------------------------------------
   if ( $specifiedUser == 0 ) {
       $msg="G_USER needs to be specified";
       $msg = "\nJOBID=$jobident\nSTATUS=".$msg;
       return($FAIL,$msg);
   }
   #-------------------------------------------------------------------
   # Check TBTYPE of the testsuite name if there is no-force-set TBTYPE 
   #-------------------------------------------------------------------
   if ($specifiedTBType == 0 ) {
       if ( $tsuiteName !~ /$NOFUNCTION/) {
	   ($rc,$msg) = searchForTBType($profFile,$tsuiteName);
	   if ( $rc == $FAIL ) { 
	       $msg = "\nJOBID=$jobident\nSTATUS=".$msg;
	       return ($rc,$msg) ;
	   }

       } else {
	   if ( $specifiedLibTsuite == 0) {
	       $msg="need to specified Testsuite either through G_TSUITE/G_LIB_TSUITE";
	       return($FAIL,$msg);
	   }
	   ($rc,$msg) = searchForTBType($profFile,$libTsuite);
	   if ( $rc == $FAIL ) { 
	       $msg = "\nJOBID=$jobident\nSTATUS=".$msg;
	       return ($rc,$msg) ;
	   }

       }
       $contentString .= $msg.":";   
   }
   #----------------------------
   # Check FTP server address 
   #----------------------------
   if (  $profFile->{env}{G_FTP_SERVER} =~ /$NOFUNCTION/ ) {
       $msg = "User must specify either: \n\t1. in env G_FTP_SERVER=\[ip address|alias\] \n\t2. -v G_FTP_SERVER= \[ip address|alias\]";
       $msg = "\nJOBID=$jobident\nSTATUS=".$msg;
       return ($FAIL,$msg);
   }
   #----------------------------
   # Upload File to Server 
   #----------------------------
   # Is server available
   ($rc,$msg) = verifyTarget($profFile,$ftpServer);
   return($rc,$msg) if ($rc == $FAIL);
   if ( $localBuild =~ /$NOFUNCTION/) { 
       $msg = "Image ($localBuild) is not given ";
       $msg = "\nJOBID=$jobident\nSTATUS=".$msg;
       $log->info($msg) if ( $profFile->{debug} > $localDebug );
       return($FAIL,$msg);
   }
   $log->info("Upload local file $localBuild to remote $targetBuild") if ( $profFile->{debug} > $localDebug );
   ($rc,$msg)=uploadImage($profFile,$localBuild,$targetBuild);
   return($rc,$msg) if ( $rc == $FAIL);
   # upload testsuite script
   if ( $tsuiteName !~ /$NOFUNCTION/)    {
       $contentString .= "G_TSUITE=".$targetTsuite.":";
       ($rc,$msg)=uploadFile($profFile,$tsuiteName,$targetTsuite);
       if ( $rc == $FAIL ) { 
	   $msg = "\nJOBID=$jobident\nSTATUS=".$msg;
	   return ($rc,$msg) ;
       }
   } 
   #this is the last one of the string
   $contentString .="G_FTP_UPLOADDIR=".$profFile->{env} {G_FTP_UPLOADDIR};
   #----------------------------
   # Submit job to tbdispatcher 
   #----------------------------
   $contentString = " -v content=\"$contentString\"".$systemString;
   ($rc,$msg)=stafMsgSend($profFile,$contentString);
   $msg = "\nJOBID=$jobident\nSTATUS=".$msg;
   return ($rc,$msg);
}
#-------------------------------------------------------------
# display function calling statistic
#------------------------------------------------------------
sub displayGcov {
   my ($profFile,$junk)=@_;
   my $log = $profFile->{logger};
   my $key;
   my $temp;
   $log->info("Subroutine call statistics");
   foreach $key ( keys %{$profFile->{gcov}}) {
       $temp = $profFile->{gcov} {$key};
       $log->info("      $key\[$temp\]");
   }
   return $PASS;
}
#---------------------------------------------------
# Update output Job Logs 
#---------------------------------------------------
sub updateJobLogs {
    my ($profFile,$content)=@_;
    my $rc;
    my $msg="updateJobLogs:";
    my $log = $profFile->{logger};
    my $dirName = $profFile->{logdir};
    my $logFile = $dirName."/".$profFile->{scriptname}."_outputlog.txt";
    my $logFile2 = $dirName."/".$profFile->{scriptname}."_outputlog2.txt";
    my $date = `date +%Y%m%d%H%M%S`;
    my $test;
    $date=~ s/\n//;
    my $gName = "updateJobLogs";
    if ( defined $profFile->{gcov}{$gName} ) {
	$profFile->{gcov}{$gName} += 1;
    } else {
	$profFile->{gcov}{$gName} = 1;
    }
    # Check the size of logfile
    if ( -e $logFile ) {
	$test = -s "$logFile";
	if ( $test > $OUTPUTLOG_SIZE ) {
	    $rc =`mv -f $logFile $logFile2`;
	    $rc = `touch $logFile`;
	}
    } else {
	$rc = `touch $logFile`;
    }
    open(LOGFD,">>$logFile");
    $date= "$date --".$content;
    printf LOGFD $date;
    close LOGFD;
    $msg = $msg." Successfully update log";
    $rc = $PASS;
    return($rc,$msg);
}

#************************************************************
# Generate entry to delete/change a status of  a job with a given id
#************************************************************
sub submitDeleteJob {
    my ($profFile,$content) = @_;
    my $rc=$FAIL;
    my $msg;
    my $alias = $profFile->{env} {G_DISPSERVER};
    my $wdir = $profFile->{env} {G_DISP_WORKDIR};
    my $log = $profFile->{logger};
    my $cmd = "$STAFCMD $alias\@$STAFPORT process start COMMAND \"/usr/bin/perl\"";
    my $params = "PARMS \"$wdir/bin/1.0/common/tbdispatcher.pl -d $content\" ";
    my $workDir = "WORKDIR $wdir";
    $cmd = $cmd." ".$params." ".$workDir;
    my $temp = `$cmd`;
    $log->info("Submit Job \[$cmd\] to $alias:$temp") if (  $profFile->{debug} > 1 ) ;
    #parse the output of the result;
    my @buff = split("\n",$temp);
    my $gName = "submitDeleteJob";
    if ( defined $profFile->{gcov}{$gName} ) {
	$profFile->{gcov}{$gName} += 1;
    } else {
	$profFile->{gcov}{$gName} = 1;
    }

    #-------------------------------------------------
    # There are 2 response  formats:
    #    Error submitting request, RC: 16 
    #    Additional info
    #    ---------------
    #    STAFConnectionProviderConnect: Error performing test read on connected endpoint: recv() RC=111: 22, Endpoint: tcp://qa16
    #and the right response is 
    #   Response
    #   --------
    #   3
    #-------------------------------------------------
    if ( $buff[0] =~ /Response/i ) {
	$msg = "Successfully delete Job $content and  JobHandle=$buff[2]";    
	return ($PASS,$msg)
    }
    $msg = "Failed to delete Job $content\n\tResult:$buff[3]";
    return ($FAIL,$msg);

}
#************************************************************
# Wait for handle set for free
#************************************************************
sub waitForHandleFree{ 
    my ($profFile,$handle) = @_;
    my $rc=$FAIL;
    my $msg="Failed to query handle($handle)";
    my $alias = $profFile->{env} {G_DISPSERVER};
    my $log = $profFile->{logger};
    my $wdir = $profFile->{env} {G_DISP_WORKDIR};
    my $cmd = "$STAFCMD $alias\@$STAFPORT process query handle $handle ";
    my $workDir = "WORKDIR $wdir ";
    my $rmtOuputFile = "/tmp/".$profFile->{scriptname}."_query.txt ";
    my $stafcmd = $cmd;
    my $temp;
    my $line;
    my @buff;
    my $notdone = 1;
    while ( $notdone ) {
	sleep 2;
	$temp = `$stafcmd`;
	$log->info("Query handle $handle \[$stafcmd\] to $alias:$temp") if (  $profFile->{debug} > 2 ) ;
	@buff = split ("\n",$temp);
	if ( $buff[0] =~ /Error/i ) {
	    last;
	}
	foreach $line ( @buff) {
	    if ( $line =~ /Return Code/ ) {
		if ( $line !~ /none/i) {
		    $notdone=0;
		    $rc = $PASS;
		    $msg="Successfully query handle($handle)";
		    last;
		}
	    }
	}       
    }
    return($rc,$msg);
}
#************************************************************
# Search for available JobId
#************************************************************
sub queryActiveJob {
    my ($profFile,$junk) = @_;
    my $rc=$FAIL;
    my $msg;
    my $alias = $profFile->{env} {G_DISPSERVER};
    my $log = $profFile->{logger};
    my $wdir = $profFile->{env} {G_DISP_WORKDIR};
    my $cmd = "$STAFCMD $alias\@$STAFPORT process start COMMAND \"/usr/bin/perl\"";
    my $params;
    my $workDir = "WORKDIR $wdir";
    my $rmtOuputFile = "/tmp/".$profFile->{scriptname}."_query.txt ";
    my $option = $TBLOPTION{$profFile->{action}};
    $params = "PARMS \"$wdir/bin/1.0/common/tbdispatcher.pl $option\" ";
    my $stafcmd = $cmd." ".$params." ".$workDir." STDOUT $rmtOuputFile";
    my $temp = `$stafcmd`;
    $log->info("Query Job \[$stafcmd\] to $alias:$temp") if (  $profFile->{debug} > 1 ) ;
    #parse the output of the result;
    my @buff = split("\n",$temp);
    my $gName = "queryActiveJob";
    if ( defined $profFile->{gcov}{$gName} ) {
	$profFile->{gcov}{$gName} += 1;
    } else {
	$profFile->{gcov}{$gName} = 1;
    }
    #-------------------------------------------------
    # There are 2 response  formats:
    #    Error submitting request, RC: 16 
    #    Additional info
    #    ---------------
    #    STAFConnectionProviderConnect: Error performing test read on connected endpoint: recv() RC=111: 22, Endpoint: tcp://qa16
    #and the right response is 
    #   Response
    #   --------
    #   3
    #-------------------------------------------------
    if ( $buff[0] !~ /Response/i ) {
	$msg = "Failed to submit $stafcmd \n\tResult:$buff[3]";
	return ($FAIL,$msg);
    }
    my $handle = $buff[2];
    ($rc,$msg)=waitForHandleFree($profFile,$handle);
    return ($rc,$msg) if ( $rc == $FAIL );
    $cmd = "$STAFCMD $alias\@$STAFPORT fs get file $rmtOuputFile ";
    $msg= "OK";
    $temp = `$cmd`;
    $log->info("Query <$cmd> file $rmtOuputFile from $alias: \n \[$temp\]") if (  $profFile->{debug} > 1 ) ;
    #parse the output of the result;
    @buff = split("\n",$temp);
    #-------------------------------------------------
    # There are 2 response  formats:
    #    Error submitting request, RC: 16 
    #    Additional info
    #    ---------------
    #    STAFConnectionProviderConnect: Error performing test read on connected endpoint: recv() RC=111: 22, Endpoint: tcp://qa16
    #and the right response is 
    #   Response
    #   --------
    #   3
    #-------------------------------------------------
    if ( $buff[0] =~ /Response/i ) {
	$msg = $temp;    
	$log->info("Query List:\n $temp") if (  $profFile->{debug} > 1 ) ;
	return ($PASS,$msg)
    }
    $msg = "Failed to query remote file $rmtOuputFile\n\tResult:$buff[0]";
    return ($FAIL,$msg);
}
#************************************************************
# Main Routine
#************************************************************
MAIN:
my $exp;
my $TRUE=1;
my $FALSE=0;
my @userTemp;
my ($x,$h);
my $option_h;
my $rc =0;
my $rc2 =0;
my $msg;
my $msg2;
my $key;
my $logdir;
my @commands = ();
my $globalRc = 0;
my $option_man = 0;
my $jobid =0 ;
$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man, 
		  "l=s"=>sub {  $userInput{logdir} = $_[1]; $logdir = $_[1]},
		  "b=s"=>\$userInput{tbchoice},
		  "t=s"=>\$userInput{tbtype},
		  "d=s"=>sub { $userInput{action} = $TB_JOBDEL; $jobid=$_[1]; },
# NOT support for now 
#		  "p=s"=>sub { $userInput{action} = $TB_PRIORITY; },
		  "j"=>sub { $userInput{action} = $TB_JOB_SUBMIT; },
		  "qs"=>sub { $userInput{action} = $TB_JOBVIEWSHRT; },
		  "ql"=>sub { $userInput{action} = $TB_JOBVIEWLONG; },
		  "ss"=>sub { $userInput{action} = $TB_TBSTATUSSHORT; },
		  "sl"=>sub { $userInput{action} = $TB_TBSTATUSLONG; },
		  "ls"=>sub { $userInput{action} = $TB_JOBLOGSHRT; },
		  "ll"=>sub { $userInput{action} = $TB_JOBLOGLONG; },

		  "f=s"=>\$userInput{filename},
		  "v=s"=>sub { if ( exists $commands[0] ) { push (@commands,$_[1]); } else {$commands[0]=$_[1]; } } ,
		  );
#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);

#printf("--------------- Input Parameters  ---------------\n") if $userInput{debug} ;
printf("--------------- $scriptFn  Input Parameters  ---------------\n");
foreach $key ( keys %userInput ) {
#    printf (" $key = $userInput{$key} :: " ) if $userInput{debug} ;
    printf (" $key = $userInput{$key} :: " );
}

#--------------------------------------
# Check needed environment variables
#-------------------------------------
if (defined $ENV{G_DISPSERVER} ) { 
    $userInput{env}{G_DISPSERVER} = $ENV{G_DISPSERVER};
}
if (defined $ENV{G_FTP_SERVER} ) { 
    $userInput{env}{G_FTP_SERVER} = $ENV{G_FTP_SERVER};
}

if (defined $ENV{G_DISP_WORKDIR} ) { 
    $userInput{env}{G_DISP_WORKDIR} = $ENV{G_DISP_WORKDIR};
}
#optional
if (defined $ENV{G_GETVS_UTIL} ) { 
    $userInput{env}{G_GETVS_UTIL} = $ENV{G_GETVS_UTIL};
}



my $limit = @commands;
if ($limit != 0 ) {
    foreach my $line (  @commands) { 
	printf "$line \n";
	if ( $line =~ /^G_DISPSERVER=/) {
	    @userTemp = split("=",$line);
	    $ENV{'G_DISPSERVER'} = $userTemp[1];
	    next;
	} 
	if ( $line =~ /^G_FTP_SERVER=/) {
	    @userTemp = split("=",$line);
	    $ENV{'G_FTP_SERVER'} = $userTemp[1];
	    next;
	}
	if ( $line =~ /^G_DISP_WORKDIR=/) {
	    @userTemp = split("=",$line);
	    $ENV{'G_DISPSERVER'} = $userTemp[1];
	    next;
	} 
	if ( $line =~ /^G_GETVS_UTIL=/) {
	    @userTemp = split("=",$line);
	    $ENV{'G_FTP_SERVER'} = $userTemp[1];
	    next;
	}

    } 
};



#---------------------------------------------
# Initialize Logger 
#---------------------------------------------
($rc,$msg) = initLogger(\%userInput, );
if ( $rc != $PASS) {
    printf ("$msg\n");
    exit 1;
}
if ( !(-e $userInput{env} {G_GETVS_UTIL})) {
    printf ("Error : $0 depends on the availability of  $KT_MKIMAGE");
    exit 1;
}
printf ("\n Environment required for jobcontol \n");
foreach $key ( keys %{$userInput{env}} ) {
    print ( "$key=$userInput{env}{$key}\n");
}



 
#---------------------------------------------
# Check the availability of TB dispatcher 
#---------------------------------------------
($rc,$msg)=verifyDispatcherServer(\%userInput);
$userInput{logger}->info($msg);
if ($rc == $FAIL) {
    exit 1;
}


#-------------------------------------
# Switch between action
#-------------------------------------

for ($userInput{action} ) {
    #-------------------------------
    #Get status of Testbed resources
    #------------------------------- 
    /^$TB_JOB_SUBMIT$/ && do {
	($rc,$msg) = jobSubmit(\%userInput,\@commands);
	#log result to file 
	($rc2,$msg2)= updateJobLogs(\%userInput,$msg);
	if ( $rc2 == $FAIL ) {
	    $msg = $msg2;
	}
	last;
    };
    #-------------------------------
    # Delete a Job
    #------------------------------- 
    /^$TB_JOBDEL$/ && do {
	($rc,$msg)=submitDeleteJob(\%userInput,$jobid);
	#log result to file 
	($rc2,$msg2)= updateJobLogs(\%userInput,$msg);
	if ( $rc2 == $FAIL ) {
	    $msg = $msg2;
	}

	last;
    };
    #-------------------------------
    #View job in short form 
    #-------------------------------
    /^$TB_JOBVIEWSHRT$/ && do {
	($rc,$msg) = queryActiveJob(\%userInput);
	last;
    };
    #-------------------------------
    #View job in long form 
    #-------------------------------
    /$TB_JOBVIEWLONG/ && do {
	($rc,$msg) = queryActiveJob(\%userInput);
	last;
    };
    #-------------------------------
    #View TestBed Status  in long form 
    #-------------------------------
    /^$TB_TBSTATUSLONG$/ && do {
	($rc,$msg) = queryActiveJob(\%userInput);
	last;
    };
    #-------------------------------
    #View TestBed Status  in long form 
    #-------------------------------
    /^$TB_TBSTATUSSHORT$/ && do {
	($rc,$msg) = queryActiveJob(\%userInput);
	last;
    };
    #-------------------------------
    #View TestBed Status  in long form 
    #-------------------------------
    /^$TB_JOBLOGSHRT$/ && do {
	($rc,$msg) = queryActiveJob(\%userInput);
	last;
    };
    #-------------------------------
    #View TestBed Status  in long form 
    #-------------------------------
    /^$TB_JOBLOGLONG$/ && do {
	($rc,$msg) = queryActiveJob(\%userInput);
	last;
    };



    #-------------------------------
    #Change Jobs  priority  
    #-------------------------------
    /$TB_PRIORITY/ && do {
#	($rc,$msg) = changeJobPriority(\%userInput);
#	$userInput{logger}->info("$msg");
	if ($rc == $FAIL) {
	    $userInput{logger}->info("==> Failed to Generate Environment Variables");
	}
	last;
    };
    $userInput{logger}->info("Warning: Please select an option");
    pod2usage(1);
    last;
}
$userInput{logger}->info("$msg");
if ( $rc == $FAIL) {
    $userInput{logger}->info("==> $userInput{scriptname}  failed");
    exit 1;
}
$userInput{logger}->info("==> $userInput{scriptname} passed");
exit (0);
1;
__END__

=head1 NAME

jobcontrol.pl - is used to submit a job from remote host

=head1 SYNOPSIS

=over 12

=item B<jobcontrol.pl>
[B<-help|-h>]
[B<-man>]
[B<-l> I<log file path>]
[B<-b> I<testbed name >]
[B<-t> I<testbed type  name>]
[B<-d> I<job identification number > ]
[B<-ss>]
[B<-sl>]
[B<-ql>]
[B<-ls>]
[B<-ll>]
[B<-qs>]
[B<-j>]
[B<-x> I<debug level>]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-b>

Specify a testbed name to be used

=item B<-d>

Delete job through identification number

=item B<-t>

Specify a testbed type name to be used 
 
=item B<-j>

Submit jobs 

=item B<-ql>

View job queues  in long form

=item B<-qs>

View job queues  in short form

=item B<-ll>

View job log in long form

=item B<-ls>

View job log  in short form

=item B<-sl>

View testbed status in long form

=item B<-ss>

View testbed status  in short form

=item B<-l>

Redirect stdout to the /path/jobcontrol.log

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-x>

Set debug to different level . ( more debug messages with higher number)


=head1 DESCRIPTION

B<jobcontrol.pl> will allow user to submit jobs, query status of each testbed/tb type and its job queues.


=head1 EXAMPLES

1. The following command is used to submit a job
    perl jobcontrol.pl -j -v G_USER=jnguyen -v G_TSUITE=/svn/svnroot/QA/automation/testsuites/1.0/common/sample/test678.tst  -v G_BUILD=/main/projects/builder/autobuild/official/vf_4r2-ver_4r2b12/vf2113/vf2113_mos_v4r2b12.img  -v G_BUILDID=id123 -v G_PROJID=proj456 

2. The following command is used to submit a job to a specific testbed even the testbed is locked  ( need to be implemented )
    perl jobcontrol.pl -j -v G_USER=jnguyen -v G_TSUITE=/svn/svnroot/QA/automation/testsuites/1.0/common/sample/test678.tst  -v G_BUILD=/main/projects/builder/autobuild/official/vf_4r2-ver_4r2b12/vf2113/vf2113_mos_v4r2b12.img  -v G_BUILDID=id123 -v G_PROJID=proj456  -v G_TESTBED=tb1 -v G_TBTYPE=nflow

3. The following command is used to delete a pending job through job id 
        perl jobcontrol.pl -d 333120111

4. The following command is used to display pending job queues in long form
        perl jobcontrol.pl -ql

5. The following command is used to display testbed status in short form
        perl jobcontrol.pl -ss

6. The following command is used to display job log in short form
        perl jobcontrol.pl -ls

=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut

