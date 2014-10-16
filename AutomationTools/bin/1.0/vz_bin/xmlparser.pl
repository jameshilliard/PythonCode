#! /usr/bin/perl -w
# ----------------------------------------------------------
# This script parses log file generated by jacs tool
# Options:
#     -f	jacs log file
#     -o	log file
#     -p	parameter
#     -v	expect value
#
# Create by Hugo 09/16/2010
#
# Change history:
#
#
# ----------------------------------------------------------
use strict;
use warnings;
use Getopt::Long;
use FileHandle;
use Log::Log4perl;
use Pod::Usage;

my $logfiledir = `pwd`;
chomp $logfiledir;
$logfiledir = $logfiledir.'/parse_result.log';

sub get_log_fn {
  return sprintf "%s", $logfiledir;
}
my $log_conf = q/
    log4perl.category = INFO, Logfile, Screen

    log4perl.appender.Logfile = Log::Log4perl::Appender::File
    log4perl.appender.Logfile.filename = sub { return get_log_fn(); }
    log4perl.appender.Logfile.mode = write
    log4perl.appender.Logfile.layout = Log::Log4perl::Layout::SimpleLayout

    log4perl.appender.Screen        = Log::Log4perl::Appender::Screen
    log4perl.appender.Screen.layout = Log::Log4perl::Layout::SimpleLayout

/;

my $NOTDEFINED = "undefined";
my $option_h = 0;
my $option_man = 0;
my $usage = "Usage: xmlparser.pl -f <jacs output-file> -o <logfile> -p <parameter> -v <expect value>\n";
my %userInput = (
    "jacs_file"     => $NOTDEFINED,      
    "log_location"  => $NOTDEFINED,
    "param"         => $NOTDEFINED,
    "exp_value"     => $NOTDEFINED,
);
my $logger = Log::Log4perl::get_logger();
Log::Log4perl::init(\$log_conf);

my $rc = GetOptions (
    "h|help" => \$option_h,
    "man"    => \$option_man,
    "f=s"    => \$userInput{jacs_file},
    "o=s"    => \$userInput{log_location},
    "p=s"    => \$userInput{param},
    "v=s"    => \$userInput{exp_value},
);

if ($rc != 1) {
   printf ("options input error\n");
   exit 1;
}

my $flag_gpa = 'fail';
SWITCH: {
   $userInput{'exp_value'} eq 'active' && do { $userInput{'exp_value'} = 2; $flag_gpa = 'true'; last SWITCH;};
   $userInput{'exp_value'} eq 'passive' && do { $userInput{'exp_value'} = 1; $flag_gpa = 'true'; last SWITCH;};
   $userInput{'exp_value'} eq 'off' && do { $userInput{'exp_value'} = 0; $flag_gpa = 'true'; last SWITCH;};
}

if ($option_h) print $usage;
pod2usage(-verbose=>2) if ($option_man);

# ---------------- Main Begin -----------------------
open(FILE, $userInput{'jacs_file'}) || die "Fail to open file\n";
my $do_flag = 'false';

foreach my $line (<FILE>) {
  if($do_flag eq 'true') {
    $line =~ s/^\s*//;
    $line =~ s/\s*$//;
    if($flag_gpa eq 'true') {
      if($line =~ /Notification/) {
         $logger->info($line."\n\n");
      } else {
         $do_flag = 'false';
	 next;
      }
    } else {
       $logger->info($line."\n\n");
    }

    my @tabletmp = split('>', $line);
    my @table = split('<', $tabletmp[1]);

    if($table[0] eq $userInput{'exp_value'}) {
      if ($flag_gpa eq 'fail') {
          $logger->info("GPV value-$table[0] matches expect-$userInput{'exp_value'}");
      } else {
          $logger->info("GPA value-$table[0] matches expect-$userInput{'exp_value'}");
      }
      $do_flag = 'false';
      close(FILE);
      exit 0;
    } else {
      if ($flag_gpa eq 'fail') { 
          $logger->info("GPV value-$table[0] doesn't match expect-$userInput{'exp_value'}");
      } else {
          $logger->info("GPA value-$table[0] doesn't match expect-$userInput{'exp_value'}");
      }
      $do_flag = 'false';
      close(FILE);
      exit 1;
    }
  }

  if($line =~ /$userInput{'param'}/i) {
     $line =~ s/^\s*//;
     $line =~ s/\s*$//;
     $logger->info($line);
     $do_flag = 'true';
  }
}

close(FILE);
#------------------------------------ End ------------------------------------

=head1 NAME

=over

=item xmlparser.pl - is used to parse a SOAP message generated by jacs tool

=item then to verify if the corresponding value matches the expected

=back

=head1 SYNOPSIS

=over

=item B<xmlparser.pl>
[B<-help|-h>]
[B<-man>]

[B<-f> I<jacs output-file>]
[B<-o> I<Log file, give full patch and log file name>]
[B<-p> I<Parameter>]
[B<-v> I<Expect value>]

=back

=head1 OPTIONS AND ARGUMENTS

=over

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-f>

Specify a file generated by jacs

=item B<-o>

Screen output. by default, the screen output will be logged into current directory

=item B<-p>

Parameter is going to check

=item B<-v>

Expect value is going to verify 

=back

=head1 AUTHOR

=over

Please report bugs using L<http://budz/>

Hugo E<lt>shqa@actiontec.comE<gt>

=back

=cut