#### Input parameters for the TCP script ####

def testInputParameters():
    
    
    #### Chassis Name can be the hostname or IP address
    chassisName = "wt-tga-10-28"
    
    srcCardNum = 1
    srcPortNum = 1
    dstCardNum = 4
    dstPortNum = 1
    
    #### Num of TCP flows in the test...can be upto 80,000
    numFlowsInTest = 10   
    
    
    ##### Chassis Info ########################
    srcCardName = "Card " + str(srcCardNum)
    dstCardName = "Card " + str(dstCardNum)
    
    srcPortName = chassisName + "_card" + str(srcCardNum) + "_port" + str(srcPortNum)   
    dstPortName = chassisName + "_card" + str(dstCardNum) + "_port" + str(dstPortNum)    
    
    chassisStore = {chassisName: {
                                     srcCardName : {
                                                       srcPortName: {
                                                                             'BindStatus': 'True',
                                                                             'PortID': '1',
                                                                             'hiddenSSIDs': [''],
                                                                             'Duplex': 'full',
                                                                             'Autonegotiation': 'on',
                                                                             'CardMode': 'TGA',
                                                                             'Channel': 'N/A',
                                                                             'secChannel': '0',
                                                                             'CardID': '1',
                                                                             'PortName': srcPortName,
                                                                             'EthernetSpeed': '1000',
                                                                             'PortType': '8023'
                                                                             }
                                                  },
                                    dstCardName  : {
                                                       dstPortName: {
                                                                             'BindStatus': 'True',
                                                                             'PortID': '1',
                                                                             'hiddenSSIDs': [''],
                                                                             'Duplex': 'full',
                                                                             'Autonegotiation': 'on',
                                                                             'CardMode': 'TGA',
                                                                             'Channel': 'N/A',
                                                                             'secChannel': '0',
                                                                             'CardID': '4',
                                                                             'PortName': dstPortName,
                                                                             'EthernetSpeed': '1000',
                                                                             'PortType': '8023'
                                                                             }
                                              },
                                      }
                      }
    
    ##### Some Input parameters #########
    clientPort = srcPortName
    serverPort = dstPortName
    
     
    
    ##### Client Info ################################
    clientStore = {'Group_1': {
             
                                         'Enable': True,
                                         'Name': 'Group_1',
                                         'PortName': clientPort,
                                         'NumClients': numFlowsInTest,
                                         'Dhcp': 'Disable',
                                         'Interface': '802.3 Ethernet',
                                         'BaseIp': '192.168.1.10',
                                         'SubnetMask': '255.0.0.0',
                                         'Gateway': '192.168.1.1',             
                                         'MacAddressMode': 'Auto',
                                         'MacAddress': '',             
                                         'MacAddressIncr': 'Default',
                                         'VlanEnable': 'False',
                                         'VlanUserPriority': 0,
                                         'VlanId': 0,
                                         'BehindNat': 0,
                                       }
                         }
    
    ###### Server Info ###################################
    serverStore = {'server1': {
                                  'macAddress': '00:01:02:FA:61:F8',
                                  'ethPort': serverPort,
                                  'serverType': 0,
                                  'ipMode': '1',
                                  'netmask': '255.0.0.0',
                                  'macMode': '1',
                                  'ipAddress': '192.170.1.10',
                                  'gateway': '192.168.1.1',
                                  'vlan': {
                                           'enable': '0',
                                           'id': '0'
                                          }
                                }
                     }
    
    
    ############### Test Specific Parameters #################################
    testSpecificStore = { 'tcp_script': {
                                            'retryLimit': 0,
                                            'flowDir': 0,
                                            'flowRate': 1000,
                                            'conFlows': 5,
                                            'resFlows': 20,
                                            'srcPort': 8000,
                                            'resType': 1,
                                            'rxWinSize': 65535,
                                            'failedConn': 2,
                                            'flowDur': 167,
                                            'flowList': [{
                                                          'clientPort': clientPort,
                                                          'mapping': 'One-to-One',
                                                          'server': 'server1',
                                                          'groupName': 'Grp_Group_1_server1',
                                                          'netmask': '255.0.0.0',
                                                          'client': 'Group_1',
                                                          'gateway': '192.168.1.1',
                                                          'serverPort': serverPort,
                                                          'clientStartIp': '192.168.1.10',
                                                          'numFlows': numFlowsInTest,
                                                          'serverStartIp': '192.170.1.10'
                                                          }],
                                            'realTimeFlag': 1,
                                            'slaVal': 90,
                                            'dstPort': 80,
                                            'segSize': 1460
                                            }
                            }
    
    
    ##### Info to specify the path for saving the results  ##################
    testParamsStore = {
                       'LogsAndResultsInfo': {
                               'TestNameDir': 'False',
                               'LogsDir': 'C:\\Program Files\\VeriWave\\WaveScale\\Results',
                               'GeneratePdfReport': 'True',
                               'TimeStampDir': 'True'
                              },
                       'L4to7Connection': {
                              'ConnectionTimeout': 20,
                              'ConnectionRate': 20
                              },                   
                       'DutInfo': {
                              'APSWVersion': 'AP SW Version:@|#^&',
                              'WLANSwitchModel': 'WLAN Switch Model:@|#^&',
                              'WLANSwitchSWVersion': 'WLAN Switch SW Version:@|#^&',
                              'APModel': 'AP Model:@|#^&'
                              }
                   }

    

    return (chassisStore, {}, clientStore,{}, testParamsStore, testSpecificStore,{}, {},{},serverStore, {})

