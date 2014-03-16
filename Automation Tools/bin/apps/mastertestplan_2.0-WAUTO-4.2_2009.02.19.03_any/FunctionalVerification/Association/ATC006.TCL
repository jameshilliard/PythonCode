# ATC 005 Mixed_80211ab-mode_Association

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

keylset global_config LogsDir [file join $LogsDirRoot FunctionalVerification Association ATC006]


keylset global_config Direction { Unidirectional }
keylset global_config Source { wireless_group_b wireless_group_a }
keylset global_config Destination { ether_group_1 ether_group_2}

keylset wireless_group_b Channel $Channel
keylset wireless_group_a Channel $A_Channel
keylset wireless_group_b AssocProbe    $AssocProbe
keylset wireless_group_a AssocProbe    $AssocProbe
