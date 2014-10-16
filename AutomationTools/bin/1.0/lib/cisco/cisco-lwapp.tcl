#
# cisco-lwapp.tcl - configures a cisco LWAPP controller (device-under-test)
#
# Generic functions to aid in configuration.  Any one of these can be
# overridden by a function at more specific model levels.
#
# $Id: cisco-lwapp.tcl,v 1.9.4.1 2008/01/24 20:56:22 manderson Exp $
#
#

set cvs_author  [cvs_clean "$Author: manderson $"]
set cvs_ID      [cvs_clean "$Id: cisco-lwapp.tcl,v 1.9.4.1 2008/01/24 20:56:22 manderson Exp $"]
set cvs_file    [cvs_clean "$RCSfile: cisco-lwapp.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.9.4.1 $"]
set cvs_date    [cvs_clean "$Date: 2008/01/24 20:56:22 $"]
set cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

debug $::DBLVL_CVS_VERSION "loading $cvs_file $cvs_version $cvs_date"

set ::admin_prompt  "\[\r\n\]\(\(.*\)\) >"
set ::config_prompt "\[\r\n\]\(\(.*\)\) config>"

# cisco-lwapp_get_version
#
# dut_configure_get_version - find the software version of this WLC
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
proc cisco-lwapp_get_version { dut_name } {
    
    global spawn_id

    debug $::DBLVL_TRACE "cisco-lwapp_get_version"
    
    if {[::configurator::dut_send_cmd "paging disable\n" $::config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to disable terminal paging.  Old software version?"
    }

    if {[::configurator::dut_send_cmd "end\n" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Couldn't leave config mode to get version info"
    }
    
    if {[::configurator::dut_send_cmd "show sysinfo\n" $::admin_prompt 10]} {
        debug $::DBLVL_WARN "Unable to retrieve system info"
    } else {
        regexp {Product Version\.+ ([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)} $::dut_configure_send_buf \
            junk v1 v2 v3 v4
        set ::dut_version [format "%03d%03d%03d%03d" $v1 $v2 $v3 $v4]
        debug $::DBLVL_INFO "Found version - $::dut_version"
    }
    
    if {[::configurator::dut_send_cmd "config\n" $::config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to re-enter config mode"
    }
}


#
# dut_configure_config_prompt - get a Cisco AP from any state to the config prompt.
#
# parameters:
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The configuration keyed list
#
proc cisco-lwapp_config_prompt { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "cisco-lwapp_config_prompt"
    
    # get the WLC to a config prompt
    if [catch {set wlc_username [vw_keylget cfg ApUsername]}] {
        if [catch {set wlc_username [vw_keylget cfg Username]}] {
            puts "Error: No ApUsername defined for $dut_name"
            exit -1
        } else {
            debug $::DBLVL_WARN "USERNAME deprecated in DUT config, please use ApUsername"
        }
    }

    if [catch {set wlc_password [vw_keylget cfg ApPassword]}] {
        if [catch {set wlc_password [vw_keylget cfg Password]}] {
            puts "Error: No ApPassword defined for $dut_name"
            exit -1
        } else {
            debug $::DBLVL_WARN "PASSWORD deprecated in DUT config, please use ApPassword"
        }
    }
    
    # kick the console
    send "\r"
    sleep 1
    
    if { $::tcl_platform(platform) == "windows" } {
        send "\r"
        sleep 1
    }
    
    expect {
        
        # the config prompt with a bit of paranoia
        -re $::config_prompt {
            if {[::configurator::dut_send_cmd "end\n" $::admin_prompt 5]} {
                debug $::DBLVL_WARN "Did not reach admin prompt"
            }
            if {[::configurator::dut_send_cmd "config\n" $::config_prompt 5]} {
                debug $::DBLVL_WARN "Did not reach config prompt"
            }
        }
        
        # admin prompt
        -re $::admin_prompt {
            if {[::configurator::dut_send_cmd "config\n" $::config_prompt 5]} {
                debug $::DBLVL_WARN "Did not reach config prompt"
            }
        }
        
        # initial login
        "User:" {
            if {[::configurator::dut_send_cmd "$wlc_username\n" "Password:" 5]} {
                debug $::DBLVL_WARN "Did not reach password prompt"
            }
            
            if {[::configurator::dut_send_cmd "$wlc_password\n" $::admin_prompt 5]} {
                debug $::DBLVL_WARN "Did not reach login prompt"
            }
            
            if {[::configurator::dut_send_cmd "config\n" $::config_prompt 5]} {
                debug $::DBLVL_WARN "Did not reach configuration prompt"
            }
        }
        
        default {
            debug $::DBLVL_WARN "Unknown prompt found"
            # close the connection
            after 1000
            catch {expect *}
            catch {exp_close}
            catch {wait}
            log_file
            breakable_after 3
            return 1
        }
    }
    
    # at the configuration prompt = success
    return 0
}


#
# cisco-lwapp_configure_prelude - setup to get an AP ready to be configured
#
# parameters:
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  dut_cfg      - The configuration keyed list
#
proc cisco-lwapp_configure_prelude { dut_name cfg } {
 
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

    set telnet_path [file join $::VW_TEST_ROOT "bin" "telnet.tcl"]
    
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
    
    #spawn tclsh $telnet_path $console_addr $console_port
    exp_spawn telnet $console_addr $console_port

    # get to the config prompt
    if {[cisco-lwapp_config_prompt $dut_name $cfg]} {
        return 1
    }
    
    cisco-lwapp_get_version $dut_name
    
    return 0
}


# cisco-lwapp_configure_radio
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The configuration keyed list
#
proc cisco-lwapp_configure_radio { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "cisco-lwapp_configure_radio"
    
    # 802.11a and 802.11b stuffs
    
    return 0
}


# cisco-lwapp_configure_ap
#
# parameters:
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg      - The configuration keyed list
#
proc cisco-lwapp_configure_ap { dut_name cfg } {
    
    global spawn_id
    
    debug $::DBLVL_TRACE "cisco-lwapp_configure_ap"
    
    set rc 0
    
    # LAP specific stuff
    if {[catch {set mac [vw_keylget cfg ApMacAddr]}]} {
        puts "Error: No ApMacAddr defined for $dut_name"
        exit -1
    }
    
    if {[catch {set cert_type [vw_keylget cfg ApCertType]} result ]} {
        puts "No ApCertType found, using mic"
        set cert_type "mic"
    }
    
    # make sure we accept self signed certs
    if { $cert_type == "ssc" } {
        if {[::configurator::dut_send_cmd "auth-list ap-policy ssc enable\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to allow self-signed certs"
        }
    }
    
    if {[::configurator::dut_send_cmd "auth-list delete $mac\n" $::config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to remove authorization for $dut_name"
        incr rc
    }
    
    if {[::configurator::dut_send_cmd "auth-list add $cert_type $mac\n" $::config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to authorize $dut_name"
        incr rc
    }
    
    return $rc
}


# cisco-lwapp_configure_radius
#
# parameters:
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg      - The configuration keyed list
#
proc cisco-lwapp_configure_radius { dut_name cfg } {
    
    global spawn_id
    
    debug $::DBLVL_TRACE "cisco-lwapp_configure_radius"

    # radius server configuration
    set rc 0
    
    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        puts "Error: \"$dut_name\" has no defined Method"
        exit -1
    }
    
    if {[::configurator::method_needs_radius $security_method]} {
        if {[catch {set radius_id [vw_keylget cfg RadiusServerId]}]} {
            debug $::DBLVL_INFO "No RadiusServerId defined, using 1"
            set radius_id 1
        }
        if {[catch {set radius_server [vw_keylget cfg RadiusServerAddr]}]} {
            puts "Error: No RadiusServerAddr defined in $dut_name"
            exit -1
        }
        if {[catch {set radius_auth [vw_keylget cfg RadiusServerAuthPort]}]} {
            debug $::DBLVL_INFO "No RadiusServerAuthPort defined for $dut_name"
            set radius_auth 1812
        }
        if {[catch {set radius_acct [vw_keylget cfg RadiusServerAcctPort]}]} {
            debug $::DBLVL_INFO "No RadiusServerAcctPort defined for $dut_name"
            set radius_acct 1813
        }
        if {[catch {set radius_secret [vw_keylget cfg RadiusServerSecret]}]} {
            puts "Error: No RadiusServerSecret defined in $dut_name"
            exit -1
        }
        
        if {[catch { set wlan_id [vw_keylget cfg BssidIndex]}]} {
            debug $::DBLVL_INFO "No BssidIndex (WlanId) defined, using 1"
            set wlan_id 1
        }
        
        if {[::configurator::dut_send_cmd "radius auth delete $radius_id\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Did not delete previous radius authentication info"
            incr rc
        }
        
        set rad_cfg "radius auth add $radius_id $radius_server $radius_auth ascii $radius_secret\n"
        if {[::configurator::dut_send_cmd "$rad_cfg" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Did not set radius authentication"
            incr rc
        }
        
        if {[::configurator::dut_send_cmd "radius acct delete $radius_id\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Did not delete previous radius accounting info"
            incr rc
        }
        
        set rad_cfg "radius acct add $radius_id $radius_server $radius_acct ascii $radius_secret\n"
        if {[::configurator::dut_send_cmd "$rad_cfg" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Did not set radius authentication"
            incr rc
        }
        
        if {[::configurator::dut_send_cmd "wlan radius_server auth add $wlan_id $radius_id\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to add radius auth server $radius_id to wlan $wlan_id"
        }
        
        if {[::configurator::dut_send_cmd "wlan radius_server acct add $wlan_id $radius_id\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to add radius acct server $radius_id to wlan $wlan_id"
        }
        
    } else {
        debug $::DBLVL_INFO "No radius config needed for $security_method"
    }

    return $rc
}


# cisco-lwapp_configure_wlan
#
# parameters:
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg      - The configuration keyed list
#
proc cisco-lwapp_configure_wlan { dut_name cfg } {
    
    global spawn_id
    
    debug $::DBLVL_TRACE "cisco-lwapp_configure_wlan"
    
    set rc 0
    
    # wlan related config
    if {[catch { set wlan_id [vw_keylget cfg BssidIndex]}]} {
        debug $::DBLVL_INFO "No BssidIndex (WlanId) defined, using 1"
        set wlan_id 1
    }
    
    if {[catch {set wlan_name [vw_keylget cfg Ssid]}]} {
        debug $::DBLVL_INFO "No Ssid defined, using \"veriwave\" for WLAN name"
        set wlan_name "veriwave"
    }
    
    if {[::configurator::dut_send_cmd "wlan delete $wlan_id\n" $::config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to remove old wlan $wlan_id"
        incr rc
    }
    
    if {[::configurator::dut_send_cmd "wlan create $wlan_id $wlan_name\n" $::config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to create new wlan $wlan_name($wlan_id)"
        incr rc
    }
    
    if {[catch {set bcast_ssid [vw_keylget cfg SsidBroadcast]}]} {
        debug $::DBLVL_INFO "No SsidBroadcast defined, will do so"
        set bcast_ssid "enable"
    }
    
    if { $bcast_ssid == "true" } {
        set bcast_ssid "enable"
    }
    
    if {[::configurator::dut_send_cmd "wlan broadcast-ssid $bcast_ssid $wlan_id\n" $::config_prompt 5]} {
        debug $::DBLVL_WARN "Did not set broadcast-ssid properly"
        incr rc
    }

    # make sure the WLAN is using the default DHCP server
    if {[catch {set dhcp_server [vw_keylget cfg DhcpServer]}]} {
        debug $::DBLVL_INFO "No DhcpServer set, using 0.0.0.0"
        set dhcp_server "0.0.0.0"
    }
    
    if {[::configurator::dut_send_cmd "wlan dhcp_server $wlan_id $dhcp_server\n" $::config_prompt 5]} {
        debug $::DBLVL_WARN "Did not set dhcp server"
        incr rc
    }

    incr rc [cisco-lwapp_configure_radius $dut_name $cfg]

    # grab the channel and figure out which Wireless interface to use
    if {[catch {set channel [vw_keylget cfg Channel]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no configured Channel.  Skipping wireless config"
        return 0
    }
    
    if { $channel <= 11 } {
        set active_int "802_11b"
    } else {
        set active_int "802_11a"
    }
    
    set this_radio_type "802.11bg"
    if {![catch {set this_int_list [vw_keylget cfg Interface]}]} {
        if {[catch {set this_int [vw_keylget this_int_list $active_int]}]} {
            puts "Error: No interface \"$active_int\" for DUT $dut_name defined"
            exit -1
        } else {
            if {[catch {set this_radio_type [vw_keylget this_int InterfaceType]}]} {
                debug $::DBLVL_INFO "No radio type set for $dut_name - $active_int, defaulting"
                set this_radio_type "802.11bg"
            }
        }
    }
    
    if {[::configurator::dut_send_cmd "wlan radio $wlan_id $this_radio_type\n" $::config_prompt 5]} {
        debug $::DBLVL_WARN "Did not set radio type"
        incr rc
    }

    switch $this_radio_type {
        "802.11a" {
            set radio_cmd "802.11a"
            set other_cmd "802.11b"
        }
        
        "802.11bg"    -
        default {
            set radio_cmd "802.11b"
            set other_cmd "802.11a"
        }
    }

    if {[catch {set ap_name [vw_keylget cfg ApName]}]} {
        # TODO - make the default from the ethernet MAC address
        puts "Error: No ApName defined for $dut_name"
        exit -1
    }
    
    set channel [vw_keylget cfg Channel]

    if {[::configurator::dut_send_cmd "$radio_cmd disable $ap_name\n" $::config_prompt 5]} {
        debug $::DBLVL_WARN "Did not temporarily disable $radio_cmd"
    }
    
    if { $::dut_version > "004001099000" } {
        set ap_tag "ap "
    } else {
        set ap_tag ""
    }
            
    if {[::configurator::dut_send_cmd "$radio_cmd channel $ap_tag $ap_name $channel\n" $::config_prompt 5]} {
        debug $::DBLVL_WARN "Did not set channel for $ap_name"
        incr rc
    }
    
    if {[catch {set power_level [vw_keylget this_int Power]}]} {
        debug $::DBLVL_INFO "No power level set for $dut_name - $active_int, defaulting"
        set power_level 2
    }
    
    if {[::configurator::dut_send_cmd "$radio_cmd txPower $ap_tag $ap_name $power_level\n" $::config_prompt 5]} {
        debug $::DBLVL_WARN "Did not set power for $ap_name"
        incr rc
    }
    
    # antenna setting. default is diversity
    if {[catch {set antenna [vw_keylget this_int AntennaDiversity]}]} {
        set antenna "enable"
        debug $::DBLVL_INFO "No antenna setting - enabling diversity mode"
    }
    
    set antenna [string tolower $antenna]
    
    if {[::configurator::dut_send_cmd "$radio_cmd antenna diversity $antenna $ap_name\n" $::config_prompt 5]} {
        debug $::DBLVL_WARN "Did not set antenna diversity"
        incr rc
    }
    
    if {[::configurator::dut_send_cmd "$radio_cmd enable $ap_name\n" $::config_prompt 5]} {
        debug $::DBLVL_WARN "Did not enable $radio_cmd"
        incr rc
    }
    
    return $rc
}


# cisco-lwapp_configure_wlan_security_wep
#
# parameters:
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg      - The configuration keyed list
#
proc cisco-lwapp_configure_wlan_security_wep { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "cisco-lwapp_confgure_wlan_security_wep"

    set rc 0
    
    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        puts "Error: \"$dut_name\" has no defined Method"
        exit -1
    }
    
    if {[catch { set wlan_id [vw_keylget cfg BssidIndex]}]} {
        debug $::DBLVL_INFO "No BssidIndex (WlanId) defined, using 1"
        set wlan_id 1
    }
    
    switch $security_method {

        "WEP-Open-40"       {
            set key_length 40
            set key_type   "open"
        }
        
        "WEP-Open-128"      {
            set key_length 104
            set key_type   "open"
        }
        
        "WEP-SharedKey-40"  {
            set key_length 40
            set key_type   "shared-key"
        }
        
        "WEP-SharedKey-128" {
            set key_length 104
            set key_type   "shared-key"
        }

        "None"               -
        "LEAP"               -
        "DWEP-EAP-TLS"       -
        "DWEP-EAP-TTLS-GTC"  -
        "DWEP-PEAP-MSCHAPV2" -
        "WPA-LEAP"           -
        "WPA-EAP-TLS"        -
        "WPA-EAP-TTLS-GTC"   -
        "WPA-PEAP-MSCHAPV2"  -
        "WPA-PSK"            -
        "WPA2-PSK"           -
        "WPA2-EAP-TLS"       -
        "WPA2-EAP-TTLS-GTC"  -
        "WPA2-PEAP-MSCHAPV2" -
        "WPA2-PSK"           -
        "WPA2-LEAP"          {
            set wep_disabled 1
        }
        
        default {
            debug $::DBLVL_WARN "Unknown method - $security_method"
        }
    }
    
    if {[info exists key_type]} {
        if {[::configurator::dut_send_cmd "wlan security static-wep-key authentication $key_type $wlan_id\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Did not set wep key auth type to $key_type"
            incr rc
        }
    }
    
    if {[info exists key_length]} {
        switch $security_method {
            "WEP-Open-40"      -
            "WEP-SharedKey-40" {
                set ascii_hex "ascii"
                if {[catch {set wep_key [vw_keylget cfg WepKey40Ascii]}]} {
                    set ascii_hex "hex"
                    if {[catch {set wep_key [vw_keylget cfg WepKey40Hex]}]} {
                        set ascii_hex "ascii"
                        set wep_key "12345"
                    }
                }
            }

            "WEP-Open-128"      -
            "WEP-SharedKey-128" {
                set ascii_hex "ascii"
                if {[catch {set wep_key [vw_keylget cfg WepKey128Ascii]}]} {
                    set ascii_hex "hex"
                    if {[catch {set wep_key [vw_keylget cfg WepKey128Hex]}]} {
                        set ascii_hex "ascii"
                        set wep_key "123456789ABCD"
                    }
                }
            }
            
            default {
                # do nothing
            }
        }

        # TODO - grab the key index from the config to use instead of 1
        if {[info exists ascii_hex] && [info exists wep_key]} {
            set cfg "wlan security static-wep-key encryption $wlan_id $key_length $ascii_hex $wep_key 1\n"
            if {[::configurator::dut_send_cmd "$cfg" $::config_prompt 5]} {
                debug $::DBLVL_WARN "Did not set WEP key"
                incr rc
            }
        }
    }

    # leave it disabled if the method doesn't need it
    if {![info exists wep_disabled]} {
        if {[::configurator::dut_send_cmd "wlan security static-wep-key enable $wlan_id\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Did not enable static wep"
            incr rc
        }
    }
    
    return $rc
}


# cisco-lwapp_configure_wlan_security_wpa
#
# parameters:
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg      - The configuration keyed list
#
proc cisco-lwapp_configure_wlan_security_wpa { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "cisco-lwapp_confgure_wlan_security_wpa"

    set rc 0
    
    if {[catch { set wlan_id [vw_keylget cfg BssidIndex]}]} {
        debug $::DBLVL_INFO "No BssidIndex (WlanId) defined, using 1"
        set wlan_id 1
    }
    
    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        puts "Error: \"$dut_name\" has no defined Method"
        exit -1
    }
    
    switch $security_method {

        "None"               -
        "WEP-Open-40"        -
        "WEP-Open-128"       -
        "WEP-SharedKey-40"   -
        "WEP-SharedKey-128"  -
        "WPA2-PSK"           -
        "WPA2-EAP-TLS"       -
        "WPA2-EAP-TTLS-GTC"  -
        "WPA2-PEAP-MSCHAPV2" -
        "DWEP-EAP-TLS"       -
        "DWEP-EAP-TTLS-GTC"  -
        "DWEP-PEAP-MSCHAPV2" -
        "LEAP"               -
        "WPA2-LEAP"          -
        "WPA2-PSK"           {
            set wpa_disabled 1
            set psk_disabled 1
        }
        
        "WPA-LEAP"          -
        "WPA-EAP-TLS"       -
        "WPA-EAP-TTLS-GTC"  -
        "WPA-PEAP-MSCHAPV2" {
            set psk_disabled 1
        }
            
        "WPA-PSK" {
            # do nothing here/everything later
        }
        
        default {
            debug $::DBLVL_WARN "Unknown method - $security_method"
        }
    }

    if {![info exists wpa_disabled] && $::dut_version >= "004001000000"} {
        if {[::configurator::dut_send_cmd "wlan security wpa enable $wlan_id\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to enable wpa"
            incr rc
        }
    } 
    
    if {[info exists psk_disabled] && $::dut_version < "004001000000"} {
        set cmd "wlan security wpa1 pre-shared-key disable $wlan_id"
        if {[::configurator::dut_send_cmd "$cmd\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to disable the PSK key"
            incr rc
        }
    } elseif {![info exists wpa_disabled] && ![info exists psk_disabled]} {
        set ascii_hex "ascii"
        if [catch {set psk [vw_keylget cfg PskAscii]}] {
            set ascii_hex "hex"
            if [catch {set psk [vw_keylget cfg PskHex]}] {
                set ascii_hex "ascii"
                set psk "whatever"
            }
        }
        if { $::dut_version < "004001000000" } {
            set cfg "wlan security wpa1 pre-shared-key enable $wlan_id $ascii_hex $psk"
        } else {
            set cfg "wlan security wpa akm psk set-key $ascii_hex $psk $wlan_id"
        }
        if {[::configurator::dut_send_cmd "$cfg\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Did not set WPA PSK key"
            incr rc
        }
        
        if { $::dut_version >= "004001000000" } {
            if {[::configurator::dut_send_cmd "wlan security wpa akm psk enable $wlan_id\n" $::config_prompt 5]} {
                debug $::DBLVL_WARN "Did not enable WPA PSK"
                incr rc
            }
        }
    }
    
    if {![info exists wpa_disabled]} {
        
        if { $::dut_version < "004001000000" } {
            set cmd "wlan security wpa1 enable $wlan_id"
        } else {
            set cmd "wlan security wpa wpa1 enable $wlan_id"
        }
        if {[::configurator::dut_send_cmd "$cmd\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to enable wpa1"
            incr rc
        }

        if { $::dut_version >= "004001000000" } {
            if {[::configurator::dut_send_cmd "wlan security wpa wpa1 ciphers tkip enable $wlan_id\n" $::config_prompt 5]} {
                debug $::DBLVL_WARN "Did not enable TKIP for WPA1"
                incr rc
            }
            if {[::configurator::dut_send_cmd "wlan security wpa wpa1 ciphers aes disable $wlan_id\n" $::config_prompt 5]} {
                debug $::DBLVL_WARN "Did not disable AES for WPA1"
            }
        }

    }
    
    return $rc
}


# cisco-lwapp_configure_wlan_security_wpa2
#
# parameters:
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg      - The configuration keyed list
#
proc cisco-lwapp_configure_wlan_security_wpa2 { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "cisco-lwapp_confgure_wlan_security_wpa2"

    set rc 0
    
    if {[catch { set wlan_id [vw_keylget cfg BssidIndex]}]} {
        debug $::DBLVL_INFO "No BssidIndex (WlanId) defined, using 1"
        set wlan_id 1
    }
    
    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        puts "Error: \"$dut_name\" has no defined Method"
        exit -1
    }
    
    switch $security_method {

        "None"               -
        "WEP-Open-40"        -
        "WEP-Open-128"       -
        "WEP-SharedKey-40"   -
        "WEP-SharedKey-128"  -
        "WPA-PSK"            -
        "WPA-EAP-TLS"        -
        "WPA-EAP-TTLS-GTC"   -
        "WPA-PEAP-MSCHAPV2"  -
        "DWEP-EAP-TLS"       -
        "DWEP-EAP-TTLS-GTC"  -
        "DWEP-PEAP-MSCHAPV2" -
        "LEAP"               -
        "WPA-LEAP"           -
        "WPA-PSK"            {
            set wpa2_disabled 1
            set psk_disabled 1
        }
        
        "WPA2-LEAP"          -
        "WPA2-EAP-TLS"       -
        "WPA2-EAP-TTLS-GTC"  -
        "WPA2-PEAP-MSCHAPV2" {
            set psk_disabled 1
        }
            
        "WPA2-PSK" {
            # do nothing here/everything later
        }
        
        default {
            debug $::DBLVL_WARN "Unknown method - $security_method"
        }
    }
    
    if {![info exists wpa2_disabled] && $::dut_version >= "004001000000"} {
        if {[::configurator::dut_send_cmd "wlan security wpa enable $wlan_id\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to enable wpa"
            incr rc
        }
    }
    
    if {[info exists psk_disabled] && $::dut_version < "004001000000"} {
        set cmd "wlan security wpa2 pre-shared-key disable $wlan_id"
        if {[::configurator::dut_send_cmd "$cmd\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to disable the PSK key"
            incr rc
        }
    } elseif {![info exists wpa2_disabled] && ![info exists psk_disabled]} {
        set ascii_hex "ascii"
        if [catch {set psk [vw_keylget cfg PskAscii]}] {
            set ascii_hex "hex"
            if [catch {set psk [vw_keylget cfg PskHex]}] {
                set ascii_hex "ascii"
                set psk "whatever"
            }
        }
        if { $::dut_version < "004001000000" } {
            set cfg "wlan security wpa2 pre-shared-key enable $wlan_id $ascii_hex $psk"
        } else {
            set cfg "wlan security wpa akm psk set-key $ascii_hex $psk $wlan_id"
        }
        if {[::configurator::dut_send_cmd "$cfg\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Did not set WPA2 PSK key"
            incr rc
        }
        
        if { $::dut_version >= "004001000000" } {
            if {[::configurator::dut_send_cmd "wlan security wpa akm psk enable $wlan_id\n" $::config_prompt 5]} {
                debug $::DBLVL_WARN "Did not enable WPA2 PSK"
                incr rc
            }
        }
    }
    
    if {![info exists wpa2_disabled]} {
        if { $::dut_version < "004001000000" } {
            set cmd "wlan security wpa2 enable $wlan_id"
        } else {
            set cmd "wlan security wpa wpa2 enable $wlan_id"
        }
        if {[::configurator::dut_send_cmd "$cmd\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to enable wpa2"
            incr rc
        }

        if { $::dut_version >= "004001000000" } {
            if {[::configurator::dut_send_cmd "wlan security wpa wpa2 ciphers aes enable $wlan_id\n" $::config_prompt 5]} {
                debug $::DBLVL_WARN "Did not enable AES for WPA2"
                incr rc
            }
            if {[::configurator::dut_send_cmd "wlan security wpa wpa2 ciphers tkip disable $wlan_id\n" $::config_prompt 5]} {
                debug $::DBLVL_WARN "Did not disable TKIP for WPA2"
            }
        }
    }
    
    # TODO tkip <enable|disable> <id> and wpa-compat <enable|disable> <id>
    
    return $rc
}


# cisco-lwapp_configure_wlan_security_1x
#
# parameters:
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg      - The configuration keyed list
#
proc cisco-lwapp_configure_wlan_security_1x { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "cisco-lwapp_confgure_wlan_security_1x"

    set rc 0
    
    if {[catch { set wlan_id [vw_keylget cfg BssidIndex]}]} {
        debug $::DBLVL_INFO "No BssidIndex (WlanId) defined, using 1"
        set wlan_id 1
    }
    
    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        puts "Error: \"$dut_name\" has no defined Method"
        exit -1
    }
    
    switch $security_method {

        "None"               -
        "WPA-PSK"            -
        "WPA2-PSK"           -
        "WPA-LEAP"           -
        "WPA2-LEAP"          -
        "WPA-EAP-TLS"        -
        "WPA-EAP-TTLS-GTC"   -
        "WPA-PEAP-MSCHAPV2"  -
        "WPA2-EAP-TLS"       -
        "WPA2-EAP-TTLS-GTC"  -
        "WPA2-PEAP-MSCHAPV2" -
        "WEP-Open-40"        -
        "WEP-SharedKey-40"   -
        "WEP-Open-128"       -
        "WEP-SharedKey-128"  {
            set 1x_disabled 1
        }
        
        "LEAP"               -
        "DWEP-EAP-TLS"       -
        "DWEP-EAP-TTLS-GTC"  -
        "DWEP-PEAP-MSCHAPV2" {
            set 1x_len 104
        }
        
        default {
            debug $::DBLVL_WARN "Unknown method - $security_method"
            set 1x_disabled 1
        }
    }

    if {![info exists 1x_disabled]} {
        if {[::configurator::dut_send_cmd "wlan security 802.1x encryption $wlan_id $1x_len\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to set 1x authentication length"
            incr 1
        }
        if {[::configurator::dut_send_cmd "wlan security 802.1x enable $wlan_id\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to enable 1x"
            incr rc
        }
    }
    return $rc
}


# cisco-lwapp_configure_wlan_security
#
# parameters:
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg      - The configuration keyed list
#
proc cisco-lwapp_configure_wlan_security { dut_name cfg } {
    
    global spawn_id
    
    debug $::DBLVL_TRACE "cisco-lwapp_confgure_wlan_security"

    set rc 0
    
    # disable them all
    if {[catch { set wlan_id [vw_keylget cfg BssidIndex]}]} {
        debug $::DBLVL_INFO "No BssidIndex (WlanId) defined, using 1"
        set wlan_id 1
    }
    
    if {[::configurator::dut_send_cmd "wlan security static-wep-key disable $wlan_id\n" $::config_prompt 5]} {
        debug $::DBLVL_WARN "Did not temporarily disable static wep"
        incr rc
    }

    if {[::configurator::dut_send_cmd "wlan security 802.1x disable $wlan_id\n" $::config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to disable 1x"
        incr rc
    } 

    if { $::dut_version < "004001000000" } {
        set cmd "wlan security wpa1 disable $wlan_id"
    } else {
        set cmd "wlan security wpa wpa1 disable $wlan_id"
    }
    
    if {[::configurator::dut_send_cmd "$cmd\n" $::config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to disable wpa1"
        incr rc
    } 
    
    if { $::dut_version < "004001000000" } {
        set cmd "wlan security wpa2 disable $wlan_id"
    } else {
        set cmd "wlan security wpa wpa2 disable $wlan_id"
    }
    if {[::configurator::dut_send_cmd "$cmd\n" $::config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to disable wpa2"
        incr rc
    } 

    if { $::dut_version >= "004001000" } {
        if {[::configurator::dut_send_cmd "wlan security wpa akm psk disable $wlan_id\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to disable wpa psk"
            incr rc
        }
        
        if {[::configurator::dut_send_cmd "wlan security wpa disable $wlan_id\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to disable wpa"
            incr rc
        }
    }
    
    # and put them back in, split into groups
    incr rc [cisco-lwapp_configure_wlan_security_wep  $dut_name $cfg]
    incr rc [cisco-lwapp_configure_wlan_security_wpa  $dut_name $cfg]
    incr rc [cisco-lwapp_configure_wlan_security_wpa2 $dut_name $cfg]
    incr rc [cisco-lwapp_configure_wlan_security_1x   $dut_name $cfg]
    
    return $rc
}


# cisco-lwapp_configure_epilogue
#
# parameters:
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg      - The configuration keyed list
#
proc cisco-lwapp_configure_epilogue { dut_name cfg } {
    
    global spawn_id
    
    debug $::DBLVL_TRACE "cisco-lwapp_configure_epilogue"
    
    # any remaining configuration or cleanup
    
    set rc 0
    
    if {[catch { set wlan_id [vw_keylget cfg BssidIndex]}]} {
        debug $::DBLVL_INFO "No BssidIndex (WlanId) defined, using 1"
        set wlan_id 1
    }

    if { $::dut_version >= "004001000000" } {
        if {[::configurator::dut_send_cmd "wlan exclusionlist $wlan_id disabled\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to disable client exclusion"
        }
    
        # one would think the above command would be enough, but no
        if {[::configurator::dut_send_cmd "wps client-exclusion 802.11-assoc disable\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to disable client exclusion"
        }

        if {[::configurator::dut_send_cmd "wps client-exclusion 802.11-auth disable\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to disable client exclusion"
        }

        if {[::configurator::dut_send_cmd "wps client-exclusion 802.1x-auth disable\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to disable client exclusion"
        }
    
        if {[::configurator::dut_send_cmd "wps client-exclusion web-auth disable\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to disable client exclusion"
        }

        if {[::configurator::dut_send_cmd "wps client-exclusion ip-theft disable\n" $::config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to disable client exclusion"
        }
    }
    
    # enable the wlan
    if {[::configurator::dut_send_cmd "wlan enable $wlan_id\n" $::config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to enable wlan $wlan_id"
    }
    
    # exit config mode
    if {[::configurator::dut_send_cmd "end\n" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Did not reach admin prompt"
        incr rc
    }
    
    if {[::configurator::dut_send_cmd "save config\n" "\(y/n\)" 5]} {
        debug $::DBLVL_WARN "Did not reach save confirmation prompt"
        incr rc
    }
    
    if {[::configurator::dut_send_cmd "y\n" $::admin_prompt 5]} {
        debug $::DBLVL_WARN "Did not reach admin prompt after saving"
        incr rc
    }
    
    # close the expect connection
    after 1000
    # so any final console messages get logged
    catch {expect *}
    catch {exp_close}
    catch {wait}
    log_file
    breakable_after 5
    
    return $rc
}


# dut_configure_cisco-cisco-lwapp - Entry point for configuring cisco lwapp devices
#
# dut_name    - The name of the AP to be configured
#
# group_name  - The name of the group this AP will be configured for
#
# global_name - A pointer to the global config for this test
#
proc dut_configure_cisco-cisco-lwapp { dut_name group_name global_name } {
    
    debug $::DBLVL_TRACE "dut_configure_cisco-cisco-lwapp"
    
    # take the passed in names, find the corresponding configs
    # and pass them down to the appropriate lower level procs.
    
    upvar #0 $dut_name    dut_cfg
    upvar #0 $group_name  group_cfg
    upvar #0 $global_name global_cfg

    # merge the group and global config together
    set cfg [::configurator::merge_config "$global_cfg" "$group_cfg"]
    set cfg [::configurator::merge_config "$cfg"        "$dut_cfg"  ]

    set rc 0
    
    # no configuration necessary for an ethernet group
    if {[catch {set group_type [vw_keylget cfg GroupType]}]} {
        puts "Error: No GroupType for group $group_name"
        exit -1
    }

    if { $group_type == "802.3" } {
        return 0
    }

    if {[catch {set dut_vendor [vw_keylget cfg Vendor]}]} {
        puts "Error: No Vendor defined for $dut_name"
        exit -1
    }

    if {[catch {set dut_model [vw_keylget cfg APModel]}]} {
        if [catch {set dut_model [vw_keylget cfg Model]}] {
            puts "Error: No APModel defined for $dut_name"
            exit -1
        }
    }
    
    if {[catch {set dut_username [vw_keylget cfg ApUsername]}]} {
        if [catch {set dut_username [vw_keylget cfg Username]}] {
            puts "Error: No ApUsername defined for $dut_name"
            exit -1
        }
    }

    if {[catch {set dut_password [vw_keylget cfg ApPassword]}]} {
        if [catch {set dut_password [vw_keylget cfg Password]}] {
            puts "Error: No ApPassword defined for $dut_name"
            exit -1
        }
    }

    if {[catch {set dut_auth_username [vw_keylget cfg AuthUsername]}]} {
        set dut_auth_username ""
    }

    if {[catch {set dut_auth_password [vw_keylget cfg AuthPassword]}]} {
        set dut_auth_password ""
    }

    if {[catch {set dut_console_addr [vw_keylget cfg ConsoleAddr]}]} {
        puts "Error: No ConsoleAddr defined for $dut_name"
        exit -1
    }

    if {[catch {set dut_console_port [vw_keylget cfg ConsolePort]}]} {
        set dut_console_port 23
    }
    
    if {[cisco-lwapp_configure_prelude $dut_name $cfg]} {
        debug $::DBLVL_WARN "cisco-lwapp_configure_prelude failed"
        return 1
    }
    if {[cisco-lwapp_configure_radio $dut_name $cfg]} {
        debug $::DBLVL_WARN "cisco-lwapp_configure_radio failed"
        return 1
    }
    if {[cisco-lwapp_configure_ap $dut_name $cfg]} {
        debug $::DBLVL_WARN "cisco-lwapp_configure_ap failed"
        return 1
    }
    if {[cisco-lwapp_configure_wlan $dut_name $cfg]} {
        debug $::DBLVL_WARN "cisco-lwapp_configure_wlan failed"
        return 1
    }
    if {[cisco-lwapp_configure_wlan_security $dut_name $cfg]} {
        debug $::DBLVL_WARN "cisco-lwapp_configure_wlan_security failed"
        return 1
    }
    if {[cisco-lwapp_configure_epilogue $dut_name $cfg]} {
        debug $::DBLVL_WARN "cisco-lwapp_configure_epilogue failed"
        return 1
    }
    
    return 0
}
