# PBTC059_2 Upstream_80211g_VoIP_Service Assurance


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

set src_path [file join $env(VW_MTP_HOME) Benchmarks Performance QoS VoIPSLA.tcl]
if {[catch {source $src_path} result]} {
    puts "Opening of $src_path failed: $result"
    exit -1
}

keylset global_config LogsDir [file join $LogsDirRoot Benchmarks Performance QoS PBTC059_2]



#keylset wireless_group_g NumClients { 1 10 50 }
#keylset ether_group_1 NumClients { 1 10 50 }

keylset wireless_group_g Dhcp     Enable
keylset wireless_backgrnd_g Dhcp  Enable
keylset ether_group_1 Dhcp        Enable
keylset ether_backgrnd Dhcp       Enable

keylset wireless_group_g Channel $Channel

keylset global_config Direction { Unidirectional }
keylset global_config Source { wireless_group_g wireless_backgrnd_g }
keylset global_config Destination { ether_group_1 ether_backgrnd }








