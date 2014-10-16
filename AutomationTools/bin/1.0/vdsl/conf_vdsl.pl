#--------------------------------------------------------
#   To automatically configure VDSL related products
#	Options:
#		-d  DUT IP Address
#		-s  Selenium Server ip address
#		-u  DUT Login user name
#		-p  DUT Login pass word
#		-b  Browser type, firefox, iexplore
#		-tab	Page entry on the top
#		-layout	Items listed on the left column
#		-value	To set items on the page
#		-product    v2kh, v1kh, v1kh_ncs, v2kh_ncs
#		-dumpraw    dump out raw html information
#   Note: option value should be same as what you see on the page. Remember to remove blank.
#	  i.e. -value ConfigureIGMPProxy=Enable
#	       -value ConfigureIGMPProxy=Disable
#
#   Version 1.0 
#   Created by Hugo 02/10/2011
#
#--------------------------------------------------------
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;

my $usage = "Usage: -l <logdir and file> -d <dut ip address> -s <selenium server> -u <dut username> -p <dut passwd> [-tab <page tab on top of page>] [-layout <page entry item>] [-tr69] -value <ManuallyEnterIP=xxx,Web=on> -product <v1kh,v2kh,q1khi,v1kh_ncs,v2kh_ncs> [-dumpraw]\n\te.g.\n\tperl conf_vdsl.pl -d 192.168.1.254 -s 192.168.100.51 -u root -p m3di\@r00m! -tab AdvancedSetup -layout WANIPAddressing -product v2kh -value ConfigureIGMPProxy=Enable\n";
my $Nodefine = 'null';
my %userInput = (
    "log_file" => $Nodefine,
    "dut_ip" => $Nodefine,
    "selenium_ip" => $Nodefine,
    "username" => $Nodefine,
    "password" => $Nodefine,
    "browser" => $Nodefine,
    "tab" => $Nodefine,
    "value_str" => $Nodefine,
    "product" => $Nodefine,
    "dumpraw" => 0,
    "tr69" => 0,

        );
my $option_h = 0;
my $option_man = 0;

my $rc = GetOptions (
    "h|help" => \$option_h,
    "man"    => \$option_man,
    "l=s"    => \$userInput{log_file},
    "d=s"    => \$userInput{dut_ip},
    "s=s"    => \$userInput{selenium_ip},
    "u=s"    => \$userInput{username},
    "p=s"    => \$userInput{password},
    "b=s"    => \$userInput{browser},
    "tab=s"    => \$userInput{tab},
    "layout=s"    => \$userInput{layout},
    "value=s"    => \$userInput{value_str},
    "product=s"    => \$userInput{product},
    "dumpraw"    => \$userInput{dumpraw},
    "tr69"    => \$userInput{tr69},
    );

if ($option_h) {
    print "$usage\n";
    exit 0;
}

if ($userInput{"tr69"} == 1) {
    $userInput{"tab"} = 'tr69';
    $userInput{'layout'} = 'tr69';
}

SWITCH: {
    $userInput{"dut_ip"} eq $Nodefine && do { print "missing dut ip\n$usage\n"; exit 1;};
    $userInput{"selenium_ip"} eq $Nodefine && do { print "missing selenium server ip\n$usage\n"; exit 1;};
    $userInput{"username"} eq $Nodefine && do { print "missing dut username\n$usage\n"; exit 1;};
    $userInput{"password"} eq $Nodefine && do { print "missing dut password\n$usage\n"; exit 1;};
    $userInput{"tab"} eq $Nodefine && do { print "missing page tab\n$usage\n"; exit 1;};
    $userInput{"layout"} eq $Nodefine && do { print "missing page layout\n$usage\n"; exit 1;};
    $userInput{"product"} eq $Nodefine && do { print "missing product\n$usage\n"; exit 1;};
}

my $se_obj;
SWITCH: {
    $userInput{"product"} eq 'v1kh' && do { 
	use FindBin;
	use lib "$FindBin::Bin/./";
	use v1kh::Confv1kh;
	$se_obj = Confv1kh->new('tab' => $userInput{"tab"}, 'layout' => $userInput{"layout"}, 'value' => $userInput{"value_str"}, 'rawhtml' => $userInput{"dumpraw"}); 
	last SWITCH; };

    $userInput{"product"} eq 'v1kh_ncs' && do {
	use FindBin;
        use lib "$FindBin::Bin/./";
        use v1kh_ncs::Confv1kh_ncs;
	$se_obj = Confv1kh_ncs->new('tab' => $userInput{"tab"}, 'layout' => $userInput{"layout"}, 'value' => $userInput{"value_str"}, 'rawhtml' => $userInput{"dumpraw"}); 
	last SWITCH; };

    $userInput{"product"} eq 'v2kh' && do { 
	use FindBin;
        use lib "$FindBin::Bin/./";
        use v2kh::Confv2kh;
	$se_obj = Confv2kh->new('tab' => $userInput{"tab"}, 'layout' => $userInput{"layout"}, 'value' => $userInput{"value_str"}, 'rawhtml' => $userInput{"dumpraw"}); 
	last SWITCH; };

    $userInput{"product"} eq 'v2kh_ncs' && do { 
	use FindBin;
        use lib "$FindBin::Bin/./";
        use v2kh_ncs::Confv2kh_ncs;
	$se_obj = Confv2kh_ncs->new('tab' => $userInput{"tab"}, 'layout' => $userInput{"layout"}, 'value' => $userInput{"value_str"}, 'rawhtml' => $userInput{"dumpraw"}); 
	last SWITCH; };

    $userInput{"product"} eq 'r1kh' && do { 
	use FindBin;
        use lib "$FindBin::Bin/./";
        use r1kh::Confr1kh;
	$se_obj = Confr1kh->new('tab' => $userInput{"tab"}, 'layout' => $userInput{"layout"}, 'value' => $userInput{"value_str"}, 'rawhtml' => $userInput{"dumpraw"}); 
	last SWITCH; };
}

$se_obj->seleaddr($userInput{"selenium_ip"});
$se_obj->dutaddr($userInput{"dut_ip"});
$se_obj->username($userInput{"username"});
$se_obj->passwd($userInput{"password"});
$se_obj->logf($userInput{"log_file"});

$se_obj->init_env();
if ($se_obj->start_work() eq 'false') {
    $se_obj->stop_env();
    exit 1;
}

$se_obj->stop_env();
exit 0;



