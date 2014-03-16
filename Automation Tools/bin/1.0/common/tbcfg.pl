#!/usr/bin/perl -w
#--------------------------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to configure testbed , switch
# and remote power 
# 
#Things todo:
# Configure the Dell Switch 
#
#--------------------------------------------------

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
my $learnFn =0;
my $NO_FILE= "Not_specified";
my $NOT_DEF= "not_defined";
my $ON=1;
my $OFF=0;
my $PASS=1;
my $FAIL=0;
my $CLI_TMO=1;
my $CLI_PROMPT= 2;
my $CLI_ILLEGAL=3;
my $EXP_DELIMITER ="@";
my $SETUP_IF_TMO = 10 * 60; # 5 minutes
my $CMD_TMO= 60;
my $verbose = 0;
my $NOFUNCTION="no function";
my @junk = split( /\//, $0);
@junk = split('\.',$junk[$#junk]);
my $scriptFn = $junk[0];
my $SETUP_ALL="all";
my $SETUP_SWITCH="switch";
my $SETUP_HOST="host";
my $SETUP_RMPW="rmpw";
my $PC8000="pc8000";
my $DELL_5324="dell5324";
my $CSCO_3560="cisco3560";
my $MANTYPE="management";
my $TESTTYPE="test";
my $BOOT_DHCP="dhcp";
my $BOOT_STATIC="static";
my $INTF_DOWN="down";
my $TELPORT=22;
my $DUMMY="dummy";


my %userInput = (
    "user" => "root",
    "password" => "gomain03",
    "debug" => "0",
    "logdir"=>"./",
    "filename"=> $NO_FILE,
    "scriptname"=> $scriptFn,
    "screenOff"=> 0,
    "logOff"=> 0,
    "hostman"=> $OFF,
    "cfg"=>$SETUP_HOST,
    "commands"=>[],
    "switchtype"=> { 
	$DELL_5324=>"cfgSwitch_dell5324",
	$CSCO_3560=>"cfgSwitch_cisco3560",
	$DUMMY=>"cfgSwitch_dummy"
    },

    );
my $path = $ENV{'SQAROOT'};
my $binver = $ENV{'G_BINVERSION'};
my $bincmd = $path."/bin/".$binver."/common/clicfg.pl";
if (! (-e $bincmd) ) {
    printf ("Error: $0 depends on the availability of $bincmd\n");
    exit 1;
}
my $RMPS="perl ".$path."/bin/".$binver."/common/UU.pl ";
my $CLICFG = "perl $bincmd -n";

sub parseDeviceSingleEntry {
    my ( $profFile,$devicetype,$subdevice,$index,$devPtr) = @_;
    my $xx;
    my $yy;
    my $kk;
    my $mm;
    my $j;
    my $temp;
    my $limit;
    my $rc=$PASS;
    my $key ;
    my $log = $profFile->{logger};
    my $msg = "Successfully parsing $devicetype  variables ";
#    my $devicetype="rmpower";
    #Import PC hosts variables.
    #$index = $data->{$devicetype}{device}{name};
    #$devicePtr = $data->{$devicetype}{device};
    my %localSwitch = (
	"type"=>"notdefined",
	"alias"=>"notdefined",
	"$subdevice"=>[],
	);
	
    foreach $kk ( keys %{$devPtr } ) {
	if ( $kk =~ /$subdevice/i ) {
	    next;
	}
	if ( $devPtr->{$kk} =~ /HASH/ ) {
	    $localSwitch{$kk}  = $NOFUNCTION;
	} else {
	    $localSwitch{$kk}  = $devPtr->{$kk};
	}
    }
    $j = 0;
    
    if ( !(defined($devPtr->{$subdevice}{name})) ) {
	foreach $kk ( sort keys %{$devPtr->{$subdevice} } ) {
	    if ( !(defined($devPtr->{$subdevice}{$index}{name})) ) {
		foreach $mm ( sort keys %{$devPtr->{$subdevice}{$kk}} ) {
		    if ($devPtr->{$subdevice}{$kk}{$mm} =~ /HASH/ ) {
			$localSwitch{$subdevice}[$j]{$mm} = $NOFUNCTION;
		    } else {
			$localSwitch{$subdevice}[$j]{$mm} = $devPtr->{$subdevice}{$kk}{$mm};
		    }
		}
	    } else {
		$mm  = $devPtr->{$subdevice}{$kk}{name};
		$localSwitch{$subdevice}[$j]{$mm} = $devPtr->{$subdevice}{$kk}{$mm};
	    }
	    $j++;
	}
    }  else {
	$kk = $devPtr->{$subdevice}{name};
	if ( !(defined ($devPtr->{$index}{name}))) {
	    foreach $mm ( sort keys %{$devPtr->{$subdevice}{$kk}} ) {
		if ($devPtr-> {$subdevice}{$kk}{$mm} =~ /HASH/ ) {
		    $localSwitch{$subdevice}[$j]{$mm} = $NOFUNCTION;
		} else {
		    $localSwitch{$subdevice}[$j]{$mm} = $devPtr-> {$subdevice}{$kk}{$mm};
		}
	    }
	} else {
	    $mm  = $devPtr-> {$subdevice} {$kk}{name};
	    $localSwitch{$subdevice}[$j]{$mm} = $devPtr-> {$subdevice}{$kk}{$mm};
	}
    }
    push(@{$profFile->{$devicetype}},\%localSwitch);
    return($PASS,"parseDeviceSingleEntry:Successfully parse deviceType=$devicetype,interface/port=$subdevice,index=$index");
}


#----------------------------------------------------
# This routine is used to parsed all devices from testbed/**.xml
#----------------------------------------------------
sub parseDevice {
    my ( $profFile, $data, $devicetype,$subdevice) = @_;
    my $xx;
    my $yy;
    my $kk;
    my $mm;
    my $j;
    my $temp;
    my $index;
    my $limit;
    my $rc=$PASS;
    my $key ;
    my $log = $profFile->{logger};
    my $devicePtr;
    my $msg = "Successfully parsing $devicetype  variables ";
#    my $devicetype="rmpower";
    #Import PC hosts variables.
    if ( !(defined ($data->{$devicetype}) )) {
	$msg = "***************** WARNING: No $devicetype tag found";
	#intention not to fail this case
	return($PASS,$msg);
    }
    if ( !(defined($data->{$devicetype}{device}{name})) )  {
	foreach $index ( sort keys %{$data->{$devicetype}{device} } ) {
	    $devicePtr = $data->{$devicetype}{device} {$index};
	    ($rc,$msg) = parseDeviceSingleEntry ( $profFile,$devicetype,$subdevice,$index,$devicePtr);
	}
    } else {
	$index = $data->{$devicetype}{device}{name};
	$devicePtr = $data->{$devicetype}{device};
	($rc,$msg) = parseDeviceSingleEntry ( $profFile,$devicetype,$subdevice,$index,$devicePtr);
    }
    
    if ( $profFile->{debug} > 2 ) { 
	$temp= Dumper($profFile->{$devicetype});
	$log->info($temp);

    }
    return($rc,$msg);
}
#-----------------------------------------------------------
# This routine is used to get the base name 
#-----------------------------------------------------------

sub getBaseName {
    my ($path,$junk) = @_;
    my @t1;
    @t1=split("/",$path );
    $junk = $t1[$#t1];
    return ($junk);
}

#-----------------------------------------------------------
# This routine is used to check if target is recheable
#-----------------------------------------------------------
sub verifyTarget {
    my ($profFile,$tsIp) = @_;
    my $log = $profFile->{logger};
    my $rc = 0;
    my @jj;
    my $output = "ping $tsIp -w 5 -c 5";
    $log->info("$output");
    my $cmd=`$output`;
    $cmd =~ s/\%/perc/;
    my $msg = " $tsIp is reachable";
    @jj = split ("\n",$cmd);
    my $limit= $#jj;
    my $found = 0;
    my $match ="packet loss";
    foreach ( my $i=0 ; $i <= $limit; $i++) {
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
	  $rc = 0;
	  $msg = "Error:$tsIp is not reachable";
	  last;
      };
      /1/ && do {
	  $rc = 0;
	  last;
      };
      /2/ && do {
	  $rc = 1;
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
    #--------------------
    # initialize logger
    #---------------------
    my $temp = $profFile->{scriptname};
    my $localLog = $profFile->{logdir}."/$temp.log";
    my $clobberLog = $profFile->{logdir}."/$temp\_clobber.log";
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

#-------------------
# Parsing Xml File 
#-------------------
sub parsingXmlCfgFile {
    my ($profFile) = @_;
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
    if ($profFile->{debug} > 2 ) {
	$temp = Dumper($data) ;
	$log->info( $temp );
    }
    if (defined ($data->{emaildesc})) {
	my $temp = $data->{emaildesc};
	if ( $temp =~ /^\s*$/ ) {
	    $temp = "No tag <id> <manual> " ;
	}
	$log->info("EmailDesc=$temp");
    }
    if (defined ($data->{desc})) {
	my $temp = $data->{desc};
	$log->info( "Description:$temp"); 
    }

    if ( (defined ($data->{id} {manual} ) )) {
	my $temp = $data->{id} {manual} ;
	if ( $temp =~ /^\s*$/ ) {
	    $temp = "No tag <id> <manual> " ;
	}
	printf ( " TAG ID $temp\n");
	$log->info("Manual ID:$temp");
    } 
    ($rc,$msg)= parseDevice($profFile,$data,"host","interface");
    if ( $rc == $FAIL ) {
	$log->info($msg);
    }
    ($rc,$msg)= parseDevice($profFile,$data,"switch","port");
    if ( $rc == $FAIL ) {
	$log->info($msg);
    }
    ($rc,$msg)= parseDevice($profFile,$data,"rmpower","port");
    if ( $rc == $FAIL ) {
	$log->info($msg);
    }
    ($rc,$msg)= parseDevice($profFile,$data,"tsserver","port");
    if ( $rc == $FAIL ) {
	$log->info($msg);
    }

    return ($rc,$msg);
}
#************************************************************
# Configure Switch by using clicfg
#************************************************************
sub setSwitch {
    my ( $profFile,$hostIp,$userId,$pwd,$var,$testlog )= @_;
    my $logdir = $profFile->{logdir};
    my $log = $profFile->{logger};
    my $rc = $PASS ;
    my $tmo = $SETUP_IF_TMO;
    my $msg = "test passed";
    my $cmd = "$CLICFG -l $logdir -d $hostIp -i $TELPORT -u $userId -p $pwd -m '$hostIp.*\[>|#\]' ".$var ; 
    $log->info($cmd);
    
    ($rc,$msg)=launchCmd($profFile,$testlog,$cmd,$tmo,$cmd); 
    if ($rc == $PASS) {
	$msg = "Successful to set up switch $hostIp -- ". $msg;
      
    } else {
	$msg = "Failed to set up switch $hostIp  -- ". $msg;
    }
    return($rc,$msg);
}
#************************************************************
#  Configure Cisco Switch
#************************************************************
sub cfgSwitch_cisco3560 {
    my ( $profFile, $ptr) = @_;
    my $rc = $FAIL;
    my $msg = "failed to set up SWITCH";
    my $log= $profFile->{logger};
    $log->info("Starting Set up Cisco 3560 Switch");
    my $dir  = $profFile->{logdir};
    my $ifType="gigabitethernet";
    my $xx;
    my ($host,$hostIp,$userId,$pwd);
    my $index;
    my $ptrIf;
    my $temp;
    my $j;
    my $limit ;
    my $globalRc = 0;
    #Get port and action
    my $type;
    my $cmd;
    my $msg2 = "";
    my $h11= "configure terminal\n";
    my $h12= "end\n";
    my $cfgFile = getBaseName ( $profFile->{filename} );
    my $file = $profFile->{logdir}."/".$cfgFile;
    my $testlog = $file.".testlog";
    my ( $vlan,$port);
    my @ltemp;
    my $found = 0;
    my ($key,$value);
    my $prodtype = $NOT_DEF;
    $userId = $ptr->{user};
    $pwd = $ptr->{password};
    $host = $ptr->{alias};
    $type= $ptr->{type};
    ($cfgFile,$temp) = split('\.',$cfgFile);
    $cfgFile = $dir."/".$cfgFile."_switch_".$type."\.txt";
    $log->info("Create switch configuration  $cfgFile ");
    my $reset = $NOT_DEF;
    #-----------------
    # Create file 
    #-----------------
    $rc = open (SWITCHFD, ">$cfgFile");
    if ( $rc == 0 ) { 
	$msg = "Config. Swith failed: could not  create $cfgFile";
	return ($FAIL, $msg);
    }  
    #------------------ Process User commands -------------------
    $limit=$#{$profFile->{commands}};
    for ( $j=0;$j<= $limit;$j++) {
	($key,$value)= split("=",$profFile->{commands}[$j]);
	if ( $profFile->{commands}[$j] =~ /PRODTYPE=/i ) {
	    $prodtype = $value;
	    next;
	}
	if ( $profFile->{commands}[$j] =~ /RESET=/i ) {
	    $reset = $value;
	    next;
	}
    }
    #-----------------
    $msg="";
#	$host = $ptr->{desc};
    $log->info ( " TYPE = $type ");
    ($rc,$msg) = verifyTarget($profFile,$host);
    if ( $rc == $FAIL ) {
	$msg .=$msg;
    }
    $log->info("$msg");
    $ptr = \@{$ptr->{port}};
    $xx=$#{$ptr};
    #-------------------------
    #shutdown all ports first 
    #-------------------------
    $port = "";
    $vlan = 2;
    $cmd ="enable\n";
    printf SWITCHFD ($cmd);
    for ( $index = 0 ;$index <=$xx; $index++) {	    
	$ptrIf = \%{$ptr->[$index]};
	$port = $ptrIf->{serviceport};
	# Write to configuration switch file
	$cmd =$h11."interface $ifType ".$port."\nswitchport access vlan ".$vlan."\nshutdown\n".$h12;
	printf SWITCHFD ($cmd);
    }
    #-------------------------------------------------------------
    # Access all ports and enable them if RESET command is not set 
    #-------------------------------------------------------------
    if ( $reset =~ /$NOT_DEF\b/ ) {
	if ( $prodtype =~ /$NOT_DEF/ ) {
	    $msg = "Error:Please enter PRODTYPE - ( actual product type =$prodtype ) ";
	    return($FAIL,$msg);
	}
	for ( $index = 0 ;$index <=$xx; $index++) {	    
	    $ptrIf = \%{$ptr->[$index]};
	    next if ( $ptrIf->{prodtype} !~ /$prodtype\b/i );
	    $vlan = $ptrIf->{vlan};
	    $port = $ptrIf->{serviceport};
	    # Write to configuration switch file
	    $cmd="vlan database\nvlan ".$vlan."\nexit\n";
	    $cmd.=$h11."interface vlan ".$vlan."\nno shutdown\nno spanning-tree vlan ".$vlan."\n";
	    $cmd .="interface $ifType ".$port."\nswitchport access vlan ".$vlan."\nno shutdown\n".$h12;
	    printf SWITCHFD ($cmd);
	}
    }

    $cmd="show vlan\n";
    printf SWITCHFD ($cmd);
    close SWITCHFD;	

    $log->info("Starting Set up SWITCH ($host) user=$userId,pwd=$pwd ");	
    $cfgFile = "-f ".$cfgFile;
    ($rc,$msg2) = setSwitch($profFile,$host,$userId,$pwd,$cfgFile,$testlog);	
    $msg .= $msg2;




    return($rc,$msg);
}



#************************************************************
#  Configure Dummy witch
#************************************************************
sub cfgSwitch_dummy{
    my ( $profFile, $ptr) = @_;
    my $rc = $PASS;
    my $msg = "Switch Dummy is not processed\n"; 
    my $log= $profFile->{logger};
    $log->info($msg);
    return ( $rc,$msg);
}
#************************************************************
#  Configure Dell Switch
#************************************************************
sub cfgSwitch_dell5324 {
    my ( $profFile, $ptr) = @_;
    my $rc = $FAIL;
    my $msg = "failed to set up SWITCH";
    my $log= $profFile->{logger};
    $log->info("Starting Set up Dell 5324 Switch ");
    my $dir  = $profFile->{logdir};
    my $xx;
    my ($host,$hostIp,$userId,$pwd);
    my $index;
    my $ptrIf;
    my $temp;
    my $j;
    my $limit ;
    my $globalRc = 0;
    #Get port and action
    my $type;
    my $cmd;
    my $msg2 = "";
    my $h11= "config\n";
    my $h12= "end\n";
    my $cfgFile = getBaseName ( $profFile->{filename} );
    my $file = $profFile->{logdir}."/".$cfgFile;
    my $testlog = $file.".testlog";
    my ( $vlan,$port);
    my @ltemp;
    my $found = 0;
    my ($key,$value);
    my $prodtype = $NOT_DEF;
    $userId = $ptr->{user};
    $pwd = $ptr->{password};
    $host = $ptr->{alias};
    $type= $ptr->{type};
    ($cfgFile,$temp) = split('\.',$cfgFile);
    $cfgFile = $dir."/".$cfgFile."_switch_".$type."\.txt";
    $log->info("Create switch configuration  $cfgFile ");
    my $reset = $NOT_DEF;
    #-----------------
    # Create file 
    #-----------------
    $rc = open (SWITCHFD, ">$cfgFile");
    if ( $rc == 0 ) { 
	$msg = "Config. Swith failed: could not  create $cfgFile";
	return ($FAIL, $msg);
    }  
    #------------------
    $limit=$#{$profFile->{commands}};
    for ( $j=0;$j<= $limit;$j++) {
	($key,$value)= split("=",$profFile->{commands}[$j]);
	if ( $profFile->{commands}[$j] =~ /PRODTYPE=/i ) {
	    $prodtype = $value;
	    next;
	}
	if ( $profFile->{commands}[$j] =~ /RESET=/i ) {
	    $reset = $value;
	    next;
	}
    }
    #-----------------
    $msg="";
#	$host = $ptr->{desc};
    $log->info ( " TYPE = $type ");
    ($rc,$msg) = verifyTarget($profFile,$host);
    if ( $rc == $FAIL ) {
	$msg .=$msg;
    }
    $log->info("$msg");
    $ptr = \@{$ptr->{port}};
    $xx=$#{$ptr};
    #shutdown all ports first 
    $port = "";
    $vlan = 2;
    $cmd ="enable\n";
    printf SWITCHFD ($cmd);
    for ( $index = 0 ;$index <=$xx; $index++) {	    
	$ptrIf = \%{$ptr->[$index]};
	$port = $ptrIf->{serviceport};
	# Write to configuration switch file
	$cmd =$h11."interface ethernet ".$port."\nswitchport access vlan ".$vlan."\nshutdown\n".$h12;
	printf SWITCHFD ($cmd);
    }
    if ( $reset =~ /$NOT_DEF\b/ ) {
	if ( $prodtype =~ /$NOT_DEF/ ) {
	    $msg = "Error:Please enter PRODTYPE - ( actual product type =$prodtype ) ";
	    return($FAIL,$msg);
	}
	for ( $index = 0 ;$index <=$xx; $index++) {	    
	    $ptrIf = \%{$ptr->[$index]};
	    next if ( $ptrIf->{prodtype} !~ /$prodtype\b/i );
	    $vlan = $ptrIf->{vlan};
	    $port = $ptrIf->{serviceport};
	    # Write to configuration switch file
	    $cmd=$h11."vlan database\nvlan ".$vlan."\n".$h12;
	    $cmd .=$h11."interface ethernet ".$port."\nswitchport access vlan ".$vlan."\nno shutdown\n".$h12;
	    printf SWITCHFD ($cmd);
	}
    }
    $cmd="show vlan\n";
    printf SWITCHFD ($cmd);
    close SWITCHFD;	

    $log->info("Starting Set up SWITCH ($host) user=$userId,pwd=$pwd ");	
    $cfgFile = "-f ".$cfgFile;
    ($rc,$msg2) = setSwitch($profFile,$host,$userId,$pwd,$cfgFile,$testlog);	
    $msg .= $msg2;
    return($rc,$msg);
}
#************************************************************
# Configure SWITCH
#************************************************************
sub cfgSwitch {
    my ( $profFile, $junk) = @_;
    my $rc = $FAIL;
    my $msg = "failed to set up SWITCH";
    my $log= $profFile->{logger};

    my $dir  = $profFile->{logdir};
    my $ptr;
    my $j;
    my $type;
    my $globalRc = $PASS ;
    my $limit ;
    my $msg2 = "";
    #Get port and action
    $limit = $#{$profFile->{switch}};
    $log->info("Starting Set up Switches -- number of Switch=$limit");
    $msg = "";
    for ( $j=0;$j<= $limit;$j++) {

	$ptr =$profFile->{switch}[$j];
	$rc= $FAIL;
	$msg2 ="";
	$type= $ptr->{type};
	$log->info("Starting Set up Switche Type($j)=$type");
=begin
	for ($type) {
	    /$DELL_5324/ && do {
		($rc,$msg2) =cfgSwitch_dell5324 ($profFile,$ptr);
		if ( $rc == $FAIL ) {
		    $globalRc = $FAIL;
		}
		last;
	    };
	    /$DUMMY/i && do {
		# don't do anything
		$msg2 = "Switch $type is not processed\n"; 
		$log->info($msg2);
		last;
	    };
	    $globalRc = $FAIL;
	    $msg2 = " Switch $type is not supported \n";
	    $log->info($msg2);
	    last;
	}
=end
=cut
	if ( not defined ($profFile->{switchtype}{$type} )) {
	    $globalRc = $FAIL;
	    $msg2 = " Switch $type is not supported \n";
	    $log->info($msg2);
	} else {
	    no strict;
	    ($rc,$msg2) =  $profFile->{switchtype}{$type} ($profFile,$ptr);
	    use strict;
	    if ( $rc == $FAIL ) {
		$globalRc = $FAIL;
	    }
	}
	$msg .= $msg2;
    }
    
    return($globalRc,$msg);
}
#************************************************************
# This routine is used to increase the ipaddress/netmask
# or ipaddress alone 
#************************************************************
sub ipIncr {
    my ($profFile,$ipOrg, $incr)=@_;
    my $log = $profFile->{logger};
    my ($ip,$mask)=split('/',$ipOrg);
    my @add = split('\.',$ip);
    my $temp = @add;
    my $mod = 0;
    my $nextCount =0;
    my $i;
    if ( defined $mask ) {
	$log->info(" Increment $ip -- mask= $mask -- IP fields=$temp") if ($profFile->{debug} > 3 ) ;
    } else {
	$log->info(" Increment $ip -- NO mask -- IP fields=$temp ") if ($profFile->{debug} > 3 ) ;
    }
    if ( $temp != 4) { return $ipOrg ;}
#    $log->info("Start IP(3) = $add[3]");
    $add[3] +=$incr;
    for ( $i = 3 ; $i >= 0; $i-- ) {
#	$log->info("IP($i) = $add[$i]");
	$add[$i] += $nextCount;
	if ( $add[$i] > 254) {
	    $nextCount = 1;
	    $add[$i] = $add[$i] % 255;
	} else {
	    $nextCount = 0;
	}
#	$log->info("MOD IP($i) = $add[$i]");
	if (($add[$i] == 0 ) && ($i == 3 )) {
	    $add[$i]++;
	}
    }
    $ip = join('.',@add);
    if ( defined $mask ) { 
	$ip = join('/',$ip,$mask);
    }
    return($ip);
}
#************************************************************
# This routine is used to convert the number of bit to 
# hex netmask
#************************************************************
sub netmask {
    my $maskNum = shift;
    my $count;
    my $mask = 0;
    my $limit = 31;
    for ( $count=0; $count <$maskNum; $count++) {
	$mask = ($mask | 0x1 ) << 1;	
    }
    $limit=$limit - $maskNum;
    for ( $count=0; $count < $limit; $count++) {
	$mask = $mask << 1;
    }
    return($mask);
}
#************************************************************
# This routine is used to find the subnet with a given ip and its mask 
#************************************************************
sub subnet {
    my ($ip,$mask)=@_;
    my $localIp;
    my @addr=split('\.',$ip);
    my $temp = ($addr[0]<<24) | ($addr[1]<<16) | ($addr[2]<<8) | $addr[3];
    $temp = $temp & $mask;
    $addr[0]=$temp >> 24 & 0xff ;
    $addr[1]=$temp >> 16 & 0xff ;
    $addr[2]=$temp >> 8 & 0xff;
    $addr[3]=$temp & 0xff ;
    $localIp = join(".",@addr);
    return $localIp;
}
#************************************************************
# This routine is used to find the subnet with a given ip and its mask 
#************************************************************
sub subnetConvert {
    my ($profFile,$ip,$mask)=@_;
    my $log = $profFile->{logger};
    my $msg;
    $log->info ("subnetConvert Param:ip=$ip and mask=$mask");
    my @addr=split('\/',$ip);
    if ( defined $addr[1]) {
	$mask = $addr[1];
    }
    my $bitmask= netmask($mask);
    my $subnet = subnet($addr[0],$bitmask);
    $msg = sprintf (" Subnet %s and bit mask in hex 0x%x\n",$subnet,$bitmask);
    $log->info ($msg);
    $subnet = $subnet."\/".$mask;
    return $subnet;
}


#-------------------------------------------------------
# Set up Child Process
#--------------------------------------------------------
sub launchCmd {
    my ($profFile,$testLog,$cmd,$tmo,$strTest) = @_;
    my $rc = $PASS;
    my $log = $profFile->{logger};
    my $retry = 1;
    my $localRetry =1;
    my $wait = 5;
    my $temp = 0;
    my @buff;
    my $msg;
    my $exp=Expect->spawn($cmd);
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
		 [ eof => sub { printf "EOF \n"; $rc = 1} ],		 
	);
    $rc = $exp->exitstatus();
    $exp->log_file();    
    $exp->soft_close();    
    # start to check the error
    $temp = `grep $strTest $testLog | wc `;
    @buff = split(' ',$temp);
    $log->info ("BUFF = $buff[0], $buff[1], $buff[2] \n");
    if ( $buff[0] == 0) {
	$rc = $PASS;
	$msg = "Successful to execute $cmd "; 
    } else {
	$rc = $FAIL;
	$temp = `grep $strTest $testLog `;
	$msg = "Failed to execute $cmd --- $temp "; 
    }
    return ($rc,$msg);
}
#--------------------------------------------------------
#  'ip' => {},
#  'range' => {},
#  'netstatic' => '19.11.11.0/24;18.12.12.0/24',
#  'eth' => 'eth2',
#  'hoststatic' => '19.11.10.1;18.13.13.1',
#  'boottype' => 'dhcp',
#  'desc' => 'main management port ',
#  'type' => 'management'

#    clicfg.pl [-help|-h] [-man] [-f CLI TEXT FILE] [-d terminal server IP]
#    [-i terminal server IP port] [-n [do not wait after processing each
#    command] [-u USERNAME ] [-p PASSWORD ] [-o timeout per for Expect ] [-l
#    log file path] [-s tty port either 0 or 1 or..] [-t Create a CLI
#    template file] [-v cli command [-v cli command] ...]

#    for ( $yy=0;$yy<=$xx;$yy++) {

#--------------------------------------------------------

sub setupInterface{
    my $rc = $FAIL;
    my $msg = "failed to set up HOST";
    my ( $profFile, $ptrIf,$host,$hostIp,$userId,$pwd) = @_;
    my $log= $profFile->{logger};
    my @tempArray;
    my $temp;
    my ($var,$cmd);
    my ($t1,$t2,$t3);
    my ($yy,$mm,$key);
    my ($iface,$gw);
    my $range;
    my $index;
    my $ip;
    my $logdir = $profFile->{logdir};
    my $tmo = $SETUP_IF_TMO;
    my $cmdTmo = $CMD_TMO;
    $t3 = $ptrIf->{eth};
    my $strTest = "-e \"SIOCSIFADDR: No such device\" -e \"SIOCADDRT: Network is unreachable\" ";
#    my $file = $profFile->{logdir}."/".$profFile->{scriptname}."_host_".$host."_$t3"."_$hostIp";
    my $file = $profFile->{logdir}."/".$profFile->{scriptname}."_host_".$t3."_$hostIp";
    my $testlog = $file.".testlog";
    $file = $file.".txt";
    $t1 = $ptrIf->{type};
    $t2 = $ptrIf->{desc};
    $log->info("Set up Interface(e.g $t2) of type $t1");
    $t1 = $ptrIf->{boottype};
    for ($t1) {
	
	/$BOOT_DHCP/ && do {
	    #create a file 
	    $log->info("Set up Interface with DHCP -- log saved to $file");
	    open(FD,">$file") or die " could not create $file" ;
	    $t3 = $ptrIf->{eth}; 
	    printf FD "dhclient -r $t3\n";
	    printf FD "killall dhclient\n";
	    printf FD "dhclient $t3\n";
	    #create IP range
	    if (( defined $ptrIf->{ip}) && ($ptrIf->{ip} !~ /^\s$/)) {
		$range = 0;
		if (( defined $ptrIf->{range}) && ($ptrIf->{range} !~ /$NOFUNCTION/))  {
		    $range = $ptrIf->{range};
		}
		$ip = $ptrIf->{ip};
		for ( $index =1 ; $index <= $range ; $index ++) {
		    $t2 = $t3.":$index";
		    printf FD ("ifconfig $t2 $ip \n");
		    $ip = ipIncr($profFile,$ip,1);
		}
	    }
	    if (defined $ptrIf->{gw}) {
		$t3 = $ptrIf->{gw};
		#create default route
		#printf FD "route add default gw $t3\n";
		#create host static
		@tempArray = split (";",$ptrIf->{hoststatic});
		foreach $t2 ( @tempArray) {
		    next if ( $t2 =~ /$NOFUNCTION/);
		    printf FD ("route add -host $t2 gw $t3 \n");
		    #create network static
		}
		@tempArray = split (";",$ptrIf->{netstatic});
		foreach $t2 ( @tempArray) {
		    next if ( $t2 =~ /$NOFUNCTION/);
		    printf FD ("route add -net $t2 gw $t3 \n");
		}
		printf FD "exit";
		close FD;
		$var = "-f $file";
		
		$cmd = "$CLICFG -o $cmdTmo  -l $logdir -d $hostIp -i $TELPORT -u $userId -p $pwd ".$var; 
		($rc,$msg)=launchCmd($profFile,$testlog,$cmd,$tmo,$strTest); 
		if ($rc == $PASS) {
		    $msg = "Successful to set up $t3 -- ". $msg;
		} else {
		    $msg = "Failed to set up $t3 -- ". $msg;
		}
	    }
	    last;
	};
	/$BOOT_STATIC/ && do {
	    #create a file 
	    $log->info("Set up Interface with Static ip -- log saved to $file");
	    open(FD,">$file") or die " could not create $file" ;
	    $iface = $ptrIf->{eth};
	    #create IP range
	    if (( defined $ptrIf->{ip}) && ($ptrIf->{ip} !~ /^\s$/)) {
#	    if ( defined $ptrIf->{ip} ) {
		#create IP interface
		$ip = $ptrIf->{ip};
		printf FD "killall dhclient\n";
		printf FD "ifconfig $iface up\n";
		printf FD "ifconfig $iface $ip up\n";
		$ip = ipIncr($profFile,$ip,1);
		$range = 0;
		if (( defined $ptrIf->{range}) && ($ptrIf->{range} !~ /$NOFUNCTION/))  {
		    $range = $ptrIf->{range};
		}
		for ( $index =1 ; $index <= $range ; $index++) {
		    $t2 = $iface.":$index";
		    printf FD ("ifconfig  $t2 $ip \n");
		    $ip = ipIncr($profFile,$ip,1);
		    }
	    }
	    $temp = subnetConvert($profFile,$ip,24);
	    # Must take out this function since it takes too long to scan all network
#	    printf FD ("nmap -sP  $temp \n");
	    if ($ptrIf->{gw} !~ /$NOFUNCTION/ ) {
		$gw = $ptrIf->{gw};
#		printf FD "route add default gw $gw\n";
	    }
	    #create host static
	    @tempArray = split (";",$ptrIf->{hoststatic});
	    foreach $t2 ( @tempArray) {
		$temp=$NOFUNCTION;
		#decice if add host with interface or gw
		($t2,$t3) = split("-",$t2);
		if ($ptrIf->{gw} !~ /$NOFUNCTION/ ) {
		    $temp = "route add -host $t2 gw $gw \n";
		}
		if (defined $t3) { 
		    if ( $t3 =~ /if/i) {
			$temp="route add -host $t2 $iface\n";
		    } else {
			if ($ptrIf->{gw} !~ /$NOFUNCTION/ ) {
			    $temp = "route add -host $t2 gw $gw \n";
			}
		    }
		}
		if ($temp !~ /$NOFUNCTION/) {
		    printf FD $temp;
		}
	    }
	    #create network static
	    @tempArray = split (";",$ptrIf->{netstatic});
	    foreach $t2 ( @tempArray) {
		#decice if add host with interface or gw
		$temp=$NOFUNCTION;
		#decice if add host with interface or gw
		($t2,$t3) = split("-",$t2);
		if ($ptrIf->{gw} !~ /$NOFUNCTION/ ) {
		    $temp = "route add -net $t2 gw $gw \n";
		}
		if (defined $t3) { 
		    if ( $t3 =~ /if/i) {
			$temp="route add -net $t2 $iface\n";
		    } else {
			if ($ptrIf->{gw} !~ /$NOFUNCTION/ ) {
			    $temp = "route add -net $t2 gw $gw \n";
			}
		    }
		}
		if ($temp !~ /$NOFUNCTION/) {
		    printf FD $temp;
		}
	    }

	    
#	    printf FD "exit";
	    close FD;
	    $var = "-f $file";
	    $cmd = "$CLICFG -o $cmdTmo  -l $logdir -d $hostIp -i $TELPORT -u $userId -p $pwd ".$var; 
	    $t3 = $ptrIf->{eth}; 
	    ($rc,$msg)=launchCmd($profFile,$testlog,$cmd,$tmo,$strTest);  
	    if ($rc == $PASS) {
		$msg = "Successful to set up $t3 -- ". $msg;
	    } else {
		$msg = "Failed to set up $t3 -- ". $msg;
	    }
	    
	    last;
	};
	/$INTF_DOWN/ && do {
	    #create a file 
	    $log->info("Turn off up Interface  -- log saved to $file");
	    open(FD,">$file") or die " could not create $file" ;
	    $t3 = $ptrIf->{eth}; 
	    printf FD "ifconfig $t3 down\n";
	    printf FD "ifconfig $t3 \n";
	    printf FD "exit";
	    close FD;
	    $var = "-f $file";
		
	    $cmd = "$CLICFG -o $cmdTmo  -l $logdir -d $hostIp -i $TELPORT -u $userId -p $pwd ".$var; 
	    ($rc,$msg)=launchCmd($profFile,$testlog,$cmd,$tmo,$strTest); 
	    if ($rc == $PASS) {
		$msg = "Successful to set up $t3 -- ". $msg;
	    } else {
		$msg = "Failed to set up $t3 -- ". $msg;
	    }
	    
	    last;
	};
    


	# for unknown case
	$rc = $FAIL;
	$msg="unknown bootype $t1";
	last;
    }
    return($rc,$msg);
}


#************************************************************
# This routine is used to set the remote power supply
# 
#************************************************************
sub setRmpw {
    my ($profFile,$ptrIf,$host,$userId,$pwd,$action,$type) =@_;
    my $rc = $PASS;
    my $cmd;
    my $msg ;
    my $result;
    my $j ;
    my $log= $profFile->{logger};
    for ($type) {
	/$PC8000/ && do {
	    $cmd = $RMPS.$host." ".$userId.":".$pwd." ".$ptrIf->{serviceport}.$action;
	    $log->info(" cmd =$cmd") if ($profFile->{debug} > 1 );
	    $result= system($cmd);
	    $msg = "RMPW successfully perform $cmd";
	    if ( $result != 0 ) {
		$rc=$FAIL;
		$msg = "RMPW failed to perform $cmd";
	    }
	    # Need to check the status
	    $log->info($result) if ($profFile->{debug} > 1 );
	    last;
	};
	$msg=  " RMPW could not recognize model $type "; 
	return($FAIL,$msg);
    }
    return($rc,$msg);
}
#************************************************************
# Configure Remote power 
# 
#************************************************************
sub cfgRmpw {
    my $rc = $FAIL;
    my $msg ;
    my ( $profFile, $junk) = @_;
    my $log= $profFile->{logger};
    my $ptr;
    my $xx;
    my ($host,$hostIp,$userId,$pwd);
    my $index;
    my $ptrIf;
    my $temp;
    my $j;
    my $limit ;
    my $globalRc = $FAIL;
    #Get port and action
    my $port=$NOT_DEF;
    my $action=$NOT_DEF;
    my $prodtype=$NOT_DEF;
    my ($keys,$value);
    my $type;
    my $found = 0;
    my $msg2 ="";
    $limit=$#{$profFile->{commands}};
    for ( $j=0;$j<= $limit;$j++) {
	($keys,$value)= split("=",$profFile->{commands}[$j]);
	if ( $profFile->{commands}[$j] =~ /PORT=/i ) {
	    $port = $value;
	    next;
	}
	if ( $profFile->{commands}[$j] =~ /ACTION=/i ) {
	    $action = $value;
	    next;
	}

	if ( $profFile->{commands}[$j] =~ /PRODTYPE=/i ) {
	    $prodtype = $value;
	    next;
	}
    }
    if ((( $port =~ /$NOT_DEF/ ) && ( $prodtype =~ /$NOT_DEF/ )) || ($action =~ /$NOT_DEF/ )) {
	$msg = "Error:Please enter PORT - ( actual=$port) or ACTION - (actual =$action)";
	return($FAIL,$msg);
    }
    $limit = $#{$profFile->{rmpower}};
    $msg = "";
    for ( $j=0;$j<= $limit;$j++) {
	$ptr =$profFile->{rmpower}[$j];
#	$host = $ptr->{desc};
	$userId = $ptr->{user};
	$pwd = $ptr->{password};
	$host = $ptr->{alias};
	$type= $ptr->{type};
    $log->info ( " TYPE = $type ");
	($rc,$msg) = verifyTarget($profFile,$host);
	if ( $rc == $FAIL ) {
	    return($rc,$FAIL);
	}
	$log->info("$msg");

	$ptr = \@{$ptr->{port}};
	$xx=$#{$ptr};
	$msg2 = "";
	for ( $index = 0 ;$index <=$xx; $index++) {	    
	    $ptrIf = \%{$ptr->[$index]};
	    # Test the logical port 
	    if( ( $ptrIf->{palias} !~ /$port\s*/ ) && ($ptrIf->{prodtype} !~ /$prodtype\s*/ ) ){
		next;
	    } 
	    
	    $log->info("Starting Set up Rmpw ($host) user=$userId,pwd=$pwd -- port = $port ; prodtype = $prodtype  ");	
	    #allways port is antecedent of prodtype 
	    ($rc,$msg2) = setRmpw($profFile,$ptrIf,$host,$userId,$pwd,$action,$type);
	    $found ++;
	    if ( $rc == $PASS) {
		$globalRc=$FAIL;
	    }
	    $msg2 .=$msg2."\n";
#	    return($rc,$msg);
	}
	$msg .= $msg2;
    }
    if ( $found == 0 ) {
	$globalRc = $FAIL;
	$msg = "failed to configure the Remote Power  with port = $port or prodtype =$prodtype " ;
    }
    return($globalRc,$msg);
}




#************************************************************
# Configure Host
#************************************************************
sub cfgHost {
    my $rc = $FAIL;
    my $msg = "failed to set up HOST";
    my ( $profFile, $junk) = @_;
    my $log= $profFile->{logger};
    my $ptr;
    my $xx;
    my ($host,$hostIp,$userId,$pwd);
    my $index;
    my $ptrIf;
    my $temp;
    my $j;
    my $strTest = "-e \"SIOCSIFADDR: No such device\" -e \"SIOCADDRT: Network is unreachable\" ";
    my $tmo = $SETUP_IF_TMO;
    my $cmdTmo = $CMD_TMO;
    my $logdir = $profFile->{logdir};
    my $limit = $#{$profFile->{host}};
    my $globalRc = 0;
    my $file;
    my $testlog;
    my ($shutdownFile,$cmd);
    for ( $j=0;$j<= $limit;$j++) {
	$ptr =$profFile->{host}[$j];
	$host = $ptr->{desc};
	$userId = $ptr->{user};
	$pwd = $ptr->{password};
	$temp = $ptr->{alias};
	($rc,$msg) = verifyTarget($profFile,$temp);
	if ( $rc == $FAIL ) {
	    return($rc,$FAIL);
	}
	$hostIp= $temp;
	$log->info("$msg");
	#lookfor ip address of alias 
#	@junk=`nslookup $temp | grep -i -e address`;
#	$temp = @junk;
#	if ( not defined $junk[1] ) {
#	    $rc = $FAIL;
#	    $msg = " Error: could not get ip Address of $temp ";
#	    return($rc,$msg);
#	}
	#comment out for case network don't use DNS
	#($temp,$hostIp)=split(':',$junk[1]);
	#$hostIp=~ s/ //g;
	#$hostIp=~ s/\n//g;
	#--------------------------------------
	# Shutdown on all interfaces 
	#-------------------------------------
	$ptr = \@{$ptr->{interface}};
	$xx=$#{$ptr};
	$shutdownFile=$logdir."/shutIf_".$hostIp."\.txt";
	$rc=open (FN,">$shutdownFile") ;
	if ( $rc == 0 ) { 
	    $msg = "Shutdown Host failed: could not  create $shutdownFile";
	    $globalRc++;
	}  else {
	    for ( $index = 0 ;$index <=$xx; $index++) {	    
		$ptrIf = \%{$ptr->[$index]};
		if ( $profFile->{hostman} != $ON ){
		    if ($ptrIf->{type} =~ /$MANTYPE/i) {
			next;
		    }
		}	    	
		print FN "ifconfig $ptrIf->{eth} down\n";
	    }
	    print FN "exit\n";
	    close FN;
	    $file = $logdir."/".$profFile->{scriptname}."_shutdownhost_".$hostIp;
	    $testlog = $file.".testlog";
	    $log->info("Shutdown all would-be configured interface host ($host)-- ip=$hostIp, user=$userId,pwd=$pwd ");	
	    #communicate with remote machine and setup their interface
	    $temp = "-f $shutdownFile";		
	    $cmd = "$CLICFG -o $cmdTmo -l $logdir -d $hostIp -i $TELPORT -u $userId -p $pwd ".$temp; 
	    ($rc,$msg)=launchCmd($profFile,$testlog,$cmd,$tmo,$strTest); 
	    if ($rc == $PASS) {
		$msg = "Successful to shutdown all If of $hostIp host  -- ". $msg;
	    } else {
		$msg = "Failed to shutdown all If of $hostIp host  -- ". $msg;
		$globalRc++;
	    }
	}
	#--------------------------------------
	# Configure each interface 
	#-------------------------------------
	$ptr = $profFile->{host}[$j];
	$ptr = \@{$ptr->{interface}};
	$xx=$#{$ptr};
	for ( $index = 0 ;$index <=$xx; $index++) {	    
	    $ptrIf = \%{$ptr->[$index]};
	    if ( $profFile->{hostman} != $ON ){
		if ($ptrIf->{type} =~ /$MANTYPE/i) {
		    next;
		}
	    }
	    $log->info("Starting Set up Host ($host)-- ip=$hostIp, user=$userId,pwd=$pwd ");	
	    #communicate with remote machine and setup their interface
	    ($rc,$msg) = setupInterface($profFile,$ptrIf,$host,$hostIp,$userId,$pwd);
	    if ( $rc == $FAIL){
		$globalRc++;
		$log->info($msg);
	    }
	}
    }
    $rc= $FAIL;
    $msg = "failed to set up HOST";
    if ( $globalRc == 0) {
	$rc = $PASS;
	$msg = "Successful to set up HOST";
    } 
    return($rc,$msg);
}
#************************************************************
# Set up Hardware
#************************************************************
sub cfgTb {
    my ( $profFile, $junk) = @_;
    my $log = $profFile->{logger};
    my $rc = $FAIL;
    my $msg = "failed to set up the configuration";
SWICH_CFGTB:
    for ( $profFile->{cfg}) {
	/$SETUP_ALL/ && do {
	    $log->info(" Set TB Switches and Hosts");
	    #setup switch
	    ($rc,$msg)=cfgSwitch($profFile);
	    if ($rc == $FAIL) {
		return ($rc,$msg);
	    }
	    ($rc,$msg)=cfgHost($profFile);
	    last;
	};
	/$SETUP_SWITCH/ && do {
	    $log->info(" Set TB Switches");
	    ($rc,$msg)=cfgSwitch($profFile);
	    last;
	};
	/$SETUP_HOST/ && do {
	    $log->info(" Set TB Hosts");
	    ($rc,$msg)=cfgHost($profFile);
	    last;

	};
	/$SETUP_RMPW/ && do {
	    $log->info(" Set TB Remote Power ");
	    ($rc,$msg)=cfgRmpw($profFile);
	    last;
	};
	die " Setup Hardware unregcognize $profFile->{cfg} "; 
    }
   return( $rc,$msg); 
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
my $logdir;
my @commands = ();
my $globalRc = 0;
my $option_man = 0;

$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man, 
		  "s"=>\$userInput{screenOff},
		  "n"=>\$userInput{logOff},
		  "l=s"=>sub {  $userInput{logdir} = $_[1]; $logdir = $_[1]},
		  "f=s"=>\$userInput{filename},
		  "a"=>sub { $userInput{cfg} = $SETUP_ALL; },
		  "w"=>sub { $userInput{cfg} = $SETUP_SWITCH; },
		  "r"=>sub { $userInput{cfg} = $SETUP_HOST; },
		  "q"=>sub { $userInput{cfg} = $SETUP_RMPW; },
		  "v=s"=>sub { if ( exists $userInput{commands}[0] ) { push (@{$userInput{commands}},$_[1]); } else {$userInput{commands}[0]=$_[1]; } } ,
		  );
#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);

my $fname = $userInput{filename};
$fname =`ls $fname`;
$fname =~ s/\n//;
$userInput{filename} = $fname;
if (!( -e $fname) ) {
#if ( $rc !=0 ) {
    printf ("ERROR: file $fname could not be found\n");	
    exit 1;
} 
#printf("--------------- Input Parameters  ---------------\n") if $userInput{debug} ;
printf("--------------- $scriptFn  Input Parameters  ---------------\n");
foreach $key ( keys %userInput ) {
#    printf (" $key = $userInput{$key} :: " ) if $userInput{debug} ;
    printf (" $key = $userInput{$key} :: " );
}
my $limit = @{$userInput{commands}};
if ($limit != 0 ) {foreach my $line (  @{$userInput{commands}}) { printf "$line \n"; } };
#---------------------------------------------
# Initialize Logger 
#---------------------------------------------
($rc,$msg) = initLogger(\%userInput, );
if ( $rc != 1) {
    printf ("RC$rc $msg\n");
    exit 1;
} 
#-------------------------------------
# Parsing input file 
#-------------------------------------
($rc,$msg) = parsingXmlCfgFile(\%userInput);
if ( $rc == $FAIL) {
    $userInput{logger}->info("$msg");
    $globalRc++;
}
#-------------------------------------
# Set up hardware
#-------------------------------------
($rc,$msg) = cfgTb(\%userInput );
if ( $rc == $FAIL) {
    $userInput{logger}->info("$msg");
    $globalRc++;
}
if ($globalRc >0 ) {
    $userInput{logger}->info("==> Testbed configuration failed");
    exit 1;
}
$userInput{logger}->info("==> Testbed configuration passed");

exit (0);
1;
__END__

=head1 NAME

tbcfg.pl - configure a testbed harness based on the pre-defined test harness xml file

=head1 SYNOPSIS

=over 12

=item B<tbcfg.pl>
[B<-help|-h>]
[B<-man>]
[B<-s>]
[B<-n>]
[B<-w>]
[B<-r>]
[B<-q>]
[B<-a>]
[B<-f> I<testbed harness xml file>]
[B<-l> I<log file path>]
[B<-x> I<set debug level>]
[B<-v> I<VAR1=... > [-v I<VAR2=...> ...]]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-a>

Setup switches + hosts 

=item B<-w>

Setup switches only . And Variables with w option is -v PRODTYPE=vf2113/cedarbp  and optional -v RESET=1. RESET option is used to reset the switch ports only. 

=item B<-r>

Setup hosts only

=item B<-q>

Turn/off power only. And Variables with q option is -v PORT=logical port and -v ACTION=ON|OFF|PULSE

=item B<-s>

Turn off screen ouput.

=item B<-n>

Turn off message log.

=item B<-f>

Specify the testbed configuration file.

=item B<-l >

Redirect stdout to the /path/tbcfg.log    

=item B<-x>

Specify the debug level. ( more debug messages for  higher number )


=head1 DESCRIPTION

B<tbcfg.pl> allows user to configure a testbed harness through the pre-defined xml file.


=head1 EXAMPLES

1. The following command is used to set up switches, hosts ...
         perl tbcfg.pl -f /svn/svnroot/QA/automation/config/1.0/testbed/sample1.xml

2. The following command is used to set up only switches 
         perl tbcfg.pl -w -f /svn/svnroot/QA/automation/config/1.0/testbed/sample1.xml -v PRODTYPE=vf2113
    Connect only the switchport which supports PRODTYPE as defined.

3. The following command is used to shutdown all ethernet switch ports belongs to sample1 
         perl tbcfg.pl -w -f /svn/svnroot/QA/automation/config/1.0/testbed/sample1.xml -v RESET=1

4. The following command is used to set up hosts 
         perl tbcfg.pl -r -f /svn/svnroot/QA/automation/config/1.0/testbed/sample1.xml

5. The following command is used to turn on( same as /off/pulse)  a Remote Power Supply (PS) switch 
         perl tbcfg.pl -q -f /svn/svnroot/QA/automation/config/1.0/testbed/sample.xml -v PORT=p1 -v ACTION=on
    where p1 is a logical name as defined in .../sample.xml. The operation is based on definition in sample.xml
    or 
         perl tbcfg.pl -q -f /svn/svnroot/QA/automation/config/1.0/testbed/sample.xml -v PRODTYPE=vf2113 -v ACTION=on
    where product type  is  defined in .../sample.xml. The operation is based on definition in sample.xml

=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut

