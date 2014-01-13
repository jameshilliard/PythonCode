#!/usr/bin/tclsh

package require Expect;

#********************************************************************
#
#  NAME: 	verifyFTP.tcl
#  DATE:	04/26/2011
#  DESCRIPTION:	try to FTP an ip and see if it is successful ;
#  
#  INPUT PARAMETERS:
#		IPaddress;
#  USAGE:	verifyFTP.tcl 192.168.1.1 eth1 actiontec:actiontec 
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

	set IPaddress [lindex $argv 0]
	puts "IPaddress is :$IPaddress"
    set interface [lindex $argv 1]
	puts "interface is :$interface"
    set userpasswd [lindex $argv 2]
    puts "interface is :$userpasswd"
}

	puts "Start to FTP $IPaddress from $interface ..."
	spawn curl ftp://$IPaddress --user $userpasswd --connect-timeout 9
    #spawn curl ftp://$IPaddress --user $userpasswd --interface $interface --connect-timeout 9
	#expect $IPaddress
    	set console_id $spawn_id
	puts "the child is :$console_id"
	set timeout 30
	expect {
	
		"couldn't connect to host" {

			puts " it is not able to FTP thru $IPaddress"
            puts "Blocked"
  			exit 0;

		} 
        "drwxr" {
            puts " it is able to FTP thru $IPaddress"
            puts "Success"
  			exit 0;

		}
        "timed out" {
            puts " timed out!"
            puts "Blocked"
            exit 0;
        }
       else {
        puts "ok"
   } 
        eof {
			exit 0;
		}
	}
		

       close -i $console_id


	
