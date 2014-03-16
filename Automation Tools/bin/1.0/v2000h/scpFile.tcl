#!/usr/bin/tclsh

package require Expect;

#********************************************************************
#
#  NAME: 	scpFile.tcl
#  DATE:	04/28/2011
#  DESCRIPTION:	fetch files from remote host using scp;
#  
#  INPUT PARAMETERS:
#		ip username passwd filepath localpath
#  USAGE:	tclsh scpFile.tcl ip username passwd filepath localpath
#
#
# ********************************************************************

if { $argc < 1 } {

	puts "usage : tclsh scpFile.tcl ip username passwd filepath localpath"
	exit 0
}  else {

	set IPaddress [lindex $argv 0]
	puts "IPaddress is :$IPaddress"

    set username [lindex $argv 1]
	puts "username is :$username"

    set passwd [lindex $argv 2]
	puts "password is :$passwd"

    set filepath [lindex $argv 3]
	puts "path of file is :$filepath"

    set localpath [lindex $argv 4]
	puts "local path of file is :$localpath"
}

	spawn scp $username@$IPaddress:$filepath $localpath

    	set console_id $spawn_id
	puts "the child is :$console_id"
	set timeout 30
	expect {
	
		" password: " {
			send -i $console_id "$passwd\n"
            exp_continue
		}                
        eof {
			exit 0;
		}
	}
		

       close -i $console_id


	
