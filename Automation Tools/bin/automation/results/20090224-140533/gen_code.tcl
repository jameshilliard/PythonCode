set ::configurator::loop_level 0
set ::test_case_number 0
set dut_aborts 0
set test_skips 0
set test_aborts 0
set test_pf_fails 0
set test_pass 0
set test_fails 0
set ::summary_line [format "%-20s " [string range unicast_packet_loss 0 19]]
set benchmark unicast_packet_loss
set current_benchmark_name unicast_packet_loss
set current_benchmark_type wml

set log_dir [file join $initial_log_dir $benchmark]
set ::configurator::cfg_0 {}
keylset ::configurator::cfg_0 ChassisName "192.168.10.99"
keylset ::configurator::cfg_0 Source "wireless_group"
keylset ::configurator::cfg_0 Destination "ether_group"
keylset ::configurator::cfg_0 Direction "Unidirectional"
keylset ::configurator::cfg_0 Frame "Standard"
keylset ::configurator::cfg_0 FrameSizeList "1023"
keylset ::configurator::cfg_0 ILoadList "128.0"
keylset ::configurator::cfg_0 ILoadMode "Custom"
keylset ::configurator::cfg_0 ChassisName "192.168.10.99"
keylset ::configurator::cfg_0 Source "wireless_group"
keylset ::configurator::cfg_0 Destination "ether_group"
keylset ::configurator::cfg_0 Direction "Unidirectional"
keylset ::configurator::cfg_0 LogsDir "/home/autolab1/vwautomate/automation/bin/./../results"
keylset ::configurator::cfg_0 NumTrials "1"
keylset ::configurator::cfg_0 TrialDuration "10"
keylset ::configurator::cfg_0 LogsDir "/home/autolab1/vwautomate/automation/bin/./../results"
keylset ::configurator::cfg_0 NumTrials "1"
keylset ::configurator::cfg_0 TrialDuration "10"
keylset ::configurator::cfg_0 AcceptableFrameLossRate "5"
set grp_wireless_group {}
set grp_ether_group {}
keylset ::configurator::cfg_0 AnonymousIdentity "anonymous"
keylset grp_wireless_group AnonymousIdentity "anonymous"
debug 9 "setting wireless_group->AnonymousIdentity to anonymous"
keylset ::configurator::cfg_0 BaseIp "192.168.10.220"
keylset grp_wireless_group BaseIp "192.168.10.220"
debug 9 "setting wireless_group->BaseIp to 192.168.10.220"
keylset grp_wireless_group Channel "6"
debug 9 "setting wireless_group->Channel to 6"
keylset ::configurator::cfg_0 Dhcp "Enable"
keylset grp_wireless_group Dhcp "Enable"
debug 9 "setting wireless_group->Dhcp to Enable"
keylset ::configurator::cfg_0 EnableValidateCertificate "off"
keylset grp_wireless_group EnableValidateCertificate "off"
debug 9 "setting wireless_group->EnableValidateCertificate to off"
keylset ::configurator::cfg_0 Gateway "192.168.10.1"
keylset grp_wireless_group Gateway "192.168.10.1"
debug 9 "setting wireless_group->Gateway to 192.168.10.1"
keylset ::configurator::cfg_0 Identity "anonymous"
keylset grp_wireless_group Identity "anonymous"
debug 9 "setting wireless_group->Identity to anonymous"
keylset ::configurator::cfg_0 IncrIp "0.0.0.1"
keylset grp_wireless_group IncrIp "0.0.0.1"
debug 9 "setting wireless_group->IncrIp to 0.0.0.1"
keylset ::configurator::cfg_0 Method "None"
keylset grp_wireless_group Method "None"
debug 9 "setting wireless_group->Method to None"
keylset ::configurator::cfg_0 NumClients "1"
keylset grp_wireless_group NumClients "1"
debug 9 "setting wireless_group->NumClients to 1"
keylset ::configurator::cfg_0 Password "whatever"
keylset grp_wireless_group Password "whatever"
debug 9 "setting wireless_group->Password to whatever"
keylset ::configurator::cfg_0 Ssid "verizon"
keylset grp_wireless_group Ssid "verizon"
debug 9 "setting wireless_group->Ssid to verizon"
keylset ::configurator::cfg_0 SubnetMask "255.255.255.0"
keylset grp_wireless_group SubnetMask "255.255.255.0"
debug 9 "setting wireless_group->SubnetMask to 255.255.255.0"
keylset ::configurator::cfg_0 GroupType "802.11abg"
keylset grp_wireless_group GroupType "802.11abg"
debug 9 "setting wireless_group->GroupType to 802.11abg"
keylset ::configurator::cfg_0 Dut "sample-generic-ap"
keylset grp_wireless_group Dut "sample-generic-ap"
debug 9 "setting wireless_group->Dut to sample-generic-ap"
keylset ::configurator::cfg_0 AuxDut "sample-generic-ap2"
keylset grp_wireless_group AuxDut "sample-generic-ap2"
debug 9 "setting wireless_group->AuxDut to sample-generic-ap2"
keylset ::configurator::cfg_0 WepKey40Hex "CAFEBABE01"
keylset grp_wireless_group WepKey40Hex "CAFEBABE01"
debug 9 "setting wireless_group->WepKey40Hex to CAFEBABE01"
keylset ::configurator::cfg_0 WepKey128Hex "BADC0FFEE123456789CAFEFEED"
keylset grp_wireless_group WepKey128Hex "BADC0FFEE123456789CAFEFEED"
debug 9 "setting wireless_group->WepKey128Hex to BADC0FFEE123456789CAFEFEED"
keylset ::configurator::cfg_0 PskAscii "whatever"
keylset grp_wireless_group PskAscii "whatever"
debug 9 "setting wireless_group->PskAscii to whatever"
keylset ::configurator::cfg_0 BssidIndex "4"
keylset grp_wireless_group BssidIndex "4"
debug 9 "setting wireless_group->BssidIndex to 4"
keylset ::configurator::cfg_0 BaseIp "192.168.10.230"
keylset grp_ether_group BaseIp "192.168.10.230"
debug 9 "setting ether_group->BaseIp to 192.168.10.230"
keylset ::configurator::cfg_0 Dhcp "Enable"
keylset grp_ether_group Dhcp "Enable"
debug 9 "setting ether_group->Dhcp to Enable"
keylset ::configurator::cfg_0 Gateway "192.168.10.1"
keylset grp_ether_group Gateway "192.168.10.1"
debug 9 "setting ether_group->Gateway to 192.168.10.1"
keylset ::configurator::cfg_0 IncrIp "0.0.0.1"
keylset grp_ether_group IncrIp "0.0.0.1"
debug 9 "setting ether_group->IncrIp to 0.0.0.1"
keylset ::configurator::cfg_0 NumClients "1"
keylset grp_ether_group NumClients "1"
debug 9 "setting ether_group->NumClients to 1"
keylset ::configurator::cfg_0 SubnetMask "255.255.255.0"
keylset grp_ether_group SubnetMask "255.255.255.0"
debug 9 "setting ether_group->SubnetMask to 255.255.255.0"
keylset ::configurator::cfg_0 GroupType "802.3"
keylset grp_ether_group GroupType "802.3"
debug 9 "setting ether_group->GroupType to 802.3"
keylset ::configurator::cfg_0 Dut "sample-generic-ap"
keylset grp_ether_group Dut "sample-generic-ap"
debug 9 "setting ether_group->Dut to sample-generic-ap"

keylset ::configurator::cfg_0 LogsDir "$log_dir"
if {$::current_benchmark_type == "wml" } {
 set cli_args [::configurator::vwConfig_global_args ::configurator::cfg_0]
} elseif {$::current_benchmark_type == "external"} {
 set cli_args [::configurator::external_args ::configurator::cfg_0 ]
} else {
 puts "Error: Unknown vwTestType for $::current_benchmark_name($::current_benchmark_test)"
 exit -1
}
if {$::current_benchmark_type == "wml" } {
 foreach group {wireless_group ether_group} {
  set cli_args [::configurator::vwConfig_group_args grp_$group $cli_args ::configurator::cfg_0]
 }
}
incr ::test_case_number
if {[catch {file mkdir $log_dir} result]} {
 puts "Error: Cannot mkdir $log_dir : $result"
 exit -1
}

puts ""
puts "###"
set time_stamp [clock format [clock seconds] -format "%Y%m%d-%H%M%S"]
puts "### BEGIN testcase $::test_case_number at $time_stamp:"
puts ""

set rc 0
puts "### BEGIN DUT configuration for testcase $::test_case_number"
set ::configurator::configured_duts {}
puts "### Configuring DUT for group wireless_group testcase $::test_case_number"
incr rc [::configurator::configure_dut grp_wireless_group 0 ]
puts "### Configuring DUT for group ether_group testcase $::test_case_number"
incr rc [::configurator::configure_dut grp_ether_group 0 ]
puts "### END DUT configuration for testcase $::test_case_number rc = $rc"
set cfg [::configurator::build_test_config grp_wireless_group 0 sample-generic-ap ]
incr rc [::configurator::run_hook $cfg "PreGroupHook" ]
set cfg [::configurator::build_test_config grp_ether_group 0 sample-generic-ap ]
incr rc [::configurator::run_hook $cfg "PreGroupHook" ]
# the PreTestHook will get the config from the last configured DUT
incr rc [::configurator::run_hook $cfg "PreTestHook" ]
if { $rc == 0 } {
  debug $::DBLVL_INFO "Pausing 15 seconds for DUT radio interfaces to initialize"
  breakable_after 15

puts "### BEGIN run of testcase $::test_case_number"
if {$::current_benchmark_type == "wml" } {
 puts "### Building WML file for testcase $::test_case_number"
 set rc [::configurator::run_wml_test $cli_args]
} elseif {$::current_benchmark_type == "external"} {
 set rc [::configurator::run_external_test $cli_args]
} else {
 puts "Error: Unknown vwTestType for $::current_benchmark_name($::current_benchmark_test)"
 exit -1
}
set cfg [::configurator::build_test_config grp_wireless_group 0 sample-generic-ap ]
incr rc [::configurator::run_hook $cfg "PostDUTHook" ]
set cfg [::configurator::build_test_config grp_ether_group 0 sample-generic-ap ]
incr rc [::configurator::run_hook $cfg "PostDUTHook" ]
# the PostTestHook will get the config from the last configured DUT
incr rc [::configurator::run_hook $::configurator::test_config "PostTestHook" ]
puts "### END run of testcase $::test_case_number"

 set time_stamp [clock format [clock seconds] -format "%Y%m%d-%H%M%S"]

 puts "### END Testcase $::test_case_number"
if { $dut_aborts > 0 } {
 puts "### Testcase $::test_case_number Error: DUT/AP configuration Error at $time_stamp."
 set result "SKIP"
 incr test_skips
} elseif {$rc == 0} {
 puts "### Testcase $::test_case_number Passed at $time_stamp."
 set result "PASS"
 incr test_pass
} elseif {$rc >0 && $rc<=2 } {
 puts "### Testcase $::test_case_number Aborted at $time_stamp."
 set result "ABORT"
 incr test_aborts
} elseif {$rc == 3} {
 puts "### Testcase $::test_case_number PF criteria Failed at $time_stamp."
 set result "PF:FAIL"
 incr test_pf_fails
} else {
 puts "### Testcase $::test_case_number Failed at $time_stamp."
 set result "FAIL"
 incr test_fails
}
 puts "### Intermediate Results: PASS: $test_pass FAIL: $test_fails ABORT: $test_aborts Skipped: $test_skips  "
append ::summary [format "%-6s %s\n" $result $::summary_line]
}


