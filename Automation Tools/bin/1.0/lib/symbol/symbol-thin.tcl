#
# symbol.tcl - configures a Symbol access point (device-under-test)
#
# Generic functions to aid in the configuration.  Any one of these can be
# overridden by a function at the model level.
#
# $Id: symbol-thin.tcl,v 1.3.6.1 2007/09/13 20:40:35 manderson Exp $
#

set cvs_author  [cvs_clean "$Author: manderson $"]
set cvs_ID      [cvs_clean "$Id: symbol-thin.tcl,v 1.3.6.1 2007/09/13 20:40:35 manderson Exp $"]
set cvs_file    [cvs_clean "$RCSfile: symbol-thin.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.3.6.1 $"]
set cvs_date    [cvs_clean "$Date: 2007/09/13 20:40:35 $"]
set cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

debug $::DBLVL_CVS_VERSION "loading $cvs_file $cvs_version $cvs_date"

set ::admin_prompt  "#"
set ::config_prompt "\\\(config\\\)#"
set ::wireless_prompt "\\\(config-wireless\\\)"


#
# dut_configure_symbol - top level procedure to configure a Symbol AP
#
# dut_name    - The name of the AP to be configured
#
# group_name  - The name of the group this AP will be configured for
#
# global_name - A pointer to the global config for this test
#
proc dut_configure_symbol { dut_name group_name global_name } {
    
    global $dut_name

    debug $::DBLVL_TRACE "dut_configure_symbol"
    
    # take the passed in names, find the corresponding configs
    # and pass them down to the appropriate lower level procs.
    upvar #0 $dut_name    dut_cfg
    upvar #0 $group_name  group_cfg
    upvar #0 $global_name global_cfg

    # merge the group and global config together
    set cfg [::configurator::merge_config "$global_cfg" "$group_cfg"]
    set cfg [::configurator::merge_config "$cfg"        "$dut_cfg"  ]
    
    if [catch {set dut_vendor [vw_keylget cfg Vendor]}] {
        puts "Error: No Vendor defined for $dut_name"
        exit -1
    }

    # only need to configure wireless groups
    if {[catch {set group_type [vw_keylget cfg GroupType]}]} {
        puts "Error: No GroupType for group $group_name"
        exit -1 
    }

    if { $group_type == "802.3" } {
        return 0
    }

    if {[catch {set dut_model [vw_keylget cfg APModel]}]} {
        if [catch {set dut_model [vw_keylget cfg Model]}] {
            puts "Error: No APModel defined for $dut_name"
            exit -1
        }
        debug $::DBLVL_WARN "MODEL deprecated.  Please use APModel"
    }
    
    if {[catch {set dut_username [vw_keylget cfg ApUsername]}]} {
        if {[catch {set dut_username [vw_keylget cfg Username]}]} {
            puts "Error: No ApUsername defined for $dut_name"
            exit -1
        }
        debug $::DBLVL_WARN "USERNAME deprecated.  Please use ApUsername"
    }

    if [catch {set dut_password [vw_keylget cfg ApPassword]}] {
        if {[catch {set dut_password [vw_keylget cfg Password]}]} {
            puts "Error: No ApPassword defined for $dut_name"
            exit -1
        }
        debug $::DBLVL_WARN "PASSWORD deprecated.  Please use ApPassword"
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
    
    if {[dut_configure_prelude $dut_name $cfg]} {
        puts "Error: Unable to get to config prompt"
        return -1
    }
        
    dut_configure_wireless  $dut_name $cfg
    dut_configure_epilogue  $dut_name $cfg
    
    ping_pause $dut_console_addr

    return 0
}


#
# dut_configure_config_prompt_cli - get logged into a Symbol AP
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The configuration keyed list
#
proc dut_configure_config_prompt_cli { dut_name cfg } {
    
    if {[catch {set dut_username [vw_keylget cfg ApUsername]}]} {
        if [catch {set dut_username [vw_keylget cfg Username]}] {
            puts "Error: No ApUsername defined for $dut_name"
            exit -1
        }
        debug $::DBLVL_WARN "USERNAME deprecated.  Please use ApUsername"
    }

    if {[catch {set dut_password [vw_keylget cfg ApPassword]}]} {
        if [catch {set dut_password [vw_keylget cfg Password]}] {
            puts "Error: No PASSWORD defined for $dut_name"
            exit -1
        }
        debug $::DBLVL_WARN "PASSWORD deprecated.  Please use ApPassword"
    }

    set rc 0
    
    if {[::configurator::dut_send_cmd "$dut_username\n" "Password:" 5]} {
        incr rc
        debug $::DBLVL_WARN "Didn't find password prompt"
    }
    
    if {[::configurator::dut_send_cmd "$dut_password\n" ">" 5]} {
        incr rc
        debug $::DBLVL_WARN "Did not find login prompt"
    }
    
    return $rc
}


#
# dut_configure_config_prompt_enable - get a Symbol AP to the enabled prompt
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The configuration keyed list
#
proc dut_configure_config_prompt_enable { dut_name cfg } {
    
    set rc 0
    
    catch {set dut_auth_password [vw_keylget cfg AuthPassword]}

    ::configurator::dut_send_cmd "ena\n" "." 5
    if {[info exists dut_auth_password]} {
        if {[::configurator::dut_send_cmd "$dut_auth_password\n" "$::admin_prompt" 5]} {
            debug $::DBLVL_WARN "Didn't reach admin prompt"
            incr rc
        }
    }
        
    return $rc
}


#
# dut_configure_config_prompt_conf_t - get a Symbol AP from a login prompt to a config prompt
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The configuration keyed list
#
proc dut_configure_config_prompt_conf_t { dut_name cfg } {
    
    set rc 0
    
    if {[::configurator::dut_send_cmd "conf t\n" "$::config_prompt" 5]} {
        debug $::DBLVL_WARN "Did not reach configure prompt"
        incr rc
    }
    
    return $rc
}


#
# dut_configure_config_prompt - get a Symbol AP from any state to the config prompt.
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The configuration keyed list
#
proc dut_configure_config_prompt { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_prompt"

    # kick the console
    send "\r"
    sleep 1

    set rc 0
    
    expect {

        # unix prompt
        -re "login: " {
            if {[::configurator::dut_send_cmd "cli\n" "Username:" 5]} {
                debug $::DBLVL_WARN "Didn't find CLI Username prompt"
                incr rc
            }
            incr rc [dut_configure_config_prompt_cli    $dut_name $cfg]
            incr rc [dut_configure_config_prompt_enable $dut_name $cfg]
            incr rc [dut_configure_config_prompt_conf_t $dut_name $cfg]
        }

        # at password prompt
        "Password:" {
            if {[::configurator::dut_send_cmd "\n" "Username:" 5]} {
                debug $::DBLVL_WARN "Didn't reach login prompt."
                incr rc
            }
            incr rc [dut_configure_config_prompt_cli    $dut_name $cfg]
            incr rc [dut_configure_config_prompt_enable $dut_name $cfg]
            incr rc [dut_configure_config_prompt_conf_t $dut_name $cfg]
        }

        # at cli login prompt
        "Username:" {
            incr rc [dut_configure_config_prompt_cli    $dut_name $cfg]
            incr rc [dut_configure_config_prompt_enable $dut_name $cfg]
            incr rc [dut_configure_config_prompt_conf_f $dut_name $cfg]
        }

        default {
            debug $::DBLVL_WARN "Unknown prompt found."
            incr rc
        }
    }
    
    return $rc
}


#
# dut_configure_prelude - setup to get an AP ready to be configured
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The configuration keyed list
#
proc dut_configure_prelude { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_prelude"
    
    # need the console address and port
    if {[catch {set console_addr [vw_keylget cfg ConsoleAddr]}]} {
        puts "Error: No ConsoleAddr for $dut_name"
        exit -1
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
    dut_configure_config_prompt $dut_name $cfg
}


#
# dut_configure_radius - configure radius server
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The configuration keyed list
#
proc dut_configure_radius { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_radius"
    
    
    # grab the channel and figure out which Wireless interface to use
    if {[catch {set channel [vw_keylget cfg Channel]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no configured Channel.  Skipping wireless config"
        return 0
    }

    if { $channel <= 11 } {
        set active_int "11bg"
    } else {
        set active_int "11a"
    }
    
    if {![catch {set this_int_list [vw_keylget cfg Interface]}]} {
        if {[catch {set this_int [vw_keylget this_int_list $active_int]}]} {
            puts "Error: No interface \"$active_int\" defined for $dut_name"
            exit -1
        }
    } else {
        puts "Error: DUT $dut_name has no Interface section"
        exit -1
    }
    
    if {[catch {set wlan_idx [vw_keylget cfg BssidIndex]}]} {
        debug $::DBLVL_INFO "No BssidIndex (wlan index) configured for group, using 1"
        set wlan_idx 1
    }

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
            debug $::DBLVL_INFO "No RadiusServerAuthPort defined for $dut_name.  Defaulting."
            set radius_auth 1812
        }
        
        if {[catch {set radius_secret [vw_keylget cfg RadiusServerSecret]}]} {
            puts "Error: No RadiusServerSecret defined in $dut_name"
            exit -1
        }
        
        if {[::configurator::dut_send_cmd "wlan $wlan_idx radius server primary $radius_server auth-port $radius_auth\n" $::wireless_prompt 5]} {
            debug $::DBLVL_WARN "Did not properly configure radius secret"
        }

        if {[::configurator::dut_send_cmd "wlan $wlan_idx radius server primary radius-key 0 $radius_secret\n" $::wireless_prompt 5]} {
            debug $::DBLVL_WARN "Did not properly configure radius secret"
        }
    } else {
        if {[::configurator::dut_send_cmd "no wlan $wlan_idx radius server primary\n" $::wireless_prompt 5]} {
            debug $::DBLVL_WARN "Did not remove radius server"
        }
    }
}


#
# dut_configure_wireless_wlan - configure things at the wlan sub-mode
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The configuration keyed list
#
proc dut_configure_wireless_wlan { dut_name cfg } {

    global spawn_id

    debug $::DBLVL_TRACE "dut_configure_wireless_wlan"

    # grab the channel and figure out which Wireless interface to use
    if {[catch {set channel [vw_keylget cfg Channel]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no configured Channel.  Skipping wireless config"
        return 0
    }

    if { $channel <= 11 } {
        set active_int "11bg"
    } else {
        set active_int "11a"
    }
    
    if {![catch {set this_int_list [vw_keylget cfg Interface]}]} {
        if {[catch {set this_int [vw_keylget this_int_list $active_int]}]} {
            puts "Error: No interface \"$active_int\" defined for $dut_name"
            exit -1
        }
    } else {
        puts "Error: DUT $dut_name has no Interface section"
        exit -1
    }
    
    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        puts "Error: \"$dut_name\" has no defined Method"
        exit -1
    }
    
    if {[catch {set wlan_idx [vw_keylget cfg BssidIndex]}]} {
        debug $::DBLVL_INFO "No BssidIndex (wlan index) configured for group, using 1"
        set wlan_idx 1
    }
    
    switch $security_method {

        "None"               -
        "WEP-Open-40"        -
        "WEP-Open-128"       -
        "WEP-SharedKey-40"   -
        "WEP-SharedKey-128"  -
        "WPA2-PSK-TKIP"      -
        "WPA-PSK-AES"        -
        "WPA-PSK"            -
        "WPA2-PSK"           {
            set authentication "none"
        }

        "WPA-EAP-TLS"        -
        "WPA-EAP-TTLS-GTC"   -
        "WPA-PEAP-MSCHAPV2"  -
        "WPA2-PEAP-MSCHAPV2-TKIP" -
        "WPA-PEAP-MSCHAPV2-AES" - 
        "WPA2-EAP-TLS"       -
        "WPA2-EAP-TTLS-GTC"  -
        "WPA2-PEAP-MSCHAPV2" -
        "WPA2-PEAP-MSCHAPV2-TKIP" -
        "WPA-PEAP-MSCHAPV2-AES" -
        "DWEP-EAP-TLS"       -
        "DWEP-EAP-TTLS-GTC"  -
        "DWEP-PEAP-MSCHAPV2" {
            set authentication "eap"
        }

        default {
            debug $::DBLVL_WARN "Unsupported method $security_method - authentication"
            set authentication "none"
        }
    }
    if {[::configurator::dut_send_cmd "wlan $wlan_idx authentication-type $authentication\n" $::wireless_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set authentication type"
    }

    switch $security_method {

        "None"               {
            set encryption "none"
        }

        "WEP-Open-40"        -
        "WEP-SharedKey-40"   {
            set encryption "wep64"
        }

        "WEP-Open-128"       -
        "WEP-SharedKey-128"  -
        "DWEP-EAP-TLS"       -
        "DWEP-EAP-TTLS-GTC"  -
        "DWEP-PEAP-MSCHAPV2" {
            set encryption "wep128"
        }

        "WPA-EAP-TLS"        -
        "WPA-EAP-TTLS-GTC"   -
        "WPA-PEAP-MSCHAPV2"  -
        "WPA2-PEAP-MSCHAPV2-TKIP" - 
        "WPA2-PSK-TKIP"      -
        "WPA-PSK"            {
            set encryption "tkip"
        }


        "WPA2-EAP-TLS"       -
        "WPA2-EAP-TTLS-GTC"  -
        "WPA2-PEAP-MSCHAPV2" -
        "WPA-PSK-AES"        -
        "WPA-PEAP-MSCHAPV2-AES" - 
        "WPA2-PSK"           {
            set encryption "ccmp"
        }

        default {
            debug $::DBLVL_WARN "Unsupported method $security_method - encryption"
            set encryption "none"
        }
    }
    if {[::configurator::dut_send_cmd "wlan $wlan_idx encryption-type $encryption\n" $::wireless_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set encryption"
    }


    # get/set the WEP/PSK keys
    switch $security_method {

        "None"               -
        "WPA-EAP-TLS"        -
        "WPA-EAP-TTLS-GTC"   -
        "WPA2-EAP-TTLS-GTC"  -
        "WPA-PEAP-MSCHAPV2"  -
        "WPA2-PEAP-MSCHAPV2" -
        "WPA2-PEAP-MSCHAPV2-TKIP" -
        "WPA-PEAP-MSCHAPV2-AES" -
        "DWEP-EAP-TLS"       -
        "DWEP-EAP-TTLS-GTC"  -
        "DWEP-PEAP-MSCHAPV2" -
        "WPA2-EAP-TLS"       {
            if {[::configurator::dut_send_cmd "no wlan $wlan_idx wep64 key 1\n" $::wireless_prompt 5]} {
                debug $::DBLVL_WARN "Unable to remove 64 bit WEP key"
            }
            if {[::configurator::dut_send_cmd "no wlan $wlan_idx wep128 key 1\n" $::wireless_prompt 5]} {
                debug $::DBLVL_WARN "Unable to remove 128 bit WEP key"
            }
            if {[::configurator::dut_send_cmd "no wlan $wlan_idx dot11i key\n" $::wireless_prompt 5]} {
                debug $::DBLVL_WARN "Unable to remove 64 bit PSK key"
            }
            if {[::configurator::dut_send_cmd "no wlan $wlan_idx dot11i phrase\n" $::wireless_prompt 5]} {
                debug $::DBLVL_WARN "Unable to remove 64 bit PSK phrase"
            }
        }   

        "WEP-Open-40"       -
        "WEP-SharedKey-40"  {
            set key_type "ascii"
            if {[catch {set wep [vw_keylget cfg WepKey40Ascii]}]} {
                set key_type "hex"
                if {[catch {set wep [vw_keylget cfg WepKey40Hex]}]} {
                    set key_type "ascii"
                    set wep "12345"
                }
            }

            if {[::configurator::dut_send_cmd "wlan $wlan_idx wep64 key 1 $key_type 0 $wep\n" $::wireless_prompt 5]} {
                debug $::DBLVL_WARN "Unable to set 64 bit WEP key"
            }
        }

        "WEP-Open-128"      -
        "WEP-SharedKey-128" {
            set key_type "ascii"
            if {[catch {set wep [vw_keylget cfg WepKey128Ascii]}]} {
                set key_type "hex"
                if {[catch {set wep [vw_keylget cfg WepKey128Hex]}]} {
                    set key_type "ascii" 
                    set wep "123456789ABCD"
                }
            }

            if {[::configurator::dut_send_cmd "wlan $wlan_idx wep128 key 1 $key_type 0 $wep\n" $::wireless_prompt 5]} {
                debug $::DBLVL_WARN "Unable to set 128 bit WEP key"
            }
        }

        "WPA-PSK"           -
        "WPA-PSK-AES"       -
        "WPA2-PSK-TKIP"     -
        "WPA2-PSK"          {
            set key_type "phrase"
            if [catch {set psk [vw_keylget cfg PskAscii]}] {
                set key_type "key"
                if [catch {set psk [vw_keylget cfg PskHex]}] {
                    set key_type "phrase"
                    set psk "whatever"
                }
            }
            if {[::configurator::dut_send_cmd "wlan $wlan_idx dot11i $key_type 0 $psk\n" $::wireless_prompt 5]} {
                debug $::DBLVL_WARN "Unable to set PSK key"
            }
        }

        default {
            debug $::DBLVL_WARN "Unsupported method $security_method - keys"
        }
    }

    set dut_ssid [::configurator::find_ssid $dut_name $cfg $active_int]
    
    # remove the previously configured wlan
    # XXX - is this necessary on this platform?
    if {[catch {set prev_wlan [keylget ::configurator::user_config ssid_is_method]}]} {
        set prev_wlan $dut_ssid
    }
    if { $prev_wlan == "" } {
        set prev_wlan $dut_ssid
    }
    if {[catch {keylset ::configurator::user_config ssid_is_method $dut_ssid} result]} {
        debug $::DBLVL_INFO "Unable to store old SSID - $result"
    }

    if {[::configurator::dut_send_cmd "wlan $wlan_idx ssid $dut_ssid\n" $::wireless_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set SSID"
    }

    # the Veriwave box trips and stumbles if this is enabled
    if {[::configurator::dut_send_cmd "no wlan $wlan_idx secure-beacon\n" $::wireless_prompt 5]} {
        debug $::DBLVL_WARN "Did not set ESSID beacon mode"
    }

    if {[catch {set bcast [string tolower [vw_keylget cfg SsidBroadcast]]}]} {
        debug $::DBLVL_INFO "No SsidBroadcast defined in config.  Defaulting to enabled"
        set bcast "enable"
    }

    # in case the DUT config was based on another vendor
    if { $bcast == "enable" || $bcast == "true" } {
        if {[::configurator::dut_send_cmd "wlan $wlan_idx answer-bcast-ess\n" $::wireless_prompt 5]} {
            debug $::DBLVL_WARN "Did not set accept broadcast essid"
        }
    }
    
    if {[::configurator::dut_send_cmd "wlan $wlan_idx enable\n" $::wireless_prompt 5]} {
        debug $::DBLVL_WARN "Unable to enable wlan index $wlan_idx"
    }
}

    
#
# dut_configure_wireless - configure things at the radio sub-mode
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The configuration keyed list
#
proc dut_configure_wireless_radio { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_wireless_radio"

    if {[catch {set ap_mac [vw_keylget cfg ApMacAddr]}]} {
        puts "Error: No ApMacAddr defined for $dut_name."
        exit -1
    }

    if {[catch {set channel [vw_keylget cfg Channel]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no configured Channel.  Skipping radio config"
        return 0
    }

    if { $channel <= 11 } {
        set active_int "11bg"
    } else {
        set active_int "11a"
    }
    
    if {![catch {set this_int_list [vw_keylget cfg Interface]}]} {
        if {[catch {set this_int [vw_keylget this_int_list $active_int]}]} {
            puts "Error: No interface \"$active_int\" defined for $dut_name"
            exit -1
        }
    } else {
        puts "Error: DUT $dut_name has no Interface section"
        exit -1
    }
    
    if {[catch {set radio_idx [vw_keylget this_int RadioIdx]}]} {
        debug $::DBLVL_INFO "No RadioIdx configured for $dut_name:$this_int, using 1"
        set radio_idx 1
    }
    
    if {[catch {set ap_model [vw_keylget cfg APModel]}]} {
        debug $::DBLVL_INFO "No ApModel defined.  How'd we get this far?  Using ap300"
        set ap_model ap300
    }
    
    # remove any -'s in the model name
    set ap_model [regsub -all -- {-} $ap_model {}]
    
    if {[::configurator::dut_send_cmd "no radio $radio_idx\n" $::wireless_prompt 5]} {
        debug $::DBLVL_WARN "Did not remove old radio"
    }
    
    if {[::configurator::dut_send_cmd "radio add $radio_idx $ap_mac $active_int $ap_model\n" $::wireless_prompt 5]} {
        debug $::DBLVL_WARN "Did not add new radio"
    }
    
    if {[catch {set placement [vw_keylget this_int Placement]} result]} {
        set placement "indoor"
        debug $::DBLVL_INFO "Defaulting to indoors placement"
    }

    if {[catch {set power [vw_keylget this_int Power]}]} {
        debug $::DBLVL_INFO "No power level set for $dut_name - $active_int, defaulting to 4"
        set power "4"
    }

    # get/set the channel
    # grab the channel and figure out which Wireless interface to use
    if {[catch {set channel [vw_keylget cfg Channel]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no configured Channel.  Skipping wireless config"
        return 0
    }

    if {[::configurator::dut_send_cmd "radio $radio_idx channel-power $placement $channel $power\n" $::wireless_prompt 5]} {
        debug $::DBLVL_WARN "Didn't set channel/power/location"
    }

    if {[catch {set wlan_idx [vw_keylget cfg BssidIndex]}]} {
        debug $::DBLVL_INFO "No BssidIndex (wlan index) configured for group, using 1"
        set wlan_idx 1
    }
    
    # save this wlan index for configuration
    catch {keylset ::configurator::$dut_name\_wlan $wlan_idx $wlan_idx}
    set indexes ""
    foreach key [keylkeys ::configurator::$dut_name\_wlan] {
        append indexes "$key,"
    }
    set indexes [string trimright $indexes ","]
    
    if {[::configurator::dut_send_cmd "radio $radio_idx bss auto $indexes\n" $::wireless_prompt 5]} {
        debug $::DBLVL_WARN "Did not set radio to wlan mapping"
    }

    if {[catch {set antenna_diversity [vw_keylget this_int AntennaDiversity]} result]} {
        set antenna_diversity "diversity"
        debug $::DBLVL_INFO "No antenna diversity setting - using full diversity mode"
    }

    set antenna_diversity [string tolower $antenna_diversity]
    if {[::configurator::dut_send_cmd "radio $radio_idx antenna-mode $antenna_diversity\n" $::wireless_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set diversity"
    }
}


#
# dut_configure_wireless - configure things at the wireless sub-mode
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The configuration keyed list
#
proc dut_configure_wireless { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_wireless"

    if {[::configurator::dut_send_cmd "wireless\n" $::wireless_prompt 5]} {
        debug $::DBLVL_WARN "Did not reach network.wireless prompt"
    }
    
    if {[::configurator::dut_send_cmd "manual-wlan-mapping enable \n" $::wireless_prompt 5]} {
        debug $::DBLVL_WARN "Did not enable manual wlan mapping"
    }
    
    dut_configure_wireless_wlan  $dut_name $cfg
    dut_configure_wireless_radio $dut_name $cfg
    dut_configure_radius         $dut_name $cfg

    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        puts "Error: \"$dut_name\" has no defined Method"
        exit -1
    }
    
    switch $security_method {

        "None"               -
        "WEP-Open-40"        -
        "WEP-Open-128"       -
        "DWEP-EAP-TLS"       -
        "DWEP-EAP-TTLS-GTC"  -
        "DWEP-PEAP-MSCHAPV2" -
        "WPA-EAP-TLS"        -
        "WPA-EAP-TTLS-GTC"   -
        "WPA-PEAP-MSCHAPV2"  -
        "WPA-PSK"            -
        "WPA-PSK-AES"        -
        "WPA-PEAP-MSCHAPV2-AES" -
        "WPA-PEAP-MSCHAPV2-TKIP" - 
        "WPA2-EAP-TLS"       -
        "WPA2-EAP-TTLS-GTC"  -
        "WPA2-PEAP-MSCHAPV2" -
        "WPA2-PSK-TKIP"      -
        "WPA2-PSK"           {
            set shared_key "no"
        }

        "WEP-SharedKey-40"   -
        "WEP-SharedKey-128"  {
            set shared_key ""
        }

        default {
            debug $::DBLVL_WARN "Unsupported method $security_method - shared key auth"
            set shared_key ""
        }
    }
    if {[::configurator::dut_send_cmd "$shared_key dot11-shared-key-auth enable\n" $::wireless_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set shared key authentication"
    }
    
    # exit the wireless mode
    if {[::configurator::dut_send_cmd "exit\n" $::config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to leave network sub-mode"
    }
}


#
# dut_configure_epilogue - configuration to do any tasks needed before
#                      configuration is sent to the DUT
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The configuration keyed list
#
proc dut_configure_epilogue { dut_name cfg } {
    global $dut_name
    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_epilogue"
    
    if {[::configurator::dut_send_cmd "end\n" "#" 5]} {
        debug $::DBLVL_WARN "Unable to exit config mode"
    }

    if {[::configurator::dut_send_cmd "write mem\n" "#" 5]} {
        debug $::DBLVL_WARN "Unable to save configuration"
    }
    
    # close the expect connection
    catch {exp_close}
    catch {wait}
    log_file
    breakable_after 2
}

