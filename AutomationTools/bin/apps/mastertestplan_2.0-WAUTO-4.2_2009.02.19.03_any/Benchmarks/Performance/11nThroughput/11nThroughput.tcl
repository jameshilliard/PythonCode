

#keylset unicast_throughput FlowLearningTime 5
#keylset unicast_throughput ClientLearningTime 5
#keylset unicast_throughput SettleTime 2
#keylset unicast_throughput AgingTime 10
#keylset unicast_throughput ArpNumRetries 10
#keylset unicast_throughput ArpRate 50
#keylset unicast_throughput ArpTimeout 20


# Test Configurations

keylset global_config TestList { unicast_throughput }


keylset unicast_throughput Benchmark unicast_unidirectional_throughput
keylset unicast_throughput Frame Custom
keylset unicast_throughput FrameSizeList $FrameSizeList
#Create layer 2 Frames of size specified in FrameSizeList



keylset unicast_throughput SearchResolution 10
keylset unicast_throughput Mode Fps
keylset unicast_throughput MinSearchValue Default
keylset unicast_throughput MaxSearchValue Default
keylset unicast_throughput StartValue Default

keylset wireless_group_a NumClients $NumClients
keylset wireless_group_g NumClients $NumClients
keylset wireless_group_b NumClients $NumClients
keylset ether_group_1 NumClients { 1 }
keylset ether_group_2 NumClients { 1 }


keylset wireless_group_a Method { None WPA-PSK WPA2-PSK }
keylset wireless_group_g Method { None WPA-PSK WPA2-PSK }
keylset wireless_group_b Method { None WPA-PSK WPA2-PSK }
keylset wireless_group_n Method { None WPA-PSK WPA2-PSK }

#Set the P/F criteria
keylset unicast_throughput AcceptableThroughput $AcceptableThroughput
