#
# symbol-ap.tcl - configures a Symbol access point (device-under-test)
#
# Generic functions to aid in the configuration.  Any one of these can be
# overridden by a function at the model level.
#
# $Id: symbol-ap.tcl,v 1.3 2007/04/04 01:46:46 wpoxon Exp $
#

set cvs_author  [cvs_clean "$Author: wpoxon $"]
set cvs_ID      [cvs_clean "$Id: symbol-ap.tcl,v 1.3 2007/04/04 01:46:46 wpoxon Exp $"]
set cvs_file    [cvs_clean "$RCSfile: symbol-ap.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.3 $"]
set cvs_date    [cvs_clean "$Date: 2007/04/04 01:46:46 $"]
set cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

debug $::DBLVL_CVS_VERSION "loading $cvs_file $cvs_version $cvs_date"

set ::toplevel_config_prompt  "admin>"

# this one is overused in the code below and should really be a pattern for
# each and every prompt instead of lumping them all together
set ::submode_config_prompt "admin\(.*\)>"

set ::network_config_prompt "admin\(network\)>"

set ::login_prompt "login:"
set ::password_prompt "Password:"

#
# end the current configuration submode and "move up one level"
# in the configuration menu structure
#
set ::exit_submode_cmd ".."

#
# end the current configuration submode and move up to the "top level"
# of the configuration menu structure
#
set ::toplevel_cmd "/"

#
# dut_configure_symbol_ap - top level procedure to configure a Symbol AP
#
# parameters:
# dut_name    - The name of the AP to be configured
#
# group_name  - The name of the group this AP will be configured for
#
# global_name - A pointer to the global config for this test
#
proc dut_configure_symbol_ap { dut_name group_name global_name } {    

    global $dut_name

    debug $::DBLVL_TRACE "dut_configure_symbol_ap"
    
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
    
    if {[dut_configure_prelude   $dut_name $cfg]} {
        puts "Error: Unable to get to config prompt"
        return -1
    }

    if {[catch {set group_type [vw_keylget cfg GroupType]}]} {
        puts "Error: No GroupType for group $group_name"
        exit -1
    }

    if { $group_type == "802.11abg" } {
        dut_configure_wireless  "$dut_name" "$cfg"
    } else {
        dut_configure_eth       "$dut_name" "$cfg"
    }        
    dut_configure_epilogue  $dut_name $cfg
    
    ping_pause $dut_console_addr

    return 0
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
    
    debug $::DBLVL_TRACE "dut_configure_config_prompt"

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

    # kick the console
    send "\r"
    sleep 1
    
    expect {
        # any sort of config prompt
        -re "$::submode_config_prompt" {
	        # return to toplevel config prompt and re-enter config
	        if {[::configurator::dut_send_cmd "/\n" "$::toplevel_config_prompt" 5]} {
		        debug $::DBLVL_WARN "Didn't reach toplevel config prompt."
	        }
        }

        # at password prompt
        "$::password_prompt" {
            if {[::configurator::dut_send_cmd "\n" "$::login_prompt" 5]} {
                debug $::DBLVL_WARN "Didn't reach login prompt."
            }
            if {[::configurator::dut_send_cmd "$dut_username\n" "$::password_prompt" 5]} {
                debug $::DBLVL_WARN "Didn't reach password prompt."
            }
            if {[::configurator::dut_send_cmd "$dut_password\n" "$::toplevel_config_prompt" 5]} {
                debug $::DBLVL_WARN "Didn't reach toplevel config prompt."
            }
        }

        # at login prompt
        "$::login_prompt" {
            if {[::configurator::dut_send_cmd "$dut_username\n" "$::password_prompt" 5]} {
                debug $::DBLVL_WARN "Didn't reach password prompt"
            }
            if {[::configurator::dut_send_cmd "$dut_password\n" "$::toplevel_config_prompt" 5]} {
                debug $::DBLVL_WARN "Didn't reach toplevel_config prompt"
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


# dut_configure_erase_config - reset an AP to factory defaults
#
# WARNING: on the symbol-5131, this will wipe out the IP addr assigned
# to the ethernet interface.  This means that if you are configuring the AP
# vial a telnet connection to the ethernet interface,
# you probably won't be able to "talk" to
# the AP again until you switch to using its factor default IP
# address which is 192.168.0.1
#
# If you are configuring the AP over a serial console connection
# then there should be no such problems.
#
# parameters:
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The configuration keyed list
#
proc dut_configure_erase_config { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_erase_config"
    
    # get to the config prompt
    if {[::configurator::dut_send_cmd "$::toplevel_cmd\n" "$::toplevel_config_prompt" 10]} {
        debug $::DBLVL_WARN "Didn't reach toplevel config prompt"
    }

    # get to the system prompt: admin(system)>
    if {[::configurator::dut_send_cmd "system\n" "$::submode_config_prompt" 10]} {
        debug $::DBLVL_WARN "Didn't reach system submode config prompt"
    }
    
    # get to the system.config prompt: admin(system.config)>
    if {[::configurator::dut_send_cmd "config\n" "$::submode_config_prompt" 10]} {
        debug $::DBLVL_WARN "Didn't reach system submode config prompt"
    }
    

    # wdp notes: do parens in (yes/no) below need to be escaped?
    #
    # run the "default" command to set the ap back to factory defaults
    if {[::configurator::dut_send_cmd "default\n" "(yes/no)" 10]} {
        puts "Error: Did not find reset confirmation prompt"
        return 1
    }
    
    send "yes\n"
    
    # close the expect connection
    catch {exp_close}
    catch {wait}
    log_file
    breakable_after 180
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

        if {[::configurator::dut_send_cmd "set eap server 1 $radius_server\n" $::submode_config_prompt 5]} {
            debug $::DBLVL_WARN "Did not properly configure radius server address"
        }
        
        if {[catch {set radius_auth [vw_keylget cfg RadiusServerAuthPort]}]} {
            debug $::DBLVL_INFO "No RadiusServerAuthPort defined for $dut_name.  Defaulting."
            set radius_auth 1812
        }
        
        if {[::configurator::dut_send_cmd "set eap port 1 $radius_auth\n" $::submode_config_prompt 5]} {
            debug $::DBLVL_WARN "Did not properly configure radius port"
        }

        if {[catch {set radius_secret [vw_keylget cfg RadiusServerSecret]}]} {
            puts "Error: No RadiusServerSecret defined in $dut_name"
            exit -1
        }
        
        if {[::configurator::dut_send_cmd "set eap secret 1 $radius_secret\n" $::submode_config_prompt 5]} {
            debug $::DBLVL_WARN "Did not properly configure radius secret"
        }
        
        # note that this code does not yet support sending accounting to another radius
        # server although the symbol supports it.
        if {![catch {set radius_acct [vw_keylget cfg RadiusServerAcctPort]}]} {
            if {[::configurator::dut_send_cmd "set eap accounting mode enable\n" $::submode_config_prompt 5]} {
                debug $::DBLVL_WARN "Did not properly enable radius accounting"
            }
            if {[::configurator::dut_send_cmd "set eap accounting server $radius_server\n" $::submode_config_prompt 5]} {
                debug $::DBLVL_WARN "Did not properly set radius accounting server"
            }
            if {[::configurator::dut_send_cmd "set eap accounting secret $radius_secret\n" $::submode_config_prompt 5]} {
                debug $::DBLVL_WARN "Wring: Did not properly set radius accounting secret"
            }
            if {[::configurator::dut_send_cmd "set eap accounting port $radius_acct\n" $::submode_config_prompt 5]} {
                debug $::DBLVL_WARN "Did not properly set radius accounting port"
            }
        }
    } else {
        debug $::DBLVL_INFO "Method $security_method method needs no radius configuration."
    }
}


#
# dut_configure_eth - configure things at the ethernet interface sub-mode
#
# parameters:
#  dut_name     - The name of the device to be tested.
#
#  cfg          - The configuration keyed list
#
proc dut_configure_eth { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_eth"
    
    # get to the config prompt
    dut_configure_config_prompt $dut_name $cfg
    
    # find the ethernet interface
    set active_int "lan"

    if {[::configurator::dut_send_cmd "network\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Did not enter network sub-mode"
    }
    
    if {[::configurator::dut_send_cmd "$active_int\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Warning: Did not enter $active_int sub-mode"
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

    if {[catch {set lan_idx [vw_keylget cfg LanIdx]}]} {
        debug $::DBLVL_INFO "No LAN index found, defaulting to 1"
        set lan_idx 1
    }
    
    # grab the console address and port
    if {[catch {set console_addr [vw_keylget cfg ConsoleAddr]}]} {
        debug $::DBLVL_WARN "No console address found.  Something is amiss."
        set console_addr "0.0.0.0"
    }
    
    if {[catch {set console_port [vw_keylget cfg ConsolePort]}]} {
        debug $::DBLVL_INFO "No console port found.  Defaulting to telnet."
        set console_port 23
    }
    
    if {[::configurator::dut_send_cmd "set ipadr $lan_idx $ip_addr\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Did not set LAN IP address"
    }
        
    if {[::configurator::dut_send_cmd "set mask $lan_idx $ip_mask\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Did not set LAN subnet mask"
    }
        
    if {[::configurator::dut_send_cmd "set dgw $lan_idx $gateway\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Did not set LAN default gateway"
    }
        
    # eh?
    if {[::configurator::dut_send_cmd "set ip-mode $lan_idx static\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Did not set LAN mode to static"
    }
        
    if {[::configurator::dut_send_cmd "set lan $lan_idx enable\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Did not enable LAN interface"
    }
    
    if {[::configurator::dut_send_cmd "set ethernet-port-lan $lan_idx\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Did not set ethernet port lan index"
    }
    
    if {[::configurator::dut_send_cmd "..\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Could not exit $active_int sub-mode"
    }
    
    if {[::configurator::dut_send_cmd "..\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Could not exit network sub-mode"
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
proc dut_configure_wireless { dut_name cfg } {

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_wireless"

    if {[catch {set security_method [vw_keylget cfg Method]}]} {
        puts "Error: \"$dut_name\" has no defined Method"
        exit -1
    }
    
    if {[catch {set channel [vw_keylget cfg Channel]}]} {
        debug $::DBLVL_INFO "\"$dut_name\" has no configured Channel.  Skipping radio config"
        return 0
    }

    if { $channel <= 11 } {
        set active_int "radio1"
    } else {
        set active_int "radio2"
    }

    if {[::configurator::dut_send_cmd "network\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Did not reach network config prompt"
    }

    if {[::configurator::dut_send_cmd "wireless\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Did not reach network.wireless prompt"
    }
    
   if {[::configurator::dut_send_cmd "security\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to enter security sub-mode"
    }
    
    if {[catch {set sec_name [vw_keylget cfg Ssid]}]} {
        debug $::DBLVL_INFO "No Ssid defined in config for security name.  Defaulting to \"veriwave\""
        set sec_name "veriwave"
    }

    if { $sec_name != "Default" } {
        # let it fail
        ::configurator::dut_send_cmd "delete $sec_name\n" $::submode_config_prompt 5
    
        if {[::configurator::dut_send_cmd "create\n" $::submode_config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to create new security policy"
        }
        if {[::configurator::dut_send_cmd "set sec-name $sec_name\n" $::submode_config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to set sec-name to $sec_name"
        }
    } else {
        if {[::configurator::dut_send_cmd "edit 1\n" $::submode_config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to edit Default security policy"
        }
    }
    
    switch $security_method {

        "None"               -
        "WEP-Open-40"        -
        "WEP-Open-128"       -
        "WEP-SharedKey-40"   -
        "WEP-SharedKey-128"  -
        "WPA-PSK"            -
        "WPA2-PSK"           {
            set authentication "none"
        }
        
        "WPA-EAP-TLS"        -
        "WPA-EAP-TTLS-GTC"   -
        "WPA-PEAP-MSCHAPV2"  -
        "WPA2-EAP-TLS"       -
        "WPA2-EAP-TTLS-GTC"  -
        "WPA2-PEAP-MSCHAPV2" -
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
    if {[::configurator::dut_send_cmd "set auth $authentication\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set auth"
    }
    
    dut_configure_radius $dut_name $cfg

    switch $security_method {

        "None"               {
            set encryption "none"
        }
        
        "WEP-Open-40"        -
        "WEP-SharedKey-40"   {
            set encryption "wep40"
        }
        
        "WEP-Open-128"       -
        "WEP-SharedKey-128"  -
        "DWEP-EAP-TLS"       -
        "DWEP-EAP-TTLS-GTC"  -
        "DWEP-PEAP-MSCHAPV2" {
            set encryption "wep104"
        }
        
        "WPA-EAP-TLS"        -
        "WPA-EAP-TTLS-GTC"   -
        "WPA-PEAP-MSCHAPV2"  -
        "WPA-PSK"            {
            set encryption "tkip"
        }
        
        "WPA2-EAP-TLS"       -
        "WPA2-EAP-TTLS-GTC"  -
        "WPA2-PEAP-MSCHAPV2" -
        "WPA2-PSK"           {
            set encryption "ccmp"
        }

        default {
            debug $::DBLVL_WARN "Unsupported method $security_method - encryption"
            set encryption "none"
        }
    }
    if {[::configurator::dut_send_cmd "set enc $encryption\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set enc"
    }
    
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
                debug $::DBLVL_INFO "No authentication keys needed"
        }   

        "WEP-Open-40"       -
        "WEP-SharedKey-40"  {
            if {[::configurator::dut_send_cmd "set wep-keyguard index 1\n" $::submode_config_prompt 5]} {
                debug $::DBLVL_WARN "Unable to set WEP key index"
            }
            
            set key_type "ascii-key"
            if {[catch {set wep [vw_keylget cfg WepKey40Ascii]}]} {
                set key_type "hex-key"
                if {[catch {set wep [vw_keylget cfg WepKey40Hex]}]} {
                    set key_type "ascii-key"
                    set wep "12345"
                }
            }

            if {[::configurator::dut_send_cmd "set wep-keyguard $key_type 1 $wep\n" $::submode_config_prompt 5]} {
                debug $::DBLVL_WARN "Unable to set 40 bit WEP key"
            }
        }

        "WEP-Open-128"      -
        "WEP-SharedKey-128" {
            if {[::configurator::dut_send_cmd "set wep-keyguard index 1\n" $::submode_config_prompt 5]} {
                debug $::DBLVL_WARN "Unable to set WEP key index"
            }
            
            set key_type "ascii-key"
            if {[catch {set wep [vw_keylget cfg WepKey128Ascii]}]} {
                set key_type "hex-key"
                if {[catch {set wep [vw_keylget cfg WepKey128Hex]}]} {
                    set key_type "ascii-key" 
                    set wep "123456789ABCD"
                }
            }
            
            if {[::configurator::dut_send_cmd "set wep-keyguard $key_type 1 $wep\n" $::submode_config_prompt 5]} {
                debug $::DBLVL_WARN "Unable to set 128 bit WEP key"
            }
        }

        "WPA-PSK"           -
        "WPA2-PSK"          {
            set is_ascii "phrase"
            if [catch {set psk [vw_keylget cfg PskAscii]}] {
                set is_ascii "key"
                if [catch {set psk [vw_keylget cfg PskHex]}] {
                    set is_ascii "phrase"
                    set psk "whatever"
                }
            }
            if { $security_method == "WPA-PSK" } {
                set enc "tkip"
            } else {
                set enc "ccmp"
            }
            if {[::configurator::dut_send_cmd "set $enc type $is_ascii\n" $::submode_config_prompt 5]} {
                debug $::DBLVL_WARN "Unable to set PSK type"
            }
            if {[::configurator::dut_send_cmd "set $enc $is_ascii $psk\n" $::submode_config_prompt 5]} {
                debug $::DBLVL_WARN "Unable to set PSK key"
            }
        }

        default {
            debug $::DBLVL_WARN "Unsupported method $security_method - wep keys"
        }
    }
    
    if { $sec_name == "Default" } {
        set save_me "change\n"
    } else {
        if {[::configurator::dut_send_cmd "add-policy\n" $::submode_config_prompt 5]} {
            debug $::DBLVL_WARN "Unable to add security policy"
        }

        set save_me "save\n"
    }

    if {[::configurator::dut_send_cmd "$save_me\n" $::submode_config_prompt 60]} {
            debug $::DBLVL_WARN "Unable to save security policy"
    } 
    
    if {[::configurator::dut_send_cmd "..\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to leave security sub-mode"
    }
    
    if {[::configurator::dut_send_cmd "wlan\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to enter wlan sub-mode"
    }
    
    set dut_ssid [::configurator::find_ssid $dut_name $cfg $active_int]
    # remove the previously configured wlan
    if {[catch {set prev_wlan [keylget ::configurator::user_config ssid_is_method]}]} {
        set prev_wlan $dut_ssid
    }
    if { $prev_wlan == "" } {
        set prev_wlan $dut_ssid
    }
    if {[catch {keylset ::configurator::user_config ssid_is_method $dut_ssid} result]} {
        debug $::DBLVL_INFO "Unable to store old SSID - $result"
    }
    
    if {[::configurator::dut_send_cmd "delete $prev_wlan\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to remove old wlan configuration"
    }

    if {[::configurator::dut_send_cmd "create\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to create new wlan config"
    }

    # necessary?  seems to use the ESSID
    if {[::configurator::dut_send_cmd "set wlan-name $dut_ssid\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set wlan name"
    }
    
    if {[::configurator::dut_send_cmd "set ess $dut_ssid\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set ssid"
    }
    
    if {[catch {set bcast [vw_keylget cfg SsidBroadcast]}]} {
        debug $::DBLVL_INFO "No SsidBroadcast defined in config.  Defaulting to enabled"
        set bcast "enable"
    }

    # in case the DUT config was based on another vendor
    if { $bcast == "true" } {
        set bcast "enable"
    }
    
    # the Veriwave box trips and stumbles if this is enabled
    if {[::configurator::dut_send_cmd "set sbeacon disable\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Did not set ESSID beacon mode"
    }
    
    if {[::configurator::dut_send_cmd "set bcast $bcast\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Did not set accept broadcast essid"
    }
    
    switch $active_int {
   	    "radio1" {
   	    		set radio_type "bg"
   	    }
   	    "radio2" {
   	        set radio_type "a"
   	    }
   	    default {
   	        debug $::DBLVL_INFO "No InterfaceType set for $active_int.  Defaulting to a"
            set radio_type "a"
        }
    }

    if {[::configurator::dut_send_cmd "set 11$radio_type enable\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to enable \"$radio_type\" radio"
    }
    
    if {[::configurator::dut_send_cmd "set security $sec_name\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to tie security mode to wlan"
    }
    
    if {[::configurator::dut_send_cmd "add-wlan\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to add wlan"
    }
    
    if {[::configurator::dut_send_cmd "..\n" $::submode_config_prompt 10]} {
        debug $::DBLVL_WARN "Unable to leave wlan sub-mode"
    }

    if {[::configurator::dut_send_cmd "radio\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Did not reach network.wireless.radio prompt"
    }
    
    if {[::configurator::dut_send_cmd "$active_int\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Did not reach network.wireless.radio.$active_int prompt"
    }

    if {[::configurator::dut_send_cmd "set ch-mode user\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Did not set channel mode"
    }
    
    # get/set the channel
    if {[catch {set channel [vw_keylget cfg Channel]}]} {
        puts "Error: Cannot find CHANNEL for $dut_name."
        exit -1
    }

    if {[::configurator::dut_send_cmd "set channel $channel\n" $::submode_config_prompt 5]} {
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
        set power_level "10"
    }

    if {[::configurator::dut_send_cmd "set power $power_level\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Didn't set power to $power_level"
    }
    
    if {[catch {set antenna_diversity [vw_keylget this_int AntennaDiversity]} result]} {
        set antenna_diversity "full"
        debug $::DBLVL_INFO "No antenna diversity setting - using full mode"
    }
    
    set antenna_diversity [string tolower $antenna_diversity]
    if {[::configurator::dut_send_cmd "set antenna $antenna_diversity\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set diversity"
    }

    if {[catch {set placement [vw_keylget this_int Placement]} result]} {
        set placement "indoor"
        debug $::DBLVL_INFO "Defaulting to indoors placement"
    }
    
    if {[::configurator::dut_send_cmd "set placement $placement\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to set placement"
    }
    
    if {[::configurator::dut_send_cmd "advanced\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Could not enter advanced radio mode"
    }
    
    if {[catch {set bssid_id [vw_keylget cfg BssidIndex]}]} {
        debug $::DBLVL_INFO "No BssidIndex (BssidId) set, using 4"
        set bssid_id 4
    }
    
    if {[::configurator::dut_send_cmd "set wlan $dut_ssid $bssid_id\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to tie $dut_ssid to $bssid_id"
    }
    
    if {[::configurator::dut_send_cmd "set bss $bssid_id $dut_ssid\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to tie $bssid_id to $dut_ssid"
    }
    
    if {[::configurator::dut_send_cmd "..\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to leave $active_int advanced sub-mode"
    }
    
    if {[::configurator::dut_send_cmd "..\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to leave $active_int sub-mode"
    }
    
    if {[::configurator::dut_send_cmd "..\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to leave radio sub-mode"
    }
    
    if {[::configurator::dut_send_cmd "..\n" $::submode_config_prompt 5]} {
        debug $::DBLVL_WARN "Unable to leave wireless sub-mode"
    }
    
    if {[::configurator::dut_send_cmd "..\n" $::submode_config_prompt 5]} {
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

    global spawn_id
    
    debug $::DBLVL_TRACE "dut_configure_epilogue"
    
    if {[::configurator::dut_send_cmd "save\n" $::submode_config_prompt 60]} {
        debug $::DBLVL_WARN "Unable to save wlan"
    }
    
    # return back to the login prompt
    #if {[::configurator::dut_send_cmd "end\n" "$::admin_prompt" 10]} {
    #    debug 1 "Didn't reach admin prompt"
    #}
    
    # and log out.  we don't care about tracking prompts since this could be
    # a term server or a generic telnet session.
    #send "exit\n" 
    
    # close the expect connection
    catch {exp_close}
    catch {wait}
    log_file
    breakable_after 2
}

