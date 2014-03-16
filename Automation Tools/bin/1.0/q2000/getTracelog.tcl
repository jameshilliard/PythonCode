#!/usr/bin/tclsh

package require Expect;

#********************************************************************
#
#  NAME: 	getTracelog.tcl
#  DATE:	04/19/2011
#  DESCRIPTION:	try to get trace route log from dut ;
#  
#  INPUT PARAMETERS:
#		IPaddress;
#  USAGE:	getTracelog.tcl 192.168.1.1
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

    set IPAddress [lindex $argv 0]
	puts "IPAddress is :$IPAddress"
	set user [lindex $argv 1]
	puts "user is :$user"
    set password [lindex $argv 2]
	puts "password is :$password"
    

}

	puts "Start to telnet.."
	spawn telnet $IPAddress

	#expect $IPaddress
    	set console_id $spawn_id
	puts "the child is :$console_id"
	set timeout 30
	expect {
	
            "Login: " {
             send -i $console_id "$user\n"
             exp_continue
		}
         "Password: " {
            send -i $console_id "$password\n"
		}

        #  "> " {
        #    send -i $console_id "sh\n"
		#}
        #  "# " {
            #puts "put in cmd"
            #send -i $console_id "cat /var/trace.log\n"
		#}
        
        eof {
			exit 0;
		}
	}

	expect ">" 
	    send -i $console_id "sh\n"

    expect "#" 
	    send -i $console_id "cat /var/trace.log\n"

    expect "#" 
	    send -i $console_id "exit\n"

    expect ">"
	    send -i $console_id "exit\n"
        puts "exit telnet ."


       close -i $console_id


	
