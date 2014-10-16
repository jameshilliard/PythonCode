#!/usr/bin/perl  -w
#

require HTTP::Request;   
require HTTP::Response;   
require HTTP::Headers;
#require HTTP::Cookies;
require LWP;

use warnings;
use Pod::Usage;
use Getopt::Long;
use FileHandle;
use Data::Dumper;
use diagnostics;

my $rc;
my $temp;
my $NOFUNCTION="NOTDEFINED";
my $usage ="Usage: configure.pl -s <server ipaddress>  -d <log directory> -l <logger> -f <config file> -h <help>\n";
#---------------------------

my %userInput = ( "server"=>$NOFUNCTION,
		  "dir"=>".",
		  "logger"=>"configure.log",
          "configfile"=>$NOFUNCTION,
		);

# ---------------------- Begin ----------------------------- 
# Get the option and check the input.
# --------------------------------------------------- 

# Get the option
$rc = GetOptions( "h|help"=>\$userInput{help}, 
		    "s=s"=>\$userInput{"server"},  
		    "d:s"=>\$userInput{"dir"},
		    "l:s"=>\$userInput{"logger"},
            "f=s"=>\$userInput{"configfile"},
		);
		            
# If "help", print the help information
if ( $userInput{help} ) 
{
    print $usage;
    exit 0;
}

# Check server address for input parameters.
if ( $userInput{"server"} =~ /$NOFUNCTION\b/ )
{
    $temp=$userInput{"server"};
    printf ( "Error:Please provide missing server ($temp)\n$usage");
    exit 1;
}

# check node for input parameters.
if ( $userInput{"configfile"} =~ /$NOFUNCTION\b/ )
{
    $temp=$userInput{"configfile"};
    printf ( "Error: FILENAME node ($temp) is not found\n$usage");
    exit 1;
}


#---------------------------
sub init{
    $ua = LWP::UserAgent->new;
    #$cookie_jar = HTTP::Cookies->new;
    $header = new HTTP::Headers
    'User-Agent'=>'User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.4) Gecko/2008111217 Fedora/3.0.4-1.fc10 Firefox/3.0.4',
    Content_Type=>"application/x-www-form-urlencoded", 
    Accept=>"Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8";

    # set the logger name of cases.
    $logFile = $userInput{"dir"}."/".$userInput{"logger"};
    $rc = open(LOG,">".$logFile);
    if( $rc != 1 ) 
    {
	    print "\nCould not write log file, please check it again.\n";
	    exit 1;
    }
    print "${logFile}\n";
    print LOG "${logFile}\n";

    # parse config file.
    $configFile = $userInput{"configfile"};
    $rc = open(CFG,"<",$configFile);
    if( $rc != 1 ) 
    {
	    print "\nCould not open config file, please check it again.\n";
        print LOG "\nCould not open config file, please check it again.\n";
	    exit 1;
    }
    print "${configFile}\n";
    print LOG "${configFile}\n";
    while(my $line = <CFG>){
        if ( $line=~ /^#/ ) {
            next;
        }
        if ( $line=~ /^\s*$/ ) {
            next;
        }        
        push @config_cases,$line;
    }
    close (CFG);
}
#sub login{
#   my $url="http://".$userInput{"server"}."/login.cgi";
#   print "${url}\n";
#   print LOG "${url}\n";
#   $content="inputUserName=".$userInput{"username"}."&inputPassword=".$userInput{"passwd"}."&nothankyou=1";
#   print "${content}\n";
#   print LOG "${content}\n";
#   $request = HTTP::Request->new(POST=>$url,$header,$content);
#   $response = $ua->request($request);
#   $cookie_jar->extract_cookies($response);
#   $header->header('Cookie'=>$cookie_jar);
#   print "-----------LOGIN---------------\n";
#   print LOG "-----------LOGIN---------------\n";
#   print $response->content;
#   print LOG $response->content;
#   print "-----------LOGIN---------------\n";
#   print LOG "-----------LOGIN---------------\n";

##
## Enable telnet
##
sub do_cases{
    foreach (@config_cases){
        @config_code = split(/\s+/,$_);
        my $url="http://".$userInput{"server"}.$config_code[1];
        print "${url}\n";
        print LOG "${url}\n";
        $request = HTTP::Request->new($config_code[0]=>$url,$header);
        $response = $ua->request($request);
#        $cookie_jar->extract_cookies($response);
#        $header->header('Cookie'=>$cookie_jar);
        print "$_\n";
        print LOG "$_\n";
        print $response->content;
        print LOG $response->content;
        print "$_\n";
        print LOG "$_\n";
    }
}
##
### Logout.
##
#sub logout{
#    my $url="http://".$userInput{"server"}."/logout.cgi";
#    $request = HTTP::Request->new(GET=>$url,$header);
#    $response = $ua->request($request);
#    $response = $response->code;
#    if ($response == '200' ){
#i        print "disconnect successful\n";
#        print LOG "disconnect successful\n";
#    } else {
#        print "disconnect fault,please try again\n";
#        print LOG "disconnect fault,please try again\n";
#    }
#}
sub main{
#    login;
    do_cases;
#    logout;
    close(LOG);
    exit 0;
} 

##################
#

#---------------------------
&init;
&main;
#---------------------------

