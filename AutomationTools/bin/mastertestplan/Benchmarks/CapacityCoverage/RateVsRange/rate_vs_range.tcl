#Test Configuration

#keylset rate_vs_range FlowLearningTime 2
#keylset rate_vs_range ClientLearningTime 2
#keylset rate_vs_range SettleTime 5
#keylset rate_vs_range AgingTime 10
#keylset rate_vs_range ArpNumRetries 5
#keylset rate_vs_range ArpRate 50
#keylset rate_vs_range ArpTimeout 10



keylset global_config TestList { rate_vs_range }

# rate_vs_range Configuration
keylset rate_vs_range Benchmark rate_vs_range
keylset rate_vs_range Frame Custom

#layer 2 Frame Sizes listed below are used
#User can change this to anything between 88-1518
keylset rate_vs_range FrameSizeList { 1518 }
keylset rate_vs_range Mode Custom

#The External attenuation value specified here will be taken into consideration while calculation total power
#NOTE (USER_PARAM): THIS VALUE SHOULD BE ADJUSTED BY THE USER
keylset rate_vs_range ExternalAttenuation 60

keylset rate_vs_range InitialPowerLevel -6
keylset rate_vs_range FinalPowerLevel -42
keylset rate_vs_range IncrementPowerLevel 1


keylset wireless_group_a NumClients { 1  }
keylset wireless_group_g NumClients { 1  }
keylset wireless_group_b NumClients { 1  }
keylset ether_group_1 NumClients { 1  }
keylset ether_group_2 NumClients { 1  }


keylset wireless_group_a Dhcp Enabled
keylset wireless_group_b Dhcp Enabled
keylset wireless_group_g Dhcp Enabled
# By default will use static IP on ethernet. 

#set the P/F criteria
keylset rate_vs_range RefPowerList $RefPowerList
keylset rate_vs_range RefRateList $RefRateList
