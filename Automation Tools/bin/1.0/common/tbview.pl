
#!/usr/bin/perl -w
#---------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used to set up a testbed base on testbed name and test suite +  
# display the availability of each testbed and its testbed types.
# 
#
#
#--------------------------------

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
my $NO_FILE= "No File specified";
my $ON=1;
my $OFF=0;
my $PASS=1;
my $FAIL=0;
my $CLI_TMO=1;
my $CLI_PROMPT= 2;
my $CLI_ILLEGAL=3;
my $EXP_DELIMITER ="@";
my $SETUP_IF_TMO = 5 * 60; # 5 minutes
my $verbose = 0;
my $NOFUNCTION="Nofunction";
my @junk = split( /\//, $0);
@junk = split('\.',$junk[$#junk]);
my $TESTBED_TMO= 20 * 60;
my $scriptFn = $junk[0];
my $TB_EXECUTE="execute";
my $TB_STATUS="status";
my $TB_VIEW="view";
my $TB_LOCAL="local";
my $TB_ENV="environment";
my $TB_LOCK="lockTb";
my $TB_UNLOCK="unlockTb";
my $TELPORT=22;
my $DUMMY="dummy";
my $path = $ENV{'G_SQAROOT'};
my $binver = $ENV{'G_BINVERSION'};
my $bincmd = $path."/bin/".$binver."/common/tbcfg.pl";
if (! (-e $bincmd) ) {
    printf ("Error: $0 depends on the availability of $bincmd\n");
    exit 1;
}
my $TBCFG = "perl $bincmd";
$bincmd = $path."/bin/".$binver."/common/clicfg.pl";
if (! (-e $bincmd) ) {
    printf ("Error: $0 depends on the availability of $bincmd\n");
    exit 1;
}
my $CLICFG="perl $bincmd";
my $TBPROF=$path."/config/".$binver."/common/tbmaster.xml";


my %envTable= (
    'host'=>{
	'alias'=>"G_HOST_IP",
	'user'=>"G_HOST_USR",
	'password'=>"G_HOST_PWD",
#	'gw'=>"G_HOST_GW",
	'interface'=>{
	    'ip' =>"G_HOST_TIP",
	    'mask' =>"G_HOST_TMASK",
	    'range'=>"G_HOST_TRANGE",
	    'netstatic'=>"G_HOST_TNET",
	    'hoststatic'=>"G_HOST_THOST",
	    'dns'=>"G_HOST_DNS",
	    'fqdn'=>"G_HOST_FQDN",
	    'eth'=>"G_HOST_IF",
        'mac'=>'G_HOST_MAC',
      'gw'=>"G_HOST_GW",
	},
    },
    'switch'=>{
	'alias'=>"G_SWITCH_IP",
	'user'=>"G_SWITCH_USR",
	'password'=>"G_SWITCH_PWD",
	'type'=>"G_SWITCH_TYPE",
	'port'=>{
	    'palias'=>"G_SWITCH_LOG_PORT",
	    'serviceport'=>"G_SWITCH_PHY_PORT",
	    'prodtype'=>"G_SWITCH_PRODTYPE_PORT",
	    'vlan'=>"G_SWITCH_VLAN_PORT",
	},
    },
    'product'=>{
	'user'=>"G_PROD_USR",
	'password'=>"G_PROD_PWD",
	'prodtype'=>"G_PROD_TYPE",
        'serialnumber'=>"G_PROD_SERIALNUM",
	'interface'=>{
	    'ip' =>"G_PROD_IP",
        'mask' =>"G_PROD_TMASK",
	    'gw'=>"G_PROD_GW",
	    'eth'=>"G_PROD_IF",
	    'dhcpstart'=>"G_PROD_DHCPSTART",
	    'dhcpend'=>"G_PROD_DHCPEND",
        'mac'=>"G_PROD_MAC",
	    'dns1'=>"G_PROD_DNS1",
	    'dns2'=>"G_PROD_DNS2",
	},
    },

    'rmpower'=>{
	'alias'=>"G_RMPS_IP",
	'port'=>{
	    'palias'=>"G_RMPS_LOG_PORT",
	    'serviceport'=>"G_RMPS_PHY_PORT",
	    'prodtype'=>"G_RMPS_PRODTYPE_PORT",
	},
    },
    'tsserver'=>{
	'alias'=>"G_TS_IP",
	'port'=>{
	    'palias'=>"G_TS_LOG_PORT",
	    'serviceport'=>"G_TS_IP_PORT",
	    'prodtype'=>"G_TS_PRODTYPE_PORT",
	},
    },
    
    );


my %userInput = (
    "debug" => "0",
    "logdir"=>"./",
    "filename"=> $TBPROF,
    "defaultfilename"=> $ON,
    "scriptname"=> $scriptFn,
    "screenOff"=> 0,
    "logOff"=> 0,
    "tbchoice"=>$NOFUNCTION,
    "tbtype"=>$NOFUNCTION,
    "prodtype"=>$NOFUNCTION,
    "action"=>$TB_VIEW,
    "testbed"=>{},
    "env"=>[],
    );



#----------------------------------------------------
# This routine is used to parsed all devices from testbed/**.xml
#----------------------------------------------------
sub generateEnv {
    my ( $profFile, $envLookup,$devicetype,$subdevice) = @_;
    my $xx;
    my $yy;
    my $kk;
    my $mm;
    my $j;
    my $jIndex;
    my $temp;
    my $index;
    my $limit;
    my $rc=$PASS;
    my $key ;
    my $log = $profFile->{logger};
    my $msg = "Successfully parsing $devicetype  variables ";
    my $envVar;
    my $orgEnvVar;
    my @buff;
    my $intF;
    $limit = $#{$profFile->{$devicetype}};
    $log->info("Generate Env  DeviceType=$devicetype, SubInterface=$subdevice" ) if ($profFile->{debug} > 3 );
    # Define G_$DEVICE_TYPE_device.interface.subinterface
    for ( $jIndex = 0 , $j=0;$j<= $limit;$j++) {
	my $ptr = $profFile->{$devicetype}[$j];
	next if ( $ptr->{type} =~ /$DUMMY/i );
	if ( defined $ptr->{prodtype} ) {
	    next if ( $ptr->{prodtype} !~ /$profFile->{prodtype}\b/i );
	}
	$xx="$devicetype";
	foreach $kk ( sort keys %{$envLookup->{$devicetype} } )  {
	    $log->info(" KEY = $kk " ) if ($profFile->{debug} > 3 );
	    if ($kk =~ /$subdevice/ ) {
		next;
	    }
	    $envVar = $envLookup->{$devicetype}{$kk};
	    $log->info("1:$envVar" ) if ($profFile->{debug} > 3 );
	    if (not defined $ptr->{$kk} ) {
		$envVar = $envVar."$jIndex=";
		push(@{$profFile->{env}},$envVar);
		$log->info("2:$envVar" ) if ($profFile->{debug} > 3 );
		next;
	    }
	    $envVar = $envVar."$jIndex=".$ptr->{$kk};
	    push(@{$profFile->{env}},$envVar);
	    $log->info("2:$envVar" ) if ($profFile->{debug} > 3 );
	}

	$xx = $#{$ptr->{$subdevice}};
	$ptr = \@{$ptr->{$subdevice}};
	
	for ($index=0,$yy=0;$yy<=$xx;$yy++) {
	    if ( defined $ptr->[$yy]{prodtype} ) {

		next if ( $ptr->[$yy]{prodtype} !~ /$profFile->{prodtype}/i );
	    }
	    $intF="";
	    if ( $devicetype =~ /product/i ) { 
		$intF = uc ($ptr->[$yy]{eth}) ."_";
		$intF ="_".$intF;
	    } 
	    foreach $key ( keys %{$envLookup->{$devicetype} {$subdevice} }) {
		$envVar = $envLookup->{$devicetype}{$subdevice}{$key}.$intF ;
#--------------------------------------------------------------------------
# Based on definition from %envTable, all of its variables must be defined 
#--------------------------------------------------------------------------
		if (not defined $ptr->[$yy]{$key} ) {
		    $envVar = $envVar."$jIndex\_$index\_0=";
		    push(@{$profFile->{env}},$envVar);
		    $log->info("3:$envVar" ) if ($profFile->{debug} > 3 );
		    next;
		}
		if ( $ptr->[$yy]{$key} !~ /\S/ ) {
		    $envVar = $envVar."$jIndex\_$index\_0=";
		    push(@{$profFile->{env}},$envVar);
		    $log->info("4:$envVar -- " ) if ($profFile->{debug} > 3 );
		    next;
		}

		$temp = $ptr->[$yy]{$key};
		#getrid of -f for netstatic and hoststatic
		if (( $key =~ /hoststatic/ ) || ( $key =~ /netstatic/ ) ) {
		    $temp =~ s/-if//g;
		}
		#for the case of HOSTSTATIC And NETSTATIC
		@buff = split(";",$temp);
		$orgEnvVar = $envVar;
		for ($mm =0 ; $mm <= $#buff; $mm++) {
		    $envVar = $orgEnvVar."$jIndex\_$index\_$mm=".$buff[$mm];
		    push(@{$profFile->{env}},$envVar);
		    $log->info("5:$envVar" ) if ($profFile->{debug} > 3 );
		}
	    }
	    $index++;
	}
	$jIndex++;
    }
    return($rc,$msg);
}

#----------------------------------------------------
# This routine is used to parsed all devices from testbed/**.xml
#----------------------------------------------------
sub generateEnv2 {
    my ( $profFile, $envLookup,$devicetype,$subdevice) = @_;
    my $xx;
    my $yy;
    my $kk;
    my $mm;
    my $j;
    my $jIndex;
    my $temp;
    my $index;
    my $limit;
    my $rc=$PASS;
    my $key ;
    my $log = $profFile->{logger};
    my $msg = "Successfully parsing $devicetype  variables ";
    my $envVar;
    my $orgEnvVar;
    my @buff;
    my $intF;
    my $ptr;
    $limit = $#{$profFile->{$devicetype}};
    $log->info("Generate Env  DeviceType=$devicetype, SubInterface=$subdevice -- numOfDev= $limit" ) if ($profFile->{debug} > 3 );
    # Define G_$DEVICE_TYPE_device.interface.subinterface
    for ( $jIndex = 0 , $j=0;$j<= $limit;$j++) {
	$ptr = $profFile->{$devicetype}[$j];
	next if ( $ptr->{type} =~ /$DUMMY/i );
	$log->info("LOOP Generate Env  DeviceType=$devicetype, SubInterface=$subdevice -- numOfDev= $limit " ) if ($profFile->{debug} > 3 );
	if ( defined $ptr->{prodtype} ) {
	    next if ( $ptr->{prodtype} !~ /$profFile->{prodtype}\b/i );
	}
	$xx="$devicetype";
	$log->info("LOOP Generate Env  DeviceType=$devicetype, SubInterface=$subdevice -- numOfDev= $limit -- devicetype =$xx" ) if ($profFile->{debug} > 3 );
	foreach $kk ( sort keys %{$envLookup->{$devicetype} } )  {
	    $log->info(" KEY = $kk " ) if ($profFile->{debug} > 3 );
	    if ($kk =~ /$subdevice/ ) {
		next;
	    }
	    $envVar = $envLookup->{$devicetype}{$kk};
	    $log->info("1:$envVar" ) if ($profFile->{debug} > 3 );
	    if (not defined $ptr->{$kk} ) {
		$envVar = $envVar."$jIndex=";
		push(@{$profFile->{env}},$envVar);
		$log->info("2:$envVar" ) if ($profFile->{debug} > 3 );
		next;
	    }
	    $envVar = $envVar."$jIndex=".$ptr->{$kk};
	    push(@{$profFile->{env}},$envVar);
	    $log->info("2:$envVar" ) if ($profFile->{debug} > 3 );
	}

	$xx = $#{$ptr->{$subdevice}};
	$ptr = \@{$ptr->{$subdevice}};
	$log->info("Generate Env  DeviceType=$devicetype, SubInterface=$subdevice -- numOfDev= $xx" ) if ($profFile->{debug} > 3 );
	for ($index=0,$yy=0;$yy<=$xx;$yy++) {
	    $intF="";
	    if ( $devicetype =~ /product/i ) { 
		$intF = uc ($ptr->[$yy]{eth}) ."_";
		$intF ="_".$intF;
	    } 
	    foreach $key ( keys %{$envLookup->{$devicetype} {$subdevice} }) {
		$envVar = $envLookup->{$devicetype}{$subdevice}{$key}.$intF;
#--------------------------------------------------------------------------
# Based on definition from %envTable, all of its variables must be defined 
#--------------------------------------------------------------------------
		if (not defined $ptr->[$yy]{$key} ) {
		    $envVar = $envVar."$jIndex\_0=";
		    push(@{$profFile->{env}},$envVar);
		    $log->info("3:$envVar" ) if ($profFile->{debug} > 3 );
		    next;
		}
		if ( $ptr->[$yy]{$key} !~ /\S/ ) {
		    $envVar = $envVar."$jIndex\_0=";
		    push(@{$profFile->{env}},$envVar);
		    $log->info("4:$envVar -- " ) if ($profFile->{debug} > 3 );
		    next;
		}
		$temp = $ptr->[$yy]{$key};
		$temp = $ptr->[$yy]{$key};
		#getrid of -f for netstatic and hoststatic
		if (( $key =~ /hoststatic/ ) || ( $key =~ /netstatic/ ) ) {
		    $temp =~ s/-if//g;
		}
		#for the case of HOSTSTATIC And NETSTATIC
		@buff = split(";",$temp);
		$orgEnvVar = $envVar;
		for ($mm =0 ; $mm <= $#buff; $mm++) {
		    $envVar = $orgEnvVar."$jIndex\_$mm=".$buff[$mm];
		    push(@{$profFile->{env}},$envVar);
		    $log->info("5:$envVar" ) if ($profFile->{debug} > 3 );
		}
	    }
	    $index++;
	}
	$jIndex++;
    }
    return($rc,$msg);
}



#----------------------------------------------------
# This routine is used to parsed all devices from testbed/**.xml
#----------------------------------------------------
sub parseDevice {
    my ( $profFile, $data,$devicetype,$subdevice) = @_;
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
    my $msg = "Successfully parsing $devicetype  variables ";
    # return if devicetype is not found 
    if ( !(defined ($data->{$devicetype}) )) {
	$msg = "No $devicetype tag found";
	return($FAIL,$msg);
    }
#    my $devicetype="rmpower";
    #Import PC hosts variables.
    #need to testout if devicetype   is hashref
    if ( !(defined ($data->{$devicetype} {device} {name} ))) {
	foreach $index ( sort keys %{$data->{$devicetype}{device} } ) {
	    my %localSwitch = (
		"type"=>"notdefined",
		"alias"=>"notdefined",
		"$subdevice"=>[],
		);
	    foreach $kk ( keys %{$data->{$devicetype}{device}{$index} } ) {
		if ( $kk =~ /$subdevice/i ) {
		    next;
		}
		if ( $data->{$devicetype}{device}{$index}{$kk} =~ /HASH/ ) {
		    $localSwitch{$kk}  = "";
		} else {
		    $localSwitch{$kk}  = $data->{$devicetype}{device}{$index}{$kk};
		}
	    }
	    $j = 0;
	    
	    $log->info( " $devicetype :: device :: $index :: $subdevice ")     if ( $profFile->{debug} > 2 ) ;
	    if ( !(defined ($data->{$devicetype}{device}{$index}{$subdevice} {name} ) ) ) {
		foreach $kk ( sort keys %{$data->{$devicetype}{device}{$index} {$subdevice} } ) {
		    foreach $mm ( sort keys %{$data->{$devicetype}{device}{$index}{$subdevice}{$kk}} ) {
			if ( $data->{$devicetype}{device}{$index} {$subdevice}{$kk}{$mm} =~ /HASH/ ) {
			    $localSwitch{$subdevice}[$j]{$mm} = "";
			} else {
			    $localSwitch{$subdevice}[$j]{$mm} = $data->{$devicetype}{device}{$index} {$subdevice}{$kk}{$mm};
			}
		    }
		    $j++;
		}		
	    } else {
		foreach $mm ( sort keys %{$data->{$devicetype}{device}{$index}{$subdevice}} ) {
		    if ( $data->{$devicetype}{device}{$index} {$subdevice}{$mm} =~ /HASH/ ) {
			$localSwitch{$subdevice}[$j]{$mm} = "";
		    } else {
			$localSwitch{$subdevice}[$j]{$mm} = $data->{$devicetype}{device}{$index} {$subdevice}{$mm};
		    }
		}
	    }
	    push(@{$profFile->{$devicetype}},\%localSwitch);
	}
    } else {
	    my %localSwitch = (
		"type"=>"notdefined",
		"alias"=>"notdefined",
		"$subdevice"=>[],
		);
	    foreach $kk ( keys %{$data->{$devicetype}{device}} ) {
		if ( $kk =~ /$subdevice/i ) {
		    next;
		}
		if ( $data->{$devicetype}{device}{$kk} =~ /HASH/ ) {
#		    $localSwitch{$kk}  = $NOFUNCTION;
		    $localSwitch{$kk}  = "";
		} else {
		    $localSwitch{$kk}  = $data->{$devicetype}{device}{$kk};
		}
	    }
	    $j = 0;
	    $log->info( " $devicetype :: device  :: $subdevice ")     if ( $profFile->{debug} > 2 ) ;


	    if ( !(defined ($data->{$devicetype}{device}{$subdevice} {name} ) ) ) {
		foreach $kk ( sort keys %{$data->{$devicetype}{device} {$subdevice} } ) {
		    foreach $mm ( sort keys %{$data->{$devicetype}{device}{$subdevice}{$kk}} ) {
			if ( $data->{$devicetype}{device}{$subdevice}{$kk}{$mm} =~ /HASH/ ) {
			    $localSwitch{$subdevice}[$j]{$mm} = "";
			} else {
			    $localSwitch{$subdevice}[$j]{$mm} = $data->{$devicetype}{device} {$subdevice}{$kk}{$mm};
			}
		    }
		    $j++;
		}		
	    } else {
		foreach $mm ( sort keys %{$data->{$devicetype}{device}{$subdevice}} ) {
		    if ( $data->{$devicetype}{device} {$subdevice}{$mm} =~ /HASH/ ) {
			$localSwitch{$subdevice}[$j]{$mm} = "";
		    } else {
			$localSwitch{$subdevice}[$j]{$mm} = $data->{$devicetype}{device}{$subdevice}{$mm};
		    }
		}
	    }
	    push(@{$profFile->{$devicetype}},\%localSwitch);
    }

    if ( $profFile->{debug} > 2 ) { 
	$limit = $#{$profFile->{$devicetype}};
	for ( $j=0;$j<= $limit;$j++) {
	    my $ptr =$profFile->{$devicetype}[$j];
	    $xx="$devicetype";
	    foreach $kk ( sort keys %{$ptr}) {
		if ($kk =~ /$subdevice/ ) {
		    next;
		}
		$yy = $ptr->{$kk};
		$xx = $xx." $kk=$yy "; 
	    }
	    $log->info($xx);
	    $xx = $#{$ptr->{$subdevice}};
	    $ptr = \@{$ptr->{$subdevice}};
	    for ( $yy=0;$yy<=$xx;$yy++) {
		foreach $key ( keys %{$ptr->[$yy]}) {
		    $temp = $ptr->[$yy] {$key};
		    $log->info("$devicetype($j) $subdevice\[$yy\] ($key) =$temp " );
		}
	    }
	}
    }
    return($rc,$msg);
}

#-------------------
# Parsing Xml File 
#-------------------
sub parsingXmlCfgFile {
    my ($profFile,$envLookup,$tbxmlfile,$testLog) = @_;
    my %stageArray=( );
    my $rc = $PASS;
    my $msg = " Parsing XML file succeeded ";
    my $key ;
    my $temp;
    my $j1;
    my $j2;
    my $log = $profFile->{logger};
    my $xmlFile = new XML::Simple;
    #Read in XML File
    my $data = $xmlFile->XMLin($tbxmlfile);
    #printout output
    if ($profFile->{debug} > 2 ) {
	$temp = Dumper($data) ;
	$log->info( $temp );
    }


    ($rc,$msg)= parseDevice($profFile,$data,"tsserver","port");
    if ( $rc == $FAIL ) {
	$log->info($msg);
    }
    ($rc,$msg)= generateEnv($profFile,$envLookup,"tsserver","port");
    if ( $rc == $FAIL ) {
	$log->info($msg);
    }

    ($rc,$msg)= parseDevice($profFile,$data,"rmpower","port");
    if ( $rc == $FAIL ) {
	$log->info($msg);
    }
    ($rc,$msg)= generateEnv($profFile,$envLookup,"rmpower","port");
    if ( $rc == $FAIL ) {
	$log->info($msg);
    }
    ($rc,$msg)= parseDevice($profFile,$data,"switch","port");
    if ( $rc == $FAIL ) {
	$log->info($msg);
    }
    ($rc,$msg)= generateEnv($profFile,$envLookup,"switch","port");
    if ( $rc == $FAIL ) {
	$log->info($msg);
    }


    ($rc,$msg)= parseDevice($profFile,$data,"host","interface");
    if ( $rc == $FAIL ) {
	$log->info($msg);
    }
    ($rc,$msg)= generateEnv($profFile,$envLookup,"host","interface");
    if ( $rc == $FAIL ) {
	$log->info($msg);
    }

    ($rc,$msg)= parseDevice($profFile,$data,"product","interface");
    if ( $rc == $FAIL ) {
	$log->info($msg);
    }
    ($rc,$msg)= generateEnv2($profFile,$envLookup,"product","interface");
    if ( $rc == $FAIL ) {
	$log->info($msg);
    }

    #Display all env
    my $lim = $#{$profFile->{env}};
    $temp="";
    $j1=`echo \"\#Environment for $tbxmlfile\" > $testLog`;
    for ( $key =0 ; $key <= $lim; $key++) {
	$j1=$profFile->{env}[$key];
	$j1=`echo \"$j1\" >> $testLog`;
	$temp = $temp." ".$profFile->{env}[$key];
    }
    $log->info($temp);

    return ($rc,$msg);
}

#------------------------------------------------
# Parse Test Bed Config
#-----------------------------------------------
sub searchTestbed{
    my ( $profFile, $data) = @_;
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
    my ($name,$desc);
    my $tbPtr;
    my $tbFilename;
    my $choice = lc($profFile->{tbchoice});
    my $log = $profFile->{logger};
    my $msg = "Successfully parsing HOST variables ";
      #Import PC hosts variables.
    $temp =Dumper($data);
    $log->info("==>SearchTedbed:\n $temp") if ( $profFile->{debug} > 2 ) ;

    if ( (defined ($data->{testbed} {$choice}) )) {
	$tbFilename = $data->{testbed} {$choice } {filename};
	$temp=`ls $tbFilename`;
	$temp =~ s/\n//g;
	$tbFilename=$temp;
	$log->info("Filename = $temp") ; #if ( $profFile->{debug} > 2 ) ;
	if (! (-e $temp )) {  
	    $msg="Error: File $tbFilename is not FOUND";
	    return($FAIL,$msg);
	}
	$msg=$tbFilename;
	$rc=$PASS;
    } else {
	$msg="No TESTBED TAG found";
        $rc=$FAIL;
    }
    return($rc,$msg);
}

#------------------------------------------------
# Parse Test Bed Config
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
    my $rc=$PASS;
    my $key ;
    my ($name,$desc);
    my $tbPtr;
    my $log = $profFile->{logger};
    my $msg = "Successfully parsing HOST variables ";
    my $ptr= \%{$profFile->{testbed}};
    $temp =Dumper($data);
    $log->info("==>ParseTedbed (file):\n $temp") if ( $profFile->{debug} > 2 ) ;

    #Import PC hosts variables.
    if ( (defined ($data->{testbed}) )) {
	
	# for the case of multiple testbed 
	if ( not defined ($data->{testbed} {name} ) ) {
	    foreach $index ( keys %{$data->{testbed}} ) {
		my %localTb = (
		    "name"=>"notdefined",
		    "desc"=>"notdefined",
		    "suite"=>{},
		);  
		$ptr->{$index}{name} = $index;
		foreach $kk ( keys %{$data->{testbed}{$index} } ) {
		    if ( $kk=~ /suite/i ){
			next;
		    }
		    $ptr->{$index}{$kk} = $data->{testbed}{$index}{$kk};
		}
		if ( !(defined ( $data->{testbed}{$index} {tbtype}{name} ))) {
		    foreach $kk ( keys %{$data->{testbed}{$index} {tbtype} } ) {
			foreach $mm ( keys %{$data->{testbed}{$index} {tbtype} {$kk} } ) {
			    $temp = $data->{testbed}{$index}{tbtype}{$kk}{$mm};
			    $ptr->{$index}{tbtype}{$kk}{$mm}= $temp;
			}
		    }
		} else {
		    $kk = $data->{testbed}{$index} {tbtype} {name};
		    foreach $mm ( keys %{$data->{testbed}{$index} {tbtype}  } ) {
			$temp = $data->{testbed}{$index}{tbtype}{$mm};
			$ptr->{$index}{tbtype}{$kk}{$mm}= $temp;
		    }
		    
		}
	    }
	} else {

	    # for the case of single  testbed 
	    $index= $data->{testbed} {name};
	    my %localTb = (
		"name"=>"notdefined",
		"desc"=>"notdefined",
		"suite"=>{},
		);
	    $ptr->{$index} = {};
#	    $ptr->{$index}{name} = $data->{testbed} {name};
	    foreach $kk ( keys %{$data->{testbed}} ) {
		if ( $kk=~ /suite/i ){
		    next;
		}
		$ptr->{$index}{$kk} = $data->{testbed}{$kk};
	    }
	    if ( !(defined ( $data->{testbed}{tbtype}{name} ))) {
		foreach $kk ( keys %{$data->{testbed}{tbtype} } ) {
		    foreach $mm ( keys %{$data->{testbed}{tbtype} {$kk} } ) {
			$temp = $data->{testbed} {tbtype}{$kk}{$mm};
			$ptr->{$index}{tbtype}{$kk}{$mm}= $temp;
		    }
		}
	    } else {
		$kk = $data->{testbed}{tbtype} {name};
		foreach $mm ( keys %{$data->{testbed}{tbtype}  } ) {
		    $temp = $data->{testbed}{tbtype}{$mm};
		    $ptr->{$index}{tbtype}{$kk}{$mm}= $temp;
		}
		
	    }
	}
    } else {
	$msg="No HOST TAG found";
	return($FAIL,$msg);
    }
    $temp =Dumper($ptr);
    $log->info("==>ParseTedbed (Structure):\n $temp") if ( $profFile->{debug} > 2 ) ;
    return($rc,$msg);
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


#---------------------------------
# Parsing master profile file 
#--------------------------------
sub parsingMasterFile {
    my ($profFile,$junk) = @_;
    my %stageArray=( );
    my $rc = $PASS;
    my $msg = " Parsing XML file succeeded ";
    my $key ;
    my $temp;
    my $tbProfile;
    my $tbFilename;
    my $log = $profFile->{logger};
    my $xmlFile = new XML::Simple;
    #Read in XML File
    my $data = $xmlFile->XMLin($profFile->{filename});
    #printout output
    
    $temp = Dumper($data) ;
    $log->info( $temp ) if ($profFile->{debug} > 2 ) ;
    
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
    # Read in in the correct testbed profile file
    ($rc,$tbFilename)=searchTestbed($profFile,$data);
    return ($rc,$tbFilename) if ( $rc == $FAIL );
    $profFile->{filename} = $tbFilename;
    ($rc,$msg)= parsingXmlTbFile($profFile);
    return ($rc,$msg);
}



#-------------------
# Parsing Xml Testbed File 
#-------------------
sub parsingXmlTbFile {
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

    ($rc,$msg)= parseTestbed($profFile,$data);
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
    if ( defined $rc ) {
	if ( $rc =~ /0/ ) {
	    $rc = $PASS;
	    $msg = "Successful to execute $cmd "; 
	} else {
	    $rc = $FAIL;
	    $msg = "Failed to execute $cmd  "; 
	}
    } else {
	    $rc = $FAIL;
	    $msg = "Failed to execute $cmd  "; 
    }
    return ($rc,$msg);
}
#------------------------------------------------
# Routine used to display the Testbed data structure
#-----------------------------------------------
sub displayTb{
    my ($profFile,$tbPtr,$tbName) = @_;
    my $log = $profFile->{logger};
    my $rc = $PASS;
    my ($kk,$mm,$i);
    my $temp;
    my ($desc,$alias);
    my $msg = " Successfully display Testbed\[$tbName\]data structure ";
    $desc = $tbPtr->{desc};
    $alias = $tbPtr->{alias};
    $log->info("\nTestbed\[$tbName\]:MasterPc($alias):Desc=$desc" );
    $i =0;
    foreach $kk ( sort keys %{$tbPtr->{tbtype}} ) {
	$log->info("\[$i\]Testbed type:$kk");
	foreach $mm ( keys %{$tbPtr->{tbtype}{$kk}} ) {
	    $temp = $tbPtr->{tbtype}{$kk} {$mm};
	    $log->info("\t\t$mm=$temp");
	}
	$i++;
    }
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
    $index = lc($profFile->{tbchoice});
    $log->info(" ====> TESTBED = $index ");

    if ( $profFile->{tbchoice}=~ /$NOFUNCTION/i ) {
	foreach  $index (sort keys %{$ptr} ) {
	    $tbPtr = \%{$ptr->{$index}};
	    ($rc,$msg)=displayTb($profFile,$tbPtr,$index);
	}
    } else {
	if ( not defined $ptr->{$index} ) {
	    $rc = $FAIL;
	    $msg = "failed to set up the configuration -- (tbprof) testbed $index not found";
	    return($rc,$msg);
	}
	$tbPtr = \%{$ptr->{$index}};
	($rc,$msg)=displayTb($profFile,$tbPtr,$index);
    }
    return($rc,$msg);
}

#------------------------------------------------
# Parse Test Bed Config
#-----------------------------------------------
sub tbenv{
    my ( $profFile, $envLookup) = @_;
    my $tbXmlFile;
    my $log = $profFile->{logger};
    my $rc = $FAIL;
    my $hostname; 
    my $tbName;
    my $tbtype;
    my $temp;
    my $msg = "failed to set up the configuration";
    my $ptr= \%{$profFile->{testbed}};

    $temp = Dumper($ptr) ;
    $log->info( $temp ) ; # if ($profFile->{debug} > 2 ); 

    #get the name of the testbed or current one
    $tbName = lc($profFile->{tbchoice}); 
    $log->info("SEARCH for testbed = $tbName" );
    if ( $tbName =~ /$NOFUNCTION/) {
	#seach for alias
	$hostname=`hostname`;
	$hostname =~ s/\n//;
	$log->info("HOSTNAME = $hostname" );
	$tbName = getTbName($profFile,$hostname);
	if ($tbName =~ /$NOFUNCTION/) {
	    $msg = "failed to set up the configuration -- (tbenv)user needs to enter testbed name";
	    return($rc,$msg);
	}
    } else {
	if ( not defined $ptr->{$tbName} ) {
	    $msg = "failed to set up the configuration -- (tbenv)testbed $tbName not found";
	    return($rc,$msg);
	}
    }
    $log->info( " Testbed = $ptr->{$tbName}{name}") if ( $profFile->{debug} > 4 ) ;
    $tbtype = lc($profFile->{tbtype});
    $tbtype =~ s/ //g;
    if ( not defined ($ptr->{$tbName}{tbtype}{$tbtype})) {
	 $msg = "Failed: Testbed Type\[$tbtype\] of  Tb\[$tbName\] was not found from database ";
	 return($rc,$msg);	
    }
    $tbXmlFile = $ptr->{$tbName}{tbtype}{$tbtype}{file};
    $log->info("1:Parse file = $tbXmlFile");
    $tbXmlFile = `ls $tbXmlFile`;
    $tbXmlFile =~ s/\n//;
    $log->info("2:Parse file = $tbXmlFile");
    my $testLog = $profFile->{logdir}."/".$profFile->{scriptname}."_env_$tbName"."_$tbtype".".testlog";
    $temp=`touch $testLog`;
    $testLog = `ls $testLog`;
    $testLog =~ s/\n//;
        
    ($rc,$msg)=parsingXmlCfgFile ($profFile,$envLookup,$tbXmlFile,$testLog);    
    return( $rc,$msg); 

}
#************************************************************
# Get Master IP address of test bed
#************************************************************
sub getTbMaster {
    my ($profFile,$tb) = @_;
    my $ptr= \%{$profFile->{testbed}};
    my $log = $profFile->{logger};
    if ( not defined $ptr->{$tb} ) {
	return($FAIL,$NOFUNCTION);	
    }
    my $alias = $ptr->{$tb}{alias};
    $log->info("\n Testbed $tb--alias($alias) is found " ) if ( $profFile->{debug} > 1 );
    return ($PASS,$alias);
}


#************************************************************
# Using cross reference for testbed name
#************************************************************
sub getTbName {
    my ($profFile,$hostname) = @_;
    my $ptr= \%{$profFile->{testbed}};
    my $tb;
    my $log = $profFile->{logger};
    foreach  $tb (keys %{$ptr} ) {
	$log->info("\n Testbed $tb " );
	if ( $ptr->{$tb}{alias} =~ /$hostname/i) {
	    $log->info("\n Testbed $tb is found " );
	    return ($tb);
	}
    }
    return($NOFUNCTION);
}
#************************************************************
#  Lock TB remotely 
#************************************************************
sub tbLock {
    my ($profFile,$junk) =@_;
    my $log = $profFile->{logger};
    my $rc = $FAIL;
    my $tb = $profFile->{tbchoice};
    my $alias ;
    my $cmd ;
    my $msg = "Failed to lock $tb:";
    my $lockfile = "/tmp/".$profFile->{scriptname}."_lock.txt";
    my $temp =`date +%Y%m%d%H%M%S`;
    $temp =~ s/\n//;
    my $hostname = `hostname`;
    $hostname =~ s/\n//;
    $temp = $hostname."_locked_on_".$temp; 
    $temp = "echo \"$temp\" > $lockfile";
    $log->info("TBLOCK = $tb\n") if ( $profFile->{debug} > 1 );
    ($rc,$alias) = getTbMaster($profFile, $tb);
    $msg = $msg.$alias;
    return($rc,$msg) if ( $rc == $FAIL ) ;
    $cmd = "$CLICFG -d $alias -i $TELPORT -u root -p gomain03 -v \"$temp\"";
    $log->info("TBLOCK : execute $cmd \n") if ( $profFile->{debug} > 1 );
    $temp = system($cmd);

    if ( $temp == 1 ) {
	$msg = $msg."through $alias";
	return ($FAIL,$msg);
    }
    $msg = " Successfully lock $tb -- alias($alias) ";
    return($PASS,$msg);
}
#************************************************************
# Lock TB locally
#************************************************************
sub tbLockLocal {
    my ($profFile,$junk) =@_;
    my $rc = $PASS;
    my $log = $profFile->{logger};
    my $lockfile = "/tmp/".$profFile->{scriptname}."_lock.txt";
    my $msg = "Successfull to set lock file $lockfile";
    $log->info("TBLOCK =$profFile->{tbchoice}\n");
    my $temp =`date +%Y%m%d%H%M%S`;
    $temp =~ s/\n//;
    my $hostname = `hostname`;
    $hostname =~ s/\n//;
    $temp = $hostname."_locked_on_".$temp; 
    $temp = `echo \"$temp\" > $lockfile`;
    if ( $temp =~ /cannot remove/ ) {
	$rc = $FAIL;
	$msg = "failed to set up $lockfile".$temp;
    }
    return($rc,$msg);
}

#************************************************************
#   Unlock TB remotely 
#************************************************************
sub tbUnlock {
    my ($profFile,$junk) =@_;
    my $log = $profFile->{logger};
    my $rc = $FAIL;
    my $tb = $profFile->{tbchoice};
    my $alias ;
    my $cmd ;
    my $msg = "Failed to unlock $tb:";
    my $lockfile = "/tmp/".$profFile->{scriptname}."_lock.txt";
    my $temp ="rm -f $lockfile";
    $log->info("TBLOCK = $tb\n") if ( $profFile->{debug} > 1 );
    ($rc,$alias) = getTbMaster($profFile, $tb);
    $msg = $msg.$alias;
    return($rc,$msg) if ( $rc == $FAIL ) ;
    $cmd = "$CLICFG -d $alias -i $TELPORT -u root -p gomain03 -v \"$temp\"";
    $log->info("TBUNLOCK : execute $cmd \n") if ( $profFile->{debug} > 1 );
    $temp = system($cmd);
    if ( $temp == 1 ) {
	$msg = $msg."through $alias";
	return ($FAIL,$msg);
    }
    $msg = " Successfully unlock $tb -- alias($alias) ";
    return($PASS,$msg);

}
#************************************************************
# Unlock TB locally
#************************************************************
sub tbUnlockLocal {
    my ($profFile,$junk) =@_;
    my $rc = $PASS;
    my $log = $profFile->{logger};
    my $lockfile = "/tmp/".$profFile->{scriptname}."_lock.txt";
    my $msg = "Successfull unlock $lockfile";
    $log->info("TBLOCK =$profFile->{tbchoice}\n");
    my $temp = `rm -f $lockfile`;
    if ( $temp =~ /cannot remove/ ) {
	$rc = $FAIL;
	$msg = "Failed to remove $lockfile:".$temp;
    }
    return($rc,$msg);
}

#************************************************************
# Set up Hardware
#************************************************************
sub cfgTb {
    my ( $profFile, $data) = @_;
    my $temp;
    my $log = $profFile->{logger};
    my $rc = $FAIL;
    my $hostname; 
    my $tbName;
    my $tbtype;
    my $prodtype;
    my $msg = "failed to set up the configuration";
    my $ptr= \%{$profFile->{testbed}};

    #get the name of the testbed or current one
    $tbName = lc($profFile->{tbchoice}); 
    if ( $tbName =~ /$NOFUNCTION/) {
	#seach for alias
	$hostname=`hostname`;
	$hostname =~ s/\n//;
	$log->info("HOSTNAME = $hostname" );
	$tbName = getTbName($profFile,$hostname);
	if ($tbName =~ /$NOFUNCTION/) {
	    $msg = "failed to set up the configuration -- user needs to enter testbed name";
	    return($rc,$msg);
	}
    } else {
	if ( not defined $ptr->{$tbName} ) {
	    $msg = "failed to set up the configuration -- testbed $tbName not found";
	    return($rc,$msg);
	}
    }
    $log->info( " Testbed = $ptr->{$tbName}{name}");
    $tbtype = lc($profFile->{tbtype});
    $tbtype =~ s/ //g;
    if ( not defined ($ptr->{$tbName}{tbtype}{$tbtype})) {
	 $msg = "Failed to set up the configuration -- Tb\[$tbName\] Testbed type\[$tbtype\] not found";
	 return($rc,$msg);	
    }
    $temp = $ptr->{$tbName}{tbtype}{$tbtype}{file};
    $prodtype=lc($profFile->{prodtype});
    $temp = "$TBCFG -a -f $temp -l $profFile->{logdir} -v PRODTYPE=$prodtype";
    $log->info("Execute cmd = $temp");
    my $testLog = $profFile->{logdir}."/".$profFile->{scriptname}."_$tbName"."_$tbtype".".testlog";
    ($rc,$msg) = launchCmd ($profFile,$testLog,$temp,$TESTBED_TMO);
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
#		  "s"=>\$userInput{screenOff},
#		  "n"=>\$userInput{logOff},
		  "l=s"=>sub {  $userInput{logdir} = $_[1]; $logdir = $_[1]},
		  "b=s"=>\$userInput{tbchoice},
		  "t=s"=>\$userInput{tbtype},
		  "p=s"=>\$userInput{prodtype},
		  "r=s"=>sub { $userInput{action} = $TB_LOCK; $userInput{tbchoice} = $_[1];},
		  "u=s"=>sub { $userInput{action} = $TB_UNLOCK; $userInput{tbchoice} = $_[1];},
		  "e"=>sub { $userInput{action} = $TB_EXECUTE; },
#		  "z"=>sub { $userInput{action} = $TB_STATUS; },
		  "g"=>sub { $userInput{action} = $TB_ENV; },
		  "f=s"=>sub { $userInput{filename}= $_[1]; $userInput{defaultfilename} = $OFF; },
		  "v=s"=>sub { if ( exists $commands[0] ) { push (@commands,$_[1]); } else {$commands[0]=$_[1]; } } ,
		  );
#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);
#---------------------------------------------
# Initialize Logger 
#---------------------------------------------
($rc,$msg) = initLogger(\%userInput, );
if ( $rc != 1) {
    printf ("RC$rc $msg\n");
    exit 1;
} 

my $fname; 
#if (( $userInput{action} !~  /$TB_UNLOCK/ ) && ( $userInput{action} !~  /$TB_LOCK/ ) ) { 
#if (  $userInput{filename} !~ /$NO_FILE/ ) {
$fname = $userInput{filename}; 
$fname=`ls $fname`;
$fname=~ s/\n//;
printf ("$fname");
$userInput{filename}= $fname;
if (!( -e $fname) ) {
    $userInput{logger}->info("ERROR: file $fname could not be found\n");	
    exit 1;
}
#------------------------------------- 
# Parsing input file 
#-------------------------------------
my $defaultFn = $userInput{filename};
($rc,$msg) = parsingMasterFile(\%userInput );
if ( $rc == $FAIL) {
    $userInput{logger}->info("<===== ParsingMasterFile: \n $msg");
    $globalRc++;
    
}

my $defaultmsg="Use user's testbed profile file: $defaultFn"; 
if ( $userInput{defaultfilename} == $ON ) {
    $defaultmsg="Use default testbed profile file: $defaultFn ";  
}

#printf("--------------- Input Parameters  ---------------\n") if $userInput{debug} ;
printf("------- $scriptFn  Input Parameters  --------\n\[$defaultmsg\]\n\n");
foreach $key ( keys %userInput ) {
#    printf (" $key = $userInput{$key} :: " ) if $userInput{debug} ;
    printf (" $key = $userInput{$key} :: " );
}
my $limit = @commands;
#if ($limit != 0 ) {foreach my $line (  @commands) { printf "$line \n"; } };
#-------------------------------------
# Switch between action
#-------------------------------------
for ($userInput{action} ) {
    /^$TB_EXECUTE$/ && do {
	if (  $userInput{filename} =~ /$NO_FILE/ ) {
	    $userInput{logger}->info("Error: need testbed profile ");
	    pod2usage(1);
	    exit 1;
	}
	($rc,$msg) = cfgTb(\%userInput );
	last;
    };
    /^$TB_LOCK$/ && do {
	if (  $userInput{tbchoice} =~ /$TB_LOCAL/i ) {
	    ($rc,$msg) = tbLockLocal(\%userInput);
	} else {
	    ($rc,$msg) = tbLock(\%userInput);
	}
	last;
    };
    /^$TB_UNLOCK$/ && do {
	if (  $userInput{tbchoice} =~ /$TB_LOCAL/i ) {
	    ($rc,$msg) = tbUnlockLocal(\%userInput);
	} else {
	    ($rc,$msg) = tbUnlock(\%userInput);
	}
	last;
    };

    /^$TB_STATUS$/ && do {
#	($rc,$msg) = tbStatus(\%userInput );
	last;
    };
    /^$TB_VIEW$/ && do {
	if (  $userInput{filename} =~ /$NO_FILE/ ) {
	    $userInput{logger}->info("Error: need testbed profile ");
	    pod2usage(1);
	    exit 1;
	}

	($rc,$msg) = tbprof(\%userInput );
	last;
    };
    /^$TB_ENV$/ && do {
	if (  $userInput{filename} =~ /$NO_FILE/ ) {
	    $userInput{logger}->info("Error: need testbed profile ");
	    pod2usage(1);
	    exit 1;
	}

	($rc,$msg) = tbenv(\%userInput,\%envTable );
#	$userInput{logger}->info("$msg");
	if ($rc == $FAIL) {
	    $userInput{logger}->info("==> $msg \n Error:Failed to Generate Environment Variables");
	    exit (1);
	}
	exit (0);
    };

    die " Unrecognize action value : $userInput{action} ";
}
$userInput{logger}->info("$msg");
if ( $rc == $FAIL) {
    $userInput{logger}->info("==> Testbed configuration failed");
    exit 1;
}
$userInput{logger}->info("==> Testbed configuration passed");
exit (0);
1;
__END__

=head1 NAME

tbview.pl - display testbed type  sets for each testbed or configure testbed topology based on the testbed and testbed type. 

=head1 SYNOPSIS

=over 12

=item B<tbview.pl>
[B<-help|-h>]
[B<-man>]
[B<-f> I<testbed profile>]
[B<-g> I<display testbed env.>]
[B<-l> I<log file path>]
[B<-b> I<testbed name >]
[B<-t> I<testbed type  name>]
[B<-r> I<testbed name/local>]
[B<-u> I<testbed name/local>]
[B<-g>]
[B<-e>]
[B<-x> I<debug level>]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-b>

Specify a testbed name to be used

=item B<-t>

Specify a testbed type  name
 
=item B<-e>

Configure testbed harness based on testbed name and its testbed type

=item B<-p>

Specify product type

=item B<-f>

Specify a testbed profile file. ( Default: $G_SQAROOT/config/1.0/common/tbprofile.xml )

=item B<-g>

Display testbed environment variables. ( Default: $G_SQAROOT/config/1.0/common/tbprofile.xml )

=item B<-l >

Redirect stdout to the /path/tbview.log

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-r>

Lock/Reserve the testbed locally or remotely ( Convention : local or Testbed Name ).

=item B<-u>

UnLock/free the testbed locally or remotely ( Convention : local or Testbed Name ).

=item B<-x>

Set debug to different level . ( more debug messages with higher number)

=back

=head1 DESCRIPTION

B<tbview.pl> will allow user to configure a testbed harness based on testbed type and testbed name


=head1 EXAMPLES

1. The following command is used to REMOTELY configure the testbed with the given selected values as  testbed tb1 and testbed type  sample
         perl tbview.pl -e -b tb1 -t sample -f /svn/svnroot/QA/automation/config/1.0/common/tbprofile.xml 


2. The following command is used to LOCALLY configure the testbed with the given selected values as  testbed tb1 and testbed type  sample  while user is currently logged in tb1 ( -b option is omitted ).
    perl tbview.pl -e -t sample -f /svn/svnroot/QA/automation/config/1.0/common/tbprofile.xml 

3. The following command is used to display available testbed types per testbed
    perl tbview.pl -f /svn/svnroot/QA/automation/config/1.0/common/tbprofile.xml 

4. The following command is used to preserve the current testbed
    perl tbview.pl -r local

5. The following command is used to preserve remotely the testbed
    perl tbview.pl -r tb1

6. The following command is used to generate the environment variables to be used with the current testsuite. 
    perl tbview.pl -g -b tb1 -t nflow -p cedarbp  -f /svn/svnroot/QA/automation/config/1.0/common/tbprofile.xml



=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut

