#!/usr/lib/php-pcntl/bin/php -q
<?php
#
#   $Id: pptpconfig.php,v 1.12 2006/08/21 06:19:12 quozl Exp $
#
#   pptpconfig.php, PPTP configuration and management GUI
#   Copyright (C) 2002-2006  James Cameron (quozl@us.netrek.org)
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

# our program name
$me = 'pptpconfig';
$id = "
# $Id: pptpconfig.php,v 1.12 2006/08/21 06:19:12 quozl Exp $
";

# load the php-gtk functions
dl("php_gtk.so");

# paths and files

# root path, change to ./ for non-root testing
if (!defined('PATH_ROOT'))
    define('PATH_ROOT', '/');

# where pppd places linkname pid files
if (!defined('PATH_RUN'))
    define('PATH_RUN', PATH_ROOT.'var/run/');

# our program's configuration file directory
if (!defined('PATH_OURS'))
    define('PATH_OURS', PATH_ROOT.'etc/'.$me.'/');

# our program's XML file directory
if (!defined('PATH_LIB'))
    define('PATH_LIB', PATH_ROOT.'usr/lib/'.$me.'/');

# silently try to create our configuration file directory
if (!is_dir(PATH_OURS)) {
    @mkdir(PATH_OURS, 0750);
}

# directory in which data is to be put
if (!defined('FILE_TUNNELS'))
    define('FILE_TUNNELS', PATH_OURS.'tunnels');

# file for locking access to tunnels file
if (!defined('FILE_LOCK'))
    define('FILE_LOCK', PATH_OURS.'lock');

# file to use for new file before renaming to FILE_TUNNELS
if (!defined('FILE_NEW'))
    define('FILE_NEW', PATH_OURS.'new');

# place where pppd keeps stuff
if (!defined('PATH_PPP'))
    define('PATH_PPP', PATH_ROOT.'etc/ppp/');

if (!defined('PATH_PEERS'))
    define('PATH_PEERS', PATH_PPP.'peers/');

if (!defined('FILE_CHAP_SECRETS'))
    define('FILE_CHAP_SECRETS', PATH_PPP.'chap-secrets');

if (!defined('FILE_CHAP_SECRETS'))
    define('FILE_CHAP_SECRETS', PATH_PPP.'pap-secrets');

# signal handler
function null($signo) {
}

# catch SIGINT ourselves, otherwise when we kill() pppd we get it too
# note: php must have been configured with "configure --enable-pcntl"
if (!defined('SIGINT')) {
    echo "pptpconfig: this PHP is not built with configure --enable-pcntl\n";
    echo "pptpconfig: stopping a tunnel may result in application exit\n";
    # also dies in pcntl_wifexited() call on tunnel start
} else {
    pcntl_signal(SIGINT, 'null');
}

# create a new session process group to prevent pppd
# process group kill from going beyond us
posix_setsid();

# define text highlight colours
$colours['no'] = &new GdkColor(0, 0, 0);
$colours['me'] = &new GdkColor(32768, 0, 32768);
$colours['tx'] = &new GdkColor(0, 32768, 32768);
$colours['rx'] = &new GdkColor(32768, 32768, 0);
$colours['uh'] = &new GdkColor(32768, 0, 0);
$colours['ok'] = &new GdkColor(0, 32768, 0);

$colours['red'] = &new GdkColor(65535, 32768, 32768);
$colours['green'] = &new GdkColor(32768, 65535, 32768);
$colours['blue'] = &new GdkColor(32768, 32768, 65535);
$colours['red-selected'] = &new GdkColor(0x9c9c, 0, 0);
$colours['green-selected'] = &new GdkColor(0, 0x7070, 0);
$colours['blue-selected'] = &new GdkColor(0, 0, 0x9c9c);

# point at the glade file containing the widget tree
$xml = $me.'.xml';
if (!@is_readable($xml)) $xml = PATH_LIB.$me.'.xml';

$use_gui = TRUE;
$quiet = FALSE;

# check for the optional quiet flag
$argidx = 1;
if ($argv[$argidx]=='-q') {
    $quiet = TRUE;
    $argidx++;
}

# basic CLI - if there's nothing on the command line, proceed with the 
# GUI.  otherwise, parse the args and execute the command
if ($argv[$argidx]!='') {
    $use_gui = FALSE;

    # get the tunnel name and command
    $name = $argv[$argidx++];
    if ($argv[$argidx]=='')
        usage();
    $command = $argv[$argidx++];

    tunnels_load();

    # make sure the named tunnel has been configured
    $found = FALSE;
    foreach ($tunnels as $tunnel) {
        if ($name==$tunnel['name'])
            $found = TRUE;
    }
    if (!$found) {
        echo "couldn't find tunnel $name!\n";
        exit(1);
    }

    if ($command=='start') {
        start($name);
    } else if ($command=='stop') {
        stop($name);
    } else if ($command=='status') {
        $status = pid_state($name);
        echo "tunnel $name is $status\n";
        if ($status=='stopped')
            exit(1);
    } else {
        usage();
    }

    exit(0);
}

function usage() {
    echo "usage: $argv[0] [-q] [tunnel {start|stop|status}]\n";
    exit(1);
}

# open the main window
on_main_setup_activate(0);

# load the tunnels file
tunnels_load();

# for each tunnel loaded, put on screen, set state, and autostart
if (count($tunnels) > 0) {
    foreach ($tunnels as $tunnel) {

	# add to the list on screen
	setup_list_insert($tunnel);

	# set the current running/stopped state
	$name = $tunnel['name'];
	setup_list_set_state($name, pid_state($name));

	# if an autostart is requested, start it now
	if ($tunnel['autostart']) {
	    start($name);
	}
    }
}

# execute the GTK+ main loop
Gtk::main();

# version number we are
function id() {
    global $me, $id;
    list(, , , $revision, $date, $time) = explode(' ', trim($id));
    return $me.' '.$revision.' '.$date.' '.$time;
}

# utility functions, instantiate a window from widget tree
function open_window($name) {
  global $xml;

  $gx = &new GladeXML($xml, $name);
  $gx->signal_autoconnect();
  return $gx;
}

# utility functions, hide a window
function hide_window($widget) {
  $window = $widget->get_toplevel();
  $window->hide();
}

# utility functions, kill a window
function kill_window($widget) {
  $window = $widget->get_toplevel();
  $window->destroy();
}

# utility functions, shutdown the program
function shutdown() {
  Gtk::main_quit();
}

# mark widget insensitive, non-responsive
function insensitive($gx, $name) {
    $widget = $gx->get_widget($name);
    return $widget->set_sensitive(0);
}

# mark widget sensitive, responsive
function sensitive($gx, $name) {
    $widget = $gx->get_widget($name);
    return $widget->set_sensitive(1);
}

# widget to grab default
function has_default_on($gx, $name) {
    $widget = $gx->get_widget($name);
    return $widget->grab_default();
}

function has_default_off($gx, $name) {
    $widget = $gx->get_widget($name);
    # no apparent way to do this ;-(
}


# encode a tunnel name to filesystem and shell name
function munge($name) {
    return rawurlencode($name);
}


# functions for status bar on main window
function bar_initialise($name, $widget) {
    global $bars;

    $bars[$name]['widget'] = $widget;
    $bars[$name]['id'] = $widget->get_context_id('text');
}

function bar_show($name, $text) {
    global $bars;

    if (!isset($bars[$name])) return;
    $bars[$name]['widget']->pop($bars[$name]['id']);
    $bars[$name]['widget']->push($bars[$name]['id'], $text);
}

# tunnels database management
function tunnels_save() {
    global $tunnels;

    # obtain interlock
    if (!($lock = fopen(FILE_LOCK, 'a+'))) {
	message('tunnels save lock open fail', 'Failed to open '.FILE_LOCK.'
information entered has not been saved.');
	return 0;
    }

    if (!flock($lock, 2)) {
	message('tunnels save lock fail', 'Failed to lock '.FILE_LOCK.'
information entered has not been saved.');
	fclose($lock);
	return 0;
    }

    # open the file
    if (!($fp = fopen(FILE_NEW, 'w'))) {
	message('tunnels save open fail', 'Failed to open '.FILE_NEW.'
information entered has not been saved.');
	fclose($lock);
	return 0;
    }

    # protect the file against ordinary users (it has passwords)
    if (!chmod(FILE_NEW, 0750)) {
	message('tunnels save chmod fail', 'Failed to chmod '.FILE_NEW.'
all tunnel information entered has been lost.');
	fclose($lock);
	fclose($fp);
	unlink(FILE_NEW);
	return 0;
    }

    # write the array to the file
    if (!fwrite($fp,serialize($tunnels))) {
	message('tunnels save write fail', 'Failed to write to '.FILE_NEW."
after opening it for write
information entered has not been saved.");
	fclose($fp);
	fclose($lock);
	return 0;
    }

    # close the file 
    if (!fclose($fp)) {
	message('tunnels save close fail', 'Failed to close '.FILE_NEW."
after writing to it
information entered may not have been saved.");
	fclose($lock);
	return 0;
    }

    # rename the new file into place
    if (!rename(FILE_NEW, FILE_TUNNELS)) {
	message('tunnels save move fail', 'Failed to move '.FILE_NEW.' into place as '.FILE_TUNNELS."
changes have been lost");
	fclose($lock);
	return 0;
    }

    # release the lock and return success
    fclose($lock);
    return 1;
}

function tunnels_load() {
    global $tunnels;

    # if no file is there, no worries
    if (!@is_file(FILE_TUNNELS)) {
	return 1;
    }

    # if the file is there but is not readable, give an error
    if (!@is_readable(FILE_TUNNELS)) {
	message('tunnels load not readable', FILE_TUNNELS.' is not readable.
this program is designed to be run as root');
	return 0;
    }

    # open the file
    if (!($fp = fopen(FILE_TUNNELS, 'r'))) {
	message('tunnels load open fail', FILE_TUNNELS.' could not be opened');
	return 0;
    }

    # read the file
    $tunnels = unserialize(fread($fp, filesize(FILE_TUNNELS)));

    # close the file
    fclose($fp);

    return 1;
}

# create files from tunnel definition
function files_save_peers($tunnel) {
    global $me;

    # peers file, add file per tunnel
    $file = PATH_PEERS.munge($tunnel['name']);
    if (!$fp=fopen($file, 'w')) {
	message('peers save open fail', 'failed to create peers file '.$file);
	return 0;
    }

    $x = '';
    $x .= "# tunnel ".$tunnel['name'].", written by $me \$Revision: 1.12 $\n\n";
    $x .= "# name of tunnel, used to select lines in secrets files\n";
    $x .= "remotename ".munge($tunnel['name'])."\n\n";
    $x .= "# name of tunnel, used to name /var/run pid file\n";
    $x .= "linkname ".munge($tunnel['name'])."\n\n";
    $x .= "# name of tunnel, passed to ip-up scripts\n";
    $x .= "ipparam ".munge($tunnel['name'])."\n\n";
    $x .= "# data stream for pppd to use\n";
    $x .= "pty \"pptp ".$tunnel['server'].
	  " --nolaunchpppd ".$tunnel['pptp-options']."\"\n\n";
    $x .= "# domain and username, used to select lines in secrets files\n";
    if ($tunnel['domain'] != '') {
	$x .= "name ".$tunnel['domain']."\\\\".$tunnel['username']."\n\n";
    } else {
	$x .= "name ".$tunnel['username']."\n\n";
    }
    if ($tunnel['usepeerdns'])    { $x .= "usepeerdns\n"; }
    if ($tunnel['require-mppe'])  { $x .= "require-mppe\n"; }
    if ($tunnel['nomppe-40'])     { $x .= "nomppe-40\n"; }
    if ($tunnel['nomppe-128'])    { $x .= "nomppe-128\n"; }
    if ($tunnel['mppe-stateful']) { $x .= "mppe-stateful\n"; }
    if ($tunnel['refuse-eap'])    { $x .= "refuse-eap\n"; }
    if ($tunnel['persist'])       { $x .= "persist\n"; }
    if ($tunnel['debug'])         { $x .= "debug dump\n"; }
    $x .= "\n# do not require the server to authenticate to our client\n";
    $x .= "noauth\n\n";
    if (@is_readable('/etc/ppp/options.pptp')) {
        $x .= "# adopt defaults from the pptp-linux package\n";
	$x .= "file /etc/ppp/options.pptp\n\n";
    }
    if ($tunnel['pppd-options'] != '') {
	$x .= "# user specified pppd options\n".$tunnel['pppd-options']."\n\n";
    }
    $x .= "# end of tunnel file\n";
    if (!@fputs($fp, $x)) {
	message('peers save write fail', 'Failed to write to peers file '.$file."
data has been lost, tunnel may not function.");
	return 0;
    }

    if (!@fclose($fp)) {
	message('peers save close fail', 'Failed to close peers file '.$file."
data may have been lost, tunnel may not function.");
	return 0;
    }
    return 1;
}

function tunnel_to_secret($tunnel) {
    global $me;

    $head = '# +++ '.$me.' added for tunnel '.$tunnel['name'];
    $tail = '# --- '.$me.' added for tunnel '.$tunnel['name'];
    if ($tunnel['domain'] == '') {
	$body = $tunnel['username']." ".
	    munge($tunnel['name'])." ".$tunnel['password']." *";
    } else {
	$body = $tunnel['domain']."\\\\".$tunnel['username']." ".
	    munge($tunnel['name'])." ".$tunnel['password']." *";
    }

    return "\n".$head."\n".$body."\n".$tail."\n";
}

# remove a secret from a secrets file
function secret_elide($tunnel, $text) {
    global $me;

    $pattern = "# \+\+\+ ".ereg_replace("-", "\-", $me)." added for tunnel ".$tunnel['name'].
	"\n\S*\s\S*\s\S*\s\S*\n".
	    "# \-\-\- ".ereg_replace("-", "\-", $me)." added for tunnel ".$tunnel['name']."\n";
    $new = preg_replace("/$pattern\n/","",$text);
    $new = preg_replace("/$pattern/","",$new);
    return $new;
}

function files_save_secrets_name($file) {
    return PATH_PPP.$file;
}

function secrets_load($file) {
    $name = files_save_secrets_name($file);

    if (@is_dir($name)) {
	message('secrets load not directory', "Unable to open secrets file for read
$name is unexpectedly a directory.");
	return 0;
    }

    if (@is_link($name)) {
	message('secrets load not file', "Unable to open secrets file for read
$name is unexpectedly a link.");
	return 0;
    }

    # if no file is there, no worries
    if (@is_file($name)) {
	
	# if the file is there but is not readable, give an error
	if (!@is_readable($name)) {
	message('secrets load not readable', "Unable to open secrets file for read
$name is not readable
Are you running as root?");
	    return 0;
	}
	
	# open the file
	if (!($fp = fopen($name, 'r'))) {
	message('secrets load open fail', "Unable to open secrets file for read
$name");
	    return 0;
	}
	
	# read the file
	$text = fread($fp, filesize($name));
	
	# close the file
	fclose($fp);
    } else {
	# file not there, initialise text
	$text = "# Secrets for authentication
# client                server          secret          IP addresses
";
    }
    return $text;
}

function secrets_save($file, $text) {
    $name = files_save_secrets_name($file);

    if (!($fp = fopen($name, 'w'))) {
	message('secrets save open fail',
		"Unable to open secrets file for write
$name");
	return 0;
    }
    
    if (!fwrite($fp, $text)) {
	message('secrets save write fail', "Unable to write to secrets file after opening it.
$name

Warning: you have lost the contents of that file, 
which may have included passwords for
dial-up connections or incoming tunnels");
	fclose($fp);
	return 0;
    }

    if (!fclose($fp)) {
	message('secrets save close fail', "Unable to close secrets file after writing to it.
$name

Warning: you may have lost the contents of that file, 
which may have included passwords for
dial-up connections or incoming tunnels");
	return 0;
    }

    return 1;
}

function files_save_secrets($tunnel, $file) {
    $text = secrets_load($file);
    if ($text === 0) return 0;

    $text = secret_elide($tunnel, $text);
    $text .= tunnel_to_secret($tunnel);

    return secrets_save($file, $text);
}

function files_save($tunnel) {
    if (!files_save_peers($tunnel)) return 0;
    if (!files_save_secrets($tunnel, "chap-secrets")) return 0;
    if (!files_save_secrets($tunnel, "pap-secrets")) return 0;
    return 1;
}

function files_remove_secrets($tunnel, $file) {
    $text = secrets_load($file);
    if ($text === 0) return 0;

    $text = secret_elide($tunnel, $text);

    return secrets_save($file, $text);
}

function files_remove($tunnel) {
    $name = PATH_PEERS.munge($tunnel['name']);
    if (!unlink($name)) {
	message('files remove', "Unable to remove peers file for tunnel
$name.");
	return 0;
    }

    if (!files_remove_secrets($tunnel, "chap-secrets")) return 0;
    if (!files_remove_secrets($tunnel, "pap-secrets")) return 0;

    return 1;
}

function on_main_setup_activate($widget) {
    global $gx;
    if (!isset($gx['setup'])) {
	$gx['setup'] = open_window('pptpconfig-setup');
	setup_initialise();

	# grab a context id for the status bar
	bar_initialise('setup', $gx['setup']->get_widget('statusbar'));
	bar_show('setup', 'Welcome to '.id());

	# disable buttons that depend on context to be enabled
	insensitive($gx['setup'], 'update');
	insensitive($gx['setup'], 'delete');
	insensitive($gx['setup'], 'start');
	insensitive($gx['setup'], 'stop');

	# enable column auto sizing
	$clist = $gx['setup']->get_widget('tunnels');
	$clist->set_column_auto_resize(0, TRUE);
	$clist->set_column_auto_resize(1, TRUE);
	$clist->set_column_auto_resize(2, TRUE);
	$clist->set_column_auto_resize(3, TRUE);

	# enable table sort by user, click a column heading to sort
	# todo: reimplement.  it is currently disabled because row
	# numbers are changed by sort, invalidating $rows[] array
	# $clist->connect('click_column', 'clist_click_column');
	# $clist->set_reorderable(TRUE);

	# disable buttons not implemented

	# iconify depends on support in GTK+ 1.3 or later
	$iconify = $gx['setup']->get_widget('iconify');
	$iconify->hide();
    }
}

# tunnel table sort by user
function clist_click_column($clist, $column) {
    # toggle the sort type on each click
    if ($clist->sort_type == GTK_SORT_ASCENDING)
	$clist->set_sort_type(GTK_SORT_DESCENDING);
    else
	$clist->set_sort_type(GTK_SORT_ASCENDING);
    # choose sort column and perform sort
    $clist->set_sort_column($column);
    $clist->sort();
    # todo: rebuild $rows[]
}

# window pptpconfig-setup
function setup_initialise() {
    global $setup;

    $setup =
	array(
	      # text entry fields setup notebook
	      'texts' => array('name', 'server', 'domain', 'username',
			       'password', 'pppd-options', 'pptp-options',
			       'resolv', 'dns-options'),
	      # radio buttons on setup notebook
	      'radios' => array('routing' => array('routing_interface_only',
						   'routing_client_to_lan', 
						   'routing_all_to_tunnel',
						   'routing_lan_to_lan')),
	      # checkboxes on setup notebook
	      'checks' => array('usepeerdns', 'require-mppe',
				'nomppe-40', 'nomppe-128', 'refuse-eap',
				'mppe-stateful', 'autostart', 'iconify',
				'persist', 'debug'),
	      # referenced subwindows, named data on main window
	      'refs' => array('client-to-lan')
	      );
}

function setup_get_text($name) {
    global $gx;
    $widget = $gx['setup']->get_widget($name);
    return $widget->get_text();
}

function setup_get_button($name) {
    global $gx;
    $widget = $gx['setup']->get_widget($name);
    return $widget->get_active();
}

# read data from the setup widgets and return a tunnel array
function setup_get() {
    global $setup, $gx;

    $texts = $setup['texts'];
    foreach ($texts as $name) $tunnel[$name] = setup_get_text($name);

    $radios = $setup['radios'];
    foreach ($radios as $key => $buttons) {
	foreach ($buttons as $name) {
	    if (setup_get_button($name))
		$tunnel[$key] = $name;
	}
    }

    $buttons = $setup['checks'];
    foreach ($buttons as $name) {
	$tunnel[$name] = setup_get_button($name);
    }

    $window = $gx['setup']->get_widget('pptpconfig-setup');
    $refs = $setup['refs'];
    foreach ($refs as $name) $tunnel[$name] = $window->get_data($name);

    return $tunnel;
}

function setup_set_text($name, $value) {
    global $gx;
    $widget = $gx['setup']->get_widget($name);
    return $widget->set_text($value);
}

function setup_set_button($name, $value) {
    global $gx;
    $widget = $gx['setup']->get_widget($name);
    return $widget->set_active($value);
}

# given a tunnel array, write it to the setup widgets 
function setup_set($tunnel) {
    global $setup, $gx;

    $texts = $setup['texts'];
    foreach ($texts as $name) setup_set_text($name, $tunnel[$name]);
    $radios = $setup['radios'];
    foreach ($radios as $key => $buttons) {
	foreach ($buttons as $name) {
	    if ($tunnel[$key] == $name)
		setup_set_button($name, 1);
	}
    }
    
    $buttons = $setup['checks'];
    foreach ($buttons as $name) {
	setup_set_button($name, $tunnel[$name]);
    }

    $window = $gx['setup']->get_widget('pptpconfig-setup');
    $refs = $setup['refs'];
    foreach ($refs as $name) $window->set_data($name, $tunnel[$name]);
}

function setup_clear_text($name) {
    global $gx;
    $widget = $gx['setup']->get_widget($name);
    return $widget->set_text('');
}

# clear the setup widgets
function setup_clear() {
    global $setup, $gx;

    $texts = $setup['texts'];
    foreach ($texts as $name) setup_clear_text($name);
    $radios = $setup['radios'];
    foreach ($radios as $key => $buttons) {
	foreach ($buttons as $name) {
	    setup_set_button($name, 0);
	}
    }

    $buttons = $setup['checks'];
    foreach ($buttons as $name) {
	setup_set_button($name, 0);
    }

    $window = $gx['setup']->get_widget('pptpconfig-setup');
    $refs = $setup['refs'];
    foreach ($refs as $name) $window->set_data($name, '');
}

function setup_iconify() {
    global $gx;
    $window = $gx['setup']->get_widget('pptpconfig-setup');
    $window->iconify();
}

function routing($routing) {
    $array = array('routing_interface_only' => '(no routing)', 'routing_client_to_lan' => '(client to LAN)', 'routing_all_to_tunnel' => '(all to tunnel)', 'routing_lan_to_lan' => '(LAN to LAN)');
    return $array[$routing];
}

# process input from pipe attached to an asynchronous command
function command_async_reader($ignore1, $ignore2, $mine) {
    global $me, $gtk_inputs;

    $pipe = $mine['pipe'];
    $context = $mine['context'];

    $line = fgets($pipe, 1024);
    if ($line === false) { 
        gtk::input_remove($gtk_inputs[$pipe]);
	$status = pclose($pipe);
        if ($status != 0) {
            scribe($context, $me.": command failed, exit code $status\n");
        }
        return FALSE;
    }
    scribe($context, $line);

    return TRUE;
}

# issue a command to a subshell to complete asynchronously
function command_async($context, $command) {
    global $gtk_inputs;

    scribe($context, $command."\n");
    $mine['context'] = $context;
    $mine['pipe'] = popen($command.' 2>&1', 'r');
    stream_set_blocking($mine['pipe'], false);
    $gtk_inputs[$mine['pipe']] = gtk::input_add($mine['pipe'], GDK_INPUT_READ, 'command_async_reader', $mine);
}

function command($context, $command) {
    global $me;

    scribe($context, $command."\n");
    $pipe = popen($command.' 2>&1', 'r');
    stream_set_blocking($pipe, true);
    while (!feof($pipe)) {
	while(Gtk::events_pending()) Gtk::main_iteration();
	$text .= fgets($pipe, 2048);
    }
    $status = pclose($pipe);
    if ($status != 0) {
	scribe($context, $text."\n");
	scribe($context, $me.": command failed, exit code $status\n");
    }
    return array('status' => $status, 'text' => $text);
}

function resolv_start($context, $interface) {
    global $tunnels, $me, $undo;

    $name = $context['name'];
    $tunnel = $tunnels[$name];

    $on = '/etc/resolv.conf';
    $sn = '/etc/resolv.conf.orig.'.munge($tunnel['name']);
    $fn = '';

    if ($tunnel['usepeerdns']) {
	$fn = '/var/run/ppp/resolv.conf';
	if (!@is_readable($fn)) $fn = '/etc/ppp/resolv.conf';
	if (!@is_readable($fn)) {
	    $fn = '';
	    scribe($context, $me.": usepeerdns was set, but /{var/run,etc}/ppp/resolv.conf was not readable\n");
	}
    } else {
	if ($tunnel['resolv'] != '') {
	    $fn = '/etc/resolv.conf.'.munge($tunnel['name']);
	    $fp = fopen($fn, 'w');
	    $dnss = split(' ', $tunnel['resolv']);
	    foreach ($dnss as $dns) {
		fwrite($fp, 'nameserver '.$dns."\n");
	    }
	    fclose($fp);
	}
    }

    if ($fn != '') {

	if ($tunnel['dns-options'] != '') {
	    $fp = fopen($fn, 'a');
	    $options = split(';', $tunnel['dns-options']);
	    foreach ($options as $option) {
		fwrite($fp, $option."\n");
	    }
	    fclose($fp);
	}

	$resolvconf = '/sbin/resolvconf';
	if (@is_executable($resolvconf)) {
	    $resolvconf_command = $resolvconf.' -a '.$interface.' < '.$fn;
	    $array = command($context, $resolvconf_command);
	    if ($array['status'] != 0) {
		scribe($context, $me.": DNS changes were not done, resolvconf failed\n");
	    } else {
		scribe($context, $me.": DNS changes made using resolvconf\n");
		$undo[] = '/sbin/resolvconf -d '.$interface;
	    }
	} else {
	    if (!@rename($on, $sn)) {
		scribe($context, $me.": failed to save $on as $sn\n");
		scribe($context, $me.": DNS changes were not done\n");
	    } else {
		if (!@rename($fn, $on)) {
		    scribe($context, $me.": failed to move $fn to $on\n");
		    scribe($context, $me.": DNS changes were not done\n");
		    rename($sn, $on);
		} else {
		    scribe($context, $me.": DNS changes made to $on\n");
		    $undo[] = 'mv '.$sn.' '.$on;
		}
	    }
	}
    }
}

function iconify_start($context, $window) {
    global $tunnels;

    $name = $context['name'];
    $tunnel = $tunnels[$name];
    
    if ($tunnel['iconify']) {
	$window->iconify();
	setup_iconify();
    }
}

function routing_start($context, $interface) {
    global $tunnels, $me, $undo;

    $name = $context['name'];
    $tunnel = $tunnels[$name];

    # add a route to the server via the interface it used to require
    $server_ip = $context['ip'];
    if ($server_ip != '') {
	$command = 'ip route replace '.$context['route'];
	$array = command($context, $command);
	if ($array['status'] != 0) $ok = 0;
	$undo[] = ereg_replace('route replace', 'route del', $command);
    }

    # if interface only routing is requested, do nothing else
    # http://pptpclient.sourceforge.net/routing.phtml#client-to-server
    if ($tunnel['routing'] == 'routing_interface_only') return;

    $interface = escapeshellarg($interface);

    # add routes to each network requested
    # http://pptpclient.sourceforge.net/routing.phtml#client-to-lan
    $ok = 1;
    $networks = unserialize($tunnel['client-to-lan']);
    if (is_array($networks)) foreach ($networks as $network => $name) {
	$network = escapeshellarg($network);
	$command = 'ip route add '.$network.' dev '.$interface;
	$array = command($context, $command);
	if ($array['status'] != 0) $ok = 0;
    }
    if ($ok) scribe($context, $me.": routes added to remote networks\n");

    if ($tunnel['routing'] == 'routing_client_to_lan') return;

    # perform all to tunnel routing
    # http://pptpclient.sourceforge.net/routing.phtml#all-to-tunnel
    if ($tunnel['routing'] == 'routing_all_to_tunnel') {
	# obtain current default route
	$default = trim(`ip route list | grep default`);
	
	# restore it later
	$undo[] = 'ip route replace '.$default;
	
	# replace with default route through the tunnel
	$command = 'ip route replace default dev '.$interface;
	$array = command($context, $command);
	
	scribe($context, $me.": default route changed to use tunnel\n");
    }

    # perform lan to lan routing
    # http://pptpclient.sourceforge.net/routing.phtml#lan-to-lan
    if ($tunnel['routing'] == 'routing_lan_to_lan') {
	if (count($networks) > 0) 
	    foreach ($networks as $network => $name) {
		$network = $network;
		command($context, $command);
		$command = 'iptables --insert OUTPUT 1 --source 0.0.0.0/0.0.0.0 --destination '.$network.' --jump ACCEPT --out-interface '.$interface;
		command($context, $command);
		$command = 'iptables --insert INPUT 1 --source '.$network.' --destination 0.0.0.0/0.0.0.0 --jump ACCEPT --in-interface '.$interface;
		command($context, $command);
		$command = 'iptables --insert FORWARD 1 --source 0.0.0.0/0.0.0.0 --destination '.$network.' --jump ACCEPT --out-interface '.$interface;
		command($context, $command);
		$command = 'iptables --insert FORWARD 1 --source '.$network.' --destination 0.0.0.0/0.0.0.0 --jump ACCEPT';
		command($context, $command);
	    } # foreach ($networks as $network => $name)
	    
	$command = 'iptables --table nat --append POSTROUTING --out-interface '.$interface.' --jump MASQUERADE';
	command($context, $command);
	$command = 'iptables --append FORWARD --protocol tcp --tcp-flags SYN,RST SYN --jump TCPMSS --clamp-mss-to-pmtu';
	command($context, $command);
	
    } # ($tunnel['routing'] == 'routing_lan_to_lan')
}

function undo_execute($context) {
    global $undo, $me;

    $undo_success = 1;
    scribe($context, $me.": restoring routing and DNS configuration\n");
    if (is_array($undo)) foreach ($undo as $number => $command) {
	$array = command($context, $command);
	unset($undo[$number]);
	if ($array['status'] != 0) $undo_success = 0;
    }
    if ($undo_success) {
	scribe($context, $me.": routing and DNS configuration restored\n");
    } else {
	scribe($context, $me.": routing and DNS configuration partly restored\n");
    }
    unset($undo);
}

function undo_name($name) {
    return PATH_RUN.'pptpconfig.'.$name.'.undo';
}

function undo_save($name) {
    global $undo;

    # todo: no interlock is attempted here, multiple users of gui may clash

    # open the file
    $file = undo_name($name);
    if (!($fp = fopen($file, 'w'))) {
	message('undo save open fail', 'Failed to open '.$file);
	return 0;
    }

    # write the array to the file
    if (!fwrite($fp,serialize($undo))) {
	message('undo save write fail', 'Failed to write to '.$file."
after opening it for write");
	fclose($fp);
	return 0;
    }

    # close the file 
    if (!fclose($fp)) {
	message('undo save close fail', 'Failed to close '.$file."
after writing to it");
	return 0;
    }

    return 1;
}

function undo_load($name) {
    global $undo;

    $file = undo_name($name);
    $undo = array();

    # if no file is there, no worries
    if (!@is_file($file)) {
	message('undo load not there', $file.' is not present,
though it was expected to have been written by this program earlier.');
	return 1;
    }

    # open the file
    if (!($fp = fopen($file, 'r'))) {
	message('undo load open fail', $file.' could not be opened');
	return 0;
    }

    # read the file
    $undo = unserialize(fread($fp, filesize($file)));

    # close the file
    fclose($fp);

    return 1;
}

function undo_remove($name) {
    $file = undo_name($name);
    if (!unlink($file)) {
	message('undo remove', "Unable to remove undo file $file");
	return 0;
    }
}

function details($tunnel) {
    if ($tunnel['domain'] != '') {
	$text = $tunnel['username'].'@'.$tunnel['domain'];
    } else {
	$text = $tunnel['username'];
    }
    $text .= ' '.routing($tunnel['routing']);
    return $text;
}

function setup_list_encode($tunnel) {
    global $statii;

    $status = $statii[$tunnel['name']];
    if ($status == '') $status = 'stopped';

    return array($tunnel['name'], 
		 $tunnel['server'], 
		 details($tunnel),
		 $status);
}

function setup_list_insert($tunnel) {
    global $gx, $rows;

    $clist = $gx['setup']->get_widget('tunnels');
    $row = $clist->append(setup_list_encode($tunnel));
    $key = $tunnel['name'];
    $rows[$key] = $row;
}

function setup_list_set_state($name, $state) {
    global $gx, $colours, $statii, $rows;

    if ($statii[$name] == $state) return;
    $statii[$name] = $state;
    $clist = $gx['setup']->get_widget('tunnels');
    $style = $clist->style;
    $style = $style->copy();
    if ($state == 'stopped') {
	$normal = $colours['blue'];
	$selected = $colours['blue-selected'];
    } else if ($state == 'running') {
	$normal = $colours['green'];
	$selected = $colours['green-selected'];
    } else {
	$normal = $colours['red'];
	$selected = $colours['red-selected'];
    }
    $style->base[GTK_STATE_NORMAL] = $normal;
    $style->bg[GTK_STATE_SELECTED] = $selected;
    $key = $name;
    $clist->set_text($rows[$key], 3, $state);
    $clist->set_row_style($rows[$key], $style);
}

function setup_list_replace($tunnel, $row) {
    global $gx, $rows;

    $name = $tunnel['name'];
    $clist = $gx['setup']->get_widget('tunnels');

    $key = $clist->get_text($row, 0);
    unset($rows[$key]);
    $key = $name;
    $rows[$key] = $row;

    $array = setup_list_encode($tunnel);
    $column = 0;
    foreach ($array as $value) {
	$clist->set_text($row, $column++, $value);
    }
}

function setup_list_delete($row) {
    global $gx;

    $clist = $gx['setup']->get_widget('tunnels');
    $clist->remove($row);
}



function on_setup_delete_event() {
    shutdown();
}

function on_setup_close_clicked($widget) {
    shutdown();
}

function notebook_reset() {
    global $gx;
    $notebook = $gx['setup']->get_widget('notebook');
    $notebook->set_page(0);
}

function on_setup_select_row($widget, $row) {
    global $gx, $selected, $tunnels;

    $selected['row'] = $row;
    
    $selected['name'] = $widget->get_text($row, 0);
    if ($selected['name'] == '') {
	message('on_setup_select_row inconsistency 1', "You selected a blank entry, but I should not have put one in the list.");
	return;
    }

    if (!isset($tunnels[$selected['name']])) {
	message('on_setup_select_row inconsistency 2', "You selected a tunnel but it is not in the internal tunnel array\n");
	return;
    }

    setup_set($tunnels[$selected['name']]);
    sensitive($gx['setup'], 'update');
    sensitive($gx['setup'], 'delete');
    sensitive($gx['setup'], 'start');
    sensitive($gx['setup'], 'stop');
    has_default_on($gx['setup'], 'start');
    bar_show('setup', '');
}

function on_setup_unselect_row($widget, $row) {
    global $gx, $selected;

    unset($selected);
    insensitive($gx['setup'], 'update');
    insensitive($gx['setup'], 'delete');
    insensitive($gx['setup'], 'start');
    insensitive($gx['setup'], 'stop');
    has_default_off($gx['setup'], 'start');
    setup_clear();
}

function on_setup_press_row($widget, $event) {
    global $gx;

    if ($event->button == 3) {
	list($row, $column) = $widget->get_selection_info($event->x, $event->y);
        if (is_int($row) && is_int($column)) {
	    $widget->select_row($row, $column);
	    bar_show('setup', '');
	    $gx['setup-popup'] = open_window('pptpconfig-setup-popup');
	    $menu = $gx['setup-popup']->get_widget('pptpconfig-setup-popup');
	    $menu->popup(NULL, NULL, NULL, $event->button, $event->time);
            # todo: need to destroy this on popdown
        }
    }

    if ($event->button == 1) {
	if ($event->type == GDK_2BUTTON_PRESS) {
	    on_setup_start_clicked($widget);
	}
    }
}

function on_setup_popup_start_activate($widget) {
    on_setup_start_clicked($widget);
}

function on_setup_popup_stop_activate($widget) {
    on_setup_stop_clicked($widget);
}

# show a particular stats value
function stats_show($tree, $name, $value) {
    global $stats, $colours, $stos, $styles;

    # but not if it has not changed
    if ($stats[$name] == $value) return;
    $stats[$name] = $value;

    # set the label's new value
    $widget = $tree->get_widget($name);
    $widget->set_text(sprintf('%8d', $value));

    return;
}

# update stats in the tunnel window
function stats($context) {
    global $x;

    $window = $context['window'];
    $interface = $window->get_data('interface');

    # read the linux kernel device status table
    $fp = fopen('/proc/net/dev', 'r');
    if (!$fp) {
	message('stats open fail', "Cannot open /proc/net/dev
Interface statistics will not be reported");
	return FALSE;
    }

    while (!ereg($interface, $line)) {
	$line = fgets($fp, 1024);
	if (feof($fp)) { fclose($fp); return TRUE; }
    }
    fclose($fp);

    # pull apart the line into fields, and display
    $regs = split(':|  *',$line);

    $tree = $context['tree'];
    stats_show($tree, 'bytes-in', $regs[3]);
    stats_show($tree, 'packets-in', $regs[4]);
    stats_show($tree, 'bytes-out', $regs[11]);
    stats_show($tree, 'packets-out', $regs[12]);

    return TRUE;
}


# translate a pppd exit code to text
# see man pppd, heading EXIT STATUS
function pppd_strerrno($status) {
    switch ($status) {
	case  1: return 'immediately fatal error'; 
	case  2: return 'error detected processing pppd options'; 
	case  3: return 'pppd is not setuid-root and you are not root'; 
	case  4: return 'kernel lacks support for pppd'; 
	case  5: return 'pppd terminated due to SIGINT, SIGTERM or SIGHUP signal'; 
	case  6: return 'port could not be locked'; 
	case  7: return 'port could not be opened'; 
	case  8: return 'connect script failed'; 
	case  9: return 'pptp could not be run'; 
	case 10: return 'PPP negotiation failed'; 
	case 11: return 'peer failed (or refused) to authenticate itself'; 
	case 12: return 'link terminated because it was idle'; 
	case 13: return 'link terminated because the connect time limit was reached'; 
	case 14: return 'callback was negotiated and incoming call expected'; 
	case 15: return 'link terminated because peer is not responding to echo requests'; 
	case 16: return 'link terminated by PPTP connection closure'; 
	case 17: return 'negotiation failed due to loopback'; 
	case 18: return 'initialisation script failed'; 
	case 19: return 'we failed to authenticate ourselves to the peer'; 
    }
    return 'untranslatable exit status';
}

function strsignal($signal) {
    switch ($signal) {
	case SIGHUP: return 'SIGHUP';
	case SIGINT: return 'SIGINT';
	case SIGQUIT: return 'SIGQUIT';
	case SIGILL: return 'SIGILL';
	case SIGABRT: return 'SIGABRT';
	case SIGFPE: return 'SIGFPE';
	case SIGKILL: return 'SIGKILL';
	case SIGSEGV: return 'SIGSEGV';
	case SIGPIPE: return 'SIGPIPE';
	case SIGALRM: return 'SIGALRM';
	case SIGTERM: return 'SIGTERM';
	case SIGUSR1: return 'SIGUSR1';
	case 16: return 'SIGUSR1';
	case SIGUSR2: return 'SIGUSR2';
	case 17: return 'SIGUSR2';
	case SIGCHLD: return 'SIGCHLD';
	case SIGCONT: return 'SIGCONT';
	case SIGSTOP: return 'SIGSTOP';
	case SIGTSTP: return 'SIGTSTP';
	case SIGTTIN: return 'SIGTTIN';
	case SIGTTOU: return 'SIGTTOU';
    }
    return 'signal '.$signal;
}

# colour and display messages in text widget
function scribe($context, $line) {
    global $colours, $me, $use_gui, $quiet;

    $colour = $colours['no'];
    if (ereg('^sent', $line)) $colour = $colours['tx'];
    if (ereg('^rcvd', $line)) $colour = $colours['rx'];
    if (ereg('^Using interface ppp', $line)) $colour = $colours['ok'];
    if (ereg('^Connect: ppp', $line)) $colour = $colours['ok'];
    if (ereg('succeeded', $line)) $colour = $colours['ok'];
    if (ereg('compression enabled', $line)) $colour = $colours['ok'];
    if (ereg('^local  IP address', $line)) $colour = $colours['ok'];
    if (ereg('^remote IP address', $line)) $colour = $colours['ok'];
    if (ereg('^primary   DNS address', $line)) $colour = $colours['ok'];
    if (ereg('^secondary DNS address', $line)) $colour = $colours['ok'];
    if (ereg('failed', $line)) $colour = $colours['uh'];
    if (ereg('^anon warn', $line)) $colour = $colours['uh'];
    if (ereg('^anon fatal', $line)) $colour = $colours['uh'];
    if (ereg('^'.$me, $line)) $colour = $colours['me'];

    if ($use_gui)   
        $context['text']->insert(NULL, $colour, NULL, $line);
    else if (!$quiet)
        echo $line;
}

# input handler for pppd pipe, displays what pppd says, with our comments
function reader($ignore, $ignore, $context) {
    global $me, $gtk_inputs, $use_gui, $quiet;

    $line = fgets($context['pipe'], 1024);
    if ($use_gui) {
        # in the gui, the reader is a callback that processes on line at a time
        if (!($line == false)) {
	    scribe($context, $line);
	
	    if (ereg("Using interface (ppp[0-9]*)", $line, $regs)) {
	        $timeout = gtk::timeout_add(500, 'stats', $context);
	        $window = $context['window'];
	        $window->set_data('timeout', $timeout);
	        $window->set_data('interface', $regs[1]);
	        # todo, if end of $line is not newline, add one here
	        scribe($context, "$me: monitoring interface ".$regs[1]."\n");
	    }
	
	    if (ereg('^remote IP address ([0-9.]*)', $line, $regs)) {
	        $window = $context['window'];
	        $window->set_data('remoteip', $regs[1]);
	    }

            return TRUE;
        } else {
            gtk::input_remove($gtk_inputs[$context['pipe']]);
        }
    } else {
        # in the CLI, reader should read all input right away
        while (!($line === false)) { 
	    scribe($context, $line);
	
	    if (ereg("Using interface (ppp[0-9]*)", $line, $regs)) {
                $context['interface'] = $regs[1];
	        # todo, if end of $line is not newline, add one here
	        scribe($context, "$me: monitoring interface ".$regs[1]."\n");
	    }
	
	    if (ereg('^remote IP address ([0-9.]*)', $line, $regs)) {
                $context['remoteip'] = $regs[1];
	    }
	
            $line = fgets($context['pipe'], 1024);
        }
    }

    $status = pclose($context['pipe']);

    # decode status, per "man wait"
    if (pcntl_wifexited($status)) {
	$reason = 'exit status';
	$status = pcntl_wexitstatus($status);
    }

    if (pcntl_wifsignaled($status)) {
	$reason = 'terminated by signal';
	$status = pcntl_wtermsig($status);
    }

    if (pcntl_wifstopped($status)) {
	$reason = 'stopped by signal';
	$status = pcntl_wstopsig($status);
    }

    if (tunnel_name_to_debug($context['name'])) {
	scribe($context, "# route -n (after pppd exit)\n" . `route -n`);
    }

    $diagnosis = ($status == 0) ? "started" : "failed";
    scribe($context, "$me: pppd process $reason $status ($diagnosis)\n");

    if ($use_gui) {
        $window = $context['window'];
        $window->set_data('exit', $status);
        $window->set_data('reason', $reason);
        $statusbar = $window->get_data('statusbar');
        $statusbar->pop($window->get_data('id'));
        $stop = $window->get_data('stop');
        $ping = $window->get_data('ping');
        $start = $window->get_data('start');
    }

    if ($status == 0) {
        if ($use_gui)
	    $state = $window->get_data('state');
        else
            $state = 'initialising';

	if ($state == 'stopping') {
	    $statusbar->push($window->get_data('id'), 'Stopped');
	    $window->set_data('state', 'stopped');
	    setup_list_set_state($context['name'], 'stopped');
	    scribe($context, "$me: stopped\n");
	    $stop->set_sensitive(0);
	    $ping->set_sensitive(0);
	    $start->set_sensitive(1);
	} else {
            if ($use_gui )
                $interface = $window->get_data('interface');
            else
                $interface = $context['interface'];

	    routing_start($context, $interface);
	    resolv_start($context, $interface);
	    undo_save($context['name']);
	    scribe($context, "$me: connected\n");
            if ($use_gui) {
	        $statusbar->push($window->get_data('id'), 'Connected');
	        $window->set_data('state', 'running');
	        setup_list_set_state($context['name'], 'running');
	        $ping->set_sensitive(1);
	        iconify_start($context, $window);
            }
	}
    } else {
	if ($reason == 'exit status') {
	    $text = pppd_strerrno($status);
	} else {
	    $text = strsignal($status);
	}
	scribe($context, "$me: $text\n");
        if ($use_gui) {
	    $window->set_data('state', 'stopped');
	    setup_list_set_state($context['name'], 'stopped');
	    $statusbar->push($window->get_data('id'), 'Stopped, '.$text);
	    $stop->set_sensitive(0);
	    $ping->set_sensitive(0);
	    $start->set_sensitive(1);
        } else {
            if (!$quiet)
	        echo "start failed: $text\n";
            exit(1);
        }
    }

    if (tunnel_name_to_debug($context['name'])) {
	scribe($context, "# route -n (after completion)\n" . `route -n`);
    }

    return FALSE;
}

function on_setup_start_clicked($widget) {
    global $selected;

    if ($selected['name'] == '') {
	    message('start unselected', "Cannot Start.
No tunnel is selected from the list.
Please select a tunnel and try again.");
	return;
    }

    start($selected['name']);
    bar_show('setup', '');
}

# return the pppd pid file path for a tunnel name
function pid_name($name) {
    return PATH_RUN.'ppp-'.munge($name).'.pid';
}

# return the tunnel state based on existence of pppd pid file
function pid_state($name) {
    return is_file(pid_name($name)) ? 'running' : 'stopped';
}

function set_style($gx, $name, $style) {
    $widget = $gx->get_widget($name);
    $widget->set_style($style);
}

# create a tunnel window (on start, or stop)
function tunnel_window_create($name) {
    global $gx;

    $gx[$name] = open_window('pptpconfig-tunnel');
    $window = $gx[$name]->get_widget('pptpconfig-tunnel');
    $window->set_title('pptpconfig tunnel '.$name);
    $window->set_data('name', $name);
    $window->set_data('state', 'initialising');
    setup_list_set_state($name, 'initialising');

    $text = $gx[$name]->get_widget('text');
    $style = &new GtkStyle;
    $style->font = gdk::font_load('-*-fixed-medium-r-normal--15-*-*-*-*-*-iso8859-*');
    set_style($gx[$name], 'text', $style);
    set_style($gx[$name], 'bytes-in', $style);
    set_style($gx[$name], 'bytes-out', $style);
    set_style($gx[$name], 'packets-in', $style);
    set_style($gx[$name], 'packets-out', $style);

    $statusbar = $gx[$name]->get_widget('statusbar');
    $window->set_data('id', $statusbar->get_context_id('text'));
    $window->set_data('statusbar', $statusbar);
    
    $start = $gx[$name]->get_widget('start');
    $window->set_data('start', $start);
    $start->set_data('name', $name);
    
    $stop = $gx[$name]->get_widget('stop');
    $window->set_data('stop', $stop);
    $stop->set_data('name', $name);
    
    $ping = $gx[$name]->get_widget('ping');
    $window->set_data('ping', $ping);
    $ping->set_data('name', $name);

    $copy = $gx[$name]->get_widget('tunnel_copy');
    $window->set_data('tunnel_copy', $copy);
    $copy->set_data('name', $name);
    # todo: this feature doesn't work properly yet, see on_tunnel_copy_activate
    $copy->hide();

    $save_as = $gx[$name]->get_widget('tunnel_save_as');
    $window->set_data('tunnel_save_as', $save_as);
    $save_as->set_data('name', $name);

    $close = $gx[$name]->get_widget('tunnel_close');
    $close->set_data('name', $name);

    return $window;
}

function kill_name($name) {
    $pidfile = pid_name($name);
    if (!is_file($pidfile)) {
	message('stop no pidfile', "Tunnel $name not running,
or $pidfile is missing.");
	return 0;
    }

    $fp = fopen($pidfile, 'r');
    if (!$fp) {
	message('stop fopen pidfile', "Cannot stop tunnel $name,
cannot open $pidfile for read.");
	return 0;
    }

    # read the process id from the pidfile
    $pid = trim(fgets($fp, 32));
    fclose($fp);

    if ($pid == '') {
	message('stop bad pidfile 1', "Cannot stop tunnel $name,
file $pidfile contains no text");
	return 0;
    }

    if ($pid == 0) {
	message('stop bad pidfile 2', "Cannot stop tunnel $name,
file $pidfile contains a zero pid '$pid'");
	return 0;
    }

    if ($pid == 1) {
	message('stop bad pidfile 3', "Cannot stop tunnel $name,
file $pidfile contains init's pid '$pid'");
	return 0;
    }

    # kill pppd with a SIGINT
    if (!posix_kill($pid, 2)) {
        message('stop kill', "Cannot stop tunnel $name,
kill() system call returned an error for PID '$pid'");
        return 0;
    }

    return 1;
}

# user requests stop tunnel
function stop($name) {
    global $gx, $use_gui;

    $killed = kill_name($name);
    if (!$use_gui && !$killed) {
        if (!$quiet)
            echo "stop failed\n";
        exit(1);
    }

    if ($use_gui) {
        # create per-tunnel window if not yet existing
        if (!isset($gx[$name])) {
	    $window = tunnel_window_create($name);
	    $window->set_data('state', 'running');
	    setup_list_set_state($name, 'running');
        } else {
	    # otherwise, just show the widget (may have been hidden by user)
	    $window = $gx[$name]->get_widget('pptpconfig-tunnel');
	    $window->show();
        }
    }

    # restore default route and DNS configuration
    if ($use_gui)
        $context['text'] = $gx[$name]->get_widget('text');
    undo_load($name);
    undo_execute($context);

    undo_remove($name);

    if ($use_gui) {
        $timeout = $window->get_data('timeout');
        if (is_int($timeout)) gtk::timeout_remove($window->get_data('timeout'));
        $start = $gx[$name]->get_widget('start');
        $ping = $gx[$name]->get_widget('ping');
        $stop = $gx[$name]->get_widget('stop');
        $state = $window->get_data('state');
        $statusbar = $window->get_data('statusbar');
        $statusbar->pop($window->get_data('id'));
        if ($state == 'starting') {
	    $window->set_data('state', 'stopping');
	    setup_list_set_state($name, 'stopping');
	    $statusbar->push($window->get_data('id'), 'Stopping');
	    $stop->set_sensitive(1);
	    $ping->set_sensitive(1);
	    $start->set_sensitive(0);
        }
        if ($state == 'running') {
	    $window->set_data('state', 'stopped');
	    setup_list_set_state($name, 'stopped');
	    $statusbar->push($window->get_data('id'), 'Stopped');
	    $stop->set_sensitive(0);
	    $ping->set_sensitive(0);
	    $start->set_sensitive(1);
        }
        setup_unselect_all();
    }
}

# erase security critical portions when dumping tunnel configuration
function tunnel_name_to_hidden_dump($name) {
    global $tunnels;

    $tunnel = $tunnels[$name];
    $hidden = '(hidden by pptpconfig)';
    if ($tunnel['password'] != '') $tunnel['password'] = $hidden;
    if ($tunnel['domain']   != '') $tunnel['domain']   = $hidden;
    return print_r($tunnel, true);
}

function tunnel_name_to_debug($name) {
    global $tunnels;

    $tunnel = $tunnels[$name];
    return $tunnel['debug'];
}

#sjd modified to respect the use_gui flag for CLI version
function start($name) {
    global $selected, $tunnels, $gx, $me, $gtk_inputs, $use_gui;

    # check for an existing tunnel
    $pidfile = pid_name($name);
    if (is_file($pidfile)) {
	message('start running', "Tunnel $name already running,
or $pidfile has been left.");
	return 0;
    }

    if ($use_gui) {
        # create per-tunnel window if not yet existing
        if (!isset($gx[$name])) {
	    $window = tunnel_window_create($name);
        } else {
	    # otherwise, just show the widget (may have been hidden by user)
	    $window = $gx[$name]->get_widget('pptpconfig-tunnel');
	    $window->show();
        }
    }

    # check the tunnel state
    if ($use_gui)
        $state = $window->get_data('state');
    else
        $state = 'initialising';

    # if it was stopped, change to initialising, clear the old log
    if ($state == 'stopped') {
	$state = 'initialising';
	$text = $gx[$name]->get_widget('text');
	$text->delete_text(0, -1);
    }

    # if it is now initialising, start the pppd process
    if ($state == 'initialising') {

	# build a context array
	$context = array('name' => $name);
        if ($use_gui) {
	    $text = $gx[$name]->get_widget('text');
	    $context['tree'] = $gx[$name];
	    $context['window'] = $window;
	    $context['text'] = $text;
        }

	# obtain the route to the server before pppd starts, so that
	# it can be used to add a host route after pppd has connected
	$tunnel = $tunnels[$name];
	$server_name = $tunnel['server'];
	$server_ip = @gethostbyname($server_name);
	if ($server_ip != '') {
	    $context['ip'] = $server_ip;
	    $context['route'] = trim(`ip route get $server_ip | head -1`);
	}
	
	# todo: gethostbyname() may return a different value if the
	# tunnel's host name is a round-robin DNS entry, which may
	# invalidate this route.

	# in debug mode, dump kernel version, module names, module info
	if (tunnel_name_to_debug($context['name'])) {
	    scribe($context, "$me: debug information dump begins\n");
	    scribe($context, "WARNING: security sensitive information follows\n");
	    scribe($context, id() . "\n");
	    scribe($context, "# pptp --version\n" . `pptp --version 2>&1`);
	    scribe($context, "# pppd --version\n" . `pppd --version 2>&1`);
	    scribe($context, "# uname -a\n" . `uname -a`);
	    scribe($context, "# modinfo ppp_mppe || modinfo ppp_mppe_mppc\n" . `modinfo ppp_mppe || modinfo ppp_mppe_mppc`);
	    scribe($context, "# grep mppe /proc/modules\n" . `grep mppe /proc/modules`);
	    scribe($context, tunnel_name_to_hidden_dump($context['name']));
	    scribe($context, "# route -n (before pppd)\n" . `route -n`);
	    # todo: additional configuration details 
	    # pptp-linux version (not yet supported by pptp-linux!)
	    scribe($context, "$me: debug information dump ends, starting pppd\n");
	}

	# construct the pppd command, with log output to us, detach on IP up
	$command = '/usr/sbin/pppd call '.munge($name).' logfd 1 updetach 2>&1;';
	# save the pppd exit code into a shell variable
	$command .= 'pppd_exit_code=$?;';
	# return the pppd exit code to our pclose() call
	$command .= 'exit $pppd_exit_code;';

	$context['pipe'] = popen($command.' 2>&1', 'r');
	socket_set_blocking($context['pipe'], FALSE);

	if ($use_gui) {
	    $window->set_data('state', 'starting');
	    setup_list_set_state($name, 'starting');

	    $statusbar = $window->get_data('statusbar');
	    $statusbar->pop($window->get_data('id'));
	    $statusbar->push($window->get_data('id'), 'Starting');

	    $gtk_inputs[$context['pipe']] = gtk::input_add($context['pipe'], GDK_INPUT_READ, 'reader', $context);
	    $window->set_data('pipe', $context['pipe']);

	    # allow the stop button, disallow the start button
	    $stop = $window->get_data('stop');
	    $stop->set_sensitive(1);
	
	    $ping = $window->get_data('ping');
	    $ping->set_sensitive(0);
	
	    $start = $window->get_data('start');
	    $start->set_sensitive(0);
	
	    notebook_reset();
	    setup_unselect_all();
	} else {
            reader(0, 0, $context);
	}
    } else {
	message('start already', "Cannot Start.
Tunnel is already running.");
    }
}

function ping($name) {
    global $gx;

    if (!isset($gx[$name])) {
	message('ping no widget', "Tunnel $name has been stopped.");
	return 1;
    }

    $window = $gx[$name]->get_widget('pptpconfig-tunnel');
    $remoteip = $window->get_data('remoteip');
    $context['text'] = $gx[$name]->get_widget('text');
    $array = command_async($context, 'ping -c 5 '.$remoteip);
}

function on_setup_stop_clicked($widget) {
    global $selected, $tunnels;

    stop($selected['name']);
    notebook_reset();
    bar_show('setup', '');
}

function setup_unselect_all() {
    global $gx;

    $clist = $gx['setup']->get_widget('tunnels');
    $clist->unselect_all();
}

function on_setup_add_clicked($widget) {
    global $tunnels;

    $tunnel = setup_get();
    if (!isset($tunnel['name']) || $tunnel['name'] == '') {
	message('add empty', "Cannot Add.
Server name is blank.

Please enter a server name.");
	return;
    }

    $name = $tunnel['name'];
    if (isset($tunnels[$name])) {
        message('add exists', "Cannot Add.
Server ".$name." is already in list.

Change the server name if you want to add a new entry,
or use Update to change the existing information.");
	return;
    }

    $tunnels[$name] = $tunnel;
    if (!tunnels_save()) { unset($tunnels[$name]); return; }
    if (!files_save($tunnel)) { unset($tunnels[$name]); return; }
    bar_show('setup', 'Tunnel '.$tunnel['name'].' added');
    setup_list_insert($tunnel);
    setup_list_set_state($name, pid_state($name));
    setup_clear();
    notebook_reset();
    setup_unselect_all();
}

function on_setup_update_clicked($widget) {
    global $tunnels, $selected;

    $tunnel = setup_get();

    if (!isset($tunnels[$selected['name']])) {
	message('update unselected', "Cannot Update.
No tunnel is selected.");
	return;
    }

    if ($tunnel['name'] == '') {
	message('update noname', "Cannot Update.
No tunnel name entered.
Please do not clear the tunnel name.");
	return;
    }

    if ($selected['name'] != $tunnel['name']) {
	
	if (isset($tunnels[$tunnel['name']])) {
	    message('update duplicate', "Cannot Update.
The name you have chosen is already in the list.");
	    return;
	}
	
	files_remove($selected);
	$tunnels[$tunnel['name']] = $tunnels[$selected['name']];
	unset($tunnels[$selected['name']]);
	# todo: does not adequately handle failure to save below
    }

    $name = $tunnel['name'];
    $copy = $tunnels[$name];    
    $tunnels[$name] = $tunnel;
    if (!tunnels_save()) { $tunnels[$name] = $copy; return; }
    if (!files_save($tunnel)) { $tunnels[$name] = $copy; return; }
    bar_show('setup', 'Tunnel '.$tunnel['name'].' updated');
    setup_list_replace($tunnel, $selected['row']);
    setup_clear();
    notebook_reset();
    setup_unselect_all();
}

function on_setup_delete_clicked($widget) {
    global $tunnels, $selected;

    $name = $selected['name'];
    $copy = $tunnels[$name];
    unset($tunnels[$name]);
    if (!tunnels_save()) { $tunnels[$name] = $copy; return; }
    if (!files_remove($selected)) { $tunnels[$name] = $copy; return; }
    bar_show('setup', 'Tunnel '.$name.' deleted');
    setup_list_delete($selected['row']);
    setup_clear();
    notebook_reset();
}

function setup_get_refs($name) {
    global $gx;

    $window = $gx['setup']->get_widget('pptpconfig-setup');
    return $window->get_data($name);
}

function setup_set_refs($name, $data) {
    global $gx;

    $window = $gx['setup']->get_widget('pptpconfig-setup');
    $window->set_data($name, $data);
}




# window pptpconfig-routing-client-to-lan
function on_details_client_to_lan_clicked($widget) {
    global $gx;

    $name = 'client-to-lan';
    $gx[$name] = open_window('pptpconfig-routing-client-to-lan');

    $widget = $gx[$name]->get_widget('update');
    $widget->hide();
    insensitive($gx[$name], 'delete');

    $data = setup_get_refs($name);
    $networks = unserialize($data);
    $clist = $gx[$name]->get_widget('networks');
    $clist->set_column_auto_resize(0, TRUE);
    if (is_array($networks) > 0) foreach ($networks as $network => $name) {
	$clist->append(array($network, $name));
    }
}

function on_client_to_lan_delete_event($widget) {
}

function on_client_to_lan_select_row($widget, $row) {
    global $gx;
    sensitive($gx['client-to-lan'], 'delete');
    $widget->set_data('selected-key', $widget->get_text($row, 0));
    $widget->set_data('selected-row', $row);
}

function on_client_to_lan_unselect_row($widget, $row) {
    global $gx;
    insensitive($gx['client-to-lan'], 'delete');
    $widget->set_data('selected-key', '');
    $widget->set_data('selected-row', -1);
}

function on_client_to_lan_update_clicked($widget) {
    global $gx;
    message('unimplemented', 'todo');
}

function on_client_to_lan_close_clicked($widget) {
    kill_window($widget);
}

function on_client_to_lan_add_clicked($widget) {
    global $gx;

    $name = 'client-to-lan';
    $widget = $gx[$name]->get_widget('network');
    $network = trim($widget->get_text());

    # refuse if network is blank
    if ($network == '') {
	message('network empty', "Cannot Add.
Network is blank.

Please enter a network.");
	return;
    }

    # refuse if network is bad format
    list($ip, $mask) = split('/', $network);
    if ($mask == '' || ereg('\.', $mask)) {
	message('network invalid', "Cannot Add $network.
The network format is not correct.

This program expects CIDR notation.

Example:
10.0.0.0/8 means network 10.0.0.0 with a netmask of 255.0.0.0
10.20.30.0/24 means network 10.20.30.0 with a netmask of 255.255.255.0
");
        # todo: accept netmask or CIDR notation, using a separate field, 
	return;
    }

    $widget = $gx[$name]->get_widget('name');
    $value = trim($widget->get_text());

    # add to the data stored on the setup window
    $data = setup_get_refs($name);
    $networks = unserialize($data);

    # if the network is already in the list, reject it
    if (isset($networks[$network])) {
	message('network duplicate', "Cannot Add $network.
Network is already in list.");
	return;
    }

    $networks[$network] = $value;
    setup_set_refs($name, serialize($networks));

    # add to list
    $clist = $gx[$name]->get_widget('networks');
    $clist->append(array($network, $value));

}

function on_client_to_lan_delete_clicked($widget) {
    global $gx;
    $name = 'client-to-lan';
    $clist = $gx[$name]->get_widget('networks');
    $row = $clist->get_data('selected-row');
    if ($row == -1) return;

    $key = $clist->get_data('selected-key');
    $clist->remove($row);

    # remove an array element from the data stored on the setup window
    $data = setup_get_refs($name);
    $networks = unserialize($data);
    unset($networks[$key]);
    setup_set_refs($name, serialize($networks));
}



# window pptpconfig-tunnel
function on_tunnel_close_activate($widget) {
    hide_window($widget);
}

function on_tunnel_close_clicked($widget) {
    global $gx;
    $name = $widget->get_data('name');
    $window = $gx[$name]->get_widget('pptpconfig-tunnel');
    $window->hide();
}

function on_tunnel_stop_activate($widget) {
    $name = $widget->get_data('name');
    stop($name);
}

function on_tunnel_start_clicked($widget) {
    $name = $widget->get_data('name');
    start($name);
}

function on_tunnel_ping_clicked($widget) {
    $name = $widget->get_data('name');
    ping($name);
}

function on_tunnel_delete_event($widget) {
    hide_window($widget);
    return TRUE;
}

function diagnostic_dump($name) {
    global $gx;

    $text = $gx[$name]->get_widget('text');
    return $text->get_chars(0, -1);
}

function on_tunnel_copy_activate($widget) {
    $name = $widget->get_data('name');

    $entry = &new GtkEntry();
    $entry->hide();
    $entry->set_text(diagnostic_dump($name));
    $entry->select_region(0, -1);
    $entry->copy_clipboard();
    # todo: the copy buffer appears to be limited to 2048 bytes!
    # perhaps the widget needs to be instantiated for the rest of the
    # paste to work

    # todo: release this poor widget
}

function on_tunnel_save_as_activate($widget) {
    $gx = open_window('pptpconfig-save-as');
    $fs = $gx->get_widget('pptpconfig-save-as');

    $ok = $fs->ok_button;
    $ok->connect('clicked', 'on_tunnel_save_as_ok', $fs);
    $name = $widget->get_data('name');
    $ok->set_data('name', $name);

    $cancel = $fs->cancel_button;
    $cancel->connect('clicked', 'on_tunnel_save_as_cancel', $fs);
}

function on_tunnel_save_as_ok($button, $fs) {
    $fn = $fs->get_filename();
    $name = $button->get_data('name');
    $fp = fopen($fn, 'w');
    if (!$fp) {
	message('tunnel save as ok', "Cannot write to file $fn");
	return;
    }
    if (!fwrite($fp, diagnostic_dump($name))) {
	message('tunnel save as write', "Failed to write to $fn after opening it for write
information has not been saved.");
	fclose($fp);
	return;
    }
    if (!fclose($fp)) {
	message('tunnel save as write', "Failed to close $fn after writing
information may not have been saved.");
	fclose($fp);
	return;
    }
    $window = $button->get_toplevel();
    kill_window($window);
    message("security warning", "File $fn saved.\n\nThe file may contain information that would allow an attacker to use your tunnel service rights.

Before posting this publically, consistently change:
- your username,
- your authentication domain name,
- your server name or IP addresses, and
- your IP addresses (shown in routing table dumps).");
}

function on_tunnel_save_as_cancel($button, $fs) {
    $window = $button->get_toplevel();
    kill_window($window);
}

# window pptpconfig-message 
function message($title, $text) {
  global $use_gui, $quiet;
  if ($use_gui) {
    $gx = open_window('pptpconfig-message');
    # todo: when window opens, text is blank, when we change text below
    # the window enlarges, try (a) setting text before title, (b)
    # creating entire widget window inline rather than use glade
    # definition.
    $window = $gx->get_widget('pptpconfig-message');
    $window->set_title('pptpconfig '.$title);
    $label = $gx->get_widget('message_label');
    $label->set_text($text);
    $ok = $gx->get_widget('message_ok');
    $ok->hide();
  } else if (!$quiet) {
    echo "$title\n";
    echo "    $text\n";
    echo "\n";
  }
}

function on_message_ok_clicked($widget) {
  kill_window($widget);
}

function on_message_close_clicked($widget) {
  kill_window($widget);
}

function on_message_delete_event() {}

?>
