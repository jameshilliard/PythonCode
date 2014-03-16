#
# cisco-ios.tcl - configures a cisco IOS access point (device-under-test)
#
# Generic functions to aid in the configuration.  Any one of these can be
# overridden by a function at the device family (cisco-12xx, cisco-123x, ...)
# or specific model (cisco-1231, cisco-1240, ...) levels.
#
# $Id: cisco-ios.tcl,v 1.27.4.1 2008/01/24 20:56:22 manderson Exp $
#
#

set cvs_author  [cvs_clean "$Author: manderson $"]
set cvs_ID      [cvs_clean "$Id: cisco-ios.tcl,v 1.27.4.1 2008/01/24 20:56:22 manderson Exp $"]
set cvs_file    [cvs_clean "$RCSfile: cisco-ios.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.27.4.1 $"]
set cvs_date    [cvs_clean "$Date: 2008/01/24 20:56:22 $"]
set cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

debug $::DBLVL_CVS_VERSION "loading $cvs_file $cvs_version $cvs_date"

set ::readonly_prompt "\[\r\n\]\[^ ^\t\]+>"
set ::admin_prompt "\[\r\n\]\[^ ^\t\]+#"
set ::config_prompt "\[\r\n\]\[^ ^\t\]+\\(config\\)#"

#
# TODO: move this to a globals.tcl file under lib/tcl
#
set ::MAX_BG_CHANNEL 14

# XXX - temporarily always clean until IOS security method code
#       can be cleaned up.
set ::cisco_ios_clean_first_time 1
if {! [info exists ::cisco_ios_clean_first_time]} {
    set ::cisco_ios_clean_first_time 1
    debug $::DBLVL_TRACE "first time clean enabled"
}


#
# dut_find_eth_addr - retrieve the ip address of the active ethernet interface
#
#   dut_name        - The name of the device to be tested.
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_find_eth_addr { dut_name cfg } {

    debug $::DBLVL_TRACE "dut_find_eth_addr"

    if {![catch {set int_list [vw_keylget cfg Interface]}]} {
    
        foreach interface [keylkeys int_list] {
            set int_cfg [vw_keylget int_list $interface]
            if {[catch {set int_type [vw_keylget int_cfg InterfaceType]}]} {
                puts "Error: No InterfaceType defined in $cfg_name->$duts->$interface"
                exit -1
            }
            if { $int_type == "802.3" } {
                set eth_int $int_cfg
                break
            }
        }
            
        if {[info exists eth_int]} {
            if {[catch {set ip_addr [vw_keylget eth_int IpAddr]}]} {
                puts "Error: No ip address set for $eth_int on $dut_name"
                exit -1
            }
        } else {
            puts "Error: No 802.3 interfaces found on $dut_name"
            exit -1
        }
    } else {
        puts "Error: No Interfaces found on $dut_name"
        exit -1
    }

    return $ip_addr
}

#
# find_bvi_members - Search the AP's running config for the bridgegroup members
# 
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The merged group, global and dut configuration
#
#  bridge_int   - bridge interface 
#
#  device_type  - filter by device type [ radio | ethernet ]
#
proc dut_find_bvi_members { dut_name cfg bridge_int device_type } {

    debug $::DBLVL_TRACE "dut_find_bvi_memebrs"
    set rc 0
    
    # if any of these fail, return an empty list. 
    if [catch {dut_configure_config_prompt $dut_name $cfg}] {
        debug $::DBLVL_WARN "Could not return to config prompt\n"
        return {}
    }
     
    if {[::configurator::dut_send_cmd "end\n" "$::admin_prompt" 5]} {
        debug $::DBLVL_WARN "Could not return to admin prompt\n"
        return {}
    }
    
    if {[::configurator::dut_send_cmd "sh bridge verbose\n" "$::admin_prompt" 5]} {
        debug $::DBLVL_WARN "Could not get bridge verbose output\n"
        return {}
    }
    
    #get the BVI interface bridge group number
    
    if {! [regexp {[A-Z]+([\d])} $bridge_int match bridge_id] } {
        debug $::DBLVL_WARN "could not determine bridge group number from $bridge_int\n"
        return {}
    }
    
    #grab output from ::dut_configure_send_buf
    
    set command_output [split $::dut_configure_send_buf "\n"]
    
    # first, we need to match our bridge group.
    
    # init our list.
    
    set bvi_members {}
    
    set in_bridge_group 0

    foreach line $command_output {
        if { $in_bridge_group } {
            if {[ regexp {^[\s]+$} $line ]} {
                # we are done.
                break
            }
            if {[ regexp {([A-Z][a-z][\w]+[0-9]+)\.[0-9]+[\s]+} $line match interface_name]} {
                switch -regexp -- $interface_name {
                Radio   {
                            if { $device_type eq "radio" } {
                                lappend bvi_members $interface_name
                            }
                        }
                default {
                            if { $device_type eq "ethernet" } {
                                lappend bvi_members $interface_name
                            }
                        }
                }
            }
            
            if {[ regexp {([A-Z][a-z][\w]+[0-9]+)[\s]+} $line match interface_name]} {
                switch -regexp -- $interface_name {
                Radio   {
                            if { $device_type eq "radio" } {
                                lappend bvi_members $interface_name
                            }
                        }
                default {
                            if { $device_type eq "ethernet" } {
                                lappend bvi_members $interface_name
                            }
                        }
                }
            }
        } else {
            
            if { [regexp {Flood ports \(BG ([0-9]+)\)[\s]+} $line match this_bridge_id ] } {
                if { $this_bridge_id == $bridge_id } {
                    set in_bridge_group 1
                }
            }
        }
    } 

    # return to the config prompt.
    
    if {[::configurator::dut_send_cmd "config term\n" "$::config_prompt" 5]} {
        puts "Could not return to configure prompt"
        exit -1
    }

    return $bvi_members
        
}
    

#
# dut_configure_config_prompt - get a Cisco AP from any state to the config prompt.
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The merged group, global and dut configuration
#
proc dut_configure_config_prompt { dut_name cfg } {

    global spawn_id

    debug $::DBLVL_TRACE "dut_configure_config_prompt"

    if [catch {set dut_username [vw_keylget cfg ApUsername]}] {
        if [catch {set dut_username [vw_keylget cfg Username]}] {
            puts "Error: No ApUsername defined for $dut_name"
            exit -1
        } else {
            debug $::DBLVL_WARN "USERNAME deprecated in DUT config, please use ApUsername"
        }
    }

    if [catch {set dut_password [vw_keylget cfg ApPassword]}] {
        if [catch {set dut_password [vw_keylget cfg Password]}] {
            puts "Error: No ApPassword defined for $dut_name"
            exit -1
        } else {
            debug $::DBLVL_WARN "PASSWORD deprecated in DUT config, please use ApPassword"
        }
    }
    
    if [catch {set dut_auth_password [vw_keylget cfg AuthPassword]}] {
        set dut_auth_password ""
    }

    # kick the console
    sleep 1
    send "\r"
    sleep 1
    send "\r"
    sleep 1
    
    expect {
        # any sort of config prompt
        -re "\[\r\n\]\[^ ^\t\]+\\((.*)\\)#" {
            if {"$expect_out(1,string)" != "config"} {
                # return to admin prompt and re-enter config
                if {[::configurator::dut_send_cmd "end\n" "$::admin_prompt" 5]} {
                    debug $::DBLVL_WARN "Didn't reach admin prompt."
                }
                if {[::configurator::dut_send_cmd "config terminal\n" "$::config_prompt" 5]} {
                    debug $::DBLVL_WARN "Didn't reach config prompt"
                }
            }
        }

        # at admin prompt
        "#$" {
            if {[::configurator::dut_send_cmd "config terminal\n" "$::config_prompt" 5]} {
                debug $::DBLVL_WARN "Didn't reach config prompt."
            }
        }

        # initial login
        "Username: " {
            if {[::configurator::dut_send_cmd "$dut_username\n" "Password:" 5]} {
                debug $::DBLVL_WARN "Didn't reach password prompt"
            }
            if {[::configurator::dut_send_cmd "$dut_password\n" "$::readonly_prompt" 5]} {
                debug $::DBLVL_WARN "Didn't reach login prompt"
            }
            if {[::configurator::dut_send_cmd "enable\n" "Password:" 5]} {
                debug $::DBLVL_WARN "Didn't reach password prompt"
            }
            if {[::configurator::dut_send_cmd "$dut_auth_password\n" "$::admin_prompt" 5]} {
                debug $::DBLVL_WARN "Didn't reach admin prompt"
            }
            if {[::configurator::dut_send_cmd "config terminal\n" "$::config_prompt" 5]} {
                debug $::DBLVL_WARN "Didn't reach config prompt"
            }
        }

        # read-only user
        ">$" {
            if {![::configurator::dut_send_cmd "enable\n" "Password:" 5]} {
                if {[::configurator::dut_send_cmd "$dut_auth_password\n" "$::admin_prompt" 5]} {
                    debug $::DBLVL_WARN "Didn't reach admin prompt"
                }
            } else {
                debug $::DBLVL_WARN "Didn't reach password prompt"
            }
            if {[::configurator::dut_send_cmd "config terminal\n" "$::config_prompt" 5]} {
                debug $::DBLVL_WARN "Didn't reach config prompt"
            }
        }
        
        # config wizard
        "enter the initial configuration dialog\?" {
            send "no\n"
            breakable_after 20
            send "\r"
            sleep 1
            if {[::configurator::dut_send_cmd "enable\n" "Password:" 5]} {
                debug $::DBLVL_WARN "Didn't reach password prompt"
            }
            if {[::configurator::dut_send_cmd "$dut_auth_password\n" "$::admin_prompt" 5]} {
                debug $::DBLVL_WARN "Didn't reach admin prompt"
            }
            if {[::configurator::dut_send_cmd "config terminal\n" "$::config_prompt" 5]} {
                debug $::DBLVL_WARN "Didn't reach config prompt"
            }
        }
        
        default {
            debug $::DBLVL_ERROR "Unknown prompt found."
            # close the expect connection
            after 1000
            catch {expect *}
            catch {exp_close}
            catch {wait}
            log_file
            breakable_after 3
            return 1
        }
    }
    
    return 0
}


#
# dut_configure_erase_config - reset an AP to factory defaults
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The merged group, global and dut configuration
#
proc dut_configure_erase_config { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_erase_config"

    set rc 0
    
    if { $::DEBUG_LEVEL >= $::DBLVL_INFO } {
        log_user 1
    } else {
        log_user 0
    }

    if {[info exists ::output_log_file]} {
        if {[catch {log_file -a $::output_log_file}]} {
            log_file
            log_file -a $::output_log_file
        }
    }
    
    # get to the config prompt
    if {[dut_configure_config_prompt $dut_name $cfg]} {
        return 1
    }
    
    if {[::configurator::dut_send_cmd "end\n" "$::admin_prompt" 10]} {
        debug $::DBLVL_WARN "Didn't reach admin prompt"
        incr rc
    }
    
    if {[::configurator::dut_send_cmd "write mem\n" "$::admin_prompt" 10]} {
        puts "Error: Did not find admin prompt after write mem"
        incr rc
    }
    
    if {[::configurator::dut_send_cmd "erase nvram:\n\n" "$::admin_prompt" 10]} {
        puts "Error: Did not find erase confirmation"
        incr rc
    }

    if {[::configurator::dut_send_cmd "reload\n\n" "." 10]} {
        puts "Error: Reload did not occur"
        incr rc
    }
    
    # close the expect connection
    after 1000
    catch {expect *}
    catch {exp_close}
    catch {wait}
    log_file
    breakable_after 3
    
    return $rc
}


# proc dut_configure_local_radius
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The merged group, global and dut configuration
#
proc dut_configure_local_radius { dut_name cfg } {
    
    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_local_radius"

    set rc 0
    
    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        puts "Error: \"$dut_name\" has no defined Method"
        exit -1
    }

    if {[::configurator::dut_send_cmd "radius-server local\n" "config-radsrv" 5]} {
        debug $::DBLVL_WARN "Did not enter local radius sub-mode"
        incr rc
    }
    
    set ip_addr [ dut_find_eth_addr $dut_name $cfg ]

    if {[catch {set radius_secret [vw_keylget cfg RadiusServerSecret]}]} {
        puts "Error: No RadiusServerSecret defined in $dut_name"
        exit -1
    }

    if {[::configurator::dut_send_cmd "nas $ip_addr key $radius_secret\n" "config-radsrv" 5]} {
        debug $::DBLVL_WARN "Did not set nas/key"
        incr rc
    }
   
    if {[::configurator::dut_send_cmd "group vw_users\n" "config-radsrv-group" 5]} {
        debug $::DBLVL_WARN "Did not enter radius group sub-mode"
        incr rc
    }

    # grab the channel and figure out which Wireless interface to use
    if {[catch {set channel [vw_keylget cfg Channel]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no configured Channel.  Skipping wireless config"
        return 0
    }

    if { $channel <= $::MAX_BG_CHANNEL } {
        set active_int "Dot11Radio0"
    } else {
        set active_int "Dot11Radio1"
    }
    
    set ssid [::configurator::find_ssid $dut_name "$cfg" "$active_int" ]
    if {[::configurator::dut_send_cmd "ssid $ssid\n" "config-radsrv-group" 5]} {
        debug $::DBLVL_WARN "Did not set ssid in group sub-mode"
        incr rc
    }
    
    if {[::configurator::dut_send_cmd "exit\n" "config-radsrv" 5]} {
        debug $::DBLVL_WARN "Did not leave group sub-mode"
        incr rc
    }
    
    if [catch {set client_identity [vw_keylget cfg Identity]}] {
        if [catch {set client_identity [vw_keylget cfg ClientIdentity]}] {
            set client_identity anonymous
        }
    }

    if [catch {set client_password [vw_keylget cfg Password]}] {
        if [catch {set client_password [vw_keylget cfg ClientPassword]}] {
            set client_password whatever
        }
    }

    if {[::configurator::dut_send_cmd "user $client_identity password $client_password group vw_users\n" "config-radsrv" 5 ]} {
        debug $::DBLVL_WARN "Did not set user in group sub-mode"
        incr rc
    }
    
    return $rc
}


#
# dut_configure_cleanup_old_config - remove any left-over config from previous
#       test runs (without rebooting the AP, because IOS AP's take a while
#       to reboot).
#
#       This function should be called prior to configuring the first
#       testcase of a test run to "clean" the AP and prep it for a new
#       set of test cases to be run.
#
# parameters:
#   dut_name    - The name of the device to be tested
#
#   cfg         - The merged group, global, and dut configuration
#
proc dut_configure_clean_old_config { dut_name cfg } {
    set func_name "dut_configure_cleanup_old_config"
    debug $::DBLVL_TRACE "$func_name"

    #
    # clean up any old configuration left over from previous tests
    # before we begin our testing
    #
    
    #
    # assume we're at config terminal prompt.  Get back to admin prompt.
    #
    if {[::configurator::dut_send_cmd "exit\r" "$::admin_prompt" 5]} {
        debug $::DBLVL_WARN "$func_name: unable to reach admin prompt"
        return 1
    }

    if {[::configurator::dut_send_cmd "terminal length 0\n" "$::admin_prompt" 5]} {
        debug $::DBLVL_WARN "$func_name: Did not set term len to 0"
        return 1
    }

    set ssid_list {}
    set subif_list {}
    
    send "show run\r"
    
    #-re "(\[^\r]*)\r\n"
    expect {
        -re {([^\n]*)\n} {
            set line $expect_out(0,string)
            set line [string range $line 0 [expr [string length $line] - 2] ]
            if {[regexp -nocase "dot11 ssid (.*)" $line whole_match ssid_name]} {
                lappend ssid_list $ssid_name
            }
            if {[regexp -nocase {interface ([a-z]+[\w]+[0-9]+\.[0-9]+)} $line whole_match interface_name]} {
        	    lappend subif_list $interface_name
            }
            flush stdout
            exp_continue
        }
        "$::admin_prompt"
    }

    if {[::configurator::dut_send_cmd "\r" "$::admin_prompt" 5]} {
        debug $::DBLVL_ERROR "$func_name: Unable to find config prompt following show run"
    return 1
    }
    
    if {[llength $subif_list]} {
    	if {[::configurator::dut_send_cmd "config terminal\r" "$::config_prompt" 5]} {
            debug $::DBLVL_ERROR "$func_name: Unable to enter terminal config mode"
	        return 1
        }
        
    	foreach interface_name $subif_list {
    		if {[::configurator::dut_send_cmd "no interface $interface_name\r" "$::config_prompt" 5]} {
            	debug $::DBLVL_ERROR "$func_name: Error removing dot11 ssid $ssid_name"
       			return 1
        	}
        	debug $::DBLVL_INFO "$func_name: Removed sub-interface $interface_name prior to first testcase run"
    	}
    	
    	if {[::configurator::dut_send_cmd "end\r" "$::admin_prompt" 5]} {
            debug $::DBLVL_ERROR "$func_name: Unable to return to admin mode"
	        return 1
        }
    	
    }
    
    if {[llength $ssid_list]} {

        if {[::configurator::dut_send_cmd "config terminal\r" "$::config_prompt" 5]} {
            debug $::DBLVL_ERROR "$func_name: Unable to enter terminal config mode"
        return 1
        }

        foreach ssid_name $ssid_list {
            if {[::configurator::dut_send_cmd "no dot11 ssid $ssid_name\r" "$::config_prompt" 5]} {
                debug $::DBLVL_ERROR "$func_name: Error removing dot11 ssid $ssid_name"
                return 1
            }
            debug $::DBLVL_INFO "$func_name: Removed dot11 ssid $ssid_name prior to first testcase run"
        }
    }

    # calling function expects us to leave the system in 'configure terminal' mode
    return 0
}

#
# dut_configure_prelude - setup to get an AP ready to be configured
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The merged group, global and dut configuration
#
proc dut_configure_prelude { dut_name cfg } {
 
    global spawn_id
    set func_name "dut_configure_prelude"
    debug $::DBLVL_TRACE "$func_name"
    
    # need the console address and port
    if {[catch {set console_addr [vw_keylget cfg ConsoleAddr]}]} {
        debug $::DBLVL_ERROR "$func_name: No ConsoleAddr for $dut_name"
        return 1
    }
    
    if {[catch {set console_port [vw_keylget cfg ConsolePort]}]} {
        debug $::DBLVL_INFO "No ConsolePort for $dut_name found, defaulting to 23"
        set console_port 23
    }

    if { $::DEBUG_LEVEL >= $::DBLVL_INFO } {
        log_user 1
    } else {
        log_user 0
    }
    if {[info exists ::output_log_file]} {
        if {[catch {log_file -a $::output_log_file}]} {
            log_file
            log_file -a $::output_log_file
        }
    }
    debug $::DBLVL_INFO "Connecting to $console_addr:$console_port"
    
    set telnet_path [file join $::VW_TEST_ROOT "bin" "telnet.tcl"]
    #spawn tclsh $telnet_path $console_addr $console_port
    exp_spawn telnet $console_addr $console_port
    
    # get to the config prompt
    if {[dut_configure_config_prompt $dut_name $cfg]} {
        return 1
    }

    return 0
}


#
# dut_configure_aaa - configure aaa stuffs
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The merged group, global and dut configuration
#
proc dut_configure_aaa { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_aaa"

    set rc 0
    
    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        puts "Error: \"$dut_name\" has no defined Method"
        exit -1
    }
    
    # do we really want to know how bizarre the old way was?
    if {[::configurator::dut_send_cmd "aaa new-model\n" "$::config_prompt" 5]} {
        debug $::DBLVL_WARN "Did not set aaa new model"
        incr rc
    }

    # retrieve radius info if in this big list o'security methods
    if { [::configurator::method_needs_radius $security_method ]} {
        if {[catch {set rad_server [vw_keylget cfg RadiusServerAddr]}]} {
            puts "Error: No RadiusServerAddr defined in $dut_name"
            exit -1
        }
        if {[catch {set rad_auth [vw_keylget cfg RadiusServerAuthPort]}]} {
            debug $::DBLVL_INFO "No RadiusServerAuthPort defined for $dut_name, using 1812"
            set rad_auth 1812
        }
        if {[catch {set rad_acct [vw_keylget cfg RadiusServerAcctPort]}]} {
            debug $::DBLVL_INFO "No RadiusServerAcctPort defined for $dut_name, using 1813"
            set rad_acct 1813
        }
    }
          
    switch $security_method {
        "WPA2-EAP-TLS"                     -
        "WPA-EAP-TLS"                      -
        "WPA-EAP-TTLS-GTC"                 -
        "WPA2-EAP-TTLS-GTC"                -
        "WPA-PEAP-MSCHAPV2"                -
        "WPA2-PEAP-MSCHAPV2"               -
        "DWEP-EAP-TLS"                     -
        "WPA-CCKM-PEAP-MSCHAPV2-TKIP"      -
        "WPA-CCKM-PEAP-MSCHAPV2-AES-CCMP"  -
        "WPA-CCKM-TLS-TKIP"                -
        "WPA-CCKM-TLS-AES-CCMP"            -
        "WPA-CCKM-LEAP-TKIP"               -
        "WPA-CCKM-LEAP-AES-CCMP"           -
        "WPA-CCKM-FAST-TKIP"               -
        "WPA-CCKM-FAST-AES-CCMP"           -
        "WPA2-CCKM-PEAP-MSCHAPV2-TKIP"     -
        "WPA2-CCKM-PEAP-MSCHAPV2-AES-CCMP" -
        "WPA2-CCKM-TLS-TKIP"               -
        "WPA2-CCKM-TLS-AES-CCMP"           -
        "WPA2-CCKM-LEAP-TKIP"              -
        "WPA2-CCKM-LEAP-AES-CCMP"          -
        "WPA2-CCKM-FAST-TKIP"              -
        "WPA2-CCKM-FAST-AES-CCMP"          -
        "DWEP-EAP-TTLS-GTC"                -
        "DWEP-PEAP-MSCHAPV2"               -
        "WPA-EAP-FAST"                     -
        "WPA2-EAP-FAST"                    -
        "WPA-PEAP-MSCHAPV2-AES"            -
        "WPA2-PEAP-MSCHAPV2-TKIP"          -
        "WPA2-EAP-TLS-TKIP"                -
        "LEAP"                             -
        "WPA-LEAP"                         -
        "WPA2-LEAP"                        {
            
            if {[::configurator::dut_send_cmd "no aaa authentication login eap_methods group rad_eap\n" "$::config_prompt" 5]} {
                debug $::DBLVL_WARN "Did not unset eap_methods"
                incr rc
            }
            if {[::configurator::dut_send_cmd "no aaa group server radius rad_eap\n" "$::config_prompt" 5]} {
                debug $::DBLVL_WARN "Did not set aaa group radius sub-mode"
                incr rc
            }
            if {[::configurator::dut_send_cmd "aaa group server radius rad_eap\n" "config-sg-radius" 5]} {
                debug $::DBLVL_WARN "Did not set aaa group radius sub-mode"
                incr rc
            }
            if {[::configurator::dut_send_cmd "server $rad_server auth-port $rad_auth acct-port $rad_acct\n" "config-sg-radius" 5]} {
                debug $::DBLVL_WARN "Did not set radius server"
                incr rc
            }
            if {[::configurator::dut_send_cmd "aaa authentication login eap_methods group rad_eap\n" "$::config_prompt" 5]} {
                debug $::DBLVL_WARN "Did not set eap_methods"
                incr rc
            }
        }

        default             {
            debug $::DBLVL_INFO "No AAA config needed for security method: $security_method"
        }
    }
    
    return $rc
}


#
# dut_configure_radius - configure radius server
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The merged group, global and dut configuration
#
proc dut_configure_radius { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_radius"

    set rc 0
    
    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        puts "Error: \"$dut_name\" has no defined Method"
        exit -1
    }

    # one big if statement to match all auth methods needing radius
    if { [::configurator::method_needs_radius $security_method ] } {
        if {[catch {set radius_server [vw_keylget cfg RadiusServerAddr]}]} {
            puts "Error: No RadiusServerAddr defined in $dut_name"
            exit -1
        }
        if {[catch {set radius_auth [vw_keylget cfg RadiusServerAuthPort]}]} {
            debug $::DBLVL_INFO "No RadiusServerAuthPort defined for $dut_name, using 1812"
            set radius_auth 1812
        }
        if {[catch {set radius_acct [vw_keylget cfg RadiusServerAcctPort]}]} {
            debug $::DBLVL_INFO "No RadiusServerAcctPort defined for $dut_name, using 1813"
            set radius_acct 1813
        }
        if {[catch {set radius_secret [vw_keylget cfg RadiusServerSecret]}]} {
            puts "Error: No RadiusServerSecret defined in $dut_name"
            exit -1
        }

        # if the ip address of the radius server is on the ap, configure a 
        # local instance
        set ip_addr [ dut_find_eth_addr $dut_name $cfg ]
        if { $ip_addr == $radius_server } {
            dut_configure_local_radius $dut_name $cfg
        }

        set rad_cfg "radius-server host $radius_server "
        append rad_cfg "auth-port $radius_auth "
        append rad_cfg "acct-port $radius_acct "
        append rad_cfg "key $radius_secret"
        if {[::configurator::dut_send_cmd "$rad_cfg\n" "$::config_prompt" 5]} {
            debug $::DBLVL_WARN "Did not set radius server"
            incr rc
        }
        
        # EAP-FAST needs a higher radius-server timeout value.
        
         switch $security_method {
        "WPA-EAP-FAST"       -
        "WAP2-EAP-FAST"      {
                    
                if {[::configurator::dut_send_cmd "no radius-server timeout 30\n" "$::config_prompt" 5]} {
                    debug $::DBLVL_WARN "Did not unset timeout"
                    incr rc
                }
                
                if {[::configurator::dut_send_cmd "radius-server timeout 30\n" "$::config_prompt" 5]} {
                    debug $::DBLVL_WARN "Did not set timeout"
                    incr rc
                }
            }
        }
       
    } else {
        debug $::DBLVL_INFO "No radius config needed for security method: $security_method"
    }
    
    return $rc
}


#
# dut_configure_dot11 - configure things at the dot11 sub-mode
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The merged group, global and dut configuration
#
proc dut_configure_dot11 { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_dot11"

    set rc 0
    
    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        puts "Error: \"$dut_name\" has no defined Method"
        exit -1
    }

    # grab the channel and figure out which Wireless interface to use
    if {[catch {set channel [vw_keylget cfg Channel]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no configured Channel.  Skipping wireless config"
        return 0
    }

    if { $channel <= $::MAX_BG_CHANNEL } {
        set active_int "Dot11Radio0"
    } else {
        set active_int "Dot11Radio1"
    }
    
    if {[catch {set vlan_enable [vw_keylget cfg VlanEnable]}]} {
        set vlan_enable false
    }
    
    if {[catch {set vlan_id [vw_keylget cfg VlanId]}]} {
        set vlan_id 0
    }
    
    
    set dut_ssid [::configurator::find_ssid $dut_name "$cfg" "$active_int" ]

    # remove the previously configured dot11
    if {[catch {set prev_ssid [keylget cfg ssid_is_method]}]} {
        set prev_ssid ""
    }

    # if { $prev_ssid == "" } {
    #    set prev_ssid $dut_ssid
    # }

    if {[catch {keylset cfg ssid_is_method $dut_ssid} result]} {
        debug $::DBLVL_WARN "Unable to store old SSID - $result"
    }
    
    if { $prev_ssid != "" } {
        if {[::configurator::dut_send_cmd "no dot11 ssid $prev_ssid\n" "$::config_prompt" 5]} {
            debug $::DBLVL_WARN "Not able to remove dot11 ssid $dut_ssid"
        }
    }

    # enter the dot11 mode
    if {[::configurator::dut_send_cmd "dot11 ssid $dut_ssid\n" "config-ssid" 5]} {
        debug $::DBLVL_WARN "Did not enter dot11 sub-mode"
        incr rc
    }
    
    #remove previous vlan
    if {[::configurator::dut_send_cmd "no vlan\n" "config-ssid" 5]} {
        debug $::DBLVL_WARN "Did not unset vlan"
        incr rc
    }
    
    #configure vlan if enabled.
    
    if { $vlan_enable } {
        if {[::configurator::dut_send_cmd "vlan $vlan_id\n" "config-ssid" 5]} {
            debug $::DBLVL_WARN "Did not set vlan"
            incr rc
        }
    }

    # set the authentication setting
    switch $security_method {
        "None"              -
        "WEP-Open-40"       -
        "WEP-Open-128"      {
            if {[::configurator::dut_send_cmd "authentication open\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not set authentication"
                incr rc
            }
            if {[::configurator::dut_send_cmd "no authentication key-management\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not unset key management"
                incr rc
            }
            if {[::configurator::dut_send_cmd "no infrastructure-ssid\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not unset key management"
                incr rc
            }
            if {[::configurator::dut_send_cmd "no authentication network-eap eap_methods\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not unset key management"
                incr rc
            }
        }
        
        "WEP-SharedKey-40"  -
        "WEP-SharedKey-128" {
            if {[::configurator::dut_send_cmd "authentication shared\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not set authentication"
                incr rc
            }
            if {[::configurator::dut_send_cmd "no authentication key-management\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not unset key management"
                incr rc
            }
            if {[::configurator::dut_send_cmd "no infrastructure-ssid\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not unset key management"
                incr rc
            }
            if {[::configurator::dut_send_cmd "no authentication network-eap eap_methods\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not unset key management"
                incr rc
            }
        }

        "LEAP" {
            if {[::configurator::dut_send_cmd "authentication open eap eap_methods\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not set authentication"
                incr rc
            }
            if {[::configurator::dut_send_cmd "authentication network-eap eap_methods\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not set network-eap"
                incr rc
            }
            if {[::configurator::dut_send_cmd "infrastructure-ssid optional\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not set optional ssid"
                incr rc
            }
            if {[::configurator::dut_send_cmd "no authentication key-management\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not unset key management"
                incr rc
            }
        }

        "WPA-LEAP"  -
        "WPA-CCKM-LEAP-TKIP" -
        "WPA-CCKM-LEAP-AES-CCMP" -
        "WPA2-CCKM-LEAP-TKIP" -
        "WPA2-CCKM-LEAP-AES-CCMP" -
        "WPA2-LEAP" {
            if {[::configurator::dut_send_cmd "authentication open eap eap_methods\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not set authentication"
                incr rc
            }
            if {[::configurator::dut_send_cmd "authentication network-eap eap_methods\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not set network-eap"
                incr rc
            }
            if {[::configurator::dut_send_cmd "authentication key-management wpa\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not set key management"
                incr rc
            }
            if {[::configurator::dut_send_cmd "infrastructure-ssid optional\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not set optional ssid"
                incr rc
            }
        }

        "WPA-PSK"            -
        "WPA-PSK-AES"        -
        "WPA2-PSK-TKIP"      -
        "WPA2-PSK"           {
            if {[::configurator::dut_send_cmd "authentication open\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not set authentication"
                incr rc
            }
            if {[::configurator::dut_send_cmd "authentication key-management wpa\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not set key management"
                incr rc
            }
            if {[::configurator::dut_send_cmd "infrastructure-ssid optional\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not set optional ssid"
                incr rc
            }
            if {[::configurator::dut_send_cmd "no authentication network-eap eap_methods\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not unset key management"
                incr rc
            }
            set is_ascii 1
            if [catch {set psk [vw_keylget cfg PskAscii]}] {
                set is_ascii 0
                if [catch {set psk [vw_keylget cfg PskHex]}] {
                    set is_ascii 1
                    set psk "whatever"
                }
            }

            if { $is_ascii } {
                if {[::configurator::dut_send_cmd "wpa-psk ascii $psk\n" "config-ssid" 5]} {
                    debug $::DBLVL_WARN "Did not set ascii psk key"
                    incr rc
                }
            } else {
                if {[::configurator::dut_send_cmd "wpa-psk hex $psk\n" "config-ssid" 5]} {
                    debug $::DBLVL_WARN "Did not set hex psk key"
                    incr rc
                }
            }
        }

        "WPA2-EAP-TLS"           -
        "WPA-EAP-TLS"            -
        "WPA-EAP-TTLS-GTC"       -
        "WPA2-EAP-TTLS-GTC"      -
        "WPA-PEAP-MSCHAPV2"      -
        "WPA-EAP-FAST"           -
        "WPA-CCKM-FAST-TKIP"     -
        "WPA-CCKM-FAST-AES-CCMP" -          
        "WPA2-EAP-FAST"          -
        "WPA-CCKM-TLS-TKIP"      -
        "WPA-CCKM-TLS-AES-CCMP"  -
        "WPA2-PEAP-MSCHAPV2-TKIP" -
        "WPA-CCKM-PEAP-MSCHAPV2-TKIP" -
        "WPA-CCKM-PEAP-MSCHAPV2-AES-CCMP" -
        "WPA2-CCKM-PEAP-MSCHAPV2-TKIP" - 
        "WPA2-CCKM-PEAP-MSCHAPV2-AES-CCMP" -
        "WPA2-CCKM-TLS-TKIP" -
        "WPA2-CCKM-TLS-AES-CCMP" -
        "WPA2-CCKM-FAST-TKIP" -
        "WPA2-CCKM-FAST-AES-CCMP" -
        "WPA2-EAP-TLS-TKIP"      -
        "WPA-PEAP-MSCHAPV2-AES"  -
        "WPA2-PEAP-MSCHAPV2"     {
            if {[::configurator::dut_send_cmd "authentication open eap eap_methods\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not set eap methods"
                incr rc
            }
            if {[::configurator::dut_send_cmd "authentication key-management wpa\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not set key management"
                incr rc
            }
            if {[::configurator::dut_send_cmd "infrastructure-ssid optional\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not set optional ssid"
                incr rc
            }
            if {[::configurator::dut_send_cmd "authentication network-eap eap_methods\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not set network eap methods"
                incr rc
            }
        }

        "DWEP-EAP-TLS"            -
        "DWEP-EAP-TTLS-GTC"       -
        "DWEP-PEAP-MSCHAPV2"      {
            if {[::configurator::dut_send_cmd "no authentication key-management\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not unset key management"
                incr rc
            }
            if {[::configurator::dut_send_cmd "no authentication network-eap eap_methods\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not unset network eap methods"
                incr rc
            }
            if {[::configurator::dut_send_cmd "authentication open eap eap_methods\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not set eap methods"
                incr rc
            }
            if {[::configurator::dut_send_cmd "infrastructure-ssid optional\n" "config-ssid" 5]} {
                debug $::DBLVL_WARN "Did not set optional ssid"
                incr rc
            }
        }

        default             {
            puts "Error: Unknown security method: $security_method in lib/cisco/cisco-ios.tcl"
            exit -1
        }
    }
    
    # default to guest-mode being on if not in config file so as to not break
    # old configs
    if {[catch {set guest_mode [vw_keylget cfg SsidBroadcast]}]} {
        set guest_mode true
    }
    if {$guest_mode} {
        set cmd "guest-mode"
    } else {
        set cmd "no guest-mode"
    }
    if {[::configurator::dut_send_cmd "$cmd\n" "config-ssid" 5]} {
        debug $::DBLVL_WARN "Did not set guest mode"
        incr rc
    }

    # exit the dot11 sub-mode
    if {[::configurator::dut_send_cmd "exit\n" "$::config_prompt" 5]} {
        debug $::DBLVL_WARN "Did not exit dot11 mode"
        incr rc
    }
    
    return $rc
}



#
# dut_configure_eth - configure things at the ethernet interface sub-mode
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The merged group, global and dut configuration
#
proc dut_configure_eth { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_eth"

    set rc 0
    
    # find the ethernet interface
    if {![catch {set int_list [vw_keylget cfg Interface]}]} {
    
        foreach interface [keylkeys int_list] {
            set int_cfg [vw_keylget int_list $interface]
            if {[catch {set int_type [vw_keylget int_cfg InterfaceType]}]} {
                puts "Error: No InterfaceType defined in $cfg_name->$duts->$interface"
                exit -1
            }
            if { $int_type == "802.3" } {
                set active_int $interface
                break
            }
        }
    }

        if {![info exists active_int]} {
            puts "Error: No 802.3 interface found in $dut_name"
            exit -1
        }

    if {[::configurator::dut_send_cmd "int $active_int\n" "config-if" 5]} {
        debug $::DBLVL_WARN "Did not enter interface sub-mode"
        incr rc
    }

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
    
    if {[catch {set ip_mask [vw_keylget this_int IpMask]}]} {
        puts "Error: No subnet mask set for $active_int on $dut_name"
        exit -1
    }
    
    if {[catch {set gateway [vw_keylget this_int Gateway]}]} {
        debug $::DBLVL_INFO "No default gateway for $active_int on $dut_name"
    }
    
    if {[::configurator::dut_send_cmd "ip address $ip_addr $ip_mask\n" "config-if" 5]} {
        debug $::DBLVL_WARN "Did not set ip address"
        incr rc
    }
    if {[::configurator::dut_send_cmd "no shutdown\n" "config-if" 5]} {
        debug $::DBLVL_WARN "Did not no shut interface"
        incr rc
    }
    if {[::configurator::dut_send_cmd "exit\n" "$::config_prompt" 5]} {
        debug $::DBLVL_WARN "Did not exit interface mode"
        incr rc
    }
    
    if {[info exists gateway]} {
        set cmd "ip default-gateway $gateway"
    } else {
        set cmd "no ip default-gateway"
    }
    if {[::configurator::dut_send_cmd "$cmd\n" "$::config_prompt" 5]} {
            debug $::DBLVL_WARN "Did not set/unset default gateway"
            incr rc
    }
    
    return $rc
}


# dut_configure_subif - configure sub-if to allow for dot1q VLAN encapsulation
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The merged group, global and dut configuration
#
#  active_int   - The interface that we are setting up the sub-interface for.

proc dut_configure_subif { dut_name cfg active_int } {
    
    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_subif"
    
    set rc 0
    
    if {[catch {set vlan_enable [vw_keylget cfg VlanEnable]}]} {
        set vlan_enable false
    }

    if {[catch {set vlan_id [vw_keylget cfg VlanId]}]} {
        set vlan_id 1
    }
    
    set subif_name $active_int.$vlan_id
    
    if {[::configurator::dut_send_cmd "interface $subif_name\n" "config-subif" 5]} {
        debug $::DBLVL_WARN "Did not enter interface sub-mode for sub-if $subif_name"
        incr rc
    }
    
    # remove dot1q encapsulation -- regardless if vlans are enabled or not.
    if {[::configurator::dut_send_cmd "no encapsulation dot1q $vlan_id native\n" "config-subif" 5]} {
        debug $::DBLVL_WARN "Did not set encapsulation dot1q $vlan_id"
        incr rc
    }
    
    # set dot1q encapsulation if vlan is enabled.
    if { $vlan_enable eq "true" } {
    	if {[::configurator::dut_send_cmd "encapsulation dot1q $vlan_id native\n" "config-subif" 5]} {
			debug $::DBLVL_WARN "Did not set encapsulation dot1q $vlan_id"
			incr rc
		}
	}
    
    
    # exit the sub mode
    if {[::configurator::dut_send_cmd "exit\n" "$::config_prompt" 5]} {
        debug $::DBLVL_WARN "Did not exit wireless sub-interface mode"
        incr rc
    }
    
    return $rc

}

#
# dut_configure_wireless - configure things at the radio sub-mode
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The merged group, global and dut configuration
#
proc dut_configure_wireless { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_wireless"

    set rc 0
    
    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        puts "Error: \"$dut_name\" has no defined Method"
        exit -1
    }

    # grab the channel and figure out which Wireless interface to use
    if {[catch {set channel [vw_keylget cfg Channel]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no configured Channel.  Skipping wireless config"
        return 0
    }

    if { $channel <= $::MAX_BG_CHANNEL } {
        set active_int "Dot11Radio0"
    } else {
        set active_int "Dot11Radio1"
    }
    
    # enter the interface mode
    if {[::configurator::dut_send_cmd "interface $active_int\n" "config-if" 5]} {
        debug $::DBLVL_WARN "Did not enter interface sub-mode"
        incr rc
   }

   # shut it down temporarily
   if {[::configurator::dut_send_cmd "shutdown\n" "config-if" 5]} {
       debug $::DBLVL_WARN "Did not shut interface"
       incr rc
   }

    # grab the channel and figure out which Wireless interface to use
    if {[catch {set channel [vw_keylget cfg Channel]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no configured Channel.  Skipping wireless config"
        return 0
    }

    if { $channel <= $::MAX_BG_CHANNEL } {
        set active_int "Dot11Radio0"
        set this_radio_type "bg"
    } else {
        set active_int "Dot11Radio1"
        set this_radio_type "a"
    }
    
    # find the ssid. we will set it later to make EAP happy.
    set ssid [::configurator::find_ssid $dut_name "$cfg" "$active_int" ]
    
    # the radio type is needed to determine different command format differences
    if {![catch {set this_int_list [vw_keylget cfg Interface]}]} {
        if {[catch {set this_int [vw_keylget this_int_list $active_int]}]} {
            puts "Error: No interface \"$active_int\" for DUT $dut_name defined"
            exit -1
        }
    }

    debug $::DBLVL_INFO "Configuring DUT with Channel"
    set channel [vw_keylget cfg Channel]

    switch $this_radio_type {
        "a" {
            # different versions of IOS may have different syntax
            if {[::configurator::dut_send_cmd "dfs channel $channel\n" "config-if" 5]} {
                debug $::DBLVL_WARN "Did not set dfs channel"
                if {[::configurator::dut_send_cmd "channel $channel\n" "config-if" 5]} {
                    debug $::DBLVL_WARN "Also did not set channel"
                    incr rc
                }
            }
        }
        "bg" {
            if {[::configurator::dut_send_cmd "channel $channel\n" "config-if" 5]} {
                debug $::DBLVL_WARN "Did not set channel"
                incr rc
            }
        }
    }
    
    if {[catch {set power_level [vw_keylget this_int Power]}]} {
        debug $::DBLVL_INFO "No power level set for $dut_name - $active_int, defaulting"
        # a semi-sensible default?
        switch $this_radio_type {
            "a" {
                set power_level 2
            }
            "bg" {
                set power_level 1
            }
        }
    }
    
    switch $this_radio_type {
        "a" {
            if {[::configurator::dut_send_cmd "power local $power_level\n" "config-if" 5]} {
                debug $::DBLVL_WARN "Did not set power level"
                incr rc
            }
        }
        "bg" {
            if {[::configurator::dut_send_cmd "power local cck $power_level\n" "config-if" 5]} {
                debug $::DBLVL_WARN "Did not set power level"
                incr rc
            }
            if {[::configurator::dut_send_cmd "power local ofdm $power_level\n" "config-if" 5]} {
                debug $::DBLVL_WARN "Did not set power level"
                incr rc
            }
        }
    }
    
    # set the encryption info
    set enc_key ""
    set enc_mode ""
    set wep_key_id ""

    switch $security_method {
        "None" { 
            unset enc_key
            unset enc_mode
            unset wep_key_id
        }

        "WEP-Open-40"      -
        "WEP-SharedKey-40" {
            set is_ascii 1
            if {[catch {set wep_key_id [vw_keylget cfg WepKeyId]}]} {
                set wep_key_id 1
            }

            if {[catch {set wep [vw_keylget cfg WepKey40Ascii]}]} {
                set is_ascii 0
                if {[catch {set hex [vw_keylget cfg WepKey40Hex]}]} {
                    set is_ascii 1
                    set wep "12345"
                }
            }

            if { $is_ascii } {
                binary scan $wep H* hex
            }

            # modified for wep_key_id
            set enc_key "encryption key $wep_key_id size 40bit 0 $hex transmit-key"
            set enc_mode "encryption mode wep mandatory"
        }

        "WEP-Open-128"      -
        "WEP-SharedKey-128" {
            set is_ascii 1
            if {[catch {set wep [vw_keylget cfg WepKey128Ascii]}]} {
                set is_ascii 0
                if {[catch {set hex [vw_keylget cfg WepKey128Hex]}]} {
                    set is_ascii 1
                    set wep "123456789ABCD"
                }
            }
       
            if { $is_ascii } {
                binary scan $wep H* hex

            }
            set enc_key "encryption key 1 size 128bit 0 $hex transmit-key"
            set enc_mode "encryption mode wep mandatory"
        }

        "LEAP"               -
        "DWEP-EAP-TLS"       -
        "DWEP-EAP-TTLS-GTC"  -
        "DWEP-PEAP-MSCHAPV2" {
            unset enc_key
            set enc_mode "encryption mode ciphers wep128"
        }

        "WPA-LEAP"                     -
        "WPA-EAP-TLS"                  -
        "WPA-EAP-TTLS-GTC"             -
        "WPA-PEAP-MSCHAPV2"            -
        "WPA-EAP-FAST"                 -
        "WPA2-PSK-TKIP"                -
        "WPA-CCKM-PEAP-MSCHAPV2-TKIP"  -
        "WPA-CCKM-TLS-TKIP"            -
        "WPA-CCKM-LEAP-TKIP"           -
        "WPA-CCKM-FAST-TKIP"           -
        "WPA2-CCKM-PEAP-MSCHAPV2-TKIP" -
        "WPA2-CCKM-TLS-TKIP"           -
        "WPA2-CCKM-LEAP-TKIP"          -
        "WPA2-CCKM-FAST-TKIP"          -
        "WPA2-PEAP-MSCHAPV2-TKIP"      -
        "WPA-PSK"           {
            unset enc_key
            set enc_mode "encryption mode ciphers tkip"
        }

        "WPA2-LEAP"          -
        "WPA2-EAP-TLS"       -
        "WPA2-EAP-TTLS-GTC"  - 
        "WPA2-PEAP-MSCHAPV2" -
        "WPA2-EAP-FAST"      -
        "WPA-PSK-AES"        -
        "WPA-PEAP-MSCHAPV2-AES" -
        "WPA-CCKM-PEAP-MSCHAPV2-AES-CCMP" -
        "WPA-CCKM-TLS-AES-CCMP" -
        "WPA-CCKM-LEAP-AES-CCMP" -
        "WPA-CCKM-FAST-AES-CCMP" -
        "WPA2-CCKM-PEAP-MSCHAPV2-AES-CCMP" -
        "WPA2-CCKM-TLS-AES-CCMP" -
        "WPA2-CCKM-LEAP-AES-CCMP" -
        "WPA2-CCKM-FAST-AES-CCMP" -
        "WPA2-PSK"           {
            unset enc_key
            set enc_mode "encryption mode ciphers aes-ccm"
        }

        default {
            puts "Error: Unknown security method: $security_method"
            exit -1
        }
    }

    # if we don't remove any existing ciphers or keys, the AP has a 
    # snit fit trying to figure out what to do
    if {[::configurator::dut_send_cmd "no enc mode ciphers\n" "config-if" 5]} {
            debug $::DBLVL_WARN "Did not unset ciphers"
            incr rc
    }
    
    if {[::configurator::dut_send_cmd "no enc key 1\n" "config-if" 5]} {
            debug $::DBLVL_WARN "Did not unset key"
            incr rc
    }

    if {[::configurator::dut_send_cmd "no enc key 2\n" "config-if" 5]} {
            debug $::DBLVL_WARN "Did not unset key"
            incr rc
    }

    if {[::configurator::dut_send_cmd "no enc key 3\n" "config-if" 5]} {
            debug $::DBLVL_WARN "Did not unset key"
            incr rc
    }
 
    if {[::configurator::dut_send_cmd "no enc key 4\n" "config-if" 5]} {
            debug $::DBLVL_WARN "Did not unset key"
            incr rc
    }
    
    if {[::configurator::dut_send_cmd "no enc mode wep mandatory\n" "config-if" 5]} {
            debug $::DBLVL_WARN "Did not unset wep mode"
            incr rc
    }
    
    if {[info exists enc_mode]} {
        if {[::configurator::dut_send_cmd "$enc_mode\n" "config-if" 5]} {
            debug $::DBLVL_WARN "Did not set/unset encryption mode"
            incr rc
        }
    }
    if {[info exists enc_key]} {
        if {[::configurator::dut_send_cmd "$enc_key\n" "config-if" 5]} {
            debug $::DBLVL_WARN "Did not set/unset encryption key"
            incr rc
        }
    }

    # unset/set the ssid
    if {[::configurator::dut_send_cmd "no ssid $ssid\n" "config-if" 5]} {
        debug $::DBLVL_WARN "Did not set ssid"
        incr rc
    }
    if {[::configurator::dut_send_cmd "ssid $ssid\n" "config-if" 5]} {
        debug $::DBLVL_WARN "Did not set ssid"
        incr rc
    }
    
    # antenna settings. defaults are diversity
    if {[catch {set antenna_rx [vw_keylget this_int AntennaRx]}]} {
        set antenna_rx "DIVERSITY"
        debug $::DBLVL_INFO "No antenna setting for receive - using diversity mode"
    }
    
    if {[catch {set antenna_tx [vw_keylget this_int AntennaTx]} result]} {
        set antenna_tx "DIVERSITY"
        debug $::DBLVL_INFO "No antenna setting for transmit - using diversity mode"
    }

    set antenna_rx [string tolower $antenna_rx]
    set antenna_tx [string tolower $antenna_tx]
    
    if {[::configurator::dut_send_cmd "antenna receive $antenna_rx\n" "config-if" 5]} {
        debug $::DBLVL_WARN "Did not set antenna receive"
        incr rc
    }
    if {[::configurator::dut_send_cmd "antenna transmit $antenna_tx\n" "config-if" 5]} {
        debug $::DBLVL_WARN "Did not send antenna transmit"
        incr rc
    }

    # re-enable the interface
    if {[::configurator::dut_send_cmd "no shutdown\n" "config-if" 5]} {
        debug $::DBLVL_WARN "Did not no-shut interface"
        incr rc
    }

    # exit the sub mode
    if {[::configurator::dut_send_cmd "exit\n" "$::config_prompt" 5]} {
        debug $::DBLVL_WARN "Did not exit wireless interface mode"
        incr rc
    }
    
    return $rc
}


#
# dut_configure_epilogue - configuration to do any tasks needed before configuration
#                      is sent to the DUT
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The merged group, global and dut configuration
#
proc dut_configure_epilogue { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_epilogue"

    set rc 0
    # exit config mode
        if {[::configurator::dut_send_cmd "end\n" "$::admin_prompt" 10]} {
        debug $::DBLVL_WARN "Didn't reach admin prompt"
        incr rc
    }
    
    if {[::configurator::dut_send_cmd "write mem\n" "$::admin_prompt" 10]} {
        puts "Error: Did not find admin prompt after write mem"
        incr rc
    }

    if { $::DEBUG_LEVEL > 4 } {
        ::configurator::dut_send_cmd "term len 0\n" "$::admin_prompt" 5
        ::configurator::dut_send_cmd "show run\n"   "$::admin_prompt" 20
    }

    # close the expect connection
    after 1000
    catch {expect *}
    catch {exp_close}
    catch {wait}
    log_file
    breakable_after 5
    
    return $rc
}


#
# Print out a message, make sure the expect connection is closed and return
#
proc dut_configure_early_return { msg } {
    
    global spawn_id
    
    debug $::DBLVL_WARN $msg
    catch {exp_close}
    catch {wait}
    breakable_after 5
}


#
# Entry point for configuring all Cisco IOS APs
#
#
# dut_name    - The name of the AP to be configured
#
# group_name  - The name of the group this AP will be configured for
#
# global_name - A pointer to the global config for this test
#
proc dut_configure_cisco-cisco-ios { dut_name group_name global_name } {
 
    set func_name "dut_configure_cisco-cisco-ios"
    
    # take the passed in names, find the corresponding configs
    # and pass them down to the appropriate lower level procs.
    
    upvar #0 $dut_name    dut_cfg
    upvar #0 $group_name  group_cfg
    upvar #0 $global_name global_cfg

    # merge the group and global config together
    set cfg [::configurator::merge_config "$global_cfg" "$group_cfg"]
    set cfg [::configurator::merge_config "$cfg"        "$dut_cfg"  ]

 #    if {[dut_configure_prelude "$dut_name" "$cfg"]} {
 #        debug $::DBLVL_ERROR "Unable to get to config prompt"
 #        return -1
 #    }

    if [catch {set dut_vendor [vw_keylget cfg Vendor]}] {
        puts "Error: No Vendor defined for $dut_name"
        exit -1
    }

    if {[catch {set dut_model [vw_keylget cfg APModel]}]} {
        if [catch {set dut_model [vw_keylget cfg Model]}] {
            puts "Error: No APModel defined for $dut_name"
            exit -1
        }
    }
    
    if [catch {set dut_username [vw_keylget cfg ApUsername]}] {
        if [catch {set dut_username [vw_keylget cfg Username]}] {
            puts "Error: No ApUsername defined for $dut_name"
            exit -1
        }
    }

    if [catch {set dut_password [vw_keylget cfg ApPassword]}] {
        if [catch {set dut_password [vw_keylget cfg Password]}] {
            puts "Error: No ApPassword defined for $dut_name"
            exit -1
        }
    }

    if [catch {set dut_auth_username [vw_keylget cfg AuthUsername]}] {
        set dut_auth_username ""
    }

    if [catch {set dut_auth_password [vw_keylget cfg AuthPassword]}] {
        set dut_auth_password ""
    }

    if [catch {set dut_console_addr [vw_keylget cfg ConsoleAddr]}] {
        puts "Error: No ConsoleAddr defined for $dut_name"
        exit -1
    }

    if [catch {set dut_console_port [vw_keylget cfg ConsolePort]}] {
        set dut_console_port 23
    }
     
    set ap_vendor_dir [file join $::VW_TEST_ROOT lib $dut_vendor]
    set ap_model_dir  [file join $ap_vendor_dir $dut_model]
    
    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        puts "Error: \"$dut_name\" has no defined Method"
        exit -1
    }

    if {[catch {set group_type [vw_keylget cfg GroupType]}]} {
        puts "Error: No GroupType configured"
        exit -1
    }
        
    if { $security_method == "erase-config" } {
        if {![info exists ::reset_just_once]} {
            if {[dut_configure_erase_config $dut_name]} {
                dut_configure_early_return "Unable to clear AP"
            }
        } else {
            # if we've been told to erase the AP but not really, just fake it.
            return 0
        }
    } else {
        
        #
        # open configuration connection to DUT
        #
        if {[dut_configure_prelude   $dut_name $cfg]} {
            dut_configure_early_return "dut_configure_prelude failed"
            return 1
        }
        
        #
        # do wireless configuration
        #
        if { $group_type == "802.11abg" } {
              
            if { $::test_case_number <= 1 } {
                if { $::cisco_ios_clean_first_time } {
                    if {[dut_configure_clean_old_config $dut_name $cfg] != 0} {
                        debug $::DBLVL_ERROR "$func_name: Unable to clean $dut_name prior for test case $::test_case_number."
                        return 1
                    }
                    set ::cisco_ios_clean_first_time 0
                } else {
                    debug $::DBLVL_INFO "$func_name: skipping cleaning of old cfg (already done)."
                }
            } else {
                debug $::DBLVL_INFO "$func_name: skipping cleaning of old cfg (done prior to first testcase)."
            }

            # make sure we are still at the config prompt
            if {[dut_configure_config_prompt $dut_name $cfg]} {
                dut_configure_early_return "get to cfg prompt failed"
                return 1
            }
                    
            if {[dut_configure_aaa       $dut_name $cfg]} {
                dut_configure_early_return "dut_configure_aaa failed"
                return 1
             }
            
             if {[dut_configure_radius    $dut_name $cfg]} {
                dut_configure_early_return "dut_configure_radius failed"
                return 1
             }
            
             if {[dut_configure_wireless  $dut_name $cfg]} {
                dut_configure_early_return "dut_configure_wireless failed"
                return 1
             }
             
             if {[dut_configure_dot11     $dut_name $cfg]} {
                dut_configure_early_return "dut_configure_dot11 failed"
                return 1
             }
            
             # before we configure subif, we need to get the name of our active radio interface
             
             
             if {[catch {set channel [vw_keylget cfg Channel]}]} {
                debug $::DBLVL_INFO "\"$dut_name\" has no configured Channel.  Skipping subif config"
             } else {
            
                 if { $channel <= $::MAX_BG_CHANNEL } {
                    set active_wireless_int "Dot11Radio0"
                 } else {
                    set active_wireless_int "Dot11Radio1"
                 }
                 
                 if {[dut_configure_subif $dut_name $cfg $active_wireless_int]} {
                    dut_configure_early_return "dut_configure_subif failed for active_int $active_wireless_int"
                    return 1
                }
            }
        }

        #
        # do ethernet configuration
        #
        if { $group_type == "802.3" } {
            if {[dut_configure_eth       $dut_name $cfg]} {
                dut_configure_early_return "dut_configure_eth failed"
                return 1
            }
            
            set do_subif 1
            
            # find the ethernet interface
            if {![catch {set int_list [vw_keylget cfg Interface]}]} {
            
                foreach interface [keylkeys int_list] {
                    set int_cfg [vw_keylget int_list $interface]
                    if {[catch {set int_type [vw_keylget int_cfg InterfaceType]}]} {
                        #don't handle this way.
                        debug $::DBLVL_TRACE "setting do_subif for ethernet to zero"
                        set do_subif 0
                    }
                    if { $int_type == "802.3" } {
                        set active_ethernet_int $interface
                        break
                    }
                }
            }
            

            if {![info exists active_ethernet_int]} {
                puts "Error: No 802.3 interface found in $dut_name, skipping sub-if config"
                set do_subif 0
            }
            if { $do_subif == 1 } {
                if {[regexp BVI $active_ethernet_int]} {
                    set bvi_members [dut_find_bvi_members $dut_name $cfg $active_ethernet_int ethernet]
                    foreach bvi_member $bvi_members {
                        if {[dut_configure_subif $dut_name $cfg $bvi_member]} {
                            dut_configure_early_return "dut_configure_subif failed for active_int $bvi_member"
                        }
                    }
                } else {
                    if {[dut_configure_subif $dut_name $cfg $active_ethernet_int]} {
                        dut_configure_early_return "dut_configure_subif failed for active_int $active_ethernet_int"
                    }
                }
            }
        }

        #
        # close configuration connection to DUT
        #
        if {[dut_configure_epilogue  $dut_name $cfg]} {
            dut_configure_early_return "dut_configure_epilogue failed"
            return 1
        }
    }

    if { $security_method == "erase-config"} {
        debug $::DBLVL_INFO "Wait 2 minutes for reboot after clean ..."
        # sleep 1 second 120 times so that things like ^c can be caught
        breakable_after 120
    }
    return 0
}

