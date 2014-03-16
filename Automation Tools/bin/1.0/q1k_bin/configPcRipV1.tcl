#!/usr/bin/expect

################################################
#
#   Description: 
#	The script is for configure rip v1 on WAN PC
#   Author: Aleon
#   Date: 11/18.2009
#
################################################

spawn telnet 127.0.0.1 2602

    after 100
    set channel_id $spawn_id;

    # logon router
    expect "assword: "
    send -i $channel_id "aleon\r"

    # enable config mode
    expect "Router> "
    send -i $channel_id "enable\r"

    expect "assword: "
    send -i $channel_id "aleon\r"

    # enter configure terminal
    expect "#"
    send -i $channel_id "configure terminal\r"

    # configure rip protocol on router
    expect "#"
    send -i $channel_id "router rip\r"

    # advertise the network for route interface
    expect "#"
    send -i $channel_id "network 1.1.1.0/24\r"
    
    expect "#"
    send -i $channel_id "network 2.2.2.0/24\r"
    
    expect "#"
    send -i $channel_id "network 3.3.3.0/24\r"

    # enable rip version 1
    expect "#"
    send -i $channel_id "version 1\r"

close $spawn_id



