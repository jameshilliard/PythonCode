
#
# description of the attributes of the wt0-ap0 DUT
#
# $Id: wt0-ap0.tcl,v 1.3 2006/04/25 18:53:03 manderson Exp $
#

set wt0-ap0 {
    { TYPE              ap                  }
    { VENDOR            cisco               }
    { MODEL             cisco-1200          }
    { CONSOLE_ADDR      10.10.250.37        }
    { CONSOLE_PORT      23                  }
    { USERNAME          Cisco               }
    { PASSWORD          Cisco               }
    { AUTH_USERNAME     ""                  }
    { AUTH_PASSWORD     Cisco               }
    {
        INTERFACE     {
            { Dot11Radio0 {
                { BSSID         "00:15:c6:28:e0:f0" }
                { SSID          veriwave2           }
                { WAVETEST_PORT 8                   }
            }}
            { BVI1 {
                { IP_ADDR       10.10.250.37    }
                { IP_MASK       255.255.255.255 }
                { WAVETEST_PORT 6               }
            }}
        }
    }
}

