#!/usr/bin/expect

################################################
#
#   Description: 
#	The script is for configure rip v1 on WAN PC
#   Author: Aleon
#   Date: 11/18.2009
#
################################################

if {$argc <= 1 } {
	puts "ERR: Missing arguments"
	exit 0
} elseif { $argc >= 5 } {
	puts "ERR: Invalid arguments -- count= $argc args= \"$argv\""
	exit 0
} else {
	set subNet [lindex $argv 1]
	set ver [lindex $argv 3]
}

spawn telnet 127.0.0.1 2602

    after 100
    set channel_id $spawn_id;

    # logon router
    expect "assword: "
    send -i $channel_id "actiontec\r"

    # enable config mode
    expect "Router> "
    send -i $channel_id "enable\r"

    expect "assword: "
    send -i $channel_id "actiontec\r"

    # enter configure terminal
    expect "#"
    send -i $channel_id "configure terminal\r"

    # configure rip protocol on router
    expect "#"
    send -i $channel_id "router rip\r"

    # advertise the network for route interface
    expect "#"
    send -i $channel_id "network $subNet\r"
    expect "#"

    send -i $channel_id "network 192.168.20.0/24\r"
    
    expect "#"
    send -i $channel_id "network 192.168.30.0/24\r"
    
    expect "#"
    send -i $channel_id "network 192.168.40.0/24\r"

    # enable rip version 1
    expect "#"
    send -i $channel_id "version $ver\r"

close $spawn_id



