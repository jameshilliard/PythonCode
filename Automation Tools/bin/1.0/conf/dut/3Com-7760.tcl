#
# 3Com-7760.tcl  - sample WaveAutomation configuration file template
#	for 3Com 7760 DUT.
#
# To use this file, make a copy of it, edit the copy with your settings,
# and then source that new file from your main configuration file.
#
# VeriWave customers may edit this file to control the automated execution of
# the VeriWave applications.
#
# $Id: 3Com-7760.tcl,v 1.2 2007/04/04 01:46:45 wpoxon Exp $
#

#
# A sample config for a 3Com ap7760 connected to a wlc-2475 WLAN switch
#
# supported APModel's:
#
#   ap7760  (with wlc-2475 controller)
#
#
# Supported Security methods:
#
#   None WEP
#   None WEP-Open-40 WEP-SharedKey-40 WEP-Open-128 WEP-SharedKey-128
#   WPA-PSK WPA2-PSK
#   WPA-EAP-TLS WPA2-EAP-TLS 
#   DWEP-EAP-TTLS-GTC DWEP-EAP-TLS
#   DWEP-PEAP-MSCHAPV2 WPA-EAP-TTLS-GTC WPA-PEAP-MSCHAPV2
#   WPA2-PEAP-MSCHAPV2 WPA2-EAP-TTLS-GTC
#

set sample-3com-7760-ap {
    { HardwareType      thin-ap             }
    { Vendor            3Com                }
    { APModel           ap7760              }
    { APSWVersion       us24_01_01_14_sh    }
    { WLANSwitchModel   wlc-2475            }
    { WLANSwitchSWVersion "us24_01_01_14_sh" }
    { ConsoleAddr       10.10.250.14        }
    { ConsolePort       23                  }
    { ApUsername        "user1"             }
    { ApPassword        "user1"             }
    { AuthPassword      "veriwave"          }
    { SsidBroadcast     enable              }

    { RadiusServerAddr      10.10.251.1     }
    { RadiusServerSecret    whatever        }
    { RadiusServerAuthPort  1812            }
    { RadiusServerAcctPort  1813            }
    { RadiusServerNumRetransmits    3       }
    { RadiusServerTimeout           10      }

    { Ssid                  "3Com-7760"                         }
    
    { ApMacAddr             00:16:e0:01:53:80                   }
    { ApKeyType             hex                                 }
    { ApSecureKey           31313131303031313232343436363838    }

    { CountryCode         us                      }
    { PskAscii            whatever                }          
        
    {
        Interface     {
            { wireless_g {
                { InterfaceType     802.11bg            }
                { WavetestPort      192.168.10.246:7    }
                { Power             min                 }
                { Antenna           diversity           }
                { BeaconPeriod      150                 }
                { Preamble          short               }
            }}
            { wireless_a {
                { InterfaceType     802.11a             }
                { WavetestPort      192.168.10.246:7    }
                { Power             min                 }
                { Antenna           diversity           }
            }}
            { ethernet {
                { InterfaceType     802.3               }
                { IpAddr            10.10.250.14        }
                { IpMask            255.255.0.0         }
                { Gateway           10.10.251.1         }
                { WavetestPort      192.168.10.246:1    }
            }}
        }
    }
}

set module_cvs_file    [cvs_clean "$RCSfile: 3Com-7760.tcl,v $"]
set module_cvs_version [cvs_clean "$Revision: 1.2 $"]
set module_cvs_date    [cvs_clean "$Date: 2007/04/04 01:46:45 $"]
set module_cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

set ::module_cfg_template_vers  "$module_cvs_file $module_cvs_version $module_cvs_date $module_cvs_release"



