#
# $Id: ping.tcl,v 1.7 2007/01/11 21:49:04 wpoxon Exp $

set cvs_author  [cvs_clean "$Author: wpoxon $"]
set cvs_ID      [cvs_clean "$Id: ping.tcl,v 1.7 2007/01/11 21:49:04 wpoxon Exp $"]
set cvs_file    [cvs_clean "$RCSfile: ping.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.7 $"]
set cvs_date    [cvs_clean "$Date: 2007/01/11 21:49:04 $"]
set cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

debug $::DBLVL_CVS_VERSION "loading $cvs_file $cvs_version $cvs_date"

#
# proc ping_test {ip_addr}
#
# ip_addr -- the ip address to ping
#
# The ping_test proc sends one ping packet to the ip address passed
# to it.  It then searches the result for "1 received" to determine
# if ping succeeded.
#
# If the ping succeeds, ping_test returns 1.
# If the ping fails, ping_test returns 0.
#
#    linux:~/demo # ping -c 1 192.168.10.42
#    PING 192.168.10.42 (192.168.10.42) 56(84) bytes of data.
#    64 bytes from 192.168.10.42: icmp_seq=1 ttl=255 time=0.558 ms
#
#    --- 192.168.10.42 ping statistics ---
#    1 packets transmitted, 1 received, 0% packet loss, time 0ms
#    rtt min/avg/max/mdev = 0.558/0.558/0.558/0.000 ms
#
proc ping_test {ip_addr} {

    global tcl_platform
    global args

    if {[info exists args(--noping)]} {
        return 1
    }
    
    if { $tcl_platform(platform) == "windows" } {
	    set ping_count_arg "-n"
	    set ping_regex "Received = 1"
    } else {
	    set ping_count_arg "-c"
	    set ping_regex "1 received"
    }

    catch {exec ping $ping_count_arg 1 $ip_addr} result
    debug $::DBLVL_INFO "Ping $ip_addr result: $result"

    if { [regexp $ping_regex $result match] } {
        return 1
    } else { 
        return 0
    }
  
} ; # End proc ping_test


#
# prog ping_pause {ip_addr}
#
# ip_addr -- the ip address to ping
#
# the ping_pause proc pings the passed in ip address until it the ping
# is successful.  it will print out a single '.' for each failed attempt
# to keep the user informed that something is happening.
#
proc ping_pause {ip_addr} {

    global tcl_platform
    global args

    if {[info exists args(--noping)]} {
        return 0
    }
    
    if { $tcl_platform(platform) == "windows" } {
	    set ping_count_arg "-n"
    } else {
	    set ping_count_arg "-c"
    }

    while {[catch {exec ping $ping_count_arg 1 $ip_addr} result]} {
        puts -nonewline "."
    }
}
