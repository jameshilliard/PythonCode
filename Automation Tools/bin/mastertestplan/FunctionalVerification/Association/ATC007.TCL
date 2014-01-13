# ATC 007 Mixed_80211bg-mode_Association
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

keylset global_config LogsDir [file join $LogsDirRoot FunctionalVerification Association ATC007]


keylset global_config Direction { Unidirectional }
keylset global_config Source { wireless_group_b wireless_group_g }
keylset global_config Destination { ether_group_1 ether_group_2}

keylset wireless_group_b Channel $Channel
keylset wireless_group_g Channel $Channel
keylset wireless_group_b AssocProbe    $AssocProbe
keylset wireless_group_g AssocProbe    $AssocProbe

#Make both wireless groups talk to the same ssid
keylset wireless_group_b Ssid "veriwave_bg"
keylset wireless_group_g Ssid "veriwave_bg"

keylset wireless_group_b DataPhyRate 11
keylset wireless_group_b MgmtPhyRate 1
