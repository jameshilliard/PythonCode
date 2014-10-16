#----------------------------------------------------------
#   This is the parent class. All vdsl product gui classes
#   can inherit from it.
#
#
#   Version 1.0
#   Created by Hugo 02/10/2011
#----------------------------------------------------------
package Webstart;
use WWW::Selenium;
use Log::Log4perl;

sub new {
    my $that = shift;
    my $class = ref($that) || $that;
    my %parm = @_;
    my $self = {
	SELEADDR => undef,
    	DUTADDR => undef,
    	USERNAME => undef,
    	PASSWD => undef,
    	BROWSER => '*firefox',
    	s_handle => undef,
    	log_handle => undef,
    	logfiledir => undef,
    	logfile => '/conf_vdsl.log',
    	timeout => 30000,
	tab => $parm{'tab'},
	layout => $parm{'layout'},
	value => $parm{'value'},
	dumpraw => $parm{'rawhtml'},
    };
    bless($self, $class);
    return $self;
}

use Alias qw(attr);
use vars qw($SELEADDR, $DUTADDR, $USERNAME, $PASSWD, $BROWSER, $s_handle, $log_handle, $logfiledir, $logfile, $timeout, $prod, $tab, $layout, $value);

sub seleaddr {
    my $self = attr shift;
    if (@_) { $SELEADDR = shift; }
    return $SELEADDR;
}

sub dutaddr {
    my $self = attr shift;
    if (@_) { $DUTADDR = shift; }
    $DUTADDR = 'http://'.$DUTADDR;
    return $DUTADDR;
}

sub browser {
    my $self = attr shift;
    if (@_) { $BROWSER = shift; }
    return $BROWSER;
}

sub username {
    my $self = attr shift;
    if (@_) { $USERNAME = shift; }
    return $USERNAME;
}

sub passwd {
    my $self = attr shift;
    if (@_) { $PASSWD = shift; }
    return $PASSWD;
}

sub logf {
    my $self = attr shift;
    if (@_) { $logfiledir = shift; }
    if ($logfiledir eq 'null') { $logfiledir = undef; }
    return $logfiledir;
}

sub init_env {
    my $self = attr shift;
    #	----------------
    #	    init log
    #	----------------
    if ($logfiledir eq undef) {
	$logfiledir = `pwd`;
	chomp $logfiledir;
	$logfiledir = $logfiledir.$logfile;
    }
    my $log_conf = "log4perl.category = INFO, Logfile, Screen
        log4perl.appender.Logfile = Log::Log4perl::Appender::File
        log4perl.appender.Logfile.filename = $logfiledir
        log4perl.appender.Logfile.mode = write
        log4perl.appender.Logfile.layout = Log::Log4perl::Layout::SimpleLayout
        log4perl.appender.Screen        = Log::Log4perl::Appender::Screen
        log4perl.appender.Screen.layout = Log::Log4perl::Layout::SimpleLayout";
    $log_handle = Log::Log4perl::get_logger();
    Log::Log4perl::init(\$log_conf);
    #	---------------------
    #	    init selenium
    #	---------------------
    $s_handle = WWW::Selenium->new(
    	    host => $SELEADDR,
    	    browser => $BROWSER,
    	    browser_url => $DUTADDR,
    );
    $s_handle->start;
    return $s_handle;
}

sub stop_env {
    my $self = attr shift;
    #	---------------------
    #	    stop selenium
    #	---------------------
    $s_handle->stop;
}

1;
