# ATC 004 Basic_80211g-only-mode_Association
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
keylset global_config LogsDir [file join $LogsDirRoot FunctionalVerification Association ATC004]

keylset global_config Direction { Unidirectional }
keylset global_config Source { wireless_group_g }
keylset global_config Destination { ether_group_1 }
keylset global_config DataPhyRate 54
keylset global_config MgmtPhyRate 24

keylset wireless_group_g Channel $Channel
keylset wireless_group_g AssocProbe    $AssocProbe
