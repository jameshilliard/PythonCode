#
# thick-apxx60.tcl - configures a 3Com stand-alone (thick)
#   Access Point like the 3Com 8760 in thick mode.
#
# Generic functions to aid in the configuration.  Any one of these can be
# overridden by a function at the model level.
#
# $Id: thick-apxx60.tcl,v 1.2 2007/04/04 01:46:45 wpoxon Exp $
#

set cvs_author  [cvs_clean "$Author: wpoxon $"]
set cvs_ID      [cvs_clean "$Id: thick-apxx60.tcl,v 1.2 2007/04/04 01:46:45 wpoxon Exp $"]
set cvs_file    [cvs_clean "$RCSfile: thick-apxx60.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.2 $"]
set cvs_date    [cvs_clean "$Date: 2007/04/04 01:46:45 $"]
set cvs_release [cvs_clean "$Name: b2_4_2_rd $"]



debug $::DBLVL_CVS_VERSION "loading $cvs_file $cvs_version $cvs_date"

set ::username_prompt   "Username:"
set ::password_prompt   "Password:"

#
# CLI commands:
#
#   cli_cmd_exit_current_leveL:     leave the current config mode
#   cli_cmd_exit_all_levels:        leave all config modes (and return to enable prompt)
#
set ::cli_cmd_exit_current_level    "end"
set ::cli_cmd_exit_all_levels       "exit"

#
# Prompts to look for from this DUT
#
# cli_prompt is the normal (not enable) prompt you get just by logging in
#
# enable_prompt is the administrator-level prompt which indicates
# we are able to make config changes.
#
# On this AP, they happen to be the same because this AP does not have
# an enable mode.  Configuration changes can be made directly from the CLI prompt.
#
set ::cli_prompt     "#"
set ::enable_prompt  "#"

#
# TODO: figure out regex so we can check for (config)# as ::config_prompt
# (currently (config)# does not match, so we removed the parens
#
set ::config_prompt "config"

#
# TODO: ditto
#
set ::ap_config_prompt "config-ap"
set ::radio_interface_config_prompt "if-wireless"
set ::vap_config_prompt "VAP"

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
        ::configurator::dut_send_cmd "show system\r" "$::cli_prompt" 5
        ::configurator::dut_send_cmd "show version\r" "$::cli_prompt" 5

        #
        # set up logging on the AP (either local or to a syslog server)
        #
        if {[catch {set show_event_log [vw_keylget cfg ShowEventLog]}]} {
            debug $::DBLVL_INFO "\"$dut_name\" ShowEventLog not defined. Not displaying AP event log."
            set show_event_log "off"
        }


        if { $show_event_log == "on" } {
            #
            # TODO: need to figure out how to deal with icky pager prompts:
            # "Press <n> next. <p> previous. <a> abort. <y> continue to end :"
            # before we enable the show event-log code, or figure out how
            # to disable paging altogether like you can do on the cisco cli
            # so all the output just spills out without prompting at each page boundary.
            #
            #::configurator::dut_send_cmd "show event-log\r" "$::cli_prompt" 5
            debug $::DBLVL_TRACE "skipping show event-log"
        }
        
        ::configurator::dut_send_cmd "config\r" "$::config_prompt" 5
        if {[catch {set logging [vw_keylget cfg Logging]}]} {
            debug $::DBLVL_INFO "\"$dut_name\" Logging not defined. Defaulting to Logging = no."
            ::configurator::dut_send_cmd "no logging on\r" "$::config_prompt" 5
            ::configurator::dut_send_cmd "no logging console\r" "$::config_prompt" 5
            set logging "no"
        }

        if { $logging == "on" } {
            ::configurator::dut_send_cmd "logging on\r" "$::config_prompt" 5
            ::configurator::dut_send_cmd "logging console\r" "$::config_prompt" 5
            
             if {[catch {set logging_level [vw_keylget cfg LoggingLevel]}]} {
                 debug $::DBLVL_INFO "\"$dut_name\" LoggingLevel not defined. Defaulting to Warning."
                 ::configurator::dut_send_cmd "logging level Warning\r" "$::config_prompt" 5
             } else {
                 ::configurator::dut_send_cmd "logging level $logging_level\r" "$::config_prompt" 5
             }
        }        
        
        if {[catch {set logging_clear [vw_keylget cfg LoggingClear]}]} {
            debug $::DBLVL_INFO "\"$dut_name\" LoggingClear not defined. Not clearing log buffers in the AP."
            set logging_clear "off"
        }

        if { $logging_clear == "on" } {
            ::configurator::dut_send_cmd "logging clear\r" "$::config_prompt" 5
        }
        
        if {[catch {set logging_host [vw_keylget cfg LoggingHost]}]} {
            debug $::DBLVL_ERROR "\"$dut_name\" LoggingHost not defined. Defaulting to LoggingHost = none."
            set logging_host "none"
        }

        if { $logging_host == "none" } {
            ::configurator::dut_send_cmd "no logging host 1\r" "$::config_prompt" 5
        } else {
            ::configurator::dut_send_cmd "logging host 1 $logging_host\r" "$::config_prompt" 5
            
            if {[catch {set logging_facility [vw_keylget cfg LoggingFacility]}]} {
                 debug $::DBLVL_ERROR "\"$dut_name\" LoggingFacility not defined. Skipping logging facility config"
            } else {
                ::configurator::dut_send_cmd "logging facility $logging_facility\r" "$::config_prompt" 5
            }
        }
        
        ::configurator::dut_send_cmd "$::cli_cmd_exit_all_levels\r" "$::cli_prompt" 5
        ::configurator::dut_send_cmd "show logging\r" "$::cli_prompt" 5
        
        #
        # set up NTP for accurate timestamping of log messages
        #
        ::configurator::dut_send_cmd "config\r" "$::config_prompt" 5

        if {[catch {set sntp_server [vw_keylget cfg SntpServer]}]} {
            debug $::DBLVL_INFO "\"$dut_name\" SNTP server not defined. Skipping SNTP configuration. (AP Log message timestamps may be innacurate)"
            set sntp_server "none"
        }

        if { $sntp_server != "none" } {
            if { $sntp_server == "off" } {
                ::configurator::dut_send_cmd "no sntp-server enable\r" "$::config_prompt" 5
            } else {
                ::configurator::dut_send_cmd "sntp-server ip 1 $sntp_server\r" "$::config_prompt" 5
                ::configurator::dut_send_cmd "sntp-server enable\r" "$::config_prompt" 5
            }
        }

        if {[catch {set sntp_timezone [vw_keylget cfg SntpTimezone]}]} {
            debug $::DBLVL_INFO "\"$dut_name\" SNTP Timezone not defined. Skipping SNTP Timezone configuration. (AP Log message timestamps may be innacurate)"
            set sntp_timezone "none"
        }

        if { $sntp_timezone != "none" } {
                ::configurator::dut_send_cmd "sntp-server timezone $sntp_timezone\r" "$::config_prompt" 5
        }

        ::configurator::dut_send_cmd "$::cli_cmd_exit_all_levels\r" "$::cli_prompt" 5
        ::configurator::dut_send_cmd "show sntp\r" "$::cli_prompt" 5

        #
        # configure wireless interfaces on the DUT
        #
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
    
    if {[::configurator::dut_send_cmd "$dut_username\r" "$::password_prompt" 10]} {
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
# dut_configure_config_prompt_enable - get the AP to the enabled prompt
#
# parameters:
#   dut_name        - The name of the device to be tested.  
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_configure_config_prompt_enable { dut_name cfg } {
    
    #
    # this type of AP does not have an enable mode.
    # the plain-old CLI prompt is good enough for issuing admin commands
    #
        
    return 0
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

    set rc 0
    
    expect {

        # at password prompt
        "$::password_prompt" {
            if {[::configurator::dut_send_cmd "\r" "$::username_prompt" 5]} {
                debug $::DBLVL_WARN "$func: Didn't reach login prompt from Password prompt."
                incr rc
            }
            incr rc [dut_configure_config_prompt_cli    $dut_name $cfg]
            incr rc [dut_configure_config_prompt_enable $dut_name $cfg]
        }

        # at cli login prompt
        "$::username_prompt" {
            incr rc [dut_configure_config_prompt_cli    $dut_name $cfg]
            incr rc [dut_configure_config_prompt_enable $dut_name $cfg]
        }
        
        # at cli enable prompt - get out of any submodes we may be in
        "$::enable_prompt" {
            debug $::DBLVL_WARN "$func: Already at enable prompt (possibly in a submode)."
        }
        
        # at config prompt
        "$::config_prompt" {
            if {[::configurator::dut_send_cmd "$::cli_cmd_exit_all_levels\r" "$::cli_prompt" 5]} {
                debug $::DBLVL_WARN "$func: Didn't reach CLI prompt from Config prompt."
                incr rc
            }
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

        if {[catch {set radius_port [vw_keylget cfg RadiusServerAuthPort]}]} {
            debug $::DBLVL_INFO "$func: No RadiusServerAuthPort defined for $dut_name.  Defaulting."
            set radius_port 1812
        }

        if {[catch {set radius_secret [vw_keylget cfg RadiusServerSecret]}]} {
            debug $::DBLVL_ERROR "$func: No RadiusServerSecret defined in $dut_name"
            exit -1
        }
        
        #
        # radius client CLI cmds for the 8760-thick AP:
        #
        # TODO (question): is key below only configurable in ASCII? (no hex?)
        # 
        # (done) radius-server address <ip addr>
        # (done) radius-server enable
        # (done) radius-server key <keyword>
        # (done) radius-server port <1024-65535>
        #        radius-server port-accounting <0=disabled or port=1024-65535>
        #        radius-server radius-mac-format <multi-colon, multi-dash, no-delimeter, single-dash>
        # (done) radius-server retransmit <1-30>
        #        radius-server secondary <duplicate of this whole menu>
        # (done) radius-server timeout <1-60>
        #        radius-server timeout-interim <60-86400>
        #        radius-server vlan-format <HEX, ASCII>
        #
        
        #
        # take care of main radius config (radius server IP address, port, and key)
        #
        if {[::configurator::dut_send_config_cmd "radius-server address $radius_server\r" $::enable_prompt 5]} {
            debug $::DBLVL_ERROR "$func: Did not properly configure radius server address $radius_server"
            return 1
        }
        
        if {[::configurator::dut_send_cmd "radius-server port $radius_port\r" $::config_prompt 5]} {
            debug $::DBLVL_ERROR "$func: Did not properly configure radius server port $radius_port"
            return 1
        }

        if {[::configurator::dut_send_cmd "radius-server key $radius_secret\r" $::config_prompt 5]} {
            debug $::DBLVL_ERROR "$func: Did not properly configure radius server key $radius_secret"
            return 1
        }
        
        #
        # see if there are any additional radius parameters we need to configure
        #
        if {[catch {set radius_retransmit [vw_keylget cfg RadiusServerNumRetransmits]}]} {
            debug $::DBLVL_INFO "$func: No RadiusServerNumRetransmits defined for $dut_name. Using current settings."
        } else {
            if {[::configurator::dut_send_cmd "radius-server retransmit $radius_retransmit\r" $::config_prompt 5]} {
                debug $::DBLVL_WARN "$func: Did not properly configure radius server retransmit"
            }
        }
        
        if {[catch {set radius_timeout [vw_keylget cfg RadiusServerTimeout]}]} {
            debug $::DBLVL_INFO "$func: No RadiusServerTimeout defined for $dut_name. Using default."
        } else {
            if {[::configurator::dut_send_cmd "radius-server timeout $radius_timeout\r" $::config_prompt 5]} {
                debug $::DBLVL_WARN "$func: Did not properly configure radius server timeout"
            }
        }
        
        if {[::configurator::dut_send_cmd "radius-server enable\r" $::config_prompt 5]} {
            debug $::DBLVL_ERROR "$func: Did not properly enable radius server"
            return 1
        }
        
        # ::configurator::dut_send_cmd "dot1x system-auth-control\r" $::config_prompt 5
        # ::configurator::dut_send_cmd "aaa authentication dot1x default radius\r" $::config_prompt 5
        ::configurator::dut_send_cmd "$::cli_cmd_exit_all_levels\r" $::enable_prompt 5
        ::configurator::dut_send_cmd "show radius\r" $::enable_prompt 5
        
        debug $::DBLVL_INFO "$func: Radius server $radius_server configured for Security method \"$security_method\""

    } else {
        # ::configurator::dut_send_config_cmd "no dot1x system-auth-control\r" $::config_prompt 5
        # ::configurator::dut_send_cmd "no aaa authentication dot1x default\r" $::config_prompt 5
        # ::configurator::dut_send_cmd "$::cli_cmd_exit_all_levels\r" $::enable_prompt 5
        debug $::DBLVL_INFO "$func: Security method \"$security_method\" does not require Radius"
    }
}


#
# send a command after first making sure that we are at
# the config prompt in the CLI.
#
proc dut_send_config_cmd { cmd expected_response waitval } {

    set func "dut_send_config_cmd"
    
    #
    # Assumes: we are called from the enable prompt.
    #
    
    if {[::configurator::dut_send_cmd "config\r" $::config_prompt 5]} {
        debug $::DBLVL_WARN "$func: did not get config prompt after sending config cmd."
        if {[::configurator::dut_send_cmd "\r" $::config_prompt 5]} {
            debug $::DBLVL_ERROR "$func: unable to get to config prompt."
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
        if {[::configurator::dut_send_cmd "$::cli_cmd_exit_current_level\r" $::enable_prompt 5]} {
            debug $::DBLVL_WARN "$func: unable to return to enable prompt following failed command."
        }
        return 1
    } 
    
    return 0 
}


#
# dut_configure_vap - configure a Virtual Access Point (VAP).  Create a new one if needed
#                       of if one already exists for the same VAP Index,
#                       then modify it.
#
#   dut_name        - The name of the device to be tested.  
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_configure_vap { dut_name cfg } {
    global $dut_name
    global spawn_id

    set func "dut_configure_vap"
    
    debug $::DBLVL_TRACE "$func"
    
    #
    # Assumptions: we should be in the interface config sub-mode
    # when this function is called
    #
    if {[::configurator::dut_send_cmd "\r" $::radio_interface_config_prompt 5]} {
        debug $::DBLVL_ERROR "$func: called at incorrect CLI submode."
        debug $::DBLVL_TRACE "$func: called at invalid CLI submode.  Returning with error."
        return 1
    }
    
    if {[catch {set vap_index [vw_keylget cfg BssidIndex]}]} {
        debug $::DBLVL_ERROR "\"$dut_name\" has no BssidIndex (VAP index). Using 1."
        set vap_index 1
    }    
    
    if {[catch {set ssid [vw_keylget cfg Ssid]}]} {
        debug $::DBLVL_ERROR "\"$dut_name\" has no Ssid defined. Using \"veriwave\""
        set ssid "veriwave"
    }

    # grab the channel and figure out which Wireless interface to use
    if {[catch {set channel [vw_keylget cfg Channel]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no configured Channel.  Skipping wireless config"
        return 1
    }
    
    if { $channel <= 14 } {
        set active_int "wireless_g"
        set active_int_cli_name "g"
    } else {
        set active_int "wireless_a"
        set active_int_cli_name "a"
    }
    
    debug $::DBLVL_TRACE "$func Configuring VAP\[$vap_index\] ssid $ssid channel $channel if $active_int_cli_name"
    
    #
    # Once we know the channel, we need to do this:
    #
    # config
    #   interface wireless [a | g]
    #     [no] key <index 1-4> <length 64,128,152> <HEX,ASCII> <KEY_VALUE>
    #
    
    #::configurator::dut_send_cmd "show station\r" $::enable_prompt 5

    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no Method defined. Skipping security method config for $dut_name"
        return 0
    }

    #
    # TODO: add code in the config file to allow the user to specify a
    # key index.  For now, just use index 1.
    #
    # Below, WEP keys are set at the (if-wireless X) level
    # using: key <index 1-4> <64,128,152>  <HEX,ASCII> key_value
    #
    set key_index 1   
    
    switch $security_method {

        "WEP-Open-40"       -
        "WEP-SharedKey-40"  {
            # the CLI on this dut likes to see 40-bit keys identified as 64-bit keys.            
            set key_length 64
            set key_type "ASCII"
            if {[catch {set key [vw_keylget cfg WepKey40Ascii]}]} {
                set key_type "HEX"
                if {[catch {set key [vw_keylget cfg WepKey40Hex]}]} {
                    debug $::DBLVL_ERROR "No WepKey40Ascii or WepKey40Hex defined for use with $security_method for $dut_name."
                    return 1
                }
            }
            if {[::configurator::dut_send_cmd "key $key_index $key_length $key_type $key\r" $::radio_interface_config_prompt 5]} {
                debug $::DBLVL_ERROR "$func: Error setting $key_type $key_length key for security method $security_method on interface $active_int_cli_name."
                return 1
            }
            debug $::DBLVL_TRACE "Configured $security_method $key_type $key_length as key\[$key_index\] on i/f $active_int_cli_name."
        }
        
        "WEP-Open-128"       -
        "WEP-SharedKey-128"  {
            set key_length 128
            set key_type "ASCII"
            if {[catch {set key [vw_keylget cfg WepKey128Ascii]}]} {
                set key_type "HEX"
                if {[catch {set key [vw_keylget cfg WepKey128Hex]}]} {
                    debug $::DBLVL_ERROR "No WepKey128Ascii or WepKey128Hex defined for use with $security_method for $dut_name."
                    return 1
                }
            }
            if {[::configurator::dut_send_cmd "key $key_index $key_length $key_type $key\r" $::radio_interface_config_prompt 5]} {
                debug $::DBLVL_ERROR "$func: Error setting $key_type $key_length key for security method $security_method on interface $active_int_cli_name."
                return 1
            }
            debug $::DBLVL_TRACE "Configured $security_method $key_type $key_length as key\[$key_index\] on i/f $active_int_cli_name."
        }       

        "WPA-PSK"  -
        "WPA2-PSK"  {
            #
            # WPA-PSK keys are configured in VAP mode
            # using: wpa-pre-shared-key (hex <keyvalue> or passphrase-key <ascii_keyvalue>)   
            #
            # passphrase-key means ASCII key when configuring WPA security
            set key_type "passphrase-key"   
            if {[catch {set key [vw_keylget cfg PskAscii]}]} {
                set key_type "hex"
                if {[catch {set key [vw_keylget cfg PskHex]}]} {
                    debug $::DBLVL_ERROR "No PskAscii or PskHex defined for use with $security_method for $dut_name."
                    return 1
                }
            }
            debug $::DBLVL_TRACE "Read cfg for $security_method $key_type key for i/f $active_int_cli_name.  Will configure in VAP sub-mode."        
        }
        
        "WPA-EAP-TLS"           -
        "WPA-PEAP-MSCHAPV2"     -
        "WPA-EAP-TTLS-GTC"      -
        "WPA2-EAP-TLS"          -
        "WPA2-PEAP-MSCHAPV2"    -
        "WPA2-EAP-TTLS-GTC"     {
            #
            # TODO: nothing to do for 802.1x auth methods at the radio interface level?
            #
        }

        
        default {
            #
            # here's how we handle things on the 2475
            #
            # TODO: see if we can or need to do similar key cleanup on the 8760-thick
            #
            # if {[::configurator::dut_send_cmd "no key $key_index\r" $::radio_interface_config_prompt 5]} {
            #    debug $::DBLVL_ERROR "$func: Error removing key\[$key_index\] for security method $security_method from interface $active_int_cli_name."
            #    return 1
            # }
            #debug $::DBLVL_TRACE "Removed key\[$key_index\] for security method $security_method from i/f $active_int_cli_name."
        }
    } 

    debug $::DBLVL_TRACE "Done setting/deleting keys on i/f $active_int_cli_name for security method $security_method."
    
    #
    # enter VAP configuration mode and configure VAP settings
    #
    # vap <0-3>
    #   assoc-timeout-interval <5-60>
    #   auth (open-system, shared-key, wpa, wpa-psk, wpa-wpa2-mixed, wpa-wpa2-psk-mixed, wpa2, wpa2-psk)
    #   auth-timeout-value <5-60> - number of minutes of inactivity (no frames sent) by client before association dropped
    #   cipher-suite (aes-ccmp, tkip, wep)
    #   [no] closed-system - if closed-system then clients must have pre-configured ssid to associate (no ssid will be broadcast)
    #   [no] description <string>
    #   [no] encryption
    #   max-association <0-64> - sets the max # of clients which can associate with this AP at one time
    #   pmksa-lifetime <1-1440> minutes
    #   pre-authentication (enable, disable)
    #   [no] shutdown
    #   ssid <string>
    #   transmit-key <1-4>
    #   vlan-id <1-4094>
    #   wpa-pre-shared-key (hex <hex keyvalue>, passphrase-key <ascii keyvalue>)
    #
    
    #
    # TODO: somewhere below we should set transmit-key
    # using the same key_index as we set above so that
    # this AP can send encrypted mcast and bcast pkts.
    # Need to check docs to determine which security methods
    # require us to set transmit-key.
    #
    debug $::DBLVL_TRACE "Configuring VAP\[$vap_index\] on i/f $active_int_cli_name"
    
    if {[::configurator::dut_send_cmd "vap $vap_index\r" $::vap_config_prompt 5]} {
        debug $::DBLVL_WARN "$func: Error modifying VAP\[$vap_index\]."
        return 1
    } else {
        debug $::DBLVL_TRACE "Setting SSID for VAP\[$vap_index\] on i/f $active_int_cli_name to $ssid"
        if {[::configurator::dut_send_cmd "ssid $ssid\r" $::vap_config_prompt 5]} {
            debug $::DBLVL_WARN "$func: Error setting SSID for VAP\[$vap_index\] (SSID: $ssid)."
            return 1
        }
    }
    
    debug $::DBLVL_TRACE "Set SSID for VAP\[$vap_index\] on i/f $active_int_cli_name to $ssid"
    debug $::DBLVL_INFO "Setting security method to $security_method for VAP\[$vap_index\] $ssid on $dut_name."
    
    set need_to_configure_radius 0
    
    #
    # the WPA* modes are configured as "auth wpa* <supported|required>"
    # TODO: provide a config variable to allow user to specify supported vs. required.
    # for now, use the default provided here.
    #
    set wpa_supported_or_required "required"
    
    #
    # set the auth type and encryption modes in the VAP
    # Note: WEP are set one level before the VAP at the (if-wireless X) level
    #
    switch $security_method {

        "None"  {
            set auth "auth open-system"
            set encryption "no encryption"
        }

        "WEP-Open-40"       - 
        "WEP-Open-128"      { 
            set auth "auth open-system"
            set encryption "encryption"
        }
        
        "WEP-SharedKey-40"  -
        "WEP-SharedKey-128"  { 
            set auth "auth shared-key"
            set encryption "encryption"
        }
              
        "WPA-PSK"  {
            #
            # WPA-PSK keys are configured here in VAP mode
            # using: wpa-pre-shared-key (hex <keyvalue> or passphrase-key <ascii_keyvalue>)   
            #
            set auth "auth wpa-psk $wpa_supported_or_required"
            set encryption "encryption"
            set wpa_key_cmd "wpa-pre-shared-key $key_type $key"
        }
        
        "WPA2-PSK"  {
            #
            # WPA2-PSK keys are configured here in VAP mode
            # using: wpa-pre-shared-key (hex <keyvalue> or passphrase-key <ascii_keyvalue>)   
            #
            set auth "auth wpa2-psk $wpa_supported_or_required"
            set encryption "encryption"
            set wpa_key_cmd "wpa-pre-shared-key $key_type $key"
        }

        "WPA-EAP-TLS"           -
        "WPA-PEAP-MSCHAPV2"     -
        "WPA-EAP-TTLS-GTC"      {
            set auth "auth wpa $wpa_supported_or_required"
            set encryption "encryption"
            # TODO: ciper-suite <aes-ccmp | tkip | wep> >  ???
            set need_to_configure_radius 1
        }
        
        "WPA2-EAP-TLS"          - 
        "WPA2-PEAP-MSCHAPV2"    -
        "WPA2-EAP-TTLS-GTC"     {
            set auth "auth wpa2 $wpa_supported_or_required"
            set encryption "encryption"
            # TODO: ciper-suite <aes-ccmp | tkip | wep> >  ???
            set need_to_configure_radius 1
        }
    } 
    
    #
    # configure authentication mode for this VAP
    #        
    if {[::configurator::dut_send_cmd "$auth\r" $::vap_config_prompt 5]} {
        debug $::DBLVL_ERROR "Error setting $auth on $dut_name VAP\[$vap_index\]."
        return 1
    }
    debug $::DBLVL_TRACE "Configured $auth on $dut_name VAP\[$vap_index\]."
    
    #
    # configure encryption mode for this VAP
    #
    if {[::configurator::dut_send_cmd "$encryption\r" $::vap_config_prompt 5]} {
        debug $::DBLVL_ERROR "Error setting $encription on $dut_name VAP\[$vap_index\]."
        return 1
    }
    debug $::DBLVL_TRACE "Configured $encryption on $dut_name VAP\[$vap_index\]."
    
    #
    # set WPA/WPA2 keys if we're running WPA-PSK or WPA2-PSK
    #
    switch $security_method {
        "WPA-PSK"  -
        "WPA2-PSK"  {
            if {[::configurator::dut_send_cmd "$wpa_key_cmd\r" $::vap_config_prompt 5]} {
                debug $::DBLVL_WARN "$func: Error setting wpa/wpa2 key for VAP\[$vap_index\]: $wpa_key_cmd."
                return 1
            }
            debug $::DBLVL_TRACE "Configured wpa/wpa2 key for VAP\[$vap_index\]: $wpa_key_cmd."
        }
    }
    
    debug $::DBLVL_TRACE "Configured new security method $security_method"
    #        
    # TODO: add support for configuring vlan's in the VAP
    #   (if-wireless X: VAP[N])# vlan-id <1-4094>
    #
    set vlan_id 1
    
    if {[::configurator::dut_send_cmd "vlan-id $vlan_id\r" $::vap_config_prompt 5]} {
        debug $::DBLVL_WARN "$func: Error configuring VLAN\[$vlan_id\] on VAP\[$vap_index\]."
        return 1
    }
 
    if {[::configurator::dut_send_cmd "no shutdown\r" $::vap_config_prompt 5]} {
        debug $::DBLVL_WARN "$func: Error enabling (no shutdown) VAP\[$vap_index\]."
        return 1
    }
    debug $::DBLVL_TRACE "Enabled VAP\[$vap_index\] using no shutdown."
       
    if {[::configurator::dut_send_cmd "$::cli_cmd_exit_all_levels\r" $::enable_prompt 5]} {
        debug $::DBLVL_WARN "Error returning to enable prompt after configuring security method $security_method for VAP $ssid."
        return 1
    }
      
    debug $::DBLVL_TRACE "Displaying WLAN vap config after setting new security method $security_method"
    ::configurator::dut_send_cmd "show station\r" $::enable_prompt 5  

    #
    # TODO: move this so we call it from dut_configure_wireless
    # instead of at the end of dut_configure_vap
    # (but we first need to add the logic in dut_configure_wireless to know
    # if radius is needed or not)
    #
    if { $need_to_configure_radius } {
        dut_configure_radius $dut_name $cfg    
    }
        
    debug $::DBLVL_TRACE "$func returning success"
    return 0
}


#
# dut_configure_radio_interface_parameter:
#
# TODO: remove un-needed parameters such as ap_mac_addr
#
# ap_mac_addr - the mac address of the AP we are programming
# radio_interface_name (should be 802.11a or 802.11g)
# parameter_set_command - the command string (such as "channel 1") we want to send to the AP.
#
# returns 0 on success on nonzero on failure if we are unable to set the requested parameter
#
proc dut_configure_radio_interface_parameter { ap_mac_addr radio_interface_name parameter_set_command } {

    debug $::DBLVL_TRACE "dut_configure_radio_interface_parameter $ap_mac_addr $radio_interface_name, $parameter_set_command"
    debug $::DBLVL_INFO "dut_configure_radio_interface_parameter $parameter_set_command"
    
    if {[::configurator::dut_send_cmd "$parameter_set_command\r" $::radio_interface_config_prompt 5]} {
        debug $::DBLVL_ERROR "Unable to set radio interface parameter for AP $ap_mac_addr interface $radio_interface_name: $parameter_set_command"
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
    
    set func "dut_configure_wireless"
    
    debug $::DBLVL_TRACE "$func $dut_name"

    if {[catch {set country_code [vw_keylget cfg CountryCode]}]} {
        debug $::DBLVL_ERROR "\"$dut_name\" has no CountryCode. (defaulting to \"us\")."
        set country_code "us"
    }
    
    #
    # TODO: enable this when a bug in the 2.1.13_sh firmware which
    # causes a crash when you set the country code to US gets fixed.
    # the same bug causes all telnet sessions to be dropped when you set
    # the country code to FR.
    #
    # skip setting of country code for now
    #
    # if {[::configurator::dut_send_cmd "country $country_code\r" $::cli_prompt 5]} {
    #    debug $::DBLVL_WARN "$func: Did not properly configure country code $country_code (continuing)"
    #}
    
    if {[catch {set ap_mac_addr [vw_keylget cfg ApMacAddr]}]} {
        debug $::DBLVL_ERROR "\"$dut_name\" has no ApMacAddr. Skipping wireless configuration."
        return 1
    }   
    
    #
    # configure parameters on the radio interface such as
    # channel number, power level, which vap to use, etc...
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
    
    #
    # TODO: add a common function (in configurator) and call it here
    # to tell us whether a valid security method has been specified.
    #
    # new code in configurator.tcl can just be a simple switch statement
    # with all the security typs we know about.  The default (unknown) case
    # should be the error case.
    #
    
    if { $channel <= 14 } {
        set active_int "wireless_g"
        set active_int_cli_name "g"
    } else {
        set active_int "wireless_a"
        set active_int_cli_name "a"
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
    
    if {[catch {set power [vw_keylget this_int Power]}]} {
        debug $::DBLVL_INFO "No power level set for $dut_name for interface $active_int, defaulting to $default_power"
        set power "$default_power"
    }

    #
    # Once we know the channel, we need to do this:
    #
    # config
    # interface wireless g
    #
    # (done)    antenna control (left, right, diversity)
    # (done)    beacon-interval  <20-1000> (milliseconds)
    #           bridge role (ap, bridge, repeater, root-bridge)
    #           bridge-link (child 1-6, parent x:x:x:x:x:x, path-cost N, port-priority N)
    # (done)    channel
    #             for b/g: (1-14, auto)
    #             for a non-turbo: (36, 40, 44, 48, 52, 56, 60, 64, 149, 153, 157, 161, 165, auto)
    #             for a turbo: (42, 50, 58, 152, 160, auto)
    #           dtim-period (1-255)
    #           fragmentation-length (256-2346)
    # (done)    [no] key <index 1-4> <length 64,128,152> <HEX,ASCII> <KEY_VALUE>
    #           MIC_mode (hardware, software)
    #           multicast-data-rate (1, 2, 5.5, 11)
    # (done)    preamble - (short-or-long, long)
    #           protection-method (CTS-only, RTS-CTS)
    #           radio-mode (b, g, b+g)    - for 802.11g radios only
    #           [no] rogue-ap (authenticate, enable, interval, scan)
    #           rts-threshold (0-2347)
    #           speed (1, 2, 5.5, 6, 9, 11, 12, 18, 24, 36, 48, 54)
    #           [no] super-g
    # (done)    transmit-power (full, half, quarter, eighth, min)
    #           [no] turbo
    
    # vap <0-3>
    #   assoc-timeout-interval <5-60>
    #   auth (open-system, shared-key, wpa, wpa-psk, wpa-wpa2-mixed, wpa-wpa2-psk-mixed, wpa2, wpa2-psk)
    #   auth-timeout-value <5-60> - number of minutes of inactivity (no frames sent) by client before association dropped
    #   cipher-suite (aes-ccmp, tkip, wep)
    #   [no] closed-system - if closed-system then clients must have pre-configured ssid to associate (no ssid will be broadcast)
    #   [no] description <string>
    #   [no] encryption
    #   max-association <0-64> - sets the max # of clients which can associate with this AP at one time
    #   pmksa-lifetime <1-1440> minutes
    #   pre-authentication (enable, disable)
    #   [no] shutdown
    #   ssid <string>
    #   transmit-key <1-4>
    #   vlan-id <1-4094>
    #   wpa-pre-shared-key (hex <hex keyvalue>, passphrase-key <ascii keyvalue>)
    #
    # wmm (supported, required)
    # wmm-acknowledge-policy <0-3> (Ack, NoAck)
    # wmmpraram (ap, bss) <0-3> ...
    
    #
    # set dot1x mode in AP if required by the security type
    # we are using
    #
    switch $security_method {
      
        "WPA-EAP-TLS"           -
        "WPA-PEAP-MSCHAPV2"     -
        "WPA-EAP-TTLS-GTC"      -
        "WPA2-EAP-TLS"          -
        "WPA2-PEAP-MSCHAPV2"    -
        "WPA2-EAP-TTLS-GTC"     {
                   
            #
            # 8760 cli cmds
            #
            # config
            #   802.1x <required or supported>
            #           required forces all clients to use 802.1x auth
            #           supported allows clients to do 802.1x if THEY initiate it
            #           or 802.11 auth if they do not speak 802.1x (probably preferred)
            #           In supported mode, the AP will not initiate 802.1x authentication
            #
            #   show auth - prints 802.1x auth config information/state
            #
            #   802.1x broadcast-key-refresh-rate <0-1440 minutes>
            #   802.1x session-key-refresh-rate <0-1440 minutes>
            #   802.1x session-timeout <0-1440 minutes>
            #   802.1x supplicant user <username> <password>
            #
            
            #
            # TODO: figure out of if this is really okay to set required
            # here (since it is not at the VAP level, will it disrupt
            # other tests when we run in a multi-VAP configuration?
            #
            set dot1x_cmd "802.1x required"
            
            #
            # TODO: ciper-suite <aes-ccmp | tkip | wep> >  ???
            #
        }
        
        default {
            set dot1x_cmd "802.1x supported"
        }
    }
 
    if {[::configurator::dut_send_config_cmd "$dot1x_cmd\r" $::config_prompt 5]} {
        debug $::DBLVL_ERROR "$func: Error setting dot1x mode: $dot1x_cmd"
        return 1
    }
    
    if {[::configurator::dut_send_cmd "$::cli_cmd_exit_current_level\r" $::enable_prompt 5]} {
        debug $::DBLVL_ERROR "$func: Error returning to CLI prompt after dot1x cmd"
        return 1
    }
    
    #
    # enter the CLI configuration mode for this wireless interface
    #         
    if {[::configurator::dut_send_config_cmd "interface wireless $active_int_cli_name\r" $::radio_interface_config_prompt 5]} {
        debug $::DBLVL_ERROR "dut_configure_wireless: Error entering radio interface cfg mode for $active_int_cli_name."
        return 1
    }
    
    #
    # configure channel
    #
    debug $::DBLVL_TRACE "Setting radio channel for $dut_name interface $active_int to $channel"
    if {[dut_configure_radio_interface_parameter $ap_mac_addr $active_int_cli_name "channel $channel"]} {
        debug $::DBLVL_WARN "Unable to set radio channel for $dut_name interface $active_int_cli_name to $channel"
    } else {
        debug $::DBLVL_INFO "Set radio channel for $dut_name interface $active_int to $channel"
    }

    #
    # configure transmit-power
    #
    debug $::DBLVL_TRACE "Setting power level for $dut_name interface $active_int to $power"
    if {[dut_configure_radio_interface_parameter $ap_mac_addr $active_int_cli_name "transmit-power $power"]} {
        debug $::DBLVL_WARN "Unable to set power level for $dut_name interface $active_int to $power"
    } else {
        debug $::DBLVL_INFO "Set power level for $dut_name interface $active_int to $power"
    }

    #
    # configure antenna
    #
    debug $::DBLVL_TRACE "Setting antenna for $dut_name interface $active_int to $antenna"
    if {[dut_configure_radio_interface_parameter $ap_mac_addr $active_int_cli_name "antenna control $antenna"]} {
        debug $::DBLVL_WARN "Unable to set antenna for $dut_name interface $active_int to $antenna"
    } else {
        debug $::DBLVL_INFO "Set antenna for $dut_name interface $active_int to $antenna"
    }

    #
    # configure BeaconPeriod
    #
    if {[catch {set beacon_period [vw_keylget this_int BeaconPeriod]}]} {
        debug $::DBLVL_INFO "No BeaconPeriod set for $dut_name for interface $active_int"
    } else {
        debug $::DBLVL_TRACE "Setting beacon period for $dut_name interface $active_int to $beacon_period"
        if {[dut_configure_radio_interface_parameter $ap_mac_addr $active_int_cli_name "beacon-interval $beacon_period"]} {
            debug $::DBLVL_WARN "Unable to set beacon period for $dut_name interface $active_int to $beacon_period"
        } else {
            debug $::DBLVL_INFO "Set beacon period for $dut_name interface $active_int to $beacon_period"
        }
    }

    #
    # configure Preamble
    #
    if {[catch {set preamble [vw_keylget this_int Preamble ]}]} {
        debug $::DBLVL_INFO "No Preamble set for $dut_name for interface $active_int"
    } else {
        debug $::DBLVL_TRACE "Set preamble for $dut_name interface $active_int to $preamble"
        if {[dut_configure_radio_interface_parameter $ap_mac_addr $active_int_cli_name "preamble $preamble"]} {
            debug $::DBLVL_WARN "Unable to set preamble for $dut_name interface $active_int to $preamble"
        } else {
            debug $::DBLVL_INFO "Set preamble for $dut_name interface $active_int to $preamble"
        }
    }

    #
    # do VAP configuration (which includes setting security methods, keys, etc...)
    #
    debug $::DBLVL_TRACE "$func calling dut_configure_vap"
    if {[dut_configure_vap $dut_name $cfg]} {
        debug $::DBLVL_TRACE "$func: dut_configure_vap returned an error."
        debug $::DBLVL_TRACE "$func: returning and propogating error return from dut_configure_vap."
        return 1
    }

    debug $::DBLVL_TRACE "$func: dut_configure_vap returned OK"

    debug $::DBLVL_TRACE "$func: returning OK"
    
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
    if {[::configurator::dut_send_cmd "$::cli_cmd_exit_all_levels\r" "closed" 5]} {
        debug $::DBLVL_WARN "Unable to exit config mode"
    }

    # close the expect connection
    catch {exp_close}
    catch {wait}
    log_file
    breakable_after 2
}



