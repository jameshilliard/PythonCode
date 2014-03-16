#!/usr/bin/tclsh

package require Expect;

#********************************************************************
#
#  NAME: 	verifyPing.tcl
#  DATE:	04/19/2011
#  DESCRIPTION:	try to ping an ip and see if it is able to ping thru ;
#  
#  INPUT PARAMETERS:
#		IPaddress;
#  USAGE:	verifyPing.tcl 192.168.1.1
#
#  Copyright actiontec, Inc
#
# ********************************************************************

if { $argc < 1 } {

	puts "ERR: Missing arguments"
	exit 0
} elseif { $argc > 2 } {

	puts "ERR: Invalid arguments - count=$argc  args=\"$argv\""
	exit 0
} else {

	set IPaddress [lindex $argv 0]
	puts "IPaddress is :$IPaddress"
    set interface [lindex $argv 1]
	puts "interface is :$interface"
}

	puts "Start to ping $IPaddress from $interface ..."
	spawn ping -I $interface $IPaddress

	#expect $IPaddress
    	set console_id $spawn_id
	puts "the child is :$console_id"
	set timeout 30
	expect {
	
		"Destination Host Unreachable" {

			puts "it is not able to ping thru $IPaddress"
  			exit 0;

		} "64 bytes from " {
            puts "it is able to ping thru $IPaddress"
  			exit 0;

		} eof {
            puts "time out"
			exit 0;
		}
	}
		

       close -i $console_id


	
