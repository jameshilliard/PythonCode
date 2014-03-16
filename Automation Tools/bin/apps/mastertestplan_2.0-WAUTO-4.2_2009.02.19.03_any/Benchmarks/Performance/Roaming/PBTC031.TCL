##This is Roaming Test for 802.11g clients TestNo -> PBTC-031


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

set src_path [file join $env(VW_MTP_HOME) Benchmarks Performance Roaming Roaming.tcl]
if {[catch {source $src_path} result]} {
    puts "Opening of $src_path failed: $result"
    exit -1
}
#Test Configuration of Roaming Test

keylset global_config LogsDir [file join $LogsDirRoot Benchmarks Performance Roaming PBTC031_1]

keylset global_config Direction { Unidirectional }
keylset global_config Source { ether_group_1 }
keylset global_config Destination { wireless_group_g }


#roamRate = 0.1
keylset wireless_group_g dwellTime 10
keylset wireless_group_g NumClients 1
# run the test for 600 seconds. 
keylset wireless_group_b repeatValue 600

