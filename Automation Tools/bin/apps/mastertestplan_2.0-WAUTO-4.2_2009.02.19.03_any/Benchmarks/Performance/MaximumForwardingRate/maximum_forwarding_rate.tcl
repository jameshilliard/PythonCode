#Test Configuration

#keylset max_forwarding_rate FlowLearningTime 2
#keylset max_forwarding_rate ClientLearningTime 2
#keylset max_forwarding_rate SettleTime 5
#keylset max_forwarding_rate AgingTime 10
#keylset max_forwarding_rate ArpNumRetries 5
#keylset max_forwarding_rate ArpRate 50
#keylset max_forwarding_rate ArpTimeout 10




keylset global_config TestList { max_forwarding_rate }

#Unicast Maximum Forwarding Rate Test parameters

keylset max_forwarding_rate Benchmark unicast_max_forwarding_rate
keylset max_forwarding_rate Frame Custom
keylset max_forwarding_rate FrameType 80211
keylset max_forwarding_rate FrameSizeList $FrameSizeList
keylset max_forwarding_rate SearchResolution 0.1




keylset wireless_group_a NumClients $NumClients
keylset wireless_group_g NumClients $NumClients
keylset wireless_group_b NumClients $NumClients 
keylset ether_group_1 NumClients { 1 }
keylset ether_group_2 NumClients { 1 }


keylset wireless_group_a Method { None WPA-PSK WPA2-PSK }
keylset wireless_group_g Method { None WPA-PSK WPA2-PSK }
keylset wireless_group_b Method { None WPA-PSK WPA2-PSK }

#Set the P/F criteria
keylset max_forwarding_rate AcceptableForwardingRate $AcceptableForwardingRate
