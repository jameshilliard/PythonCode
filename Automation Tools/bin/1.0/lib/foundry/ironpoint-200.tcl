#
# ironpoint-200.tcl - configures a Foundry ironpoint 200 access point (device-under-test)
#
# The functions in this file will override any that are defined in the upper
# foundry level.
#
# $Id: ironpoint-200.tcl,v 1.9.6.1 2007/12/14 20:06:57 manderson Exp $
#

global Author Id RCSfile Revision Date Name

set cvs_author  [cvs_clean "$Author: manderson $"]
set cvs_ID      [cvs_clean "$Id: ironpoint-200.tcl,v 1.9.6.1 2007/12/14 20:06:57 manderson Exp $"]
set cvs_file    [cvs_clean "$RCSfile: ironpoint-200.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.9.6.1 $"]
set cvs_date    [cvs_clean "$Date: 2007/12/14 20:06:57 $"]
set cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

debug $::DBLVL_CVS_VERSION "loading $cvs_file $cvs_version $cvs_date"

# note that except for the entry point for the AP's configuration, this file is currently
# blank but as differences between various Foundry access points are identified this file
# will get utilized for configuring any settings unique to the ip-200

debug $::DBLVL_TRACE "sourcing ironpoint-200.tcl"

# foundry doesn't really have device families, so we just inherit
# at the vendor level.
set lib [file join $::VW_TEST_ROOT lib foundry foundry.tcl]
if {[catch {source $lib} result]} {
    puts "Error: Opening of $lib failed: $result"
    exit -1
}

#
# dut_configure_foundry-ironpoint-200 - entry point for configuring fat Foundry APs
#
# dut_name    - The name of the AP to be configured
#
# group_name  - The name of the group this AP will be configured for
#
# global_name - A pointer to the global config for this test
#
proc dut_configure_foundry-ironpoint-200 { dut_name group_name global_name } {
    
    global $dut_name

    debug $::DBLVL_TRACE "dut_configure_foundry-ironpoint-200"
    
    # take the passed in names, find the corresponding configs
    # and pass them down to the appropriate lower level procs.
    
    upvar #0 $dut_name    dut_cfg
    upvar #0 $group_name  group_cfg
    upvar #0 $global_name global_cfg

    # merge the group and global config together
    set cfg [::configurator::merge_config "$global_cfg" "$group_cfg"]
    set cfg [::configurator::merge_config "$cfg"        "$dut_cfg"  ]
    
    # find the ethernet interface.  FAT Foundry's don't have a lot of options here
    set active_int "ethernet"
    
    # need the addr, mask and gateway
    if {![catch {set this_int_list [vw_keylget cfg Interface]}]} {
        if {[catch {set this_int [vw_keylget this_int_list $active_int]}]} {
            puts "Error: No interface \"$active_int\" defined for $dut_name"
            exit -1
        }
    }
    if {[catch {set ip_addr [vw_keylget this_int IpAddr]}]} {
        puts "Error: No ip address set for $active_int on $dut_name"
        exit -1
    }
        
    # grab the console address and port
    if {[catch {set console_addr [vw_keylget cfg ConsoleAddr]}]} {
        debug $::DBLVL_WARN "No console address found.  Something is amiss."
        set console_addr "0.0.0.0"
    }
    
    if {[catch {set console_port [vw_keylget cfg ConsolePort]}]} {
        debug $::DBLVL_WARN "No console port found.  Something is amiss."
        set console_port 23
    }
    
    if {[catch {set group_type [vw_keylget cfg GroupType]}]} {
        puts "Error: No GroupType for group $group_name"
        exit -1
    }

    # if the console matches this ethernet address, do not configure
    # 1. because if we have gotten this far, the interface is configured.
    # 2. setting it again drops our connection.
    if { $group_type == "802.3" && "$console_port" == "23" && "$console_addr" == "$ip_addr" } {
        debug $::DBLVL_INFO "Not setting ethernet address"
        return 0
    }

    if {[dut_configure_prelude "$dut_name" "$cfg"]} {
        debug $::DBLVL_ERROR "Unable to get to config prompt"
        return -1
    }
    
    if { $group_type == "802.11abg" } {
        dut_configure_radius    "$dut_name" "$cfg"
        dut_configure_wireless  "$dut_name" "$cfg"
        dut_configure_ap_global "$dut_name" "$cfg"
    } else {
        dut_configure_eth       "$dut_name" "$cfg"
    }
    
    dut_configure_epilogue  "$dut_name" "$cfg"
    
    if {![catch {set dut_console_addr [vw_keylget cfg ConsoleAddr]}]} {
        ping_pause $dut_console_addr
    }

    return 0
}

#
# entry point for configuring the IronPoint 200
#
set ::config_file_proc dut_configure_foundry-ironpoint-200
