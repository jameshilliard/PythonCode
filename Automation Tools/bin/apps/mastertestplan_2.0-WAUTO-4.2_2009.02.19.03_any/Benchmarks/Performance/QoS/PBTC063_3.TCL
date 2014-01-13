##This is Roaming Test for 802.11a clients TestNo -> PBTC-063_1. ProactiveKeyCaching Disabled, pmkid caching Disabled and preauthentication Enabled.

if { ![info exists env(VW_MTP_HOME)] } {
    puts "Error: Environment variable VW_MTP_HOME not set.\n"
    exit -1
}
set src_path [file join $env(VW_MTP_HOME) global_configs.tcl]
if {[catch {source $src_path} result]} {
    puts "Opening of $src_path failed: $result"
    exit -1
}
set src_path [file join $env(VW_MTP_HOME) client_setup.tcl]
if {[catch {source $src_path} result]} {
    puts "Opening of $src_path failed: $result"
    exit -1
}

set src_path [file join $env(VW_MTP_HOME) Benchmarks Performance QoS VoIPRoaming.tcl]
if {[catch {source $src_path} result]} {
    puts "Opening of $src_path failed: $result"
    exit -1
}

keylset global_config LogsDir [file join $LogsDirRoot Benchmarks Performance QoS PBTC063_3]


#Test Configuration of VOIP Roaming Test

keylset global_config Direction { Unidirectional }
keylset global_config Source { ether_group_1 }
keylset global_config Destination { wireless_group_a }

keylset wireless_group_a ProactiveKeyCaching Disable

keylset wireless_group_a Method { WPA-PSK WPA2-PSK WPA-PEAP-MSCHAPv2 WPA2-PEAP-MSCHAPv2 WPA2-EAP-FAST }

keylset wireless_group_a NumClients { 10 50 100 }
keylset qos_roam_quality qosRoamRoamRate { 0.5 1 5 }

keylset qos_roam_quality pmkid 0
keylset qos_roam_quality preauth 1

