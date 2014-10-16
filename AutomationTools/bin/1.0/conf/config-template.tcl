#
# config.tcl - test automation configuration file template
#
# VeriWave customers may edit this file to control the automated execution of
# the VeriWave applications.
#
# if this file is renamed to $VW_TEST_ROOT/automation/conf/config.tcl it will be
# automatically sourced by automation programs found in $VW_TEST_ROOT/automation/bin.
#
# $Id: config-template.tcl,v 1.62.2.1.2.5 2008/02/06 15:23:05 manderson Exp $
#

##
## Global configuration section begins here
##
## In the global configuration section, we set values which
## will be common to all tests.
##
## Values set in this section may be over-ridden
## by more specific values which pertain to specific test applications
## in the test-specific section of the config which
## follows the global configuration section.
##

# version number for this template file.  Please do not edit.  
keylset global_config TemplateVersion 4.0.0.0

#
# First, configure the IP address of the WaveTest chassis
#
# If using a multi-chassis set-up, specify the IP address of the
# primary chassis.
#
keylset global_config ChassisName  192.168.10.246

#
# and the directory under which to store test result logs
#
# Example:
#
#   keylset global_config LogsDir "/var/log/veriwave"
#
# if not specifically set, VW_TEST_ROOT is set to one directory higher
# than the running vw_auto.tcl program.
#
keylset global_config LogsDir [file join $VW_TEST_ROOT results]

#
# The license key to be used to enable extra tests
# This is now a list to support entering multiple license keys in the format of #####-#####-#####
#
#keylset global_config LicenseKey   { #####-#####-##### #####-#####-##### }

#
# Now define whether the tests should run with Unidirectional
# or Bidirectional traffic
#
# Valid Values: Unidirectional or Bidirectional
#
keylset global_config Direction { Unidirectional }


#
# Now specify the Destination and Source group or groups
#
# Note: the specified here must exactly match the names
# of groups which you have defined later in this file
# in the group definition section.
#
keylset global_config Destination { ether_group    }
keylset global_config Source      { wireless_group }

#
# The number of trials to run for each combination of Frame Size and
# Intended Load. (May be overridden at the group or test-specific level)
#
keylset global_config NumTrials 1


#
# The duration in seconds each trial is to last (in seconds)
# (May be overridden at the group or test-specific level)
#
keylset global_config TrialDuration 10

#
# Loss Tolerance (default = 0.0 (percent))
#
# Defines what percentage of packet loss is acceptable in order for a
# test to be considered as PASSing.  By default, a loss percentage of 0.0
# is used, meaning that in order for a test to be considered as PASSing,
# zero packet loss must be seen.
# (May be overridden at the group or test-specific level)
#
#keylset global_config LossTolerance 0.0


#
# Data and management frame PHY rates
# Defines what speed to use for the maximum PHY rate for data and 
# management frame types.
# (May be overridden at the group or test-specific level)
#
#keylset global_config DataPhyRate 54
#keylset global_config MgmtPhyRate 6


#
# ARP discovery configuration.  
# It should be okay to leave these parameters commented out in most
# configurations which will allow the system to use default values.
#
# If you wish to adjust the ARP parameters, simply un-comment the
# lines below and set the values as needed.
# (May be overridden at the group or test-specific level)
#
#keylset global_config ArpNumRetries  5
#keylset global_config ArpRate        10
#keylset global_config ArpTimeout     30

#-------------------------------------------------------------------------------
###User Specified Pass/Fail Criteria for a specific test category
##To Enable the user specified pass/fail criteria set the PassFailUser 
# to True
#keylset global_config PassFailUser True

#--unicast_packet_loss: 
#specify the Acceptable frame loss rate in percentage 
#keylset unicast_packet_loss AcceptableFrameLossRate 5
#--unicast_unidirectinal_throughput:
#user can specify the mode of Reference Throughput along with the Throughput input mode

#ReferenceTPUTMode ,can be specified as  :Theoretical or MediumCapacity
#keylset unicast_unidirectional_throughput ReferenceTPUTMode Theoretical
#ThroughputInputMode Percentage or Specify(in Mbps)

#keylset unicast_unidirectional_throughput ThroughputInputMode Percentage
#keylset unicast_unidirectional_throughput AcceptableThroughput 50

#--unicast_latency
#provide the acceptable Avg latency and Max latency values in milliseconds 
# defaults are 2ms for average and 20ms for Max Latency
#keylset unicast_latency AcceptableAvgLatency 2
#keylset unicast_latency AcceptableMaxLatency 20

#--unicast_maximum_client_capacity
#keylset unicast_max_client_capacity  ExpectedClientConnections 25

#--unicast_maximum_forwarding_rate
# Mode can be Percentage=Percentage of Medium Capacity (or) Specify=user can directly specify 
# Defaut value will be Percentage mode and AcceptableForwardingRate of 90 % 
#keylset unicast_max_forwarding_rate ForwardingRateMode Percentage
#keylset unicast_max_forwarding_rate AcceptableForwardingRate 90

#--rate_vs_range
### Give the Reference P/F criteria in Two List
### One for Power levels and another for Corresponding forwarding rates
### Check that values in the Ref power list are in the range of Initial and Final Power levels
#keylset rate_vs_range RefPowerList {-6 -20 -40)
#keylset rate_vs_range RefRateList  {3 3 3}  

#--tcp_goodput
### Goodput Mode can be Percentage/Specify
### This value will be in % in percentage mode and in Kbps in specify Mode
### Default values is Percentage mode and 90% acceptable goodput
#keylset tcp_goodput GoodputMode Percentage
#keylset tcp_goodput AcceptableGoodput 80

#-- aaa_auth_rate
#keylset aaa_auth_rate ExpectedAuthentications 1.0

#-- qos_service
#keylset qos_assurance BackgroundAcceptableBackgroundRate 2500

#--qos_capacity
#keylset qos_capacity VoiceExpectedCallCapacity 50

#--roaming_delay and roaming_benchmark
#For roaming_delay , roaming_benchmark we have to specify the acceptable pass/fail criteria
# inside the wireless group paramters for each group.

# wireless_group_a {
#    {AcceptableRoamFailures 0}
#    {AcceptableRoamDelay 700}
# }


#-------------------------------------------------------------------------------
# Database support for logging the results
# If DbSupport is True then provide the database type, database username,
# database password, database name and also the database server ip or name
# as given below. (uncomment these things and use)
# by default Dabase support will be disabled, if enabled the default values
# are as shown below
#keylset global_config DbSupport  True

#keylset global_config DbType "mysql"
#keylset global_config DbUserName "root"
#keylset global_config DbName "veriwave"
#keylset global_config DbPassword "veriwave"
#keylset global_config DbServerIP "localhost"
#-------------------------------------------------------------------------------



#
# Then, configure one or more tests to run.
#
# Choose one or more of:
#
#   unicast_latency
#   unicast_max_client_capacity
#   unicast_max_forwarding_rate
#   unicast_packet_loss
#   unicast_unidirectional_throughput
#   qos_capacity
#   qos_assurance
#   qos_roam_quality
#   roaming_delay
#   rate_vs_range
#   tcp_goodput
#   aaa_auth_rate
#   mesh_latency_aggregate
#   mesh_latency_per_hop
#   mesh_max_forwarding_rate_per_hop
#   mesh_throughput_aggregate
#   mesh_throughput_per_hop

#
# If you specify more than one test, the test names in the list should be
# separated by whitespace.
#
# Example:
#
#  keylset global_config TestList { 
#   unicast_latency
#   unicast_max_forwarding_rate
#   unicast_packet_loss
#   unicast_unidirectional_throughput
#  }
#
keylset global_config TestList {
   unicast_latency
   unicast_max_forwarding_rate
   unicast_packet_loss
   unicast_unidirectional_throughput
}

#
# The following sets card 4 on channel 1 and card 5 on channel 11 into 
# monitor mode
#
#keylset monitor1 Port 192.168.10.246:4.1
#keylset monitor1 Channel 1
#keylset monitor2 Port 192.168.10.246:5.1
#keylset monitor2 Channel 11
#keylset global_config PortMonitors {monitor1 monitor2}

##
## BEGIN group config
##
## Group configuration begins here
##
## Values set in this Group config section may be over-ridden
## by more specific values which pertain to specific Devices Under Test (DUT's)
## in the DUT configuration section of this config file
##

#
# When defining a group,
# the Channel or list of channels to test may be defined for a group
# as follows:  The channel definition can be a single channel,
# or it can be specified as a list of channel numbers,
# or it can be specified as a range of values [range start end step_value]
#
# Examples:
#
# Channel settings may be specified as a list such as:
#
#   { Channel { 1 3 5 7 } }
#
# or an individual channel like this:
#
#   { Channel { 3 } }
#
# or a range like:
#
#   { Channel [range 1 12 1] }
#
#   The range example above will cycle through all of the channels
#   from 1 through 12 (inclusive)
#
# or as a randomized list (if you would like the channels to be tested
# in a different order each time you execute this set of tests:
#
#   { Channel [randomize_list [range 1 12 1]] }
#

#
# The list of security methods to iterate through may also be defined here.
#
# Valid choices include:
#
#   None
#
#   WEP-Open-40 WEP-Open-128
#   WEP-SharedKey-40 WEP-SharedKey-128
#
#   WPA-EAP-TLS   WPA-PSK  WPA-PEAP-MSCHAPV2  WPA-EAP-TTLS-GTC 
#   WPA2-EAP-TLS WPA2-PSK WPA2-PEAP-MSCHAPV2 WPA2-EAP-TTLS-GTC
#
#   LEAP WPA-LEAP WPA2-LEAP
#
#   DWEP-EAP-TTLS-GTC DWEP-EAP-TLS
#   DWEP-PEAP-MSCHAPV2
#
# TODO: move to group level only!
#
# Example:
#
#   { Method { WEP-Open-40 WEP-SharedKey-128 } }
#

#
# The username and password to be used for client authenticated security methods
# 
# Example:
#
#  { Identity             anonymous }
#  { Password             whatever  }
#  { AnonymousIdentity    anonymous }

#
# The ASCII or hex keys for the PSK security methods.  If both ASCII and hex
# are defined, ASCII is used by default.
#
# Example:
#
# { PskAscii             whatever         }
# { PskHex               0123456789ABCDEF }

#
# WEP keys in either ASCII or hex.  Like PSK, ASCII is used if both formats
# are defined.
#
# Example:
#
# { WepKey40Ascii   a1b2c                      }
# { WepKey128Ascii  d1e2f3g4h5i6j              }
# { WepKey40Hex     CAFEBABE01                 }
# { WepKey128Hex    BADC0FFEE123456789CAFEFEED }

#
# The location of certs and key files for public key based security methods.
# There is no default for these options.  If they are not specified they won't be
# used.
#
# Example:
#
# { ClientCertificate          $VW_TEST_ROOT/etc/cert-clt.pem }
# { RootCertificate            $VW_TEST_ROOT/etc/root.pem     }
# { PrivateKeyFile             $VW_TEST_ROOT/etc/cert-clt.pem }
# { EnableValidateCertificate  off                            }

#
# GroupType should be set to either 802.3 (for ethernet groups)
# or 802.11abg for wireless groups.
#
# Dut should be set to the name of the Device Under Test (DUT)
# that this group is attached to.
#
# Dhcp should be set to Enable or Disable
#
# EnableValidateCertificate should be set to on or off
#
# Bssid should be set to a valid BSSID or to 0
# If Bssid is set to 0, the test software will scan for the BSSID
# on the specified channel(s).
#

#
# Definition for a wireless group
#
set wireless_group {
    { GroupType         802.11abg                       }
    { BssidIndex        4                               }
    { Ssid              "automation"                    }
    { Dut               sample-generic-ap               }
    { Method            { WEP-Open-40 WEP-Open-128 }    }
    { Channel           { 1 7 }                         }
    { NumClients        1                               }

    { Identity          anonymous                       }
    { Password          whatever                        }
    { AnonymousIdentity anonymous                       }
    { PskAscii          whatever                        }
    { WepKey40Hex       CAFEBABE01                      }
    { WepKey128Hex      BADC0FFEE123456789CAFEFEED      }
    { EnableValidateCertificate     off                 }
    
    { Dhcp              Enable          }
    
    { BaseIp            10.10.250.20    }
    { IncrIp            0.0.0.1         }
    { SubnetMask        255.255.0.0     }
    { Gateway           10.10.251.1     }
}

#
# An alternative way of setting/overriding values
# for this group is shown below using the more verbose
# TCL "keylset" notation which is a little harder to read,
# but easier to use in some circumstances because
# individual lines may be commented out to disable them,
# where comments cannot be placed in the middle of the
# more compact curly-brace-style definition above
#

#keylset wireless_group   WepKey40Ascii       12345

# this is equivalent to placing
#
#   { WepKey40Ascii   12345 }
#
# in the wireless_group definition above.  Either or both formats
# may be used for defining values to be used with this wireless group
#
# Some more examples are provided here of values which
# you may want to define and enable in the future.  They are
# included here as commented-out (disabled) values for now.

#keylset wireless_group   WepKey128Ascii      123456789ABCD
#keylset wireless_group   ClientCertificate   $VW_TEST_ROOT/etc/cert-clt.pem
#keylset wireless_group   RootCertificate     $VW_TEST_ROOT/etc/root.pem
#keylset wireless_group   PrivateKeyFile      $VW_TEST_ROOT/etc/cert-clt.pem
#keylset wireless_group   DataPhyRate         54
#keylset wireless_group   MgmtPhyRate         6
#keylset wireless_group   ServiceProfile      veriwave

#
# Elsewhere in this file we specify the defaults for running
# each type of test.  Here we show how to override those default
# parameters to provide alternative values which will be used
# for just this wireless group.
#
# Any values defined specifically for a group will take precedence and
# override the default values which are defined for a given test.
#
# Example: we'll change the dwellTime roaming test parameter
# to make it a different value for this group than for the
# system-wide default value for roaming dwellTime.
#
#keylset wireless_group    dwellTime           1

# the list of APs that will be used in a roaming test _along_ with the Dut entry
keylset wireless_group AuxDut       { sample-generic-ap2 }

# 802.11n groups must have phyInterface defined
#keylset wireless_group phyInterface 802.11n

# 802.11n groups should also define GroupType properly
#keylset wireless_group GroupType 802.11n

#
# load some additional wireless groups
#
# A statement below of the form:
#
#     cfg_load_module group wireless_group_x
#
# will load the file conf/wireless_group_x.tcl
# into this configuration.
#
#cfg_load_module group wireless_group_b
#cfg_load_module group wireless_group_w
#cfg_load_module group wireless_group_wc

#
# Definition for an ethernet group
#
set ether_group {
    { GroupType         802.3               }
    { NumClients        1                   }
    { Dut               sample-generic-ap   }
    { Dhcp              Enable              }
    { Gateway           10.10.251.1         }
    { BaseIp            10.10.10.50         }
    { SubnetMask        255.255.0.0         }
    { IncrIp            0.0.0.1             }
}

#
# load some additional ethernet groups
# (similar to loading additional wireless groups above)
#
#cfg_load_module group ether_group_w
#cfg_load_module group ether_group_wc

##
## BEGIN test-specific config
##
## Test-specific configuration begins here
##
## Values set in the test-specific section may be over-ridden
## by more specific values which pertain to specific Devices Under Test (DUT's)
## in the DUT configuration section of this config file
##

#
# Documentation on Test-specific parameters
#
# The following parameters are described once in this comment section,
# an may appear in one or more of the test-specific sections
# of the configuration file below.
#

#
#  FrameSizeList
# Define the frame sizes to be used in each test.
#
# Frame sizes may be set by explicitly listing each frame size
#    which you would like to test (like this):
#
#    keylset unicast_latency FrameSizeList { 64 128 256 }
#
# or frame sizes may alternatively be set using range notation like this:
#
#    keylset ... [range <start> <end> <step>]
#
#   the <step> parameter is optional and defaults to step=1 if not specified
#
# Example 1:
#
#    keylset unicast_latency FrameSizeList [range 64 256 64]
#
# generates a list of values for a range which starts at 64,
# ends at 256, and has a step of 64 and will set the FrameSizeList
# for the test to be this list of frame sizes:
#
#   { 64 128 192 256 }
#
# Example 2:
#
# to test all possible frame sizes between 64 and 1024
# (64 through 1024 inclusive), you would use:
#
#   keylset unicast_latency FrameSizeList [range 64 1024]
#
#       (a step of 1 is implied)
#
# Example 3:
#
# to test all possible even frame sizes
# from 64 and 1024 inclusive you would use:
#
#   keylset unicast_latency FrameSizeList [range 64 1024 2]
#
#   (a step of 2 is specified)
#
#

#  Intended Load List (ILoadList)
# Define the list of Intended Loads.  The intended load is expressed
# in frames/sec and is applied at the port level.  The port load is
# divided equally between all source clients on a port.  The intended
# load is expressed in frames/second.
#
# There is a enforced 1:1 relationship between the frame size list and
# intended load list for the unicast latency test.  In short, there must be
# exactly one entry in the intended load list for each frame size.
# 
# The specified intended load list for the unicast packet loss test will be
# applied to each frame size when the test is run.
#
# Either intended load list may be specified as a list such as:
#
#   keylset unicast_latency ILoadList { 100 500 }
#
# or a range like:
#
#   keylset unicast_latency ILoadList [ range 100 500 100 ]
#   which is equivalent to ...           { 100 200 300 400 500 }
#
#

#  SearchResolution
# The search resolution (default = 0.1)
#
# Determines how precise the search for the final test result needs to be.
# For instance, a value of 0.1 means that the search will stop if the current
# result is within 0.1% of the previous iteration result.
#
#


#
#  unicast_latency test specific information
#
keylset unicast_latency Test unicast_latency
keylset unicast_latency Frame Custom
keylset unicast_latency FrameSizeList { 88 128 256 512 1024 1280 1518 } 
keylset unicast_latency ILoadList { 700.0 600.0 500.0 400.0 300.0 200.0 100.0 }
keylset unicast_latency ILoadMode Custom

# If you have customized one of the tests and wish WaveAutomation
# to run that one instead of the default tests, specify it with the 
# TestLocation variable
#keylset unicast_latency TestLocation /usr/local/bin/unicast_latency-modified.py
#keylset unicast_latency TestLocation "C:\Tests\unicast_latency-modified.py"

#
#  unicast_max_client_capacity test specific information
#
keylset unicast_max_client_capacity Test unicast_max_client_capacity
keylset unicast_max_client_capacity Frame Standard
keylset unicast_max_client_capacity FrameSizeList { 88 128 }
keylset unicast_max_client_capacity ILoadList { 700.0 600.0 }
keylset unicast_max_client_capacity ILoadMode Custom
keylset unicast_max_client_capacity SearchResolutionAbsolute 1
keylset unicast_max_client_capacity MinSearchValue 1
keylset unicast_max_client_capacity MaxSearchValue 16

#
#  unicast_max_forwarding_rate test specific information
#
keylset unicast_max_forwarding_rate Test unicast_max_forwarding_rate
keylset unicast_max_forwarding_rate Frame Standard
keylset unicast_max_forwarding_rate FrameSizeList {64 1500}
keylset unicast_max_forwarding_rate SearchResolution 0.1

#
#  unicast_packet_loss test specific information
#
keylset unicast_packet_loss Test unicast_packet_loss
keylset unicast_packet_loss Frame Standard
keylset unicast_packet_loss FrameSizeList {1023}
keylset unicast_packet_loss ILoadList {128.0}
keylset unicast_packet_loss ILoadMode Custom

#
#  unicast_unidirectional_throughput test specific information
#
# use either the Fps settings or the percentage settings for 
# SearchResolution, MinSearchValue,  MaxSearchValue and StartValue.
#
keylset unicast_unidirectional_throughput Test unicast_unidirectional_throughput
keylset unicast_unidirectional_throughput Frame Standard
keylset unicast_unidirectional_throughput FrameSizeList { 256 1024 }
keylset unicast_unidirectional_throughput SearchResolution 0.1
keylset unicast_unidirectional_throughput Mode Fps
keylset unicast_unidirectional_throughput MinSearchValue Default
keylset unicast_unidirectional_throughput MaxSearchValue Default
keylset unicast_unidirectional_throughput StartValue Default
#keylset unicast_unidirectional_throughput Mode Percentage
#keylset unicast_unidirectional_throughput SearchResolution 5%
#keylset unicast_unidirectional_throughput MinSearchValue 1%
#keylset unicast_unidirectional_throughput MaxSearchValue 150%
#keylset unicast_unidirectional_throughput StartValue 50%
#keylset unicast_unidirectional_throughput SearchResolution Default 

# Units for MinSearchValue and MaxSearchValue are in pkts/sec.
# Units can also be percent, if number is followed by "%"
# Can use "Default" and theoretical maximum will be determined.
keylset unicast_unidirectional_throughput MinSearchValue Default
keylset unicast_unidirectional_throughput MaxSearchValue Default 
keylset unicast_unidirectional_throughput Mode Fps

# MediumCapacity values are specified as a TCL list of pairs.
#keylset unicast_unidirectional_throughput MediumCapacity {64, 14, 88, 15, 96, 16}

# roaming_delay test specific information
#
# all roaming_delay options are per group,
# their values need to be defined at the group
# level
keylset roaming_delay Test roaming_delay

# Roaming parameters are now specific to each wireless group, not
# at the test level. Repeat these paramaters for each wireless group
# you have configured for your roaming test.

# the list of APs that will be used in a roaming test _along_ with the Dut entry
#keylset wireless_group AuxDut       { sample-foundry-ap2 sample-foundry-ap3 }

#keylset wireless_group deauth 0
#keylset wireless_group preauth 0
#keylset wireless_group disassociate 0
#keylset wireless_group dwellTime 1
#keylset wireless_group dwellTimeOption 1
#keylset wireless_group pmkid 0
#keylset wireless_group timeDistOption 1
#keylset wireless_group clientDistOption 1
#keylset wireless_group powerProfileFlag 0
#keylset wireless_group learningFlowFlag 1
#keylset wireless_group learningPacketRate 100
#keylset wireless_group learningPacketCount 10
#keylset wireless_group learningPacketSize 256
#keylset wireless_group flowPacketSize 256
#keylset wireless_group flowRate 100
#keylset wireless_group reassoc 0
#keylset wireless_group srcStartPwr -6
#keylset wireless_group srcEndPwr -2
#keylset wireless_group destStartPwr -6
#keylset wireless_group destEndPwr -40
#keylset wireless_group srcChangeStep 1
#keylset wireless_group srcChangeInt 1000
#keylset wireless_group destChangeStep 2
#keylset wireless_group destChangeInt 1000
#keylset wireless_group durationUnits 0
#keylset wireless_group repeatValue 1
#keylset wireless_group repeatType 1


# roaming_benchmark test specific information
#
# most roaming_benchmark options are per group and thus
# must have their values defined at the group level
#
# roaming_benchmark test currently not enabled
#keylset roaming_benchmark Test roaming_benchmark
#keylset roaming_benhcmark roamRate  1.0

#
# qos_capacity test specific information
#
# Either the Source or Destination group
# must be an ethernet group
keylset qos_capacity Test qos_capacity
keylset qos_capacity VoiceQoSEnabled False
keylset qos_capacity VoiceCodec G.711
keylset qos_capacity VoiceSearchMin 1
keylset qos_capacity VoiceSearchMax 75
keylset qos_capacity VoiceUserPriority 7
keylset qos_capacity VoiceTosField Default 
keylset qos_capacity VoiceTosReserved False
keylset qos_capacity VoiceTosDiffsrvDscp Default
keylset qos_capacity VoiceTosLowCost False
keylset qos_capacity VoiceTosLowDelay False
keylset qos_capacity VoiceTosHighThroughput False
keylset qos_capacity VoiceTosHighReliability False
keylset qos_capacity VoiceSrcPort 5003
keylset qos_capacity VoiceDestPort 5004
keylset qos_capacity SlaMinRValue 78.0
keylset qos_capacity SlaMaxPktLoss 1.0
keylset qos_capacity SlaMode R-Value
keylset qos_capacity SlaMaxLatency 30.0
keylset qos_capacity SlaMaxJitter 250.0
keylset qos_capacity BackgroundQoSEnabled False
keylset qos_capacity BackgroundFrameSize 1500
keylset qos_capacity BackgroundFrameRate 100
keylset qos_capacity BackgroundType UDP
keylset qos_capacity BackgroundUserPriority 1
keylset qos_capacity BackgroundTosField Default
keylset qos_capacity BackgroundTosReserved False
keylset qos_capacity BackgroundTosDiffservDscp Default
keylset qos_capacity BackgroundTosLowCost False
keylset qos_capacity BackgroundTosLowDelay False
keylset qos_capacity BackgroundTosHighThroughput False
keylset qos_capacity BackgroundTosHighReliability False
keylset qos_capacity BackgroundSrcPort 0
keylset qos_capacity BackgroundDestPort 0

# When running the QoS test either the Source or the 
# Destination group must be an ethernet group
keylset qos_assurance Test qos_assurance
keylset qos_assurance VoiceCodec G.711
keylset qos_assurance VoiceNumberOfCalls 1
keylset qos_assurance VoiceQoSEnabled False
keylset qos_assurance VoiceUserPriority 7
keylset qos_assurance VoiceTosField Default
keylset qos_assurance VoiceTosReserved False
keylset qos_assurance VoiceTosDiffservDscp Default
keylset qos_assurance VoiceTosLowCost False
keylset qos_assurance VoiceTosLowDelay False
keylset qos_assurance VoiceTosHighThroughput False
keylset qos_assurance VoiceTosHighReliability False
keylset qos_assurance VoiceSearchMax 50
keylset qos_assurance VoiceSearchMin 1
keylset qos_assurance VoiceSsrcPort 5003
keylset qos_assurance VoiceDestPort 5004
keylset qos_assurance SlaMinRValue 78.0
keylset qos_assurance SlaMaxPktLoss 1.0
keylset qos_assurance SlaMode R-Value
keylset qos_assurance SlaMaxLatency 30.0
keylset qos_assurance SlaMaxJitter 250.0
keylset qos_assurance BackgroundQoSEnabled False
keylset qos_assurance BackgroundFrameRate 100.0
keylset qos_assurance BackgroundFRrameSize 1500
keylset qos_assurance BackgroundMaxFrameRate Default
keylset qos_assurance BackgroundMinFrameRate Default
keylset qos_assurance BackgroundSearchResolution 0.1
keylset qos_assurance BackgroundSearchStep 10
keylset qos_assurance BackgroundType UDP
keylset qos_assurance BackgroundUserPriority 1
keylset qos_assurance BackgroundTosField Default
keylset qos_assurance BackgroundTosReserved False
keylset qos_assurance BackgroundTosDiffservDscp Default
keylset qos_assurance BackgroundTosLowCost False
keylset qos_assurance BackgroundTosLowDelay False
keylset qos_assurance BackgroundTosHighThroughput False
keylset qos_assurance BackgroundTosHighReliability False
keylset qos_assurance BackgroundSrcPort 0
keylset qos_assurance BackgroundDestPort 0
keylset qos_assurance BackgroundDirection Bidirectional

#
#  qos_roam_quality test specific information
#
keylset qos_roam_quality Test qos_roam_quality
keylset qos_roam_quality qosRoamQosEnabled True
keylset qos_roam_quality qosRoamBaseCallDurationUnits 1
keylset qos_roam_quality qosRoamCallDropDelayThreshold 50
keylset qos_roam_quality qosRoamBaseCallDurationVal 1
keylset qos_roam_quality qosRoamDeauth 0
keylset qos_roam_quality qosRoamPreauth 0
keylset qos_roam_quality qosRoamDisassociate 0
keylset qos_roam_quality qosRoamDwellTime 1.0
keylset qos_roam_quality qosRoamRenewDHCPonConn 0
keylset qos_roam_quality qosRoamPmkid 0
keylset qos_roam_quality qosRoamRenewDHCP 0
keylset qos_roam_quality qosRoamDurationUnits 0
keylset qos_roam_quality qosRoamRepeatValue 30
keylset qos_roam_quality qosRoamPowerProfileFlag 0
keylset qos_roam_quality qosRoamRepeatType 1
keylset qos_roam_quality qosRoamReassoc 0
keylset qos_roam_quality qosRoamRoamRate 1.0

#
#  rate_vs_range test specific information
#
keylset rate_vs_range Test rate_vs_range
keylset rate_vs_range Frame Custom
keylset rate_vs_range FrameSizeList { 256 1024 }
keylset rate_vs_range ILoadList { 4380.0 2799.0 }
keylset rate_vs_range Mode Custom
keylset rate_vs_range ExternalAttenuation 0
keylset rate_vs_range InitialPowerLevel -10
keylset rate_vs_range FinalPowerLevel -20
keylset rate_vs_range IncrementPowerLevel 2

# RvR only works in the eth->wirless direction.  Override
# what was defined at the global level
keylset rate_vs_range Source      ether_group
keylset rate_vs_range Destination wireless_group

#
# tcp_goodput test specific information
#
keylset tcp_goodput Test tcp_goodput
keylset tcp_goodput NumOfSessionPerClient 2
keylset tcp_goodput TcpWindowSize 65535
keylset tcp_goodput FrameSizeList { 536 1460 }


#
# aaa_auth_rate test specific information
#
keylset aaa_auth_rate Test aaa_auth_rate
keylset aaa_auth_rate AuthenticationRate 10
keylset aaa_auth_rate ResultSampleTime 1
keylset aaa_auth_rate DisconnectClients True

#
#  mesh_latency_aggregate test specific information
#
keylset mesh_latency_aggregate Test mesh_latency_aggregate
keylset mesh_latency_aggregate Frame Custom
keylset mesh_latency_aggregate FrameSizeList { 88 128 256 512 1024 1280 1518 } 
keylset mesh_latency_aggregate ILoadList { 700.0 600.0 500.0 400.0 300.0 200.0 100.0 }
keylset mesh_latency_aggregate ILoadMode Custom

# to enable Blog Mode/Interference Generation for this test
# uncomment this line, and define the data section "blog1"
# an example is provided below

#keylset mesh_latency_aggregate Blog blog1

#
#  mesh_latency_per_hop test specific information
#
keylset mesh_latency_per_hop Test mesh_latency_per_hop
keylset mesh_latency_per_hop Frame Custom
keylset mesh_latency_per_hop FrameSizeList { 88 128 256 512 1024 1280 1518 } 
keylset mesh_latency_per_hop ILoadList { 700.0 600.0 500.0 400.0 300.0 200.0 100.0 }
keylset mesh_latency_per_hop ILoadMode Custom
#
#  mesh_max_forwarding_rate_per_hop test specific information
#
keylset mesh_max_forwarding_rate_per_hop Test mesh_max_forwarding_rate_per_hop
keylset mesh_max_forwarding_rate_per_hop Frame Standard
keylset mesh_max_forwarding_rate_per_hop FrameSizeList {88 128 256 512 1024 1280 1518}
keylset mesh_max_forwarding_rate_per_hop SearchResolution 0.1
#
#  mesh_throughput_aggregate test specific information
#
# use either the Fps settings or the percentage settings for 
# SearchResolution, MinSearchValue,  MaxSearchValue and StartValue.
#
keylset mesh_throughput_aggregate Test mesh_throughput_aggregate
keylset mesh_throughput_aggregate Frame Standard
keylset mesh_throughput_aggregate FrameSizeList {88 128 256 512 1024 1280 1518}
keylset mesh_throughput_aggregate SearchResolution 0.1
keylset mesh_throughput_aggregate Mode Percent
keylset mesh_throughput_aggregate MinSearchValue 1%
keylset mesh_throughput_aggregate MaxSearchValue 150%
keylset mesh_throughput_aggregate StartValue 50%

#
#  mesh_throughput_per_hop test specific information
#
# use either the Fps settings or the percentage settings for 
# SearchResolution, MinSearchValue,  MaxSearchValue and StartValue.
#
keylset mesh_throughput_per_hop Test mesh_throughput_per_hop
keylset mesh_throughput_per_hop Frame Standard
keylset mesh_throughput_per_hop FrameSizeList {88 128 256 512 1024 1280 1518}
keylset mesh_throughput_per_hop SearchResolution 0.1
keylset mesh_throughput_per_hop Mode Percent
keylset mesh_throughput_per_hop MinSearchValue 1%
keylset mesh_throughput_per_hop MaxSearchValue 150%
keylset mesh_throughput_per_hop StartValue 50%


#
# WaveAutomation can also run any executable during test execution.
#
#keylset ext_test_example Test          my_external_test
#keylset ext_test_example TestType      external
#keylset ext_test_example TestLocation  "/bin/ls"
#keylset ext_test_example TestExtraArgs {-a /tmp}

# external tests can also have arguments passed down to them from
# WaveAutomate.  If these arguments exist in your configuration file
# they will be passed down as arguments to your external test.
# For example, if you have:
#
# keylset global_config PingHosts {192.168.1.1 192.168.1.2 192.168.1.3}
# keylset ext_ping_test Test  ping_test
# keylset ext_ping_test TestType external
# keylset ext_ping_test TestLocation "/usr/local/bin/ping_test"
# keylset ext_ping_test TestExtraArgs {-c 1}
# keylset ext_ping_test TestArgs PingHosts
# 
# WaveAutomate will run ping three times, once for each of the hosts
# specificed in the PingHosts variable with the following command lines:
#
# /usr/local/bin/ping_test -c 1 --PingHosts=192.168.1.1
# /usr/local/bin/ping_test -c 1 --PingHosts=192.168.1.2
# /usr/local/bin/ping_test -c 1 --PingHosts=192.168.1.3
#
# You can control how the arguments are formatted with the following:
#
# keylset ext_ping_test TestArgsPrefix "--"
# keylset ext_ping_test TestArgsEquals "="

##
##  END of Test-specific definitions
##


##
## Beginning of DUT configuration section
##
## Parameters specified in the DUT configuration take precedence
## over parameters specified in either the Global config or
## test-specific configuration sections.
##

#
# Note: to keep this configuration file more compact and maintainable,
# DUT configurations are stored separate files and sourced in to this file.
# This has the additional benefit of allowing the user to keep the
# DUT configuration files separate from the rest of the configuration.
# DUT configurations are often static after they are defined and working,
# and keeping them in separate files from the main body of the automation
# configuration allows those DUT configuration files to be reused and shared
# by multiple users who may choose to reference those common/shared
# DUT configurations from their own separate and more frequently changed
# personal automation configuration files.
#
# Example:
#
#  DUT files may be loaded into this automation configuration file
#  using commands like this:
#
#   cfg_load_module dut dutNameAndModel
#
# See the existing files in the dut directory for an example of
# what a dut config file should look like.
#

#
# load DUT definition files from conf/dut directory
#
#
# For each DUT in the testbed, we need to describe the attributes of the DUT.
# Those attributes are stored in the configuration files we load for
# each DUT below.
#
# If using a multi-chassis testbed, where TxCard and RxCard are defined
# in chassis:card format, WavetestPort must also be in chassis:card format.
#
# Interfaces may now be configured to use DHCP for setting address information
# Adding the line { Dhcp Enable } in an Interface section will cause the given 
# wireless or Ethernet interface to query a DHCP server for client addresses 
# instead of using TestBase TestMask TestGate and TestIncr for the client addresses.
#

#cfg_load_module dut 3Com-2750
#cfg_load_module dut 3Com-3750
#cfg_load_module dut 3Com-7760
#cfg_load_module dut 3Com-8760-thick
#cfg_load_module dut cisco-1020
#cfg_load_module dut cisco-ios-1200
#cfg_load_module dut foundry-ip-200
#cfg_load_module dut symbol-300
#cfg_load_module dut symbol-5131


#
# A sample config for a generic, unknown or unsupported AP.  In any case,
# WaveAutomate will not try to configure this device.
#
#
# Do not change the Vendor from generic.  To add a vendor to the output PDF, add it to the APModel line
keylset sample-generic-ap Vendor                          generic

# Configure as needed.  These values are passed down into the PDF
keylset sample-generic-ap APModel                         unspecified
keylset sample-generic-ap APSwVersion                     unspecified

# Hardware mappings between the AP and the Veriwave chassis
keylset sample-generic-ap Interface.802_11b.InterfaceType 802.11bg
keylset sample-generic-ap Interface.802_11b.WavetestPort  192.168.1.1:5

keylset sample-generic-ap Interface.802_11a.InterfaceType 802.11a
keylset sample-generic-ap Interface.802_11a.WavetestPort  192.168.1.1:6

keylset sample-generic-ap Interface.802_3.InterfaceType   802.3
keylset sample-generic-ap Interface.802_3.WavetestPort    192.168.1.1:1

# keylset sample-generic-ap Interface.802_11n.InterfaceType 802.11n
# keylset sample-generic-ap Interface.802_11n.WavetestPort 192.168.1.1:4 

# the sampleDUTHook function defined below would be called for each
# ethernet and wireless group in the test.  Other hooks include:
# PostGroupHook, PreTestHook and PostTestHook
# keylset sample-generic-ap PreGroupHook                    sampleDUTHook

# The WaveAutomate configuration file is TCL. One can do many things to save
# time and lessen the chance of errors
set sample-generic-ap2 ${sample-generic-ap}
keylset sample-generic-ap2 Interface.802_11b.WavetestPort 192.168.1.1:3
keylset sample-generic-ap2 Interface.802_11a.WavetestPort 192.168.1.1:4

# Multi-port cards are defined with the following syntax:
#   address:card:port
# keylset sample-generic-ap2 Interface.802_11b.WavetestPort 192.168.1.1:3:1

# One can have a variable in an option match whatever value another variable
# has while the test runs.
#
# keylset test_wireless_group1 Method {None WPA-PSK WPA2-PEAP-MSCHAPV2}
# keylset test_wireless_group2 Method %%test_wireless_group1.Method%%
#
# In the above example, WaveAutomate will loop over the 3 security
# methods and both wireless groups would use the same security method
# across all 3 tests.
# If you had set test_wireless_group2 to the list of 3 methods,
# automation would have done a nested loop and done a total of 9 tests.

# Example data structure for Blog Mode/Interference Generation.
# Must match the blog setting at the Test Level. 
# See example for mesh_latency_aggregate 

# The card specified here MUST NOT be specified in a wireless group.
# You can ONLY specify wireless interfaces for Blog Mode

#keylset blog1 Card                        192.168.16.246:7
#keylset blog1 Band.1.BinLow               40
#keylset blog1 Band.1.BinHigh              614
#keylset blog1 Band.1.BinStrikeProbability 25
#keylset blog1 Band.2.BinLow               615
#keylset blog1 Band.2.BinHigh              1189
#keylset blog1 Band.2.BinStrikeProbability 25
#keylset blog1 Band.3.BinLow               1190
#keylset blog1 Band.3.BinHigh              1764
#keylset blog1 Band.3.BinStrikeProbability 25
#keylset blog1 Band.4.BinLow               1765
#keylset blog1 Band.4.BinHigh              2340
#keylset blog1 Band.4.BinStrikeProbability 25


##
## End of DUT configuration section
##

##
## Begin Sample External DUT Configuration
##

# this is a sample of how to integrate WaveAutomate with an external
# program to get an AP/Wireless Controller configured.
proc sampleDUTHook { config } {

    puts "Start of sampleDUTHook function"

    # This function will be called once for every client group configured
    # for each test.  In the simplest form, this function will be called twice.
    # Once for the wireless client group and a second time for the ethernet
    # clients.

    # $config is a TCL keyed list containing the global, group, test and DUT
    # configuration for this particular client group.

    # Start building the command line
    set cmd $::mine::program

    # Items are retrieved from this data structure with the vw_keylget function.
    # Knowing which type of client this is is usually the first step.
    set group_type [vw_keylget config "GroupType"]
    switch -glob -- $group_type {

        "802.3" {
            puts "this ethernet group will be ignored for this example" }

        "802.11*" {
            # While creating and debugging this function, it is handy to
            # have the full list of options:
            foreach key [keylkeys config] {
                set val [vw_keylget config $key]
                puts "$key = $val"
            }

            # Build the URL needed to communicate with the AP
            set user [vw_keylget config LoginUser]
            set pass [vw_keylget config LoginPassword]
            set addr [vw_keylget config LoginAddress]
            set port [vw_keylget config LoginPort]
            lappend cmd "--url=$user:$pass@$addr:$port"

            # Common options needed for configuring an AP
            set channel [vw_keylget config "Channel"]
            lappend cmd "--Channel=$channel"

            set ssid    [vw_keylget config "Ssid"]
            lappend cmd "--Ssid=$ssid"

            # The security method may or may not match what is used
            # on the AP.  Translate as necessary.  This is also a
            # good opportunity to grab and security method specific
            # configuration.
            set vw_method  [vw_keylget config "Method"]
            switch $vw_method {
                "None" {
                    set method "Open"
                }

                "WPA-PSK"  {
                    set pskpass [vw_keylget config PSKPassword]
                    set method "WPA2PSK"
                }
                "WPA2-PSK" {
                    set pskpass [vw_keylget config PSKPassword]
                    set method "WPAPSK"
                }
                default {
                    set method $vw_method
                }
            }
            lappend cmd "--method=$method"
            if {[info exists pskpass]} {
                lappend cmd "--pskpass=$pskpass"
            }
        }
    }

    # In a real example we'd be exec'ing the command.  For now,
    # just print it to the screen.
    puts "External command is $cmd"

    # All output from puts statements will show up in the output.log file
    # at the top level of the results directory
    puts "End of sampleDUTHook function"

}

# If one needs to store information between test runs it is safest
# to store them in a namespace to make sure you do not collide
# with WaveAutomate's variable names.
#
# puts ::mine::program
# set  ::mine::another_variable "some information"
namespace eval mine {
    set program "/usr/local/bin/configure_dut"
}

##
## End Sample External DUT Configuration
##

