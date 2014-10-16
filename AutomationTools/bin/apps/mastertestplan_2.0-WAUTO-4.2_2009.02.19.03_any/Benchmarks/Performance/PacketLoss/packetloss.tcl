# Test Configurations

keylset global_config TestList { unicast_packet_loss }

#  unicast_latency test specific information

keylset unicast_packet_loss Benchmark unicast_packet_loss
keylset unicast_packet_loss Frame Custom
#layer 2 frame size: 
keylset unicast_packet_loss FrameSizeList $FrameSizeList 


#Intended Load 700,600....,100 layer 2 packets/sec
keylset unicast_packet_loss ILoadList { 1000 3000 5000 7000 }
#keylset unicast_packet_loss ILoadList { 2000 4000 6000 8000 10000 }
keylset unicast_packet_loss ILoadMode Custom

#keylset unicast_packet_loss FlowLearningTime 5
#keylset unicast_packet_loss ClientLearningTime 5
#keylset unicast_packet_loss SettleTime 2
#keylset unicast_packet_loss AgingTime 5
#keylset unicast_packet_loss ArpNumRetries 2
#keylset unicast_packet_loss ArpRate 50
#keylset unicast_packet_loss ArpTimeout 10

keylset wireless_group_a NumClients $NumClients
keylset wireless_group_g NumClients $NumClients
keylset wireless_group_b NumClients $NumClients
keylset ether_group_1 NumClients { 1}
keylset ether_group_2 NumClients { 1}

keylset wireless_group_a Dhcp Enable
keylset wireless_group_g Dhcp Enable
keylset wireless_group_b Dhcp Enable
keylset ether_group_1 Dhcp Enable

keylset wireless_group_a Method { None WPA-PSK WPA2-PSK }
keylset wireless_group_g Method { None WPA-PSK WPA2-PSK }
keylset wireless_group_b Method { None WPA-PSK WPA2-PSK }

#Set the P/F criteria
# Because this test actually oversubscribes the medium, the check
# will just make sure some traffic is always forwarded.
keylset unicast_packet_loss AcceptableFrameLossRate 90


