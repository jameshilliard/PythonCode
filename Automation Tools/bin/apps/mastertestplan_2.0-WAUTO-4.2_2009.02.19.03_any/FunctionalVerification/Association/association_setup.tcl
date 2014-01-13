# Common configuration parameters for association tests

#keylset association FlowLearningTime 2
#keylset association ClientLearningTime 2
#keylset association SettleTime 5
#keylset association AgingTime 10
#keylset association ArpNumRetries 5
#keylset association ArpRate 50
#keylset association ArpTimeout 10



keylset global_config TestList { association }

keylset association Benchmark unicast_packet_loss

#Frame can be  Standard/Custom
keylset association Frame Custom

#Create layer 2 Frames of size 88 and 1518
keylset association FrameSizeList { 88 1518 }

#Intended Load 100.0 layer2  packets/sec
keylset association ILoadList { 100.0 }
keylset association ILoadMode Custom



keylset wireless_group_a NumClients $NumClients
keylset wireless_group_g NumClients $NumClients
keylset wireless_group_b NumClients $NumClients
keylset ether_group_1 NumClients { 1 }
keylset ether_group_2 NumClients { 1 }

#Set the P/F criteria
keylset association AcceptableFrameLossRate 50
