#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
# executeTest.pl
# Name: Aleon
# Contact: hpeng@actiontec.com
# Description: This perl script is used to execute TR069 test case and put out
#              the log infomation.
# Copyright @ Actiontec Ltd.
#-------------------------------------------------------------------------------

use strict;
use warnings;
use diagnostics;
#use Expect;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use Data::Dumper;

# Local variables
my $iCount;
my @junk;
my $temp;
my $rc;
my $count;
my $NOFUNCTION="NOTDEFINED";
my $usage ="Usage: executeTest.pl -s <jacs server> -f <case file name> -v <expect value> -d <directory> -l <log file>\n";
my %userInput = ( "jacs"=>$NOFUNCTION,
          "logDir"=>$NOFUNCTION,
          "caseFile"=>$NOFUNCTION,
          "expectValue"=>$NOFUNCTION,
          "logFile"=>$NOFUNCTION,
        );

# ---------------------- Begin -----------------------------
# Step One: Get the option and check the input.
# ----------------------------------------------------------

# Get the option
$rc = GetOptions( "h|help"=>\$userInput{help},
              "s=s"=>\$userInput{"jacs"},
              "d=s"=>\$userInput{"logDir"},
              "f=s"=>\$userInput{"caseFile"},
              "v=s"=>\$userInput{"expectValue"},
              "l=s"=>\$userInput{"logFile"},
            );


# If "help", print the help information
if ( $userInput{help} )
{
    print $usage;
    exit 0;
}

# check if there is expect jacs file in local;
my $Jfile = $userInput{"jacs"};
if ( !( $Jfile =~ m/$NOFUNCTION/ )) {
    if (!( -e $Jfile) ) {
    printf ("ERROR: jacs file $Jfile could not be found\n");
    exit 1;
    }
}

# check if there is expect case file in local;
my $Cfile = $userInput{"caseFile"};
if ( !( $Cfile =~ m/$NOFUNCTION/ )) {
    if (!( -e $Cfile) ) {
    printf ("ERROR: case file $Cfile could not be found\n");
    exit 1;
    }
}

# execute operation of jacs soap;
printf "Jacs file is :$Jfile\n";
printf "Case file is :$Cfile\n";

#-------------------------------------------------
#   This routine is used to parse the case parameter
#   and return the parameter of this node
#-------------------------------------------------
sub parseCase {
    my $buf;
    my $flag=0;
    my $root=0;
    my $msg;
    my $node="NONE";
    my $setValue="NONE";
    my $iCount;
    my @scriptFile;
    my $getAddress="192.168.10.76";
    my $getConnection;
    my @get_address;
    my $getParamCmd;
    my @get_param_cmd;
    my $setParamCmd;
    my @set_param_cmd;
    my $setParam;
    my @set_param;
    my $setNotification;

    # Open case file;
    $buf = open (FILE,$userInput{"caseFile"});
    if ($buf != 1) {
    print "\n Could not open case file, please check it again.\n";
    exit 1;
    }

    # Get file to array.
    @scriptFile = <FILE>;

    for ($iCount=0; $iCount <= $#scriptFile; $iCount ++) {

    # Get info of connection.
    if ($scriptFile[$iCount] =~ /http/) {
        # Print "Get the ipaddress of DUT...\n";
        $getConnection = $scriptFile[$iCount];

        @get_address = (split /\//, $getConnection);
       # if ($#get_address != 3) {
       #    print "The setting of connection is not correctly, please check it again.\n";
       #    exit 1;
       # } else {
        my $getAddressList = $get_address[2];
        my @get_address_list = (split /:/, $getAddressList);
        $getAddress = $get_address_list[0];
       # }
    }
    # Get the info of getting.
    if ($scriptFile[$iCount] =~ /get_params/) {
        $flag = 0;
        print "\n------------------\nThe case is GPV.\n------------------\n";
        # Get the setting of parameters.
        $getParamCmd = $scriptFile[$iCount];
        # Split the getting parameter line.
        @get_param_cmd = (split / /, $getParamCmd);
        if ($#get_param_cmd != 1) {
        print "The command of GPV is not correctly, please check it again;\n";
        exit 1;
        } else {
        # Get the node;
        $node = $get_param_cmd[1];
           if ($node =~ /\.$/) {
            $root = 1;
           }
        chomp($node);
        }
    }
    # Get the info of setting value.
    if ($scriptFile[$iCount] =~ /set_params/) {
        $flag = 1;
        print "\n------------------\nThe case is SPV.\n------------------\n";
        # Get the setting of parameters.
        $setParamCmd = $scriptFile[$iCount];
        # Split the getting parameter line.
        @set_param_cmd = (split / /, $setParamCmd);

        if ($#set_param_cmd == 0) {
            print "The command of SPV is not correctly, please check it again;\n";
        exit 1;
        } else {
        $setParam = $set_param_cmd[1];
        @set_param = (split /=/,$setParam);
        if ($#set_param != 1) {
            print "The setting of node parameter is not correctly, please check it again;\n";
            exit 1;
        } else {
            $node = $set_param[0];
            $setValue = $set_param[1];
            chomp($node);
            chomp($setValue);
        }
        }
    }
        # Get the info of getting attribute.
        if ($scriptFile[$iCount] =~ /get_attribs/) {
              $flag = 2;
              print "\n------------------\nThe case is GPA.\n------------------\n";
              # Get the setting of parameters.
              $getParamCmd = $scriptFile[$iCount];
              # Split the getting parameter line.
              @get_param_cmd = (split / /, $getParamCmd);
              if ($#get_param_cmd != 1) {
                   print "The command of GPA is not correctly, please check it again;\n";
                   exit 1;
              } else {
                   # Get the node;
                   $node = $get_param_cmd[1];
           if ($node =~ /\.$/) {
            $root = 1;
           }
                   chomp($node);
              }
        }
    # Get the info of setting attribute.
    if ($scriptFile[$iCount] =~ /set_attribs/) {
        $flag = 3;
        print "\n------------------\nThe case is SPA.\n------------------\n";
        # Get the setting of parameters.
        $setParamCmd = $scriptFile[$iCount];
        # Split the getting parameter line.
        @set_param_cmd = (split / /, $setParamCmd);

        if ($#set_param_cmd != 5) {
            print "The command of SPA is not correctly, please check it again;\n";
        exit 1;
        } else {
            $node = $set_param_cmd[1];
            $setNotification = $set_param_cmd[2];
            $setValue = $set_param_cmd[5];
            chomp($node);
            chomp($setNotification);
            chomp($setValue);

        }
    }
    # Get rpc parameters.
    if ($scriptFile[$iCount] =~ /rpc /) {
        $flag = 4;
        print "\n------------------\nThe case is RPC.\n------------------\n";
        $setParamCmd = $scriptFile[$iCount];
        @set_param_cmd = (split / /, $setParamCmd);
        $node = $set_param_cmd[1];
        chomp($node);
    }
    }
    return ($flag,$getAddress,$node,$setValue,$root);
}

#-------------------------------------------------
#   This routine is used to execute test case
#       and return the result.
#-------------------------------------------------
sub executeTest {

    my $result;
    my $msg;
    my $count=0;
    my @jj;
    my $last;
    my $value="NONE";
    my $totalLine;
    my $getValue="NONE";
    my @get_value;
    my ($flag,$node,$root) = @_;

    # Execute the command of jack.
    logMsg("info","Starting to run case ....\n");
    $rc = `$Jfile $Cfile`;
    # Get result;
    @jj = split("\n",$rc);
    $totalLine = $#jj;
    # print "Total log line is :$totalLine\n";

    for (my $i=0; $i <= $totalLine; $i ++) {

    # Get fault info
    if ($jj[$i] =~ /<soap:Fault>/) {
        # Print fault infomation.
        logMsg("title","GETTING JACKS LOG OF RESPONSE");
        for (my $j=0;$j <= 10;$j ++){
        print "$jj[$i+$j]\n";
        print MAINLOG "$jj[$i+$j]\n";
        }
        $msg = "Can NOT get value by '$node'.";
        $count = $count+0;
        }

    # Get GPV response info.
    if ($jj[$i] =~ /<cwmp:GetParameterValuesResponse>/) {
        # Print informaton of execution;
        logMsg("title","GETTING JACKS LOG OF RESPONSE");
        my $rest = $totalLine - $i;
        print "root is :$root\n";
        if ($root == 1) {
                for (my $x=0;$x <= $rest;$x ++) {
            if ($jj[$i+$x] =~ /<\/cwmp:GetParameterValuesResponse>/) {
                $last=$x;
            }
            }
            for (my $j=0;$j <= $last; $j ++) {
            print "$jj[$i+$j]\n";
            print MAINLOG "$jj[$i+$j]\n";
            }
            $count = $count+1;
            $msg = "The getting node '$node' is root.\n The value is as log.\n  "
        } else {
            for (my $j=0;$j <= 7; $j ++) {
            print "$jj[$i+$j]\n";
            print MAINLOG "$jj[$i+$j]\n";
            }
            $count = $count+1;
            $getValue = $jj[$i+4];
            $get_value[2] = "NONE";
            @get_value = (split /<|>/, $getValue);
            # check if get value.
            $getValue = $get_value[2];
            $msg = " The getting node is: $node\n  The getting value is: $getValue\n";
        }

        }

    # Get GPA response info.
    if ($jj[$i] =~ /<cwmp:GetParameterAttributesResponse>/) {
        # Print informaton of execution;
        logMsg("title","GETTING JACKS LOG OF RESPONSE");
        for (my $j=0;$j <= 10;$j ++){
        print "$jj[$i+$j]\n";
        print MAINLOG "$jj[$i+$j]\n";
        }
        $count = $count+1;
        $getValue = $jj[$i+4];
        # print $getValue;
        $get_value[2] = "NONE";
        @get_value = (split /<|>/, $getValue);
        # get value.
        $getValue = $get_value[2];
        $msg = "The getting node is: $node\n  The getting 'Notification' is: $getValue\n";
        }

    # Get SPV response.
    if ($jj[$i] =~ /<cwmp:SetParameterValuesResponse>/) {
        # Print informaton of execution;
        logMsg("title","GETTING JACKS LOG OF RESPONSE");
        for (my $j=0;$j <= 2;$j ++){
        print "$jj[$i+$j]\n";
        print MAINLOG "$jj[$i+$j]\n";
        }
        $count = $count+1;
        $getValue = $jj[$i+1];
        @get_value = (split /<|>/, $getValue);
        $getValue = $get_value[2];
        if ($getValue == 0) {
        $msg = "The setting node is: $node\n  The setting status is: $getValue\n";
        } elsif ($getValue == 1) {
            $msg = "WARN: The setting node is: $node\n The setting status is: $getValue \n-| SPV need to reboot DUT to take effect. "
        }
        else {
            $msg = "WARN: The setting node is: $node\n  The setting status is: $getValue\n";
        }
        }

    # Get SPA response info.
    if ($jj[$i] =~ /<cwmp:SetParameterAttributesResponse\/>/) {
        # Print informaton of execution;
        logMsg("title","GETTING JACKS LOG OF RESPONSE");
        print "$jj[$i]\n";
        print MAINLOG "$jj[$i]\n";
        $count = $count+1;
        $getValue = $jj[$i];
        $msg = "The setting node is: $node\n  The setting status is: $getValue\n";
        }

    # Get RPC response info.
    if ($jj[$i] =~ /<cwmp:GetRPCMethodsResponse>/) {
        # Print informaton of execution;
        logMsg("title","GETTING JACKS LOG OF RESPONSE");
        for (my $j=0;$j <= 17;$j ++){
        print "$jj[$i+$j]\n";
        print MAINLOG "$jj[$i+$j]\n";
        }
        $count = $count+1;
        $msg = "The RPC add node is: $node\n";
        }
    # Get RPC response of AddObject.
    if ($jj[$i] =~ /<cwmp:AddObjectResponse>/) {
        # Print informaton of execution;
        logMsg("title","GETTING JACKS LOG OF RESPONSE");
        for (my $j=0;$j <= 3;$j ++){
        print "$jj[$i+$j]\n";
        print MAINLOG "$jj[$i+$j]\n";
        }
        $count = $count+1;
        $msg = "The RPC node is: $node\n";
        }
    # Get RPC response of DeleteObject.
    if ($jj[$i] =~ /<cwmp:DeleteObjectResponse>/) {
        # Print informaton of execution;
        logMsg("title","GETTING JACKS LOG OF RESPONSE");
        for (my $j=0;$j <= 3;$j ++){
        print "$jj[$i+$j]\n";
        print MAINLOG "$jj[$i+$j]\n";
        }
        $count = $count+1;
        $msg = "The RPC node is: $node\n";
        }

    # Get RPC response of Reboot.
    if ($jj[$i] =~ /<cwmp:RebootResponse\/>/) {
        # Print information of jacs.
        logMsg("title","GETTING JACKS LOG OF RESPONSE");
        print "$jj[$i]\n";
        print MAINLOG "$jj[$i]\n";
        $count = $count+1;
        $getValue = $jj[$i];
        $msg = "The RPC node is: $node.\n Response :$getValue\n";
    }
    # Get RPC response of FactoryReset.
    if ($jj[$i] =~ /<cwmp:FactoryResetResponse\/>/) {
        # Print information of jacs.
        logMsg("title","GETTING JACKS LOG OF RESPONSE");
        print "$jj[$i]\n";
        print MAINLOG "$jj[$i]\n";
        $count = $count+1;
        $getValue = $jj[$i];
        $msg = "The RPC node is: $node.\n Response :$getValue\n";
    }
    # Get RPC response of DownloadResponse.
    if ($jj[$i] =~ /<cwmp:DownloadResponse>/) {
        # Print information of jacs.
        logMsg("title","GETTING JACKS LOG OF RESPONSE");
        for (my $j=0;$j <= 4;$j ++){
        print "$jj[$i+$j]\n";
        print MAINLOG "$jj[$i+$j]\n";
        }
        $count = $count+1;
        $getValue = $jj[$i];
        $msg = "The RPC node is: $node.\n Response :$getValue\n";
    }
    # Get RPC response of UploadResponse.
    if ($jj[$i] =~ /<cwmp:UploadResponse>/) {
        # Print information of jacs.
        logMsg("title","GETTING JACKS LOG OF RESPONSE");
        for (my $j=0;$j <= 3;$j ++){
        print "$jj[$i+$j]\n";
        print MAINLOG "$jj[$i+$j]\n";
        }
        $count = $count+1;
        $getValue = $jj[$i];
        $msg = "The RPC node is: $node.\n Response :$getValue\n";
    }

    }
    #print "Flag is : $flag;\n";
    for ($flag) {
    /0/ && do {
        logMsg("info","--------Execute GPV------------");
        logMsg("info","$msg");
        if ($count == 0) {
        logMsg("warn","It's Fail to execute GPV.");
        $result = 0;
        } else {
        logMsg("info","It's Successful to execute GPV.");
        $result = 1;
        }
        last;
    };
    /1/ && do {
        logMsg("info","Execute SPV :\n$msg");
        if ($count == 0) {
        logMsg("warn","It's Fail to execute SPV.");
        $result = 0;
        } else {
        logMsg("info","It's Successful to execute SPV.");
        $result = 1;
        }
        last;
    };
    /2/ && do {
        logMsg("info","Execute GPA :\n$msg");
        if ($count == 0) {
        logMsg("warn","It's Fail to execute GPA.");
        $result = 0;
        } else {
        logMsg("info","It's Successful to execute GPA.");
        $result = 1;
        }
        last;
    };
    /3/ && do {
        logMsg("info","Execute SPA :\n$msg");
        if ($count == 0) {
        logMsg("warn","It's Fail to execute SPA.");
        $result = 0;
        } else {
        logMsg("info","It's Successful to execute SPA.");
        $result = 1;
        }
        last;
    };
    /4/ && do {
        logMsg("info","Execute RPC :\n$msg");
        if ($count == 0) {
        logMsg("info","It's Fail to execute RPC.");
        $result = 0;
        } else {
        logMsg("info","It's Successful to execute RPC.");
        $result = 1;
        }
        last;
    };
    die "Error: unrecognize error code $flag \n";
    }
    return ($rc,$result,$node,$getValue);
}
#-----------------------------------------------------------
# This routine is used to display the log file of running.
#
#-----------------------------------------------------------
sub logMsg {
    my ($level,$msg) = @_;
    for ($level) {
    /title/ && do {
        print "\n-|----------------------------------------------";
        print "\n-|           $msg";
        print "\n-|----------------------------------------------\n";
        print MAINLOG "\n-|----------------------------------------------";
        print MAINLOG "\n-|           $msg";
        print MAINLOG "\n-|----------------------------------------------\n";
        last;
    };
    /info/ && do {
        print "\n-| INFO: $msg\n";
        print MAINLOG "\n-| INFO: $msg\n";
        last;
    };
    /warn/ && do {
        print "\n-| WARN: $msg\n";
        print MAINLOG "\n-| WARN: $msg\n";
        last;
    };
    /error/ && do {
        print "\n-| ERROR: $msg\n";
        print MAINLOG "\n-| ERROR: $msg\n";
        last;
    };
    /result/ && do {
        print "\n-|----------------------RESULT-----------------";
        print "\n-| END TEST -- $msg";
        print "\n-|---------------------------------------------\n";
        print MAINLOG "\n-|------------------RESULT---------------------";
        print MAINLOG "\n-| END TEST -- $msg";
        print MAINLOG "\n-|---------------------------------------------\n";
        last;
    };
    die "ERROR: unknow level for message.";
    }

}

#-----------------------------------------------------------
# This routine is used to check the connection
#                     of DUT with Jack server.
#-----------------------------------------------------------
sub verifyTarget {
    my ($getAddress) = @_;
    my $FAIL;
    my $PASS;
    my $rc=0;
    my @jj;

    logMsg("info","check the connection with DUT.");
    my $cmd = `ping -c 5 -w 10 192.168.55.254`;
    $cmd =~ s/\%/perc/;
    printf "\n $cmd \n";
    my $msg = "$getAddress is reachable";
    @jj = split ("\n", $cmd);
    my $limit = $#jj;
    #print "total line is :$limit\n";
    my $found = 0;
    my $match = "packet loss";
    foreach (my $i = 0; $i <= $limit; $i ++) {
    if ( $jj[$i] =~ /$match/i ) {
        $found =0;
        if ( $jj[$i] !~ /100perc/i ) {
        $found = 2;
        last;
        }
        $msg = " Error: $getAddress is not reachable =>".$jj[$i];
        last;

    }
    }
    for ($found) {
          /0/ && do {
        $rc = 1;
        $msg = "Error:$getAddress is not reachable";
        last;
      };
      /1/ && do {
        $rc = 1;
        last;
          };
          /2/ && do {
        $rc = 0;
        last;
      };
    die "verifyTarget: unrecognize error code $found \n";
    }
    return ($rc,$cmd);
}

#-------------------------------------------------
#   Main.
#-------------------------------------------------
    my $loggerFile="main.log";
    my $parse;
    my $node;
    my $flag;
    my $result;
    my $setValue;
    my $getValue;
    my $value;
    my $msg;
    my $cmd;
    my $root;
    my $getAddress;

    #---------------------------------
    # parse case and get the info of case;
    #---------------------------------
    ($flag,$getAddress,$node,$setValue,$root) = parseCase();
    print "-| The parse node is :$node\n";
    print "-| The parse value is:$setValue\n";
    print "-| The parse address is :$getAddress\n";

    #---------------------------------
    # set gpv log;
    #---------------------------------
    # Set up log directory;
    my $caseLog = $userInput{"logDir"}."/".$node."\.log";
    #print "GPV log file is :$caseLog\n";
    my $caseLogFlag = open (CASELOG,">".$caseLog);
    if ($caseLogFlag != 1) {
    print "\n Could not open write the file";
    exit 1;
    }
    #---------------------------------
    # set main log
    #---------------------------------
    $loggerFile = $userInput{"logDir"}."/".$userInput{"logFile"};
    #print "Main log file :$loggerFile\n";

    my $mainLogFlag = open (MAINLOG,">".$loggerFile);
    if ($mainLogFlag != 1) {
    print "\n Could not open write the file\n";
    exit 1;
    }

    #---------------------------------
    # Verify the connection of DUT;
    #---------------------------------
    ($rc,$cmd) = verifyTarget($getAddress);
    if ($rc != 0) {
    logMsg("error","Can NOT connect to DUT.\n");
    exit 1;
    } else {
    print MAINLOG "\n $cmd \n";
    logMsg("info","It's okay to connect to DUT.\n");
    }

    #---------------------------------
    # Running case;
    #---------------------------------

    for ($flag) {
    /0/ && do {
        # execute GPV case.
        ($rc,$result,$node,$getValue) = executeTest($flag,$node,$root);
        print CASELOG $rc;
        if ($root == 1) {
        if ($result == 1) {
            logMsg("result","PASS: It's successful to GPV correct value.");
        } else {
            logMsg("result","FAIL: Can NOT GPV the correct value.");
        }
        } else {
        if ($getValue eq $userInput{"expectValue"} && $result == 1) {
            logMsg("result","PASS: It's successful to GPV correct value.");
        } else {
            logMsg("result","FAIL: Can NOT GPV the correct value.");
        }
        }
        last;
    };
    /1/ && do {
        # Execute SPV case;
        ($rc,$result,$node,$getValue) = executeTest($flag,$node,$root);
        print CASELOG $rc;
        if ($result == 1) {
        logMsg("result","PASS: It's successful to SPV.");
        } else {
        logMsg("result","FAIL: It's fail to SPV.");
        }
        last;
    };
    /2/ && do {
        # Execute GPA case;
        ($rc,$result,$node,$getValue) = executeTest($flag,$node,$root);
        print CASELOG $rc;
        if ($getValue eq $userInput{"expectValue"} && $result == 1) {
        logMsg("result","PASS: It's successful to GPA correct value.");
        } else {
        logMsg("result","FAIL: Can NOT GPA the correct value.");
        }
        last;
    };
    /3/ && do {
        # execute SPA case.
        ($rc,$result,$node,$getValue) = executeTest($flag,$node,$root);
        print CASELOG $rc;

        if ($result == 1) {
        logMsg("result","PASS: It's successful to SPA correct value.");
        } else {
        logMsg("result","FAIL: Can NOT SPA the correct value.");
        }
        last;
    };
    /4/ && do {
        # Execute RPC case;
        ($rc,$result,$node,$getValue) = executeTest($flag,$node,$root);
        print CASELOG $rc;
        if ($result == 1) {
        logMsg("result","PASS: It's successful to RPC.");
        } else {
        logMsg("result","FAIL: It's fail to RPC.");
        }
        last;
    };
    die "There are no SPV or GPV parameters in case file, please check case file again.\n";

    }

    sleep 2;
    close(MAINLOG);
    close(CASELOG);


