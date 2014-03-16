
#Configure Wireless and Ethernet Groups to be used in master test plan
#NOTE:
#1> Specify Multiple Security Types using 
#{ Method { None WEP-Open-40 WEP-SharedKey-128 } }
#This means in first iteration the wireless client group has no security,
#in second iteration the wireless client supports 'WEP-Open-40' type security,
#in third iteration the wireless client supports 'WEP-SharedKey-128' type security
#
#2>Specify Multiple a/b/g channels
#{ Channel { 1 2 3 } }
#This means that the b/g wireless client group will transmit on chaannel 1 for first iteration,
#on channel 2 in next iteration and on channel 3 on last iteration.
#
#3>Specify Multiple 'Number of Clients'
#{ NumClients { 10 50 } }
#This means that the group (wireless/ethernet) has 10 clients for first iterations and 50 for next iteration.
#
#4>Dhcp can be { Enable Disable }
#{ Dhcp { Enable Disable } }
#
#5>AssosProbe is 'probe before association' it can be off, unicast, bdcast(broadcast)
#{ AssosProbe { off unicast bdcast } }


# Group Configurations
set wireless_group_a {
    { GroupType         802.11abg                       }
    { BssidIndex        1                               }
    { Ssid              "veriwave_a"                    	 }
    { Dut               dut1     			 }
    { Method            { None  }   		 }
    { Channel           { 36 }                         }
    { NumClients        { 1 }                           }
    { Identity          anonymous                       }
    { Password          whatever                        }
    { AnonymousIdentity anonymous                       }
    { PskAscii          whatever                        }
    { WepKey40Hex       AAFEBABE01                      }
    { WepKey128Hex      BADC0FFEE123456789CAFEFEED      }
    { ClientCertificate          $VW_TEST_ROOT/etc/cert-clt.pem }
    { RootCertificate            $VW_TEST_ROOT/etc/root.pem     }
    { PrivateKeyFile             $VW_TEST_ROOT/etc/cert-clt.pem }
    { EnableValidateCertificate     off                 }

    { Dhcp              Disable         }

    { BaseIp            172.16.1.10   }
    { IncrIp            0.0.0.1         }
    { SubnetMask        255.255.0.0     }
    { Gateway           172.16.0.1 	}
    { AssocProbe        { unicast }     }
    { AssocRate         2               }
    { AssocTimeout      20              }
    { MacAddressMode    Auto            }
    { KeepAlive		True		}
    { KeepAliveRate	20		}
    { GratuitousArp	True		}
    { phyInterface    802.11ag    }
}
 
set wireless_group_g {
    { GroupType         802.11abg                       }
    { BssidIndex        2                               }
    { Ssid              "veriwave_g"                    }
    { Dut               dut1                            }
    { Method            { None }                        }
    { Channel           { 6  }                          }
    { NumClients        { 1 }                           }
    { Password		whatever			}
    { Identity          anonymous                       }
    { AnonymousIdentity anonymous                       }
    { PskAscii          whatever                        }
    { WepKey40Hex       1234567890                      }
    { ClientCertificate	$VW_TEST_ROOT/etc/cert-clt.pem  }
    { RootCertificate   $VW_TEST_ROOT/etc/root.pem      }
    { PrivateKeyFile    $VW_TEST_ROOT/etc/cert-clt.pem  }
    { WepKey128Hex      BADC0FFEE123456789CAFEFEED      }
    { EnableValidateCertificate     off                 }

    { Dhcp              Disable                         }

    { BaseIp            172.16.2.20     }
    { IncrIp            0.0.0.1         }
    { SubnetMask        255.255.0.0     }
    { Gateway           172.16.0.1      }
    { AssocProbe    { unicast }         }
    { AssocRate         2               }
    { AssocTimeout      20              }
    { MacAddressMode    Auto            }
    { KeepAlive		True		}
    { KeepAliveRate	20		}
    { GratuituousArp	True		}
    { phyInterface    802.11ag    }
}

set wireless_group_b {
    { GroupType         802.11abg                       }
    { BssidIndex        3                               }
    { Ssid              "veriwave_b"                    }
    { Dut               dut1                      }
    { Method            { None }                        }
    { Channel           { 6  }                          }
    { NumClients        { 1 }                           }

    { Identity          anonymous                       }
    { Password          whatever                        }
    { AnonymousIdentity anonymous                       }
    { PskAscii          whatever                        }
    { WepKey40Hex       AAFEBABE01                      }
    { WepKey128Hex      BADC0FFEE123456789CAFEFEED      }
    { EnableValidateCertificate     off                 }
    { ClientCertificate          $VW_TEST_ROOT/etc/cert-clt.pem }
    { RootCertificate            $VW_TEST_ROOT/etc/root.pem     }
    { PrivateKeyFile             $VW_TEST_ROOT/etc/cert-clt.pem }

    { Dhcp              Disable         }

    { BaseIp            172.16.3.30  	}
    { IncrIp            0.0.0.1         }
    { SubnetMask        255.255.0.0     }
    { Gateway           172.16.0.1     }
    { AssocProbe    { unicast }         }
    { AssocRate         2               }
    { AssocTimeout      20              }
    { MacAddressMode    Auto            }
    { KeepAlive		True		}
    { KeepAliveRate	20		}
    { GratuituousArp	True		}
    { phyInterface    802.11b    }
}

set wireless_group_n {
    { GroupType         802.11abgn                    }
    { BssidIndex        1                             }
    { Ssid              "veriwave_n"                  }
    { Dut               dut1     			      }
    { Method            { None  }   		          }
    { Channel           {6 }                          }
    { NumClients        { 1 }                         }
    { Identity          anonymous                     }
    { Password          whatever                      }
    { AnonymousIdentity anonymous                     }
    { PskAscii          whatever                      }
    { WepKey40Hex       AAFEBABE01                    }
    { WepKey128Hex      BADC0FFEE123456789CAFEFEED    }
    { ClientCertificate          $VW_TEST_ROOT/etc/cert-clt.pem }
    { RootCertificate            $VW_TEST_ROOT/etc/root.pem     }
    { PrivateKeyFile             $VW_TEST_ROOT/etc/cert-clt.pem }
    { EnableValidateCertificate     off                 }
    { Dhcp              Disable         }
    { BaseIp            172.16.4.10    }
    { Gateway           172.16.0.1   }
    { IncrIp            0.0.0.1         }
    { SubnetMask        255.255.0.0     }
    { AssocProbe        { unicast }     }
    { AssocRate         2               }
    { AssocTimeout      20              }
    { MacAddressMode    Auto            }
    { KeepAlive		    True	        }
    { KeepAliveRate	    20		        }
    { GratuitousArp	    True            }
    { EnableAMPDUaggregation False      }
    { DataMcsIndex      7               }
    { GuardInterval     standard        }
    { ChannelBandwidth  20              }
    { ChannelModel      Bypass          }
    { phyInterface    802.11n    }
}
set ether_group_1 {
    { GroupType         802.3               }
    { NumClients        { 1  }              }
    { Dut               dut1          }
    { Dhcp              Disable             }
    { Gateway           172.16.0.1	    }
    { BaseIp            172.16.100.10	    }
    { SubnetMask        255.255.0.0         }
    { IncrIp            0.0.0.1             }
    { Method            { None }	          }
}

set ether_group_2 {
    { GroupType         802.3               }
    { NumClients        { 1 }               }
    { Dut               dut1          }
    { Dhcp              Disable             }
    { Gateway           172.16.0.1          }
    { BaseIp            172.16.110.20       }
    { SubnetMask        255.255.0.0         }
    { IncrIp            0.0.0.1             }
    { Method            { None }	          }
}

# The following client groups are used for specific tests like STC024
set wireless_group_3 $wireless_group_g
keylset wireless_group_3 BaseIp 172.16.4.40

set wireless_group_4 $wireless_group_b
keylset wireless_group_3 BaseIp 172.16.5.50

set ether_group_3 $ether_group_1
keylset ether_group_3 BaseIp 172.16.101.10

set ether_group_4 $ether_group_2
keylset ether_group_3 BaseIp 172.16.111.20
