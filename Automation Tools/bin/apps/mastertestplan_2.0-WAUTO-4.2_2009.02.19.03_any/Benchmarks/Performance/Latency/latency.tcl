# Test Configurations

keylset global_config TestList { unicast_latency }

#  unicast_latency test specific information
#
keylset unicast_latency Benchmark unicast_latency
keylset unicast_latency Frame Custom
keylset unicast_latency FrameSizeList $FrameSizeList 
##Create layer 2 Frames of size specified with FrameSizeList

##Intended Load at layer2 in packets/sec
keylset unicast_latency ILoadList $LatencyIloadList
keylset unicast_latency ILoadMode Custom

#keylset unicast_latency FlowLearningTime 2
#keylset unicast_latency ClientLearningTime 2
#keylset unicast_latency SettleTime 5
#keylset unicast_latency AgingTime 10
#keylset unicast_latency ArpNumRetries 5
#keylset unicast_latency ArpRate 50
#keylset unicast_latency ArpTimeout 10


keylset wireless_group_a NumClients $NumClients
keylset wireless_group_g NumClients $NumClients
keylset wireless_group_b NumClients $NumClients
keylset ether_group_1 NumClients { 1}
keylset ether_group_2 NumClients { 1}

keylset wireless_group_a Method { None WPA-PSK WPA2-PSK }
keylset wireless_group_g Method { None WPA-PSK WPA2-PSK }
keylset wireless_group_b Method { None WPA-PSK WPA2-PSK }

#Set the P/F criteria
keylset unicast_latency AcceptableMaxLatency $AcceptableMaxLatency
keylset unicast_latency AcceptableAvgLatency $AcceptableAvgLatency









