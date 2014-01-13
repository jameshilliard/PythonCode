#Group Handset
keylset global_config Channel {36}

keylset Handset GroupType 802.11abg
keylset Handset Dut dut1

#Group Handset - Client Options
keylset Handset GratuitousArp True
keylset Handset Dhcp Enable
keylset Handset Ssid veriwave_a
keylset Handset Qos Disable
keylset Handset Uapsd 0
keylset Handset ListenInt 1
keylset Handset phyInterface 802.11a
keylset Handset Wlan80211eQoSAC 0
keylset Handset SubnetMask 255.255.0.0
keylset Handset BaseIp 192.168.3.10
keylset Handset Gateway 192.168.1.1
keylset Handset MacAddress None

#Group Handset - Security Options
keylset Handset Method {None}

#Group Laptop
keylset Laptop GroupType 802.11abg
keylset Laptop Dut dut1

#Group Laptop - Client Options
keylset Laptop GratuitousArp True
keylset Laptop Dhcp Enable
keylset Laptop Ssid veriwave_a
keylset Laptop Hops -1
keylset Laptop Qos Disable
keylset Laptop Uapsd 0
keylset Laptop ListenInt 1
keylset Laptop phyInterface 802.11a
keylset Laptop VlanEnable True
keylset Laptop Wlan80211eQoSAC 0
keylset Laptop SubnetMask 255.255.0.0
keylset Laptop BaseIp 192.168.1.10
keylset Laptop Gateway 192.168.1.1
keylset Laptop MacAddress None

#Group Laptop - Security Options
keylset Laptop Method {None}

#Group PDA
keylset PDA GroupType 802.11abg
keylset PDA Dut dut1

#Group PDA - Client Options
keylset PDA GratuitousArp True
keylset PDA Dhcp Enable
keylset PDA Ssid veriwave_a
keylset PDA Hops 0
keylset PDA Qos Disable
keylset PDA Uapsd 0
keylset PDA ListenInt 1
keylset PDA phyInterface 802.11a
keylset PDA Wlan80211eQoSAC 0
keylset PDA SubnetMask 255.255.0.0
keylset PDA BaseIp 192.168.2.10
keylset PDA Gateway 192.168.1.1
keylset PDA MacAddress None

#Group PDA - Security Options
keylset PDA Method {None}

#Group VideoCamera
keylset VideoCamera GroupType 802.11abg
keylset VideoCamera Dut dut1

#Group VideoCamera - Client Options
keylset VideoCamera GratuitousArp True
keylset VideoCamera Dhcp Enable
keylset VideoCamera Ssid veriwave_a
keylset VideoCamera Hops 0
keylset VideoCamera Qos Disable
keylset VideoCamera Uapsd 0
keylset VideoCamera ListenInt 1
keylset VideoCamera phyInterface 802.11a
keylset VideoCamera Wlan80211eQoSAC 0
keylset VideoCamera SubnetMask 255.255.0.0
keylset VideoCamera BaseIp 192.168.2.10
keylset VideoCamera Gateway 192.168.1.1
keylset VideoCamera MacAddress None

#Group VideoCamera - Security Options
keylset VideoCamera Method {None}

#Specific To HealthCare
#Group PatientMonitor
keylset PatientMonitor GroupType 802.11abg
keylset PatientMonitor Dut dut1

#Group PatientMonitor - Client Options
keylset PatientMonitor GratuitousArp True
keylset PatientMonitor Dhcp Enable
keylset PatientMonitor Ssid veriwave_a
keylset PatientMonitor Qos Disable
keylset PatientMonitor Uapsd 0
keylset PatientMonitor ListenInt 1
keylset PatientMonitor phyInterface 802.11a
keylset PatientMonitor Wlan80211eQoSAC 0
keylset PatientMonitor SubnetMask 255.255.0.0
keylset PatientMonitor BaseIp 192.168.4.10
keylset PatientMonitor Gateway 192.168.1.1
keylset PatientMonitor MacAddress None

#Group PatientMonitor - Security Options
keylset PatientMonitor Method {None}


#Specific to Retail
#Group POSTerminal
keylset POSTerminal GroupType 802.11abg
keylset POSTerminal Dut dut1

#Group POSTerminal - Client Options
keylset POSTerminal GratuitousArp True
keylset POSTerminal Dhcp Enable
keylset POSTerminal Ssid veriwave_a
keylset POSTerminal Qos Disable
keylset POSTerminal Uapsd 0
keylset POSTerminal ListenInt 1
keylset POSTerminal phyInterface 802.11a
keylset POSTerminal Wlan80211eQoSAC 0
keylset POSTerminal SubnetMask 255.255.0.0
keylset POSTerminal BaseIp 192.168.4.10
keylset POSTerminal Gateway 192.168.1.1
keylset POSTerminal MacAddress None

#Group POSTerminal - Security Options
keylset POSTerminal Method {None}

#Specific to Retail
#Group Scanner
keylset Scanner GroupType 802.11abg
keylset Scanner Dut dut1

#Group Scanner - Client Options
keylset Scanner GratuitousArp True
keylset Scanner Dhcp Enable
keylset Scanner Ssid veriwave_a
keylset Scanner Hops 2
keylset Scanner Qos Disable
keylset Scanner Uapsd 0
keylset Scanner ListenInt 1
keylset Scanner phyInterface 802.11a
keylset Scanner Wlan80211eQoSAC 0
keylset Scanner SubnetMask 255.255.0.0
keylset Scanner BaseIp 192.168.5.10
keylset Scanner Gateway 192.168.1.1
keylset Scanner MacAddress None

#Group Scanner - Security Options
keylset Scanner Method {None}

#Group HomeLaptop
keylset HomeLaptop GroupType 802.11abg
keylset HomeLaptop Dut dut1

#Group HomeLaptop - Client Options
keylset HomeLaptop GratuitousArp True
keylset HomeLaptop Dhcp Enable
keylset HomeLaptop Ssid veriwave_a
keylset HomeLaptop Qos Disable
keylset HomeLaptop Uapsd 0
keylset HomeLaptop ListenInt 1
keylset HomeLaptop phyInterface 802.11a
keylset HomeLaptop Wlan80211eQoSAC 0
keylset HomeLaptop BaseIp 192.168.1.12
keylset HomeLaptop Gateway 192.168.1.1
keylset HomeLaptop MacAddress None

#Group HomeLaptop - Security Options
keylset HomeLaptop Method {None}


#Group WirelessTv
keylset WirelessTv GroupType 802.11abg
keylset WirelessTv Dut dut1

#Group WirelessTv - Client Options
keylset WirelessTv GratuitousArp True
keylset WirelessTv Dhcp Enable
keylset WirelessTv Ssid veriwave_a
keylset WirelessTv Hops 2
keylset WirelessTv Qos Disable
keylset WirelessTv Uapsd 0
keylset WirelessTv ListenInt 1
keylset WirelessTv phyInterface 802.11a
keylset WirelessTv Wlan80211eQoSAC 0
keylset WirelessTv BaseIp 192.168.1.13
keylset WirelessTv Gateway 192.168.1.1
keylset WirelessTv MacAddress None

#Group WirelessTv - Security Options
keylset WirelessTv Method {None}

#Group WorkLaptop
keylset WorkLaptop GroupType 802.11abg
keylset WorkLaptop Dut dut1

#Group WorkLaptop - Client Options
keylset WorkLaptop GratuitousArp True
keylset WorkLaptop Dhcp Enable
keylset WorkLaptop Ssid veriwave_a
keylset WorkLaptop Hops -1
keylset WorkLaptop Qos Disable
keylset WorkLaptop Uapsd 0
keylset WorkLaptop ListenInt 1
keylset WorkLaptop phyInterface 802.11a
keylset WorkLaptop Wlan80211eQoSAC 0
keylset WorkLaptop BaseIp 192.168.1.10
keylset WorkLaptop Gateway 192.168.1.1
keylset WorkLaptop MacAddress None

#Group WorkLaptop - Security Options
keylset WorkLaptop Method {None}

#Group iDevice
keylset iDevice GroupType 802.11abg
keylset iDevice Dut dut1

#Group iDevice - Client Options
keylset iDevice GratuitousArp True
keylset iDevice Dhcp Enable
keylset iDevice Ssid veriwave_a
keylset iDevice Hops 3
keylset iDevice Qos Disable
keylset iDevice Uapsd 0
keylset iDevice ListenInt 1
keylset iDevice phyInterface 802.11a
keylset iDevice Wlan80211eQoSAC 0
keylset iDevice BaseIp 192.168.1.14
keylset iDevice Gateway 192.168.1.1
keylset iDevice MacAddress None

#Group iDevice - Security Options
keylset iDevice Method {None}



