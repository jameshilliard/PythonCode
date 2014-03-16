##This is Roaming Test for 802.11a clients TestNo -> PBTC-061

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

keylset global_config LogsDir [file join $LogsDirRoot Benchmarks Performance QoS PBTC061]

#Test Configuration of VOIP Roaming Test

keylset global_config Direction { Unidirectional }
keylset global_config Source { ether_group_1 }
keylset global_config Destination { wireless_group_a }

keylset wireless_group_a Method $RoamingSecurityTypes

keylset wireless_group_a NumClients { 10 }
keylset qos_roam_quality qosRoamRoamRate { 0.5 1 5 }
