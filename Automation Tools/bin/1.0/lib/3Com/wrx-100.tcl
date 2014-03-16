#
# 3Com-thin.tcl - configures 3Com Managed Access Points (MAPs)
# connected to a 3Com WRX-100 Wireless LAN Controller (WLC)
#
# Generic functions to aid in the configuration.  Any one of these can be
# overridden by a function at the model level.
#
# $Id: wrx-100.tcl,v 1.3 2007/07/05 17:05:58 manderson Exp $
#

set cvs_author  [cvs_clean "$Author: manderson $"]
set cvs_ID      [cvs_clean "$Id: wrx-100.tcl,v 1.3 2007/07/05 17:05:58 manderson Exp $"]
set cvs_file    [cvs_clean "$RCSfile: wrx-100.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.3 $"]
set cvs_date    [cvs_clean "$Date: 2007/07/05 17:05:58 $"]
set cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

debug $::DBLVL_CVS_VERSION "loading $cvs_file $cvs_version $cvs_date"

set ::admin_prompt  "#"


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
    set ::configurator::3Com_clear 0

    debug $::DBLVL_TRACE "dut_configure_3Com"
    
    # take the passed in names, find the corresponding configs
    # and pass them down to the appropriate lower level procs.
    
    upvar #0 $dut_name    dut_cfg
    upvar #0 $group_name  group_cfg
    upvar #0 $global_name global_cfg

    # merge the group and global config together
    set cfg [::configurator::merge_config "$global_cfg" "$group_cfg"]
    set cfg [::configurator::merge_config "$cfg"        "$dut_cfg"  ]
    
    if {[dut_configure_prelude   $dut_name $cfg]} {
        puts "Error: Unable to get to config prompt"
        return -1
    }

    if {[::configurator::dut_send_cmd "set length 0\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set terminal length to zero to disable paging of output"
    }
    
    if {[catch {set group_type [vw_keylget cfg GroupType]}]} {
        puts "Error: No GroupType for group $group_name"
        exit -1
    }

    if { $group_type == "802.11abg" } {
        dut_configure_wireless  $dut_name $cfg
    }
    
    if { $group_type == "802.3" } {
        debug $::DBLVL_INFO "No ethernet configuration needed."
    }
    
    dut_configure_epilogue  $dut_name $cfg
    
    if {[catch {set console_addr [vw_keylget cfg ConsoleAddr]}]} {
        puts "Error: No ConsoleAddr for $dut_name"
        exit -1
    }
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
    
    debug $::DBLVL_TRACE "dut_configure_config_prompt_cli"
    
    if {[catch {set dut_username [vw_keylget cfg ApUsername]}]} {
        if [catch {set dut_username [vw_keylget $dut_name Username]}] {
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
    
    if {[::configurator::dut_send_cmd "$dut_username\r" "Password:" 10]} {
        incr rc
        debug $::DBLVL_WARN "Didn't find password prompt"
    }
    
    if {[::configurator::dut_send_cmd "$dut_password\r" ">" 5]} {
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
    
    debug $::DBLVL_TRACE "dut_configure_config_prompt_enable"
    
    set rc 0
    
    catch {set dut_auth_password [vw_keylget cfg AuthPassword]}

    ::configurator::dut_send_cmd "enable\r" "." 5
    if {[info exists dut_auth_password]} {
        if {[::configurator::dut_send_cmd "$dut_auth_password\r" "$::admin_prompt" 5]} {
            debug $::DBLVL_WARN "Didn't reach admin prompt"
            incr rc
        }
    }
        
    return $rc
}


#
# dut_configure_config_prompt - get a 3Com AP from any state
# to the config prompt.
#
# parameters:
#   dut_name        - The name of the device to be tested.  
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_configure_config_prompt { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_prompt"

    # kick the console
    #send "\r"
    #sleep 1

    set rc 0
    
    expect {

        # at enable password prompt - send 3 <c/r> to get back to CLI prompt
        "Enter password:" {
            if {[::configurator::dut_send_cmd "\r\r\r" ">" 5]} {
                debug $::DBLVL_WARN "Didn't reach CLI prompt from enable password prompt."
                incr rc
            }
            incr rc [dut_configure_config_prompt_enable $dut_name]
        }

        # at password prompt
        "Password:" {
            if {[::configurator::dut_send_cmd "\r" "Username:" 5]} {
                debug $::DBLVL_WARN "Didn't reach login prompt from Password prompt."
                incr rc
            }
            incr rc [dut_configure_config_prompt_cli    $dut_name $cfg]
            incr rc [dut_configure_config_prompt_enable $dut_name $cfg]
        }

        # at cli login prompt
        "Username:" {
            incr rc [dut_configure_config_prompt_cli    $dut_name $cfg]
            incr rc [dut_configure_config_prompt_enable $dut_name $cfg]
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
#
#   dut_name        - The name of the device to be tested.  
#
#   cfg             - The merged group, global and dut configuration
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
#   dut_name        - The name of the device to be tested.  
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_configure_radius { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_radius"
    
    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no Method defined. Skipping wireless config"
        return 0
    }
    
    # one big if statement to match all auth methods needing radius
    if { [::configurator::method_needs_radius $security_method ] } {
        if {[catch {set radius_server [vw_keylget $dut_name RadiusServerAddr]}]} {
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
        
        if {[::configurator::dut_send_cmd "set radius server server-1 address $radius_server key $radius_secret\r" $::admin_prompt 5]} {
            debug $::DBLVL_WARN "Did not properly configure radius server"
        }

        if {[::configurator::dut_send_cmd "set server group server-group-1 members server-1\r" $::admin_prompt 5]} {
            debug $::DBLVL_WARN "Did not properly set radius server group"
        }
    } else {
            debug $::DBLVL_INFO "Security method \"$security_method\" needs no Radius"
    }
}


#
# dut_configure_service_profile - configure a service profile
#
#   dut_name        - The name of the device to be tested.  
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_configure_service_profile { dut_name cfg } {

    global spawn_id

    debug $::DBLVL_TRACE "dut_configure_service_profile"

    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no Method defined. Skipping wireless config"
        return 0
    }
    
    if {[catch {set profile_name [vw_keylget cfg ServiceProfile]}]} {
        debug $::DBLVL_WARN "No service profile found,  using \"veriwave\""
        set profile_name "veriwave"
    }
    
    if {[::configurator::dut_send_cmd "set service-profile $profile_name\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to create service-profile \"$profile_name\""
    }
    
    # grab the channel and figure out which Wireless interface to use
    if {[catch {set channel [vw_keylget cfg Channel]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no configured Channel.  Skipping wireless config"
        return 0
    }
    
    if { $channel <= 14 } {
        set active_int "11g"
    } else {
        set active_int "11a"
    }
    set dut_ssid [::configurator::find_ssid $dut_name "$cfg" $active_int]

    if {[::configurator::dut_send_cmd "set service-profile $profile_name ssid-name $dut_ssid\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set SSID"
    }

    if {[catch {set bcast [string tolower [vw_keylget cfg SsidBroadcast]]}]} {
        debug $::DBLVL_INFO "No SsidBroadcast defined in config.  Defaulting to enabled"
        set bcast "enable"
    }

    if {[::configurator::dut_send_cmd "set service-profile $profile_name beacon $bcast\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set SSID beacons"
    }
    
    if {[::configurator::dut_send_cmd "set service-profile $profile_name auth-fallthru last-resort\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to disable fallthru authentication"
    }
    if {[::configurator::dut_send_cmd "set user last-resort-$dut_ssid attr vlan-name default\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set last-resort user"
    }

    dut_configure_service_profile_dot1x           "$dut_name" "$cfg" "$security_method" "$profile_name"
    dut_configure_service_profile_encryption      "$dut_name" "$cfg" "$security_method" "$profile_name"
    dut_configure_service_profile_auth_keys       "$dut_name" "$cfg" "$security_method" "$profile_name"
    dut_configure_service_profile_rsn_wpa         "$dut_name" "$cfg" "$security_method" "$profile_name"

}


proc dut_configure_service_profile_rsn_wpa {dut_name cfg security_method profile_name} {
    
    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_service_profile_rsn"
    
    set rsn_ie "disable"
    set wpa_ie "disable"
 
    switch $security_method {
    
        "None"               -
        "WEP-Open-40"        -
        "WEP-SharedKey-40"   -
        "WEP-Open-128"       -
        "WEP-SharedKey-128"  {
        }
            
        "WPA-PSK"            -
        "WPA-EAP-TLS"        -
        "WPA-EAP-TTLS-GTC"   -
        "WPA-PEAP-MSCHAPV2"  -
        "DWEP-EAP-TLS"       -
        "DWEP-EAP-TTLS-GTC"  -
        "DWEP-PEAP-MSCHAPV2" {
            set wpa_ie "enable"
        }
        
        "WPA2-PSK"           -
        "WPA2-EAP-TLS"       -
        "WPA2-EAP-TTLS-GTC"  -
        "WPA2-PEAP-MSCHAPV2" {
            set rsn_ie "enable"
        }

        default {
            debug $::DBLVL_WARN "Unsupported method $security_method - rsn/wpa"
        }
    }
    
    if {[::configurator::dut_send_cmd "set service-profile $profile_name rsn-ie $rsn_ie\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set rsn-ie"
    }

    if {[::configurator::dut_send_cmd "set service-profile $profile_name wpa-ie $wpa_ie\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set wpa-ie"
    }
}

proc dut_configure_service_profile_dot1x {dut_name cfg security_method profile_name} {
    
    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_service_profile_dot1x"

    dut_configure_radius "$dut_name" "$cfg"

    set dot1x "disable"
    
    switch $security_method {
    
        "None"               -
        "WEP-Open-40"        -
        "WEP-SharedKey-40"   -
        "WEP-Open-128"       -
        "WEP-SharedKey-128"  -
        "WPA-PSK"            -
        "WPA2-PSK"           {
        }
        
        "DWEP-EAP-TLS"       -
        "DWEP-EAP-TTLS-GTC"  -
        "WPA-EAP-TLS"        -
        "WPA-EAP-TTLS-GTC"   -
        "WPA2-EAP-TLS"       -
        "WPA2-EAP-TTLS-GTC"  -
        "DWEP-PEAP-MSCHAPV2" -
        "WPA-PEAP-MSCHAPV2"  -
        "WPA2-PEAP-MSCHAPV2" {
            set dot1x "enable"
        }
    }
    
    if {[::configurator::dut_send_cmd "set service-profile $profile_name auth-dot1x $dot1x\r" $::admin_prompt 5]} {
            debug $::DBLVL_WARN "Unable to set dot1x"
    }
    
    if { $dot1x == "enable" } {
        
        # grab the channel and figure out which Wireless interface to use
        if {[catch {set channel [vw_keylget cfg Channel]}]} {
            debug $::DBLVL_INFO "\"$dut_name\" has no configured Channel.  Skipping dot1x config"
            return 0
        }

        if { $channel <= 14 } {
            set active_int "11g"
        } else {
            set active_int "11a"
        }
        set dut_ssid [::configurator::find_ssid $dut_name "$cfg" $active_int]
        
        if {[::configurator::dut_send_cmd "set authentication dot1x ssid $dut_ssid * pass-through server-group-1\r" $::admin_prompt 5]} {
            debug $::DBLVL_WARN "Unable to set dot1x radius group"
        }
        if {[::configurator::dut_send_cmd "set service-profile $profile_name attr vlan-name default\r" $::admin_prompt 5]} {
            debug $::DBLVL_WARN "Unable to set service profile vlan-name to default"
        }
    }
}
    
    
proc dut_configure_service_profile_encryption {dut_name cfg security_method profile_name} {
    
    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_service_profile_encryption"
    
    set ccmp   "disable"
    set tkip   "disable"
    set wep104 "disable"
    set wep40  "disable"
    
    switch $security_method {
    
        "None"               {
        }
        
        "WEP-Open-40"        -
        "WEP-SharedKey-40"   {
            set wep40 "enable"
        }
        
        "WEP-Open-128"       -
        "WEP-SharedKey-128"  -
        "DWEP-EAP-TLS"       -
        "DWEP-EAP-TTLS-GTC"  -
        "DWEP-PEAP-MSCHAPV2" {
            set wep104 "enable"
        }
            
        "WPA-PSK"            -
        "WPA-EAP-TLS"        -
        "WPA-EAP-TTLS-GTC"   -
        "WPA-PEAP-MSCHAPV2"  {
            set tkip "enable"
        }

        "WPA2-PSK"           -
        "WPA2-EAP-TLS"       -
        "WPA2-EAP-TTLS-GTC"  -
        "WPA2-PEAP-MSCHAPV2" {
            set ccmp "enable"
        }

        default {
            debug $::DBLVL_WARN "Unsupported method $security_method - authentication"
        }
    }
    
    if {[::configurator::dut_send_cmd "set service-profile $profile_name cipher-ccmp $ccmp\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to disable ccmp encryption"
    }

    if {[::configurator::dut_send_cmd "set service-profile $profile_name cipher-tkip $tkip\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to disable tkip encryption"
    }

    if {[::configurator::dut_send_cmd "set service-profile $profile_name cipher-wep104 $wep104\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to disable wep104 encryption"
    }

    if {[::configurator::dut_send_cmd "set service-profile $profile_name cipher-wep40 $wep40\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to disable wep40 encryption"
    }

    switch $security_method {
    
            "None"               {
                set ssid_type "clear"
            }

            "WEP-Open-40"        -
            "WEP-Open-128"       -
            "WEP-SharedKey-40"   -
            "WEP-SharedKey-128"  -
            "WPA-PSK"            -
            "WPA2-PSK"           -
            "WPA-EAP-TLS"        -
            "WPA-EAP-TTLS-GTC"   -
            "WPA-PEAP-MSCHAPV2"  -
            "WPA2-EAP-TLS"       -
            "WPA2-EAP-TTLS-GTC"  -
            "WPA2-PEAP-MSCHAPV2" -
            "DWEP-EAP-TLS"       -
            "DWEP-EAP-TTLS-GTC"  -
            "DWEP-PEAP-MSCHAPV2" {
                set ssid_type "crypto"
            }
    
            default {
                debug $::DBLVL_WARN "Unsupported method $security_method - ssid_type"
                set ssid_type "clear"
            }
        }
        if {[::configurator::dut_send_cmd "set service-profile $profile_name ssid-type $ssid_type\r" $::admin_prompt 5]} {
            debug $::DBLVL_WARN "Unable to set SSID type"
        }
}
    

proc dut_configure_service_profile_auth_keys {dut_name cfg security_method profile_name} {
    
    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_service_profile_auth_keys"
    
    # get/set the WEP/PSK keys
    switch $security_method {
    
        "None"               -
        "WPA-EAP-TLS"        -
        "WPA-EAP-TTLS-GTC"   -
        "WPA2-EAP-TTLS-GTC"  -
        "WPA-PEAP-MSCHAPV2"  -
        "WPA2-PEAP-MSCHAPV2" -
        "DWEP-EAP-TLS"       -
        "DWEP-EAP-TTLS-GTC"  -
        "DWEP-PEAP-MSCHAPV2" -
        "WPA2-EAP-TLS"       {
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

            if { $key_type == "ascii" } {
                puts "Error: $dut_name does not support 40 bit ASCII WEP keys"
                exit -1
            }
            
            if {[::configurator::dut_send_cmd "set service-profile $profile_name wep key-index 1 key $wep\r" $::admin_prompt 5]} {
                debug $::DBLVL_WARN "Unable to set 40 bit WEP key"
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

            if { $key_type == "ascii" } {
                puts "Error: $dut_name does not support 128 bit ASCII WEP keys"
                exit -1
            }
            
            if {[::configurator::dut_send_cmd "set service-profile $profile_name wep key-index 1 key $wep\r" $::admin_prompt 5]} {
                debug $::DBLVL_WARN "Unable to set 128 bit WEP key"
            }
        }
    
        "WPA-PSK"           -
        "WPA2-PSK"          {
            set key_type "phrase"
            if {[catch {set psk [vw_keylget cfg PskAscii]}]} {
                set key_type "key"
                if {[catch {set psk [vw_keylget cfg PskHex]}]} {
                    set key_type "phrase"
                    set psk "whatever"
                }
            }
            if {[::configurator::dut_send_cmd "set service-profile $profile_name psk-$key_type $psk\r" $::admin_prompt 5]} {
                debug $::DBLVL_WARN "Unable to set PSK key"
            }
        }
    
        default {
            debug $::DBLVL_WARN "Unsupported method $security_method - keys"
        }
    }
    
    if { $security_method == "WEP-SharedKey-40" || $security_method == "WEP-SharedKey-128" } {
        set shared_key "enable"
    } else {
        set shared_key "disable"
    }
    
    if {[::configurator::dut_send_cmd "set service-profile $profile_name shared-key-auth $shared_key\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set shared key auth"
    }

    if { $security_method == "WPA-PSK" || $security_method == "WPA2-PSK" } {
        set psk "enable"
    } else {
        set psk "disable"
    }
    
    if {[::configurator::dut_send_cmd "set service-profile $profile_name auth-psk $psk\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set shared key auth"
    }
}

    
#
# dut_configure_radio_profile - configure a radio profile
#
#   dut_name        - The name of the device to be tested.  
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_configure_radio_profile { dut_name cfg } {

    global spawn_id

    debug $::DBLVL_TRACE "dut_configure_radio_profile"

    if {[catch {set profile_name [vw_keylget cfg RadioProfile]}]} {
        debug $::DBLVL_WARN "No radio profile found,  using \"veriwave\""
        set profile_name "veriwave"
    }

    # no other radios can be using this profile at this time.  if this is a new test instance,
    # clear any radios using it.  if this isn't a new test instance, it can fail.
    if {![info exists ::this_3com_test]} {
        set ::this_3com_test -1
    }
    
    set radios {}
    if { $::test_case_number != $::this_3com_test } {
        
        set ::this_3com_test $::test_case_number
        
        if {[::configurator::dut_send_cmd "show config\r" "# Configuration nvgen" 5]} {
            debug $::DBLVL_WARN "Did not see start of configuration"
        }

        expect {
        -re "(\[^\r]*)\r\n" {
            set line $expect_out(0,string)
            if {[regexp -nocase "set ap (\[\[:digit:\]\]+) radio (\[\[:digit:\]\]+) .*radio-profile $profile_name" $line whole_match ap_num radio_num]} {
                 lappend radios "clear ap $ap_num radio $radio_num\r"
            }
            flush stdout
            exp_continue
            }
        "$::admin_prompt"
        }
    }
    
    foreach radio $radios {
        if {[::configurator::dut_send_cmd "$radio" $::admin_prompt 5]} {
            debug $::DBLVL_WARN "Did not clear radio"
        }
    }
        
    if {[::configurator::dut_send_cmd "set radio-profile $profile_name\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to create radio-profile \"$profile_name\""
    }
    
    if {[::configurator::dut_send_cmd "set radio-profile $profile_name auto-tune channel-config disable\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to turn off channel auto-tune"
    }
    
    if {[::configurator::dut_send_cmd "set radio-profile $profile_name auto-tune power-config disable\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to turn off power auto-tune"
    }
    
    if {[catch {set service_profile [vw_keylget cfg ServiceProfile]}]} {
        debug $::DBLVL_WARN "No service profile found, using \"veriwave\""
        set service_profile "veriwave"
    }
    
    if {[::configurator::dut_send_cmd "set radio-profile $profile_name service-profile $service_profile\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to map service profile \"$service_profile\" to radio profile \"$profile_name\""
    }
    
    if {[::configurator::dut_send_cmd "set radio-profile $profile_name mode enable\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to enable radio-profile \"$profile_name\""
    }
}


#
# dut_configure_dap - configure a MAP/DAP
#
#   dut_name        - The name of the device to be tested.  
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_configure_dap { dut_name cfg } {
    
    global spawn_id

    debug $::DBLVL_TRACE "dut_configure_dap"

    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no Method defined. Skipping wireless config"
        return 0
    }
    
    # grab the channel and figure out which Wireless interface to use
    if {[catch {set channel [vw_keylget cfg Channel]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no configured Channel.  Skipping wireless config"
        return 0
    }
    
    if { $channel <= 14 } {
        set active_int "11g"
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
    
    if {[catch {set country_code [vw_keylget cfg CountryCode]}]} {
        debug $::DBLVL_WARN "No CountryCode set for $dut_name.  Defaulting to \"us\""
        set country_code "us"
    }
    if {[::configurator::dut_send_cmd "set system countrycode $country_code\r" "Are you sure?" 5]} {
        debug $::DBLVL_WARN "Unable to set country code"
    } else {
        if {[::configurator::dut_send_cmd "y\r" $::admin_prompt 5]} {
            debug $::DBLVL_WARN "Set coutry code failed"
        } else {
            debug $::DBLVL_INFO "setting country code"
            #set ::configurator::3Com_clear 1
       }
       
    }
    
    if {[catch {set ap_serial [vw_keylget cfg ApSerialNumber]}]} {
        debug $::DBLVL_ERR "No ApSerialNumber configured for $dut_name"
        return 1
    }
    
    if {[catch {set ap_model [vw_keylget cfg APModel]}]} {
        debug $::DBLVL_ERR "No APModel set for $dut_name"
        return 1
    }
    
    if {[catch {set ap_num [vw_keylget cfg ApNumber]}]} {
        debug $::DBLVL_WARN "No ApNumber set, using 1"
        set ap_num 1
    }
   
    if { [ string toupper $ap_model] == "AP2750"} { 
        if {[::configurator::dut_send_cmd "set ap $ap_num serial-id $ap_serial model $ap_model radiotype $active_int\r" \
            $::admin_prompt 5]} {
                debug $::DBLVL_WARN "DAP setup failed."
                return 1
        }
    }

    if { [ string toupper $ap_model] == "AP3750"} { 
        if {[::configurator::dut_send_cmd "set ap $ap_num serial-id $ap_serial model $ap_model radiotype $active_int\r" \
            $::admin_prompt 5]} {
                debug $::DBLVL_WARN "DAP setup failed."
                return 1
        }
    }
    if {[catch {set radio_profile [vw_keylget cfg RadioProfile]}]} {
        debug $::DBLVL_WARN "No RadioProfile set, using \"veriwave\""
        set radio_profile veriwave
    }

    # grab the channel and figure out which radio to use
    if {[catch {set channel [vw_keylget cfg Channel]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no configured Channel.  Skipping wireless config"
        return 0
    }
   
    if { [ string toupper $ap_model] != "AP2750"} { 
        if { $channel <= 14 } {
            set radio_idx "1"
            if {[::configurator::dut_send_cmd "set ap $ap_num radio 2 mode disable\r" $::admin_prompt 5]} {
                debug $::DBLVL_WARN "Unable to Disable ap $ap_num radio 2"
            }
        } else {
            set radio_idx "2"
            if {[::configurator::dut_send_cmd "set ap $ap_num radio 1 mode disable\r" $::admin_prompt 5]} {
                debug $::DBLVL_WARN "Unable to Disable ap $ap_num radio 1"
            }
        }
    } else {
        # AP2750's only have radio index 1
        set radio_idx "1"
    }
    if {[::configurator::dut_send_cmd "set ap $ap_num radio $radio_idx radio-profile $radio_profile mode enable\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to tie radio profile to DAP"
    }

    debug $::DBLVL_INFO "Configuring DUT channel"
    set channel [vw_keylget cfg Channel]

    if {[::configurator::dut_send_cmd "set ap $ap_num radio $radio_idx channel $channel\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set channel"
    }
    
    if {[catch {set power [vw_keylget this_int Power]}]} {
        debug $::DBLVL_INFO "No power level set for $dut_name - $active_int, defaulting to 4"
        set power "4"
    }
    if {[::configurator::dut_send_cmd "set ap $ap_num radio $radio_idx tx-power $power\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set power"
    }
    
    if {[catch {set antenna [vw_keylget this_int Antenna]}]} {
        debug $::DBLVL_INFO "No antenna set for $dut_name, using internal"
        set antenna "internal"
    }
    if {[::configurator::dut_send_cmd "set ap $ap_num radio $radio_idx antennatype $antenna\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set antenna type"
    }
    
    if {[catch {set lan_int [vw_keylget this_int_list "lan" ]}]} {
        puts "Error: No interface \"lan\" defined for $dut_name"
        exit -1
    }
    
    if {[::configurator::dut_send_cmd "set ap $ap_num radio $radio_idx mode enable\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to enable DAP"
    }
}


#
# dut_configure_wireless - configure things at the wireless sub-mode
#
#   dut_name        - The name of the device to be tested.  
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_configure_wireless { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_wireless"

    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no Method defined. Skipping wireless config"
        return 0
    }
    
    # grab the channel and figure out which Wireless interface to use
    if {[catch {set channel [vw_keylget cfg Channel]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no configured Channel.  Skipping wireless config"
        return 0
    }
    
    if { $channel <= 14 } {
        set active_int "11g"
    } else {
        set active_int "11a"
    } 

    # the AP2750 always uses radio index 1 and controlls radio type using the radio type command
    if {[catch {set ap_model [vw_keylget cfg APModel]}]} {
        debug $::DBLVL_ERR "No APModel set for $dut_name"
        return 1
    }
    
    # grab the channel and figure out which radio to use
    if {[catch {set channel [vw_keylget cfg Channel]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no configured Channel.  Skipping wireless config"
        return 0
    }
   
    # the ap2750 always uses radio index 1 
    if {[string toupper $ap_model] == "AP2750" } {
        set radio_idx "1"
    } else {
        if { $channel <= 14 } {
            set radio_idx "1"
        } else {
            set radio_idx "2"
        }
    }

    if {[catch {set ap_num [vw_keylget cfg ApNumber]}]} {
        debug $::DBLVL_INFO "No ApNumber for $dut_name, using 1."
        set ap_num 1
    }
    
    if {[catch {set profile_name [vw_keylget cfg RadioProfile]}]} {
        debug $::DBLVL_WARN "No radio profile found,  using \"veriwave\""
        set profile_name "veriwave"
    }
    
    if {[catch {set profile_name [vw_keylget cfg ServiceProfile]}]} {
        debug $::DBLVL_WARN "No service profile found,  using \"veriwave\""
        set profile_name "veriwave"
    }

    if {[catch {set ap_num [vw_keylget cfg ApNumber]}]} {
        debug $::DBLVL_WARN "No ApNumber set, using 1"
        set ap_num 1
    }

    if {![info exists ::args(--noclean) ]} {
        # allow --noclean to disable the clearing of the ap
        if {$active_int == "11g"} {
            if {[::configurator::dut_send_cmd "disp ap config $ap_num\r" "802.11g" 5]} {
                if {[::configurator::dut_send_cmd "clear ap $ap_num\r" "Would you like to continue?" 5]} {
                    debug $::DBLVL_WARN "Unable to clear ap $ap_num"
                } else {
                    if {[::configurator::dut_send_cmd "y\r" $::admin_prompt 5]} {
                        debug $::DBLVL_WARN "Clear ap failed"
                    } else {
                        debug $::DBLVL_INFO "Clearing ap $ap_num to change to radiotype 11g. This can be disabled with --noclean"
                        set ::configurator::3Com_clear 1
                   }
               }
            }
        }
        if {$active_int == "11a"} {
            if {[::configurator::dut_send_cmd "disp ap config $ap_num\r" "802.11a" 5]} {
                if {[::configurator::dut_send_cmd "clear ap $ap_num\r" "Would you like to continue?" 5]} {
                    debug $::DBLVL_WARN "Unable to clear ap $ap_num"
                } else {
                    if {[::configurator::dut_send_cmd "y\r" $::admin_prompt 5]} {
                        debug $::DBLVL_WARN "Clear ap failed"
                    } else {
                        debug $::DBLVL_INFO "Clearing ap $ap_num to change to radiotype 11a"
                        set ::configurator::3Com_clear 1
                    }
               }
            }
        }
    }

    if {[catch {set ap_serial [vw_keylget cfg ApSerialNumber]}]} {
        debug $::DBLVL_ERR "No ApSerialNumber configured for $dut_name"
        return 1
    }
    set serial_upper [string toupper $ap_serial]

    if {[::configurator::dut_send_cmd "disp ap status $ap_num\r" $serial_upper 5]} {
        if {[::configurator::dut_send_cmd "clear ap $ap_num\r" "Would you like to continue?" 5]} {
            debug $::DBLVL_WARN "Unable to clear ap $ap_num"
        } else {
            if {[::configurator::dut_send_cmd "y\r" $::admin_prompt 5]} {
                debug $::DBLVL_WARN "Clear ap failed"
            } else {
                debug $::DBLVL_INFO "Clearing ap $ap_num to serial number. This can be disabled with --noclean"
                set ::configurator::3Com_clear 1
                breakable_after 20
           }
       }
    }

    if {[::configurator::dut_send_cmd "set ap $ap_num radio $radio_idx mode disable\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to disable radio before configuration"
    }
    
    dut_configure_service_profile $dut_name $cfg
    dut_configure_radio_profile   $dut_name $cfg
    dut_configure_dap             $dut_name $cfg
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

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_epilogue"
    
    if {[::configurator::dut_send_cmd "save configuration\r" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Unable to exit config mode"
    }
    if { $::configurator::3Com_clear == 1} {
        # we need to make sure the ap came to operational state
        # grab the ap
        if {[catch {set ap_num [vw_keylget cfg ApNumber]}]} {
            debug $::DBLVL_WARN "No ApNumber set, using 1"
            set ap_num 1
        }

        set cnt 1
        if {[::configurator::dut_send_cmd "display ap status $ap_num\r" "State:     operational" 5]} {
           while {$cnt < 20} {
               debug $::DBLVL_INFO "Cleared ap is not yet Operational Checking again in 30 seconds ($cnt/20)" 
               if {[::configurator::dut_send_cmd "display ap status $ap_num\r" "State:     operational" 5]} {
                   incr cnt
                   breakable_after 30
               } else {
                   break
               }
            }
        }
        if {$cnt == 20} {
           debug $::DBLVL_WARN "Warning cleared ap is NOT operational ($cnt/20)" 
        } else {
           debug $::DBLVL_INFO "Cleared ap is now Operational ($cnt/20)" 
        }
        set ::configurator:3Com_clear 0
    }
    # close the expect connection
    catch {exp_close}
    catch {wait}
    log_file
    breakable_after 2
}

