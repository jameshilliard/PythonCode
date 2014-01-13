#!/usr/bin/perl -w
#----------------------------------
#Author: Alex_dai
#
#Description: detect the HTML change between different version,then give the list  
#	      of the filename which was new added or deleted or modified
#
#Input parameters:
#		$CustomName  :
#		$ProductType :
#		$baseVersion :
#		$diffVresion :
#		$outputfile     :
#		$logdir      :
#
#Usage: ./versionDiffInHtml.pl -c $CustomName -p $ProductType -v baseVersion -v diffVresion -o $outputfile  [-l $logdir]
#
#-----------------------------------	


use strict;
use warnings;
use diagnostics;
use Log::Log4perl;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use Data::Dumper;
use Expect;
#default timeout for each command
#-----<<<----------------
my $FAIL=1;
my $PASS=0;
my $NODEFINE="none";
my @junk = split( /\//, $0);
@junk = split('\.',$junk[$#junk]);
my $scriptFn = $junk[0];
my $logdir = `pwd`;
$logdir=~ s/\n//;
my %diffResult;
my $LocalDirA;
my $LocalDirB;
my @LocalDirA ;
my @LocalDirB ;
my @pathA ;
my @pathB ;
#---------------------------------------------------------
# This routine is used to initialize the log feature
#---------------------------------------------------------
sub initLogger {
    my ( $profFile, $junk) = @_;
    my $rc = $PASS;
    my $msg ="Successfully Set Logger";
    my $found=1;
    my $count=0;
    my $localLog;
    #--------------------
    # initialize logger
    #---------------------
    my $temp = $profFile->{scriptname}."_$profFile->{seed}";
    while ( $found ) {
	$localLog = $profFile->{logdir}."/".$profFile->{scriptname}."_output_$count.log";
	if ( !(-e $localLog)){
	    $found=0;
	    next;
	}
	$count++;
    }

   
    my $clobberLog = $profFile->{logdir}."/".$profFile->{scriptname}."_clobber_$count.log";
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
#	my $writer = Log::Log4perl::Appender->new("Log::Log4perl::Appender::File",
#						  filename => $clobberLog,
#						  mode => "clobber");
	$appender->layout($layout);	
	$profFile->{logger}->add_appender($appender);
#	$profFile->{logger}->add_appender($writer);
    }
    if ( $profFile -> {noprint} ) {
	$profFile->{logger}->info("--> Log initialized <--");
    }
    return($rc,$msg);

}

#--------------------------------------------------------
#
#Load config file
#
#--------------------------------------------------------
sub loadCfg{
	my ($profFile) = @_;
	my $rc = $PASS;
	my $msg = "Load config file successfully.";
	my @tempA;
	my @tempB;
	my $k;

	#$LocalDirA = $profFile->{version}[0];
#	$LocalDirB = $profFile->{version}[1];
	if( ! open CONFIG, "< /root/automation/config/1.0/common/versionDiff.cfg"){
	#	die "Cannot open config file!";		
		$rc = $FAIL;
		$msg = "cannot open config file";
		return ($rc,$msg);
	}
	while (<CONFIG>) {
		chomp;
		if(! $pathA[0]){
			if(/^($profFile->{customname}:$profFile->{producttype}:$profFile->{version}[0];)/){
				@tempA = split(";",$_);
				shift @tempA;
				@pathA = @tempA;
				foreach $k (0..$#pathA){
					$LocalDirA[$k] = "/root/automation/Download/http"."/$profFile->{customname}"."/$profFile->{producttype}"."/$profFile->{version}[0]";
				}
			}
		}
		if(! $pathB[0]){
			if(/^($profFile->{customname}:$profFile->{producttype}:$profFile->{version}[1];)/){
				@tempB = split(";",$_);
				shift @tempB;
				@pathB = @tempB;
				foreach $k (0..$#pathB){
					$LocalDirB[$k] = "/root/automation/Download/http"."/$profFile->{customname}"."/$profFile->{producttype}"."/$profFile->{version}[1]";
				}
			}		
		}
		if($pathA[0] && $pathB[0]){
			close CONFIG;
			return ($rc,$msg);
		}
	}
	close CONFIG;



	if( ! open CONFIG, "< /root/automation/config/1.0/common/versionDiff.cfg"){
	#	die "Cannot open config file!";		
		$rc = $FAIL;
		$msg = "cannot open config file";
		return ($rc,$msg);
	}
	while (<CONFIG>) {
		chomp;
		if(! $pathA[0]){
			if(/^($profFile->{customname}:$profFile->{producttype}:\$U_DUT_FW_VERSION;)/) {
				@tempA = split(";",$_);
				shift @tempA;
				@pathA = @tempA;
				foreach $k (0..$#pathA){
					$pathA[$k] =~ s/\$U_DUT_FW_VERSION/$profFile->{version}[0]/;
					$LocalDirA[$k] = "/root/automation/Download/http"."/$profFile->{customname}"."/$profFile->{producttype}"."/$profFile->{version}[0]";
				}
			}
		}
		if(! $pathB[0]){
			if(/^($profFile->{customname}:$profFile->{producttype}:\$U_DUT_FW_VERSION;)/) {
				@tempB = split(";",$_);
				shift @tempB;
				@pathB = @tempB;
				foreach $k (0..$#pathB){
					$pathB[$k] =~ s/\$U_DUT_FW_VERSION/$profFile->{version}[1]/;
					$LocalDirB[$k] = "/root/automation/Download/http"."/$profFile->{customname}"."/$profFile->{producttype}"."/$profFile->{version}[1]";
				}
			}
		}
		if($pathA[0] && $pathB[0]){
			close CONFIG;
			return ($rc,$msg);
		}
	}
	close CONFIG;


	if(!$pathA[0] ||!$pathB[0]){
		$rc = $FAIL;
		$msg = "Cannot find the cvs path";
		return ($rc,$msg);
	}
	
	return ($rc,$msg);

}




#--------------------------------------------------------
# 
# Download the source code from CVS server
#  
#--------------------------------------------------------
sub GetSourceProcess{
    my ($profFile) = @_;
#    print "version 	$profFile->{version}[0]		$profFile->{version}[1]\n";
    my $rc = $PASS;
    my $ret = 0;
    my $index=0;
    my $log = $profFile->{logger};
    my $msg = "";
    my $cmd;
    my $k;
    my $Local_Dir;
    
    system("mkdir $LocalDirA[0] -p");
    system("mkdir $LocalDirB[0] -p");

    for($k = 0;$k < @pathA;$k++){
	$cmd = $pathA[$k];
	$cmd =~ s/\$Local_Dir/$k/;
	$Local_Dir = $LocalDirA[$k]."/$k";
	if(-e $Local_Dir){
		$LocalDirA[$k] = $Local_Dir;
		next;
	}
	$ret = system($cmd);
    	$ret /= 256;
    	if($ret != 0){
		$rc = $FAIL;
		$msg = "fail in checkout $cmd.";
		return ($rc,$msg);
	}
	system("mv $k $LocalDirA[$k]");
	$LocalDirA[$k] = $Local_Dir;
    }

    for($k = 0;$k < @pathB;$k++){
	$cmd = $pathB[$k];
	$cmd =~ s/\$Local_Dir/$k/;
	$Local_Dir = $LocalDirB[$k]."/$k";
	if(-e $Local_Dir){
		$LocalDirB[$k] = $Local_Dir;
		next;
	}
	$ret = system($cmd);
    	$ret /= 256;
    	if($ret != 0){
		$rc = $FAIL;
		$msg = "fail in checkout $cmd.";
		return ($rc,$msg);
	}
	system("mv $k $LocalDirB[$k]");
	$LocalDirB[$k] = $Local_Dir;
    }

    $msg = "download source code form CVS server successfully.";
    $log->info("$msg");
    return $rc;
}

#-----------------------------------------------------------
#
#Compare the files between the two version,and find the different files
#
#-----------------------------------------------------------
sub DiffProcess{
	my ($dir1,$dir2) = @_;
	my $rc =0;
	my %Dir;
	my %Dir1;
	my %Dir2;
	my @temp;
	my $key;
	my $msg = "diff successfully";

	if(-e $dir1){
		@temp=`ls $dir1`;
		chomp(@temp);
		foreach (@temp) {
			$key = $dir1."/$_";
			$key =~ s/$LocalDirA\///;
			$Dir{$key} = $Dir1{$key} = 1;
			$diffResult{$key} = [];
		}
	}
	if(-e $dir2){
		@temp = `ls $dir2`;
		chomp(@temp);
		foreach (@temp) {
			$key = $dir2."/$_";
			$key =~ s/$LocalDirB\///;		
			$Dir{$key} = $Dir2{$key} = 1;	
			$diffResult{$key} = [];
		}
	}
	foreach $key (keys %Dir){
		my $file1 = "$LocalDirA"."/$key";
		my $file2 = "$LocalDirB"."/$key";
		if(-d $file1 or -d $file2){
			($rc,$msg) = DiffProcess($file1,$file2);
			delete $diffResult{$key};			
		}else {
			if(exists $Dir1{$key} and exists $Dir2{$key}){
				my $value = system("diff $file1 $file2 -q > /dev/null");
				$value /=256;
				if($value == 0){
					delete $diffResult{$key};
				}elsif($value ==1) {
					$diffResult{$key}[0] = "Old";
					$diffResult{$key}[1] = "Modified";
				}else {
					$diffResult{$key}[0] = "---";
					$diffResult{$key}[1] = "---";
				}
			}elsif(exists $Dir1{$key} and !(exists $Dir2{$key})){
				$diffResult{$key}[0] = "New";
				$diffResult{$key}[1] = "No";
			}elsif(!(exists $Dir1{$key}) and exists $Dir2{$key}){
				$diffResult{$key}[0] = "NO";
				$diffResult{$key}[1] = "New";
			}
		}
		delete $Dir{$key};
		delete $Dir1{$key};
		delete $Dir2{$key};
	}
	return ($rc,$msg);
}


#************************************************************
# Main Routine
#************************************************************
MAIN:
my $TRUE=1;
my $FALSE=0;
my $option_h;
my $rc =0;
my $msg;
my $count = 0;
my $globalRc = $PASS;
my $option_man = 0;
my $temp;
my $found =0;
my $key;
my %userInput = (
    "debug" => "0",
    "logdir"=>$logdir,
    "outputfile"=>$NODEFINE,
    "scriptname"=> $scriptFn,
    "screenOff"=> 0,
    "customname"=>$NODEFINE,
    "producttype"=>$NODEFINE,
    "prefix"=>$NODEFINE,
    "postfix"=>$NODEFINE,
    "version"=> [],
    "logOff"=> 0,
    "noprint"=> 1,
    "errtable"=>[ "Login failed due to a bad username or password",
		  "parser error :",
    ],
    );

#---------------------------------------------
# Initialize Logger 
#---------------------------------------------
$userInput{seed}="0";
$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man, 
		  "c=s"=>\$userInput{customname},
		  "p=s"=>\$userInput{producttype},
		  "o=s"=>\$userInput{outputfile},
		  "l=s"=>sub {  $userInput{logdir} = $_[1];},
		  "B=s"=>\$userInput{postfix},
		  "n"=>sub { $userInput{noprint} = 0},
		  "v=s"=>sub { if ( exists $userInput{version}[0] ) { push (@{$userInput{version}},$_[1]); } else {$userInput{version}[0]=$_[1]; } } ,
		  );
#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);
if ( $userInput{customname} =~ $NODEFINE || 
     $userInput{producttype} =~ $NODEFINE || 
     !(exists$userInput{version}[0]) || 
     !(exists $userInput{version}[1]) ) {
    print ("\n==>Error Missing Version param\n");
    pod2usage(1);
    exit 1;
}

($rc,$msg) = initLogger(\%userInput, 0);
if ( $rc == $FAIL) {
    print ("RC$rc $msg\n");
    exit 1;
} 
if ( $globalRc == $FAIL) {
    $userInput{logger}->info("$msg");
    exit 1;
}



#printf("--------------- Input Parameters  ---------------\n") if $userInput{debug} ;

if ( $userInput{ noprint } ) { 
print("--------------- $scriptFn  Input Parameters  ---------------\n");
    foreach $key ( keys %userInput ) {
#    printf (" $key = $userInput{$key} :: " ) if $userInput{debug} ;
	print (" $key = $userInput{$key} ::\n" );
    }
}

($rc,$msg) = loadCfg(\%userInput);
$userInput{logger}->info("$msg");
goto fail  if($rc == $FAIL);
    
goto fail if(($rc= GetSourceProcess(\%userInput)) == $FAIL);

my $i;
my $j;
system("rm -rf $userInput{outputfile}");
for($i = 0;$i < @pathA;$i++){
    for($j = 0;$j < @pathB;$j++){
	$LocalDirA = $LocalDirA[$i];
	$LocalDirB = $LocalDirB[$j];
	%diffResult = ();
	($rc,$msg) = DiffProcess($LocalDirA[$i],$LocalDirB[$j]);
	goto fail  if($rc == $FAIL);

	my $filename = "FileName";
	open OUTPUT,">> $userInput{outputfile}";
	print "\n--------------------------the different of two product versions-----------------------------\n";
	print OUTPUT "-----------------------------the different of two product versions------------------------------------\n";
	printf "\t%-52s 	%-15s 	\t%-15s\n",$filename,$userInput{version}[0]."\/$i",$userInput{version}[1]."\/$j";
	printf OUTPUT "\t%-52s 	%-15s 	\t%-15s\n",$filename,$userInput{version}[0]."\/$i",$userInput{version}[1]."\/$j";
	foreach $key (keys %diffResult){	    
	    if($key =~ /^.*\.html/){
			printf "%-60s \t\t%-15s    \t\t%-15s\n",$key,$diffResult{$key}[0],$diffResult{$key}[1];
			printf OUTPUT "%-60s \t\t%-15s    \t\t%-15s\n",$key,$diffResult{$key}[0],$diffResult{$key}[1];
		}
	}
	close OUTPUT;
    }
}

if ( $userInput{noprint} ) {
    $userInput{logger}->info("$msg");
}
fail:
if ( $rc == $FAIL) {
    $userInput{logger}->info("==> $userInput{scriptname}  failed");
    exit 1;
}
pass:
$userInput{logger}->info("==> $userInput{scriptname} passed");
exit (0);
1;
__END__


=head1 NAME
versionDiffInHtml.pl is used to detect the HTML change between different version,then give the list of the filename which was new added or deleted or modified 

=head1 SYNOPSIS

=over

=item B<versionDiffInHtml.pl>
[B<-help|-h>]
[B<-man>]
[B<-c> I<custom name>]
[B<-p> I<product type>]
[B<-v> I<firmware version>]
[B<-o> I<output file to save result >]
[B<-l> I<log file directory>]
[B<-i> I<insert header title(optional)>]
[B<-n> I<not to print out debug message>]


=back

=head1 OPTIONS AND ARGUMENTS

=over

=item B<-c >

Custom name

=item B<-p>

Product type

=item B<-v>
Firmware version 

=item B<-o>

Output file where the output of versionDiffInHtml.pl will be stored

=item B<-l >

Redirect stdout to the /path/versionDiffInHtml.log

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-x>

Set debug to different level . ( more debug messages with higher number)

=item B<-i>
Insert text file at the beginning of the text file 

=item B<-n>
Suppress the debug message 


=back


=head1 EXAMPLES

=over

1. The following command is used to detect the HTML change between different version,and save the result to $outputfile
         perl versionDiffInHtml.pl -c $CustomName -p $ProductType -v baseVersion -v diffVresion -o $outputfile [-l $logdir]

=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut
