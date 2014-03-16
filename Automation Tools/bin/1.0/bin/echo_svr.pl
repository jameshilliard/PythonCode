#! c:/perl/bin/perl.exe
# --------------------------------------------------------------------
# echo.pl
# Description: 
#        1. echo.pl and selenium-server.jar should be under the same 
#           directory. 
#        2. There is no any other java programs running in WinXP. 
#           Otherwise it would be killed rudly.
#
# Contact: shqa@actiontec.com
# 08/09/2010
# --------------------------------------------------------------------
use strict;
use warnings;
use Socket;
use IO::Handle;
use Win32::Process::List;
use Win32::Console::ANSI;
use Term::ANSIColor;
use constant ECHO_PORT => 2010;
use POSIX;
use thread;

sub handle_request_process {
  my $flag_proc = shift;
  my $sysproc = Win32::Process::List->new();
  my %proclist = $sysproc->GetProcesses();
  foreach my $p ( keys %proclist ) {
    if ( $proclist{$p} =~ /IEXPLORE.EXE/i ) {
        print color 'bold green';
        print "There is a iexplore process - $p, kill it\n";
        print color 'reset';
        kill 9, $p;
        sleep 1;
    } elsif ( $proclist{$p} eq "java.exe" and $flag_proc eq 'restart') {
        print color 'bold green';
        print "Terminate selenium server - $p\n";
        print color 'reset';
        kill 9, $p;
        sleep 2;
    } elsif ( $proclist{$p} eq "mshta.exe" ) {
        print color 'bold green';
        print "Stop Selenium Remote Control - $p\n";
        print color 'reset';
        kill 9, $p;
        sleep 1;
    } elsif ( $proclist{$p} eq "dwwin.exe" ) {
        print color 'bold green';
        print "Terminate IE error prompt window - $p\n";
        print color 'reset';
        kill 9, $p;
        sleep 1;
    }
  }
  
  print SESSION 'done'."\n";
  close SESSION;
  
  if ( $flag_proc eq 'restart' ) {
    print color 'bold green';
    print "To (re)start selenium server\n";
    print color 'reset';
    sleep 2;
    system("java -jar selenium-server.jar");
  }
  
}

sub handle_request {
  my ($flag_req) = @_; 
  my $thd = threads->new(\&handle_request_process, $flag_req);
  $thd->detach;
  return 0;
}

#-------------------------------------------------
#   Main routine starts here
#-------------------------------------------------

my $port = ECHO_PORT;
my $protocol = getprotobyname('tcp');

socket(SOCK, AF_INET, SOCK_STREAM, $protocol) or die "socket() failed: $!";
setsockopt(SOCK, SOL_SOCKET, SO_REUSEADDR, 1) or die "Cannot set SO_REUSEADDR: $!";

my $my_addr = sockaddr_in($port, INADDR_ANY);
bind(SOCK, $my_addr) or die "bind() failed: $!";
listen(SOCK, SOMAXCONN) or die "listen() failed: $!";

print color 'bold yellow';
print "Waiting for incoming connections on port $port....\n";
print color 'reset';

while (1) {

  next unless my $remote_addr = accept(SESSION, SOCK);
  my ($hisport, $hisaddr) = sockaddr_in($remote_addr);
  
  warn "Connection from";

  SESSION->autoflush(1);

  my $recv_str = <SESSION>;
  $recv_str = (scalar $recv_str);
  chomp $recv_str;

  if ( $recv_str eq 'restart' ) {
    print color 'bold yellow';
    print "client sends an instruction - $recv_str\n";
    print color 'reset';
    handle_request('restart');
  } elsif ( $recv_str eq 'clean' ) {
    print color 'bold yellow';
    print "Client sends an instruction - $recv_str\n";
    print color 'reset';
    handle_request('clean');
  } else {
    $hisaddr = inet_ntoa($hisaddr);
    print color 'bold red';
    print "What is $hisaddr talking about? - $recv_str\n";
    print color 'reset';
    print SESSION 'done'."\n";
    close SESSION;
  }
  
}


