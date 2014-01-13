#
# an example config for a Foundry IronPoint 200.
#
# $Id: foundry-ip-200.tcl,v 1.2 2007/04/04 01:46:45 wpoxon Exp $
#

set sample-foundry-ap {
    { HardwareType      ap                  }
    { Vendor            foundry             }
    { APModel           ironpoint-200       }
    { ConsoleAddr       10.10.250.5         }
    { ConsolePort       23                  }
    { ApUsername        "admin"             }
    { ApPassword        "admin"             }
    { AuthUsername      ""                  }
    { AuthPassword      ""                  }
    { SsidBroadcast     true                }
    { SVP               disable             }

    { RadiusServerAddr      10.10.251.1     }
    { RadiusServerSecret    whatever        }
    { RadiusServerAuthPort  1812            }
    { RadiusServerAcctPort  1813            }
        
    {
        Interface     {
            { wireless_g {
                { InterfaceType     802.11bg            }
                { WavetestPort      192.168.10.246:8    }
                { Power             auto                }
                { AntennaDiversity  full                }
            }}
            { wireless_a {
                { InterfaceType     802.11a             }
                { WavetestPort      192.168.10.246:8    }
                { Power             auto                }
                { AntennaDiversity  full                }
            }}
            { ethernet {
                { InterfaceType     802.3               }
                { IpAddr            10.10.250.5         }
                { IpMask            255.255.0.0         }
                { Gateway           10.10.251.1         }
                { WavetestPort      192.168.10.246:6    }
            }}
        }
    }
}
  
set sample-foundry-ap2 {
    { HardwareType      ap                  }
    { Vendor            foundry             }
    { APModel           ironpoint-200       }
    { ConsoleAddr       10.10.250.5         }
    { ConsolePort       23                  }
    { ApUsername        "admin"             }
    { ApPassword        "admin"             }
    { AuthUsername      ""                  }
    { AuthPassword      ""                  }
    { SsidBroadcast    true                 }
    
    { AuxChannel       48                   }

    { RadiusServerAddr      10.10.251.1     }
    { RadiusServerSecret    whatever        }
    { RadiusServerAuthPort  1812            }
    { RadiusServerAcctPort  1813            }
        
    {
        Interface     {
            { wireless_g {
                { InterfaceType     802.11bg            }
                { WavetestPort      192.168.10.246:8    }
                { Power             auto                }
                { AntennaDiversity  full                }
            }}
            { wireless_a {
                { InterfaceType     802.11a             }
                { WavetestPort      192.168.10.246:8    }
                { Power             auto                }
                { AntennaDiversity  full                }
            }}
            { ethernet {
                { InterfaceType     802.3               }
                { IpAddr            10.10.250.5         }
                { IpMask            255.255.0.0         }
                { Gateway           10.10.251.1         }
                { WavetestPort      192.168.10.246:6    }
            }}
        }
    }
}


set module_cvs_file    [cvs_clean "$RCSfile: foundry-ip-200.tcl,v $"]
set module_cvs_version [cvs_clean "$Revision: 1.2 $"]
set module_cvs_date    [cvs_clean "$Date: 2007/04/04 01:46:45 $"]
set module_cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

set ::module_cfg_template_vers  "$module_cvs_file $module_cvs_version $module_cvs_date $module_cvs_release"


