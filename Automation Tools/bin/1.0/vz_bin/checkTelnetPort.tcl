#!/usr/bin/tclsh

package require Expect;

#********************************************************************
#
#  NAME: 	checkTelnet.tcl
#  DATE:	07/15/2009
#  DESCRIPTION:	Auto execute the operation of telnet to 
#		verify the function of telnet ;
#  
#  INPUT PARAMETERS:
#		IPaddress, username, password, port;
#  USAGE:	checkTelnet.tcl 192.168.1.1 admin admin1 23
#
#  Copyright actiontec, Inc
#
# ********************************************************************

if { $argc <= 1 } {

	puts "ERR: Missing arguments"
	exit 0
} elseif { $argc > 4 } {

	puts "ERR: Invalid arguments - count=$argc  args=\"$argv\""
	exit 0
} else {

	set IPaddress [lindex $argv 0]
	puts "IPaddress is :$IPaddress"
	set username  [lindex $argv 1]
	puts "Username is : $username"
	set passwd    [lindex $argv 2]
	puts "Passwd is : $passwd"
	set port      [lindex $argv 3]
	puts "The port is : $port"

}

	puts "Start to telnet $IPaddress ..."
	spawn telnet $IPaddress $port

	#expect $IPaddress
    	set console_id $spawn_id
	puts "the child is :$console_id"
	set timeout 10
	expect {
	
		"Connection refused" {

			puts "The port was blocked or Not exit, can NOT access! "
  			exit 0;

		} "Username:" {

			send -i $console_id "$username\n"
        		exp_continue
      		} "Password:" {
         
			send -i $console_id "$passwd\n"
		#	exp_continue
		} "Router>" {

	      	 	send -i $console_id "\n"

		} eof {
			exit 0;
		}
	}
	expect ">" 
	send -i $console_id "system ver\n"
	
	expect ">"
	send -i $console_id "exit\n"
		

    puts "exit telnet ."
    close -i $console_id


	
