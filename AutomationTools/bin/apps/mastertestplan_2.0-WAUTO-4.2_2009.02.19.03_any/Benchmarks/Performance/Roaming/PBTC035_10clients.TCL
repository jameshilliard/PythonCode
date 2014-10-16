##This is Roaming Test for 802.11g clients TestNo -> PBTC-035, 10 clients

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
keylset global_config LogsDir [file join $LogsDirRoot Benchmarks Performance Roaming PBTC035_2]

keylset global_config Direction { Unidirectional }
keylset global_config Source { ether_group_1 }
keylset global_config Destination { wireless_group_g }

keylset wireless_group_g Dhcp Enable
keylset ether_group_1 Dhcp Enable

#roamRate = .5, 1, 4 roams/sec
keylset wireless_group_g dwellTime { 20 10 2.5}
keylset wireless_group_g NumClients 10
keylset wireless_group_g repeatValue 300

