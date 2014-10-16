#BOTC 002 80211n_Mixed_Spatial-Stream_Operation

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

set src_path [file join $env(VW_MTP_HOME) FunctionalVerification 11nBasic 11nbasic.tcl]
if {[catch {source $src_path} result]} {
    puts "Opening of $src_path failed: $result"
    exit -1
}


keylset global_config LogsDir [file join $LogsDirRoot FunctionalVerification 11nBasic  BOTC002_4]

keylset unicast_packet_loss ILoadList { 100}

#According to procedure
keylset unicast_packet_loss ILoadList { 300}

keylset global_config Direction { Unidirectional }

keylset wireless_group_n GuardInterval  {  standard }
keylset wireless_group_n ChannelBandwidth  {20 }
keylset wireless_group_n ChannelModel {Bypass }


set wireless_group_n2 $wireless_group_n

keylset wireless_group_n2 BaseIp {192.168.1.210}

keylset wireless_group_n NumClients {1 10 }
keylset wireless_group_n2 NumClients {1 10 }

keylset ether_group_1 NumClients {2}
keylset global_config Source { wireless_group_n  wireless_group_n2 }
keylset global_config Destination { ether_group_1  }


keylset wireless_group_n EnableAMPDUaggregation False
#keylset wireless_group_n DataMcsIndex   { 0 1  2  3  4  5  6  7 }
#keylset wireless_group_n2 DataMcsIndex  { 8 9 10 11 12 13 14 15 }
keylset wireless_group_n DataMcsIndex   { 3 }
keylset wireless_group_n2 DataMcsIndex  { 11 }
