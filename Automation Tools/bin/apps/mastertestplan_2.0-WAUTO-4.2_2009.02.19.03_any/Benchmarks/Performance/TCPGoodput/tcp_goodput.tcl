#Test Configuration

keylset global_config TestList { tcp_goodput }


# tcp_goodput test specific information
#
keylset tcp_goodput Benchmark tcp_goodput

#User parameter : NumOfSessionPerClient
keylset tcp_goodput NumOfSessionPerClient 1
keylset tcp_goodput TcpWindowSize 65535
keylset tcp_goodput FrameSizeList $MSSsegmentSize
#Create layer 2 Frames of size specified in FrameSizeList


#keylset tcp_goodput FlowLearningTime 2
#keylset tcp_goodput ClientLearningTime 2
#keylset tcp_goodput SettleTime 5
#keylset tcp_goodput AgingTime 10
#keylset tcp_goodput ArpNumRetries 10
#keylset tcp_goodput ArpRate 50
#keylset tcp_goodput ArpTimeout 20


keylset wireless_group_a NumClients $NumClients
keylset wireless_group_g NumClients $NumClients
keylset wireless_group_b NumClients $NumClients
keylset ether_group_1 NumClients { 1 } 
keylset ether_group_2 NumClients { 1 }



keylset wireless_group_a Dhcp Enable
keylset wireless_group_g Dhcp Enable
keylset wireless_group_b Dhcp Enable

keylset wireless_group_a Method { None WPA-PSK WPA2-PSK }
keylset wireless_group_g Method { None WPA-PSK WPA2-PSK }
keylset wireless_group_b Method { None WPA-PSK WPA2-PSK }

#Set the P/F criteria 
keylset tcp_goodput AcceptableGoodput $AcceptableGoodput
