#
# A sample configuration for a Cisco LWAPP AP
#
# Note that the console info, usernames and password are for the WLC
# and not the AP.
#
# $Id: cisco-1020.tcl,v 1.2 2007/04/04 01:46:45 wpoxon Exp $
#

set sample-cisco-1020 {
    { HardwareType      lap                 }
    { Vendor            cisco               }
    { APModel           lap-cisco-1020      }
    { ApName            ap:26:a1:80         }
    { ApMacAddr         00:0b:85:26:a1:80   }
    { ApCertType        mic                 }
    { ApSwVersion       IOS-12.3(7)JX       }
        
    { ConsoleAddr       192.168.10.245      }
    { ConsolePort       2040                }
    { ApUsername        "admin"             }
    { ApPassword        "admin"             }
    { SsidBroadcast     true                }

    { RadiusServerAddr      10.10.251.1     }
    { RadiusServerSecret    whatever        }
    { RadiusServerAuthPort  1812            }
    { RadiusServerAcctPort  1813            }
        
    {
        Interface     {
            { 802_11b {
                { InterfaceType     802.11bg            }
                { WavetestPort      192.168.10.249:5    }
                { Power             1                   }
                { AntennaDiversity  enable              }
            }}
            { 802_11a {
                { InterfaceType     802.11a             }
                { WavetestPort      192.168.10.249:5    }
                { Power             1                   }
                { AntennaDiversity  enable              }
            }}
            { 802_3 {
                { InterfaceType     802.3               }
                { IpAddr            10.10.250.6         }
                { IpMask            255.255.0.0         }
                { Gateway           10.10.251.1         }
                { WavetestPort      192.168.10.249:1    }
            }}
        }
    }
}


set module_cvs_file    [cvs_clean "$RCSfile: cisco-1020.tcl,v $"]
set module_cvs_version [cvs_clean "$Revision: 1.2 $"]
set module_cvs_date    [cvs_clean "$Date: 2007/04/04 01:46:45 $"]
set module_cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

set ::module_cfg_template_vers  "$module_cvs_file $module_cvs_version $module_cvs_date $module_cvs_release"

