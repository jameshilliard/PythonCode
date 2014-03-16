#
# foundry.tcl - configures a Foundry access point (device-under-test)
#
# Generic functions to aid in the configuration.  Any one of these can be
# overridden by a function at the model level.
#
# $Id: foundry.tcl,v 1.25.2.1.2.1 2007/12/14 20:06:57 manderson Exp $
#

set cvs_author  [cvs_clean "$Author: manderson $"]
set cvs_ID      [cvs_clean "$Id: foundry.tcl,v 1.25.2.1.2.1 2007/12/14 20:06:57 manderson Exp $"]
set cvs_file    [cvs_clean "$RCSfile: foundry.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.25.2.1.2.1 $"]
set cvs_date    [cvs_clean "$Date: 2007/12/14 20:06:57 $"]
set cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

debug $::DBLVL_CVS_VERSION "loading $cvs_file $cvs_version $cvs_date"

set ::admin_prompt  "^.*#$"

set ::config_prompt "^.*\\(config\\)#$"

#
# dut_configure_config_prompt - get a Foundry AP from any state to the config prompt.
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  dut_cfg      - The configuration keyed list
#
proc dut_configure_config_prompt { dut_name cfg} {

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_prompt"

    if [catch {set dut_username [vw_keylget cfg ApUsername]}] {
        if [catch {set dut_username [vw_keylget cfg Username]}] {
            puts "Error: No ApUsername defined for $dut_name"
            exit -1
        } else {
            debug $::DBLVL_WARN "USERNAME deprecated in DUT config.  Please use ApUsername"
        }
    }

    if [catch {set dut_password [vw_keylget cfg ApPassword]}] {
        if [catch {set dut_password [vw_keylget cfg Password]}] {
            puts "Error: No ApPassword defined for $dut_name"
            exit -1
            } else {
                debug $::DBLVL_WARN "PASSWORD deprecated in DUT config.  Please use ApPassword"
        }
    }

    # kick the console
    send "\r"
    sleep 1
    
    if {$::tcl_platform(platform) == "windows"} {
        send "\r"
        sleep 1
    }
    
    expect {
        # any sort of config prompt
        -re "^.*\\((.*)\\)#$" {
            if {"$expect_out(1,string)" != "config"} {
                # return to admin prompt and re-enter config
                if {[::configurator::dut_send_cmd "end\n" "$::admin_prompt" 5]} {
                    debug $::DBLVL_WARN "Didn't reach admin prompt."
                }
                if {[::configurator::dut_send_cmd "config\n" "$::config_prompt" 5]} {
                    debug $::DBLVL_WARN "Didn't reach config prompt"
                }
            }
        }

        # at admin prompt
        "#$" {
            if {[::configurator::dut_send_cmd "config\n" "$::config_prompt" 5]} {
                debug $::DBLVL_WARN "Didn't reach config prompt."
            }
        }

        # goofy, middle of somebody else's login prompt
        "Password: " {
            if {[::configurator::dut_send_cmd "\n\n\n$dut_username\n" "Password:" 5]} {
                debug $::DBLVL_WARN "Didn't reach password prompt."
            }
            if {[::configurator::dut_send_cmd "$dut_password\n" "$::admin_prompt" 5]} {
                debug $::DBLVL_WARN "Didn't reach admin prompt."
            }
            if {[::configurator::dut_send_cmd "config\n" "$::config_prompt" 5]} {
                debug $::DBLVL_WARN "Didn't reach config prompt"
            }
        }

        # initial login
        "Username: " {
            if {[::configurator::dut_send_cmd "$dut_username\n" "Password:" 5]} {
                debug $::DBLVL_WARN "Didn't reach password prompt"
            }
            if {[::configurator::dut_send_cmd "$dut_password\n" "$::admin_prompt" 5]} {
                debug $::DBLVL_WARN "Didn't reach admin prompt"
            }
            if {[::configurator::dut_send_cmd "config\n" "$::config_prompt" 5]} {
                debug $::DBLVL_WARN "Didn't reach config prompt"
            }
        }

        # read-only user
        "Foundry AP>$" {
            if {[::configurator::dut_send_cmd "exit\n" "Username:" 5]} {
                debug $::DBLVL_WARN "Didn't reach username prompt"
            }
            if {[::configurator::dut_send_cmd "$dut_username\n" "Password:" 5]} {
                debug $::DBLVL_WARN "Didn't reach password prompt"
            }
            if {[::configurator::dut_send_cmd "$dut_password\n" "$::admin_prompt" 5]} {
                debug $::DBLVL_WARN "Didn't reach admin prompt"
            }
            if {[::configurator::dut_send_cmd "config\n" "$::config_prompt" 5]} {
                debug $::DBLVL_WARN "Didn't reach config prompt"
            }
        }
        
        default {
            debug $::DBLVL_WARN "Unknown prompt found."
            return 1
        }
    }
    
    return 0
}


#
# dut_configure_prelude - setup to get an AP ready to be configured
#
# parameters:
#
#   dut_name        - The name of this DUT
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
    dut_configure_config_prompt "$dut_name" "$cfg"
}


#
# dut_configure_radius - configure radius server
#
#   dut_name        - The name of this DUT
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_configure_radius { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_radius"

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
        
        if {[::configurator::dut_send_cmd "radius-server address $radius_server\n" $::config_prompt 10]} {
            debug $::DBLVL_WARN "Did not set radius address"
        }
        
        if {[::configurator::dut_send_cmd "radius-server key $radius_secret\n" $::config_prompt 10]} {
            debug $::DBLVL_WARN "Did not set radius key"
        }
        
        if {[::configurator::dut_send_cmd "radius-server port $radius_auth\n" $::config_prompt 10]} {
            debug $::DBLVL_WARN "Did not set radius port"
        }
        
        if {[::configurator::dut_send_cmd "radius-server port-accounting $radius_acct\n" $::config_prompt 10]} {
            debug $::DBLVL_WARN "Did not set radius accounting port"
        }
    } else {
        debug $::DBLVL_INFO "Method $security_method method needs no radius configuration."
    }
}


#
# dut_configure_eth - configure things at the ethernet interface sub-mode
#
#   dut_name        - The name of the device to be tested.  
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_configure_eth { dut_name cfg } {

    global spawn_id
    
    set if_eth_prompt "^.*\\(if-ethernet\\)#$"
    debug $::DBLVL_TRACE "dut_configure_eth"
    
    # get to the config prompt
    dut_configure_config_prompt $dut_name "$cfg"
    
    # find the ethernet interface.  FAT Foundry's don't have a lot of options here
    set active_int "ethernet"
    
    if {[::configurator::dut_send_cmd "interface $active_int\n" "$if_eth_prompt" 10]} {
        debug $::DBLVL_WARN "Didn't get to if-ethernet"
    }
    
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
    
    if {[catch {set ip_mask [vw_keylget this_int IpMask]}]} {
        puts "Error: No subnet mask set for $active_int on $dut_name"
        exit -1
    }
    
    if {[catch {set gateway [vw_keylget this_int Gateway]}]} {
        debug $::DBLVL_INFO "No default gateway for $active_int on $dut_name, using $ip_addr"
        set gateway $ip_addr
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
    

    if {[::configurator::dut_send_cmd "ip address $ip_addr $ip_mask $gateway\n" "$if_eth_prompt" 10]} {
        debug $::DBLVL_WARN "Probably did not set ethernet address properly"
    }
    
    # no shut
    if {[::configurator::dut_send_cmd "no shutdown\n" "$if_eth_prompt" 10]} {
        debug $::DBLVL_WARN "Didn't get to if-ethernet"
    }
    
    if {[::configurator::dut_send_cmd "exit\n" "$::config_prompt" 10]} {
        debug $::DBLVL_WARN "Could not exit if-eth mode"
    }
}


#
# dut_configure_wireless - configure things at the radio sub-mode
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
    
    if { $channel <= 11 } {
        set active_int "wireless_g"
    } else {
        set active_int "wireless_a"
    }
    set int_name [string map {_ " "} $active_int]
    set if_11_prompt "^.*\\(if-$int_name\\)#$"

    if {[::configurator::dut_send_cmd "interface $int_name\n" "$if_11_prompt" 10]} {
        debug $::DBLVL_WARN "Didn't get to $if_11_prompt"
    }
    
    if {[::configurator::dut_send_cmd "channel $channel\n" "$if_11_prompt" 10]} {
        debug $::DBLVL_WARN "Didn't set channel to $channel"
    }

    if {![catch {set this_int_list [vw_keylget cfg Interface]}]} {
        if {[catch {set this_int [vw_keylget this_int_list $active_int]}]} {
            puts "Error: No interface \"$active_int\" defined for $dut_name"
            exit -1
        }
    }
    
    if {[catch {set power_level [vw_keylget this_int Power]}]} {
        debug $::DBLVL_INFO "No power level set for $dut_name - $active_int, defaulting"
        set power_level "auto"
    }
    if {[::configurator::dut_send_cmd "transmit-power $power_level\n" "$if_11_prompt" 10]} {
        debug $::DBLVL_WARN "Didn't set power to $power"
    }
    
    # get/set the WEP keys
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
        "WPA2-EAP-TLS"       -
        "WPA-PSK"            -
        "WPA-PEAP-MSCHAPV2-AES" -
        "WPA2-PEAP-MSCHAPV2-TKIP" -
        "WPA-PSK-AES"        -
        "WPA2-PSK-TKIP"      -
        "WPA2-PSK"           {
            debug $::DBLVL_INFO "No WEP key needed"
        }   

        "WEP-Open-40"       -
        "WEP-SharedKey-40"  {
            set is_ascii 1
            if {[catch {set wep [vw_keylget cfg WepKey40Ascii]}]} {
                set is_ascii 0
                if {[catch {set wep [vw_keylget cfg WepKey40Hex]}]} {
                    set is_ascii 1
                    set wep "12345"
                }
            }
            if { $is_ascii } {
                if {[::configurator::dut_send_cmd "key 1 64 ascii $wep\n" $if_11_prompt 10]} {
                    debug $::DBLVL_WARN "Unable to set ASCII WEP-40 key"
                }
            } else {
                if {[::configurator::dut_send_cmd "key 1 64 hex $wep\n" $if_11_prompt 10]} {
                    debug $::DBLVL_WARN "Unable to set HEX WEP-40 key"
                }
            }
        }

        "WEP-Open-128"      -
        "WEP-SharedKey-128" {
            set is_ascii 1
            if {[catch {set wep [vw_keylget cfg WepKey128Ascii]}]} {
                set is_ascii 0
                if {[catch {set wep [vw_keylget cfg WepKey128Hex]}]} {
                    set is_ascii 1 
                    set wep "123456789ABCD"
                }
            }
            if { $is_ascii } {
                if {[::configurator::dut_send_cmd "key 1 128 ascii $wep\n" $if_11_prompt 10]} {
                    debug $::DBLVL_WARN "Unable to set ASCII WEP-128 key"
                }
            } else {
                if {[::configurator::dut_send_cmd "key 1 128 hex $wep\n" $if_11_prompt 10]} {
                    debug $::DBLVL_WARN "Unable to set HEX WEP-128 key"
                }
            }
        }

        default {
            debug $::DBLVL_WARN "Unsupported method $security_method - wep keys"
        }
    }
    
    if {[info exists enc_key]} {
        if {[::configurator::dut_send_cmd "$enc_key\n" "$if_11_prompt" 10]} {
            debug $::DBLVL_WARN "Unable to set key to $enc_key"
        }
    }
    
    if {[catch {set antenna_diversity [vw_keylget this_int AntennaDiversity]} result]} {
        set antenna_diversity "full"
        debug $::DBLVL_INFO "No antenna diversity setting - using full mode"
    }
    
    set antenna_diversity [string tolower $antenna_diversity]
    if {[::configurator::dut_send_cmd "antenna diversity $antenna_diversity\n" "$if_11_prompt" 10]} {
        debug $::DBLVL_WARN "Unable to set diversity"
    }
    
    if {[catch {set vap [vw_keylget cfg BssidIndex]} result]} {
        set vap "0"
        debug $::DBLVL_INFO "No BssidIndex (VAP) set, using 0"
    }
    
    set if_vap_prompt "^.*\\(if-$int_name: VAP\\\[$vap\\\]\\)#$"
    
    if {[::configurator::dut_send_cmd "vap $vap\n" "$if_vap_prompt" 10]} {
        debug $::DBLVL_WARN "Unable to enter VAP sub-mode"
    }
    
    set dut_ssid [::configurator::find_ssid "$dut_name" "$cfg" "$active_int"]
    if {[::configurator::dut_send_cmd "ssid $dut_ssid\n" "$if_vap_prompt" 10]} {
        debug $::DBLVL_WARN "Unable to set ssid"
    }
    
    # get the authentication info
    set authentication "authentication "
    switch $security_method {

        "None"               -
        "WEP-Open-40"        -
        "WEP-Open-128"       -
        "DWEP-EAP-TLS"       -
        "DWEP-EAP-TTLS-GTC"  -
        "DWEP-PEAP-MSCHAPV2" {
            append authentication "open"
        }
        
        "WEP-SharedKey-40"  -
        "WEP-SharedKey-128" {
            append authentication "shared"
        }

		"WPA-PSK-AES" -
        "WPA-PSK" {
            append authentication "wpa-psk require"
        }
        
        "WPA2-PSK-TKIP" - 
        "WPA2-PSK" {
            append authentication "wpa2-psk require"
        }
        
        "WPA-EAP-TLS"       -
        "WPA-EAP-TTLS-GTC"  -
        "WPA-PEAP-MSCHAPV2-AES" - 
        "WPA-PEAP-MSCHAPV2" {
            append authentication "wpa req"
        }
        
        "WPA2-EAP-TLS"       -
        "WPA2-EAP-TTLS-GTC"  -
        "WPA2-PEAP-MSCHAPV2-TKIP" - 
        "WPA2-PEAP-MSCHAPV2" {
            append authentication "wpa2 req"
        }
        
        default {
            debug $::DBLVL_WARN "Unsupported method $security_method - authentication"
            set authentication ""
        }
    }
    
    if {[::configurator::dut_send_cmd "$authentication\n" "$if_vap_prompt" 10]} {
        debug $::DBLVL_WARN "Unable to set authentication \"$authentication\""
    }
    
    # and the encryption info
    switch $security_method {

        "None" {
            set encryption "no encryption"
        }
        
        "WEP-Open-40"        -
        "WEP-Open-128"       -
        "WPA-PSK"            -
        "WPA2-PSK"           -
        "WPA-EAP-TLS"        -
        "WPA2-EAP-TLS"       -
        "WEP-SharedKey-40"   -
        "WEP-SharedKey-128"  -
        "WPA-EAP-TTLS-GTC"   -
        "WPA2-EAP-TTLS-GTC"  -
        "WPA-PEAP-MSCHAPV2"  -
        "WPA-PEAP-MSCHAPV2-AES" -
        "WPA2-PEAP-MSCHAPV2-TKIP" -
        "WPA-PSK-AES"        -
        "WPA2-PSK-TKIP"      -
        "WPA2-PEAP-MSCHAPV2" -
        "DWEP-EAP-TLS"       -
        "DWEP-EAP-TTLS-GTC"  -
        "DWEP-PEAP-MSCHAPV2" {
            set encryption "encryption"
        }
    }

    if {[info exists encryption]} {
        if {[::configurator::dut_send_cmd "$encryption\n" "$if_vap_prompt" 10]} {
            debug $::DBLVL_WARN "Unable to set encryption \"$encryption\""
        }
    }
        
    # 802.1x
    switch $security_method {

        "None"              -
        "WEP-Open-40"       -
        "WEP-Open-128"      -
        "WEP-SharedKey-40"  -
        "WEP-SharedKey-128" -
        "WPA-PSK"           -
        "WPA-PSK-AES"       -
        "WPA2-PSK-TKIP"     - 
        "WPA2-PSK"          {
            set eap "no 802.1x"
        }

        "WPA-EAP-TLS"        -
        "WPA2-EAP-TLS"       -
        "WPA-EAP-TTLS-GTC"   -
        "WPA2-EAP-TTLS-GTC"  -
        "WPA-PEAP-MSCHAPV2"  -
        "WPA2-PEAP-MSCHAPV2" -
        "DWEP-EAP-TLS"       -
        "DWEP-EAP-TTLS-GTC"  -
        "WPA2-PEAP-MSCHAPV2-TKIP" -
        "WPA-PEAP-MSCHAPV2-AES" -
        "DWEP-PEAP-MSCHAPV2" {
            set eap "802.1x required"
        }
    }

    if {[info exists eap]} {
        if {[::configurator::dut_send_cmd "$eap\n" "$if_vap_prompt" 10]} {
            debug $::DBLVL_WARN "Unable to set 802.1x \"$eap\""
        }
    }
        
    
    # and lastly the keys for psk
    switch $security_method {
        
        "None"               -
        "WEP-Open-40"        -
        "WEP-Open-128"       -
        "WEP-SharedKey-40"   -
        "WEP-SharedKey-128"  -
        "WPA-EAP-TLS"        -
        "WPA2-EAP-TLS"       -
        "WPA-EAP-TTLS-GTC"   -
        "WPA2-EAP-TTLS-GTC"  -
        "WPA-PEAP-MSCHAPV2"  -
        "WPA2-PEAP-MSCHAPV2-TKIP" -
        "WPA-PEAP-MSCHAPV2-AES" -
        "WPA2-PEAP-MSCHAPV2" -
        "DWEP-EAP-TLS"       -
        "DWEP-EAP-TTLS-GTC"  -
        "DWEP-PEAP-MSCHAPV2" {
        }

        "WPA-PSK"           -
        "WPA-PSK-AES"       -
        "WPA2-PSK-TKIP"     -
        "WPA2-PSK"          {
            set is_ascii 1
            if [catch {set psk [vw_keylget cfg PskAscii]}] {
                set is_ascii 0
                if [catch {set psk [vw_keylget cfg PskHex]}] {
                    set is_ascii 1
                    set psk "whatever"
                }
            }
            if {[::configurator::dut_send_cmd "wpa-preshared-key passphrase-key $psk\n" $if_vap_prompt 10]} {
                if { $is_ascii } {
                    debug $::DBLVL_WARN "Unable to set ASCII PSK key"
                
                } else {
                    debug $::DBLVL_WARN "Unable to set HEX PSK key"
   
                }
            }
        }
        
        default {
            debug $::DBLVL_WARN "Unsupported method $security_method - psk"
        }
        
        
       
        
    }
    
    # alternative ciphers 
	
	switch $security_method {
	
		"WPA2-PEAP-MSCHAPV2-TKIP"  -
		"WPA2-PSK-TKIP"            {
			 if {[::configurator::dut_send_cmd "cipher-suite tkip\n" $if_vap_prompt 10]} {
				debug $::DBLVL_WARN "Unable to set cipher-suite tkip"
			}
		
		}
		
		"WPA-PEAP-MSCHAPV2-AES"    -
		"WPA-PSK-AES"              { 
			 if {[::configurator::dut_send_cmd "cipher-suite aes-ccmp\n" $if_vap_prompt 10]} {
				debug $::DBLVL_WARN "Unable to set cipher-suite aes-ccmp"
			}
		}
	}


    if {[::configurator::dut_send_cmd "no shutdown\n" "$if_vap_prompt" 10]} {
        debug $::DBLVL_WARN "Unable to no shut VAP $vap"
    }
    
    if {[::configurator::dut_send_cmd "exit\n" "$if_11_prompt" 10]} {
        debug $::DBLVL_WARN "Unable to leave VAP sub-mode"
    }
    
    if {[::configurator::dut_send_cmd "exit\n" "$::config_prompt" 10]} {
        debug $::DBLVL_WARN "Unable to leave wireless sub-mode"
    }
}


#
# dut_configure_epilogue - configuration to do any tasks needed before
#                      configuration is sent to the DUT
#
#   dut_name        - The name of the device to be tested.  
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_configure_epilogue { dut_name cfg } {
    global $dut_name
    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_epilogue"
    
    # return back to the login prompt
    if {[::configurator::dut_send_cmd "end\n" "$::admin_prompt" 10]} {
        debug $::DBLVL_WARN "Didn't reach admin prompt"
    }
    
    # and log out.  we don't care about tracking prompts since this could be
    # a term server or a generic telnet session.
    send "exit\n" 
    
    # close the expect connection
    if {[catch {exp_close} result]} {
        debug $::DBLVL_WARN "Close of socket returned:$result"
    }
    catch {wait}
    log_file
    breakable_after 2
}


#
# dut_configure_ap_global - configure things at the global (per-ap) level
#
#   dut_name        - The name of the device to be tested.  
#
#   cfg             - The merged group, global and dut configuration
#
proc dut_configure_ap_global { dut_name cfg } {
    global $dut_name
    global spawn_id

    debug $::DBLVL_TRACE "dut_configure_ap_global"

    # get to the config prompt
    dut_configure_config_prompt $dut_name $cfg

    # check for and configure the Inline Scanning parameter
    dut_configure_ap_global_parameter $dut_name "$cfg" "InlineScanning" "inline-scanning" "no inline-scanning"
    
    # check for and configure the LoadBalance setting
    if {[catch {set loadbalance_weight [vw_keylget cfg LoadBalance]}]} {
        debug $::DBLVL_CFG "No LoadBalance setting.  Will not alter loadbalance setting on $dut_name."
    } else {
        debug $::DBLVL_CFG "User specified LoadBalance weight for $dut_name as $loadbalance_weight"

        if {[is_negative_parameter $loadbalance_weight]} {
            set loadbalance_cmd "no loadbalance"
        } else {
            set loadbalance_cmd "loadbalance $loadbalance_weight"
         }

        if {[::configurator::dut_send_cmd "$loadbalance_cmd\n" $::config_prompt 10]} {
            debug $::DBLVL_WARN "Unable to set LoadBalance $loadbalance_weight for $dut_name"
        }
    }

}


proc dut_configure_ap_global_parameter { dut_name cfg param affirmative_cli negative_cli } {

    if {[catch {set mode [vw_keylget cfg $param]}]} {
        debug $::DBLVL_CFG "No $param setting.  Will not alter $param setting on $dut_name."
    } else {
        debug $::DBLVL_CFG "User specified $param for $dut_name as $mode"
        set cmd ""

        if {[::configurator::is_affirmative_parameter $mode]} {
            set cmd $affirmative_cli
        } else {
            if {[::configurator::is_negative_parameter $mode]} {
                set cmd $negative_cli
            } else {
                debug $::DBLVL_WARN "Unsupported $param setting $mode"
            }
        }

        if {[::configurator::dut_send_cmd "$cmd\n" $::config_prompt 10]} {
            debug $::DBLVL_WARN "Unable to set $param to $mode for $dut_name"
        }
    }
}
