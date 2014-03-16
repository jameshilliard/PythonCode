#BOTC 005 80211n_AMPDU_Aggregate_Transmit

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

keylset global_config LogsDir [file join $LogsDirRoot FunctionalVerification 11nBasic BOTC005_3]


keylset global_config Direction { Unidirectional }
keylset global_config FrameSizeList {64}

keylset wireless_group_n NumClients {1 10 }
keylset wireless_group_n Channel {11}

keylset global_config Source { ether_group_1   }
keylset global_config Destination { wireless_group_n }

keylset unicast_packet_loss ILoadList { 83000 }

keylset wireless_group_n EnableAMPDUaggregation True
keylset wireless_group_n DataMcsIndex   {  15 }


keylset wireless_group_n AssocProbe {Unicast Broadcast}


keylset wireless_group_n GuardInterval  {  standard }
#keylset wireless_group_n2 GuardInterval  {  short }

keylset wireless_group_n ChannelBandwidth  {40 }
keylset wireless_group_n ChannelModel {Bypass A B C D E F}
