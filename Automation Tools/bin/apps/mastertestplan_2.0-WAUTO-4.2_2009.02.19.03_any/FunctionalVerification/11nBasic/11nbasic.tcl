# Test Configurations

keylset global_config TestList { unicast_packet_loss }
keylset unicast_packet_loss Benchmark unicast_packet_loss

#Enable/Disable the User Specified Pass/Fail criteria for all the category
#could be disabled in the test specific part also.
keylset global_config PassFailUser True

#  unicast_latency test specific information
keylset unicast_packet_loss Frame Custom
#layer 2 frame size:

#keylset unicast_packet_loss FrameSizeList $FrameSizeList
keylset unicast_packet_loss FrameSizeList {88 1518}

# If PassFailUser is True then user can specify the Acceptable Frame Loss Rate
# If PassFailUser is False then the test runs normally as before and gives the exit
# status of the code as the result
keylset unicast_packet_loss AcceptableFrameLossRate 5

#Intended Load 700,600....,100 layer 2 packets/sec
keylset unicast_packet_loss ILoadMode Custom
keylset unicast_packet_loss ILoadList { 500}


#keylset unicast_packet_loss FlowLearningTime 5
#keylset unicast_packet_loss ClientLearningTime 5
#keylset unicast_packet_loss SettleTime 2
#keylset unicast_packet_loss AgingTime 5
#keylset unicast_packet_loss ArpNumRetries 2
#keylset unicast_packet_loss ArpRate 50
#keylset unicast_packet_loss ArpTimeout 10

keylset wireless_group_n  NumClients {1 10}

keylset ether_group_1 NumClients { 1}
keylset ether_group_2 NumClients { 1}

#keylset wireless_group_a Method { None WPA-PSK WPA2-PSK }
#keylset wireless_group_g Method { None WPA-PSK WPA2-PSK }
keylset wireless_group_g Method { None }

keylset wireless_group_b Method { None WPA-PSK WPA2-PSK }
