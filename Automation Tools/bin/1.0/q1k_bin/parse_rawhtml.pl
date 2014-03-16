#!/usr/bin/perl -w
#------------------------------------------------------------
# This script parses HTML tables into native Perl data structures.
# In order to use the cell values in verifying test results.
#
#
#  Hugo 11/06/2009
#------------------------------------------------------------
use strict;
use warnings;
use HTML::Parser;
use Getopt::Long;
use FileHandle;
use Pod::Usage;
use Data::Dumper;
use Log::Log4perl;
use Pod::Usage;

my $NOTDEFINED = "not_defined";
my $logfiledir = `pwd`;
chomp $logfiledir;
$logfiledir = $logfiledir.'/123.log';
my $usage = "Usage: parse_rawhtml.pl -file <raw html file> -o <logfile-/dir/filename>";
my %userInput = (
    "rawhtml"=>$NOTDEFINED,
    "logdir"=>$NOTDEFINED,
	);
my $option_h = 0;
my $option_man = 0;
my $rc = GetOptions (
    "h|help" => \$option_h,
    "man" => \$option_man,
    "file=s" => \$userInput{rawhtml},
    "o=s" => \$userInput{logdir},
	);

if ( $rc != 1) {
   printf ("option error\n");
   exit 1;
} 
pod2usage(1) if ( $option_h );
pod2usage(-verbose=>2) if ( $option_man );

if ( !( $userInput{logdir} =~ /$NOTDEFINED/i ) ) {
  $logfiledir = $userInput{logdir};
}

undef $/;
open (FILEDATA, $userInput{"rawhtml"})||die("cannot open the file\n$usage\n\n"); 
my $data = <FILEDATA>;

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
my $state = '';
my @table = ();  ## @table = ( [foo,bar], [baz,blech] );
my @row   = ();  ## ("foo", "bar")
my $cell  = '';  ## "foo"
my $p = HTML::Parser->new( api_version => 3 );

$p->handler( start => sub {
    my $tag = shift;

    $state = 'TABLE' if $tag eq 'table';
    $state = 'TR'    if $tag eq 'tr';

    if( $state eq 'TD' ) {
        $cell .= shift if $tag ne 'img';
    }

    $state = 'TD'    if $tag eq 'td';

}, "tagname,text" );

$p->handler( default => sub {
    $cell .= shift if $state eq 'TD';
}, "text" );

$p->handler( end => sub {
    my $tag = shift;

    if( $tag eq 'td' ) {
        $state = 'TR';
        push @row, '['.$cell.']'.' ' if $cell ne '';

        $cell = '';
    }

    if( $tag eq 'tr' ) {
        $state = 'TABLE';
        push @table, [@row];

        @row = ();
    }

    $state = ''      if $tag eq 'table';

}, "tagname" );

#-------------------------- Begin -----------------------------
## get the HTML table  
#undef $/;
#open (FILEDATA, $userInput{"rawhtml"})||die("cannot open the file\n$usage\n\n"); 
#my $data = <FILEDATA>;
my $logger = Log::Log4perl::get_logger();

Log::Log4perl::init( \$log_conf );
$p->parse($data);

#print Dumper(\@table);
foreach my $row_content ( @table ) {
 $logger->info(@$row_content);
}

close(FILEDATA);
exit;

#-------------------------- End -----------------------------

=head1 NAME

=over

=item parse_rawhtml.pl is used to parse a raw html format file

=item It would output all 'tr' contents 

=back

=head1 SYNOPSIS

=over

=item B<parse_rawhtml.pl>
[B<-help|-h>]
[B<-man>]

[B<-file> I<raw html file>]
[B<-o> I<log file, give full patch and log file name>]


=back

=head1 OPTIONS AND ARGUMENTS

=over

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print a man page and exit.

=item B<-file>

Specify a raw html file

=item B<-o>

Screen output. by default, the screen output will be logged into current directory 

=back

=head1 AUTHOR

=over

Please report bugs using L<http://budz/> 

Hugo E<lt>xgong@actiontec.comE<gt>

=back

=cut
