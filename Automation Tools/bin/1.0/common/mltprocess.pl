#!/usr/bin/perl -w
#---------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to set up a testbed base on testbed name and test suite +  
# display the availability of each testbed and its testbed types.
# 
# Change history:
#    * Add handle element flag in order to allow 
#      a must done process to finish before killing it. 
#                                      Hugo 09/14/2010
#    * xxx
#
#--------------------------------
use strict;
use warnings;
#use diagnostics;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use XML::Simple;
use Data::Dumper;
use Log::Log4perl;
#use Expect;
use POSIX ":sys_wait_h";
#use IO::Handle;
use POSIX ':signal_h';
my $NO_FILE= "No_File_specified";
my $ON=1;
my $OFF=0;
my $PASS=1;
my $FAIL=0;
my $SETUP_IF_TMO = 5 * 60; # 5 minutes
my $NOFUNCTION="none";
my @junk = split( /\//, $0);
@junk = split('\.',$junk[$#junk]);
my $scriptFn = $junk[0];
#--->> The Following Macro is used for CLI options

my $MLT_CREATE="createsample";
my $MLT_EXECUTE="execute";
my $MLT_EXIT="exit";
my $MLT_DEAD = "dead";
my $MLT_CREATED = "CREATED";
#-----<<<----------------
my $DUMMY= "dummy";
#---->>> Used for Job status
my $JOB_NEW="new_job";
my $JOB_PENDING="pending_job";
my $JOB_DISP="dispatched_job";
my $JOB_QUEUE="queued_job";
my $JOB_DEL="deleted_job";
#----<<<<
my $OUTPUTLOG_SIZE=40 * 1024;
my $WAIT_PROCESS_TIME = 10; # ten seconds
my $path = $ENV{'SQAROOT'};
my $binver = $ENV{'G_BINVERSION'};
my %userInput = (
    "debug" => "0",
    "logdir"=>"./",
    "filename"=>$NO_FILE,
    "template"=>$NO_FILE,
    "scriptname"=> $scriptFn,
    "numofentries"=> 1,
    "screenOff"=> 0,
    "logOff"=> 0,
    "action"=>$MLT_EXECUTE,
    "connectPID"=>{}, # associative array which is indexed by testbed name
    "gcov"=>{}, # associative array which is indexed by subroutine name
    "process"=>{},
    "pidarray"=>[], # numerical array which is indexed by [0..n]
    "pipeRead"=>[], # numerical array which is indexed by [0..n]
    "pipeWrite"=>[], # numerical array which is indexed by [0..n]
    "resulthandle"=>0,
    "signal"=>$NOFUNCTION,
    );
#------------------------------------------------
# Create template 
#-----------------------------------------------
sub createMltTemplate {
    my ( $profFile, $data) = @_;
    my $log = $profFile->{logger};
    my $filename = $profFile->{template};
    my $numOfEntries = $profFile->{numofentries};
    my $rc = $PASS;
    my $i;
    my $msg = "Successfully create file $filename";
    #Import PC hosts variables.
    if ( defined $profFile->{gcov}{createMltTemplate} ) {
	$profFile->{gcov}{createMltTemplate} += 1;
    } else {
	$profFile->{gcov}{createMltTemplate} = 1;
    }
    $rc = open( MLT_FD,"> $filename");
    if ($rc == 0 ) {
	$msg = "Failed to create $filename";
	$rc = $FAIL;
	return($rc,$msg);
    }
    print MLT_FD ( "<multiprocess>\n");
    print MLT_FD ( "\t<desc> Need to insert description here </desc>\n");
    for ($i = 0; $i < $numOfEntries ; $i++) {
	print MLT_FD ("\t<process>\n");
	print MLT_FD ("\t\t<name>$i</name>\n");
	print MLT_FD ("\t\t<desc>$i</desc>\n");
	print MLT_FD ("\t\t<script>$i</script>\n");
	print MLT_FD ("\t\t<loop>1</loop>\n");  
	print MLT_FD ("\t\t<fatal>exit</fatal>\n");
	print MLT_FD ( "\t\t<passed>continue</passed>\n");
	print MLT_FD ("\t\t<flag>nodefined</flag>\n");
	print MLT_FD ( "\t</process>\n");
    }
    print MLT_FD ( "</multiprocess>\n");
    close MLT_FD;
    return($rc,$msg);
} 
#------------------------------------------------
# Parse Test Bed Config
#-----------------------------------------------
sub parseProcessTable{
    my ( $profFile, $data) = @_;
    my $kk;
    my $temp;
    my $index;
    my $rc=$PASS;
    my $key ;
    my $handle = $profFile->{resulthandle};
    my ($name,$desc);
    my $procPtr;
    my $log = $profFile->{logger};
    my $msg = "Successfully parsing process table ";
    my $ptr= \%{$profFile->{process}};
    my $gName = "parseProcessTable";
    #Import PC hosts variables.
    if ( defined $profFile->{gcov}{$gName} ) {
	$profFile->{gcov}{$gName} += 1;
    } else {
	$profFile->{gcov}{$gName} = 1;
    }
    if ( !(defined ($data->{process}) ) ) {
	$msg="No PROCESS TAG found";
	return($FAIL,$msg);
    }
    if ( !(defined ($data->{process} {name}) ) ) {
	foreach $index ( sort keys %{$data->{process}} ) {
	    # if process  is not defined then initialize process status 
	    if ( not defined $ptr->{$index}) {
		$ptr->{$index}{status} = $NOFUNCTION;
		$ptr->{$index}{msg} = $NOFUNCTION;
		$ptr->{$index}{pipeWrite} = $NOFUNCTION;
		$ptr->{$index}{pipeRead} = $NOFUNCTION;
		$ptr->{$index}{pid} = $NOFUNCTION;
		$ptr->{$index}{iteration} = 1;
		$ptr->{$index}{delay} = 0;
	    }
	    $ptr->{$index}{name} = $index;
	    foreach $kk ( sort keys %{$data->{process}{$index} } ) {
		$ptr->{$index}{$kk} = $data->{process}{$index}{$kk};
	    }
	}
    } else {
	$index = 0;
	# if process  is not defined then initialize process status 
	if ( not defined $ptr->{$index}) {
	    $ptr->{$index}{status} = $NOFUNCTION;
	    $ptr->{$index}{msg} = $NOFUNCTION;
	    $ptr->{$index}{pipeWrite} = $NOFUNCTION;
	    $ptr->{$index}{pipeRead} = $NOFUNCTION;
	    $ptr->{$index}{pid} = $NOFUNCTION;
	    $ptr->{$index}{iteration} = 1;
	    $ptr->{$index}{delay} = 0;
	}
	$ptr->{$index}{name} = $index;
	foreach $kk ( sort keys %{$data->{process} } ) {
	    $ptr->{$index}{$kk} = $data->{process}{$kk};
	}
    }
    $temp = " Process ID INITIAL Data ";
    ($rc,$temp) = printProcTbl($profFile,$temp,1);
    return($rc,$msg);
}


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

#-----------------------------------
# Parsing Xml Testbed profile 
#-----------------------------------
sub parsingXmlProcessFile {
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
    my $gName = "parsingXmlProcessFile";
    if ( defined $profFile->{gcov}{$gName} ) {
	$profFile->{gcov}{$gName} += 1;
    } else {
	$profFile->{gcov}{$gName} = 1;
    }  
    if ($profFile->{debug} > 2 ) {
	$temp = Dumper($data) ;
	$log->info( $temp );
    }
    if (defined ($data->{desc})) {
	my $temp = $data->{desc};
	$log->info( "Description:$temp") if (  $profFile->{debug} > 2 ) ;
    }
    ($rc,$msg)= parseProcessTable($profFile,$data);
    if ( $rc == $FAIL ) {
	$log->info($msg);
    }
    return ($rc,$msg);
}

#-------------------------------------------------------
# Set up Child Process
#--------------------------------------------------------
sub launchCmd {

    my ($profFile,$testLog,$cmd,$tmo) = @_;
    my $rc = $PASS;
    my $log = $profFile->{logger};
    my $retry = 1;
    my $localRetry =1;
    my $wait = 5;
    my $temp = 0;
    my @buff;
    my $msg;
    my $log = $profFile->{logger};
    my $exp=Expect->spawn($cmd);
    my $gName = "launchCmd";
    if ( defined $profFile->{gcov}{$gName} ) {
	$profFile->{gcov}{$gName} += 1;
    } else {
	$profFile->{gcov}{$gName} = 1;
    }

    $exp->log_file( "$testLog","w");
    $exp->expect($tmo,
		 [
		 timeout =>
		 sub {
		     $rc = $FAIL; #failed
		     $msg = "Error: Timeout--$cmd";
		     return($rc,$msg);
		 }
		 ],
		 [ eof => sub { print "EOF \n"; $rc = 1} ],		 
	);
    $rc = $exp->exitstatus();
    $exp->log_file();    
    $exp->soft_close();    
    if ( $rc == 0) {
	$rc = $PASS;
	$msg = "Successful to execute $cmd ";
	
    } else {
	$rc = $FAIL;
	$msg = "Failed to execute $cmd  "; 
    }
    return ($rc,$msg);
}
#---------------------------------------------------
# This routine is used to print table of all Process
#---------------------------------------------------
sub printProcTbl {
    my ( $profFile,$data,$saveFlag)=@_;
    my $rc = $PASS;
    my $log = $profFile->{logger};
    my ($name,$desc,$kk);
    my $index;
    my $handle = $profFile->{resulthandle};
    my $msg = "Successfully  print all process entries";
    my $ptrProc = \%{$profFile->{process}};
    my $temp = "----------------------------------------";
    print $handle ("$temp\n");
    print $handle (" $data\n");
    print $handle ("$temp\n");
    foreach  $index ( sort keys  %{$ptrProc} ) {
	$name = $ptrProc->{$index} {name};
	$desc = $ptrProc->{$index} {desc};
	$temp = "Process($name) -- Description = $desc";
	$log->info($temp );
	print $handle ("$temp\n") if ( $saveFlag );
	foreach $kk ( sort keys %{$ptrProc->{$index}} ) {
	    $temp = $ptrProc->{$index}{$kk};
	    $temp = "  \<$kk\>=$temp";
	    print $handle ("$temp\n") if ( $saveFlag );
	    $log->info($temp) ;
	}
    }
    return($PASS,$msg);


}
#---------------------------------------------------
# This routine is used to fork a single process
#---------------------------------------------------
sub forkSingleProcess {
    my ( $profFile,$index)=@_;
    my $rc = $PASS;
    my $log = $profFile->{logger};
    my ($id, $temp,$cmd,$wHd);
    my $handle = $profFile->{resulthandle};
    my $msg = " ForSingleProcess: successfully Fork the process index=$index" ;
    my $ptrProc = \%{$profFile->{process}};
    #-------------------
    $cmd = $ptrProc->{$index} {script};
    $ptrProc->{$index}{pipeWrite}="Write".$index; 
    $ptrProc->{$index}{pipeRead}="Read".$index;
    $log->info("Launch process \[$index\]=$cmd");
    no strict;
    pipe  $ptrProc->{$index}{pipeRead},*{ $ptrProc->{$index}{pipeWrite} } or die " Could not open pipe $ptrProc->{$index}{pipeWrite} \n" ;
    use strict;
    $id = fork();
    die "FORK Failed \n" unless defined ($id) ;
    if ($id) {
	close $ptrProc->{$index}{pipeWrite};
	$log->info("process PID=$id just created") if ( $profFile->{debug}>2);
	$ptrProc->{$index}{pid} = $id;
	$ptrProc->{$index}{status}=$MLT_CREATED;
	$log->info( "Fork Child ID $id\n") ;
    }else {
	# Child process always has pid = 0 
	close $ptrProc->{$index}{pipeRead};
	$log->info( "--current process \#$index: $cmd \n"); #  if ( $profFile->{debug} > 2  );
	$wHd =  $ptrProc->{$index}{pipeWrite};
#	$rc = system("$cmd");
	$temp = $ptrProc->{$index}{delay};
	if ( $temp != 0 ) {
	    $log->info( "Child (ID=$id) sleep $temp \n") ;
	    sleep $temp;
	    
	}
	
	$temp =`$cmd`;
	$rc = $?;
#	$rc = $rc & 0xff;
	#exit code;
	$rc = $rc >> 8;
	if ($rc!=0){
	    no strict;
	    print  $wHd  "\[$temp WriteChild($index) rc=$rc RC=Failed \]" ;
	    use strict;
	} else {
	    no strict;
	    print  $wHd  "\[$temp WriteChild($index) rc=$rc RC=Passed \]" ;
	    use strict;
	}
	print "Child($index) exit\n" ; 
	exit(0);
    } 
    return ($rc,$msg);
}
#---------------------------------------------------
# This routine is used to fork all process
#---------------------------------------------------
sub forkAllProcess {
    my ( $profFile,$data)=@_;
    my $rc = $PASS;
    my $log = $profFile->{logger};
    my $i = 0;
    my $temp;
    my $index;
    my $handle = $profFile->{resulthandle};
    my $msg;
    my $ptrProc = \%{$profFile->{process}};
    foreach $index (keys %{$ptrProc}){
	($rc,$msg)  = forkSingleProcess($profFile,$index);
	return ($rc,$msg) if ( $rc == $FAIL) ;
	$i++;
    }
    print $handle "NUMBER_OF_PROCESS=$i has been launched\n";
    $msg = $i;
    # Save data to Result File 
    $temp = " Process ID Data ";
    ($rc,$temp) = printProcTbl($profFile,$temp,1);
    return($PASS,$msg);
}

#-----------------
# get process ID 
#-----------------
sub getProcessPID
{
    my ($profFile,$childId) = @_;
    my $log = $profFile->{logger};
    my $line  = '';
    my %processId=();
    my @temp;
    open(FILE2_DES,"ps -ef|") or die " Could not process ps -ef $! ";
    while ( $line = <FILE2_DES>  ) {
	@temp = split( ' ',$line );
	$log->info( "Org: $line\nUID=$temp[0], PID=$temp[1], PPID=$temp[2]\n") if ( $profFile->{debug} > 2 ) ;
	$processId{$temp[1]} = $temp[2];
    }
    close (FILE2_DES); 
    return %processId;   
}
#---------------------------------------
# Check Process id and return the index 
#---------------------------------------
sub checkProcId {
    my ($profFile,$childId) = @_;
    my $ptrProc = \%{$profFile->{process}};
    my $msg = "$childId is not found";
    my $index;
    my $log = $profFile->{logger};
    foreach $index (keys %{$ptrProc}) {	
	if ( $ptrProc->{$index} {pid} == $childId ) {
	    $msg = $index;
	    return($PASS,$msg);
	}
    }
    return($FAIL,$msg);
}
#--------------------------------------------
# This routine is used to send sigkill to all
# process 
#--------------------------------------------
sub killAllProcess {
    my ($profFile,$data) = @_;
    my $filehandle= $profFile->{resulthandle};
    my $ptrProc = \%{$profFile->{process}};
    my $rc = $PASS;
    my $log = $profFile->{logger};
    my $msg = " Successfully killall Child Process";
    my $stdInput ;
    my $chId;
    my $index;
    my $pid;
    my $procid;
    my %childId;
    my $childid;
    my $flag ;
    my %processId = &getProcessPID($profFile);
    foreach  $index ( keys %{$ptrProc}){
       # Get PID of each process
	$pid = $ptrProc->{$index} {pid};
	#------------------------				
	# Create initial %childId
	#------------------------
	foreach $procid (keys %processId ) {
	    $log->info( "PID= $procid, PPID=$processId{$procid}") if ( $profFile->{debug} > 4 ) ;
	    if ($procid eq $pid) {
		$childId{$pid} = $processId{$procid};
		next;
	    }
	    if ($processId{$procid} eq $pid) {
		$childId{$procid} = $pid;
	    }
	}
	if ( $profFile->{debug} > 2  ) {
	    foreach $childid (keys %childId ) {
		$log->info( "INITIAL: childID: $childid, parentID: $childId{$childid}");
	    }
	}
	#------------------------				
	# Build up %childId
	#------------------------
	$flag = 1;
	while ( $flag > 0 ) {
	    $flag = 0;
	    foreach $procid (keys %processId ) {
		foreach $childid (keys %childId ) {		
		    if ($processId{$procid} eq $childid) {
			if ( !(defined $childId{$procid}))  {
			    $childId{$procid} =$childid;
			    $flag ++;
			}
		    }
		}	
	    }
	}
    }

    
    #------------------------				
    # Kill Child Process
    #--------------------
    foreach $childid (keys %childId ) {
	print "ChildID: $childid, ParentID: $childId{$childid}\n";
	print "   Kill process $childid\n";
	kill(SIGKILL,$childid);
    }
    foreach $index ( keys %{$ptrProc}) {
	$stdInput = "STDIN".$index;
	close $stdInput ;
    }
    return ($rc,$msg);
}


#---------------------------------------------------
# Launch all jobs and check their status
#---------------------------------------------------
sub jobLaunch {
    my ($profFile,$data) = @_;
    my $filehandle= $profFile->{resulthandle};
    my $ptrProc = \%{$profFile->{process}};
    my $rc = $PASS;
    my $log = $profFile->{logger};
    my $retry = 1;
    my $localRetry =1;
    my $wait = 5;
    my $doneflag = 0;
    my $msg;
    my $msg2;
    my $tempChild = 0;
    my $doneFlag = 1;
    my $stdInput ;
    my $chId;
    my $j;
    my $index;
    my $pid;
    my $numOfProc;
    my $tempChildId;
    my $childIndex;
    my $line;
    my $line2;
    my $loop;
    my $iteration;
    my $globalRc = 0;
    my $currentRC = 0;
    my $MustDone = 0;
    my $numMust = 0;
    my $allowExit = 0;
    my $exitHappen = 0;
   
    #----------------------
    # Launch Child Process
    #----------------------
    ($rc,$msg) = forkAllProcess($profFile);
    if ( $rc == $FAIL ) {
	return($rc,$msg);
    }
    # Save number of launched processes 
    $numOfProc = $msg;

    # Summary number of flag 
    my $ptr = \%{$profFile->{process}};
    foreach  my $inx ( sort keys  %{$ptr} ) { 
          if ( $ptr->{$inx}{flag} ) {
             $numMust++;
          }
    }

    #-----------------------------------------------
    # Create standard Input pipe from ChildProcess
    #-----------------------------------------------
   no strict;
    foreach $index ( sort keys %{$ptrProc} ) {
	$stdInput = "STDIN".$index;
	open($stdInput , "<&=" . fileno( $ptrProc->{$index} {pipeRead} ) ) or die " could not open STDIN for parent $index\n";
	
    }
    use strict;
    #---------------------------------------------------------
    # when one child process failed, kill all child processes
    #---------------------------------------------------------
    while ( $doneFlag && ($userInput{'signal'} !~ /$MLT_EXIT\b/ ) ) {
	$tempChildId = waitpid(-1, WNOHANG);
	next if ( $tempChildId < 1 );
	$log->info ( "==>Exit Child ID $tempChildId " );
	($rc,$msg) = checkProcId($profFile,$tempChildId);
	if ( $rc == $FAIL ) {
	    ($rc,$msg2) = killAllProcess($profFile);
	    return($FAIL,$msg);
	}
	# get index of $ptrProc
	$childIndex = $msg;
	$ptrProc->{$childIndex} {status} = $MLT_DEAD;
	$stdInput = "STDIN".$childIndex;
	$currentRC= 0;
	#------------------------------------------
	# Get the output sent from the Child Process
	#------------------------------------------
	$loop = $ptrProc->{$childIndex} {loop};
	$iteration = $ptrProc->{$childIndex} {iteration};
	$line2="";
	while ($line = <$stdInput>) { 
	    $line2 .=$line;
	}
	if ($line2 =~ /RC=Failed/){
	    $msg =  "\[PIPE\] index($childIndex) Process \#$tempChildId with child process ($tempChildId) failed at iteration $iteration\nResult=\[$line2\]";
	    print $filehandle "$msg\n" ;
	    $log->info("$msg");
	    $globalRc++;
	    $currentRC= 1;
	    if ( $ptrProc->{$childIndex} {fatal} =~ /exit/i) {
		$msg = "\[PIPE\] index($childIndex) Process \#$tempChildId with child process ($tempChildId ) is killed ";
		$log->info( $msg);
		print $filehandle "$msg\n";
		($rc,$msg) = killAllProcess($profFile);
		$doneFlag = 0;

		$msg = "Multiple Processes Test Failed \n";
#		$log->info( $msg);
		print $filehandle "$msg\n";
		return($FAIL,$msg);
	    }
	}
	
   
        # end of while 	
	if ( $loop <= 1 ) {
	    # check if the passed stage required to exist
	    $msg= "\[PIPE1\] index($childIndex) Process \#$tempChildId with child process ($tempChildId) is ";
	    $msg  .=  $ptrProc->{$childIndex}{passed}." !!!" ;
	    $log->info( $msg);
           
            if ($ptrProc->{$childIndex}{flag} and $ptrProc->{$childIndex}{flag} =~ /must\b/i ) {
            	$MustDone += 1;
            }

            if ( $MustDone == $numMust ) {
                $allowExit = 1;
            }

            if ( $ptrProc->{$childIndex}{passed} =~ /exit\b/i ) {
                $exitHappen = 1;
            }
	    
	    if (( $ptrProc->{$childIndex}{passed} =~ /exit\b/i and $allowExit == 1 ) or ( $exitHappen == 1 and $allowExit == 1 )){
		$msg= "\[PIPE2\] index($childIndex) Process \#$tempChildId with child process ($tempChildId) is killed";
		print $filehandle "$msg\n";
		($rc,$msg) = killAllProcess($profFile);
		$doneFlag = 0;
		$rc = $PASS;
		$msg = "Multiple Processes Test Passed \n";
		if ( $globalRc > 0 ) { 
		    $rc =$FAIL;
		    $msg = "Multiple Processes Test Failed \n";
		}
		print $filehandle "$msg\n";
		return($rc,$msg);
	    }
	    
	} else { 
	    
	    # Keep launching the next thread  
	    if ( $currentRC == 0 ) {
		$msg = "\[PIPE\] index($childIndex) Process \#$tempChildId with child process ($tempChildId) passed at iteration $iteration\n$line2";
		$log->info( $msg);
		print $filehandle "$msg\n";
	    }
	    $ptrProc->{$childIndex} {loop} -= 1; 
	    $ptrProc->{$childIndex} {iteration} +=1;
	    $iteration = $ptrProc->{$childIndex} {iteration};
	    ($rc,$msg)  = forkSingleProcess($profFile,$childIndex);
	    no strict;
	    # create an output pipe of the child process
	    open($stdInput , "<&=" . fileno( $ptrProc->{$childIndex} {pipeRead} ) ) or die " could not open STDIN for parent $index\n";
	    use strict;
	    return ($rc,$msg) if ( $rc == $FAIL);
	}
#    sleep 1;


	$doneFlag = 0;
	foreach $index ( keys %{$ptrProc} ) {
	    if ( $ptrProc->{$index} { status } !~ /$MLT_DEAD\b/ ) {
		$doneFlag = 1;
	    }
	}
    }
    if ( $profFile->{'signal'} =~ /$MLT_EXIT\b/ ) { ($rc,$msg) = killAllProcess($profFile);}
    $rc = $PASS;
    $msg = "Multiple Processes Test Passed \n";
    if ( $globalRc > 0 ) { 
	$rc =$FAIL;
	$msg = "Multiple Processes Test Failed \n";
    }
    print $filehandle "$msg\n";
    return ($rc,$msg);
}



#---------------------------------------------------
# SIGKILL Handler
#---------------------------------------------------
sub setExitFlag {
    my $gName = "setExitFlag";
    if ( defined $userInput{gcov}{$gName} ) {
	$userInput{gcov}{$gName} += 1;
    } else {
	$userInput{gcov}{$gName} = 1;
    }
    $userInput{logger}->info("----------->KILL SIGNAL received");
    $userInput{'signal'} = $MLT_EXIT;
    return;
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
my $msg;
my $key;
my $temp;
my @commands = ();
my $globalRc = 0;
my $option_man = 0;
my $jobid =0 ;
my $notdone;
my $count;
$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man, 
		  "l=s"=>sub {  $userInput{logdir} = $_[1]; },
		  "c=s"=>sub { $userInput{action} = $MLT_CREATE; $userInput{numofentries} = $_[1];},

		  "o=s"=>sub { $userInput{template} = $_[1]},
		  "f=s"=>sub { $userInput{filename}=$_[1];$userInput{action} = $MLT_EXECUTE; },
		  "v=s"=>sub { if ( exists $commands[0] ) { push (@commands,$_[1]); } else {$commands[0]=$_[1]; } } ,
		  );

#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);


#print("--------------- Input Parameters  ---------------\n") if $userInput{debug} ;
print("--------------- $scriptFn  Input Parameters  ---------------\n");
foreach $key ( keys %userInput ) {
#    print (" $key = $userInput{$key} :: " ) if $userInput{debug} ;
    print (" $key = $userInput{$key} :: " );
}
my $limit = @commands;
if ($limit != 0 ) {foreach my $line (  @commands) { print "$line \n"; } };
#---------------------------------------------
# Initialize Logger 
#---------------------------------------------
($rc,$msg) = initLogger(\%userInput, );
if ( $rc != 1) {
    print ("RC$rc $msg\n");
    exit 1;
} 
#-------------------------------------
# Switch between action
#-------------------------------------
for ($userInput{action} ) {
#-------------------
# Submit jobs
#-------------------
    /$MLT_EXECUTE/ && do {
	if ( $userInput{filename} =~ /$NO_FILE/ ) {
	    $msg = "Error= please enter filename ";
	    $userInput{logger}->info("$msg");
	    pod2usage(1) if ( $option_h );
	    exit 1;
	}
	$temp = `ls $userInput{filename}`;
	$temp =~ s/\n//;
	if ( $temp =~ /cannot access/ ) {
	    $msg = "Error= $userInput{filename} could not be found  ";
	    $userInput{logger}->info("$msg");
	    exit 1;
	}


	if ( $userInput{template} =~ /$NO_FILE\b/ ) {
	    $notdone = 1 ;
	    $count = 1;
	    while ( $notdone ) {
		$userInput{template} = $userInput{logdir}."/".$userInput{scriptname}."_result_".$count."\.txt";
		$temp = `ls  $userInput{template}`;
		$temp =~ s/\n//;
		if ( $temp =~ /^\s*$/ ) {
		    $msg = "$userInput{template} is created ";
		    $temp = `touch $userInput{template}`;
		    $temp = `ls  $userInput{template}`;
		    $temp =~ s/\n//;
		    $notdone = 0;
		    next;
		}
		$count ++;
	    }
	} else {
		$userInput{template} = $userInput{logdir}."/".$userInput{template};
	}
	$temp = $userInput{template};
	$temp = `touch $temp`;
	$temp = `ls $userInput{template}`;
	$temp =~ s/\n//;
	if ( $temp =~ /cannot access/ ) {
	    $msg = "Error= $userInput{template} could not be found  ";
	    $userInput{logger}->info("$msg");
	    exit 1;
	}
	$userInput{template} = $temp;
	$msg = " Result  file is saved to $temp";
	$userInput{logger}->info("$msg");
	
	open ( TEMPFD,">$userInput{template}") or die " Could not open $userInput{template}";
	$temp = `date +%Y%m%d%H%M%S`;
	$temp =~ s/\n//;
	print TEMPFD "------------------------------------------------------\n";
	print TEMPFD " Result File for inputfile\[$userInput{filename}\] \n YYYYMMDDHHMMSS=$temp\n";
	print TEMPFD "------------------------------------------------------\n";
	$userInput{resulthandle} = *TEMPFD;
	#-------------------------------------------------
	#Parsing input file from Management Frame Work  
	#-------------------------------------------------
	($rc,$msg) = parsingXmlProcessFile(\%userInput );
	if ( $rc == $FAIL) {
	    close $userInput{resulthandle} ;
	    $userInput{logger}->info("$msg");
	    last;
	}
	print TEMPFD "------------------------------------------------------\n";
	#-----------------------------
	# Register SIG kill handler
	#------------------------------

	$SIG{KILL}=\&setExitFlag;
	$SIG{HUP}=\&setExitFlag;
	$SIG{QUIT}=\&setExitFlag;
	$SIG{INT}=\&setExitFlag; # for control C
	$SIG{TRAP}=\&setExitFlag; # for control C
	($rc,$msg) = jobLaunch(\%userInput );
	close $userInput{resulthandle} ;
	last;
    };
     #-----------------------------
     #Display Job log in long form 
     #-----------------------------
    /$MLT_CREATE/ && do {
	if ( $userInput{template} =~ /$NO_FILE/ ) {
	    $notdone = 1 ;
	    $count = 1;
	    while ( $notdone ) {
		$userInput{template} = $userInput{logdir}."/".$userInput{scriptname}."_outfile_".$count."\.txt";
		$temp = `ls  $userInput{template}`;
		$temp =~ s/\n//;
		if ( $temp =~ /^\s*$/ ) {
		    $msg = "$userInput{template} is created ";
		    $temp = `touch $userInput{template}`;
		    $temp = `ls  $userInput{template}`;
		    $temp =~ s/\n//;
		    $notdone = 0;
		    next;
		}
		$count ++;
	    }
	    $userInput{template} = $temp;
	    $msg = " Output file is saved to $temp";
	    $userInput{logger}->info("$msg");
	} else {
		$userInput{template} = $userInput{logdir}."/".$userInput{template};
	}

	($rc,$msg)= createMltTemplate (\%userInput);
	if ( $rc == $FAIL) {
	    last;
	}
	displayGcov(\%userInput ) if ($userInput{debug} > 2 );
	last;
    };
    $userInput{logger}->info( " Unrecognize action value : $userInput{action} ");
    pod2usage(1) if ( $option_h );
    exit 1;
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

mltprocess.pl - is the utility to launch multiple processes at the same time. All the processes need to be defined in the xml form. 

=head1 SYNOPSIS

=over 12

=item B<mltprocess.pl>
[B<-help|-h>]
[B<-man>]
[B<-c> I<create a template xml profile with a given number of entries>]
[B<-o> I<create a template xml profile with different name from default file (mltprocess_infile_x.xml>]
[B<-f> I<multi process xml profile>]
[B<-l> I<log file path>]
[B<-x> I<debug level>]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-c>

Create an output file with a given name 


=item B<-f>

Specify a multi process  file.

=item B<-l >

Redirect stdout to the /path/mltprocess.log

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-x>

Set debug to different level . ( more debug messages with higher number)

=head1 DESCRIPTION

B<tbdispatcher.pl> will allow user to launch jobs, query status of each testbed/tb type and its job queues.


=head1 EXAMPLES

1. The following command is used to launch a multi process file
         perl mltprocess.pl -f test123.xml

2. The following command is used to save all logs to a specific directory
         perl mltprocess.pl -f test123.xml -l /tmp

3. The following command is used to create a template file ( with default name mlt_process_infile_1.xml) of 20 entries and save in /tmp directory
        perl mltprocess.pl -c 20 -l /tmp 

4. The following command is used to create a text456.xml template file  of 20 entries and save in /tmp directory
        perl mltprocess.pl -c 20 -l /tmp -o test456.xml


=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut

