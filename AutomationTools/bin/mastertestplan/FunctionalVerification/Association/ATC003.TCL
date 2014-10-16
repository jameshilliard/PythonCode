# ATC 003 Basic_80211b-only-mode_Association
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
keylset global_config LogsDir [file join $LogsDirRoot FunctionalVerification Association ATC003]

keylset global_config Direction { Unidirectional }
keylset global_config Source { wireless_group_b }
keylset global_config Destination { ether_group_1 }
keylset global_config DataPhyRate 11
keylset global_config MgmtPhyRate 2

keylset wireless_group_b Channel $Channel
keylset wireless_group_b AssocProbe    $AssocProbe
keylset wireless_group_b DataPhyRate 11
keylset wireless_group_b MgmtPhyRate 1
