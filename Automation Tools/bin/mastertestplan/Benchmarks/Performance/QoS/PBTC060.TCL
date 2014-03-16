##This is VOIP Roaming Test for 802.11g clients TestNo -> PBTC-060


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

keylset global_config LogsDir [file join $LogsDirRoot Benchmarks Performance QoS PBTC060]



#Test Configuration of VoIP Roaming Test

keylset global_config Direction { Unidirectional }
keylset global_config Source { ether_group_1 }
keylset global_config Destination { wireless_group_g }

keylset wireless_group_g Method $RoamingSecurityTypes
keylset wireless_group_g NumClients { 10 }
keylset qos_roam_quality qosRoamRoamRate { 0.5  1.0  5.0 }
