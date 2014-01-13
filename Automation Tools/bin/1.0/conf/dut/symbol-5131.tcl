#
# A sample config for a Symbol 5131 AP
#
# $Id: symbol-5131.tcl,v 1.2 2007/04/04 01:46:45 wpoxon Exp $
#

set sample-symbol-ap {
    { HardwareType        ap                  }
    { Vendor              symbol              }
    { APModel             ap-5131             }
    { ApSwVersion         "1.1.0.0-045R"      }
    { WlanSwitchModel     n/a                 }
    { WlanSwitchSwVersion n/a                 }
    { ConsoleAddr         10.10.250.9         }
    { ConsolePort         23                  }
    { ApUsername          "admin"             }
    { ApPassword          "veriwave"          }
    { AuthUsername        ""                  }
    { AuthPassword        ""                  }
    { Ssid                vw-symbol           }
    { SsidBroadcast       enable              }

    { RadiusServerAddr     10.10.250.1    }
    { RadiusServerSecret   whomever       }
    { RadiusServerAuthPort 1812           }
    { RadiusServerAcctPort 1813           }

    {
        Interface     {
            { radio1 {
                { RadioType        bg                  }
                { WavetestPort     192.168.10.246:2    }
                { Power            5                   }
                { AntennaDiversity full                }
 
            }}
            { radio2 {
                { RadioType        a                   }
                { WavetestPort     192.168.10.246:2    }
                { Power            5                   }
                { AntennaDiversity full                }
            }}
            { lan {
                { IpAddr       10.10.250.9             }
                { IpMask       255.255.255.0           }
                { Gateway      10.10.250.1             }
                { WavetestPort 192.168.10.246:1        }
            }}
        }
    }
}

set module_cvs_file    [cvs_clean "$RCSfile: symbol-5131.tcl,v $"]
set module_cvs_version [cvs_clean "$Revision: 1.2 $"]
set module_cvs_date    [cvs_clean "$Date: 2007/04/04 01:46:45 $"]
set module_cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

set ::module_cfg_template_vers  "$module_cvs_file $module_cvs_version $module_cvs_date $module_cvs_release"

