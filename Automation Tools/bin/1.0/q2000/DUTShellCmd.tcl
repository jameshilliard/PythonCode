#!/usr/bin/tclsh

package require Expect;

#********************************************************************
#
#  NAME: 	checkDUTDate.tcl
#  DATE:	04/29/2011
#  DESCRIPTION:	Auto execute the operation of telnet and acquire the current on dut;
#  
#  INPUT PARAMETERS:
#		IPaddress, username, password,shellcmd;
#  USAGE:	checkTelnet.tcl 192.168.0.1 admin QwestM0dem ls
#
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
	set cmd      [lindex $argv 3]
	puts "The command to be executed is : $cmd"

}

	puts "Start to telnet $IPaddress ..."
	spawn telnet $IPaddress 23

	#expect $IPaddress
    	set console_id $spawn_id
	puts "the child is :$console_id"
	set timeout 10
	expect {
	
		"Connection refused" {

			puts "The port was blocked or Not exist, can NOT access! "
  			exit 0;

		} "Username:" | "Login:" {

			send -i $console_id "$username\n"
			exp_continue
      		} "Password:" {
         
			send -i $console_id "$passwd\n"
			exp_continue
		} "Router>" | ">" {
			send -i $console_id "sh\n"
            exp_continue
		} 
         "# " {
			send -i $console_id "$cmd\n"
            #exp_continue
		}
        eof {
			exit 0;
		}
	}
	
	expect "#"
	send -i $console_id "exit\n"
		

    puts "exit telnet ."
    close -i $console_id


	
