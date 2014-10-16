
#
# environment.tcl - sets up the environment so that sub-programs
#    invoked from within the main automation script(s)
#    can learn critical items (such as the root of the VeriWave
#    automation tree) from environment variables
#
# this file is sourced by automation programs found in $VW_TEST_ROOT/bin
#
# $Id: environment.tcl,v 1.12.6.1 2008/01/24 20:56:22 manderson Exp $

# tell python where to find modules and whatnot
if { $tcl_platform(platform) == "windows" } {
    set path_sep ";"
    set env(PYTHONPATH) "C:\\Program Files\\Veriwave\\library.zip"
} else {
    set path_sep ":"
    set env1 [file join $VW_TEST_ROOT ".." lib python wave_engine]
    set env2 [file join $VW_TEST_ROOT ".." lib python vcl]
    set env3 [file join $VW_TEST_ROOT ".." lib python]
    set env4 [file join $VW_TEST_ROOT ".." apps QoS]
    set env(PYTHONPATH) "$env1$path_sep$env2$path_sep$env3$path_sep$env4"
}


#
# ALL_SECURITY_METHODS is the list of all supported security methods.  Useful
# for when one doesn't want to type them in again and as a reference as to
# which methods are available.
#
set ALL_SECURITY_METHODS {
        None
        WEP-Open-40
        WEP-Open-128
        WEP-SharedKey-40
        WEP-SharedKey-128
        WPA-PSK
        WPA-EAP-TLS
        WPA-EAP-TTLS-GTC
        WPA-PEAP-MSCHAPV2
        WPA-EAP-FAST
        WPA2-PSK
        WPA2-EAP-TLS
        WPA2-EAP-TTLS-GTC
        WPA2-PEAP-MSCHAPV2
        WPA2-EAP-FAST
        DWEP-EAP-TLS
        DWEP-EAP-TTLS-GTC
        DWEP-PEAP-MSCHAPV2
        LEAP
        WPA-LEAP
        WPA2-LEAP
        WPA-PSK-AES
        WPA-PEAP-MSCHAPV2-AES
        WPA2-PEAP-MSCHAPV2-TKIP
        WPA2-EAP-TLS-TKIP
        WPA2-PSK-TKIP
        WPA-CCKM-PEAP-MSCHAPv2-TKIP
        WPA-CCKM-PEAP-MSCHAPv2-AES-CCMP
        WPA2-CCKM-PEAP-MSCHAPv2-TKIP
        WPA2-CCKM-PEAP-MSCHAPv2-AES-CCMP
        WPA-CCKM-TLS-TKIP
        WPA-CCKM-TLS-AES-CCMP
        WPA2-CCKM-TLS-TKIP
        WPA2-CCKM-TLS-AES-CCMP
        WPA-CCKM-LEAP-TKIP
        WPA-CCKM-LEAP-AES-CCMP
        WPA2-CCKM-LEAP-TKIP
        WPA2-CCKM-LEAP-AES-CCMP
        WPA-CCKM-FAST-TKIP
        WPA-CCKM-FAST-AES-CCMP
        WPA2-CCKM-FAST-TKIP
        WPA2-CCKM-FAST-AES-CCMP
}

