#
# A sample config for a Symbol AP-300 connected to a WS-5100 WLAN switch
#
# $Id: symbol-300.tcl,v 1.2 2007/04/04 01:46:45 wpoxon Exp $
#
set sample-symbol-thin-ap {
    { HardwareType        thin-ap             }
    { Vendor              symbol              }
    { APModel             ap-300              }
    { ApSwVersion         Unknown             }
    { WlanSwitchModel     ws5100              }
    { WlanSwitchSwVersion 3.0.0.0-260R        }
    { ConsoleAddr         10.10.250.11        }
    { ConsolePort         23                  }
    { ApUsername          admin               }
    { ApPassword          superuser           }
    { AuthPassword        ""                  }
    { Ssid                symbol-300          }
    { SsidBroadcast       enable              }
    { ApMacAddr           00:A0:F8:CE:5E:C6   }

    { RadiusServerAddr     10.10.251.1    }
    { RadiusServerSecret   whatever       }
    { RadiusServerAuthPort 1812           }
    { RadiusServerAcctPort 1813           }

    {
        Interface     {
            { 11bg {
                { RadioType        bg                  }
                { WlanIdx          1                   }
                { RadioIdx         1                   }
                { WavetestPort     192.168.10.246:8    }
                { Power            17                  }
                { AntennaDiversity diversity           }
 
            }}
            { 11a {
                { RadioType        a                   }
                { WlanIdx          1                   }
                { RadioIdx         1                   }
                { WavetestPort     192.168.10.246:8    }
                { Power            17                  }
                { AntennaDiversity diversity           }
            }}
            { lan {
                { WavetestPort     192.168.10.246:6    }
            }}
        }
    }
}

set module_cvs_file    [cvs_clean "$RCSfile: symbol-300.tcl,v $"]
set module_cvs_version [cvs_clean "$Revision: 1.2 $"]
set module_cvs_date    [cvs_clean "$Date: 2007/04/04 01:46:45 $"]
set module_cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

set ::module_cfg_template_vers  "$module_cvs_file $module_cvs_version $module_cvs_date $module_cvs_release"


