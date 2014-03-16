#

set cvs_author  [cvs_clean "$Author: manderson $"]
set cvs_ID      [cvs_clean "$Id: exec_lines.tcl,v 1.24 2007/07/02 16:11:55 manderson Exp $"]
set cvs_file    [cvs_clean "$RCSfile: exec_lines.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.24 $"]
set cvs_date    [cvs_clean "$Date: 2007/07/02 16:11:55 $"]
set cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

debug $::DBLVL_CVS_VERSION "loading $cvs_file $cvs_version $cvs_date"

# proc exec_lines cmd
#
# cmd -- the command the be executed.
#
# exec_lines is a drop-in replacement for exec but uses expect so that
# long running programs can show some status.
#
# unlike exec, a catch around the call to exec_lines is not as necessary.
#
# $Id: exec_lines.tcl,v 1.24 2007/07/02 16:11:55 manderson Exp $
#
proc exec_lines { cmd } {

    debug $::DBLVL_TRACE "exec_lines $cmd"

    set spawn "exp_spawn"
    set wait  "exp_wait"

    if {$::tcl_platform(platform) != "windows"} {
        #set stty_init "-opost"
    }

    debug $::DBLVL_INFO "spawning $cmd\n"
    if {![eval $spawn -noecho $cmd]} {
        debug $::DBLVL_ERROR "exec_lines: spawn failed for cmd $cmd\n"
        return 1
    }
    set timeout -1
    
    if {[info exists ::output_log_file]} {
        if {[catch {log_file -a $::output_log_file}]} {
            log_file
            log_file -a $::output_log_file
        }
    }
    
    expect {
        "\(A\)bort, \(R\)etry, \(I\)gnore" {
            debug $::DBLVL_ERROR "HTL error encountered.  Aborting."
            send "A\r"
            unlock_chassis "no"
            set test_aborted 1
        }
        
    }
    
    debug $::DBLVL_TRACE "waiting for $cmd\n"
    set wait_list [$wait]
    debug $::DBLVL_TRACE "wait returned $wait_list\n"
    set rc [lindex $wait_list 3]

    if {[info exists test_aborted]} {
        return 2
    } else {
        return $rc
    }
}


#
# proc unlock_chassis all
#
# all     - If "yes", will unbind all connections to the chassis.
#
# unlock_chassis uses VCL to clear any stale locks that may exist.  Useful
# for when a test has been aborted due to a ^c.
#
#
# TODO - this will always unlock all and is ignoring the all arg.
proc unlock_chassis { all } {

    debug $::DBLVL_TRACE "unlock_chassis"

    if [catch {set chassis_addr [vw_keylget ::global_config ChassisName]}] {
        if [catch {set chassis_addr [vw_keylget ::global_config CHASSIS_ADDR]}] {
            ::tcl::exit -1
        }
    }

    if [catch {chassis connect $chassis_addr} result] {
        puts "Error: Cannot connect to $chassis_addr : $result"
        return
    }

    #if { $all == "yes" } {
        if [catch {chassis setUserId 0} result] {
            puts "Error: Cannot setUserId to 0 : $result"
        }
    #}

    if [catch {port unbindAll} result] {
        puts "Error: Cannot unbindALL : $result"
    }

    if [catch {chassis disconnectAll} result] {
        puts "Error: Cannot disconnectAll : $result"
    }
}

#
# proc reset_chassis
#
# a procedure that uses VCL to connect to a chassis and reset it.
#
proc reset_chassis {} {

    debug $::DBLVL_TRACE "reset_chassis"

    set reset_time 180

    if [catch {set chassis_addr [vw_keylget ::global_config ChassisName]}] {
        if [catch {set chassis_addr [vw_keylget ::global_config CHASSIS_ADDR]}] {
            exit -1
        }
    }

    if [catch {chassis connect $chassis_addr} result] {
        puts "Error: Cannot connect to $chassis_addr : $result"
        return
    }

    if [catch {chassis reset $chassis_addr} result] {
        puts "Error: Cannot reset chassis $chassis addr : $result"
    }

    debug $::DBLVL_INFO "Waiting $reset_time seconds for chassis to reset"
    breakable_after $reset_time
}
