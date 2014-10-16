#
# wlc-2475.tcl - configures a 3Com Managed Access Point (MAP)
#
# Generic functions to aid in the configuration.  Any one of these can be
# overridden by a function at the model level.
#
# $Id: wlc-2475.tcl,v 1.2 2007/04/04 01:46:45 wpoxon Exp $
#

set cvs_author  [cvs_clean "$Author: wpoxon $"]
set cvs_ID      [cvs_clean "$Id: wlc-2475.tcl,v 1.2 2007/04/04 01:46:45 wpoxon Exp $"]
set cvs_file    [cvs_clean "$RCSfile: wlc-2475.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.2 $"]
set cvs_date    [cvs_clean "$Date: 2007/04/04 01:46:45 $"]
set cvs_release [cvs_clean "$Name: b2_4_2_rd $"]



debug $::DBLVL_CVS_VERSION "loading $cvs_file $cvs_version $cvs_date"

#
# Prompts to look for from this DUT
#
# cli_prompt is the normal (not enable) prompt you get just by logging in
#
# enable_prompt is the administrator-level prompt which indicates
# we are able to make config changes.
#
set ::cli_prompt     ">"
set ::enable_prompt  "#"

#
# TODO: figure out regex so we can check for (config)# as ::config_prompt
# (currently (config)# does not match, so we removed the parens
#
set ::config_prompt "config"

#
# TODO: same as above except we want to see (config-ess)# as the prompt in the regex
#
set ::ess_config_prompt "config-ess"

#
# TODO: ditto
#
set ::ap_config_prompt "config-ap"
set ::radio_interface_config_prompt "config-ap-radio-if"


#
# dut_configure_3Com - top level procedure to configure a 3Com AP
#
# dut_name    - The name of the AP to be configured
#
# group_name  - The name of the group this AP will be configured for
#
# global_name - A pointer to the global config for this test
#
proc dut_configure_3Com { dut_name group_name global_name } {
    
    global $dut_name

    debug $::DBLVL_TRACE "dut_configure_3Com group_name = $group_name  global_name = $global_name"

    #
    # number of seconds we recommend the user tell vw_auto.tcl to wait
    # between configuring the radios on this dut (which may entail a reboot
    # of the AP) and when the test begins to run and scans for BSSID's.
    #
    # The intent of this pause is to allow the AP to fully initialize
    # and bring up its radios before the WT-90 begins to scan for BSSID's.
    #
    # If this value is too short, the tests which run on the WT-90
    # will fail immediately with a "did not find any BSSID's on channel X" msg
    #
    set recommended_dut_pause 30
    
    # take the passed in names, find the corresponding configs
    # and pass them down to the appropriate lower level procs.
    
    upvar #0 $dut_name    dut_cfg
    upvar #0 $group_name  group_cfg
    upvar #0 $global_name global_cfg

    # merge the group and global config together
    set cfg [::configurator::merge_config "$global_cfg" "$group_cfg"]
    set cfg [::configurator::merge_config "$cfg"        "$dut_cfg"  ]
    
    if {[catch {set group_type [vw_keylget cfg GroupType]}]} {
        debug $::DBLVL_ERROR "Error: No GroupType for group $group_name" 
        return 1
    }  

    if { $group_type == "802.3" } {
        debug $::DBLVL_INFO "No ethernet configuration needed."
        return 0
    }

    if {[dut_configure_prelude   $dut_name $cfg]} {
        debug $::DBLVL_ERROR "Error: Unable to get to config prompt"
        return 1
    }
        
    if { $group_type == "802.11abg" } {
        ::configurator::dut_send_cmd "show system\r" "#" 5
        ::configurator::dut_send_cmd "show wlan aps\r" "#" 5

        debug $::DBLVL_TRACE "dut_configure_3Com: wlan parms before we change anything"
        ::configurator::dut_send_cmd "show wlan ess configuration\r" "#" 5

        debug $::DBLVL_TRACE "dut_configure_3Com: Beginning Wireless Configuration"
        if {[dut_configure_wireless  $dut_name $cfg]} {
            debug $::DBLVL_TRACE "dut_configure_3Com: Failed Wireless Configuration"
            dut_configure_epilogue  $dut_name $cfg
            return 1
        }
        debug $::DBLVL_TRACE "dut_configure_3Com: Completed Wireless Configuration"
    }

    dut_configure_epilogue  $dut_name $cfg

    if {[catch {set console_addr [vw_keylget cfg ConsoleAddr]}]} {
        debug $::DBLVL_ERROR "No ConsoleAddr for $dut_name"
        return 1
    }
    
    #
    # check to make sure the user has configured an appropriate pause
    # for this type of DUT before the test begins
    #
    if {$::DUT_PAUSE < $recommended_dut_pause } {
        debug $::DBLVL_WARN "DUT_PAUSE is only $::DUT_PAUSE seconds.  $recommended_dut_pause is recommended for this device."
        debug $::DBLVL_WARN "use vw_auto.tcl --pause $recommended_dut_pause to adjust this value"
    }
    
    #
    # pause to let the configuration changes take effect
    # and for the radios on the DUT to initialize and start
    # sending beacons before we launch the test and
    # scan for BSSID's on the configured radio channel
    #
    ping_pause $console_addr
    
    return 0
}


#
# dut_configure_config_prompt_cli - get logged into a 3Com AP
#
# parameters:
#   dut_name        - The name of the device to be tested.  
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_configure_config_prompt_cli { dut_name cfg } {
    
    if {[catch {set dut_username [vw_keylget cfg ApUsername]}]} {
        if [catch {set dut_username [vw_keylget $dut_name Username]}] {
            debug $::DBLVL_ERROR "Error: No ApUsername defined for $dut_name"
            return 1
        }
        debug $::DBLVL_WARN "USERNAME deprecated.  Please use ApUsername"
    }

    if {[catch {set dut_password [vw_keylget cfg ApPassword]}]} {
        if [catch {set dut_password [vw_keylget cfg Password]}] {
            debug $::DBLVL_ERROR "Error: No PASSWORD defined for $dut_name"
            return 1
        }
        debug $::DBLVL_WARN "PASSWORD deprecated.  Please use ApPassword"
    }

    set rc 0
    
    if {[::configurator::dut_send_cmd "$dut_username\r" "Password:" 10]} {
        incr rc
        debug $::DBLVL_WARN "Didn't find password prompt"
    }
    
    if {[::configurator::dut_send_cmd "$dut_password\r" "$::cli_prompt" 5]} {
        incr rc
        debug $::DBLVL_WARN "Did not find login prompt"
    }
    
    return $rc
}


#
# dut_configure_config_prompt_enable - get a 3Com AP to the enabled prompt
#
# parameters:
#   dut_name        - The name of the device to be tested.  
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_configure_config_prompt_enable { dut_name cfg } {
    
    set rc 0
    
    catch {set dut_auth_password [vw_keylget cfg AuthPassword]}

    ::configurator::dut_send_cmd "enable\r" "." 5
    if {[info exists dut_auth_password]} {
        if {[::configurator::dut_send_cmd "$dut_auth_password\r" "$::enable_prompt" 5]} {
            debug $::DBLVL_WARN "Didn't reach enable prompt"
            incr rc
        }
    }
        
    return $rc
}


#
# dut_configure_enable_prompt - get a 3Com AP from any state
# to the enable prompt.
#
# parameters:
#   dut_name        - The name of the device to be tested.  
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_configure_enable_prompt { dut_name cfg } {
    global $dut_name
    global spawn_id
    
    set func "dut_configure_enable_prompt"
    debug $::DBLVL_TRACE "$func"

    # kick the console
    #send "\r"
    #sleep 1

    set rc 0
    
    expect {

        # at enable password prompt - send 3 <c/r> to get back to CLI prompt
        #"Enter password:" {
        #    if {[::configurator::dut_send_cmd "\r\r\r" "$::cli_prompt" 5]} {
        #        debug $::DBLVL_WARN "$func: Didn't reach CLI prompt from enable password prompt."
        #        incr rc
        #    }
        #    incr rc [dut_configure_config_prompt_enable $dut_name]
        #}

        # at password prompt
        "Password:" {
            if {[::configurator::dut_send_cmd "\r" "User Name:" 5]} {
                debug $::DBLVL_WARN "$func: Didn't reach login prompt from Password prompt."
                incr rc
            }
            incr rc [dut_configure_config_prompt_cli    $dut_name $cfg]
            incr rc [dut_configure_config_prompt_enable $dut_name $cfg]
        }

        # at cli login prompt
        "User Name:" {
            incr rc [dut_configure_config_prompt_cli    $dut_name $cfg]
            incr rc [dut_configure_config_prompt_enable $dut_name $cfg]
        }
        
        # at cli prompt
        "$::cli_prompt" {
            incr rc [dut_configure_config_prompt_enable $dut_name $cfg]
        }

        # at cli enable prompt - get out of any submodes we may be in
        "$::enable_prompt" {
            debug $::DBLVL_WARN "$func: Already at enable prompt (possibly in a submode)."
            
            # if {[::configurator::dut_send_cmd "end\r" "$::enable_prompt" 5]} {
            #    debug $::DBLVL_WARN "$func: Didn't reach CLI enable prompt from enable prompt (possibly in a submode)."
            #    incr rc
            # }          
        }
        default {
            debug $::DBLVL_WARN "$func: Unknown prompt found."
            incr rc
        }
    }
    
    return $rc
}


#
# dut_configure_prelude - setup to get an AP ready to be configured
#
# parameters:
#
#   dut_name        - The name of the device to be tested.  
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_configure_prelude { dut_name cfg } {
    global $dut_name
    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_prelude"
    
    # need the console address and port
    if {[catch {set console_addr [vw_keylget cfg ConsoleAddr]}]} {
        debug $::DBLVL_ERROR "Error: No ConsoleAddr for $dut_name"
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

    # get to the enable prompt
    dut_configure_enable_prompt $dut_name $cfg
}


#
# dut_configure_radius - configure radius server
#
#   dut_name        - The name of the device to be tested.  
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_configure_radius { dut_name cfg } {
    global $dut_name
    global spawn_id
    
    set func "dut_configure_radius"
    debug $::DBLVL_TRACE "$func $dut_name"

    #
    # TODO: see if we can remove this for wlc-2475 firmware versions later than 01.01.14.sh
    #
    # For now, we need to pause here to let the radius configuration
    # be absorbed by the system before proceeding with radio configuration
    # to avoid bad pkts being exchanged between the 2475 and the thin AP.
    #
    set radius_config_delay_hack 45
        
    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        debug $::DBLVL_INFO "$func: \"$dut_name\" has no Method defined. Skipping wireless config"
        return 0
    }
    
    # one big if statement to match all auth methods needing radius
    if { [::configurator::method_needs_radius $security_method ] } {
        
        if {[catch {set radius_server [vw_keylget $dut_name RadiusServerAddr]}]} {
            debug $::DBLVL_ERROR "$func: No RadiusServerAddr defined for $dut_name"
            exit -1
        }

        if {[catch {set radius_auth [vw_keylget cfg RadiusServerAuthPort]}]} {
            debug $::DBLVL_INFO "$func: No RadiusServerAuthPort defined for $dut_name.  Defaulting."
            set radius_auth 1812
        }

        if {[catch {set radius_secret [vw_keylget cfg RadiusServerSecret]}]} {
            debug $::DBLVL_ERROR "$func: No RadiusServerSecret defined in $dut_name"
            exit -1
        }

        debug $::DBLVL_INFO "$func: Pausing $radius_config_delay_hack seconds before we begin radius config"
        breakable_after $radius_config_delay_hack
        
        #
        # take care of main radius config (radius server IP address, port, and key)
        #
        if {[::configurator::dut_send_config_cmd "radius-server host $radius_server auth-port $radius_auth key $radius_secret\r" $::enable_prompt 5]} {
            debug $::DBLVL_WARN "$func: Did not properly configure radius server"
        }

        #
        # see if there are any secondary radius parameters we need to configure
        #
        if {[catch {set radius_retransmit [vw_keylget cfg RadiusServerNumRetransmits]}]} {
            debug $::DBLVL_INFO "$func: No RadiusServerNumRetransmits defined for $dut_name. Using default."
            if {[::configurator::dut_send_cmd "no radius-server retransmit\r" $::config_prompt 5]} {
                debug $::DBLVL_WARN "$func: Did not properly configure radius server retransmit default"
            }
        } else {
            if {[::configurator::dut_send_cmd "radius-server retransmit $radius_retransmit\r" $::config_prompt 5]} {
                debug $::DBLVL_WARN "$func: Did not properly configure radius server retransmit"
            }
        }
        
        if {[catch {set radius_timeout [vw_keylget cfg RadiusServerTimeout]}]} {
            debug $::DBLVL_INFO "$func: No RadiusServerTimeout defined for $dut_name. Using default."
            if {[::configurator::dut_send_cmd "no radius-server timeout\r" $::config_prompt 5]} {
                debug $::DBLVL_WARN "$func: Did not properly configure radius server timeout default"
            }
        } else {
            if {[::configurator::dut_send_cmd "radius-server timeout $radius_timeout\r" $::config_prompt 5]} {
                debug $::DBLVL_WARN "$func: Did not properly configure radius server timeout"
            }
        }
    
        # ::configurator::dut_send_cmd "dot1x system-auth-control\r" $::config_prompt 5
        # ::configurator::dut_send_cmd "aaa authentication dot1x default radius\r" $::config_prompt 5
        ::configurator::dut_send_cmd "end\r" $::enable_prompt 5
        ::configurator::dut_send_cmd "show radius-servers\r" $::enable_prompt 5
        
        debug $::DBLVL_INFO "$func: Radius server $radius_server configured for Security method \"$security_method\""


        debug $::DBLVL_INFO "$func: Pausing $radius_config_delay_hack seconds after radius config before we begin radio config"
        breakable_after $radius_config_delay_hack

    } else {
        # ::configurator::dut_send_config_cmd "no dot1x system-auth-control\r" $::config_prompt 5
        # ::configurator::dut_send_cmd "no aaa authentication dot1x default\r" $::config_prompt 5
        # ::configurator::dut_send_cmd "end\r" $::enable_prompt 5
        debug $::DBLVL_INFO "$func: Security method \"$security_method\" does not require Radius"
    }
}


#
# send a command after first making sure that we are at
# the config prompt in the CLI.
#
proc dut_send_config_cmd { cmd expected_response waitval } {

    set func "dut_send_config_cmd"
    
    if {[::configurator::dut_send_cmd "\r" $::enable_prompt 5]} {
        debug $::DBLVL_WARN "$func: unable to get find enable prompt."
        return 1
    }
    
    if {[::configurator::dut_send_cmd "config\r" $::config_prompt 5]} {
        if {[::configurator::dut_send_cmd "\r" $::config_prompt 5]} {
            debug $::DBLVL_WARN "$func: unable to get to config prompt."
            return 1
        }
    }
  
    #
    # We are in config mode in the CLI, go ahead and send the command
    #
    if {[::configurator::dut_send_cmd "$cmd\r" $expected_response $waitval]} {
        debug $::DBLVL_WARN "$func: ($cmd) did not receive expected response."
        #
        # attempt to get back to the enable prompt following this error
        #
        if {[::configurator::dut_send_cmd "end\r" $::enable_prompt 5]} {
            debug $::DBLVL_WARN "$func: unable to return to enable prompt following failed command."
        }
        return 1
    } 
    
    return 0 
}


#
# dut_configure_ess - configure an ESS.  Create a new one if needed
#                       of if one already exists for the same ESS Index,
#                       then modify it.
#
#   dut_name        - The name of the device to be tested.  
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_configure_ess { dut_name cfg } {
    global $dut_name
    global spawn_id

    if {[catch {set ess_index [vw_keylget cfg BssidIndex]}]} {
        debug $::DBLVL_ERROR "\"$dut_name\" has no BssidIndex. Skipping ESS configuration."
        return 1
    }    
    
    if {[catch {set ess_ssid [vw_keylget cfg Ssid]}]} {
        debug $::DBLVL_ERROR "\"$dut_name\" has no Ssid. (continuing without it)"
        return 1
    }

    #
    # check to see whether the EssIndex exists already or not
    #
    # this tells us whether we need to modify an existing ESS or add a new one
    #
    debug $::DBLVL_TRACE "dut_configure_ess: checking to see if ess index $ess_index exists"
    set need_to_create_ess 0    
    if {![::configurator::dut_send_cmd "show wlan ess configuration $ess_index\r" "No such instance" 5]} {
        set need_to_create_ess 1
        debug $::DBLVL_INFO "Did not find an existing Ess for index $ess_index.  Will create one."
    } else {
        debug $::DBLVL_INFO "Found an existing Ess for index $ess_index.  Will modify it."
    }
    
    if { $need_to_create_ess } {
        #
        # create a new ESS
        #
        debug $::DBLVL_TRACE "creating ess index $ess_index"
        if {[::configurator::dut_send_config_cmd "wlan ess create $ess_index \"$ess_ssid\"\r" "No such instance" 5]} {
            debug $::DBLVL_ERROR "Error creating new ESS for index $ess_index (SSID: $ess_ssid)."
            return 1
        }   
    } else {
        #
        # modify an existing ESS
        #
        debug $::DBLVL_TRACE "modifying ess index $ess_index"
        if {[::configurator::dut_send_config_cmd "wlan ess configure id $ess_index\r" $::ess_config_prompt 5]} {
            debug $::DBLVL_WARN "Error modifying ESS index $ess_index (SSID: $ess_ssid)."
            return 1
        } else {
            if {[::configurator::dut_send_cmd "ssid $ess_ssid\r" $::ess_config_prompt 5]} {
                debug $::DBLVL_WARN "Error modifying ESS SSID for index $ess_index (SSID: $ess_ssid)."
                return 1
            } else {
                if {[::configurator::dut_send_cmd "end\r" $::enable_prompt 5]} {
                    debug $::DBLVL_WARN "Error returning to enable prompt after configuring ESS SSID for index $ess_index (SSID: $ess_ssid)."
                    return 1
                }
            }
        }
    }
    
    #
    # Set security mode in the ESS
    #
    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no Method defined. Skipping security method config for $dut_name"
        return 0
    }
    
    debug $::DBLVL_INFO "Setting security method to $security_method for ESS $ess_ssid on $dut_name."
    debug $::DBLVL_TRACE "removing security suites from ESS $ess_ssid on $dut_name."
    
    if {[::configurator::dut_send_config_cmd "wlan ess configure ssid $ess_ssid\r" $::ess_config_prompt 5]} {
        debug $::DBLVL_WARN "Error reaching ess config prompt to set security mode for ESS index $ess_ssid."
        return 1
    }
    
    #
    # remove any security suites which  may be configured on this ESS
    #
    # TODO: if we find out we need to support multiple security methods per SSID
    # (instead of using separate SSID's for each unique security method) then we
    # need move this "clear all the methods out of the ESS for this SSID" code
    # down into the None case below and get smarter about teaching the other
    # security methods about whether they need to create new security methods
    # using "security suite create <method> <keytype> <key>" if an entry for
    # a given security method does not yet exist, and to use
    # "security suite modify ... " if a given security method already has
    # an entry defined in the ESS for this SSID.
    #
    foreach method { 802.1x open-shared-wep open-wep shared-wep wpa wpa-psk wpa2 wpa2-psk } {
        debug $::DBLVL_INFO "removing security method $method from ESS $ess_ssid on $dut_name."
        if {[::configurator::dut_send_cmd "no security suite create $method\r" $::ess_config_prompt 5]} {
            debug $::DBLVL_ERROR "Error removing security method $method from ESS $ess_ssid on $dut_name."
            return 1
        }
    }
    
    debug $::DBLVL_TRACE "removed security suites from ESS $ess_ssid on $dut_name.  Configuring new security method $security_method"
    debug $::DBLVL_TRACE "Configuring new security method $security_method"
    
    set need_to_configure_radius 0
    
    switch $security_method {

        "None"  {
             debug $::DBLVL_TRACE "Configured new security method $security_method"         
        }

        "WEP-Open-40"       {
            set key_type "key-ascii"
            if {[catch {set key [vw_keylget cfg WepKey40Ascii]}]} {
                set key_type "key-hex"
                if {[catch {set key [vw_keylget cfg WepKey40Hex]}]} {
                    debug $::DBLVL_ERROR "No WepKey40Ascii or WepKey40Hex defined for use with $security_method for ESS $ess_ssid."
                    return 1
                }
            }
            if {[::configurator::dut_send_cmd "security suite create open-wep $key_type $key\r" $::ess_config_prompt 5]} {
                debug $::DBLVL_ERROR "Error adding security method $security_method with $key_type $key to ESS $ess_ssid on $dut_name."
                return 1
            }
            debug $::DBLVL_TRACE "Configured new security method $security_method"
        }
        
        "WEP-SharedKey-40"  {
            set key_type "key-ascii"
            if {[catch {set key [vw_keylget cfg WepKey40Ascii]}]} {
                set key_type "key-hex"
                if {[catch {set key [vw_keylget cfg WepKey40Hex]}]} {
                    debug $::DBLVL_ERROR "No WepKey40Ascii or WepKey40Hex defined for use with $security_method for ESS $ess_ssid."
                    return 1
                }
            }
            if {[::configurator::dut_send_cmd "security suite create shared-wep $key_type $key\r" $::ess_config_prompt 5]} {
                debug $::DBLVL_ERROR "Error adding security method $security_method with $key_type $key to ESS $ess_ssid on $dut_name."
                return 1
            }
            debug $::DBLVL_TRACE "Configured new security method $security_method"
        }

        "WEP-Open-128"       {
            set key_type "key-ascii"
            if {[catch {set key [vw_keylget cfg WepKey128Ascii]}]} {
                set key_type "key-hex"
                if {[catch {set key [vw_keylget cfg WepKey128Hex]}]} {
                    debug $::DBLVL_ERROR "No WepKey128Ascii or WepKey128Hex defined for use with $security_method for ESS $ess_ssid."
                    return 1
                }
            }
            if {[::configurator::dut_send_cmd "security suite create open-wep $key_type $key\r" $::ess_config_prompt 5]} {
                debug $::DBLVL_ERROR "Error adding security method $security_method with $key_type $key to ESS $ess_ssid on $dut_name."
                return 1
            }
            debug $::DBLVL_TRACE "Configured new security method $security_method"
        }
        
        "WEP-SharedKey-128"  {
            set key_type "key-ascii"
            if {[catch {set key [vw_keylget cfg WepKey128Ascii]}]} {
                set key_type "key-hex"
                if {[catch {set key [vw_keylget cfg WepKey128Hex]}]} {
                    debug $::DBLVL_ERROR "No WepKey128Ascii or WepKey128Hex defined for use with $security_method for ESS $ess_ssid."
                    return 1
                }
            }
            if {[::configurator::dut_send_cmd "security suite create shared-wep $key_type $key\r" $::ess_config_prompt 5]} {
                debug $::DBLVL_ERROR "Error adding security method $security_method with $key_type $key to ESS $ess_ssid on $dut_name."
                return 1
            }
            debug $::DBLVL_TRACE "Configured new security method $security_method"
        }
                
        "WPA-PSK"  {
            set key_type "key-ascii"
            set key "no-key"
            if {[catch {set key [vw_keylget cfg PskAscii]}]} {
                debug $::DBLVL_ERROR "No PskAscii defined for use with $security_method for ESS $ess_ssid (key = $key)."
                return 1
            }
            if {[::configurator::dut_send_cmd "security suite create wpa-psk $key_type $key\r" $::ess_config_prompt 5]} {
                debug $::DBLVL_ERROR "Error adding security method $security_method with $key_type $key to ESS $ess_ssid on $dut_name."
                return 1
            }
            debug $::DBLVL_TRACE "Configured new security method $security_method"
        }
        
        "WPA2-PSK"  {
            set key_type "key-ascii"
            if {[catch {set key [vw_keylget cfg PskAscii]}]} {
                debug $::DBLVL_ERROR "No PskAscii defined for use with $security_method for ESS $ess_ssid."
                return 1
            }
            if {[::configurator::dut_send_cmd "security suite create wpa2-psk $key_type $key\r" $::ess_config_prompt 5]} {
                debug $::DBLVL_ERROR "Error adding security method $security_method with $key_type $key to ESS $ess_ssid on $dut_name."
                return 1
            }
        }

        "DWEP-EAP-TTLS-GTC"     -
        "DWEP-EAP-TLS"          -
        "DWEP-PEAP-MSCHAPV2"    -
        "WPA-EAP-TLS"           -
        "WPA2-EAP-TLS"          - 
        "WPA-PEAP-MSCHAPV2"     -
        "WPA2-PEAP-MSCHAPV2"    -
        "WPA-EAP-TTLS-GTC"      -
        "WPA2-EAP-TTLS-GTC"     -
        "WPA-LEAP"              -
        "WPA2-LEAP"             -
        "LEAP"                  {

            set key_type "key-ascii"
            if {[::configurator::dut_send_cmd "security suite create 802.1x\r" $::ess_config_prompt 5]} {
                debug $::DBLVL_ERROR "Error adding security method $security_method with $key_type $key to ESS $ess_ssid on $dut_name."
                return 1
            }
            
            set need_to_configure_radius 1
        }   
    } 
    
    # TODO: add support for configuring vlan's in the ESS
    #   (config-wlan-ess)# security suite configure vpa
    #   (config-ess-security)# vlan 5
    
    debug $::DBLVL_TRACE "Configured new security method $security_method"
    
    if {[::configurator::dut_send_cmd "end\r" $::enable_prompt 5]} {
        debug $::DBLVL_WARN "Error returning to enable prompt after configuring security method $security_method for ESS $ess_ssid."
        return 1
    }
    
    debug $::DBLVL_TRACE "Displaying WLAN ess config after setting new security method $security_method"  
    ::configurator::dut_send_cmd "show wlan ess configuration\r" "#" 5 
    
    if { $need_to_configure_radius } {
        dut_configure_radius $dut_name $cfg    
    }
    
    debug $::DBLVL_TRACE "dut_configure_ess returning success"
    return 0
}


#
# dut_configure_radio_interface_parameter:
#
# ap_mac_addr - the mac address of the AP we are programming
# radio_interface_name (should be 802.11a or 802.11g)
# parameter_set_command - the command string (such as "channel 1") we want to send to the AP.
#
# performs this dialog with the AP to set a radio interface parameter:
#
#   ap2475(config)# wlan ap 00:16:e0:01:53:80 config
#   ap2475(config-ap)# interface radio 802.11g
#   ap2475(config-ap-radio-if)# channel 1
#   ap2475(config-ap-radio-if)# end
#
# returns 0 on success on nonzero on failure if we are unable to set the requested parameter
#
proc dut_configure_radio_interface_parameter { ap_mac_addr radio_interface_name parameter_set_command } {

    debug $::DBLVL_TRACE "dut_configure_radio_interface_parameter $ap_mac_addr $radio_interface_name, $parameter_set_command"
    debug $::DBLVL_INFO "dut_configure_radio_interface_parameter $parameter_set_command"

    if {![::configurator::dut_send_cmd "\r" $::config_prompt 5]} {
        debug $::DBLVL_INFO "dut_configure_radio_interface_parameter found config prompt, returning to enable prompt."
        if {[::configurator::dut_send_cmd "end\r" $::enable_prompt 5]} {
            debug $::DBLVL_WARN "Error returning to enable prompt before configuring radio interface parameter for AP $ap_mac_addr interface $radio_interface_name: $parameter_set_command."
            return 1
        }
    }
     
    if {[::configurator::dut_send_config_cmd "wlan ap $ap_mac_addr config\r" $::ap_config_prompt 5]} {
        debug $::DBLVL_WARN "Error setting radio interface parameter for AP $ap_mac_addr."
        return 1
    }
    
    if {[::configurator::dut_send_cmd "interface radio $radio_interface_name\r" $::radio_interface_config_prompt 5]} {
        debug $::DBLVL_WARN "Error setting radio interface parameter for AP $ap_mac_addr interface $radio_interface_name."
        return 1
    }
    
    if {[::configurator::dut_send_cmd "$parameter_set_command\r" $::radio_interface_config_prompt 5]} {
        debug $::DBLVL_WARN "Error setting radio interface parameter for AP $ap_mac_addr interface $radio_interface_name: $parameter_set_command"
    }
            
    if {[::configurator::dut_send_cmd "end\r" $::enable_prompt 5]} {
        debug $::DBLVL_WARN "Error returning to enable prompt after configuring radio interface parameter for AP $ap_mac_addr interface $radio_interface_name: $parameter_set_command."
        return 1
    }
    
    return 0 
}


#
# dut_configure_wireless - configure things at the wireless sub-mode
#
#   dut_name        - The name of the device to be tested.  
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_configure_wireless { dut_name cfg } {
    global $dut_name
    global spawn_id
    set default_power "min"
    
    debug $::DBLVL_TRACE "dut_configure_wireless $dut_name"

    if {[catch {set country_code [vw_keylget cfg CountryCode]}]} {
        debug $::DBLVL_ERROR "\"$dut_name\" has no CountryCode. (defaulting to \"us\")."
        set country_code "us"
    }
    
    if {[::configurator::dut_send_config_cmd "wlan country-code $country_code\r" $::config_prompt 5]} {
        debug $::DBLVL_WARN "$func: Did not properly configure country code $country_code (continuing)"
    }
    
    ::configurator::dut_send_cmd "no wlan tx-power off\r" $::enable_prompt 5
    ::configurator::dut_send_cmd "end\r" $::enable_prompt 5
    
    if {[dut_configure_ess $dut_name $cfg]} {
        return 1
    }

    if {[catch {set ap_mac_addr [vw_keylget cfg ApMacAddr]}]} {
        debug $::DBLVL_ERROR "\"$dut_name\" has no ApMacAddr. Skipping wireless configuration."
        return 1
    }
    
    #
    # configure parameters on the radio interface such as
    # channel number, power level, which ess to use, etc...
    #
    
    # grab the channel and figure out which Wireless interface to use
    if {[catch {set channel [vw_keylget cfg Channel]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no configured Channel.  Skipping wireless config"
        return 1
    }

    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no Method defined. Skipping wireless config"
        return 1
    }
    
    if { $channel <= 14 } {
        set active_int "wireless_g"
        set active_int_cli_name "802.11g"
    } else {
        set active_int "wireless_a"
        set active_int_cli_name "802.11a"
    }
    
    if {![catch {set this_int_list [vw_keylget cfg Interface]}]} {
        if {[catch {set this_int [vw_keylget this_int_list $active_int]}]} {
            debug $::DBLVL_ERROR "Error: No interface \"$active_int\" defined for $dut_name"
            return 1
        }
    } else {
        debug $::DBLVL_ERROR "Error: DUT $dut_name has no Interface section"
        return 1
    }
    
    if {[catch {set antenna [vw_keylget this_int Antenna]}]} {
        debug $::DBLVL_INFO "No antenna set for $dut_name for interface $active_int, using diversity"
        set antenna "diversity"
    }

    if {[catch {set bss [vw_keylget this_int Bss]}]} {
        debug $::DBLVL_WARN "No Bss set for $dut_name for interface $active_int"
    } else {
        if {[dut_configure_radio_interface_parameter $ap_mac_addr $active_int_cli_name "bss add $bss"]} {
            debug $::DBLVL_WARN "Unable to set Bss for $dut_name interface $active_int to $bss"
        } else {
            debug $::DBLVL_INFO "Set Bss for $dut_name interface $active_int to $bss"
        }
    }
    
    if {[catch {set power [vw_keylget this_int Power]}]} {
        debug $::DBLVL_INFO "No power level set for $dut_name for interface $active_int, defaulting to $default_power"
        set power "$default_power"
    }

    #
    # Once we know the channel, we need to do this:
    #
    # config
    # wlan ap <mac> config
    # interface radio 802.11g
    # (done) channel 1
    # (done) power (max, half, quarter, eighth, min)
    # allow traffic - "allows user traffic" ?!
    # (done) antenna (1, 2, diversity)
    # (done) beacon period <50-300> (milliseconds)
    # (done) bss add <ssid>
    # (done) enable - enables the radio
    # (done) preamble - (short, long)
    # rogue-detect enable - disable using no rogue-detect enable
    # rogue-detect rogue-scan-interval (short, medium, long)
    #

    if {[dut_configure_radio_interface_parameter $ap_mac_addr $active_int_cli_name "channel $channel"]} {
        debug $::DBLVL_WARN "Unable to set radio channel for $dut_name interface $active_int_cli_name to $channel"
    } else {
        debug $::DBLVL_INFO "Set radio channel for $dut_name interface $active_int to $channel"
    }
        
    if {[dut_configure_radio_interface_parameter $ap_mac_addr $active_int_cli_name "power $power"]} {
        debug $::DBLVL_WARN "Unable to set power level for $dut_name interface $active_int to $power"
    } else {
        debug $::DBLVL_INFO "Set power level for $dut_name interface $active_int to $power"
    }

    if {[dut_configure_radio_interface_parameter $ap_mac_addr $active_int_cli_name "antenna $antenna"]} {
        debug $::DBLVL_WARN "Unable to set antenna for $dut_name interface $active_int to $antenna"
    } else {
        debug $::DBLVL_INFO "Set antenna for $dut_name interface $active_int to $antenna"
    }

    if {[catch {set beacon_period [vw_keylget this_int BeaconPeriod]}]} {
        debug $::DBLVL_INFO "No BeaconPeriod set for $dut_name for interface $active_int"
    } else {
        if {[dut_configure_radio_interface_parameter $ap_mac_addr $active_int_cli_name "beacon period $beacon_period"]} {
            debug $::DBLVL_WARN "Unable to set beacon period for $dut_name interface $active_int to $beacon_period"
        } else {
            debug $::DBLVL_INFO "Set beacon period for $dut_name interface $active_int to $beacon_period"
        }
    }

    if {[catch {set preamble [vw_keylget this_int Preamble ]}]} {
        debug $::DBLVL_INFO "No Preamble set for $dut_name for interface $active_int"
    } else {
        if {[dut_configure_radio_interface_parameter $ap_mac_addr $active_int_cli_name "preamble $preamble"]} {
            debug $::DBLVL_WARN "Unable to set preamble for $dut_name interface $active_int to $preamble"
        } else {
            debug $::DBLVL_INFO "Set preamble for $dut_name interface $active_int to $preamble"
        }
    }
        
    if {[dut_configure_radio_interface_parameter $ap_mac_addr $active_int_cli_name "enable"]} {
        debug $::DBLVL_WARN "Unable to enable radio for $dut_name interface $active_int"
    } else {
        debug $::DBLVL_INFO "Enabled radio for $dut_name interface $active_int"
    }

    #
    # TODO: see circa pg 471 whether we need to configure any dot1x cmds here if we
    # for a specific interface
    # are going to be doing 802.1x authentication
    #
    # Example: 
    return 0
}


#
# dut_configure_epilogue - configuration to do any tasks needed before
#                      configuration is sent to the DUT
#
# parameters:
#
#   dut_name        - The name of the device to be tested.  
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_configure_epilogue { dut_name cfg } {
    global $dut_name
    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_epilogue"
    
    #
    # TODO: update this section so we save the running config to the startup cfg
    #
    if {[::configurator::dut_send_cmd "exit\r" "closed" 5]} {
        debug $::DBLVL_WARN "Unable to exit config mode"
    }

    # close the expect connection
    catch {exp_close}
    catch {wait}
    log_file
    breakable_after 2
}



