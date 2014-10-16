#
# A sample config for a 3Com ap2750 connected to a WXR100 WLAN switch
#
# Valid 3Com ApModel values:
#     ap2750
#
# Other 3Com AP Models (not yet tested): ap3750, ap7250, ap8250, ap8750,
#     mp-52, mp-241, mp-252, mp-262, mp-341, mp-352, mp-620,
#     mp-372, mp-372-CN, mp-372-JP
#
# ApType should be set to
#     map - for Managed Access Points (MAPs) physically cabled to the WX switch
#     dap - for distributed MAPs which are reachable via L2/L3 networks
#
# $Id: 3Com-2750.tcl,v 1.2 2007/04/04 01:46:45 wpoxon Exp $
#

set sample-3com-2750-ap {
    { HardwareType        thin-ap               }
    { Vendor              3Com                  }
    { APModel             ap2750                }
    { ApType              dap                   }
    { ApSwVersion         4.2.3.2.0_080106_1558 }
    { WlanSwitchModel     wxr100                }
    { WlanSwitchSwVersion 4.2.3.2REL            }
    { ConsoleAddr         10.10.250.12          }
    { ConsolePort         23                    }
    { ApUsername          "admin"               }
    { ApPassword          "optional"            }
    { AuthPassword        "optional"            }
    { SsidBroadcast       enable                }

    { RadiusServerAddr      10.10.251.1     }
    { RadiusServerSecret    whatever        }
    { RadiusServerAuthPort  1812            }
    { RadiusServerAcctPort  1813            }
        
    { ApMacAddr           00:A0:F8:CE:5E:C6       }
    { ApSerialNumber      L9DQ4NBC2A400           }
    { ApNumber            1                       }
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


set module_cvs_file    [cvs_clean "$RCSfile: 3Com-2750.tcl,v $"]
set module_cvs_version [cvs_clean "$Revision: 1.2 $"]
set module_cvs_date    [cvs_clean "$Date: 2007/04/04 01:46:45 $"]
set module_cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

set ::module_cfg_template_vers  "$module_cvs_file $module_cvs_version $module_cvs_date $module_cvs_release"

