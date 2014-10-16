#
# a sample Cisco 12xx "thick" access point configuration.
#
# $Id: cisco-ios-1200.tcl,v 1.2 2007/04/04 01:46:45 wpoxon Exp $
#

set arifs-cisco-1232 {
    { HardwareType        ap                  }
    { Vendor              cisco               }
    { APModel             cisco-1232          }
    { APSWVersion         IOS-12.3(11)JX      }
    { WLANSwitchModel     n/a                 }
    { WLANSwitchSWVersion n/a                 }
    { ConsoleAddr         192.168.10.245      }
    { ConsolePort         2035                }
    { ApUsername          Cisco               }
    { ApPassword          Cisco               }
    { AuthUsername        ""                  }
    { AuthPassword        Cisco               }
    { Ssid                veriwave            }
    { SsidBroadcast       true                }

        
    { RadiusServerAddr      10.10.250.1   }
    { RadiusServerSecret    nothing       }
    { RadiusServerAauthPort 1812          }
    { RadiusServerAcctPort  1813          }

    {
        Interface     {
            { Dot11Radio0 {
                { InterfaceType 802.11bg            }
                { Bssid         "00:15:c6:28:e0:f0" }
                { Power         1                   }
                { WavetestPort  192.168.10.246:9    }
                { AntennaRx     DIVERSITY           }
                { AntennaTx     DIVERSITY           }
            }}
            { BVI1 {
				{ InterfaceType 802.3				}
                { IpAddr        10.10.250.36        }
                { IpMask        255.255.255.0       }
                { Gateway       10.10.250.1         }
                { WavetestPort  192.168.10.246:1    }
            }}
        }
    }
}

set module_cvs_file    [cvs_clean "$RCSfile: cisco-ios-1200.tcl,v $"]
set module_cvs_version [cvs_clean "$Revision: 1.2 $"]
set module_cvs_date    [cvs_clean "$Date: 2007/04/04 01:46:45 $"]
set module_cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

set ::module_cfg_template_vers  "$module_cvs_file $module_cvs_version $module_cvs_date $module_cvs_release"


