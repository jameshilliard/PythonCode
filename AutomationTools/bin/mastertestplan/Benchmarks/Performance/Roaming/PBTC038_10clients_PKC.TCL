##This is Roaming Test for 802.11a clients TestNo -> PBTC-038, 10 clients (Proactive Key Caching enabled)

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
keylset global_config LogsDir [file join $LogsDirRoot Benchmarks Performance Roaming PBTC038_10clients_PKC ]

keylset global_config Direction { Unidirectional }
keylset global_config Source { ether_group_1 }
keylset global_config Destination { wireless_group_a }


keylset wireless_group_a Method $RoamingSecurityTypes


keylset wireless_group_a preauth 0
keylset wireless_group_a pmkid 0
keylset wireless_group_a ProactiveKeyCaching True

#roamRate = 0.5, 1, 4 roams/sec 
keylset wireless_group_a dwellTime {20 10 2.5}
keylset wireless_group_a dwellTime {20 }
keylset wireless_group_a NumClients 10
# run the test for 300 seconds
keylset wireless_group_a repeatValue 300

