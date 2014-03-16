#!/usr/bin/perl -w
#---------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to configure DUT with CLI via telnet/minicom. User could enter single string(s)
# from command line or from text file
# 
#
#--------------------------------
# History       :
#   DATE        |   REV     | AUTH      | INFO
#31 Oct 2011    |   1.0.0   | rayofox   | Initial Version
#28 Mar 2012    |   1.0.1   | alex      | improve the code about login and retry control
#


use strict;
use warnings;
#use diagnostics;
use Expect;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
my $learnFn =0;
my $FAIL=0;
my $PASS=1;
my $ERR_TMO=2;
my $CLI_TMO=1;
my $CLI_PROMPT= 2;
my $CLI_ILLEGAL=3;
my $CLI_LOGOUT=4;
my $DEFAULT_RETRY = 5;
my $EXP_DELIMITER ="@";
my $verbose = 0;
my $NOFUNCTION="no function";
my $SSHPORT=22; # ssh
my $TELPORT=23; # telnet
my $SFTPPORT=115;#sftp
my $STUNNELPORT=992;#stunnel
my $CONSOLE=782;#console
my $QAPROMPT = '^.*-> \r?$';
my $CON_PROMPT = '^\[Enter .*$';
my $CON_PROMPT2 = '^\[bumped .*$';
my $NO_FILE= "No File specified";
my $UNDEF= "undefined";
my $MORE="\-\-More";
my %userInput = (
    "user" => "admin",
    "password" => "admin",
    "debug" => 0,
    "tmo" => 5,
    "waittime"=> 5,
    "logdir"=>"./",
    "tsIp"=>"127.0.0.1",
    "port"=>"21",
    "ttyPort"=>"",
    "ttyFlag"=> 0,
    "filename"=> $NO_FILE,
    "learn"=> 0,
    "learnFile" => $NO_FILE,
    "nosleep" => 0,
    "bypassipcheck" => 0,
    "usesftp" => 0,
    "testbed" =>$UNDEF,
    );


my %specialTbl=("reset\$"=>{ "function"=>"waitForLogin",
                 "tmo"=>5,
                 "retry"=>20,
                 "prompt"=>['System reset, are you sure? *'],
                 "response"=>['y'],
                 "notmo"=>0,

        },
        "reset no-prompt\$"=>{ "function"=>"waitForLogin",
                       "tmo"=>5,
                       "retry"=>30,
                       "prompt"=>[],
                       "response"=>["y"],
                       "notmo"=>0,
        },
        "reset save-config yes\$"=>{ "function"=>"waitForLogin",
                         "tmo"=>5,
                         "retry"=>30,
                         "prompt"=>[],
                         "response"=>["y"],
                         "notmo"=>0,
        },
        "DONTMATCHsave "=>{ "function"=>"dummy",
                   "tmo"=>10,
                   "retry"=>70,
                   "prompt"=>[],
                   "response"=>[],
                    "notmo"=>0,
        },
        "unset all\$"=>{ "function"=>$NOFUNCTION,
                   "tmo"=>5,
                   "retry"=>30,
                   "prompt"=>["Erase all system config, are you sure* "],
                   "response"=>["y"],
                 "notmo"=>0,
        },
        "exit\$"=>{ "function"=>"waitForLogin",
               "tmo"=>10,
               "retry"=>5,
               "prompt"=>["Please press Enter to activate this console*"],
               "response"=>["y"],
               "notmo"=>1,
        },
        "^perl -MCPAN"=>{ "function"=>"perlInstall",
                  "tmo"=>5,
                  "retry"=>60,
                  "prompt"=>['\[yes\]'],
                  "response"=>["yes"],
                  "notmo"=>1,
        },
        "^enable\$"=>{ "function"=>$NOFUNCTION,
                  "tmo"=>5,
                  "retry"=>60,
                  "prompt"=>['[P|p]assword:'],
# I don't like this , for the hack only
                  "response"=>['actiontec'],
                  "notmo"=>1,
        },


    );

#--------------------------------------------
# This routine is used to verify the result of the actual
# data with previous learning data
#---------------------------------------------
sub expectTest {
    my ($errCode,$buffer,$expBuffer) = @_;
    my $rc = $PASS;
    my $msg = "Passed: CLI ok\n";
    my $limit = 0;
    my $i =0;
    my $data1 = 0;
    my $data2 = 0;
  SWITCH_EXPECTTEST: for ($errCode) {
    /$CLI_LOGOUT/ && do  {
        printf "CLI_LOGOUT case \n";
        $rc = $PASS;
        $msg = "ExpecTest -- telnet exit";
        last;
    };
    /$CLI_TMO/ && do  {
        printf "CLI_TMO case \n";
        $rc = $FAIL;
        $msg = "Error: expecTest -- Command did not response";
        last;
    };
    /$CLI_PROMPT/ && do {
        printf "CLI_PROMPT case \n";    
        $limit = @{$expBuffer};
        for ( $i = 0 ; $i <$limit ; $i++) {
        $data1 =  $buffer->[$i];
        $data2 = $expBuffer->[$i];
        if ( $data2 =~ /^#/) {
            next;
        }
        if (( $data1 ne $data2 )) {
            $rc = $FAIL;
            $msg = "Error: expectTest -- actual data:$data1\n does not matched with \nexpected data:$data2 "; 
            last;
        } else {
            $rc = $PASS;
            $msg = "Passed: expectTest -- expected and actual data are matched";
        }
        }
        last;
    };
    /$CLI_ILLEGAL/ && do {
        printf "CLI_ILLEGAL case \n";
        #get array size;
        $rc = $FAIL;
        $msg = "Error: ExpectTest -- Illegal syntax/command";

        $limit = @{$expBuffer};
        for ( $i = 0 ; $i <$limit ; $i++) {
        $data1 = $buffer->[$i];
        $data2 = $expBuffer->[$i];
        if ( $data2 =~ /^\#/) {
            printf "Skip testing $data2";
            next;
        }
        if (( $data1 ne $data2)) {
            $rc = $FAIL;
            
            $msg = "Error: ExpectTest --Illegal syntax/command -- actual data:$data1\n does not matched with \nexpected data:$data2 "; 
            last;
        } else {
        $rc = $PASS;
        $msg = "Passed: expectTest -- illegal command matched with User data";  
        }
        }
        last;
    } ;
    die "ExpectTest -- unknown value for SWITCH_EXPECTTEST where errCode=$errCode";
    }
    return($rc,$msg);
}


#---------------------------------------------------------
# This routine is used to send/learn/replay a command
#----------------------------------------------------------
sub sendCmd {
#    my ($localExp,$timeout,$cmd,$expBuffer,$learnFlag) = @_;
    my ($localExp,$cmd,$expBuffer,$userInput) =@_;

    my $timeout = $userInput->{tmo};
    my $learnFlag = $userInput->{learn};

    my $rc = $FAIL;
    my $msg = "ClI OK";
    my @buffer = 0;
    my @buffer2=0;
    my $i = 0;
    my $line ;
    my $errorCode=0;
    $localExp->clear_accum();
    $rc = $localExp->send("$cmd\n");
    # Need a sleep 2 seconds for buffer settling
    if ( $userInput->{nosleep} == 0 ) { 
    sleep 2;
    } 

    @buffer2 = $localExp->expect($timeout,          
          [
        qr/unknown keyword */,
        sub {       
            $rc = $PASS;
            $errorCode =  $CLI_ILLEGAL;         
            printf "--- unknown  --- - \n " if $verbose ;
        }
           ],
          [
        qr/Unrecognized command */,
        sub {       
            $rc = $PASS;
            $errorCode =  $CLI_ILLEGAL;         
            printf "--- Unrecognized command  --- - \n " if $verbose ;
        }
           ],
           [
        qr/command not completed*/,
        sub {       
            $rc = $PASS;
            $errorCode =  $CLI_ILLEGAL;         
            printf "--- command not completed   --- - \n " if $verbose ;
        }
           ],
 

          [
        qr"$CON_PROMPT",
        sub {       
            $rc = $PASS;
            printf " --- console --- \n" if $verbose ; 
            $errorCode =  $CLI_PROMPT;          
        }
           ],
           [
        qr'--More--',
        sub {       
            $rc = $PASS;
            printf " --- MORE  --- \n" ; #if $verbose ; 
            $errorCode =  $CLI_PROMPT;          
        }
           ],
          [
        qr"$QAPROMPT",
        sub {       
            $rc = $PASS;
            printf " ---  CLI --- \n" if $verbose ; 
            $errorCode =  $CLI_PROMPT;          
        }
           ],
  
          [
        'cli-> $',
        sub {       
            $rc = $PASS;
            printf " ---  CLI --- \n" if $verbose ; 
            $errorCode =  $CLI_PROMPT;          
        }
           ],
 
          [
        '[L|l]ine-> $',
        sub {       
            $rc = $PASS;
            printf " ---  SLIMLINE --- \n" if $verbose ; 
            $errorCode =  $CLI_PROMPT;          
        }
           ],


  
          [
        '^logout',
        sub {       
            $rc = $PASS;
            printf " ---  CLI --- \n" if $verbose ; 
            $errorCode =  $CLI_LOGOUT;  
            $msg = "--- LOGOUT  ---- \n";
            printf $msg  if $verbose;
            return ($rc,$msg);

        }
           ],

  
          [
        '\]# *$',
        sub {       
            $rc = $PASS;
            printf " ---  CLI --- \n" if $verbose ; 
            $errorCode =  $CLI_PROMPT;          
        }
           ],

          [
                timeout => 
                sub {
            $rc = $ERR_TMO;
            $msg =  " Error: No response from CLI\n" ;
            $errorCode =  $CLI_TMO;         
            printf "--- $msg ---- \n" if $verbose;
            return ($rc,$msg);
           }
          ],
    );
    @buffer= split ("\n",($localExp->before( ).$localExp->match().$localExp->after( )));
    $localExp->clear_accum();
  SWITCH_SENDCMD:
    for ($learnFlag) {    
#learning;
     /1/ && do  {
#       printf $learnFn "=> learn Flag $learnFlag SEND CMD  $cmd \n"; 
        print $learnFn "$cmd\n" ;
        foreach ( $i=1 ; $i < $#buffer; $i++) {
        $line = $EXP_DELIMITER . $buffer[$i];
        print $learnFn "$line\n";
        }
        last;
     };
#non learning
     #pop the 1st entry
     ($rc,@buffer2)=@buffer;
#    printf ("\n BUFFER 2 = $buffer2[0]\n BUFFER1 = $buffer[0]\n");
     ($rc,$msg) = expectTest($errorCode,\@buffer2,$expBuffer);
     printf " RC($rc)=$msg \n";
     # temporary for debug ( need to delete/comment out  this portion )
     if ( $verbose ) {
         if ($rc == $FAIL) {
         printf"\n Original Buffer";
         my $buffFN1="bufferOrg.txt";
         my $buffFN2="bufferClean.txt";
         my $junk1;
         $line="";
         $junk1 = `rm -f  $buffFN1`;
         $junk1 = `rm -f $buffFN2`;
         foreach ( $i=0 ; $i < $#buffer; $i++) {
             $line = $buffer[$i];
             if ( $line !~ /\s*/ ) { printf "$line\n" } ;
             $junk1 = `echo $line >> $buffFN1`;
         }
         
         printf"\n Buffer already cleaned";
         foreach ( $i=0 ; $i < $#buffer2; $i++) {
             $line = $buffer2[$i];
             if ( $line !~ /\s*/ ) { printf "$line\n" } ;
             $junk1 = `echo $line >> $buffFN2`;
         }
         }
     }
     last;
    }
    
    $localExp->clear_accum();
    return ( $rc,$msg);
}
#---------------------------------------------
# This routine is used to execute special commands based on %specialTBL
#---------------------------------------------
sub specialCmdProcess {
    my ($localExp,$timeout,$com,$userInput,$entry) = @_;
    my $prompt = $entry->{prompt}; 
    my $resp = $entry->{response};
    my $wait = $entry->{tmo};
    my $retry = $entry->{retry};
    my $notmofail = $entry->{notmo};
    my $i = 0;
    my $rc = $PASS;
    my $junk;
    my $pp;
    my $rr;
    my $bypass = 0;
    my $msg = "ExtraCmd process passed";
    my $limit = @{$prompt};
    $localExp->clear_accum();
    if ( $userInput->{learn} ) { 
    printf $learnFn "$com\n" ;
    }
    $rc = $localExp->send("$com\n");
    # Need a sleep 1 seconds for buffer settling
    sleep 1;
    for ($i = 0 ; $i < $limit ; $i++) {
    $pp = $prompt->[$i];
    $rr = $resp->[$i];
    printf ( "+++ tmo[$timeout] prompt \[$pp\] and resp $rr \n ");
    $localExp->expect($timeout,
              [
               $pp,
               sub {
                   $rc = $PASS;
                   printf (" GET question \n ");
                   my $fh = shift;
                   $fh->send("$rr\n");
               }
              ],
              [
               '\]# ?$',
               sub {
                   my $fh = shift;
                   $bypass = 1;
                   print (" GET PROMPT \n ");
                   $fh->send("\n");
                   $rc = $PASS;
               }
              ],

              [ timeout=>
                sub {
                $rc = $FAIL;
                $rc = $PASS if ( $notmofail);
                $junk = ( $localExp->before());
                $msg = " TIME OUT : Special command  process failed at $pp --$junk";
                print "\n $msg ";
                return;
                }
              ],              
        );    


    if ( $rc == $FAIL ) {
        return($rc,$msg) ;
    }
    }   
    $localExp->expect($timeout,           
              [
               'cli-> $',
               sub {
               my $fh = shift;
#              $fh->send("$resp->[$i]\n");
               }
              ],
              [
               "$QAPROMPT",
               sub {
               my $fh = shift;
#              $fh->send("$resp->[$i]\n");
               }
              ],

              [
               '[L|l]ine-> $',
               sub {
               my $fh = shift;
               }
              ],

              [
               '\]# $',
               sub {
               my $fh = shift;
               $bypass = 1;
               }
              ],

              [ timeout=>
            sub {
#               $rc = $FAIL;
                $junk ="";
                if (defined $localExp->before()) {
                $junk .= $localExp->before();
                }
                if (defined $localExp->match()) {
                $junk .= $localExp->match();
                }
                if (defined $localExp->after()) {
                $junk .= $localExp->after();
                } 
                $msg = "Special command  process failed at $junk";
                #return; /11/1/2007 JN no need for this return
            }
              ],              
    );    
    $junk = $localExp->before().$localExp->match().$localExp->after();
#   print ( " JUNK \[$junk\] \n");
    no strict;
    if ( $entry->{function} ne $NOFUNCTION) {
    ($rc,$msg )= $entry->{function}($localExp,$userInput,$retry,$wait,$prompt,$resp,$bypass) ;  
#   $junk =5;
#   print ( " Sleep for $junk seconds \n");
#   sleep $junk; # add on 10/30
    }
    $rc = $PASS;
    use strict;
    return ($rc,$msg);
    
}
    
#--------------------------------
# This routine is used to send commands from the commands arrays entered
# via file system or command line
#--------------------------------
sub sendBatchCmd {
    my $spawn_ok = 0;
    my ($localExp,$cmands,$userInput) = @_;
    my $timeout = $userInput->{tmo};
    my $learnFlag = $userInput->{learn};
    my $rc=$PASS;
    my $ii; 
    my $llimit = 0;
    my $com = 0;
    my $nextCom = 0;
    my @expCom = ( );
    my $prevCom = "";
    my $startFlag = 0;
    my $key;
    my $msg = "Execute all commands complete\n";
    $llimit = $#{$cmands};
#    printf " Limit = $llimit ;COMMAND $cmands";
    # clean all expect buffer
    $localExp->expect(0);   
    if ( @{$cmands} == 0 ) {

    $msg = "Command Buffer is Empty ";
#   printf "WARNING: $msg \n";
    return ($rc,$msg);
    }
    my $nextEntry = 0;
    for ( $ii=0; $ii <= $llimit; $ii++) {
    $com = $cmands->[$ii];
    $com =~ s/\n//;
#   printf " [$ii]COMMAND = $com \n";
    #skip the comment line 
    if (( $com =~ m/^[\#]/ )  && ($startFlag == 0) ){
        
        printf (" Comment Skip $com \n");
        if ($learnFlag) {
        print $learnFn "$com\n" ;
        }
        next;
    }
        if ( $com =~ m/^$EXP_DELIMITER/) {
        # skip if expected data are not accompanied by its command
        if ( $startFlag == 0 ) {
        next;
        }
    } 
    $nextEntry = $ii + 1;
#   printf (" NEXT ENTRy $nextEntry  and limit= $llimit \n");
    if ( $nextEntry <= $llimit ) {
        $nextCom = $cmands->[$nextEntry];
     #   printf (" 2: Next Command $nextCom \n");
        if ( $nextCom =~ m/^$EXP_DELIMITER/ ) {
        if ( $startFlag == 0 ) {
            $startFlag = 1;
            $prevCom=$com; 
            next;
        }
        $com =~ s/$EXP_DELIMITER//;
        if ( !(defined($expCom[0]))) {
            $expCom[0] = $com;
        } else {
            push(@expCom,$com);
        }
        next;
        }
    }
    if ( $startFlag == 1 ) {
        $com =~ s/$EXP_DELIMITER//;
        push(@expCom,$com);
        $com = $prevCom;
    }
    $startFlag = 0; 
    $localExp->clear_accum();
    my $foundFlag = 0;
    print "EXECUTE \[$ii\]:$com\n" if ($userInput->{debug} > 0 );
    #---------------------------------------------------------------
    # Need to handle special CLI as programmed from specialTbl array
    #-----------------------------------------------------------------
    foreach $key ( keys %specialTbl ) {
        if ( $com =~ /$key/ ) {
        print ("Special cmd[$com] and key [$key]\n");
        $foundFlag = 1;
        my $prompt = $specialTbl{$key}->{prompt};
        my $retry = $specialTbl{$key}->{retry};
        my $wait = $specialTbl{$key}->{tmo};        
        ($rc,$msg) = specialCmdProcess($localExp,$wait,$com,$userInput,$specialTbl{$key});
        }
    }
    if ($foundFlag == 0 ) {
        #------------------------------
        # Execute non special cli
        #-----------------------------
        ($rc,$msg) = sendCmd($localExp,$com,\@expCom,$userInput);   
    }
#   printf ( " RC === $rc \n");
      SWITCH_SENDBATCHCMD: for ($rc) {
         /$FAIL/ && do {     
#       printf " --- \n CASE 0 : $msg\n";
         $msg =$msg."\nFailed at line \[$ii\]:$com\n";
        return($rc,$msg);       
         };
         /2/ && do  {
#       printf " CASE 2 : $msg";
         $msg =$msg."\nFailed at line \[$ii\]:$com\n";
        return($rc,$msg);       
         };
         /$PASS/ && do { 
#        printf " CASE 1 : $msg";
         last; 
         };
         die "unknown value for SWITCH_EXPECTTEST where return code =$rc \n";              }
    @expCom = ( );
    }
    return ($rc,$msg);
}
#--------------------------------
# This routine is used for login
#--------------------------------

sub dummy {
    my ($localExp,$userInput,$retry,$wait,$prompt,$resp) = @_;    
    my $timeout = $userInput->{tmo};
    my $rc = $FAIL;
    my $msg = " DUMMY function \n";
    my $tmoFlag;
    my $a = 0;
    my $localRetry = 0;
    printf $msg;
    while ( $a < 4 ) {
    $localExp->expect($timeout,           
              [
               '\]# $',
               sub {
                   my $fh = shift;
                   if ($a == 3 ) {
                   $a = 4;
                   $rc = $PASS;
                   return;
                   }
                   $fh->send("\n");
                   $a = 3;
               }
              ],

              [
               '[L|l]ine-> $',
               sub {
                   my $fh = shift;
                   if ($a == 3 ) {
                   $a = 4;
                   $rc = $PASS;
                   return;
                   }
                   $fh->send("\n");
                   $a = 3;
               }
              ],

              [
               'cli-> $',
               sub {
                   my $fh = shift;
                   if ($a == 3 ) {
                   $a = 4;
                   $rc = $PASS;
                   return;
                   }
                   $fh->send("\n");
                   $a = 3;
               }
              ],
              [
               "$QAPROMPT",
               sub {
                   my $fh = shift;
                   if ($a == 3 ) {
                   $a = 4;
                   $rc = $PASS;
                   return;
                   }
                   $fh->send("\n");
                   $a = 3;
               }
              ],
              
              [
               timeout =>
               sub {
                   my $fh = shift;
                   $tmoFlag = 1;
                   if ($localRetry < $retry ) {
                   $localRetry +=1;
                   print "+++ Wait for $wait seconds";
                   sleep $wait; 

                   $rc = $PASS;
                   return;
                   }
                   $rc =$FAIL;
                   $a = 10;
                   $tmoFlag = 0;
                   return;
               }
              ],
              '-re', qr'[#>:] $', #' wait for shell prompt, then exit expect
        );
#   print "\nStatus($a): $spawn_ok\n";
    if ($tmoFlag == 1 ) {
        $localExp->send("\n");
        $tmoFlag = 0;
    }
    }


    
    return($PASS,$msg);
}

#--------------------------------
# This routine is used for login
#--------------------------------

sub perlInstall {
    my ($localExp,$userInput,$retry,$wait,$prompt,$resp,$bypass) = @_;    
    my $timeout = $userInput->{tmo};
    my $login = $userInput->{user};
    my $passwd = $userInput->{password};
    my $a=0;
    my $ycount = 0;
    my $rc =$FAIL;
    my $spawn_ok = 0;
    my $localRetry = 0;
    my $junk;
    my $tmoFlag =0;
    my $localpp = $prompt->[0];
    my $localresp = $resp->[0];
    print (" perlIntall \n");
    if ( $bypass == 1 ) {
    return ($PASS,"Status $a ");
    }
    while ( $a < 4 ) {
    $localExp->expect($timeout,           
              [
               "$localpp",
               sub {
                   my $fh = shift;
                   print ( "Wait for:$localpp\n");
                   $fh->send("$localresp");
                   sleep 2;
               }
              ],
              [
              'Enter arithmetic or Perl expression: exit',
               sub {
               my $fh = shift;
               print ( "Enter arithmetic .... \n");
               $fh->send("\n");
               sleep 2;

               }
              ],
              [
              'Do you want to modify/update your configuration (y|n) ? \[no\]',
               sub {
                   my $fh = shift;
                   printf ( "\nDo you .... \n");
                   $fh->send("yes\r\n");
                   sleep 2;
               }
              ],

              [
               "$QAPROMPT",
               sub {
                   my $fh = shift;
                   if ($a == 3  ) {
                   $a = 4;
                   $rc = $PASS;
                   return;
                   }
                   $spawn_ok = 1;
                   $fh->send("\r\n");
                   $a = 3;
               }
              ],
              [
               '\]#',
               sub {
                   my $fh = shift;
                   if ($a == 3 ) {
                   $a = 4;
                   $rc = $PASS;
                   return;
                   }
                   $fh->send("\r\n");
                   $a = 3;
                   
               }
              ],
              [
               '^y$'=>
               sub {
                   $rc = $PASS;
                   if ( $ycount > 10 ) {
                   $rc = $FAIL;
                   $a = 4;
                   }
                   $ycount++;
                   $tmoFlag = 1;
                   return;
               }
              ],


              [
               timeout =>
               sub {
                   my $fh = shift;
                   $tmoFlag = 1;
                   if ($localRetry < $retry ) {
                   $localRetry +=1;
                   print "-- Wait for $wait seconds";
                   sleep $wait; 
                   $rc = $PASS;
                   return;
                   }
                   $rc =$FAIL;
                   $a = 10;
                   $tmoFlag = 0;
                   return;
               }
              ],
              '-re', qr'[#>:] $', #' wait for shell prompt, then exit expect
        );
#   print "\nStatus($a): $spawn_ok\n";
    if ($tmoFlag == 1 ) {
        $localExp->send("\r\n");
        $tmoFlag = 0;
    }
    }
    sleep 2;
    $junk = $localExp->before().$localExp->match().$localExp->after();              
    return ($rc,"Status $a ");
}
#--------------------------------
# This routine is used for login
#--------------------------------

sub waitForLogin {
    my ($localExp,$userInput,$retry,$wait,$prompt,$resp,$bypass) = @_;    
    my $timeout = $userInput->{tmo};
    my $login = $userInput->{user};
    my $passwd = $userInput->{password};
    my $a=0;
    my $rc =$FAIL;
    my $spawn_ok = 0;
    my $localRetry = 0;
    my $junk;
    my $tmoFlag =0;
    while ( $a < 4 ) {
    $localExp->expect($timeout,           
              [
               "Please press Enter to activate this console*",
               sub {
                   $spawn_ok = 1;
                   my $fh = shift;
                   $fh->send("\n");
                   sleep 1;
                   $a = 0;
               }
              ],
              [
               "Connection closed by foreign host.",
               sub {
                   my $fh = shift;
                   $rc =$FAIL;
                   $a = 21;
                   $tmoFlag = 0;
                   #print "CONNECTION CLOSED by FOREIGN HOST";
                   return;
               }
               ],
              [
               "Press CTRL-A Z for help on special keys*",
               sub {
                   $spawn_ok = 1;
                   my $fh = shift;
                   $fh->send("\n");
                   sleep 2;
               }
              ], 

              [
               "Connection refused",
               sub {
                   my $fh = shift;
                   $rc =$FAIL;
                   $a = 20;
                   $tmoFlag = 0;
                   print " CONNECTION REFUSED";
                   return;
               }
              ], 

              [
               "Are you sure you want to continue connecting (yes/no)?",
               sub {
                   $spawn_ok = 1;
                   my $fh = shift;
                   printf (" SSH \n ====== \n");
                   $fh->send("yes\n");
                   if ($userInput->{port} == $TELPORT) {
                   $a = 1;
                   }
                   if ($userInput->{port} == $SSHPORT) {
                   $a = 1;
                   }

                   sleep 2;
               }
              ], 

              [
               'Escape character is *',
               sub {
                   $spawn_ok = 1;
                   my $fh = shift;
#                  $fh->send("\n");
               }
              ],

              [
               '\]# *$',
               sub {
                   my $fh = shift;
                   if ($a == 3 ) {
                   $a = 4;
                   $rc = $PASS;
                   return;
                   }
                   $spawn_ok = 1;
                   $fh->send("\n");
                   $a = 3;
               }
              ],

              [
               '[L|l]ine-> $',
               sub {
                   my $fh = shift;
                   if ($a == 3 ) {
                   $a = 4;
                   $rc = $PASS;
                   return;
                   }
                   $spawn_ok = 1;
                   $fh->send("\n");
                   $a = 3;
               }
              ],
              
              [
               "$CON_PROMPT",
               sub {
                   my $fh = shift;
                   $spawn_ok = 1;
                   print " ENTER ";
                   $fh->send("\n");
                   $fh->send("\n");
#                  $fh->send("exit\n");
                   $a = 0;
               }
              ],
              [
               "$CON_PROMPT2",
               sub {
                   my $fh = shift;
                   $spawn_ok = 1;
                   print " bumped ";
                   $fh->send("\n");
                   $fh->send("\n");
#                  $fh->send("exit\n");
                   $a = 0;
               }
              ],

    
              [
               'cli-> $',
               sub {
                   my $fh = shift;
                   if ($a == 3 ) {
                   $a = 4;
                   $rc = $PASS;
                   return;
                   }
                   $spawn_ok = 1;
                   $fh->send("\n");
                   $a = 3;
               }
              ],

              [
               "$QAPROMPT",
               sub {
                   my $fh = shift;
                   $spawn_ok = 1;
                   if ($a == 3 ) {
                   $a = 4;
                   $rc = $PASS;
                   return;
                   }
                   if ($a == 0) {
                   if ($userInput->{port} == $CONSOLE) {
                       $fh->send("exit\n");
                       return;
                   }
                   }
                   $fh->send("\n");
                   $a = 3;
               }
              ],
              
              [
               qr'Username: .*$',
               sub {
                   if ($localRetry < $retry ) {
                       $localRetry +=1;
                   }else {
                       print "\nLogin failed!\n";
                       $rc =$FAIL;
                       $a = 10;
                       $tmoFlag = 0;
                       return;
                   }                   
                   $spawn_ok = 1;
                   my $fh = shift;
#                  print " USER +$login+";
#                  sleep 1;
                   $fh->send("$login\n");
                   $a = 1;
                   sleep 1;
               }
              ],


              [
               qr'[l|L]ogin: $',
               sub {
                   $spawn_ok = 1;
                   my $fh = shift;
                   $fh->send("$login\n");
                   $a = 1;
                   
               }
              ],
              [
               qr'[P|p]assword: .*$',
               sub {
                   my $fh = shift;
                   my $rc = $FAIL;
                   if ( $userInput->{port} == $TELPORT ) {
                   $a = 1;
                   }
                   if ( $userInput->{port} == $SSHPORT ) {
                   $a = 1;
                   }
                   if ( $userInput->{port} == $SFTPPORT ) {
                   $a = 1;
                   }
                   if ( $userInput->{port} == $STUNNELPORT) {
                   $a = 1;
                   }
                   if ( $userInput->{port} == $CONSOLE) {
                   print "PASS " ;
                   $a = 2;
                   $fh->send("$passwd\n");
                   return;
                   }
                   
                   if ( "$userInput->{port}" =~ /(2602|2601|2604|2605)/ ) {
                   print $userInput->{port} ;

                   $a = 1;
                   }

                   if ( $a < 1 ) {
                   $a = 0;
                   $fh->send("\n");

                   } else {
                   $a = 2;
                   $fh->send("$passwd\n");
                   sleep 1;
#                  print " ==>$passwd< \n";
                   }
               }
              ],
              [
               timeout =>
               sub {
                   my $fh = shift;
                   $tmoFlag = 1;
                   if ($localRetry < $retry ) {
                   $localRetry +=1;
                   print "!!! Wait for $wait seconds";
                   sleep $wait; 
                   $rc = $PASS;
                   return;
                   }
                   $rc =$FAIL;
                   $a = 10;
                   $tmoFlag = 0;
                   return;
               }
              ],
              '-re', qr'[#>:] $', #' wait for shell prompt, then exit expect
        );
#   print "\nStatus($a): $spawn_ok\n";
    if ($tmoFlag == 1 ) {
        $localExp->send("\n");
        $localExp->send("\n") if ( $userInput->{port} == $STUNNELPORT) ;
        $tmoFlag = 0;
    }
    }
    sleep 2;
#    $junk = $localExp->before().$localExp->match().$localExp->after();             
    return ($rc,"Status:$a ");
}
#-----------------------------------------------------------
# This routine is used to check the terminal server
#-----------------------------------------------------------
sub verifyTarget {
    my ($userInput,@jj) = @_;
    my $tsIp= $userInput->{tsIp};
    my $rc = $FAIL;
    my $cmd = `ping -c 5 -w 10 $tsIp `;
    $cmd =~ s/\%/perc/;
    printf " \n $cmd \n";
    my $msg = " $tsIp is reachable";
    @jj = split ("\n",$cmd);
    my $limit= $#jj;
    my $found = 0;
    my $match ="packet loss";
    foreach ( my $i=0 ; $i <= $limit; $i++) {
    if ( $jj[$i] =~ /$match/i ) {
        $found = 0;
        if ( $jj[$i] !~ /100perc/i ) {
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
sub popBuff{
    my ($profFile,$buff)=@_;
    my $fname = $profFile->{filename};
    my $line;
    $fname = `ls $fname`;
    
    $fname =~ s/\n//; 
    if (!( -e $fname) ) {
    print ("ERROR: file $fname could not be found\n");  
    exit 1;
    }
    open(FD,"<$fname") or die "Could not read $fname $!";
    while ( $line = <FD>) {
    $line =~ s/\n//g;
#   next if ( $line =!~ /^\#.*/ );
    push(@{$buff},$line);
    }
}

#************************************************************
# Main Routine
#************************************************************
MAIN:



my $exp;
my $TRUE=1;
my $FALSE=0;
my @junk = split( /\//, $0);
my $scriptFn = $junk[$#junk];

my @userTemp;
my ($x,$h);
my $option_h;
my $rc =0;
my $msg;
my $key;
my $logdir;
my $logdir2;
my $cmd;
my @commands = ();



my $option_man = 0;
$rc = GetOptions( "x"=>\$userInput{debug}, 
          "help|h"=>\$option_h, 
          "c"=>\$userInput{usesftp},
          "man"=>\$option_man, 
          "d=s"=>\$userInput{tsIp},
          "b"=>\$userInput{bypassipcheck},
          "l=s"=>sub {  $logdir = `cd $_[1];pwd`; $logdir2 = $logdir; $logdir=~ s/\n//;$userInput{logdir} = $logdir; },
          "i=s"=>\$userInput{port},
          "u=s"=>\$userInput{user},
          "m=s"=>sub { $userInput{prompt} = $_[1]; $QAPROMPT= $_[1] },
          "n"=>\$userInput{nosleep},
          "p=s"=>\$userInput{password},
          "o=s"=>\$userInput{tmo},
          "f=s"=>sub { $userInput{filename}=$_[1];popBuff(\%userInput,\@commands);}, 
          "e=s"=>\$userInput{testbed},
          "t=s"=>sub { $userInput{learn} = 1; $userInput{learnFile} = $_[1] },
          "s=s"=>sub { $userInput{ttyFlag} = 1; $userInput{ttyPort} .= $_[1] },
          "v=s"=>sub {  push (@commands,$_[1]); } ,
          );
#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);

#printf ("\n----- CLICFG = $userInput{logdir} ------\n");
my $fname = $userInput{filename};
if ( !( $fname =~ m/$NO_FILE/ )) {
    $fname = `ls $fname`;
    $fname =~ s/\n//; 
    $userInput{filename}=$fname;
    if (!( -e $fname) ) {
    printf ("ERROR: file $fname could not be found\n"); 
    exit 1;
    }
}
if ( $userInput{learn}) {
    $userInput{learnFile} = $userInput{logdir}."/".$userInput{learnFile};
}

#printf("--------------- Input Parameters  ---------------\n") if $userInput{debug} ;
printf("---------------$fname Input Parameters  ---------------\n");
foreach $key ( keys %userInput ) {
#    printf (" $key = $userInput{$key} :: " ) if $userInput{debug} ;
    printf (" $key = $userInput{$key} :: " );
}
my $limit = @commands;
if ($limit != 0 ) {foreach my $line (  @commands) { print "$line \n"; } };
($x,$h) =split ('\/',$userInput{tsIp});
$userInput{tsIp} = $x;


my $temp;
my $a = 0;
if ( $userInput{ttyFlag} == 0  ) {
    $rc = $PASS;
    ($rc,$msg) = verifyTarget(\%userInput,0) if ( !($userInput{bypassipcheck}));
    if ( $rc != $PASS ) {
    printf ("\n $msg \n");
    exit 1;
    }
}
if ( $userInput{usesftp} ) {
    $userInput{port}=$SFTPPORT;
}



$temp = $userInput{port};
SWITCHMAIN:
    my $conRefused = 2;
my $conRetry = 0;
my $conWait=2;
my $doneFlag  = 1;
my $stunnelCfg = $userInput{logdir}. "/stunnel.cfg";
while ( $doneFlag ) {
    for ($temp) {
    /$SFTPPORT\b/ && do {
        $cmd  = "sftp $userInput{user}\@$userInput{tsIp} ";
        printf " $cmd \n"; 
        $exp= Expect->spawn($cmd) or die ( "Cannot spawn $cmd $!\n");
        last;
    };

    /$STUNNELPORT\b/ && do {
        #create a file to hold all credential
        $rc=`echo "client=yes" > $stunnelCfg`;
        $rc=`echo "connect=$userInput{tsIp}:992" >> $stunnelCfg`;
        $cmd  = "stunnel  $stunnelCfg";
        printf " $cmd \n"; 
        $exp= Expect->spawn($cmd) or die ( "Cannot spawn $cmd $!\n");
        last;
    };

    /^$SSHPORT\b/ && do {
        $cmd  = "ssh  $userInput{tsIp} -l $userInput{user}";
        printf " $cmd \n"; 
        $exp= Expect->spawn($cmd) or die ( "Cannot spawn $cmd $!\n");
        last;
    };
    /^$TELPORT\b/ && do {
        $cmd = "telnet  $userInput{tsIp} -l $userInput{user}";
        printf " $cmd \n"; 
        $exp= Expect->spawn($cmd) or die ( "Cannot spawn $cmd $!\n");
        
        last;
    };
    /^$CONSOLE\b/ && do {
        $cmd = "console -f  -M $userInput{tsIp} $userInput{testbed}";
        printf " $cmd \n"; 
        $exp= Expect->spawn($cmd) or die ( "Cannot spawn $cmd $!\n");
        sleep 1;
        last;
    };



    if ( $userInput{ttyFlag} == 1  ) {
        $cmd = "minicom $userInput{ttyPort}";
        printf " $cmd \n"; 
        $exp= Expect->spawn($cmd) or die ( "Cannot spawn unreliable process $!\n");
    } else {
        $cmd = "telnet  $userInput{tsIp} $temp ";
        printf " $cmd \n"; 
        $exp= Expect->spawn($cmd) or die ( "Cannot spawn $cmd \n");
    }
    last;
    }
    
#set up log directory
    my $locallog= $userInput{logdir}."/".$scriptFn."\.log";
    my $localfound = 1;
    my $localcount = 0;
    while ($localfound) {
    $localcount++;
    if ( -e $locallog ) {
        $locallog = $userInput{logdir}."/".$scriptFn."\_$localcount\.log";
    } else {
     $localfound = 0;   
    }
    }

    $exp->log_file($locallog,"w");
    my $tmodefault = 0;
    if (!( $userInput{nosleep}) ) {
    sleep 5 ;
    $tmodefault = 5;
    }
        
#--- Wait for Login ----
    
    ($rc,$msg) = waitForLogin($exp,\%userInput,$DEFAULT_RETRY,$tmodefault);
    if ($rc != $PASS ) {
    @junk = split(":",$msg);
    if ( $junk[1] == 20 ) {
        if ($conRetry < $conRefused ) {
        $conRetry +=1;
        print "!!! Wait for $conWait seconds -- $conRetry";
        sleep $conWait; 
        $rc = $PASS;
        next;
        } 
    }
    printf ("\n $msg \n");
    exit 1;
    }
    $doneFlag = 0;
}
#--- Set Up learning File 

if ( $userInput{learn} ) {
    if ( -e $userInput{learnFile} ) {
    $rc = system ( "rm -f $userInput{learnFile}" );
    sleep 1;
    }

    $learnFn = new FileHandle "> $userInput{learnFile}";
}
$temp = \%userInput;
my $buffer= \@commands;
#--- Command Line ----
$limit = @{$buffer};
($rc,$msg) = sendBatchCmd($exp,\@commands,\%userInput);
if ( $rc != $PASS ) {
    printf ("\n==> Cli configuration failed : $msg \n");
    exit (1);
} 
#execute file 
=begin3
if ( ( $fname !~ m/$NO_FILE/ )) {
    open(FN,"<$fname");
    @commands = <FN>;
    ($rc,$msg) = sendBatchCmd($exp,\@commands,\%userInput);
    if ( $rc != $PASS ) {
    printf ("\n==> Cli configuration failed : $msg \n");
    exit (1);
    } 
}
=end3
=cut
if ( $userInput{learn} ) { close ($learnFn)} ;
#undef $learnFn;
printf ( " PRINT EXIT \n");
$exp->send("exit\n");
$exp->expect(3,
         ["Please press Enter to activate this console*", 
          sub { printf " \n I am done \n"; } ],
         [timeout=> sub { printf  " Time out for exit \n  ";} ],
         're',
         );



$exp->log_file();
$exp->hard_close();

printf ("\n==> Cli configuration passed\n");

exit (0);
1;
__END__

=head1 NAME

clicfg.pl - Send "native CLI command" to DUT 

=head1 SYNOPSIS

=over 12

=item B<clicfg.pl>
[B<-help|-h>]
[B<-man>]
[B<-f> I<CLI TEXT FILE>]
[B<-d > I<terminal server IP>]
[B<-e > I<testbed console name>]
[B<-i > I<terminal server IP port>]
[B<-m > I<prompt like to use>]
[B<-n > [do not wait after processing each command]
[B<-u> I<USERNAME> ]
[B<-p> I<PASSWORD> ]
[B<-o> I<timeout per for Expect> ]
[B<-l> I<log file path>]
[B<-s> I<tty port either 0 or 1 or..>]
[B<-t> I<Create a CLI template file>]
[B<-v> I<cli command> [-v I<cli command>] ...]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-d>

Specify a Terminal Server ip address ( default = 192.168.35.78 )

=item B<-e>

Specify a testbed console name( default = undefined )

=item B<-i>

Specify a Terminal Server ip port ( default port = 3700 )
 
=item B<-n>

Specify a "no 1sec wait" after processing each command

=item B<-m>

Specify a specific prompt at the host

=item B<-u>

Specify a user to login to server with

=item B<-p>

Specify a password to login to server with

=item B<-o>

Specify a timeout for Expect to wait for a command

=item B<-l >

Redirect stdout to the /path/clicfg.log if user uses "-v" parameters or "cli text file".log   

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-t>

Set to a learning mode for creating a template file.


=head1 DESCRIPTION

B<clicfg.pl> will allow user to configure a DUT through a series of command lines or from a text file


=head1 EXAMPLES

1. The following command is used to select tty0 and send 2 CLIs commands to the DUT console:
         perl clicfg.pl -s 0 -v "get interface " -v "get configuration all"


2. The following command is used to send 2 CLIs commands via the terminal server with default IP address 192.168.35.78 and port 3700:
         perl clicfg.pl  -v "get interface " -v "get configuration all"


3. The following command is used to send 2 CLIs commands via the terminal server with IP address 192.168.35.79 and port 3800:
         perl clicfg.pl  -d 192.168.35.79 -i 3800 -v "get interface " -v "get configuration all"

4. The following command is used to send 2 CLIs commands and a list of CLI commands file from cli123.txt via the terminal server with IP address 192.168.35.79 and port 3800:
         perl clicfg.pl  -d 192.168.35.79 -i 3800 -v "get interface " -v "get configuration all" -f cli123.txt

5. The following command is used a list of CLI commands file from cli123.txt via a HOST  with IP address 192.168.35.100 at port 22 ( ssh) including password and userid   :
         perl clicfg.pl  -d 192.168.35.79 -i 22  -f cli123.txt -u joe -p hello -m "joe*" 

6. The following command is used to log to tb1_bhr2 terminal server via conserver :
         perl clicfg.pl  -d 10.1.10.20  -i 782  -e tb1_bhr2 [-f cli123.txt] -u admin -p admin1 -m "WIRELESS > " -v "kernel meminfo" 


=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut
