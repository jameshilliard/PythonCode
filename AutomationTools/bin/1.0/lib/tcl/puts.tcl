#
# proc puts
#
# functions necessary to aid in the writing of test output to both the
# console and a log file
#
# $Id: puts.tcl,v 1.3 2007/04/04 01:46:46 wpoxon Exp $
#

# move puts out of the way for use later.
rename puts ::tcl::puts


# a puts replacement. modified from a version on the TCL wiki.
proc puts args {
    set la [llength $args]
    if {$la<1 || $la>3} {
	    error "usage: puts ?-nonewline? ?channel? string"
    }
    set nl \n
    if {[lindex $args 0]=="-nonewline"} {
	    set nl ""
	    set args [lrange $args 1 end]
    }
    if {[llength $args]==1} {
	    set args [list stdout [join $args]] ;# (2)
    }
    foreach {channel s} $args break
    #set s [join $s] ;# (1) prevent braces at leading/tailing spaces
    set cmd ::tcl::puts
    if {$nl==""} {lappend cmd -nonewline}
    lappend cmd $channel $s
    catch {eval $cmd}

    # now write it to the log, creating one if necessary
    if {![info exists ::output_log_file]} {
	    if {$::tcl_platform(platform) == "windows"} {
	        set temp_dir $::env(TEMP)
	    } else {
	        set temp_dir "/tmp"
	    }

	    set ::output_log_file [file join $temp_dir vw_auto_[pid].log]
	    set access [list RDWR CREAT TRUNC]
	
    } else {
	    set access [list RDWR APPEND]
    }
    
    if {[catch {open $::output_log_file $access 0600} fp]} {
	    ::tcl::puts "Error: could not open temporary log file: $fp"
	    ::tcl::exit -1
    }
    
    catch {::tcl::puts $fp $s}

    if {[catch {close $fp} result]} {
	    ::tcl::puts "Error: could not close temporary log file: $result"
	    ::tcl::exit -1
    }
}

