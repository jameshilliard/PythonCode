package Confv2kh;

use FindBin;
use lib "$FindBin::Bin/../";
use Webstart;
require "./v2kh/v2kh.link";

@ISA = ("Webstart");
use Alias qw(attr);

sub start_work {
    my $self = attr shift;
    $s_handle->open('index.html');
    $s_handle->wait_for_page_to_load($timeout);
    $log_handle->info("Go to first page - index.html");
    my $ret = 'false';

    SWITCH: {
	$tab eq 'Home' && do { $ret = do_home(); last SWITCH; };
	$tab eq 'Status' && do { $ret = do_status();  last SWITCH; };
	$tab eq 'WirelessSetup' && do { $ret = do_wiresetup(); last SWITCH; };
	$tab eq 'Firewall' && do { $ret = do_firewall(); last SWITCH; };
	$tab eq 'AdvancedSetup' && do { $ret = do_adsetup(); last SWITCH; };
	$tab eq 'tr69' && do { $ret = do_tr69setup(); last SWITCH; };

	$log_handle->error("no $tab on the top of dut page");
	return $ret;
    }
    return $ret;
}

sub waitfor_element {
    my $link = undef;
    my $count = 10;
    if (@_) { $link = shift; }
    while (! $s_handle->is_element_present($link)) {
	sleep 2;
	if ($count-- == 0) { $log_handle->error("No $link element in webpage"); last; }
    }
}

sub split_value {
    my @arr_splitcomma;
    my @arr_splitequal;

    push @arr_splitcomma, split /,/, $value;
    foreach my $element_comma (@arr_splitcomma) {
	push @arr_splitequal, split /=/, $element_comma;
    }

    return @arr_splitequal;
}

sub click_apply {
    $s_handle->click($rlink->{Apply});
    $log_handle->info("Click on Apply button");
}

sub do_adsetup {
    my $ret = 'false';
    dut_login();
    waitfor_element($rlink->{AdvancedSetup});
    $s_handle->click($rlink->{AdvancedSetup});
    $s_handle->wait_for_page_to_load($timeout);
    $log_handle->info("Go to Advanced Setup page");
    SWITCH: {
	$layout eq 'WANIPAddressing' && do { $ret = do_wanipaddressing(); last SWITCH; };

	$log_handle->error("no $layout in this page");
	return $ret;
    }
    return $ret;
}

sub dut_login {
    if ($s_handle->is_element_present($rlink->{Username})) {
       $s_handle->type($rlink->{Username}, $USERNAME);
       $log_handle->info("Input user name $USERNAME");
    }
    if ($s_handle->is_element_present($rlink->{Password})) {
       $s_handle->type($rlink->{Password}, $PASSWD);
       $log_handle->info("Input user password $PASSWD");
    }
    if ($s_handle->is_element_present($rlink->{Login})) {
	$s_handle->click($rlink->{Login});
	$s_handle->wait_for_page_to_load($timeout);
	$log_handle->info("Click on Login button");
    }
    
}

sub do_wanipaddressing {
    waitfor_element($rlink->{WANIPAddressing});
    $s_handle->click($rlink->{WANIPAddressing});
    $s_handle->wait_for_page_to_load($timeout);
    $log_handle->info("Go to WAN IP Addressing page");
    # spit out raw html
    if ($dumpraw == 1) { $log_handle->info($s_handle->get_html_source()); return 'ture'; }
    my %hash_value = split_value();
    foreach my $element (keys (%hash_value)) {
	SWITCH: {
	    $element eq 'RFC1483TransparentBridging' && do { last SWITCH;};	    
	    $element eq 'RFC1483viaDHCP' && do { last SWITCH;};	    
	    $element eq 'RFC1483viaStaticIP' && do { last SWITCH;};	    
	    $element eq 'HostName' && do { last SWITCH;};	    
	    $element eq 'DomainName' && do { last SWITCH;};	    
	    $element eq 'MyISPdoesnotrequireausenameandpassword' && do { last SWITCH;};	    
	    $element eq 'ConfigureIGMPProxy' && do { 
		if ($hash_value{$element} eq 'Enable') {
		    $s_handle->click("id=subrf42");
		    $log_handle->info("Set Configure IGMP Proxy to Enable");
		} else {
		    $s_handle->click("id=subrf44");
		    $log_handle->info("Set Configure IGMP Proxy to Disable");
		}
		last SWITCH;};	    
    	}
    }
    click_apply();
    waitfor_element($rlink->{Apply});
    return 'true';
}

sub do_tr69 {
#start to configure here
sleep 1;

}

sub do_tr69setup {
    my $ret = 'false';
    dut_login();
    waitfor_element($rlink->{AdvancedSetup});

    $s_handle->open('tr69.html');
    $s_handle->wait_for_page_to_load($timeout);
    $log_handle->info("Go to TR69 Setup page");
    $ret = do_tr69();
    return $ret;


}

1;
