keylset global_config TrialDuration 5
keylset global_config AgingTime 1

keylset global_config ChassisName 192.168.1.99
keylset global_config LogsDir "/root/veriwave_cross_logs"

#catch {source [file join $env(HOME) "vw_licenses.tcl"]}
keylset global_config LicenseKey {mcdas-us41j-fqasd hcdaw-x611r-z960d hcdaw-nuj15-btuqx smda4-sg416-pqas6 smda4-pg419-qqas5 ncdar-ts41k-fqasd scdam-ys41f-fqasd}

keylset global_config NumTrials     1

keylset global_config TestList { unicast_throughput }

set wireless_group_g {
    { GroupType         802.11abg                       }
    { BssidIndex        2                               }
    { Ssid              "verizontest"                   }
    { Dut               dut1                            }
    { Method            { None }                        }
    { Channel           { 6 }                      }
    { NumClients        { 10 }                          }
    { Password		    whatever			}
    { Identity          anonymous                       }
    { AnonymousIdentity anonymous                       }
    { PskAscii          1234567890                      }
    { WepKey40Hex       1234567890                      }
    { ClientCertificate	$VW_TEST_ROOT/etc/cert-clt.pem  }
    { RootCertificate   $VW_TEST_ROOT/etc/root.pem      }
    { PrivateKeyFile    $VW_TEST_ROOT/etc/cert-clt.pem  }
    { WepKey128Hex      BADC0FFEE123456789CAFEFEED      }
    { EnableValidateCertificate     off                 }
    { Dhcp              Disable                         }
    { BaseIp            192.168.1.105  }
    { IncrIp            0.0.0.1         }
    { SubnetMask        255.255.255.0   }
    { Gateway           192.168.1.1    }
    { AssocProbe    { unicast }         }
    { AssocRate         2               }
    { AssocTimeout      20              }
    { MacAddressMode    Auto            }
    { KeepAlive		    True	        }
    { KeepAliveRate	20                  }
    { GratuituousArp	True            }
}

set ether_group_1 {
    { GroupType         802.3               }
    { NumClients        { 10 }               }
    { Dut               dut11               }
    { Dhcp              Disable             }
    { Gateway           192.168.1.1	    }
    { BaseIp            192.168.1.151	    }
    { SubnetMask        255.255.255.0       }
	{ BehindNAT         False               }
    { IncrIp            0.0.0.1             }
}

set ether_group_2 {
    { GroupType         802.3               }
    { NumClients        { 10 }               }
    { Dut               dut12                }
    { Dhcp              Disable             }
    { Gateway           200.200.200.2       }
    { BaseIp            200.200.200.100      }
    { SubnetMask        255.255.255.0         }
	{ BehindNAT         False               }
    { IncrIp            0.0.0.1             }
}

set ether_group_3 {
    { GroupType         802.3               }
    { NumClients        { 10 }              }
    { Dut               dut13                }
    { Dhcp              Disable             }
    { Gateway           192.168.1.1	    }
    { BaseIp            192.168.1.231	    }
    { SubnetMask        255.255.255.0         }
	{ BehindNAT         False               }
    { IncrIp            0.0.0.1             }
}

set ether_group_4 {
    { GroupType         802.3               }
    { NumClients        { 10 }               }
    { Dut               dut14               }
    { Dhcp              Disable             }
    { Gateway           47.19.10.2        }
    { BaseIp            47.19.10.10     }
    { SubnetMask        255.0.0.0         }
	{ BehindNAT         False               }
    { IncrIp            0.0.0.1             }
}

set chassis_addr [vw_keylget ::global_config ChassisName]

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
keylset dut13 Interface.ethernet.InterfaceType     802.3 
keylset dut13 Interface.ethernet.WavetestPort      $chassis_addr:1:3

keylset dut14 HardwareType                         generic
keylset dut14 Vendor                               generic
keylset dut14 APModel                              MI424e_208
keylset dut14 Interface.ethernet.InterfaceType     802.3 
keylset dut14 Interface.ethernet.WavetestPort      $chassis_addr:1:4

keylset unicast_throughput Benchmark unicast_unidirectional_throughput
keylset unicast_throughput Frame Standard
keylset unicast_throughput FrameSizeList { 64 128 256 512 1024 1400 1518 }
keylset unicast_throughput SearchResolution 10
keylset unicast_throughput Mode Fps
keylset unicast_throughput MinSearchValue Default
keylset unicast_throughput MaxSearchValue Default
keylset unicast_throughput StartValue Default

#keylset wireless_group_a NumClients $NumClients
#keylset wireless_group_g NumClients $NumClients
#keylset wireless_group_b NumClients $NumClients
#keylset ether_group_1 NumClients { 1 }
#keylset ether_group_2 NumClients { 1 }

#keylset wireless_group_a Method { None WPA-PSK WPA2-PSK }
keylset wireless_group_g Method { WPA2-PSK }
#keylset wireless_group_b Method { None WPA-PSK WPA2-PSK }

#keylset test_throughput Benchmark unicast_unidirectional_throughput
#keylset test_throughput Frame Standard
#keylset test_throughput FrameSizeList { 64 128 256 512 1024 1400 1518 }

if {[info exists descr]} {
    keylset dut APSWVersion $descr
} else {
   keylset dut APSWVersion       "generic"
}

keylset global_config Direction { Bidirectional }
keylset global_config Source      { ether_group_3 }
keylset global_config Destination { ether_group_4 }
