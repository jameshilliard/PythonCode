#
# 3Com xx60 thick access points
#
# supported APModel's:
#
#   ap8760  (stand-alone thick AP)
#
# $Id: 3Com-8760-thick.tcl,v 1.2 2007/04/04 01:46:45 wpoxon Exp $
#


#
# Supported Security methods:
#
#   None WEP
#   None WEP-Open-40 WEP-SharedKey-40 WEP-Open-128 WEP-SharedKey-128
#   WPA-EAP-TLS WPA2-EAP-TLS WPA-PSK WPA2-PSK
#   DWEP-EAP-TTLS-GTC DWEP-EAP-TLS
#   DWEP-PEAP-MSCHAPV2 WPA-EAP-TTLS-GTC WPA-PEAP-MSCHAPV2
#   WPA2-PEAP-MSCHAPV2 WPA2-EAP-TTLS-GTC
#
# Valid Values for Parameters for this AP:
#
#   Antenna             { left, right, diversity }
#   Power               { full, half, quarter, eighth, min }
#   BeaconPeriod        { 20-1000 } (milliseconds)
#   Preamble            { long | short-or-long }
#
#   Logging             { on | off }
#   LoggingHost         hostname or IP address of syslog server to log to
#                       or 'none' to log locally to AP console
#   LoggingLevel        { Emergency | Alert | Critical | Error | Warning | Notice | Informational | Debug }
#   LoggingFacility     <type> where <type> is the facililty number in the range 16-23
#                       which is used by the syslog server to dispatch syslog msgs to the appropriate service
#   LoggingClear        { on | off } if on, clear all log messages stored in the AP's memory
#                       before we begin running a new test
#   ShowEventLog        { on | off } if on, display contents of the AP's event before we clear it
#   SntpServer          { <ip_addr> | none | off } sets the address of the NTP server to use to <ip_addr>
#                           makes no sntp config changes if 'none' is specified
#                           disables sntp client requests from the AP if 'off' is specified
#   SntpTimezone        { -12 to +12 | none }
#
#
set sample-3com-thick-8760-ap {
    { HardwareType      thick-ap            }
    { Vendor            3Com                }
    { APModel           thick-ap8760        }
    { APSWVersion       v2.1.13_sh          }
    { WLANSwitchModel   "none"              }
    { WLANSwitchSWVersion "none"            }
    { ConsoleAddr       10.10.250.15        }
    { ConsolePort       23                  }
    { ApUsername        "admin"             }
    { ApPassword        "password"          }
    { SsidBroadcast     enable              }
    
    { Logging           on                  }
    { LoggingHost       none                }
    { LoggingLevel      Debug               }
    { LoggingFacility   16                  }
    { LoggingClear      on                  }
    { ShowEventLog      on                  }
    
    { SntpServer        10.10.251.1         }
    { SntpTimezone      -5                  }
    
    { RadiusServerAddr      10.10.251.1     }
    { RadiusServerSecret    whatever        }
    { RadiusServerAuthPort  1812            }
    { RadiusServerAcctPort  1813            }
    { RadiusServerNumRetransmits    10      }
    { RadiusServerTimeout           30      }
    

    
    { ApMacAddr             00:18:6e:10:7c:00                   }
    { ApKeyType             hex                                 }
    { ApSecureKey           31313131303031313232343436363838    }

    { CountryCode         us                      }
    { PskAscii            whatever                }          
        
    {
        Interface     {
            { wireless_g {
                { InterfaceType     802.11bg            }
                { WavetestPort      192.168.10.249:7    }
                { Power             min                 }
                { Antenna           diversity           }
                { BeaconPeriod      150                 }
                { Preamble          short-or-long       }
            }}
            { wireless_a {
                { InterfaceType     802.11a             }
                { WavetestPort      192.168.10.249:7    }
                { Power             min                 }
                { Antenna           diversity           }
            }}
            { ethernet {
                { InterfaceType     802.3               }
                { IpAddr            10.10.250.14        }
                { IpMask            255.255.0.0         }
                { Gateway           10.10.251.1         }
                { WavetestPort      192.168.10.249:1    }
            }}
        }
    }
}

set module_cvs_file    [cvs_clean "$RCSfile: 3Com-8760-thick.tcl,v $"]
set module_cvs_version [cvs_clean "$Revision: 1.2 $"]
set module_cvs_date    [cvs_clean "$Date: 2007/04/04 01:46:45 $"]
set module_cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

set ::module_cfg_template_vers  "$module_cvs_file $module_cvs_version $module_cvs_date $module_cvs_release"
