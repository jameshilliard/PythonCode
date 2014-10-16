#!/usr/bin/tclsh

package require Expect;

#********************************************************************
#
#  NAME: 	CheckIperf.tcl
#  DATE:	05/04/2011
#  DESCRIPTION:	Test if the iperf is successful;
#  
#  INPUT PARAMETERS:
#		address,sshcli,target,port,remote_port,protocol,username,password;
#  USAGE:	CheckIperf.tcl 192.168.100.52 sshcli root actiontec target port remote_port protocol
#                           $0              $1    $2  $3        $4      $5   $6         $7
#
# ********************************************************************

if { $argc <= 1 } {

	puts "ERR: Missing arguments"
	exit 0
} elseif { $argc > 8 } {

	puts "ERR: Invalid arguments - count=$argc  args=\"$argv\""
	exit 0
} else {

	set address     [lindex $argv 0]
	    puts "address is :$address"
	set sshcli      [lindex $argv 1]
	    puts "sshcli is : $sshcli"
	set username    [lindex $argv 2]
	    puts "username is : $username"
	set passwd      [lindex $argv 3]
	    puts "password is : $passwd"
    set target      [lindex $argv 4]
	    puts "target ip is :$target"
	set port        [lindex $argv 5]
	    puts "local port is : $port"
	set remote      [lindex $argv 6]
	    puts "remote port is : $remote"
	set protocol    [lindex $argv 7]
	    puts "The protocol is : $protocol"

}

	puts "Start the iperf server on local side"
	spawn iperf -s -u -p $port

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


	
