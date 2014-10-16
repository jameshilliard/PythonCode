keylset global_config TrialDuration 5
keylset global_config AgingTime 1

keylset global_config ChassisName 192.168.11.99
keylset global_config LogsDir "/root/veriwave_cross_logs"
set chassis_addr [vw_keylget ::global_config ChassisName]
#catch {source [file join $env(HOME) "vw_licenses.tcl"]}
keylset global_config LicenseKey {mcdas-us41j-fqasd hcdaw-x611r-z960d hcdaw-nuj15-btuqx smda4-sg416-pqas6 smda4-pg419-qqas5 ncdar-ts41k-fqasd scdam-ys41f-fqasd}


keylset global_config Direction { Bidirectional }


# reverse direction
keylset global_config Source      { wireless_group_g }
keylset global_config Destination { ether_group_1 }
keylset global_config TestList { tcp_goodput }

keylset global_config NumTrials     1
keylset tcp_goodput Benchmark tcp_goodput
keylset tcp_goodput TcpWindowSize 65535
keylset tcp_goodput NumOfSessionPerClient 1
keylset tcp_goodput FrameSizeList { 1518 }

set wireless_group_g {
    { GroupType         802.11abg                       }
    { BssidIndex        2                               }
    { Ssid              "verizontest"                    }
    { Dut               dut1                            }
    { Method            { None }                        }
    { Channel           { 6 }                          }
    { NumClients        { 10 }                           }
    { Password		      whatever			}
    { Identity          anonymous                       }
    { AnonymousIdentity anonymous                       }
    { PskAscii          1234567890                        }
    { WepKey40Hex       1234567890                      }
    { ClientCertificate	$VW_TEST_ROOT/etc/cert-clt.pem  }
    { RootCertificate   $VW_TEST_ROOT/etc/root.pem      }
    { PrivateKeyFile    $VW_TEST_ROOT/etc/cert-clt.pem  }
    { WepKey128Hex      BADC0FFEE123456789CAFEFEED      }
    { EnableValidateCertificate     off                 }

    { Dhcp              Disable                         }

    { BaseIp            192.168.10.105    }
    { IncrIp            0.0.0.1         }
    { SubnetMask        255.255.255.0     }
    { Gateway           192.168.10.1      }
    { AssocProbe    { unicast }         }
    { AssocRate         2               }
    { AssocTimeout      20              }
    { MacAddressMode    Auto            }
    { KeepAlive		True		}
    { KeepAliveRate	20		}
    { GratuituousArp	True		}
}

set ether_group_1 {
    { GroupType         802.3               }
    { NumClients        { 4 }              }
    { Dut               dut11                }
    { Dhcp              Disable             }
    { Gateway           192.168.10.1	    }
    { BaseIp            192.168.10.151	    }
    { SubnetMask        255.255.255.0       }
	{ BehindNAT         False              }
    { IncrIp            0.0.0.1             }
}


keylset dut1 HardwareType                         generic
keylset dut1 Vendor                               generic
keylset dut1 APModel                              MI424e_208
keylset dut1 Interface.bg_radio.InterfaceType     802.11bg 
keylset dut1 Interface.bg_radio.WavetestPort      $chassis_addr:2:1

keylset dut11 HardwareType                         generic
keylset dut11 Vendor                               generic
keylset dut11 APModel                              MI424e_208
keylset dut11 Interface.ethernet.InterfaceType     802.3 
keylset dut11 Interface.ethernet.WavetestPort      $chassis_addr:1:1

keylset dut12 HardwareType                         generic
keylset dut12 Vendor                               generic
keylset dut12 APModel                              MI424e_208
keylset dut12 Interface.ethernet.InterfaceType     802.3 
keylset dut12 Interface.ethernet.WavetestPort      $chassis_addr:1:2

keylset dut13 HardwareType                         generic
keylset dut13 Vendor                               generic
keylset dut13 APModel                              MI424e_208
keylset dut13 PreGroupHook                         VerizonDUTHook
keylset dut13 Interface.ethernet.InterfaceType     802.3 
keylset dut13 Interface.ethernet.WavetestPort      $chassis_addr:1:3

keylset dut14 HardwareType                         generic
keylset dut14 Vendor                               generic
keylset dut14 APModel                              MI424e_208
keylset dut14 Interface.ethernet.InterfaceType     802.3 
keylset dut14 Interface.ethernet.WavetestPort      $chassis_addr:1:4

keylset wireless_group_g Method { WPA-PSK }

if {[info exists descr]} {
    keylset dut APSWVersion $descr
} else {
   keylset dut APSWVersion       "generic"
}