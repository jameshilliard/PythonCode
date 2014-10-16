#
# 3Com-3750.tcl  - sample WaveAutomation configuration file template
#	for 3Com 3750 DUT.
#
# To use this file, make a copy of it, edit the copy with your settings,
# and then source that new file from your main configuration file.
#
# VeriWave customers may edit this file to control the automated execution of
# the VeriWave applications.
#
# $Id: 3Com-3750.tcl,v 1.2 2007/04/04 01:46:45 wpoxon Exp $
#

#
# A sample config for a 3Com ap3750 connected to a wrx-100 WLAN switch
#
# supported APModel's:
#
#   ap3750  (with wrx-100 controller)
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

set sample-3com-ap-3750 {
    { HardwareType      thin-ap             }
    { Vendor            3Com                }
    { APModel           ap3750              }
    { ConsoleAddr       10.10.250.12        }
    { ConsolePort       23                  }
    { ApUsername        "admin"             }
    { ApPassword        "optional"          }
    { AuthPassword      "optional"          }
    { SsidBroadcast     enable              }

    { RadiusServerAddr      10.10.251.1     }
    { RadiusServerSecret    whatever        }
    { RadiusServerAuthPort  1812            }
    { RadiusServerAcctPort  1813            }

    { ApMacAddr           00:14:7c:a0:d0:80       }
    { ApSerialNumber      MQRE7CEA0D080           }
    { ApNumber            2                       }
    { CountryCode         us                      }
    { RadioProfile        veriwave                }
    { Antenna             Internal                }

    {
        Interface     {
            { 11g {
                { InterfaceType     802.11bg            }
                { WavetestPort      192.168.10.246:9    }
                { Power             4                   }
                { AntennaDiversity  full                }
            }}
            { 11a {
                { InterfaceType     802.11a             }
                { WavetestPort      192.168.10.246:9    }
                { Power             4                   }
                { AntennaDiversity  full                }
            }}
            { lan {
                { InterfaceType     802.3               }
                { IpAddr            10.10.250.5         }
                { IpMask            255.255.0.0         }
                { Gateway           10.10.251.1         }
                { WavetestPort      192.168.10.246:6    }
            }}
        }
    }
}

set module_cvs_file    [cvs_clean "$RCSfile: 3Com-3750.tcl,v $"]
set module_cvs_version [cvs_clean "$Revision: 1.2 $"]
set module_cvs_date    [cvs_clean "$Date: 2007/04/04 01:46:45 $"]
set module_cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

set ::module_cfg_template_vers  "$module_cvs_file $module_cvs_version $module_cvs_date $module_cvs_release"


