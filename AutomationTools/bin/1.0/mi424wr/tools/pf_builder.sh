#!/bin/sh
bin=/home/aedorn/automation/bin/1.0/mi424wr
xml=/home/aedorn/automation/platform/1.0/verizon2/testcases/manual_test_plan/tcases
json=/home/aedorn/automation/platform/1.0/verizon2/testcases/manual_test_plan/json

# Initial setup
ruby $bin/xmlbuild.rb -j $json -o $xml/tc_30.xml -d "Port Forwarding - Set router to the current time" -e "PF - initial setup" -t "Port Forwarding - Initial Setup" tc_changetime_current

# Case 1
ruby $bin/xmlbuild.rb -j $json -o $xml/tc_31.xml -d "Port Forwarding - Forward ports, and run nmap/iperf tests for PC1. Firewall level - Typical. Default settings." -e "PF - Case 13: PC1 testing" -t "Port Forwarding - Port scan and Iperf tests: PC1" tc_all_firewall_typical tc_pf_pc1 tc_pf_pc1_test tc_pf_pc1_iperftest tc_all_enable_telnet getconfig tc_all_disable_telnet tc_pf_remove_rules
ruby $bin/xmlbuild.rb -j $json -o $xml/tc_32.xml -d "Port Forwarding - Forward ports, and run nmap/iperf tests for PC2. Firewall level - Typical. Default settings." -e "PF - Case 13: PC2 testing" -t "Port Forwarding - Port scan and Iperf tests: PC2" tc_all_firewall_typical tc_pf_pc2 tc_pf_pc2_test tc_pf_pc2_iperftest tc_all_enable_telnet getconfig tc_all_disable_telnet tc_pf_remove_rules

ruby $bin/xmlbuild.rb -j $json -o $xml/tc_33.xml -d "Port Forwarding - Forward ports, and run nmap/iperf tests for PC1. Firewall level - Minimum. Default settings." -e "PF - Case 14: PC1 testing" -t "Port Forwarding - Port scan and Iperf tests: PC1" tc_all_firewall_low tc_pf_pc1 tc_pf_pc1_test tc_pf_pc1_iperftest tc_all_enable_telnet getconfig tc_all_disable_telnet tc_pf_remove_rules
ruby $bin/xmlbuild.rb -j $json -o $xml/tc_34.xml -d "Port Forwarding - Forward ports, and run nmap/iperf tests for PC2. Firewall level - Minimum. Default settings." -e "PF - Case 14: PC2 testing" -t "Port Forwarding - Port scan and Iperf tests: PC2" tc_all_firewall_low tc_pf_pc2 tc_pf_pc2_test tc_pf_pc2_iperftest tc_all_enable_telnet getconfig tc_all_disable_telnet tc_pf_remove_rules

ruby $bin/xmlbuild.rb -j $json -o $xml/tc_35.xml -d "Port Forwarding - Forward ports, and run nmap/iperf tests for PC1. Firewall level - Maximum. Default settings." -e "PF - Case 15: PC1 testing" -t "Port Forwarding - Port scan and Iperf tests: PC1" tc_all_firewall_high tc_pf_pc1 tc_pf_pc1_test tc_pf_pc1_iperftest tc_all_enable_telnet getconfig tc_all_disable_telnet tc_pf_remove_rules
ruby $bin/xmlbuild.rb -j $json -o $xml/tc_36.xml -d "Port Forwarding - Forward ports, and run nmap/iperf tests for PC2. Firewall level - Maximum. Default settings." -e "PF - Case 15: PC2 testing" -t "Port Forwarding - Port scan and Iperf tests: PC2" tc_all_firewall_high tc_pf_pc2 tc_pf_pc2_test tc_pf_pc2_iperftest tc_all_enable_telnet getconfig tc_all_disable_telnet tc_pf_remove_rules