#This is a security script


#keylset security FlowLearningTime 2
#keylset security ClientLearningTime 2
#keylset security SettleTime 2
#keylset security AgingTime 2
#keylset security ArpNumRetries 5
#keylset security ArpRate 50
#keylset security ArpTimeout 10


keylset global_config TestList { security }

# Test Configurations

keylset security Benchmark unicast_packet_loss
keylset security Frame Custom

#layer2 Frame Size is 88 first time, 512 second time and 1518 in the last iteration
keylset security FrameSizeList { 88 512 1518 }

#Intended load is 100 layer2 packets/sec
keylset security ILoadList { 100.0 }
keylset security ILoadMode Custom

#Set the P/F criteria
keylset security AcceptableFrameLossRate 50

