#!/usr/bin/tclsh

package require Expect;

#********************************************************************
#
#  NAME: 	verifyPing.tcl
#  DATE:	04/19/2011
#  DESCRIPTION:	try to curl an ip and see if it is able to curl thru ;
#  
#  INPUT PARAMETERS:
#		IPaddress;
#  USAGE:	verifyCurl.tcl eth2 www.google.com pc3_curl_www.google.com_via_dut_blocked.log
#
#  Copyright actiontec, Inc
#
# ********************************************************************

if { $argc < 1 } {

	puts "ERR: Missing arguments"
	exit 0
} elseif { $argc > 3 } {

	puts "ERR: Invalid arguments - count=$argc  args=\"$argv\""
	exit 0
} else {
    set interface [lindex $argv 0]
	    puts "IPaddress is :$interface"
	set website [lindex $argv 1]
	    puts "IPaddress is :$website"
    set log [lindex $argv 2]
    	puts "interface is :$log"
}

	spawn curl --interface $interface $website  --connect-timeout 30 -o $log

	#expect $IPaddress
    	set console_id $spawn_id
	puts "the child is :$console_id"
	set timeout 30
	expect {
	
		"timed out" {
			puts "!!!! "
  			exit 0;

		}   eof {
			exit 0;
		}
	}
		

       close -i $console_id
