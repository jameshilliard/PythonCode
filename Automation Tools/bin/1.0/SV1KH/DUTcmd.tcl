#!/usr/bin/tclsh

package require Expect;

if { $argc <= 1 } {

	puts "ERR: Missing arguments"
	exit 0
} elseif { $argc > 4 } {

	puts "ERR: Invalid arguments - count=$argc  args=\"$argv\""
	exit 0
} else {

	set IPaddress [lindex $argv 0]
	puts "address is :$IPaddress"
	set username  [lindex $argv 1]
	puts "a b c d e f g $username"
	set passwd    [lindex $argv 2]
#	puts "Passwd is : $passwd"
	set cmd      [lindex $argv 3]
#	puts "The command is : $cmd"

}
