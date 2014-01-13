#!/usr/bin/perl -w
#---------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to launch test suites and 
# record their output to a log directory $XXXX.log ( e.g $SQAROOT/logs ) 
# 
#CVS Tag:
#$Date:$
#$Revision:$
#$Header:$
# To DO:
# - Run Test case by selection ( range from-to) 
# - Run in back ground during processing a test case
#
# Change history:
#  * Add handle MySQL.
#           Hugo 04/2010
#  * 
#
#
#--------------------------------

use strict;
use warnings;
use diagnostics;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use XML::Simple;
use Data::Dumper;
use Log::Log4perl;
use IO::Handle;
use Expect; 
use threads;
use FindBin;
use lib "$FindBin::Bin/./"; 
use Gfdaemon::Operate_TableTestResult;

#Initialize main variables
my $G_KEYENV=\%ENV;
my $FAIL=0;
my $PASS=1;
my $FAIL_MSG="fail";
my $PASS_MSG="pass";
my $OFF= 0;
my $ON = 1;
my $NODESC="no description";
#These MACRO are used for specific routine.
my $SP_FAIL = 1;
my $SP_PASS = 0;
my $SQAROOT= $ENV{'SQAROOT'};
my $numberOfTcPass =0 ;
my $numberOfTcFail =0 ;
my $numberOfNcPass =0 ;
my $numberOfNcFail =0 ;
my $numberofIc = 0;
my $NO_FILE= "No File specified";
my $NOFUNCTION="nofunction";
my $DEF="Vardefined";
my $DEVNULL= "/dev/null";
#---------------------------------------------------------------
# This table is used to check the required necessary environment
# for gflaunch.pl
#----------------------------------------------------------------
my %gflaunch_globalVar= (
    "G_USER"=>$DEF,
    "G_BUILD"=>$DEF,
    "G_TP_DIR"=>$DEF,
    "G_PROJID"=>$DEF,
    "G_BUILDID"=>$DEF
);

my $gfTMO = 30 * 60; # 30 minutes 
my %gflaunch_userInput = ( "user"=>"admin",
    "debug"=>0,
    "screenOff"=>0,
    "template"=>$NOFUNCTION,
    "numofentries"=>1,
    "logOff"=>0,
    "logdir"=>"$SQAROOT/logs",
    "ftplogdir"=>"/qatest/automation/logs",
    "httplogdir"=>"/logs",
    "ncfail"=>"0",
    "ncpass"=>"0",
    "tcfail"=>"0",
    "tcpass"=>"0",
    "filename"=>$NO_FILE,
    "tcase"=>[],
    "env"=>{
        "G_TMO"=>$gfTMO,
        "G_FTP_SERVER"=>"G_FTP_SERVER_is_not_defined_in_bashrc",
        "G_HTTP_SERVER"=>$NOFUNCTION,
        "G_CURRENTLOG"=>$NOFUNCTION ,
        "G_NOPFGREP"=>$OFF,
        "G_FWVERSION"=>$NOFUNCTION,
        "G_TST_TITLE"=>$NOFUNCTION,
        "G_HW_SERIAL"=>$NOFUNCTION,
        "G_HW_REV"=>$NOFUNCTION,
        "G_PROD_TYPE"=>$NOFUNCTION,
        "G_FORCE_REC"=>$NOFUNCTION,
        "G_CC"=>"",
    },
);

#--------------------------------------------------
# Insert testcase run-result to Database
#
#--------------------------------------------------
sub insertDB {
    my ($tid, $tsult, $bugid, $cment, $tlog, $tdur) = @_ ;
    my $dbip = $ENV{'G_DATABASE_SERVER'};
    my $dbuser = 'actiontec';
    my $dbpasswd = 'actiontec';
    my $dbname = 'ATLAS';
    my $dbtable = 'testresult';
    my $dbtbed = $ENV{'MY_TB'};
    Gfdaemon::Operate_TableTestResult->conn_db($dbip, $dbuser, $dbpasswd, $dbname, $dbtable, $dbtbed);
    Gfdaemon::Operate_TableTestResult->insert_tcresult($tid, $tsult, $bugid, $cment, $tlog, $tdur);
    Gfdaemon::Operate_TableTestResult->dis_conn_db();
}

#--------------------------------------------------
# This subroutine is used to set up logdir 
# Success: RC= 1
#---------------------------------------------------
sub setupLogdir {
    my ($profFile,$junk) = @_;
    my $rc = $PASS;
    my $msg = "Successfully creating log directory ";
    my @junk;
    my $temp;
    my $link;
    my $i;
    my $jj;
    my $notfound;
    my $count;
    my $limit = 0;
    my $logName="logs";
    my $match = 0;
    if ( !(-d $profFile->{logdir}) ) {
        $rc = system("mkdir  $profFile->{logdir} ");
        if ( $rc != 0) {
            $rc = 0;
            $msg = "Error in creating log directory $profFile->{logdir} ";
            return ($rc,$msg);
        }
    }
# Search for next available directory
    $rc = `ls -1 $profFile->{logdir}`;
    @junk = split("\n",$rc);
    $limit = @junk;
    $match = 0;
    for ( $i = 0;  $i <= $#junk; $i++) {
        $temp = "logs".$i;
        $notfound = 1;
        $jj=0;
        $count = 0;
        while( $notfound && ($jj <= $#junk) ) { 
                if ( $junk[$jj] !~ /$logName/ ) {
                    $jj++;
                    next;
                }
                if ( $junk[$jj] =~ m/^$temp$/ ) {
                    $notfound = 0;
                    last;
                }
                $jj++;
                $count++;

            }
            if (( !$notfound ) && ($jj <=$#junk) ) {
                    next;
                }
                $limit = $i;
                last;
            } 

            $temp= $profFile->{logdir}."/logs".$limit;
            $rc = system("mkdir  $temp");
            if ( $rc != 0) {
                $msg = "Error in creating log directory $temp ";
                return(0,$msg);
            }
            $link = $profFile->{logdir}."/current";
            $rc = system("rm -f $link");
            $rc = system("ln -s $temp $link");
            if ( $rc != 0) {
                $msg = "Error in creating log directory $temp ";
                return($FAIL,$msg);
            }
            $rc = $PASS;
            $profFile->{logdir}=$temp;
            #Reexport $G_LOG

            $msg = $msg." $profFile->{logdir}";
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
            my $localLog = $profFile->{logdir}."/gflaunch_info.log";
            my $clobberLog = $profFile->{logdir}."/gflaunch_clobber.log";
            # layout: date-module + line mumber -(info,debug,warn,error,fatal)> message +  new line 
            my $layout = Log::Log4perl::Layout::PatternLayout->new("%d--%F{1}:%L--%M--%p> %m%n");
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
#-------------------------------------------
# Get directory path name
#-------------------------------------------
        sub getPathName{
            my ($path,$junk) = @_;
            my @t1;
            @t1=split("/",$path );
            $junk = $t1[$#t1];
            if ($#t1 > 0 ) {
                $path =~ s/$junk//;
            } else {
                $path = $junk;
            }
            return ($path);
        }


#-------------------------------------------
# Replace variables for xml code section
#-------------------------------------------
        sub replaceVar {
            my ( $profFile, $testcase, $varArrayPtr) = @_;
            my $rc = $PASS;
            my $msg;
            my $var;
            my @buff=();
            my $found;
            my $temp;
            my $log= $profFile->{logger};
            my $tc = $testcase." "; 
            if ($#{$varArrayPtr}<0) {
                $log->info("Org=$testcase \nConvert=$tc") if ($profFile->{debug} > 3 );
                return ($rc,$tc);
            }

            do {
                $found = 0;
                foreach $var ( @{$varArrayPtr} ) {
                    if ($var =~ /^\s*$/) {
                        next;
                    }

                    @buff= split("=",$var);
                    $buff[0]=~ s/\s//g;
                    $buff[0]=~ s/\$//g;
                    $buff[0]=~ s/\t//g;
                    $temp = $buff[0];
                    if ( !(defined $buff[1])) {
                        next;
                    }
                    $buff[1]=~ s/;//g;
                    $buff[1]=~ s/\"//g;
                    $log->info( "START TC=$tc -- \nBuff0=$buff[0]--$buff[1]  Array Input  = \[$var\] ") if ( $profFile->{debug} > 3 );

#	    if ( $tc =~ /\$$temp\s*$/) {
                    if ( $tc =~ /\$$temp\b/) {
                        $found = 1;
                        $tc =~ s/\$$temp\b/$buff[1]/g;
                        $log->info( "Found TC=$tc -- \nBuff0=$temp--$buff[1]  Array Input  = \[$var\] ") if ( $profFile->{debug} > 3 );	
                    }
                }
            } while ( $found );
            $log->info("Org=$testcase \nConvert=$tc") if ($profFile->{debug} > 3 );
            return ($rc,$tc);
        }
#-------------------------------------------
# Built export string
#-------------------------------------------
        sub buildEnvString {
            my ( $profFile,$junk) = @_;
            my $rc = $PASS;
            my $msg="ReplaceEnv: no seconds reference found";
            my $var="";
            my @buff=();
            my $found;
            my $temp;
            my $temp1;
            my $envKey;
            my $newEnv;
            my $log= $profFile->{logger};
            foreach  $envKey ( keys %ENV ) {
                $temp = $ENV{$envKey};

                if($temp)
                {
                    next if ( $temp =~ /^\s*$/);
                    $var .= "export ".$envKey."="."\"$temp\"".";";
                    $profFile->{env}{$envKey} = $temp;
                }
            }

            $log->info($var) if ( $profFile->{debug} > 3);
            $msg =$var;

            return ($rc,$msg);
        }

#-------------------------------------------
# Replace variables for xml code section
#-------------------------------------------
        sub replaceEnv {
            my ( $profFile, $envInput) = @_;
            my $rc = $PASS;
            my $msg="ReplaceEnv: no seconds reference found";
            my $var;
            my @buff=();
            my $found;
            my $temp;
            my $temp1;
            my $envKey;
            my $newEnv;
            my ($envVar,$envValue,my @end)=split("=",$envInput);
            $envValue = "" if ( not defined $envValue); 
            foreach my $str (@end)
            {
                $envValue = $envValue."=".$str;
            }
            my $log= $profFile->{logger};
            foreach  $envKey ( keys %ENV ) {

#	if ( $envValue =~ /$envKey[\s|\/]*/) {
                if ( $envValue =~ /$envKey\b/) {
                    $temp = $ENV{$envKey};
                    $var = $temp;
                    $temp1 = $envValue;
                    $envValue =~ s/\$$envKey\b/$temp/;

#	    $log->info("Key=$envKey=$var:Org=\[$temp1\] --- TEMP=\[$envValue\]");

                    $msg="Found $envKey ";
                }

            }
            $profFile->{env}{$envVar} = $envValue;
            $ENV{$envVar}=$envValue;
#    $log->info("replaceEnv=>Org=\[$envInput\] \nConvert=\[$envVar=$envValue\]") if ($profFile->{debug} > 3 );

            return ($rc,$msg);
        }


#-----------------------------------------------
# Change $variable  with Environment Variables  
#-----------------------------------------------
        sub subEnv {
            my ($profFile, $testcase) = @_;
            my $rc = $PASS;
            my $env = $profFile->{env};
            my $msg;
            my $var;
            my $log = $profFile->{logger};
            my $temp ;
            my $found = 0;
            my $tc = $testcase; 
            do {
                $found = 0;
                foreach $var ( sort keys %{$env} ) {
                    $temp = $env->{$var};
                    $log->info( "TEMP = \[$var\]=$temp\nTESTCASE:$tc   \n") if ( $profFile->{debug} > 5 );
                    $temp = $var;
                    if ( $var =~ /^$/) { next ; } 
                    if ( $tc =~ /\$$temp\b[\s|\/]*/) {
                        $found = 1;
                        $tc =~ s/\$$temp\b/$env->{$var}/;
                        $log->info ( "FOUND TEMP  =$temp\nTESTCASE:$tc \n") if ( $profFile->{debug} > 5 );
                    }
                }
            } while ( $found );
#    if ( $tc =~ /\$/ ) {
#	$tc =" SubEnv Failed to match : Org=$testcase \n $tc"; 
#	$rc = 0;
#	return ($rc,$tc);
#    }
            $log->info("Org=$testcase \nConvert=$tc\n") if ($profFile->{debug} > 3 );
            return ($rc,$tc);
        }

#-------------------
# Parsing Xml File 
#-------------------
        sub parsingXmlFile {
            my ($profFile, $tc,$tcIndex) = @_;
            my $rc = $PASS;
            my $msg = " Parsing XML file succeeded ";
            my @tcaseVar;
            my $xx;
            my $yy;
            my $temp;
            my $temp2;
            my %sArray=();
            my $log = $profFile->{logger};    
            my $kk;
            my $index;

            #----------------------------------------------
            # Replace GLOBAL variable with absolute path
            #---------------------------------------------
            $tc=~ s/\n//;
            @tcaseVar = split(";",$tc); 
            # create object
            $tcaseVar[0]=`ls $tcaseVar[0]`;
            $tcaseVar[0]=~s/\n//;
            if (!( -e $tcaseVar[0])) {
                $msg= " Error: $tc could not be found";
                return($FAIL,$msg);
            }
            my $xmlFile = new XML::Simple;
            #Read in XML File
            my $data;
            eval {$data = $xmlFile->XMLin($tcaseVar[0])};
            if (!defined $data ) {
                $msg= " Error:Test case $tcaseVar[0] has BAD XML format ";
                $rc=$FAIL;
                return($rc,$msg);
            }
            #printout output
            if ($profFile->{debug} > 3 ) {
                $temp = Dumper($data) ;
                $log->info( $temp );
                if (ref($data->{stage}{step}) eq "HASH") {
                    $log->info( " parse: $data->{stage}{step} is a reference to a hash.\n");
                }
                unless (ref($data->{stage}{step})) {
                    $log->info( "parse: $data->{step} is not a reference at all.\n");
                }
            }
#----
            if (defined ($data->{name})) {
                $temp2 = $data->{name};

                if ( $temp2 !~ /HASH/ ) {
                    $temp = $data->{name};
                }
                $log->info( "parse: Description=> $temp.\n") if ( $profFile->{debug}>3);
                $profFile->{tcase}[$tcIndex]->{name}  = $temp;
            }



            if (defined ($data->{description})) {
                $temp2 = $data->{description};

                if ( $temp2 !~ /HASH/ ) {
                    $temp = $data->{description};
                }
                $log->info( "parse: Description=> $temp.\n") if ( $profFile->{debug}>3);
                $profFile->{tcase}[$tcIndex]->{description}  = $temp;
            }

            if (defined ($data->{emaildesc})) {
                $temp2 = $data->{emaildesc};

                if ( $temp2 !~ /HASH/ ) {
                    $temp = $data->{emaildesc};
                }
                $log->info( "parse: EMAILDESC $temp.\n") if ( $profFile->{debug}>3);
                $profFile->{tcase}[$tcIndex]->{emaildesc}  = $temp;
            }
#----
            if ( (defined ($data->{id} {manual} ) )) {
                $temp2 = $data->{id} {manual} ;


                if ( $temp2 !~ /HASH/ ) {
                    $temp = $temp2;
                }
                $log->info( "Parse: <id> <manual> $temp .\n") if ( $profFile->{debug}>3);
                $profFile->{tcase}[$tcIndex]{id} {manual}= $temp;
            }  

            if ( (defined ($data->{id} {auto} ) )) {
                $temp2 = $data->{id} {auto} ;

                if ( $temp2 !~ /HASH/ ) {
                    $temp = $temp2;
                }
                $log->info( "1: <id> <auto> $temp .\n") if ( $profFile->{debug}>3);
                $profFile->{tcase}[$tcIndex]{id} {auto}= $temp;
            } 

            #Import all variables
            if ( (defined ($data->{code}) )) {
                my $temp = $data->{code};
                #my @temp = split("\n",$data->{code} );
                $profFile->{tcase}[$tcIndex]->{code}  = $temp;
            } 
            #Import all variables
            if ( (defined ($data->{subr}) )) {
                my $temp = $data->{subr};
                $profFile->{tcase}[$tcIndex]->{subr}  = $temp;
            } 

            #let save the stage \    
            if ( $profFile->{debug} > 3 ) {
                if (ref($data->{stage}{step}) eq "HASH") {
                    $log->info("$data->{stage}{step} is a reference to a hash.\n");
                }
                unless (ref($data->{stage}{step})) {
                    $log->info("$data->{stage}{step} is not a reference at all.\n");
                }
            }
            my $dataPtr= $data->{stage}{step} ;
            if ( !(defined $data->{stage}{step} {name}) ) {
                foreach $index ( sort { $a <=> $b } keys %{$dataPtr} ) {
                    $log->info("Index $index ") if ( $profFile->{debug} > 4 );
                    foreach $kk ( sort keys %{$dataPtr->{$index} } ) {
                        $temp = $dataPtr->{$index}{$kk};
# move to execute single step
#		($rc,$temp) = subEnv($profFile,$temp);	    
                        $sArray{$index}{$kk} = $temp;
                        $log->info("sArray index=$index $kk= $temp ") if ( $profFile->{debug} > 4 );
                    }
                }
            } else {
                $index  = 0;
                $log->info("Index $index ") if ( $profFile->{debug} > 4 );
#	$temp = Dumper($dataPtr);
#	$log->info("email $temp");
                foreach $kk ( sort keys %{$dataPtr} ) {
                    $temp = $dataPtr->{$kk};
                    ($rc,$temp) = subEnv($profFile,$temp);	    
                    $sArray{$index}{$kk} = $temp;
                    $log->info("sArray index=$index $kk= $temp ") if ( $profFile->{debug} > 4 );
                }
            }
            $profFile->{tcase}[$tcIndex]{stage} = \%sArray;
            if ( $profFile->{debug} > 2 ) {
                $temp = Dumper(\%sArray);
                $log->info(" $temp");
            }
            return ($rc,$msg);
        }
#-------------------------------------------------------
# Set up Child Process
# !!!!NOTE that the return code of this routine
# is exceptional. The return code is generated by external script
#--------------------------------------------------------
        sub executeChildProcess {
            my ($profFile,$testcase,$tcIndex,$tcVar,$testLog,$parentId,$childId,$tmo) = @_;
            my $rc = $PASS;
            my $retry = 1;
            my $localRetry =1;
            my $wait = 5;
            my $temp = 0;
            my $log = $profFile->{logger};    
            ($rc,$temp) = buildEnvString ( $profFile);
#    $log->info("executeChildProcess: VAR = $temp ");
            $testcase = $temp.$testcase;
            $log->info("executeChildProcess:$testcase") if ( $profFile->{debug} > 0 );
#    $log->info("executeChildProcess:$testcase -- TIMEOUT = $tmo");
            $rc = $PASS;
            my $exp=Expect->spawn("$testcase");
            $exp->log_file( "$testLog","w");
            $exp->expect($tmo,
                [
                timeout =>
                sub {
                    $log->info("gflaunch.pl-executeChildProcess:$testcase is TimeOUT ");
                    $rc = $FAIL; #failed
                    return;
                }
                ],
                [ eof => sub { $log->info ("==>EOF \n"); $rc = $PASS} ],	 	
            );
            if ($rc == $FAIL) {
                $rc = $SP_FAIL; #set to special failed 
            } else { 
                $rc = $exp->exitstatus();
            }
            $exp->log_file();    
            $exp->soft_close();    
            print $parentId $rc;

            return $rc;
        }

#------------------------------------
# Get the stage index 
#------------------------------------
        sub getStageIndex {
            my ( $arrayPtr , $hashPtr)= @_;
            my $limit = $#{$arrayPtr};
            my $i;
            for ($i=0 ; $i <= $limit ;$i++) {
#	printf ( " $arrayPtr->[$i] -- hashPtr= $hashPtr\n");
                if ( $arrayPtr->[$i] eq $hashPtr) {
                    last;
                }
            }
            return($i);
        }
#------------------------------------
# Routine to import env from user
#------------------------------------
        sub importEnvFromUser{
            my ($profFile,$tc) =@_;
            my $log = $profFile->{logger};
            $log->info("-----------------  GETENV = $tc ");
            my $temp =`$tc`;
            my $rc;
            my $msg;
            my @buff=split("\n",$temp);
            #get the last line which contains the user environment
            $temp = $buff[$#buff];
            $log->info("-----------------  ENVV = $temp ");
            @buff= split(" ",$temp);
            my $i;
            my @tt;
            my $limit = $#buff;

            for ( $i = 0 ; $i <= $limit; $i ++ ) {
                @tt=split("=",$buff[$i]);
                $ENV{$tt[0]}="";	   		   
                if ( defined $tt[1] ) {	   
                    $ENV{$tt[0]}=$tt[1];
                    $temp = $ENV{$tt[0]};

                }
            }
            foreach $i ( sort keys %ENV ) {
                $temp = $i."=".$ENV{$i};
                ($rc,$msg) = replaceEnv ($profFile, $temp);
                if ( $i =~ /^[G|U]_/) {
                    $log->info("Import env: $temp");
                }
            }

            return(1);
        }
#------------------------------------
# Routine used to execute script from xml script tag
#------------------------------------
        sub executeScript {
            my ($profFile, $tc,$tcIndex,$tcVar,$testlog_tcase,$noerrorcheck) = @_;
            my $rc = $PASS;
            my $log =$profFile->{logger};
            my $msg = "Testcase $tc  successfully launched ";
            my $resultFromChild=$SP_FAIL;
            my $temp2;
            my $date;
            my @resultP=[0];
            my @resultF=[0];
            my $parentId ;
            my $childId;
            my $pid;
            $log->info(" \n --- SCRIPT ---\nTestcase=$tc\n---Save to log=$testlog_tcase----") if ($profFile->{debug} > 0  );
            # Fork out the system
#		    pipe (PARENT_RDR,CHILD_WTR);
            pipe (CHILD_RDR,PARENT_WTR);
            $parentId=*PARENT_WTR;
            $childId=*CHILD_RDR;
            $parentId->autoflush(1);
            $childId->autoflush(1);

            $pid = fork() ;
            if ( not defined $pid ) {
                die "fork () failed ";
            }

            if (!( $pid )) {
                #child process 
                $temp2 = $ENV{'G_TMO'};
                $date = `date +%Y%m%d%H%M%S`;
                $date =~ s/\n//;
                $log->info("==>CHILD Process start with Time out $temp2 -- $date");
                close $childId;
                $rc = executeChildProcess($profFile,$tc,$tcIndex,$tcVar,$testlog_tcase,$parentId,$childId,$temp2);
                $date = `date +%Y%m%d%H%M%S`;
                $date =~ s/\n//;
                $log->info("==>CHILD Process end $rc -- $date");
                close $parentId;
                exit (0);
            } else {
                #parent process
                close $parentId;
                #wait for child terminated
                $resultFromChild= <$childId>;
                $log->info("==>RCV from CHILD   $resultFromChild");
                waitpid($pid,0);
                close $childId;
            }

            $temp2 = $profFile->{'env'}{'G_NOPFGREP'} ;
            $resultF[0] = 0;
            $resultF[1] = 0;

            if ( $temp2 == $OFF ){ 
                if ($noerrorcheck == $OFF) {
                    if ( -e $testlog_tcase ) {
                        $rc = `cat $testlog_tcase `;
                        $rc = `grep -i -e "-| failed[^a-z]" -e "-| fail[^a-z]" -e "-| error[^a-z]" $testlog_tcase | wc`;
                        #$rc = `grep -i -e "\(failed\|error\)[^a-z]"  $testlog_tcase | wc`;
                        @resultF = split(" ",$rc);
                        $log->info (" FAILED= $resultF[0],$resultF[1],$resultF[2]") if ($profFile->{debug} > 3  );
                        $rc = `grep passed $testlog_tcase | wc`;
                        @resultP = split(" ",$rc);
                        $log->info (" PASSED = $resultP[0],$resultP[1],$resultP[2]") if ($profFile->{debug} > 3  );
                    }
                }
            }

            $rc = $PASS;
            $log->info("==>CHILD Process return value = $resultFromChild");
            if ( $resultFromChild == 0 ) {
                if ($resultF[0] !=0 ) {
                    #set current stage to failed 
                    $rc = $FAIL;
                    $msg="Testcase $tc failed";
                }
            } else {
                $rc = $FAIL;
                $msg="Testcase $tc failed";
            }
            return($rc,$msg);
        }
#------------------------------------
# Launch test case in XML format
#------------------------------------
        sub launchXmlTest {
            my ($profFile, $testcase,$tcIndex,$tcVar,$tcCount) = @_;
            my $rc = $PASS;
            my $glRc = 0;
            my $log =$profFile->{logger};
            my $msg = "testcases successfully launched ";
            my $msg2 = "";
            my $arrayOfTestcase;
            my $limit;
            my $temp;
            my $temp2;
            my $index;
            my $tc;
            my $kk;
            my $ii;
            my $newLib;
            my $tcArray = $profFile->{tcase};
            my @resultP;
            my @resultF;
            my @junk = split("/",$testcase );
            my $testlogDir = $profFile->{logdir}."/".$junk[$#junk]."_$tcCount";
            my @stageArray;
            my $stagePtr;
            my $NEXT= "next";
            my $FINAL="end";
            my $EXIT="exit";
            my $currentStageRc  = $FAIL;
            my $currentIndex  =0;
            my $testlog_tcase =$DEVNULL;
            my $testlog_tcase2 =$DEVNULL;
            my $testlog_tcase3 =$NOFUNCTION;
            my $parentId ;
            my $childId;
            my $pid;
            my $myStep;
            my $testindex;
            my $noerrorcheck=$OFF;
            my $found = 1;
            $temp =$testlogDir;
            my $desc;
            $index = 0;

            while ( $found ) {
                $index++;
                if ( -d $testlogDir ) {
                    $temp = $testlogDir."_$index"; 
                    next;
                }
                $testlogDir = $temp;
                $found = 0;
            }
            $ENV{'G_CURRENTLOG'} = $testlogDir;
            $profFile->{env}{G_CURRENTLOG} = $testlogDir;

            if ( !(-d $testlogDir) && ($profFile->{logOff} == 0) ) {
                $rc = system("mkdir $testlogDir");
                if ( $rc != 0) {
                    $msg = "Error: $testcase failed: because  of mkdir $testlogDir failure";
                    $rc = 0;
                    return($rc,$msg);
                }
            }
            my $testResultLog = $testlogDir."/result.txt";
            if ( -e $testResultLog) {
                $rc = `rm -f $testResultLog`;
            } else {
                $rc = `touch $testResultLog`;
            }

            #-------------------------------
            # parsing the xml 
            #-------------------------------
            ($rc,$msg2) = parsingXmlFile($profFile, $testcase,$tcIndex);
            if ( $rc == $FAIL) {
                $msg = "\n ------------->> ERROR >>------------ \n LaunchXmlTest: $msg2\n-------------<<<<<<<<<------------ ";
                $log->info ($msg);
                $temp = system ("echo \"$msg\" > $testResultLog");
                return($rc,$msg);
            }
            $arrayOfTestcase = \%{$profFile->{tcase}[$tcIndex]{stage}};
            $msg = "\[$tcIndex\].LaunchXmlTest: $testcase and logs saved to $ENV{'G_CURRENTLOG'}";
            $log->info ( $msg);

            # Add the testcase name

            $msg = "Testcase Name: ".$profFile->{tcase}[$tcIndex]{name}."\n";
            $msg .= "Title: ".$profFile->{tcase}[$tcIndex]{emaildesc}."\n";
            $msg .= "Description:\n".$profFile->{tcase}[$tcIndex]{description};  
            $rc = system ("echo \"$msg\" >> $testResultLog");

            #-----------------------------------------
            # Execute each single step of the XML test case
            #-----------------------------------------
            my @arrayVar=() ;
            # import scalar value from XML file code section

            if ( defined ( $tcArray->[$tcIndex]{code})) {
                $temp2 = $tcArray->[$tcIndex]{code};
                $log->info( "\n  CODE = $temp2  \n") if ($profFile->{debug} > 3 );
                # By doing this, we import to the stack all values of XML
                eval ($tcArray->[$tcIndex]{code} );
                if ( defined  $tcArray->[$tcIndex]{subr}  ) {
                    $temp2 = "$tcArray->[$tcIndex]{subr}";
                    $temp2 =~ s/LEQ/<=/g;
                    eval ($temp2);
                }
                @arrayVar = split("\n",$tcArray->[$tcIndex]->{code} );
                if ( $profFile->{debug} > 4 ) {

                    foreach my $var ( @arrayVar) {
                        $log->info("launchXmlTest VAR = $var");
                    }
                }
            }
            #build array of index
            $kk =0;
            foreach $index ( sort { $a <=> $b } keys %{$arrayOfTestcase} )  {
                $stageArray[$kk] = \%{$arrayOfTestcase->{$index}};
                #$temp = Dumper($arrayOfTestcase->{$index});
                #$log->info ( "-- $temp");
                #$log->info("== ($index)ARRAY $stageArray[$kk] = $arrayOfTestcase->{$index} ");
                #$log->info ( "++ $stageArray[$kk]->{desc}");
                $kk++;
                foreach $ii ( keys %{$arrayOfTestcase->{$index}}) {
                    $temp = $arrayOfTestcase->{$index}{$ii};

                    ($rc,$tc) = replaceVar($profFile,$temp,\@arrayVar);
                    $arrayOfTestcase->{$index}{$ii} = $tc;

                }	
            }

#    $temp2 = Dumper($arrayOfTestcase);
#    $log->info($temp2);

            for ( $index = 0; $index <= $#stageArray; $index++) {
                #-----
                $stagePtr = $stageArray[$index];
                $log->info("\n\n\n===============================================>");
                $log->info("Start to execute step\[$index\] : $stagePtr->{desc}");
                if ( $profFile->{debug} > 4 ) {
                    foreach $kk ( keys %{$stagePtr}) {
                        $temp = $stagePtr->{$kk};
                        $log->info("Index\[$kk]\]: $temp\n");
                    }
                }
                $currentStageRc = $PASS;
                $currentIndex = $index;
                if ( $profFile->{logOff} == 1 ) {
                    $testlog_tcase = "/dev/null";
                    $testlog_tcase2 = "/dev/null";
                } else {

                    $testlog_tcase = $testlogDir."/step_"."$index"."\.txt";
                    $testlog_tcase2 = $testlogDir."/step2_"."$index"."\.txt";
                    $testlog_tcase3 = $testlogDir."/step3_"."$index"."\.txt";
                    $myStep = "step_"."$index";
                }
                foreach $kk ( keys %{$stagePtr}) {
                    $tc = $stagePtr->{$kk};
                    SWITCH_LAUNCHXML_BYPASS_ERRORCHECK: for ($kk) {
                        /noerrorcheck/ && do {
                            if ( (defined $stagePtr->{$kk})) {
                                $noerrorcheck=$OFF if ( $stagePtr->{$kk} =~ /0/);
                                $noerrorcheck=$ON if ( $stagePtr->{$kk} =~ /1/);
                                $noerrorcheck=$OFF if ( $stagePtr->{$kk} =~ /OFF/i);
                                $noerrorcheck=$ON if ( $stagePtr->{$kk} =~ /ON/i);
                                $log->info($noerrorcheck) if ($profFile->{debug} > 2 ) ;
                            }
                            last;
                        };
                        last;
                    }
                }
                $desc=$NODESC;
                if ( defined $stagePtr->{desc} ) {  
                    $desc= $stagePtr->{desc} ;
                }

                # Run command (script ,getenv or sub) 
                foreach $kk ( keys %{$stagePtr}) {
                    $tc = $stagePtr->{$kk};

                    #$log->info("!!!$kk:\[$index\]:$tc ");
                    if ( $stagePtr->{$kk} =~ /HASH/) {
                        #$temp = Dumper($tc);
                        #$log->info ( ">> $temp");
                        $temp2 = " Step\[$index\] --- Entry[$kk]  is not DEFINED ---";
                        $log->warn($temp2);
                        $rc = system (" echo $temp2 >> $testlog_tcase");
                        last;
                    }
                    ($temp,$tc) = subEnv($profFile,$tc);	    
                    SWITCH_LAUNCHXMLTEST: for ($kk) {
                        /script/ && do {
=begin3
            if ( $stagePtr->{$kk} =~ /HASH/) {
            $temp2 = " Step\[$index\] --- SCRIPT is not DEFINED ---";
            $log->warn($temp2);
            $rc = system (" echo $temp2 >> $testlog_tcase");
            last;
            }
=cut
$log->info("\[$index\]:$tc ");

($rc,$msg) = executeScript($profFile,$tc,$tcIndex,$tcVar,$testlog_tcase,$noerrorcheck);
if ( $rc == 0 ) {
    $glRc++;
    $currentStageRc = $FAIL;
}
#write step failed to final result
if ( $profFile->{logOff} != 1 ) {
    if ( $currentStageRc == $PASS ) {
        $temp2 ="$myStep Passed:$desc";  
        $rc = system ("echo \"$temp2\" >> $testResultLog");
    } else {
        $temp2 ="$myStep FAILED:$desc";  
        $rc = system ("echo \"$temp2\" >> $testResultLog");
    }
}
last;  
        };
        /getenv/ && do {
            if ( $profFile->{logOff} == 1 ) {
                $testlog_tcase = "/dev/null";
            } else {
                $testlog_tcase = $testlogDir."/step_"."$index"."\.txt";
                $myStep = "step_"."$index";
            }
            $log->info ("Get Env $tc") if ($profFile->{debug} > 2  );
            ($rc,$msg) = importEnvFromUser($profFile,$tc);
            #write step failed to final result
            if ( $profFile->{logOff} != 1 ) {
                if ( $currentStageRc == $PASS ) {
                    $temp2 ="$myStep Passed:$desc";  
                    $rc = system("echo \"$temp2\" >> $testResultLog");
                } else {
                    $temp2 ="$myStep FAILED:$desc";  
                    $rc = system("echo \"$temp2\" >> $testResultLog");
                }
            }
            last;
        };
        /sub/ && do {
            $log->info ("SUB $tc") if ($profFile->{debug} > 2  );
            require $newLib; 
            no strict;
            $rc = $stagePtr->{$kk} ( );
            last;
        };
    }
}
# Check result and jump to next
foreach $kk ( keys %{$stagePtr}) {
    $tc = $stagePtr->{$kk};   
    SWITCH_LAUNCHXML_CHKRESULT: for ($kk) {
        /passed/ && do {
            $log->info(" PASSED STEP $stagePtr->{$kk}\n") if ($profFile->{debug} > 2  );
            #if current stage is failed then exit 
            if ( $currentStageRc == $FAIL ) { last; }
            if ( $stagePtr->{$kk} =~ /HASH/) {
                $temp2 = " Step\[$index\] --- PASSED is not DEFINED ---";
                $log->warn($temp2);
                $rc = system (" echo $temp2 >> $testlog_tcase");
                last;
            }
            if ( $stagePtr->{$kk} =~ /$NEXT/i) { last;} 
            if ( $stagePtr->{$kk} =~ /($FINAL|$EXIT)/i) {
                $index = @stageArray;
                last;
            } 
            if ( $stagePtr->{$kk} !~ /\d/) {
                $temp2 = " PASSED STEP: UNKNOWN keyword = $stagePtr->{$kk} -- please use step 1,2,...  \n";
                $log->warn($temp2);
                $rc = system (" echo $temp2 >> $testlog_tcase");
                last;
            } 

            $temp2 = $stagePtr->{$kk} ;
#		  $temp2 = sprintf("%s", $temp2);
#		  $log->info ( " PASSED INDEX = $temp2 ");
#		  $temp = \%{$arrayOfTestcase->{$temp2}};

            foreach $testindex ( sort keys %{$arrayOfTestcase} ) {
                if ( $testindex == $temp2 ) {
                    $temp = \%{$arrayOfTestcase->{$testindex}};
                    last;
                }
            }

#		  $temp2 = Dumper($temp);
#		  $log->info ( " $temp2");
#		  $temp2 = $stagePtr->{$kk} ;
#		  $log->info ( " PASSED INDEX = $temp2 -- $temp");

            $index = getStageIndex ( \@stageArray,$temp);

            $log->info ( " PASSED INDEX = $temp2 --- next = $index ");
            last;
        };
        /failed/ && do {
            $log->info(" FAILED  STEP $stagePtr->{$kk}\n") if ($profFile->{debug} > 2  );
            #if current stage is passed then exit
            if ( $currentStageRc == $PASS ) { last; }
            if ( $stagePtr->{$kk} =~ /HASH/) {
                $temp2 = " Step\[$index\] --- failed is not DEFINED ---";
                $log->warn($temp2);
                $rc = system (" echo $temp2 >> $testlog_tcase");
                last;
            }
            if ( $stagePtr->{$kk} =~ /$NEXT/i) { last;} 
            if ( $stagePtr->{$kk} =~ /($FINAL|$EXIT)/i) {
                $index = @stageArray ;
                last;
            } 
            if ( $stagePtr->{$kk} !~ /\d/) {
                $temp2 = " PASSED STEP: UNKNOWN keyword = $stagePtr->{$kk} -- please use step 1,2,...  \n";
                $log->warn($temp2);
                $rc = system (" echo $temp2 >> $testlog_tcase");
                last;
            } 



            $temp2 = $stagePtr->{$kk} ;
#		  $temp2 = sprintf("%s", $temp2);
#		  $temp = \%{$arrayOfTestcase->{$temp2}};
            foreach $testindex ( sort keys %{$arrayOfTestcase} ) {
                if ( $testindex == $temp2 ) {
                    $temp = \%{$arrayOfTestcase->{$testindex}};
                    last;
                }
            }
            $index = getStageIndex ( \@stageArray,$temp);
            $log->info ( " FAILED INDEX = $temp2 --- next = $index ");
            last;
        };
        last;
    }
}
$temp2 = "No Description";
$temp = "NoerrorCheck--0=off, 1= on";
if ( $testlog_tcase3 !~ /$NOFUNCTION/ ) {
    if ( defined( $stagePtr->{desc} )) {
        $temp2 = $stagePtr->{desc};
    }
    $rc = system (" echo \"------------------\nDescription:$temp2\n$noerrorcheck:$temp\n----------------\" > $testlog_tcase2");
    $rc = system ( "cat $testlog_tcase2 $testlog_tcase > $testlog_tcase3");
    $rc = system ( "mv -f $testlog_tcase3 $testlog_tcase");
}	
$rc = system ( "rm -f $testlog_tcase2");	
if ( $currentIndex !=$index ) {
    $index--; #need to subtract by 1 since for loop will increase this index
}
    }
    if ($glRc!=0) {
        $msg = "$testcase failed ";
        return(0,$msg);
    }
    $rc = $PASS;
    return ($rc,$msg);

}

#------------------------------------
# Launch script written in native linux script
#------------------------------------
sub launchExeTest {
    my ($profFile, $testcase,$tcIndex,$tcVar,$tcCount) = @_;
    my $rc = $FAIL;
    my $msg = "testcases passed ";
    my $log = $profFile->{logger};
    my @junk = split("/",$testcase );
    my $testlogDir = $profFile->{logdir}."/".$junk[$#junk]."_$tcCount";
    my $logFile = "/dev/null";
    my $temp= "\$nothing=0";
    if ( !(-d $testlogDir) && ($profFile->{logOff} == 0) ) {
        $rc = system("mkdir $testlogDir");
        if ( $rc != 0 ) {
            $msg = "Error: $testcase failed: because  of mkdir $testlogDir failure";
            $rc = $FAIL;
            return($rc,$msg);
        }
    } 
    if ($profFile->{logOff} == 0) {
        $logFile = $testlogDir."/testlog.txt"; 
    } 
    $log->info ( "\[$tcIndex\].LaunchExeTest: $testcase \n");
    $rc = system("/bin/bash $testcase > $logFile");
    if ($rc == -1 ) {
        $rc = $FAIL; # this test is failed
        $msg = "failed to execute $!";
        $log->info ( $msg);
        return($rc,$msg);
    }
    my $junk = $rc & 127 ;
    if ( $junk ) {
        $msg ="child died with signal $junk";  
        $rc = $FAIL;
        $log->info ( $msg);
        return($rc,$msg);
    }
    $junk = $rc >> 8;
    if ( $junk == 0 ){
        $rc = $FAIL;
    } else {
        $rc = $PASS;
        $msg = " Test case failed with return code $junk";
    }
    $log->info ( $msg);
    return($rc,$msg);
}
#--------------------------------------------------
# This routine is used to get the passing variable
# from the command line
#-----------------------------------------------------
sub getTcVariables{
    my ($profFile, $tc) = @_;
    my @buff = split(";",$tc);
    my @temp;
    my $log = $profFile->{logger};
    my $var = "0";
    my $rc = $FAIL; #set to failed cased
    my $limit;
    my $index;
    if ( $#buff < 1 ) {
        return ($FAIL,$var);
    }
    $limit = $#buff;
    for ($index= 1; $index <= $limit ;$index++) {
        @temp = split("=",$buff[$index]);
        $log->info("var=$temp[0]--value=$temp[1]") if ($profFile->{debug} > 2 );
        if ( $temp[0] =~ /var/ ) {

            if ( !( defined $temp[1] )) {
                return ($FAIL,$var);
            }
            $log->info("Found: var=$temp[0]--value=$temp[1]") if ($profFile->{debug} > 2 );
            $var=$temp[1];
            return ($PASS,$var);
        }
    }
    return($rc,$var);
}
#--------------------------------------------------
# This routine is used to get the label index from the function
# table
#-----------------------------------------------------
sub getLabelIndex{
    my ($profFile,$tc,$status) = @_;
    my $log =$profFile->{logger};
    my @buff = split(";",$tc);
    my @temp;
    my $index = 0;
    my $nodef = "NOT_DEF";
    my $goto =  $nodef;
    my $rc = $FAIL; #set to failed cased
    my $tcArray = \@{$profFile->{tcase}};
    my $limit ;
    my $type;
    my $func;
    my $nolabel="label UNKNOWN ";
    if ( $#buff < 1 ) {
        return (0,$index,$nolabel);
    }
    $limit = $#buff;
    for ($index= 1; $index <= $limit ;$index++) {
        @temp = split("=",$buff[$index]);
        if ( $temp[0] =~ /^$status$/i ) {
            if ( !( defined $temp[1] )) {
                return (0,0,$nolabel);
            }
            $log->info("Match with $status and label value=$temp[1]") if ($profFile->{debug} > 2 );
            $goto=$temp[1];
            last;
        }
    }
    if ( $goto =~ /$nodef/ ) {
        return (0,0,$nolabel);
    }
    $limit = $#{$tcArray};
#    if ( $goto =~ /^end$/i) {
#	return (1,$limit,$goto);
#    }
    for ($index=0;$index <= $limit ;$index++) {
        $type = $tcArray->[$index]->{type};
        $func = $tcArray->[$index]->{function};
#	$log->info("Check for label: \[$index\] type=$type and func=$func  -- search label ($goto) " );
        if ( $type =~ /label\b/ ) {
            if ( $func =~ /^$goto\b/ ) {
                $log->info("label value=$temp[1] and index=$index") if ($profFile->{debug} > 2 );
#		$log->info("label value=$temp[1] and index=$index");
                return(1,$index,$goto);
            }
        }
    }
    return($rc,$index,$goto);
}

sub convertSecToHour {
    use integer;
    my ($duration,$junk)=@_;
    my (@time,$res);
    $time[0] = $duration / 3600;
    $res = $duration;
    if ( $time[0] >= 1 ) {
        $res = $duration - ($time[0] * 3600);
        $duration = $res;
    } 
    $time[1] = $res / 60;
    $res = $duration;
    if ( $time [1] >= 1 ) {
        $res = $duration - ($time[1] * 60);
        $duration = $res;
    }
    $time[2] = $res;
    $res = join (":",@time);
    no integer;
    return ($res);
}

sub getTimeDiff {
    my ($startTime,$endTime)=@_;
    my @startT;
    my @endT;
    my ( $duration,$resEnd,$resStart);
    @startT = split ( ":",$startTime );
    @endT = split ( ":",$endTime );
    if ( $endT[0] < $startT[0] ) {
        $endT[0] += $startT[0]; 
    }
    #convert to seconds
    $resEnd = ($endT[0] * 3600) + ($endT[1]*60) + $endT[2];
    $resStart = ($startT[0] * 3600) + ($startT[1]*60) + $startT[2];
    $duration = $resEnd - $resStart;
    return($duration);
}
#------------------------------------
# Launch testcase
#------------------------------------
sub launchTest {
    my ($profFile, $junk) = @_;
    my $mainRc = $PASS;
    my $label;
    my $log = $profFile->{logger};
    my $mainMsg = "testcases successfully launched ";
    my $tcArray = \@{$profFile->{tcase}};
    my $limit = $#{$tcArray};
    my $i = 0;
    my $func;
    my $tstName=$profFile->{env} {'G_TST_TITLE'};
    my $prodType=$profFile->{env} {'G_PROD_TYPE'};
    my $emaildesc;
    my $testManId;
    my $testAutoId;
    my $tcCount = 0;
    my $type;
    my $status;
    my $line;
    my $forceRecord;
    my $temp;
    my $fwVersion=$profFile->{env} {'G_FWVERSION'};
    my @buff=();
    my($rc,$msg,$tcName);
    my $var;
    my $tc;
    my $hwversion;
    my $swversion;
    my ($startTime,$endTime,$duration,$dur2, $totalDuration,$totalDuration2);
    my $resultCSV=$profFile->{logdir}."/"."result.csv";
    my $resHdr = "Testsuite Name; Item ; Description ; Firmware ; Result ; Comments ; Tester ; Date; Processing time";
    $rc = `echo \"Test Suite Title= $tstName\" > $resultCSV`;
    $rc = `echo \"$resHdr\" >> $resultCSV`;
    $status=`date +%m/%d/%Y`;
    $status =~ s/\n//g;
    my $msgRes;
    my $tsuiteName=getBaseName($profFile->{filename});
    my $resTail = ";;Automation;$status;"; 
    my $hwserial;
    $status = 0;
    $ENV{'G_TCFAIL'} = 0;
    $ENV{'G_TCPASS'} = 0;
    $ENV{'G_NCFAIL'} = 0;
    $ENV{'G_NCPASS'} = 0;
	$ENV{'G_ICNUM'} = 0;
    $profFile->{env} {G_TCFAIL} = 0;
    $profFile->{env} {G_NCFAIL} = 0;
    $profFile->{env} {G_TCPASS} = 0;
    $profFile->{env} {G_NCPASS} = 0;
	$profFile->{env} {G_ICNUM} = 0;
	$profFile->{icnum} = 0;
    my $FD = $profFile->{resultFN};
    #-------------------------------------------------
    # The deal is that each test case has the following 
    # format ( -tc xxx;pass/fail=label;var="-v ..future:)"
    # The split of each test case will be divided in 
    # couple of section inside the buff array
    #-------------------------------------------------
    $log->info ("---- number of testcase ($limit) will be executed \n----");
    $totalDuration=0;

    for ($i =0; $i<= $limit ; $i++ ) {
        $func = $tcArray->[$i]{function};
        $type = $tcArray->[$i]{type};

        if ( $type =~ /label\b/ ) {
            next;
        }
        @buff = split(";",$func);	
        $var = getTcVariables($profFile,$func);

        #----------------------------------------------
        # Replace GLOBAL variable with absolute path
        #---------------------------------------------
        ($rc,$tc) = subEnv ( $profFile, $buff[0]);

#	($rc,$temp) = buildEnvString ( $profFile);
#	$tc = $temp.$tc;
        $startTime = `date +%H:%M:%S`;
        $startTime=~ s/\n//;
        $log->info("\n"x8);
        $log->info("#"x80);
        $log->info("startTime:$startTime");
        $tcCount++;
		$tcName = getBaseName($tc);
		if(defined $ENV{U_CUSTOM_IGNORE_TCASES} and $ENV{U_CUSTOM_IGNORE_TCASES} =~ /$tcName/){
			$profFile->{icnum} += 1;
	#		$ENV{'G_ICNUM'} += 1;
			$profFile->{env} {G_ICNUM} = $ENV{'G_ICNUM'} = $profFile->{icnum};
			$log->info("---- Testcase ignore : $buff[0]\n$tc ----");
			$rc = $PASS;
			$msg = "$tc ignored: because of it is contained in blackname list";
			$tcArray->[$i]->{result} = $rc;
			$tcArray->[$i]->{msg} = $msg;
			$endTime = `date +%H:%M:%S`;
       			$endTime=~ s/\n//;
        		$log->info("endTime:$endTime");
			next;
		}elsif ( $buff[0]=~ /\.xml/ ) {
            $log->info("---- Launch XML Test : $buff[0]\n$tc -----");
            ($rc,$msg) = launchXmlTest($profFile,$tc,$i,$var,$tcCount);
        } else {
            $log->info ("---- Launch EXE  Test : $buff[0]\n$tc----");
            ($rc,$msg) = launchExeTest($profFile,$tc,$i,$var,$tcCount);
        }
        $endTime = `date +%H:%M:%S`;
        $endTime=~ s/\n//;
        $log->info("endTime:$endTime");
        $duration=getTimeDiff($startTime,$endTime);
        $log->info("==>Duration:$duration");
        $dur2 = convertSecToHour ( $duration);
        $totalDuration += $duration;
        $fwVersion=$profFile->{env} {'G_FWVERSION'};
        $forceRecord=$profFile->{env} {'G_FORCE_REC'};
        $hwserial=$profFile->{env} {'G_HW_SERIAL'};
        $hwversion=$profFile->{env} {'G_HW_REV'};
        $swversion=$profFile->{env} {'G_FWVERSION'};
        $testManId = $tcArray->[$i]{id}{manual};
        $testAutoId = $tcArray->[$i]{id}{auto};
        $emaildesc = $tcArray->[$i] {emaildesc};
        $tcArray->[$i]->{result} = $rc;
        $tcArray->[$i]->{msg} = $msg;
         

        my @tcName_db = split /\./, $tcName;
        my $tclog_info = "http://".$profFile->{env}{G_HTTP_SERVER}.$profFile->{env}{G_HTTP_DIR}."/".$tcName."_$tcCount";

        if ( $rc == $FAIL ) {
            if ( $type =~ /tc/ ) {
                $msg = "\[$tcCount\].Testcase FAILED: $tcName";
                #    0->pass           # 
                #    1->fail           #
                #    2->none excute    #
                #my $trds = threads->new(\&insertDB, $tcName_db[0], '1', '', '', $tclog_info, $duration);
                #$trds->join;

                $profFile->{tcfail} += 1;
                $ENV{'G_TCFAIL'} = $profFile->{tcfail};
                $profFile->{env} {G_TCFAIL} = $profFile->{tcfail};

                #"Item ; Description ; Firmware ; Result ; Comments ; Tester ; Date; Processing time ";
                $msgRes= $tsuiteName.";".$tcArray->[$i]{name}.";".$emaildesc.";".$fwVersion.";"."FAIL ".$resTail."".$duration." (HH:MM:SS= ".$dur2.");";

                $temp =`echo \"$msgRes\" >> $resultCSV`; 
            } else {
                $msg = "\[$tcCount\].Non-Testcase FAILED: $tcName";
                #my $trds = threads->new(\&insertDB, $tcName_db[0], '1', '', 'nc', $tclog_info, $duration);
                #$trds->join;

                $profFile->{ncfail} += 1;
                $profFile->{env} {G_NCFAIL} = $profFile->{ncfail};
                $ENV{'G_NCFAIL'} = $profFile->{ncfail};
            }	    
            $status=$FAIL_MSG;
        } else {
            if ( $type =~ /tc/ ) { 
                $msg = "\[$tcCount\].Testcase Passed: $tcName";
                #my $trds = threads->new(\&insertDB, $tcName_db[0], '0', '', '', $tclog_info, $duration);
                #$trds->join;

                $profFile->{tcpass} += 1;
                $ENV{'G_TCPASS'} = $profFile->{tcpass};  
                $profFile->{env} {G_TCPASS} = $profFile->{tcpass}; 
                $msgRes= $tsuiteName.";".$tcArray->[$i]{name}.";".$emaildesc.";".$fwVersion.";"."pass".$resTail.$duration." (HH:MM:SS=".$dur2.");";
                $temp =`echo \"$msgRes\" >> $resultCSV`; 
            } else {
                $msg = "\[$tcCount\].Non-Testcase Passed: $tcName";
                #my $trds = threads->new(\&insertDB, $tcName_db[0], '0', '', 'nc', $tclog_info, $duration);
                #$trds->join;

                $profFile->{ncpass} += 1;
                $ENV{'G_NCPASS'} = $profFile->{ncpass};
                $profFile->{env} {G_NCPASS} = $profFile->{ncpass};  
            }
            $status=$PASS_MSG;
        }
        $log->info($msg) if ( $profFile->{debug} > 4 ) ;	    
        printf $FD "$msg\n";
        $msg = $msg." -- http://".$profFile->{env}{G_HTTP_SERVER}.$profFile->{env}{G_HTTP_DIR}."/".$tcName."_$tcCount" ;
        printf $FD "$msg\n";
        $temp = getPathName($tc);
        $msg = "Testcase Path: ".$temp;
        printf $FD "$msg\n";
        $temp = $testManId;
        $msg= "Testcase Manual Id\[".$temp."\]";
        $temp = $emaildesc;
        $msg = "$msg => $temp";
        $temp = "Testcase Auto Id\[".$testAutoId."\]\n";
        $msg = $temp.$msg;
        $temp = "Start time: ".$startTime."\nDuration: ".$duration."\n";
        $msg = $temp.$msg;
        printf $FD "$msg \n\n";
        flush $FD;
# Force to record Hardware and Serial 

        if ( $forceRecord =~ /^on\b/i ) {
#	    $profFile->{env} {'G_FORCE_REC'} = "OFF";
            $log->info(" Detect Force Record On ");
            $totalDuration2 = convertSecToHour($totalDuration);
            $temp =`echo \"\nTotal Processing Time = $totalDuration\" >> $resultCSV`;
            $temp =`echo \"Product Type = $prodType\" >> $resultCSV`;  
            $temp =`echo \"HardWare Serial Number= $hwserial\" >> $resultCSV`;
            $temp =`echo \"HardWare Revision= $hwversion\n\" >> $resultCSV`;
            $temp =`echo \"Software Revision= $swversion\n\" >> $resultCSV`;

#	    $forceRecord = "OFF";
            print $FD ("HardWare Serial Number= $hwserial\nHardWare Revision= $hwversion\nTotal Processing Time = $totalDuration2\nSoftware Revision= $swversion\n");

        }
        ($rc,$temp,$label) = getLabelIndex($profFile,$func,$status);
        if ( $rc == $PASS) {
            $i = $temp; #jump to next test case
            $msg = "Testcase $status: testcase after label \[$i\]=$label will be executed next";
            $log->info($msg) ;
        }
    }

    if ( $forceRecord =~ /$NOFUNCTION/ ) {
        $totalDuration2 = convertSecToHour($totalDuration);
        $temp =`echo \"\nTotal Processing Time = $totalDuration\" >> $resultCSV`;
        $temp =`echo \"Product Type = $prodType\" >> $resultCSV`;  
        $temp =`echo \"HardWare Serial Number= $hwserial\" >> $resultCSV`;
        $temp =`echo \"HardWare Revision= $hwversion\n\" >> $resultCSV`;
        $temp =`echo \"Software Revision= $swversion\n\" >> $resultCSV`;
        print $FD ("HardWare Serial Number= $hwserial\nHardWare Revision= $hwversion\nTotal Processing Time = $totalDuration2\nSoftware Revision= $swversion\n");
    }
	print "\n\n";
    $log->info("  -------        Total Duration:$totalDuration");
    $log->info ("---- Launching Test Ended ----");
    return($mainRc,$mainMsg);
}


#--------------------------------------------------------------
# This routine is used to parse input and setup environment for 
# test cases and set up launching tables.
#--------------------------------------------------------------
sub parsingFile {
    my ($usrFile, $profFile) = @_;
    my $rc = $PASS;
    my $log= $profFile->{logger};
    my $msg = "Parse File Passed ";
    my $msg2 = "test not running";
    my $step = 0;
    my @buff=();
    my $line ;
    my $temp;
    my $count ;
    my $execLine=0;
    my $limit = $#{$usrFile};
    $log->info( "PARSING FILE with #of lines = $limit") if ( $profFile->{debug} > 2 );
    $log->info( "\[Index from File\]-\[Index from local Table\]: input ...");
    for ( $step = 0; $step <= $limit; $step++ ) {

        $line = $usrFile->[$step];
        if ( $line=~ /^#/ ) {
            next;
        }
        if ( $line=~ /^\s*$/ ) {
            next;
        }
        $log->info( "\[$step\]-\[$execLine\]:$line");
        $execLine++;
        @buff=split(" ",$line);
        $temp ="";
        for ( $count=1;$count<=$#buff;$count++) {
            if ($count > 1 ) {
                $temp .= " ";
            }
            $temp .=$buff[$count]; 
        }
        $buff[1]=$temp;
        SWITCH_PARSINGFILE:
        for ( $buff[0]) {
            my %newFunc = ( 
                "function"=>"NULL",
                "name"=>$NODESC,
                "emaildesc"=>"no emaildesc tag",
                "id"=>{ "manual"=>"no <id> <manual> tag",
                    "auto"=>"no <id> <AUTO> tag",
                },
                "stage"=>"none",
                "type"=>"none",
                "result"=>0,
                "msg"=>"none",
                "code"=>"\$nothing=0",
            );
            /-v/ && do {
                $log->info( "Parse V OPTION") if ( $profFile->{debug} > 3 );
                @buff= split("=",$buff[1]);
                $ENV{$buff[0]}=$buff[1];
#		$profFile->{env}{$buff[0]}=$buff[1];
                last;
            };
            /-nc/ && do {
                $log->info( "Parse NC  OPTION") if ( $profFile->{debug} > 3 );
                $newFunc{type}="nc";
                $newFunc{function}= $buff[1];
                $newFunc{msg}="$msg2: $line";
                push(@{$profFile->{tcase}},\%newFunc);
                last;
            };
            /-tc/ && do {
                $log->info( "Parse TC  OPTION") if ( $profFile->{debug} > 3 );
                $newFunc{type}="tc";
                $newFunc{function}= $buff[1];
                $newFunc{msg}="$msg2: $line";
                push(@{$profFile->{tcase}},\%newFunc);
                last;
            };
            /-label/ && do {
                $log->info( "Parse LABEL  OPTION") if ( $profFile->{debug} > 3 );
                $newFunc{type}="label";
                $newFunc{function}= $buff[1];
                $newFunc{msg}="$msg2: $line";
                push(@{$profFile->{tcase}},\%newFunc);
                last;
            };
            $log->info( "Warning: line[$step] is not recognized by parser");
            last;
        }
    }
    return($rc,$msg);
}
#--------------------------------------------------
# This subroutine is used to import system environment
#---------------------------------------------------
sub importEnv {
    my ($profFile,$junk) = @_;
    my $rc = $PASS;
    my $msg = "Parse Environment variables  Passed ";
    my $temp;
    my $i = 0;
    my $var;
    foreach $var (sort keys %ENV ) {

        if ( defined $ENV{$var} ) { 
            $temp = $var."=".$ENV{$var};
        } else {
            $temp = $var."=";
            $ENV{$var}="";
        }

        ($rc,$msg) = replaceEnv ($profFile, $temp);

        $profFile->{env}{$var}="$ENV{$var}";
        $i++;
    }


    if ( $profFile->{debug} > 5 ) {
        $i = 0;
        foreach $var (sort keys %{$profFile->{env}} ) {
            if ( defined ($ENV{$var}) ) {
                $temp = "$i: EnvVAR  $var = $ENV{$var} -- $profFile->{env}{$var}\n";
            } else {
                $temp = "$i: EnvVAR  $var = NULL \n";
            }
            $profFile->{logger}->info($temp);
            $i++;
        }
    }

    return ($rc,$msg);
}
#---------------------------------------------------------------
# This subroutine is used to set up environment through $ENV{}
#--------------------------------------------------------------
sub setUpEnv {
    my ($profFile,$globVar) =@_;
    my $rc = $PASS;
    my $msg = "";
    my $key;
    my $temp;
    my @t1;
    my $notfound;
    my $log = $profFile->{logger};
    my $date;
    foreach $key ( keys %{$profFile->{env}} ) {
        $ENV{$key}= $profFile->{env} {$key};
        if ( $key =~ /G_FTP_DIR/) {
            $profFile->{ftplogdir} = $profFile->{env} {$key};
        }
        if ( $key =~ /G_HTTP_DIR/) {
            $profFile->{httplogdir} = "/".$profFile->{env} {$key};
        }
    }

    foreach $key  ( keys %{$globVar} ) {
        if ( $key =~ /G_FTP_DIR/) {
            #skip the internal variables
            next;
        }
        if (!(defined $profFile->{env}{$key} )) {
            $notfound=1;
            $temp = "==>Environment $key is not found";
            $msg .=$temp;
            $log->info($temp);
            $profFile->{env}{$key} = "$key\_unknown";
            $ENV{$key} = "$key\_unknown";
            $rc = $FAIL;
        }
        SWITCH_SETUPENV: for ($key) {
            /^G_BUILD$/ && do {
                #initialize the global variables for FTP G_FTP_DIR
                # NOTE: it is better get name from binary image ???
                $temp = $profFile->{env}{$key} ;
                if (!(defined $profFile->{env}{$key} )) {
                    $temp="unknown";

                } else {
                    $temp = getBaseName($temp);
#		  @t1=split("/",$temp );
#		  $temp = $t1[$#t1];
                }
                $date = `date +%Y%m%d%H%M%S`;
                $date =~ s/\n//;
                if (!(defined $profFile->{env}{G_USER} )) {
                    $ENV{'G_USER'} ="root";
                }
                #save under format : ftp logdir + user_name + name of image+date
                $ENV{'G_DATE'} = $date;
                $ENV{'G_FTP_DIR'} = $profFile->{ftplogdir}."/".$ENV{'G_USER'}."/".$temp."_".$date;
                $ENV{'G_HTTP_DIR'} = $profFile->{httplogdir}."/".$ENV{'G_USER'}."/".$temp."_".$date;
                $profFile->{env}{G_FTP_DIR} = $profFile->{ftplogdir}."/".$ENV{'G_USER'}."/".$temp."_".$date;
                $profFile->{env}{G_HTTP_DIR} = $profFile->{httplogdir}."/".$ENV{'G_USER'}."/".$temp."_".$date;
                last;
            };
            /^G_USER$/ && do {
                $temp = $profFile->{env}{$key} ;
                if (!(defined $profFile->{env}{$key} )) {
                    $ENV{'G_USER'} ="root";
                    $profFile->{env}{G_USER} = "root";
                }
                last;
            };
            last;
        }

    }

    if ( $profFile->{env}{G_HTTP_SERVER} =~ /$NOFUNCTION/ ) {
        $profFile->{env}{G_HTTP_SERVER} = $profFile->{env}{G_FTP_SERVER};
        $ENV{'G_HTTP_USER'} = $profFile->{env}{G_FTP_SERVER};
    }



    if ( $rc == $PASS ) {
        $msg = "All needed Env Variables were set up correctly";
    }
    return($rc,$msg);    
}
#------------------------------------------------
# Create template 
#-----------------------------------------------
sub createTemplate {
    my ( $profFile, $data) = @_;
    my $log = $profFile->{logger};
    my $filename = $profFile->{template};
    my $numOfEntries = $profFile->{numofentries};
    my $rc = $PASS;
    my $i;
    my $msg = "Successfully create file $filename";
    #Import PC hosts variables.
    $rc = open( MLT_FD,"> $filename");
    if ($rc == 0 ) {
        $msg = "Failed to create $filename";
        $rc = $FAIL;
        return($rc,$msg);
    }    
    printf MLT_FD ( "<testcase>\n");
    printf MLT_FD ( "<name>$filename</name>\n");
    printf MLT_FD ( "<emaildesc>Sample Test Case $filename</emaildesc>\n");
    printf MLT_FD ( "<description> Need to insert description here </description>\n");
    printf MLT_FD ( "<id>\n\t<manual>1234</manual>\n\t<auto>3456</auto>\n</id>\n");
    printf MLT_FD ("<code>\n</code>\n");
    printf MLT_FD ("<stage>\n");
    for ($i = 0; $i < $numOfEntries ; $i++) {
        printf MLT_FD ("\t<step>\n");
        printf MLT_FD ("\t\t<name>$i</name>\n");
        printf MLT_FD ("\t\t<desc>step $i</desc>\n");
        printf MLT_FD ("\t\t<script>echo \"test step $i\" </script>\n");
        printf MLT_FD ( "\t\t<passed></passed>\n");
        printf MLT_FD ("\t\t<failed></failed>\n");
        printf MLT_FD ( "\t</step>\n");
    }
    printf MLT_FD ("</stage>\n");
    printf MLT_FD ( "</testcase>\n");
    close MLT_FD;
    return($rc,$msg);
} 

#************************************************************
# Main Routine
#************************************************************
MAIN:

my @gflaunch_junk = split( /\//, $0);
my $gflaunch_scriptFn = $gflaunch_junk[$#gflaunch_junk];
my @gflaunch_userParam;
my %gflaunch_scalar=();
my $option_h;
my @gflaunch_commands = ();
my $msg;
my $junk;
my $option_man = 0;
$gflaunch_scalar{rc} = GetOptions( "x=s"=>\$gflaunch_userInput{debug}, 
    "help|h"=>\$option_h, 
    "man"=>\$option_man,
    "c=s"=>sub { $gflaunch_userInput{numofentries} = $_[1]; $gflaunch_userInput{numofentries} = 1 if ( $_[1] < 1 ); }, 
    "t=s"=>\$gflaunch_userInput{template},
    "s"=>\$gflaunch_userInput{screenOff},
    "n"=>\$gflaunch_userInput{logOff},
    "l=s"=>\$gflaunch_userInput{logdir},
    "f=s"=>\$gflaunch_userInput{filename},
    "v=s"=>sub { $junk = "-v $_[1]"; if ( exists $gflaunch_commands[0] ) { push (@gflaunch_commands,$junk); } else {$gflaunch_commands[0]=$junk; } } ,
    "tc=s"=>sub { $junk = "-tc $_[1]"; if ( exists $gflaunch_commands[0] ) { push (@gflaunch_commands,$junk); } else {$gflaunch_commands[0]=$junk; } } ,
    "nc=s"=>sub { $junk = "-nc $_[1]"; if ( exists $gflaunch_commands[0] ) { push (@gflaunch_commands,$junk); } else {$gflaunch_commands[0]=$junk; } } ,
    "label=s"=>sub { $junk = "-label $_[1]"; if ( exists $gflaunch_commands[0] ) { push (@gflaunch_commands,$junk); } else {$gflaunch_commands[0]=$junk; } } ,

);
#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);




#------------------------------------------
# 1. Set up log directory to recording logs
#------------------------------------------
if ( $gflaunch_userInput{logOff} == 0 ) {
    ($gflaunch_scalar{rc},$gflaunch_scalar{msg}) = setupLogdir(\%gflaunch_userInput);
    if ( $gflaunch_scalar{rc} != 1) {
        printf ("RC$gflaunch_scalar{rc} $gflaunch_scalar{msg}\n");
        exit 1;
    } 
}

#---------------------------------------------
#2. Initialize Logger 
#---------------------------------------------
($gflaunch_scalar{rc},$gflaunch_scalar{msg}) = initLogger(\%gflaunch_userInput, );
if ( $gflaunch_scalar{rc} != 1) {
    printf ("RC$gflaunch_scalar{rc} $gflaunch_scalar{msg}\n");
    exit 1;
} 

if ( $gflaunch_userInput{template} !~ /$NOFUNCTION/ ) { 
    ($gflaunch_scalar{rc},$gflaunch_scalar{msg})= createTemplate (\%gflaunch_userInput);
    $gflaunch_userInput{logger}->info($gflaunch_scalar{msg});
    exit $gflaunch_scalar{rc};
}
#---------------------------------------------
# 3. Read in the test suite file
#---------------------------------------------

# copy tst to logdir
system("cp -rf $gflaunch_userInput{filename}  $gflaunch_userInput{logdir}");
$gflaunch_scalar{fname} = $gflaunch_userInput{filename};
#$ENV{'G_TSUITE'}=$gflaunch_scalar{fname};
#$gflaunch_userInput{env}{G_TSUITE}=$gflaunch_scalar{fname};
if ( !( $gflaunch_scalar{fname} =~ m/$NO_FILE/  )) {
    $gflaunch_userInput{logger}->info("---- Read in testsuite $gflaunch_userInput{filename} ----"); 
    if (!( -e $gflaunch_scalar{fname}) ) {
        $msg = "ERROR: file $gflaunch_scalar{fname} could not be found\n";	
        $gflaunch_userInput{logger}->error($msg); 
        exit 1;
    }
    open(OPENFN,"< $gflaunch_scalar{fname} ") ;
    @gflaunch_userParam = <OPENFN>;
    $gflaunch_scalar{limit} = $#gflaunch_userParam;
#-------------------------------------
# Get rid of \n for each input line 
#-------------------------------------
    for ( $gflaunch_scalar{step} = 0; $gflaunch_scalar{step} <= $gflaunch_scalar{limit}; $gflaunch_scalar{step}++) {
        $gflaunch_userParam[$gflaunch_scalar{step}]=~ s/\n//;
    }
#-------------------------------------
# Parsing input file 
#-------------------------------------
    ($gflaunch_scalar{rc},$gflaunch_scalar{msg} ) = parsingFile(\@gflaunch_userParam,\%gflaunch_userInput );

}
#-------------------------------------------------------------------
# 4. Parsing command line. Note that any environment entered from file 
# will be overwritten by this command line   
#-------------------------------------------------------------------
$gflaunch_userInput{logger}->info( "---- Parse Command Line ----" );
($gflaunch_scalar{rc},$gflaunch_scalar{msg}) = parsingFile(\@gflaunch_commands, \%gflaunch_userInput );
$msg = "--------------- Input Parameters  ---------------\n";
$gflaunch_userInput{logger}->info( $msg);
foreach my $key ( keys %gflaunch_userInput ) {
    $msg = "$key = $gflaunch_userInput{$key}";
    if ( ($key =~ /^logger$/) || ($key =~ /^tcase$/) ) {
        next;
    }
    $gflaunch_userInput{logger}->info($msg);
}


if ( $gflaunch_userInput{debug} > 2 ) {

    my $t1 = \@{$gflaunch_userInput{tcase}};
    my ($type,$func);
    $gflaunch_scalar{limit} = $#{$t1};
    for ($gflaunch_scalar{step} = 0 ; $gflaunch_scalar{step} <=     $gflaunch_scalar{limit}; $gflaunch_scalar{step}++) {
        $type = $t1->[$gflaunch_scalar{step}]->{type};
        $func = $t1->[$gflaunch_scalar{step}]->{function};
        $msg = "$gflaunch_scalar{step}: $type = $func";
        $gflaunch_userInput{logger}->info($msg);
    }
}

#------------------------------------------
# 5. Import all Env to current variables
#------------------------------------------
my $resultFile = $gflaunch_userInput{logdir}."/result.txt";
$ENV{'G_RESULT'}= $resultFile;
$gflaunch_userInput{env}{G_RESULT}= $resultFile;
$ENV{'G_LOG'}= $gflaunch_userInput{logdir};
($gflaunch_scalar{rc},$gflaunch_scalar{msg})= importEnv(\%gflaunch_userInput,0);

#---------------------------------------------
# 6. Set up all necessary global variables
#---------------------------------------------

#Set up filename for ftp directory 
($gflaunch_scalar{rc},$gflaunch_scalar{msg})= setUpEnv(\%gflaunch_userInput,\%gflaunch_globalVar);
$ENV{'G_TSUITE'}=$gflaunch_scalar{fname};
$gflaunch_userInput{env}{G_TSUITE}=$gflaunch_scalar{fname};


if ( $gflaunch_scalar{rc} != 1) {
    $gflaunch_userInput{logger}->info($msg);
} 


$gflaunch_scalar{step} = 0;
$msg = "Start---- ** GLOBAL ENVIRONMENT VARIABLES USED FOR GFLAUNCH.PL **---";
$gflaunch_userInput{logger}->info($msg);
foreach (sort keys %ENV ) {
    if ( $_ !~ /^[G|U]_/){
        next;
    }
    $msg ="$gflaunch_scalar{step}: ENV $_ = $ENV{$_}";
    $gflaunch_userInput{logger}->info($msg);
    $gflaunch_scalar{step}++;
}
$msg = "End ----- *******************************************************---";
$gflaunch_userInput{logger}->info($msg);


if ( $gflaunch_userInput{debug} > 1 ) {
    $msg = "Start---- ** GLOBAL ENVIRONMENT VARIABLES not SPECIFIC USED for GFLAUNCH.PL **---";
    $gflaunch_userInput{logger}->info($msg);
    $gflaunch_scalar{step} = 0;
    foreach (sort keys %ENV ) {
        if ( $_ =~ /^[G|U]_/){
            next;
        }
        $msg ="$gflaunch_scalar{step}: ENV $_ = $ENV{$_}";
        $gflaunch_userInput{logger}->info($msg);
        $gflaunch_scalar{step}++;
    }
    $msg = "End ----- *******************************************************---";
    $gflaunch_userInput{logger}->info($msg);
}

#---------------------------------------------
# 7. execute testcases 
#---------------------------------------------
$gflaunch_userInput{resultFile} = $resultFile;
$gflaunch_userInput{resultFN} =  *STDOUT;
my $fd = *STDOUT;
if ( $gflaunch_userInput{logOff} == 0 ) {
    open (RESULTFN,">$resultFile");
    $gflaunch_userInput{resultFN} = *RESULTFN;
    $fd = *RESULTFN;
}
my $temp = $NOFUNCTION;
my $temp2 = $NOFUNCTION;
if ( defined $ENV{'G_PROJID'} ) {
    $temp = $ENV{'G_PROJID'};
}
if ( defined $ENV{'G_BUILDID'} ) {
    $temp2 = $ENV{'G_BUILDID'};
}
my $tbType = $NOFUNCTION;
if ( defined $ENV{'G_TBTYPE'} ) {
    $tbType = $ENV{'G_TBTYPE'};
}
my $tstName = $gflaunch_userInput{env}{G_TST_TITLE};
$temp = "G_TST_TITLE=\"$tstName\"\n"."G_PROJID=$temp\n"."G_BUILDID=$temp2\n"."G_TBTYPE=".$tbType."\n";
$msg = "http://".$gflaunch_userInput{env} {G_HTTP_SERVER}.$gflaunch_userInput{env}{G_HTTP_DIR} ."/gflaunch_info.log\n";
$msg = $temp."For entire log please see at: ".$msg;
$msg = $msg." or coke:".$gflaunch_userInput{env}{G_FTP_DIR} ."/gflaunch_info.log\n";
printf $fd ($msg);
#close RESULTFN;  
($gflaunch_scalar{rc},$gflaunch_scalar{msg}) = launchTest(\%gflaunch_userInput);
$gflaunch_scalar{limit} = $#{$gflaunch_userInput{tcase}}; 
#open (RESULTFN, ">> $resultFile");

#---------------------------------------------
# 8. Display and Save the final result
#---------------------------------------------
my $function;
my $ftpserver;
$gflaunch_userInput{logger}->info("--- TEST SUMMARY saved at $resultFile ---");
if ( !( $gflaunch_scalar{fname} =~ m/$NO_FILE/  )) {
    printf $fd ("Test Suite Name: $gflaunch_userInput{filename}\n"); 
} else {
    printf $fd ("Test Suite Name: not used \n"); 
}
#-------------------------------------------------
# Post Result
#-------------------------------------------------
my $exitRc;
$gflaunch_scalar{limit}++;
$numberOfTcFail = $gflaunch_userInput{tcfail};
$numberOfTcPass = $gflaunch_userInput{tcpass};
$numberOfNcFail = $gflaunch_userInput{ncfail};
$numberOfNcPass = $gflaunch_userInput{ncpass};
$numberofIc = $gflaunch_userInput{icnum};
my $totalTC = $numberOfTcFail + $numberOfTcPass;
my $totalNTC = $numberOfNcFail + $numberOfNcPass; 
if ( ( $gflaunch_userInput{tcfail} != 0) || ( $gflaunch_userInput{ncfail} != 0) ) {
    $msg="Test Failed: Number of Testcases ($totalTC) -- Failed($numberOfTcFail)\
    \t\tNumber of Non-Testcases ($totalNTC) -- Failed($numberOfNcFail)\
	\t\tNumber of ignore Testcases ($numberofIc)";
    $exitRc =  $SP_FAIL;
} else {
    $exitRc = $SP_PASS;
    $msg="Test Passed: Number of Testcases ($totalTC) -- Passed($numberOfTcPass)\
    \t\tNumber of Non-Testcases ($totalNTC) -- Passed($numberOfNcPass)\
	\t\tNumber of ignore Testcases ($numberofIc)";
}
$gflaunch_userInput{logger}->info($msg);
printf $fd ("$msg\n");
close $fd;
exit ($exitRc);
1;
__END__

=head1 NAME

gflaunch.pl - launch a testsuite/individual testcases.

=head1 SYNOPSIS

=over 12

=item B<gflaunch.pl>

[B<-help|-h>]
[B<-man>]
[B<-s> I<turn off to print logs to screen >]
[B<-n> I<turn off to print logs to log directory >]
[B<-l> I<logdir (defaults:$SQAROOT/logs)>]
[B<-c> I<number of entries when creating template>]
[B<-t> I<template  filename >]
[B<-f> I<test suite filename >]
[B<-v> I<G_BUILD=vfxxx.img > [-v I<G_USER=userEmail> ...]]
[B<-tc|nc> I<testcase or non testcase >]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-n >

Turn off the logging of the output messages.

=item B<-l >

Redirect stdout to the /path  

=item B<-h>

Print a brief help message and exit.

=item B<-man>

Print a man page 

=item B<-c>

Count of entries when creating template. Default is 1

=item B<-t>

Name of template

=item B<-f>

Name of test suite which contains a set of testcases 

=item B<-v>

Variable (-v) option is used to allow user to pass variables via gflauncher.pl (e.g  -v G_BUILD=</path/build_names> for uploading the image or -v G_USER=<email user name>)

=item B<-tc>

Testcase (-tc) option allows user to run an/more invidual testcase(s) ( e.g: -tc /path/testcase_names)

=item B<-nc>

Non testcase (-nc) option allows user to run an/more invidual testcase(s) ( e.g: -nc /path/testcase_names). There is no different between -nc and -tc with the exception that gflaunch.pl  needs to differentiate testcases and non testcases categories.

=head1 DESCRIPTION

B<gflaunch.pl> is used to launch test suite and record test logs. It allows a dynamic environment
of adding new application via -tc or -nc options.


=head1 EXAMPLES

1. The following command is used to run a list of testcases from command line
         perl gflaunch.pl  -v BUILD=/main/projects/builder/autobuild/official/trunk-ver_4r2b4/vf2113/vf2113_mos_v4r2b4.img -v G_USER=jnguyen -tc $SQAROOT/platform/$G_PFVERSION/testcases/sample/tc1.xml -tc $SQAROOT/platform/$G_PFVERSION/testcases/sample/tc2.xml -v G_USER=int-sqa


2. The following command is used to run a testsuite 
         perl gflaunch.pl  -v BUILD=/main/projects/builder/autobuild/official/trunk-ver_4r2b4/vf2113/vf2113_mos_v4r2b4.img -v G_USER=jnguyen -f  /svn/svnroot/QA/automation/testsuites/1.0/common/test345.tst -v G_USER=int-sqa


=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut

