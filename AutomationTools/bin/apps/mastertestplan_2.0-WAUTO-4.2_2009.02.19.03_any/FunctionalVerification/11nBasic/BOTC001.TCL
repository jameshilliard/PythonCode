#BOTC 001 80211n_Spatial-Stream_Operation

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
keylset global_config LogsDir [ file join $LogsDirRoot FunctionalVerification 11nBasic BOTC001]

keylset global_config Direction { Unidirectional }
keylset global_config Source { wireless_group_n}
keylset global_config Destination { ether_group_1 }

keylset wireless_group_n EnableAMPDUaggregation False
keylset wireless_group_n DataMcsIndex  { 7  15 }
keylset wireless_group_n GuardInterval  {standard short}
keylset wireless_group_n ChannelBandwidth  {20 40}
keylset wireless_group_n ChannelModel {Bypass A B C D E F}
