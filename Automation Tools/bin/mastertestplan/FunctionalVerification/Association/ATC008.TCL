# ATC 008 Basic_80211n-mode_Association
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

set src_path [file join $env(VW_MTP_HOME) FunctionalVerification Association association_setup.tcl]
if {[catch {source $src_path} result]} {
    puts "Opening of $src_path failed: $result"
    exit -1
}

keylset global_config LogsDir [file join $LogsDirRoot FunctionalVerification Association ATC008]


keylset global_config Direction { Unidirectional }
keylset global_config Source { wireless_group_n }
keylset global_config Destination { ether_group_1 }

#set Channel {1 36}
#set AssocProbe {Broadcast Unicast}
keylset wireless_group_n Channel $Channel
keylset wireless_group_n AssocProbe  $AssocProbe

keylset wireless_group_n ChannelModel {Bypass}

