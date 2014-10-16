#! /usr/bin/perl -w

use strict;
use Socket;
use IO::Handle;
use Getopt::Long;

my $usage = "Usage: echo_cli.pl [-d peer addr] [-p peer port<2010>] <-i message>\n";
my $NOFUNCTION = 'NODEFINED';
my %userInput = (
	"host" => $NOFUNCTION,
	"port" => $NOFUNCTION,
	"message" => 'restart',
);

my $rc = GetOptions(
	"h|help" => \$userInput{help},
	"d=s" => \$userInput{host},
	"p=i" => \$userInput{port},
	"i=s" => \$userInput{message},
);

if ($userInput{help}) {
	print "$usage\n\n";
	exit 0;
}

if ($userInput{host} eq $NOFUNCTION) {
	print "Missing peer ip address\n";
	print "$usage\n\n";
	exit 0;
}

if ($userInput{port} eq $NOFUNCTION) {
	print "Missing peer port\n";
	print "$usage\n\n";
	exit 0;
}

my $protocol = getprotobyname('tcp');
my $peer_host = inet_aton($userInput{host}) or die "$userInput{host}: unknown host";
my $peer_port = $userInput{port};

socket(SOCK, AF_INET, SOCK_STREAM, $protocol) or die "socket() failed: $!";
my $dest_addr = sockaddr_in($peer_port, $peer_host);
connect(SOCK, $dest_addr) or die "connect() failed: $!";

SOCK->autoflush(1);
print SOCK $userInput{message}."\n";

my $ret = <SOCK>;
chomp $ret;
while ( $ret ne 'done' ) { ;;} 

close SOCK;
sleep 5;
exit 0;



