#!/usr/bin/perl -w
#---------------------------------
#Name: Joe Nguyen
#Description: 
# This script is used send result through email to request user
#
#--------------------------------
use strict;
use warnings;
use diagnostics;
use Expect;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
my $learnFn =0;
#my $logdir =$ENV{'SQAROOT'};
my $logdir ="./";
my $NOTDEFINED= "noop";
my $CLI_TMO=1;
my $CLI_PROMPT= 2;
my $CLI_ILLEGAL=3;
my $EXP_DELIMITER ="@";
my $verbose = 0;
my $FQDN="\@".$ENV{'G_FQDN'};
my $NOFUNCTION="no function";
my $NOFILE="testsuite_notfound";
my $NOATTACH="noattachment_defined";
my $BRANCH=$ENV{'BRANCH'};
$BRANCH ||= '';
my %userInput = ( "debug"=>0,
		  "logdir"=>"$logdir/logs",
		  "ftplogdir"=>"/qatest/automation/logs",
		  "from"=>"qaautomation",
		  "build"=>"qaautomation",
		  "testsuite"=>$NOFILE,
		  "to"=>$NOTDEFINED,
		  "cc"=>$NOTDEFINED,
		  "image"=>$NOTDEFINED,
		  "subject"=>"",
		  "attachment"=>$NOATTACH,
		  "ncfail"=>0,
		  "ncpass"=>0,
		  "tcfail"=>0,
		  "tcpass"=>0,
		  "fwversion"=>$NOTDEFINED,
		  "subject1"=>"AUTOTEST",
		  "xlsfile"=>$NOTDEFINED,
    );
sub getBaseName {
    my ($path,$junk)=@_;
    my @temp = split("/",$path);
    $junk = $temp[$#temp];
    return $junk;
}
#-----------------------------------------
#Construct message
#-----------------------------------------
sub constructMsg{
    my ($usrIp,$junk)=@_;
    my $to = $usrIp->{to};
    my $from = $usrIp->{from};
    my $rc ;
    my $msg;
    my $cmd;
    my $localfile = $usrIp->{logdir}."/totalRS.txt";
    my $file = $usrIp->{attachment};
    my $testsuite=$usrIp->{testsuite};
    my $cc=$NOTDEFINED;
    my @temp;
    my $build = $usrIp->{build};
    my $hname = `hostname`;
    $hname =~ s/\n//;
    my $result=" ";
    my $status = "failed";
    my @body;
    if ( $from !~ /\@/ ) {
	$from = $from.$FQDN;
    }
    if ( $to !~ /\@/ ) {
	$to = $to.$FQDN;
    }
    
    if (($usrIp->{ncfail} == 0 ) && ($usrIp->{tcfail} == 0)) {
	$status = "passed";
    }
    my $totalTC = $usrIp->{tcfail} + $usrIp->{tcpass} ;
    my $totalNTC = $usrIp->{ncfail} + $usrIp->{ncpass} ;
    my $ncfail = $usrIp->{ncfail};
    my $ncpass = $usrIp->{ncpass} ;
    my $tcfail = $usrIp->{tcfail}; 
    my $tcpass = $usrIp->{tcpass}; 
    my $xlsfile = $usrIp->{xlsfile}; 
    my $fwversion = $usrIp->{fwversion}; 
    my $buildName = getBaseName($usrIp->{build});
    if ( !( $usrIp->{cc} =~ /$NOTDEFINED/ ) ) {
	$cc = $usrIp->{cc};
#	$cc=~ s/;/\@yahoo.com;/g;
#	$cc = "-cc:".$cc;
    }
#--- Set up Email Body 
    if ( ( $usrIp->{tcfail} != 0) || ( $usrIp->{ncfail} != 0) ) {
	$result="Test Failed: Number of Testcases ($totalTC) -- Failed($tcfail)\
\t\tNumber of Non-Testcases ($totalNTC) -- Failed( $ncfail)\n";
    } else {
	$result="Test Passed: Number of Testcases ($totalTC) -- Passed( $tcpass)\
\t\tNumber of Non-Testcases ($totalNTC) -- Passed( $ncpass)\n";
    }
    if (!(-e $file )) {
	$msg = "\nError: could not found result file \<$file\>\n";
	$status = "failed";
    } else {
	open(ATTACHFN,"< $file");
	@body=<ATTACHFN>;
	$msg=join("",@body);
	close ATTACHFN;
    }
    
    $result .= "\nBuild:$build\n"."TestSuite:$testsuite\n".$msg;
#--------------- Set up Email Subject
    $msg = getBaseName($testsuite);
    my $subj1 = $usrIp->{subject1};
    my $subject="\[$subj1 from $hname\]:testsuite\[$msg\] for build $BRANCH\[$buildName--version:$fwversion\] is $status";
   
#--------------  send email
    if ($usrIp->{debug} > 4 ) {
	printf ("From: $from \nTo:$to\nCC: $cc\n");
	printf ( "Subject=$subject\n");
	printf ( "Email body =$result\n");
    }
    open(ATTACHFN,"> $localfile");
    printf ATTACHFN "$result";
    close ATTACHFN;


#    $cmd = "postie -to:$to -cc:$cc -from:$from -s:\"$subject\" ... ";
#    $cmd = "mutt -s:\"$subject\" -c:\"$cc\" $to < $localfile ";

#    $cmd = "postie -to:$to $cc -from:$from -s:\"$subject\"  -msg:\"$result\" ";
    $cmd = "mutt -s \"$subject\" -c:\"$cc\" $to < $localfile ";

    if ( $cc =~ /$NOTDEFINED/ ) {
	$cmd = "mutt -s \"$subject\"  $to < $localfile  ";
    }

#added by Martin begin
    if ( index( $xlsfile,"result.xls") >= 0 ) {
    	$cmd = "mutt -s \"$subject\" -a \"$xlsfile\" -c:\"$cc\" $to < $localfile ";
    	if ( $cc =~ /$NOTDEFINED/ ) {
		$cmd = "mutt -s \"$subject\" -a \"$xlsfile\"  $to < $localfile  ";
	    }
    }
#added by Martin end

    printf "$cmd\n";
    $msg = `$cmd `;
    $rc = 0;
=begin_1
#---------- Postie >>>
    if ($msg=~/^Sent/) {
	$rc=1;
	$msg = "Sendmail passed: ". $msg;
    }  else {
	$msg = "Sendmail failed: ". $msg;
    }
#----------- Postie <<<
=end
=cut
    printf "--$msg--";
    if ($msg !~ /[a-z]/) {
	$rc=1;
	$msg = "Sendmail passed: ". $msg;
    }  else {
	$msg = "Sendmail failed: ". $msg;
    }
    return($rc,$msg);

}
#-----------------------------------------
#parse file
#-----------------------------------------
sub parseFile {
    my ($usrIp,$cmd)=@_;
    my $rc=1;
    my $msg="Parse successfully user inputs";
    my $entry;
    my @temp;
    my @buff;
    my $value;
    my $j1;
    my $from= $usrIp->{from};
    foreach $entry ( @{$cmd} ) {
	printf ( "Entry = $entry\n") if ($usrIp->{debug} > 4 );
	$entry =~ s/\n//;
	@temp=split("=",$entry);
	$temp[0] = lc $temp[0];
	if ( $temp[0] =~ /cc/i ) {
	    next if ( !defined $temp[1] );
	    next if ( $temp[1] =~ /$NOTDEFINED/ );
	    @buff = split (";",$temp[1] );
	    $usrIp->{'cc'}="";
	    foreach $value ( @buff) {
	    printf ( "value = $value\n") if ($usrIp->{debug} > 4 );
		if ( $value =~ /\@/ ) {
		    $j1 = $value;
		} else {
		    $j1 = $value.$FQDN;
		}
		$usrIp->{'cc'} .= $j1.";";
	    }
=comment
	    if ( $usrIp->{'cc'} !~ /$NOTDEFINED/ ) {
		$usrIp->{'cc'} = $usrIp->{'cc'}.";".$temp[1].$FQDN;
	    } else {
		if ( $temp[1] =~ /\@/ ) {
		    $usrIp->{'cc'} = $temp[1];
		} else {
		    $usrIp->{'cc'} = $temp[1].$FQDN;
		}
	    }

=cut

	} else {
	    if ( defined $temp[1] ) {
		$usrIp->{$temp[0]} = $temp[1];
	    } else {
		$usrIp->{$temp[0]} = "";
	    }
	}
    }
    if (  ( $usrIp->{from} =~ /^\s*$/) ) {
	$usrIp->{from} = $from;
    }
    if ( ( $usrIp->{to} =~ /$NOTDEFINED/) ) {
	$msg= "Error: missing recipient address\n";
	$rc = 0;
    } 
    print " CC = $usrIp->{cc}\n ";
    return ($rc,$msg);
}

#************************************************************
# Main Routine
#************************************************************
MAIN:
my @junk = split( /\//, $0);
my $scriptFn = $junk[$#junk];
my @userTemp;
my ($x,$h);
my $option_h;
my $option_man = 0;
my $rc = 0;
my $msg;
my $key;
my @commands = ();

$rc = GetOptions( "x=s"=>\$userInput{debug}, 
		  "help|h"=>\$option_h, 
		  "man"=>\$option_man, 
		  "l=s"=>\$userInput{logdir},
		  "v=s"=>sub { if ( exists $commands[0] ) { push (@commands,$_[1]); } else {$commands[0]=$_[1]; } } ,
		  );


#Using pod2usage to display Help or Man
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man);
($rc,$msg) = parseFile(\%userInput,\@commands);
if ($rc == 0 ) {
    printf $msg;
    pod2usage(1);
    exit 1;
}
print ( " LOGDIR =$userInput{logdir} \n");
($rc,$msg) = constructMsg(\%userInput);
if ($rc == 0 ) {
    $rc = 1; 
} else { 
    $rc = 0 ;
}
printf "\n-- $msg\n";
exit $rc;
1;
__END__

=head1 NAME

sendemail.pl - Send result through email

=head1 SYNOPSIS

=over 12

=item B<sendemail.pl>
[B<-help|-h>]
[B<-man>]
[B<-f> I<CLI TEXT FILE>]
[B<-x > I<debug level number>]
[B<-v> I<TO=..> I<ATTACHMENT=..> I<TESTSUITE=..> I<NCPASS=..> I<NCFAIL=..> I<TCPASS=..> [-v I<FROM=..>] [-v I<BUILD=..> ]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-x>

Set debug level ( from 1 and up)

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-v>

Set the must following variables:
    - NCFAIL = number of Non testcases failed
    - NCPASS = number of Non testcases passed
    - TCFAIL = number of testcases failed
    - BUILD = build image name
    - TCPASS = number of testcases passed
    - ATTACHMENT = result file 
    - TO = to user
    - CC = carbon copy to user ( e.g:joe1;joe2;joe3;joe4...)    
    - And optional FROM = user ( by default : qaautomation@yahoo.com)

=head1 DESCRIPTION

B<sendemail.pl> is a utility to send a result from a master test hosts. 

=head1 EXAMPLES

1. The following command is used to send a result file to a request user joe
    perl sendemail.pl -v TO=jnguyen -v NCFAIL=0 -v NCPASS=1 -v TCPASS=1 -v TCPASS=0 -v ATTACHMENT=/tmp/resultfile -v BUILD=vf2113.img

=back

=head1 AUTHOR

Please report bugs using L<http://budz/>

Joe Nguyen  E<lt>joe_nguyen@yahoo.comE<gt>

=cut

