#!/bin/sh
bin=/home/aedorn/automation/bin/1.0/mi424wr
xml=/home/aedorn/automation/platform/1.0/verizon2/testcases/manual_test_plan/tcases
json=/home/aedorn/automation/platform/1.0/verizon2/testcases/manual_test_plan/json

# Initial setup
ruby $bin/xmlbuild.rb -o $xml/tc_37.xml -d "Firewall Port Scanning" -e "FW - Firewall at Maximum" -t "Firewall - Port scanning" tc_all_firewall_high tc_firewall_max_port_test tc_all_enable_telnet getconfig tc_all_disable_telnet
ruby $bin/xmlbuild.rb -o $xml/tc_38.xml -d "Firewall Port Scanning" -e "FW - Firewall at Typical" -t "Firewall - Port scanning" tc_all_firewall_typical tc_firewall_med_port_test tc_all_enable_telnet getconfig tc_all_disable_telnet
ruby $bin/xmlbuild.rb -o $xml/tc_39.xml -d "Firewall Port Scanning" -e "FW - Firewall at Minimum" -t "Firewall - Port scanning" tc_all_firewall_low tc_firewall_min_port_test tc_all_enable_telnet getconfig tc_all_disable_telnet

