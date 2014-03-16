# Test Configurations

keylset global_config TestList { basic_forwarding }
keylset global_config TrialDuration 10

keylset basic_forwarding Benchmark unicast_packet_loss 
keylset basic_forwarding Frame Custom

#Change FrameSize from 88 to 1518 incrementing by 1byte at a time
keylset basic_forwarding FrameSizeList { [ range 64 1518 1] }

#Intended Load List 1000 layer 2 packets/sec
# Note: MTP calls for multiple rates, but this greatly speeds up the test. 
keylset basic_forwarding ILoadList { 1000.0 3000.0 5000.0 7000.0}
keylset basic_forwarding ILoadList { 4000.0 }
keylset basic_forwarding ILoadMode Custom

#keylset basic_forwarding FlowLearningTime 5
#keylset basic_forwarding ClientLearningTime 5
# The following 2 settings are test specific overrides. 
keylset basic_forwarding SettleTime 1
keylset basic_forwarding AgingTime 2
#keylset basic_forwarding ArpNumRetries 5
#keylset basic_forwarding ArpRate 50
#keylset basic_forwarding ArpTimeout 10

# Note: MTP calls for testing with TKIP and AES encryption as well. 
#keylset wireless_group_a Method { None WPA-PSK WPA2-PSK }
#keylset wireless_group_g Method { None WPA-PSK WPA2-PSK }
#keylset wireless_group_n Method { None WPA-PSK WPA2-PSK }
keylset wireless_group_a Method { None }
keylset wireless_group_g Method { None }
keylset wireless_group_n Method { None }

# Note: MTP calls for testing at 1 and 10 clients.
keylset wireless_group_a NumClients { 1  }
keylset wireless_group_g NumClients { 1  }
keylset wireless_group_b NumClients { 1  }
keylset wireless_group_n NumClients { 1  }
#keylset wireless_group_a NumClients { 1  10 }
#keylset wireless_group_g NumClients { 1  10 }
#keylset wireless_group_b NumClients { 1  1O }
#keylset wireless_group_n NumClients { 1  10 }
keylset ether_group_1 NumClients { 1  }
keylset ether_group_2 NumClients { 1  }

keylset basic_forwarding AcceptableFrameLossRate 0









