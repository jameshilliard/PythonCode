# ATC 009 Mixed_80211n-and-Legacy_Association
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

keylset global_config LogsDir [file join $LogsDirRoot FunctionalVerification Association ATC009]

keylset ether_group_1 NumClients 2

keylset global_config Direction { Unidirectional }
# Need to make sure the n-client group is last so the AP is configured to support N
# plus g
keylset global_config Source { wireless_group_g wireless_group_n}
keylset global_config Destination { ether_group_1 }


#keylset wireless_group_n DataMcsIndex { 15}


#set Channel {1 }
#set AssocProbe {Broadcast Unicast}
keylset wireless_group_n Channel $Channel
keylset wireless_group_g Channel $Channel
# need to make sure each client group is talking to the same SSID
keylset wireless_group_g Ssid "veriwave_n"

keylset wireless_group_n AssocProbe  $AssocProbe
keylset wireless_group_g AssocProbe  $AssocProbe
keylset wireless_group_n ChannelModel {Bypass}

