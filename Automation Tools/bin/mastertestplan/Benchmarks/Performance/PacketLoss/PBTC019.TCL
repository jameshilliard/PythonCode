# PBTC 019 Upstream_80211g_Packet_loss
keylset global_config TestCaseName "PBTC019"
keylset global_config TestDescription "Upstream_80211g_Packet_loss"

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

set src_path [file join $env(VW_MTP_HOME) Benchmarks Performance PacketLoss packetloss.tcl]
if {[catch {source $src_path} result]} {
    puts "Opening of $src_path failed: $result"
    exit -1
}


keylset global_config LogsDir [file join $LogsDirRoot Benchmarks Performance PacketLoss PBTC019]
keylset global_config Direction { Unidirectional }
keylset global_config Source { wireless_group_g }
keylset global_config Destination { ether_group_1 }
