##This is Roaming Test for 802.11g clients TestNo -> PBTC-037, 50 clients (PMKID Caching enabled)

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
keylset global_config LogsDir [file join $LogsDirRoot Benchmarks Performance Roaming PBTC037_50clients_PMKID ]

keylset global_config Direction { Unidirectional }
keylset global_config Source { ether_group_1 }
keylset global_config Destination { wireless_group_g }


keylset wireless_group_g Method $RoamingSecurityTypes

keylset wireless_group_g preauth 0
keylset wireless_group_g pmkid 1
keylset wireless_group_g ProactiveKeyCaching False

#roamRate = 0.5, 1, 4 roams/sec 
keylset wireless_group_g dwellTime {100 50 12.5 }
keylset wireless_group_g NumClients 50
# run the test for 300 seconds
keylset wireless_group_g repeatValue 300

