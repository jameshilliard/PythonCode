#Imports

from vcl import *
from basetest import *
import Qlib
import WaveEngine as WE
from CommonFunctions import *
from qos_common import *
from optparse import OptionParser
from socket import inet_ntoa
import struct
from odict import *

import time
import math
import os
import os.path
import sched
import traceback
import copy
import thread
from optparse import OptionParser

#Graph libraries
from reportlab.graphics.charts.axes import XValueAxis
from reportlab.graphics.shapes import Drawing, Line, String, Rect, STATE_DEFAULTS
from reportlab.graphics.charts.linecharts import HorizontalLineChart
from reportlab.graphics.charts.linecharts import makeMarker
from reportlab.graphics import renderPDF
from reportlab.graphics.charts.barcharts import VerticalBarChart
from reportlab.lib import colors
from reportlab.graphics.charts.legends import Legend, LineLegend
#from reportlab.graphics.charts.textlabels import label

################################### Constants ##################################
_TosPrecBit = 5
_TosFieldDelayBit = 4
_TosFieldThroughputBit = 3
_TosFieldReliabilityBit = 2
_TosFieldMonetaryBit = 1
_TosFieldReservedBit = 0

class Test(QosCommon, BaseTest):
    
    def __init__(self):
        BaseTest.__init__(self)
        
        self.testParameters = odict.OrderedDict()

        self.CSVfilename      = 'Results_qos_capacity.csv'
        self.ReportFilename   = 'Report_qos_capacity.pdf' 
        self.DetailedFilename = 'Detailed_Results_qos_capacity.csv'  
        self.RSSIFilename = 'RSSI_qos_capacity.csv'
        
        self.trialDuration  = 5
        self.settleTime = 2
        self.numCallsPerAP  = 1
        
        self.UserPassFailCriteria = {}
        self.UserPassFailCriteria['user']='False'
        self.FinalResult=0
        self.testParameters['Trial Duration (secs)'] = self.trialDuration
        self.testParameters['Settle Time (secs)'] = self.settleTime
        
        self.CardMap = { 'WT90_E1': ( 'wt-tga-xx-xx', 1, 0, 'on', 100, 'full' ),
                         'WT90_W1': ( 'wt-tga-xx-xx', 9, 0,  6 )
                       }

        self.CardList = ['WT90_E1' , 'WT90_W1']
        self.wifiCardList = ['WT90_W1']
        self.ethCardList =  ['WT90_E1']
       
        self.Security_None = {'Method': 'NONE'}  
        self.Security_WPA2 = {'Method': 'WPA2-EAP-TLS', 
        'Identity': 'anonymous', 'Password' : 'whatever'}
        
                  
        self.NetworkList = {
                           'Cisco': {'ssid': 'cisco',
                           'bssid' : '00:12:7f:47:e1:c0',
                           'security': self.Security_None}, 
                           'Symbol': {'ssid': 'OPEN',
                           'bssid' : '00:15:70:00:82:b0',
                           'security': self.Security_None},
                           }

        self.ARPRate           =  10.0
        self.ARPRetries        =   3
        self.ARPTimeout        =  10.0

        self.BSSIDscanTime    = 1.5
        self.AssociateRate    = 10
        self.AssociateTimeout = 10 
        self.AssociateRetries = 0
        self.acceptablePerPacketLoss = 20
        self.acceptableAvgLatency = 30
       
        self.CSVfilename      = 'Results_qos_capacity.csv'
        self.ReportFilename   = 'Report_qos_capacity.pdf'
        self.LoggingDirectory = "logs"
        self.SavePCAPfile     = False
        
        self.ClientgrpFlows = {}
        self.PortStats = {}
        self.FlowList = odict.OrderedDict()
        self.bgFlowList = odict.OrderedDict()
        

        self.MainFlowList = {
                            'Flow1': {'Type'         : 'RTP', 
                                      'Framesize'    : 256,
                                      'Phyrate'      : 54, 
                                      'Ratemode'     : 'pps',
                                      'Intendedrate' : 30, 
                                      'Numframes'    : WE.MAXtxFrames,
                                      'UserPriority' : 7,
                                      'TosField'     : 0,
                                      'Protocol'     : 119,
                                      'SrcPort'      : 5004,
                                      'DestPort'     : 5005,
                                      'Codec'        : 'G.711',
                                      'flowType'     : 'mainFlow',
                                      'DscpMode'     : 'off'
                                      },
                                      
                             'Flow2': {'Type'        : 'RTP', 
                                      'Framesize'    : 1500,
                                      'Phyrate'      : 54, 
                                      'Ratemode'     : 'pps',
                                      'Intendedrate' : 100, 
                                      'Numframes'    : WE.MAXtxFrames,
                                      'UserPriority' : 5,
                                      'TosField'     : 0,
                                      'Protocol'     : 17,
                                      'SrcPort'      : 0,
                                      'DestPort'     : 0,
                                      'flowType'     : 'bkFlow',
                                      'DscpMode'     : 'off'
                                      },
                               }

        self.ClientGroups = {
                            'Group_1': {'Enable'     : True,
                                       'bssid'      : '00:15:70:00:82:b0',
                                       'StartMAC'   : 'AUTO',
                                       'MACIncrMode': 'Auto',
                                       'MacAddressMode': 'Auto',
                                       'MACStep'    : 'Default',
                                       'StartIP'    : '192.168.1.10', 
                                       'IPStep'     : '0.0.0.1',
                                       'Port'       : 'WT90_W1',
                                       'Gateway'    : '192.168.1.1',
                                       'SubMask'    : '255.255.0.0',
                                       'NumClients' : 1,
                                       'clientCount': 'Variable',
                                       'Security'   : 'None',
                                       'Identity'   : 'anonymous',
                                       'AnonymousIdentity': 'anonymous',
                                       'Password'   : 'whatever',
                                       'NetworkAuthMethod': 'None',
                                       'ClientCertificate': '',
                                       'EnableValidateCertificate': 'off',
                                       'PrivateKeyFile': '',
                                       'KeyId'      : '1',
                                       'KeyType'    : 'ascii',
                                       'KeyWidth'   : '',
                                       'NetworkKey' : '',
                                       'RootCertificate': '',
                                       'EncryptionMethod': 'None',
                                       'Method'     : 'None',
                                       'ApAuthMethod': 'Open',
                                       'MainFlow'  : 'Flow1',
                                       'QosEnabled': 'on',
                                       'VlanEnable': False,
                                       'vlanId'    : 'None', 
                                       'DataPhyRate': '54',
                                       'Dhcp'      : 'Disable'
                                       },
                                       
                            'Group_2': {'Enable'    : True,
                                       'StartMAC'  : 'AUTO',
                                       'MACIncrMode': 'Auto',
                                       'MacAddressMode': 'Auto',
                                       'MACStep'    : 'Default',                                       
                                       'StartIP'   : '192.168.1.90',
                                       'IPStep'    : '0.0.0.1',
                                       'Port'      : 'WT90_E1',
                                       'Gateway'   : '192.168.1.1',
                                       'SubMask'   : '255.255.0.0', 
                                       'NumClients': 1,
                                       'clientCount': 'Variable',
                                       'MainFlow'  : 'Flow1',
                                       'VlanEnable': False,
                                       'vlanId'    : 1,
                                       'EncryptionMethod': 'None',
                                       'Method'    : 'None',
                                       'ApAuthMethod': 'Open',
                                       'Identity'   : 'anonymous',
                                       'AnonymousIdentity': 'anonymous',
                                       'Password'   : 'whatever',
                                       'NetworkAuthMethod': 'None',
                                       'ClientCertificate': '',
                                       'EnableValidateCertificate': 'off',
                                       'PrivateKeyFile': '',
                                       'KeyId'      : '1',
                                       'KeyType'    : 'ascii',
                                       'KeyWidth'   : '',
                                       'NetworkKey' : '',
                                       'RootCertificate': '',
                                       'DataPhyRate': '54',
                                       'Dhcp'      : 'Disable'
                                       },

                            'BKGroup_1': {'Enable'     : True,
                                       'bssid'      : '00:15:70:00:82:b0',
                                       'StartMAC'   : 'AUTO',
                                       'MACIncrMode': 'Auto',
                                       'MacAddressMode': 'Auto',
                                       'MACStep'    : 'Default',
                                       'StartIP'    : '192.168.1.8', 
                                       'IPStep'     : '0.0.0.1',
                                       'Port'       : 'WT90_W1',
                                       'Gateway'    : '192.168.1.1',
                                       'SubMask'    : '255.255.0.0',
                                       'NumClients' : 1,
                                       'clientCount': 'Fixed',
                                       'Security'   : 'None',
                                       'Identity'   : 'anonymous',
                                       'AnonymousIdentity': 'anonymous',
                                       'Password'   : 'whatever',
                                       'NetworkAuthMethod': 'None',
                                       'ClientCertificate': '',
                                       'EnableValidateCertificate': 'off',
                                       'PrivateKeyFile': '',
                                       'KeyId'      : '1',
                                       'KeyType'    : 'ascii',
                                       'KeyWidth'   : '',
                                       'NetworkKey' : '',
                                       'RootCertificate': '',
                                       'EncryptionMethod': 'None',
                                       'Method'     : 'None',
                                       'ApAuthMethod': 'Open',
                                       'MainFlow'  : 'Flow2',
                                       'QosEnabled': 'on',
                                       'VlanEnable': False,
                                       'vlanId'    : 'None', 
                                       'DataPhyRate': '54',
                                       'Dhcp'      : 'Disable'
                                       },
                                       
                            'BKGroup_2': {'Enable'    : True,
                                       'StartMAC'  : 'AUTO',
                                       'MACIncrMode': 'Auto',
                                       'MacAddressMode': 'Auto',
                                       'MACStep'    : 'Default',                                       
                                       'StartIP'   : '192.168.1.88',
                                       'IPStep'    : '0.0.0.1',
                                       'Port'      : 'WT90_E1',
                                       'Gateway'   : '192.168.1.1',
                                       'SubMask'   : '255.255.0.0', 
                                       'NumClients': 1,
                                       'clientCount': 'Fixed',
                                       'MainFlow'  : 'Flow2',
                                       'VlanEnable': False,
                                       'vlanId'    : 1,
                                       'EncryptionMethod': 'None',
                                       'Method'    : 'None',
                                       'ApAuthMethod': 'Open',
                                       'Identity'   : 'anonymous',
                                       'AnonymousIdentity': 'anonymous',
                                       'Password'   : 'whatever',
                                       'NetworkAuthMethod': 'None',
                                       'ClientCertificate': '',
                                       'EnableValidateCertificate': 'off',
                                       'PrivateKeyFile': '',
                                       'KeyId'      : '1',
                                       'KeyType'    : 'ascii',
                                       'KeyWidth'   : '',
                                       'NetworkKey' : '',
                                       'RootCertificate': '',
                                       'DataPhyRate': '54',
                                       'Dhcp'      : 'Disable'
                                       },                                       
                                 }
       
        self.SourceClients = [('ClientEth', 'WT90_E1', '00:00:00:00:00:00', 'DEFAULT', '192.168.1.2',  '255.255.0.0', '192.168.1.1', (), self.Security_None, {})]
        self.DestClients   = [('ClientUno', 'WT90_W1', '00:00:00:00:00:00', 'DEFAULT', '192.168.1.120', '255.255.0.0', '192.168.1.1', (), self.Security_None, self.ClientOptions )]       
       
        self.ClientLearningTime = 1
        self.ClientLearningRate = 10
        self.FlowLearningTime   = 1
        self.FlowLearningRate   = 100
        
        self.ClientgrpFlows = {}
        self.PortStats = {}
        self.FlowList = odict.OrderedDict()
        self.bgFlowList = odict.OrderedDict()
        self.finalGraphs = odict.OrderedDict() 
        
        self.voiceCodec = "VOIPG711"
        self.voiceSearchMax = 75
        self.voiceSearchMin = 1
        self.backgroundFrameSize = 88
        self.numOfVoiceGrpPairs = 1
        self.voiceFrameRate = 50
        self.backgroundFrameRate = 100
        self.bgTrafficBidirFlag = False
        self.slaMode = "R-Value"
        self.slaRvalue = 78.0
        self.FlowMappings = OrderedDict([
            ('Map1', {'DstCG': 'Group_2', 'Enable': True, 'Traffic': 'Flow1', 'SrcCG': 'Group_1', 'flowNum': 'Variable'}), 
            ('Map2', {'DstCG': 'BKGroup_2', 'Enable': True, 'Traffic': 'Flow2', 'SrcCG': 'BKGroup_1', 'flowNum': 'Fixed'})])
#------------------------ End of User Configuration --------------------------
        self.resultNumCalls = 0
        self.resultRvalue = 0
        self.resultMos = 0   
        self.resultJitter = 0
        self.resultLoss1 = 0
        self.resultLoss2 = 0
        self.resultLoss3 = 0 
        self.resultLoss4 = 0
        self.resultLoss5 = 0
        self.resultFrate = 0
        self.resultAvgLatency =  0
        self.resultPerPacketLoss = 0
        self.resultBgNumCalls = 0
        self.resultBgFrate = 0
        self.resultBgJitter = 0
        self.resultBgAvgLatency = 0
        self.resultBgPerPacketLoss = 0 
        self.resultBgLoadMbps = 0
        self.maxCapacityReached = False
        self.brokeSlaAtMinCall = False
        self.voiceUserPriority = None
        self.backgroundUserPriority = None
        self.trialMaxNumOfCalls = []
        self.trialCalls_slafailed=[]
        self.check_flag=0  
    
    def getTestName(self):
        
        return 'qos_capacity'
    
    def loadData(self, waveChassisStore, wavePortStore, waveClientTableStore,
           waveSecurityStore, waveTestStore, waveTestSpecificStore,
           waveMappingStore, waveBlogStore):
             
        
        self.ClientGroups = odict.OrderedDict() 
        self.bgClientGroups = odict.OrderedDict()
        self.MainFlowList = odict.OrderedDict()   
        self.FlowMappings = odict.OrderedDict()  
        self.CardList = []
        self.wifiCardList = []
        self.ethCardList =  []
        
        self.setWifiAndEthCardLists(waveChassisStore)
        # parse generic parameters
        BaseTest.loadData(self, 
                          waveChassisStore, wavePortStore, 
                          waveClientTableStore, waveSecurityStore, 
                          waveTestStore, waveTestSpecificStore, 
                          waveMappingStore, waveBlogStore)   
        
        # grab qos-specific config data
        qos_capacity_data = waveTestSpecificStore['qos_capacity']

        #___________________________________TEL_________________________________________________
        #check for the db key in the waveTestStore['LogsAndResultsInfo'] dictionary if present assign the
        #the corresponding value to DbSupport. Similarly check for the key for pass/fail criteria pf and
        #update the self.UserPassFailCriteria['user'].If user is True then assign the other values for the
        #calculation purpose to judge the pass/fail of the result.
        if  waveTestStore['LogsAndResultsInfo'].has_key('db'):
            if  waveTestStore['LogsAndResultsInfo']['db'] == "True":
                self.DbSupport = waveTestStore['LogsAndResultsInfo']['db']
        if  waveTestStore['LogsAndResultsInfo'].has_key('pf'):
            if  waveTestStore['LogsAndResultsInfo']['pf'] == "True":
                self.UserPassFailCriteria['user'] = waveTestStore['LogsAndResultsInfo']['pf']
                if qos_capacity_data['Voice'].has_key('ExpectedCallCapacity'):
                    if int(qos_capacity_data['Voice']['ExpectedCallCapacity']) >=0:  
                        self.UserPassFailCriteria['ref_min_calls']= int(qos_capacity_data['Voice']['ExpectedCallCapacity'])
                    else:
                        WaveEngine.OutputstreamHDL("\nThe value for the parameter ExpectedCallCapacity should be a positive number\n",WaveEngine.MSG_ERROR)
                        raise  WaveEngine.RaiseException
                else:
                    #WaveEngine.OutputstreamHDL("\nUser has not given the value for <ExpectedCallCapacity> parameter, hence reverting to default value and proceeding further....\n",WaveEngine.MSG_WARNING)
                    self.UserPassFailCriteria['ref_min_calls']= 30
        #___________________________________TEL_________________________________________________
        
        self.ClientGroups = self.configCGs(waveClientTableStore, waveSecurityStore, waveTestSpecificStore)
                
        # Auto Mapping options
        autoMap = qos_capacity_data['AutoMap']
        self.trafficDirection = autoMap.get('trafficDirection', 'Ethernet To Wireless')
        self.testParameters['Voice and Background Traffic Direction'] = self.trafficDirection     
         
        (tmpFlowMaps, self.ClientGroups) = self.configCGMaps(self.ClientGroups)         
                 
       
        try:
            if 'qos_capacity' not in waveTestSpecificStore.keys():
                self.Print("No QoS Capacity config found\n", 'ERR')
                raise WE.RaiseException
        except WE.RaiseException:
            self.Print("WaveEngine terminating the run\n", 'ERR')
            self.CloseShop()
            return -1  
        
        self.slaMode = qos_capacity_data['SLA']['Mode']
        
        self.testParameters['Acceptance Mode'] = self.slaMode 
        
        if self.slaMode == "R-Value":     
            self.slaRvalue = float(qos_capacity_data['SLA']['MinRValue'])
            self.testParameters['Acceptable R-value'] = self.slaRvalue 
        else:          
            self.slaMaxLatency = qos_capacity_data['SLA']['MaxLatency']     
            self.slaMaxPktLoss = qos_capacity_data['SLA']['MaxPktLoss']     
            self.slaMaxJitter = qos_capacity_data['SLA']['MaxJitter']
            self.testParameters['Acceptable Latency(msecs)'] = self.slaMaxLatency 
            self.testParameters['Acceptable PacketLoss'] = self.slaMaxPktLoss 
            self.testParameters['Acceptable Jitter(msecs)'] = self.slaMaxJitter 
        
        
        self.voiceCodec = qos_capacity_data['Voice']['Codec']
        self.voiceSearchMin = int(qos_capacity_data['Voice']['SearchMin'])
        self.voiceSearchMax = int(qos_capacity_data['Voice']['SearchMax'])
        
        if 'QoSEnabled' not in qos_capacity_data['Voice'].keys():    #Backward compatibility for config files that won't have 'QoSEnabled' key
            self.voiceQoSEnabledF = 'True'
        else:
            self.voiceQoSEnabledF = qos_capacity_data['Voice']['QoSEnabled']
        if self.voiceQoSEnabledF.lower() == 'true':
            if 'UserPriority' not in qos_capacity_data['Voice'].keys():
                self.voiceUserPriority = 7            
            else: 
                if qos_capacity_data['Voice']['UserPriority'] == "Default": 
                    self.voiceUserPriority = 7
                else:      
                    self.voiceUserPriority = qos_capacity_data['Voice']['UserPriority']            
               
        if 'SrcPort' not in qos_capacity_data['Voice'].keys():
            self.voiceSrcPort = 5004
        else:    
            if qos_capacity_data['Voice']['SrcPort'] == "Default": 
                self.voiceSrcPort = 5004
            else:     
                self.voiceSrcPort = qos_capacity_data['Voice']['SrcPort']
            
        if 'DestPort' not in qos_capacity_data['Voice'].keys():
            self.voiceDestPort = 5003
        else:    
            if qos_capacity_data['Voice']['DestPort'] == "Default": 
                self.voiceDestPort = 5003
            else:     
                self.voiceDestPort = qos_capacity_data['Voice']['DestPort']
                 
        if 'TosField' not in qos_capacity_data['Voice'].keys() or \
            qos_capacity_data['Voice']['TosField'] == "Default": 
            self.voiceTosField = 0           
        else: 
            tosPrec = qos_capacity_data['Voice']['TosField']    
            if tosPrec == "Network Control":
                self.voiceTosField = 7
            elif tosPrec == "Internet Control":
                self.voiceTosField = 6
            elif tosPrec == "CRITIC/ECP":
                self.voiceTosField = 5
            elif tosPrec == "Flash Override":
                self.voiceTosField = 4
            elif tosPrec == "Flash":
                self.voiceTosField = 3
            elif tosPrec == "Immediate":
                self.voiceTosField = 2
            elif tosPrec == "Priority":
                self.voiceTosField = 1 
            else: # default to "Routine"
                self.voiceTosField = 0 
                
            self.voiceTosField <<= _TosPrecBit

            if bool(qos_capacity_data['Voice']['TosReserved']) == True:
                self.voiceTosField |= (1 << _TosFieldReservedBit) 
            if bool(qos_capacity_data['Voice']['TosLowCost']) == True:
                self.voiceTosField |= (1 << _TosFieldMonetaryBit) 
            if bool(qos_capacity_data['Voice']['TosLowDelay']) == True:
                self.voiceTosField |= (1 << _TosFieldDelayBit) 
            if bool(qos_capacity_data['Voice']['TosHighReliability']) == True:
                self.voiceTosField |= (1 << _TosFieldReliabilityBit) 
            if bool(qos_capacity_data['Voice']['TosHighThroughput']) == True:  
                self.voiceTosField |= (1 << _TosFieldThroughputBit)         

        if 'TosDiffservDSCP' not in qos_capacity_data['Voice'].keys() or \
            qos_capacity_data['Voice']['TosDiffservDSCP'] == "Default":
            self.voiceDscpMode = "off"                    
        else:
            self.voiceDscpMode = "on" 
            self.voiceTosField = int(qos_capacity_data['Voice']['TosDiffservDSCP']) 
             
        if 'QoSEnabled' not in qos_capacity_data['Background'].keys(): #Backward comptability for config files that won't have 'QoSEnabled' key
            self.bgQoSEnabledF = 'True'
        else:
            self.bgQoSEnabledF = qos_capacity_data['Background']['QoSEnabled']
        if self.bgQoSEnabledF.lower() == 'true':
            if 'UserPriority' not in qos_capacity_data['Background'].keys():
                self.backgroundUserPriority = 1
            else:    
                if qos_capacity_data['Background']['UserPriority'] == "Default": 
                    self.backgroundUserPriority = 1
                else:     
                    self.backgroundUserPriority = qos_capacity_data['Background']['UserPriority']

        if 'SrcPort' not in qos_capacity_data['Background'].keys():
            self.backgroundSrcPort = 0
        else:    
            if qos_capacity_data['Background']['SrcPort'] == "Default": 
                self.backgroundSrcPort = 0
            else:     
                self.backgroundSrcPort = qos_capacity_data['Background']['SrcPort']
                
        if 'DestPort' not in qos_capacity_data['Background'].keys():
            self.backgroundDestPort = 0
        else:    
            if qos_capacity_data['Background']['DestPort'] == "Default": 
                self.backgroundDestPort = 0
            else:     
                self.backgroundDestPort = qos_capacity_data['Background']['DestPort']

        if 'TosField' not in qos_capacity_data['Background'].keys() or \
            qos_capacity_data['Background']['TosField'] == "Default": 
            self.backgroundTosField = 0           
        else: 
            tosPrec = qos_capacity_data['Background']['TosField']    
            if tosPrec == "Network Control":
                self.backgroundTosField = 7
            elif tosPrec == "Internet Control":
                self.backgroundTosField = 6
            elif tosPrec == "CRITIC/ECP":
                self.backgroundTosField = 5
            elif tosPrec == "Flash Override":
                self.backgroundTosField = 4
            elif tosPrec == "Flash":
                self.backgroundTosField = 3
            elif tosPrec == "Immediate":
                self.backgroundTosField = 2
            elif tosPrec == "Priority":
                self.backgroundTosField = 1 
            else: # default to "Routine"
                self.backgroundTosField = 0 
                
            self.backgroundTosField <<= _TosPrecBit

            if bool(qos_capacity_data['Background']['TosReserved']) == True:
                self.backgroundTosField |= (1 << _TosFieldReservedBit) 
            if bool(qos_capacity_data['Background']['TosLowCost']) == True:
                self.backgroundTosField |= (1 << _TosFieldMonetaryBit) 
            if bool(qos_capacity_data['Background']['TosLowDelay']) == True:
                self.backgroundTosField |= (1 << _TosFieldDelayBit) 
            if bool(qos_capacity_data['Background']['TosHighReliability']) == True:
                self.backgroundTosField |= (1 << _TosFieldReliabilityBit) 
            if bool(qos_capacity_data['Background']['TosHighThroughput']) == True:  
                self.backgroundTosField |= (1 << _TosFieldThroughputBit)                

        if 'TosDiffservDSCP' not in qos_capacity_data['Background'].keys() or \
            qos_capacity_data['Background']['TosDiffservDSCP'] == "Default":
            self.backgroundDscpMode = "off"                    
        else:
            self.backgroundDscpMode = "on" 
            self.backgroundTosField = int(qos_capacity_data['Background']['TosDiffservDSCP'])
                       
        self.backgroundType = qos_capacity_data['Background']['Type']
        self.backgroundFrameSize = int(qos_capacity_data['Background']['FrameSize'])
        self.backgroundFrameRate = int(qos_capacity_data['Background']['FrameRate'])
        if qos_capacity_data['Background']['Direction'] == 'Unidirectional':
            self.bgTrafficBidirFlag = False
        else:
            self.bgTrafficBidirFlag = True            
        self.testParameters['Background Traffic Flow Direction'] = qos_capacity_data['Background']['Direction']  
              
        self.voiceCodecReport = self.voiceCodec        
        if self.voiceCodec == "G.711":
            self.voiceCodec = "VOIPG711"           
            self.voiceFrameRate = 50    
        elif self.voiceCodec == "G.729":  
            self.voiceCodec = "VOIPG729A"
            self.voiceFrameRate = 50
        elif self.voiceCodec == "G.723":  
            self.voiceCodec = "VOIPG7231"
            self.voiceFrameRate = 33
        else:
            self.Print("Warning : %s Codec Option Not Available using G.711 codec instead\n" % (self.voiceCodec), 'ERR') 
            self.voiceCodec = "VOIPG711"
        
        flowParams = dict()
        flowParams['Type'] = self.voiceCodec
        flowParams['Numframes'] = WE.MAXtxFrames
        flowParams['UserPriority'] =  self.voiceUserPriority
        flowParams['TosField'] = self.voiceTosField
        flowParams['DscpMode'] = self.voiceDscpMode
        flowParams['SrcPort'] = self.voiceSrcPort
        flowParams['DestPort'] = self.voiceDestPort
        flowParams['flowType'] = 'mainFlow'
        self.MainFlowList['Flow1'] = flowParams
        
        flowParams = dict()                                      
        flowParams['Type'] = qos_capacity_data['Background']['Type']
        flowParams['Framesize'] = qos_capacity_data['Background']['FrameSize'] 
        flowParams['Ratemode'] = 'pps'
        flowParams['Intendedrate'] =  qos_capacity_data['Background']['FrameRate'] 
        flowParams['Numframes'] = WE.MAXtxFrames
        flowParams['UserPriority'] = self.backgroundUserPriority
        flowParams['TosField'] = self.backgroundTosField  
        flowParams['DscpMode'] = self.backgroundDscpMode
        flowParams['SrcPort'] = self.backgroundSrcPort
        flowParams['DestPort'] =  self.backgroundDestPort
        flowParams['flowType'] = 'bkFlow'
        self.MainFlowList['Flow2'] = flowParams         
        
        clGroups = self.ClientGroups.keys()
        voiceSrcGroup = []
        bgSrcGroup = []
        voiceDestGroup = []
        bgDestGroup = []
        self.numOfVoiceGrpPairs = 0
        
        for map in tmpFlowMaps:
            if tmpFlowMaps[map]['flowType'] == 'voice':
                voiceSrcGroup.append(tmpFlowMaps[map]['SrcCG'])
                voiceDestGroup.append(tmpFlowMaps[map]['DstCG'])
                self.numOfVoiceGrpPairs = self.numOfVoiceGrpPairs + 1
            else:
                bgSrcGroup.append(tmpFlowMaps[map]['SrcCG'])
                bgDestGroup.append(tmpFlowMaps[map]['DstCG'])                
        jj = 1
        kk = 0
        for clGrps in voiceSrcGroup:
            mapParams = dict()
            mapName = 'Map' + str(jj)
            mapParams['Enable'] = True
            mapParams['SrcCG'] = clGrps
            mapParams['DstCG'] = voiceDestGroup[kk]
            mapParams['Traffic'] = "Flow1"
            mapParams['flowNum'] = "Variable"            
            self.FlowMappings[mapName] = mapParams 
            kk = kk + 1
            jj = jj + 1   
        
        kk = 0
        for clGrps in bgSrcGroup:
            mapParams = dict()
            mapName = 'Map' + str(jj)
            mapParams['Enable'] = True
            mapParams['SrcCG'] = clGrps
            mapParams['DstCG'] = bgDestGroup[kk]
            mapParams['Traffic'] = "Flow2"
            mapParams['flowNum'] = "Fixed"            
            self.FlowMappings[mapName] = mapParams 
            jj = jj + 1 
            kk = kk + 1           
       
        self.testParameters['Trial Duration (secs)'] = self.TransmitTime
        self.testParameters['Settle Time (secs)'] = self.SettleTime 
        self.testParameters['Num of Trials'] = self.Trials         
        self.testParameters['Voice Codec'] = self.voiceCodecReport 
        #self.testParameters['Voice Phy rate (Mbps)'] = waveClientTableStore[groups]['DataPhyRate'] 
        #self.testParameters['Voice Security'] = waveSecurityStore[groups]['Method']
        self.testParameters['Min Calls/AP'] = self.voiceSearchMin 
        self.testParameters['Max Calls/AP'] = self.voiceSearchMax 
        if self.backgroundUserPriority == None:
            self.testParameters['Background Traffic User Priority'] = 'Disabled'         
        else:
            self.testParameters['Background Traffic User Priority'] = self.backgroundUserPriority 
        self.testParameters['Background Traffic Type'] = self.backgroundType 
        self.testParameters['Background Traffic Frame Size (bytes)'] = self.backgroundFrameSize 
        self.testParameters['Background Traffic Frame Rate (pps)'] = self.backgroundFrameRate 
        
        # initialize the max num of calls for each trial
        for i in range(0, self.Trials):
            self.trialMaxNumOfCalls.append(0)       
            self.trialCalls_slafailed.append(0)
    def setWifiAndEthCardLists(self, waveChassisStore):
        self.CardMap = dict()         
        for chassis in waveChassisStore.keys():
            for cards in waveChassisStore[chassis].keys():
                for portName in waveChassisStore[chassis][cards]:
                    if waveChassisStore[chassis][cards][portName]['BindStatus'] == "True":
                        if waveChassisStore[chassis][cards][portName]['PortType'] == "8023":
                            self.ethCardList.append(waveChassisStore[chassis][cards][portName]['PortName'])                     
                        else:
                            self.wifiCardList.append(waveChassisStore[chassis][cards][portName]['PortName'])         

    def validateConfigs(self):
        for flowMap in self.FlowMappings.keys():
            srcgroup = self.FlowMappings[flowMap]['SrcCG']
            destgroup = self.FlowMappings[flowMap]['DstCG']
            srcGrpStartIp = self.ClientGroups[srcgroup]['StartIP'] 
            dstGrpStartIp = self.ClientGroups[destgroup]['StartIP'] 
            
            srcDHCPstate = self.ClientGroups[srcgroup]['Dhcp'] 
            dstDHCPstate = self.ClientGroups[destgroup]['Dhcp']
             
            ipAddrDiff = abs(int(srcGrpStartIp.split('.')[2]) - int(dstGrpStartIp.split('.')[2])) * 255 \
                           + abs(int(srcGrpStartIp.split('.')[3]) - int(dstGrpStartIp.split('.')[3]))
            
            if srcDHCPstate == "Disable" and dstDHCPstate == "Disable":
                if ipAddrDiff < self.voiceSearchMax:
                    self.Print( "Error: IP addresses between %s and %s client groups can not overlap.\nStarting IP addresses for these groups must be at least %d apart.\n" % ( srcgroup, destgroup, self.voiceSearchMax ), 'ERR' )
                    return -1
    
    def CustomMAC(self, ip_addr):        
        value1 = 0
        value2 = 1
        value3 = int(ip_addr.split('.')[0])
        value4 = int(ip_addr.split('.')[1])
        value5 = int(ip_addr.split('.')[2])
        value6 = int(ip_addr.split('.')[3])
        return "%02X:%02X:%02X:%02X:%02X:%02X" % (value1, value2, value3, value4, value5, value6)

    def RandomMAC(self):
        #value1 = int(random.random()*64) * 4
        #value2 = int(random.random()*256)
        value1 = 0
        value2 = 1
        value3 = int(random.random()*256)
        value4 = int(random.random()*256)
        value5 = int(random.random()*256)
        value6 = int(random.random()*256)
        return "%02X:%02X:%02X:%02X:%02X:%02X" % (value1, value2, value3, value4, value5, value6)    
    
    def createClientTuple(self, clientGroups):
        clientsPerCG = OrderedDict()
        groups = clientGroups.keys()
          
        groups.sort()
        for group in groups:
            groupProperties = clientGroups[group]           
            if not self.isCGEnabled(groupProperties):
                continue
            clientData = ()
            clientData += (group,)
            if not 'Port' in groupProperties.keys():
                self.Print("Port not found in %s\n" % group, 'ERR')
                continue
            port = groupProperties['Port']
            clientData += (port,)
            if WE.GetCachePortInfo(port) in WE.WiFiPortTypes:
                if 'bssid' not in groupProperties.keys():
                    self.Print("bssid not found\n" ,
                          'ERR')
                    continue
                bssid = groupProperties['bssid']
            else:
                bssid = '00:00:00:00:00:00'
            clientData += (bssid,)
              
            if not 'MacAddressMode' in groupProperties.keys():
                self.Print("MacAddressMode not found in %s\n" % group, 'ERR')
                continue   

            macAddrMode = str(groupProperties['MacAddressMode']).upper()
            if macAddrMode == 'AUTO':
                # automatic mode -- assign MAC by cc:ss:pp:ip:ip:ip
                clientData += ('AUTO',)
            elif macAddrMode in [ 'DEFAULT', 'RANDOM' ]:
                # default mode -- assign MAC by the IETF draft rr:pp:pp:rr:rr:rr
                # also known as random mode
                macAddrMode = 'DEFAULT'
                clientData += (groupProperties['StartMAC'],)
            else:
                clientData += (groupProperties['StartMAC'],)          
            
            if groupProperties['Dhcp'] == 'Enable':
                #Inform WE.Createclients by giving IP:0.0.0.0 that client gets IP by Dhcp 
                clientData += ('0.0.0.0',)    
                clientData += ('',)           #subnet mask
                clientData += ('',)           #Gateway            
            elif groupProperties['Dhcp'] == 'Disable':
                if not 'StartIP' in groupProperties.keys():
                    self.Print("StartIP not found in %s\n" % group, 'ERR')
                    continue
                clientData += (groupProperties['StartIP'],)
                if not 'SubMask' in groupProperties.keys():
                    self.Print("SubMask not found in %s\n" % group, 'ERR')
                    continue   
                clientData += (groupProperties['SubMask'],)
                if not 'Gateway' in groupProperties.keys():
                    self.Print("Gateway not found in %s\n" % group, 'ERR')
                    continue
                clientData += (groupProperties['Gateway'],)            
            
            incrTuple = ()
            incrTuple += (groupProperties['NumClients'],)
 
            if not 'MACIncrMode' in groupProperties.keys():
                self.Print("MACIncrMode not found in %s\n" % group, 'ERR')
                continue   
                     
                # store AUTO or DEFAULT from base MAC
            if macAddrMode in [ 'DEFAULT', 'AUTO' ]:
                incrTuple += (macAddrMode,)
            else:
                macIncr = groupProperties['MACStep']
                macIncrInt = int(macIncr)
                if macAddrMode == 'INCREMENT':
                    macIncrMac = MACaddress().inc(macIncrInt)
                else:
                    macIncrMac = MACaddress().dec(macIncrInt)
                incrTuple += (macIncrMac.get(),)           
                 
            if not 'IPStep' in groupProperties.keys():
                self.Print("IPStep not found in %s\n" % group, 'ERR')
                continue
            incrTuple += (groupProperties['IPStep'],)
            clientData += (incrTuple,)
            
            secOptions = dict()        
            secOptions['Method'] =  groupProperties['Method'] 
            secOptions['Identity'] = groupProperties['Identity'] 
            secOptions['Password'] = groupProperties['Password'] 
            secOptions['KeyId'] = groupProperties['KeyId'] 
            secOptions['NetworkAuthMethod'] =  groupProperties['NetworkAuthMethod'] 
            secOptions['EthNetworkAuthMethod'] =  groupProperties['EthNetworkAuthMethod']             
            secOptions['KeyType'] = groupProperties['KeyType'] 
            secOptions['ClientCertificate'] = groupProperties['ClientCertificate'] 
            secOptions['EnableValidateCertificate'] = groupProperties['EnableValidateCertificate']   
            secOptions['PrivateKeyFile']= groupProperties['PrivateKeyFile'] 
            secOptions['KeyWidth']  = groupProperties['KeyWidth'] 
            secOptions['EncryptionMethod'] = groupProperties['EncryptionMethod'] 
            secOptions['NetworkKey']   = groupProperties['NetworkKey'] 
            secOptions['RootCertificate'] = groupProperties['RootCertificate'] 
            secOptions['ApAuthMethod'] = groupProperties['ApAuthMethod'] 
            secOptions['AnonymousIdentity'] = groupProperties['AnonymousIdentity'] 
                        
            clientData += (secOptions,)
            
            clientOptions = odict.OrderedDict()

            if 'AssocProbe' in groupProperties.keys():
                probeVal = str(groupProperties['AssocProbe'])
                if probeVal == 'Broadcast':
                    clientOptions['ProbeBeforeAssoc'] = "bdcast"
                elif probeVal == 'None':
                    clientOptions['ProbeBeforeAssoc'] = "off"
                else:
                    clientOptions['ProbeBeforeAssoc'] = "unicast"                
                
            if 'MgmtPhyRate' in groupProperties.keys():
                clientOptions['PhyRate'] = groupProperties['MgmtPhyRate']

            if 'TxPower' in groupProperties.keys():
                clientOptions['TxPower'] = groupProperties['TxPower']

            if 'CtsToSelf' in groupProperties.keys():
                clientOptions['CtsToSelf'] = groupProperties['CtsToSelf']
                
            if WE.GetCachePortInfo(port) in WE.WiFiPortTypes: 
                if 'GratuitousArp' in groupProperties.keys():
                    gratArp = 'off'
                    if groupProperties['GratuitousArp'] == 'True':
                        gratArp = 'on'                
                    clientOptions['GratuitousArp'] = gratArp
                    
            patt = re.compile(r'BK.+')                
            if 'QosEnabled' in groupProperties.keys():
                clientOptions['WmeEnabled'] = 'on'
                """
                if self.bgTrafficBidirFlag == False and patt.match(group):
                    # Handle special case here, where bk traffic is unidirectional (Eth->Wifi)
                    # and the bk WLAN QoS setting is enabled. In this case, we shouldn't be 
                    # setting WmeEnabled on.
                    for i in self.FlowMappings.keys():  
                        if self.FlowMappings[i]['SrcCG'] == group:
                            clientOptions['WmeEnabled'] = 'on'   
                            break 
                        clientOptions['WmeEnabled'] = 'off'
                """
                if self.backgroundUserPriority == None and patt.match(group):
                    clientOptions['WmeEnabled'] = 'off'
                elif self.voiceUserPriority == None:
                    clientOptions['WmeEnabled'] = 'off'                    
                        
            if 'VlanEnable' in groupProperties.keys():
                if groupProperties['VlanEnable'] == 'True':
                    clientOptions['VlanTag'] = \
                        (groupProperties['VlanUserPriority'] & 0x7 )* 2**13 + \
                        (groupProperties['VlanCfi'] & 0x1 ) * 2**12 + \
                        (groupProperties['VlanId'] & 0xfff )                   
            # if bk traffic type is TCP, needs to add enableNetworkInterface to
            # the client options
            if self.backgroundType == 'TCP' and self.backgroundFrameRate > 0 and patt.match(group):
                clientOptions['enableNetworkInterface'] = True
            
            if groupProperties['Interface'] in WE.WiFiInterfaceTypes:
                interfaceOptions = self.clientgroupObjs[group].interfaceOptions
                clientOptions.update(interfaceOptions)
                
            clientData += (clientOptions,)           
            
            clientDataList = []
            clientDataList.append(clientData)            
            clientsPerCG[group] = clientDataList
            
            
        return clientsPerCG
    
    def getNextIP(self, ip_addr, chg_val):
        ipSplit = ip_addr.split('.')
        if chg_val == 2:
            ipSplit[3] = str(int(ipSplit[3]) + 1)
        else:
            ipSplit[3] = str(int(ipSplit[3]) - 1)    
        addr = ipSplit[0] + '.' + ipSplit[1] + '.' + ipSplit[2] + '.' + ipSplit[3]
        return addr
    
    def VerifyBSSID_MAC(self, clients):
        # set random seed for psuedo-random MAC addresses that are repeatable.
        if not WE.GroupVerifyBSSID_MAC([clients], self.BSSIDscanTime):
            self.SavePCAPfile = True
            raise WE.RaiseException
    
    def createflows(self, groupname):
        
        if self.ClientGroups[groupname]['Enable'] == False:
            return
        
        if 'MainFlow' not in self.ClientGroups[groupname].keys():
            self.Print("MainFlow not defined for %s\n" % groupname, 'ERR')
            return                
                
        mainflowname = self.ClientGroups[groupname]['MainFlow']
        if mainflowname not in self.MainFlowList.keys():
            self.Print("%s not defined\n" % mainflowname, 'ERR')
            return
        Keys = self.MainFlowList[mainflowname].keys()
        if 'Type' in Keys:
            pkttype = self.MainFlowList[mainflowname]['Type']
        else:
            pkttype = 'IP'
        if 'Framesize' in Keys:
            framesize = self.MainFlowList[mainflowname]['Framesize']
        else:
            framesize = 256
            
        if 'DataPhyRate' in self.ClientGroups[groupname].keys():
            # if drop here it's a wireless group
            phyrate = self.ClientGroups[groupname]['DataPhyRate']
        else:
            # if drop here it's an ethernet group
            phyrate = -1
        if 'Ratemode' in Keys:
            ratemode = self.MainFlowList[mainflowname]['Ratemode']
        else:
            ratemode = 'pps'
            
        if 'Intendedrate' in Keys:
            intendedrate = self.MainFlowList[mainflowname]['Intendedrate']            
        else:
            intendedrate = 100
            
        if 'Numframes' in Keys:
            numframes = self.MainFlowList[mainflowname]['Numframes']
        else:
            numframes = WE.MAXtxFrames

        if 'flowType' in Keys:
            flowType = self.MainFlowList[mainflowname]['flowType']
        else:
            flowType = "Default"    
        mainflow = self.Flow(pkttype, framesize, phyrate, ratemode, intendedrate, numframes, flowType)
        
        self.AddFlow(groupname, mainflow, None)
      
    
    def AddFlow(self, CGname, flowprof, learnflowprof = None):
        if flowprof == None:
            self.Print("No Flow profile for Clientgroup %s\n" % CGname,\
                    'ERR')
            return
        if CGname not in self.ClientgrpClients.keys():
            self.Print("No clients found in Clientgroup %s\n" % CGname,\
                    'ERR')
            return
        if flowprof.IntendedRate <= 0:
            return
        
        self.ClientgrpFlows[CGname] = flowprof
        FlowOptions = self.FlowOptions.copy() # VPR 2983 {}
        FlowOptions['Type'] = flowprof.Type     
        
        if flowprof.FlowType != "mainFlow":  
            FlowOptions['RateMode'] = flowprof.RateMode
            FlowOptions['FrameSize'] = flowprof.FrameSize
            FlowOptions['IntendedRate'] = flowprof.IntendedRate
            FlowOptions['NumFrames'] = flowprof.NumFrames 

        for flowMapName in self.FlowMappings.keys():
            if self.FlowMappings[flowMapName]['SrcCG'] == CGname:
                if self.FlowMappings[flowMapName]['Enable'] == True:
                    # Set the correct wireless data phy rate for the flow
                    srcCGName = self.FlowMappings[flowMapName]['SrcCG']  
                    dstCGName = self.FlowMappings[flowMapName]['DstCG']

                    if self.ClientgrpFlows[srcCGName] < 0:
                        FlowOptions['PhyRate'] = self.ClientGroups[dstCGName]['DataPhyRate']
                    else:
                        FlowOptions['PhyRate'] = self.ClientGroups[srcCGName]['DataPhyRate']                    
                    if FlowOptions['PhyRate'] < 0:
                        # if drop here there is something wrong with our configs
                        FlowOptions['PhyRate'] = 54 
                    
                    ethGroup = ''
                    enetQoSEnableF = 'False'
                    enetPriority = None
                    if self.ClientGroups[srcCGName]['Port'] in self.ethCardList:
                        ethGroup = srcCGName
                    elif self.ClientGroups[dstCGName]['Port'] in self.ethCardList:
                        ethGroup = dstCGName
                    if ethGroup != '':
                        enetQoSEnableF = self.ClientGroups[ethGroup].get('VlanEnable', 'False')
                        enetPriority = self.ClientGroups[ethGroup].get('VlanUserPriority', None)
                              
                    if self.FlowMappings[flowMapName]['flowNum'] == "Variable":                                          
                        Flowdict = WE.CreateFlows_Pairs(self.ClientgrpClients[srcCGName],
                            self.ClientgrpClients[dstCGName], True, FlowOptions)              
                        
                        for key in Flowdict.keys():
                            self.FlowList[key] = Flowdict[key]                        

                        WE.ModifyFlows(self.FlowList, {'Type': FlowOptions['Type']})    
                        #The 'portList' assumes WE.CreateFlows_Pairs() returns
                        #flownames with the order (i) srcGroup--> DestGroup and (ii)
                        #DestGroup-->SrcGroup
                        self.configQoSParameters(Flowdict, enetQoSEnableF, enetPriority,
                                                 self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['UserPriority']
                                                 )
                        
                        flowKeys = Flowdict.keys()
                        srcFlowKeys = flowKeys[:len(flowKeys)/2]
                        dstFlowKeys = flowKeys[len(flowKeys)/2:] 
                        # VPR 4893: swapped the src and dest ports for voice traffic                       
                        self.configTosIPnumber(srcFlowKeys, self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['TosField'],
                                    int(self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['SrcPort']), \
                                    int(self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['DestPort']), \
                                    self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['DscpMode'])          
                        self.configTosIPnumber(dstFlowKeys, self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['TosField'],
                                    int(self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['DestPort']), \
                                    int(self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['SrcPort']), \
                                    self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['DscpMode'])                           
                    else:
                        Flowdict2 = WE.CreateFlows_Pairs(self.ClientgrpClients[srcCGName],
                            self.ClientgrpClients[dstCGName], self.bgTrafficBidirFlag, FlowOptions)            
                        if FlowOptions['Type'] == 'TCP':
                            flowType = 'biflow'      
                        else:
                            flowType = 'flow' 
                        #The 'portList' assumes WE.CreateFlows_Pairs() returns
                        #flownames with the order (i) srcGroup--> DestGroup and (ii)
                        #DestGroup-->SrcGroup
                        self.configQoSParameters(Flowdict2, enetQoSEnableF, enetPriority,
                                                 self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['UserPriority'], 
                                                 flowType)
                        
                        if self.bgTrafficBidirFlag == True:
                            flowKeys = Flowdict2.keys()
                            srcFlowKeys = flowKeys[:len(flowKeys)/2]
                            dstFlowKeys = flowKeys[len(flowKeys)/2:]                         
                            # VPR 5062: swapped the src and dest ports for bk traffic 
                            self.configTosIPnumber(srcFlowKeys, self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['TosField'], \
                                        int(self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['SrcPort']), \
                                        int(self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['DestPort']), \
                                        self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['DscpMode'], flowType)
                            self.configTosIPnumber(dstFlowKeys, self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['TosField'], \
                                        int(self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['DestPort']), \
                                        int(self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['SrcPort']), \
                                        self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['DscpMode'], flowType)
                        else:
                            self.configTosIPnumber(Flowdict2.keys(), self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['TosField'], \
                                        int(self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['SrcPort']), \
                                        int(self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['DestPort']), \
                                        self.MainFlowList[self.FlowMappings[flowMapName]['Traffic']]['DscpMode'], flowType)                            
                        
                        for key in Flowdict2.keys():
                            self.bgFlowList[key] = Flowdict2[key]

                        WE.ModifyFlows(self.bgFlowList, {'FrameSize': flowprof.FrameSize,
                                                                 'IntendedRate': flowprof.IntendedRate, 
                                                                 'NumFrames': flowprof.NumFrames, 
                                                                 'RateMode': flowprof.RateMode,
                                                                 'Type': FlowOptions['Type']})    
                        
    def configQoSParameters(self, flowDict, enetQoSEnableF, 
                            enetPriority, wlanPriority, flowType='flow'):
        for flowName in flowDict:   
            (srcPort, srcGrp, dstPort, dstGrp) = flowDict[flowName]         
                 
            if srcPort in self.ethCardList and enetQoSEnableF == 'True':
                WE.VCLtest("%s.read('%s')" % (flowType, flowName))
                WE.VCLtest("enetQos.readFlow()")    
                WE.VCLtest("enetQos.setPriorityTag('on')")
                WE.VCLtest("enetQos.setTgaPriority(%s)" % enetPriority)
                WE.VCLtest("enetQos.setUserPriority(%s)" % enetPriority)
                WE.VCLtest("enetQos.modifyFlow()")     
                WE.VCLtest("%s.write('%s')" % (flowType, flowName))               
            elif srcPort in self.wifiCardList and wlanPriority != None:
                WE.VCLtest("%s.read('%s')" % (flowType, flowName))
                WE.VCLtest("wlanQos.readFlow()")    
                WE.VCLtest("wlanQos.setTgaPriority(%s)" % wlanPriority)
                WE.VCLtest("wlanQos.setUserPriority(%s)" % wlanPriority)
                WE.VCLtest("wlanQos.modifyFlow()")    
                WE.VCLtest("%s.write('%s')" % (flowType, flowName))
    
    def configTosIPnumber(self, flowNames, tosByte, srcPort, destPort, dscpMode, flowType='flow'):       
        for flowName in flowNames:            
            WE.VCLtest("%s.read('%s')" % (flowType, flowName))
                
            WE.VCLtest("ipv4.readFlow()")     
            WE.VCLtest("ipv4.setDscpMode('%s')" % dscpMode) 
            if dscpMode == "off":              
                WE.VCLtest("ipv4.setTosField(%d)" % tosByte) 
            else:                
                WE.VCLtest("ipv4.setDscp(%d)" % tosByte)                  
            WE.VCLtest("ipv4.modifyFlow()") 
            
            exec("pktType = %s.getType()" % (flowType))
            if 'TCP' in pktType:
                WE.VCLtest("tcp.setSrcPort(%d)" % srcPort)
                WE.VCLtest("tcp.setDestPort(%d)" % destPort)    
                WE.VCLtest("tcp.modifyFlow()")                 
            elif 'UDP' in pktType:   
                WE.VCLtest("udp.setSrcPort(%d)" % srcPort)
                WE.VCLtest("udp.setDestPort(%d)" % destPort)    
                WE.VCLtest("udp.modifyFlow()")    
                
            WE.VCLtest("%s.write('%s')" % (flowType, flowName))
    
    class Flow:
        def __init__(self, Type = 'IP', Framesize = 256, Phyrate = 54, Ratemode = 'pps', 
                      Intendedrate = 100, Numframes = WE.MAXtxFrames, FlowType = "Default"):
            self.Type = Type
            self.FrameSize = Framesize
            self.PhyRate = Phyrate
            self.RateMode = Ratemode
            self.IntendedRate = Intendedrate
            self.NumFrames = Numframes
            self.FlowType = FlowType            

        def SetFramesize(self, size):
            self.FrameSize = size
           
    def configureFlows(self):
        if len(self.MainFlowList) > 0:
            self._createFlowGroup(self.FlowList, "XmitGroup") 
            self._createFlowGroup(self.bgFlowList, "BkGroup")
        else:
            self.Print("No main transmit flows created\n", 'ERR')
            return -1
        pass
    
    def doArpExchanges(self):
        arpList = odict.OrderedDict()
        if len(self.FlowList) > 0:
            arpList = self.FlowList.copy()
            # only do ARPs if bk traffic type is not TCP
            if self.backgroundType != 'TCP' and self.backgroundFrameRate > 0: 
                for flws in self.bgFlowList:
                   arpList[flws] = self.bgFlowList[flws]
            if WE.ExchangeARP(arpList, "XmitGroup",self.ARPRate, self.ARPRetries,self.ARPTimeout) < 0.0:
                raise WE.RaiseException    

    def startTest(self, upLinkFlowNameListByAP, downLinkFlowNameListByAP):       
        self.testResults = odict.OrderedDict()  
         
        for ll in range(0,self.Trials):
            self.resultsDict['trialNum'] = []
            self.resultsDict['mainFlowLat'] = []
            self.resultsDict['mainFlowLoss'] = []
            self.resultsDict['mainFlowFrate'] = []
            self.resultsDict['mainRvalue'] = []
            self.resultsDict['mainMosScore'] = []
            self.resultsDict['mainJitter'] = [] 
            self.resultsDict['mainLoss1'] = []
            self.resultsDict['mainLoss2'] = []
            self.resultsDict['mainLoss3'] = []
            self.resultsDict['mainLoss4'] = []
            self.resultsDict['mainLoss5'] = []      
            self.resultsDict['bgFlowLat'] = []
            self.resultsDict['bgFlowLoss'] = []
            self.resultsDict['bgFlowFrate'] = []
            self.resultsDict['callCount'] = []
            self.resultsDict['upFlowLat'] = []
            self.resultsDict['upFlowLoss'] = []        
            self.resultsDict['upFlowFrate'] = []
            self.resultsDict['upMosScore'] = []
            self.resultsDict['upMinMos'] = []
            self.resultsDict['downMinMos'] = []        
            self.resultsDict['upMinRvalue'] = []
            self.resultsDict['downMinRvalue'] = []
            self.resultsDict['upMaxJitter'] = []
            self.resultsDict['downMaxJitter'] = []   
            self.resultsDict['upMinFrate'] = []  
            self.resultsDict['downMinFrate'] = [] 
            self.resultsDict['upMaxFlowLoss'] = []
            self.resultsDict['downMaxFlowLoss'] = []
            self.resultsDict['upMaxFlowLat'] = []
            self.resultsDict['downMaxFlowLat'] = []  
            self.resultsDict['upMinFlowLat'] = []
            self.resultsDict['downMinFlowLat'] = []  
            self.resultsDict['bgMaxFlowLat'] = []
            self.resultsDict['bgMaxFlowLoss'] = []        
            self.resultsDict['bgMinFlowLat'] = []   
            self.resultsDict['bgMinFrate'] = []                                            
            self.resultsDict['upRvalue'] = []
            self.resultsDict['upJitter'] = []
            self.resultsDict['upLoss1'] = []
            self.resultsDict['upLoss2'] = []
            self.resultsDict['upLoss3'] = []
            self.resultsDict['upLoss4'] = []
            self.resultsDict['upLoss5'] = []    
            self.resultsDict['downFlowLat'] = []
            self.resultsDict['downFlowLoss'] = []
            self.resultsDict['downFlowFrate'] = []
            self.resultsDict['downMosScore'] = []
            self.resultsDict['downRvalue'] = []
            self.resultsDict['downJitter'] = []
            self.resultsDict['downLoss1'] = []
            self.resultsDict['downLoss2'] = []
            self.resultsDict['downLoss3'] = []
            self.resultsDict['downLoss4'] = []
            self.resultsDict['downLoss5'] = []  
        
            # Print out the AP's BSSID, SSID, RSSI and other info to the CSV file
            WE.WriteAPinformation(self.clientList)
            self.Print("\nTrial Number : %d\n" % (ll+1))  
            WE.WriteDetailedLog(['Trial Number : %d' % (ll+1)])  
            voiceNumFrames = int(self.voiceFrameRate * self.TransmitTime)  
            bkNumFrames = int(self.backgroundFrameRate * self.TransmitTime)
            voiceFlowList = []
                
            analysisDict = odict.OrderedDict()
            for flowName in self.bgFlowList.keys():
                analysisDict[flowName] = self.bgFlowList[flowName]
                                 
            self._createFlowGroup({}, 'runGroup')
    
            if self.voiceSearchMin != 1:
                for jj in range(0, self.voiceSearchMin-1):
                    for grpNum in range(0, self.numOfVoiceGrpPairs):
                        flowNamesAP = upLinkFlowNameListByAP[grpNum]                 
                        flowName = flowNamesAP[jj]                            
                        analysisDict[flowName] = self.FlowList[flowName]       
                        self._addFlowToFlowGroup('runGroup', flowName)  
                        voiceFlowList.append(flowName)                                                                                                    
                        flowNamesAP = downLinkFlowNameListByAP[grpNum]               
                        flowNameR = flowNamesAP[jj]                            
                        analysisDict[flowNameR] = self.FlowList[flowNameR]  
                        self._addFlowToFlowGroup('runGroup', flowNameR)     
                        voiceFlowList.append(flowNameR)
                        
            for ii in range(self.voiceSearchMin-1,self.voiceSearchMax):        
                self.Print("\nTrying %d call(s) per voice group pair\n" % (ii+1))      
                WE.WriteDetailedLog(['Trying %d call(s) per voice group pair' % (ii+1)])
                for grpNum in range(0, self.numOfVoiceGrpPairs):                             
                    flowNamesAP = upLinkFlowNameListByAP[grpNum]
                    flowName = flowNamesAP[ii]
                    analysisDict[flowName] = self.FlowList[flowName] 
                    self._addFlowToFlowGroup('runGroup', flowName) 
                    voiceFlowList.append(flowName)                                       
                    flowNamesAP = downLinkFlowNameListByAP[grpNum]    
                    flowNameR = flowNamesAP[ii]
                    analysisDict[flowNameR] = self.FlowList[flowNameR]
                    self._addFlowToFlowGroup('runGroup', flowNameR) 
                    voiceFlowList.append(flowNameR)

                # VPR 4370: calculate the number of frames per flow            
                for flowName in voiceFlowList:
                    WE.VCLtest("flow.read('%s')" % (flowName))
                    WE.VCLtest("flow.setNumFrames(%d)" % (voiceNumFrames))
                    WE.VCLtest("flow.write('%s')" % (flowName))     
                if self.backgroundType == 'TCP':
                    flowType = 'biflow'
                else:
                    flowType = 'flow'        
                for flowName in self.bgFlowList.keys():               
                    WE.VCLtest("%s.read('%s')" % (flowType, flowName))
                    WE.VCLtest("%s.setNumFrames(%d)" % (flowType, bkNumFrames))
                    WE.VCLtest("%s.write('%s')" % (flowType, flowName))   
                    
                WE.ClearAllCounter(self.CardList)   
                
                self._startFlowGroup("runGroup")                
                if len(self.bgFlowList) > 0:
                    self._startFlowGroup("BkGroup")   
                kk = 0
                while kk < self.TransmitTime:                          
                    time.sleep(1)
                    kk = kk + 1
                    self.Print("\r Call(s) in Progress : %d secs" % (kk))          
                                        
                WE.VCLtest("action.stopFlowGroup('%s')" % "runGroup", globals()) 
                if len(self.bgFlowList) > 0:
                    WE.VCLtest("action.stopFlowGroup('%s')" % "BkGroup", globals())
                                    
                WE.Sleep(self.SettleTime, 'SUT settle time')   
                if self.callAnalysis(analysisDict, ll+1) !=  True:
                    if ii == self.voiceSearchMin-1 :
                        self.brokeSlaAtMinCall = True
                    self.trialCalls_slafailed[ll]=int(self.numOfVoiceGrpPairs)*(ii+1) 
                    self.maxCapacityReached = True
                    self.testResults[str(ll+1)] = copy.deepcopy(self.resultsDict)
                    break 
                else:
                    self.testResults[str(ll+1)] = copy.deepcopy(self.resultsDict)
                    # store the current num of calls for this trial
                    self.trialMaxNumOfCalls[ll] = int(self.numOfVoiceGrpPairs)*(ii+1)
            
            WE.CheckEthLinkWifiClientState(self.CardList, self.clientList)        
            WE.VCLtest("flowGroup.destroy('runGroup')")   
                           
                
    def initReport(self):
        self.MyReport = WaveReport(os.path.join(self.LoggingDirectory, self.ReportFilename))
        if self.MyReport.Story == None:
            return
        self.MyReport.Title("Service Capacity Report", self.DUTinfo)
    
    
    def PrintRealtimeStats(self, Ethports, Wports):
        for ethport in Ethports:
            (txpkts, rxpkts, txrate, rxrate) = WE.GetPortstats(ethport)
            self.Print("\r%s : Txpkts - %d, Rxpkts - %d, Txrate - %d, Rxrate - %d\n" % (ethport, txpkts, rxpkts, txrate, rxrate))

        for wport in Wports:
            (txpkts, rxpkts, txrate, rxrate) = WE.GetPortstats(wport)
            self.Print("\r%s : Txpkts - %d, Rxpkts - %d, Txrate - %d, Rxrate - %d\n" % (wport, txpkts, rxpkts, txrate, rxrate))
        
    
    ##################################### MeasureFlow_Latency ###################################
    # Returns the average latency value of a flow
    #
    def MeasureFlow_Latency(self, flowName, portName):
        WE.VCLtest("flowStats.read('%s','%s')" % (portName, flowName))
        WE.VCLtest("flowStats.read('%s','%s')" % (portName, flowName))
        if flowStats.getRxFlowLatencyCountOverall() != 0:
            avgLatency = flowStats.getRxFlowSumLatencyOverall()/flowStats.getRxFlowLatencyCountOverall()
            avgLatency = avgLatency / 1000000.0
        else:
            avgLatency = 0    
        return avgLatency
    
    
    def MeasureFlow_OLOAD_FR_LossRate(self, flowName, srcPortName, destPortName, TestDuration):
        WE.WriteDetailedLog(['Flow Name', 'src_port', 'des_port', 'txFlowFramesOk', 'rxFlowFramesOk'])
        WE.VCLtest("flowStats.read('%s','%s')" % (srcPortName, flowName))
        TXframes = flowStats.txFlowFramesOk
        WE.VCLtest("flowStats.read('%s','%s')" % (destPortName, flowName))
        RXframes = flowStats.rxFlowFramesOk
        OfferedLoad = TXframes / float(TestDuration)
        frate = RXframes / float(TestDuration)
        flowType = 'flow'
        # Check if bk traffic type is TCP
        if "F_BK" in flowName and self.backgroundType == 'TCP': 
            flowType = 'biflow'
        WE.VCLtest("%s.read('%s')" % (flowType, flowName), globals())
        intendedRate = flow.getIntendedRate()
        txLoss = (intendedRate*TestDuration) - TXframes
        if txLoss < 0:
            txLoss = 0
        lossOnChannel = (TXframes - RXframes)
        if lossOnChannel < 0:
            lossOnChannel = 0
        perTotalLoss = ( (txLoss + lossOnChannel) * 100.0 )/ (intendedRate*TestDuration)
        WE.WriteDetailedLog([flowName, srcPortName, destPortName, TXframes, RXframes])        
        return (OfferedLoad, frate, perTotalLoss)
        
   
    def MeasureFlow_Jitter_Lossburst(self, flowName, portName):
        WE.VCLtest("flowStats.read('%s','%s')" % (portName, flowName))
        WE.VCLtest("flowStats.read('%s','%s')" % (portName, flowName))
        
        jitter = flowStats.getRxFlowSmoothedInterarrivalJitter() / 1000000.0
        loss2 = flowStats.getRxFlow2PacketLossNumber()
        loss3 = flowStats.getRxFlow3PacketLossNumber()
        loss4 = flowStats.getRxFlow4PacketLossNumber()
        loss5 = flowStats.getRxFlow5PacketLossNumber()
        loss1 = ( flowStats.getRxFlowOutOfSequenceFrames() - (loss2 +loss3 + loss4 +loss5) )
        
        return (jitter, loss1, loss2, loss3, loss4, loss5)

        

    ##################################### MeasureRvalue###################################
    # Returns the average latency value of a flow
    #
    def Measure_rvalue(self, flowName, portName, duration):
        rvalue = 0.0
        WE.VCLtest("flowStats.read('%s','%s')" % (portName, flowName))
        rvalue = flowStats.calcCumulativeRValue(flowName, duration, 0, 0)
        if rvalue < 0: 
            return 0 
        return rvalue        
    
    def callAnalysis(self, flowdict, trialNum):      
        return_flag = True         
        frateSum = 0
        perPacketLossSum = 0
        avgLatencySum = 0
        callCount = 0
        rvalueSum = 0
        mosSum = 0
        jitterSum = 0.0
        loss1Sum = 0
        loss2Sum = 0
        loss3Sum = 0
        loss4Sum = 0
        loss5Sum = 0
        upFrateSum = 0
        upMinFrate = 4294967295
        upMinRvalue = 4294967295
        upRvalueSum = 0
        upMosSum = 0
        upMinMos = 4294967295
        upMaxJitter = -1
        upMaxFlowLoss = -1
        upMaxFlowLat = -1
        upMinFlowLat = 4294967295
        bgMaxFlowLat = -1
        bgMaxFlowLoss = -1
        bgMinFlowLat = 4294967295
        bgMinFrate = 4294967295
        bgMinJitter = 4294967295
        upJitterSum = 0
        upLoss1Sum = 0
        upLoss2Sum = 0
        upLoss3Sum = 0
        upLoss4Sum = 0
        upLoss5Sum = 0
        upPerPacketLossSum = 0
        upAvgLatencySum = 0        
        downFrateSum = 0
        downMinFrate = 4294967295
        downMinRvalue = 4294967295
        downRvalueSum = 0
        downMosSum = 0
        downMinMos = 4294967295
        downMaxJitter = -1
        downMaxFlowLoss = -1
        downMaxFlowLat = -1
        downMinFlowLat = 4294967295
        downJitterSum = 0
        downLoss1Sum = 0
        downLoss2Sum = 0
        downLoss3Sum = 0
        downLoss4Sum = 0
        downLoss5Sum = 0
        downPerPacketLossSum = 0
        downAvgLatencySum = 0
                          
        self.testEndReason = 0
        self.testEndvalue = 0
        self.testEndDirection = "Uplink/Downlink"
               
        bgFrateSum = 0
        bgPerPacketLossSum = 0
        bgAvgLatencySum = 0
        bgJitterSum = 0
        bgCallCount = 0         
                
        for key in flowdict.keys():
            endDir = False
            tempDict = dict()
            tempDict[key] = flowdict[key]
            (oload, frate, perPacketLoss) = self.MeasureFlow_OLOAD_FR_LossRate(key, flowdict[key][0], flowdict[key][2], self.TransmitTime)            
            avgLatency = self.MeasureFlow_Latency(key, flowdict[key][2])
            (jitter, loss1, loss2, loss3, loss4, loss5) =  self.MeasureFlow_Jitter_Lossburst(key, flowdict[key][2])
            rvalue =  self.Measure_rvalue(key, flowdict[key][2], self.TransmitTime) 
            R = float(rvalue)
            mosScore = 0.0
            if R < 6.5:
                mosScore = 1.0
            elif R > 100:
                mosScore = 4.5
            else:                          
                mosScore = 1.0 - (7.0 * R / 1000.0) +  (7.0 * (R ** 2.0) / 6250.0) - (7.0 * (R ** 3.0)/ 1000000.0)
            
            if key in self.bgFlowList.keys():
                self.Print("\r%s : R-value - N/A OLOAD - %d pps, FWD RATE - %d pps, AVG LATENCY - %0.3f msecs PKT LOSS - %0.3f \n" % (key, oload, frate, avgLatency, perPacketLoss))  
                WE.WriteDetailedLog(['Flow Name', 'R-value', 'OLOAD', 'Fwd Rate', 'Avg Latency', 'Pkt Loss'])
                WE.WriteDetailedLog(['%s, %s, %d pps, %d pps, %0.3f msecs, %0.3f' % (key, 'N/A', oload, frate, avgLatency, perPacketLoss)])
            else:
                self.Print("\r%s : R-value - %0.3f OLOAD - %d pps, LOSS BURSTS - %d,%d,%d,%d,%d JITTER = %0.2f FWD RATE - %d pps, AVG LATENCY - %0.3f msecs PKT LOSS - %0.3f \n" % (key, R, oload, loss1, loss2, loss3, loss4, loss5, jitter, frate, avgLatency, perPacketLoss))  
                WE.WriteDetailedLog(['Flow Name', 'R-value', 'OLOAD', 'Loss burst', 'Jitter', 'Fwd Rate', 'Avg Latency', 'Pkt Loss'])
                WE.WriteDetailedLog(['%s, %0.3f, %d pps, %d %d %d %d %d, %0.2f, %d pps, %0.3f, %0.3f' % (key, R, oload, loss1, loss2, loss3, loss4, loss5, jitter, frate, avgLatency, perPacketLoss)])
            if key not in self.bgFlowList.keys():
                frateSum = frateSum + frate
                rvalueSum = rvalueSum + rvalue
                mosSum = mosSum + mosScore
                jitterSum = jitterSum + jitter
                loss1Sum = loss1Sum + loss1
                loss2Sum = loss2Sum + loss2
                loss3Sum = loss3Sum + loss3
                loss4Sum = loss4Sum + loss4
                loss5Sum = loss5Sum + loss5
                perPacketLossSum = perPacketLossSum + perPacketLoss
                avgLatencySum = avgLatencySum + avgLatency
                
                if key in self.upLinkMainFlowList: 
                    upMinRvalue = min(upMinRvalue, rvalue)
                    upMinMos = min(upMinMos, mosScore)
                    upMaxJitter = max(upMaxJitter, jitter)
                    upMinFrate = min(upMinFrate, frate)
                    upMaxFlowLoss = max(upMaxFlowLoss, perPacketLoss)
                    upMaxFlowLat = max(upMaxFlowLat, avgLatency)
                    upMinFlowLat = min(upMinFlowLat, avgLatency)
                    upFrateSum = upFrateSum + frate
                    upRvalueSum = upRvalueSum + rvalue
                    upMosSum = upMosSum + mosScore
                    upJitterSum = upJitterSum + jitter
                    upLoss1Sum = upLoss1Sum + loss1
                    upLoss2Sum = upLoss2Sum + loss2
                    upLoss3Sum = upLoss3Sum + loss3
                    upLoss4Sum = upLoss4Sum + loss4
                    upLoss5Sum = upLoss5Sum + loss5
                    upPerPacketLossSum = upPerPacketLossSum + perPacketLoss
                    upAvgLatencySum = upAvgLatencySum + avgLatency
                else:    
                    downMinRvalue = min(downMinRvalue, rvalue)
                    downMinMos = min(downMinMos, mosScore)
                    downMaxJitter = max(downMaxJitter, jitter)
                    downMinFrate = min(downMinFrate, frate)
                    downMaxFlowLoss = max(downMaxFlowLoss, perPacketLoss)
                    downMaxFlowLat = max(downMaxFlowLat, avgLatency)
                    downMinFlowLat = min(downMinFlowLat, avgLatency)       
                    downFrateSum = downFrateSum + frate
                    downRvalueSum = downRvalueSum + rvalue
                    downMosSum = downMosSum + mosScore
                    downJitterSum = downJitterSum + jitter
                    downLoss1Sum = downLoss1Sum + loss1
                    downLoss2Sum = downLoss2Sum + loss2
                    downLoss3Sum = downLoss3Sum + loss3
                    downLoss4Sum = downLoss4Sum + loss4
                    downLoss5Sum = downLoss5Sum + loss5
                    downPerPacketLossSum = downPerPacketLossSum + perPacketLoss
                    downAvgLatencySum = downAvgLatencySum + avgLatency
                
                callCount = callCount + 1  
                
                if self.slaMode == "R-Value":
                    if rvalue < self.slaRvalue:
                        self.testEndReason = 1
                        if self.check_flag == 0:
                            self.testEndvalue = rvalue 
                            self.check_flag=1 
                        if rvalue < self.testEndvalue:
                            self.testEndvalue = rvalue
                        return_flag = False
                        endDir = True
                else:
                    if avgLatency > self.slaMaxLatency:
                        self.testEndReason = 2
                        self.testEndvalue = avgLatency
                        return_flag = False
                        endDir = True
                        
                    if perPacketLoss > self.slaMaxPktLoss:
                        self.testEndReason = 3
                        self.testEndvalue = perPacketLoss
                        return_flag = False  
                        endDir = True
                        
                    if jitter > self.slaMaxJitter:
                        self.testEndReason = 4
                        self.testEndvalue = jitter
                        return_flag = False     
                        endDir = True
            
                if endDir == True:
                    if key in self.upLinkMainFlowList:
                        self.testEndDirection = "Uplink"
                    else:
                        self.testEndDirection = "Downlink"  
            else:
                bgMinJitter = min(bgMinJitter, jitter)
                bgMaxFlowLat = max(bgMaxFlowLat, avgLatency)
                bgMinFlowLat = min(bgMinFlowLat, avgLatency)
                bgMinFrate = min(bgMinFrate, frate)
                bgMaxFlowLoss = max(bgMaxFlowLoss, perPacketLoss)
                bgFrateSum = bgFrateSum + frate
                bgPerPacketLossSum = bgPerPacketLossSum + perPacketLoss
                bgAvgLatencySum = bgAvgLatencySum + avgLatency
                bgJitterSum = bgJitterSum + jitter
                bgCallCount = bgCallCount + 1
        
        bgLoad = (bgFrateSum * self.backgroundFrameSize * 8.0)/ 1000000.0
        
        self.Print("\rTotal Call(s) %d : avg FWD RATE - %d pps, avg LATENCY - %0.3f msecs avg PKT LOSS - %0.3f percent avg R Value - %0.2f\n" % (callCount/2, frateSum/callCount, avgLatencySum/callCount, perPacketLossSum/callCount, rvalueSum/callCount))  
        WE.WriteDetailedLog(['Total Call(s)', 'avg FWD RATE', 'avg LATENCY', 'avg PKT LOSS', 'avg R Value'])
        WE.WriteDetailedLog(['%d, %d pps, %0.3f msecs, %0.3f percent, %0.2f' % (callCount/2, frateSum/callCount, avgLatencySum/callCount, perPacketLossSum/callCount, rvalueSum/callCount)])
        if bgCallCount > 0:
            self.Print("\rTotal BKFlows %d : achievedLoad - %0.2f Mbps avg FWD RATE - %d pps, avg LATENCY - %0.3f msecs avg LOSS - %0.3f percent\n" % (bgCallCount, bgLoad, bgFrateSum/bgCallCount, bgAvgLatencySum/bgCallCount, bgPerPacketLossSum/bgCallCount))  
            WE.WriteDetailedLog(['Total BKFlows', 'achievedLoad', 'avg FWD RATE', 'avg LATENCY', 'avg PKT LOSS'])                                        
            WE.WriteDetailedLog(['%d, %0.2f Mbps, %d pps, %0.3f msecs, %0.3f percent' % (bgCallCount*2, bgLoad, bgFrateSum/bgCallCount, bgAvgLatencySum/bgCallCount, bgPerPacketLossSum/bgCallCount)])
        else:    
            self.Print("\rTotal BKFlows %d : achievedLoad - %0.2f Mbps avg FWD RATE - %d pps, avg LATENCY - %0.3f msecs avg PKT LOSS - %0.3f percent\n" % (0, 0, 0, 0, 0))  
            WE.WriteDetailedLog(['Total BKFlows', 'achievedLoad', 'avg FWD RATE', 'avg LATENCY', 'avg PKT LOSS'])
            WE.WriteDetailedLog(['%d, %0.2f Mbps, %d pps, %0.3f msecs, %0.3f percent' % (0, 0, 0, 0, 0)])
        if return_flag == True or (callCount/2) == self.voiceSearchMin:    #We want the values, in case SLA is broken with min calls so the other condition (callCount/2)...
            self.resultNumCalls = callCount#/self.numAps
            self.resultFrate = round(min(upMinFrate, downMinFrate),2)
            self.resultAvgLatency = round(max(upMaxFlowLat, downMaxFlowLat), 2)
            self.resultMos = round(min(upMinMos, downMinMos), 2) 
            self.resultRvalue = round(min(upMinRvalue, downMinRvalue), 2)            
            self.resultJitter = round(max(upMaxJitter, downMaxJitter), 2)
            self.resultLoss1 = round(loss1Sum/callCount,2)
            self.resultLoss2 = round(loss2Sum/callCount,2)
            self.resultLoss3 = round(loss3Sum/callCount,2)
            self.resultLoss4 = round(loss4Sum/callCount,2)
            self.resultLoss5 = round(loss5Sum/callCount,2)            
            self.resultPerPacketLoss = round(max(upMaxFlowLoss, downMaxFlowLoss),2)
            if bgCallCount > 0:
                self.resultBgNumCalls = bgCallCount#/self.numAps
                self.resultBgFrate = round(bgMinFrate, 2)
                self.resultBgJitter = round(bgMinJitter,2)            
                self.resultBgLoadMbps = round(bgLoad,2)
                self.resultBgAvgLatency =  round(bgMaxFlowLat, 2)
                self.resultBgPerPacketLoss = round(bgMaxFlowLoss, 2)
            else:
                self.resultBgNumCalls = self.resultBgFrate = self.resultBgJitter = \
                self.resultBgLoadMbps = self.resultBgAvgLatency = self.resultBgPerPacketLoss
                
        self.resultsDict['trialNum'].append(trialNum) 
        self.resultsDict['mainFlowLat'].append(round(avgLatencySum/callCount,2)) 
        self.resultsDict['mainFlowLoss'].append(round(perPacketLossSum/callCount,2))
        self.resultsDict['mainFlowFrate'].append(round(frateSum/callCount,2))
        self.resultsDict['mainMosScore'].append(round(mosSum/callCount,2))
        self.resultsDict['mainRvalue'].append(round(rvalueSum/callCount,2))
        self.resultsDict['mainJitter'].append(round(jitterSum/callCount,2))
        self.resultsDict['mainLoss1'].append(round(loss1Sum/callCount,2))
        self.resultsDict['mainLoss2'].append(round(loss2Sum/callCount,2))
        self.resultsDict['mainLoss3'].append(round(loss3Sum/callCount,2))
        self.resultsDict['mainLoss4'].append(round(loss4Sum/callCount,2))
        self.resultsDict['mainLoss5'].append(round(loss5Sum/callCount,2))         
        self.resultsDict['upFlowLat'].append(round(upAvgLatencySum*2/callCount,2)) 
        self.resultsDict['upFlowLoss'].append(round(upPerPacketLossSum*2/callCount,2))
        self.resultsDict['upFlowFrate'].append(round(upFrateSum*2/callCount,2))
        self.resultsDict['upMosScore'].append(round(upMosSum*2/callCount,2))
        self.resultsDict['upMinMos'].append(round(upMinMos,2))
        self.resultsDict['downMinMos'].append(round(downMinMos,2))        
        self.resultsDict['upMinRvalue'].append(round(upMinRvalue,2))
        self.resultsDict['downMinRvalue'].append(round(downMinRvalue,2))
        self.resultsDict['upMaxJitter'].append(round(upMaxJitter,2))
        self.resultsDict['downMaxJitter'].append(round(downMaxJitter,2))
        self.resultsDict['upMinFrate'].append(round(upMinFrate,2))
        self.resultsDict['downMinFrate'].append(round(downMinFrate,2)) 
        self.resultsDict['upMaxFlowLoss'].append(round(upMaxFlowLoss,2))
        self.resultsDict['downMaxFlowLoss'].append(round(downMaxFlowLoss,2))   
        self.resultsDict['upMaxFlowLat'].append(round(upMaxFlowLat,2))
        self.resultsDict['downMaxFlowLat'].append(round(downMaxFlowLat,2))   
        self.resultsDict['upMinFlowLat'].append(round(upMinFlowLat,2))
        self.resultsDict['downMinFlowLat'].append(round(downMinFlowLat,2))                   
        self.resultsDict['upRvalue'].append(round(upRvalueSum*2/callCount,2))
        self.resultsDict['upJitter'].append(round(upJitterSum*2/callCount,2))
        self.resultsDict['upLoss1'].append(round(upLoss1Sum*2/float(callCount),2))
        self.resultsDict['upLoss2'].append(round(upLoss2Sum*2/float(callCount),2))
        self.resultsDict['upLoss3'].append(round(upLoss3Sum*2/float(callCount),2))
        self.resultsDict['upLoss4'].append(round(upLoss4Sum*2/float(callCount),2))
        self.resultsDict['upLoss5'].append(round(upLoss5Sum*2/float(callCount),2))        
        self.resultsDict['downFlowLat'].append(round(downAvgLatencySum*2/callCount,2)) 
        self.resultsDict['downFlowLoss'].append(round(downPerPacketLossSum*2/callCount,2))
        self.resultsDict['downFlowFrate'].append(round(downFrateSum*2/callCount,2))
        self.resultsDict['downMosScore'].append(round(downMosSum*2/callCount,2))
        self.resultsDict['downRvalue'].append(round(downRvalueSum*2/callCount,2))
        self.resultsDict['downJitter'].append(round(downJitterSum*2/callCount,2))
        self.resultsDict['downLoss1'].append(round(downLoss1Sum*2/float(callCount),2))
        self.resultsDict['downLoss2'].append(round(downLoss2Sum*2/float(callCount),2))
        self.resultsDict['downLoss3'].append(round(downLoss3Sum*2/float(callCount),2))
        self.resultsDict['downLoss4'].append(round(downLoss4Sum*2/float(callCount),2))
        self.resultsDict['downLoss5'].append(round(downLoss5Sum*2/float(callCount),2))   
        if bgCallCount > 0:     
            self.resultsDict['bgFlowLat'].append(round(bgAvgLatencySum/bgCallCount,2))
            self.resultsDict['bgFlowLoss'].append(round(bgPerPacketLossSum/bgCallCount,2))
            self.resultsDict['bgFlowFrate'].append(round(bgFrateSum/bgCallCount,2))
            self.resultsDict['bgMaxFlowLoss'].append(round(bgMaxFlowLoss,2))
            self.resultsDict['bgMaxFlowLat'].append(round(bgMaxFlowLat,2))
            self.resultsDict['bgMinFlowLat'].append(round(bgMinFlowLat,2))   
            self.resultsDict['bgMinFrate'].append(round(bgMinFrate,2))            
        else:
            self.resultsDict['bgFlowLat'].append(0)
            self.resultsDict['bgFlowLoss'].append(0)
            self.resultsDict['bgFlowFrate'].append(0)  
            self.resultsDict['bgMaxFlowLoss'].append(0)
            self.resultsDict['bgMaxFlowLat'].append(0)
            self.resultsDict['bgMinFlowLat'].append(0)   
            self.resultsDict['bgMinFrate'].append(0)   
                   
        #self.resultsDict['callCount'].append(str(callCount/(self.numAps*2)))
        self.resultsDict['callCount'].append(str(callCount/2))                  
        return return_flag       
    
    def run(self):
        self.ClientgrpFlows = {}    
        self.upLinkMainFlowListPerAP = []   
        self.upLinkMainFlowList = [] 
        self.downLinkMainFlowListPerAP = []     
        self.FlowList = odict.OrderedDict()
        self.resultsDict = odict.OrderedDict()
        self.numAps = 1        
        numCalls = self.voiceSearchMax
        
        #FIX ME- Split this into logical groups (methods). It mixes all sorts of tasks
        #into one method.
        
        try:
            self.ExitStatus = 0
            WE.OpenLogging(Path=self.LoggingDirectory, Detailed=self.DetailedFilename)
            self.configurePorts()
            #if self.validateConfigs() == -1:
            #    raise WE.RaiseException            
            self.initReport()
            self.initailizeCSVfile()            
            for clientgroup in self.ClientGroups:
                if self.ClientGroups[clientgroup]['clientCount'] != "Fixed":
                    self.ClientGroups[clientgroup]['NumClients'] = numCalls           
            clientTuples = self.createClientTuple(self.ClientGroups)
            self.createClientsForTopology(clientTuples)
            #Related to VPR 4202. We want the MAC addresses to be distinct and also be set 
            #consistently. See the usage of the variable _ClientMACCounter in WaveEngine
            WE.SetClientMACCounter()    
            (self.ClientgrpClients, 
             self.clientList)         = self.createClients(clientTuples)
            
            self.connectClients(self.clientList)       
            WE.ClientLearning(self.clientList, self.ClientLearningTime, 
                    self.ClientLearningRate)
            groupnames = self.ClientGroups.keys()
            groupnames.sort()
            for name in groupnames:
                if bool(self.ClientGroups[name]['Enable']) == True:
                    self.createflows(name)  
            self._configureClientObjectsFlows(self.FlowList) 
            if self.configureFlows() == -1:
                raise WE.RaiseException
            self.setNATflag()       
            
            if self.backgroundType == 'TCP':
                # do biflow.connect
                if WE.ConnectBiflow(bgFlows.keys()) < 0:
                    self.SavePCAPfile = True
                    raise WE.RaiseException                
            self.doArpExchanges()            

            upLinkFlowNameList = []
            downLinkFlowNameList = []
            for i in range(0, self.numOfVoiceGrpPairs):
                upLinkFlowNameList.append([])
                downLinkFlowNameList.append([])

            flowNames = self.FlowList.keys()
            if flowNames == []:
                raise WE.RaiseException
            
            # Figuring out uplink/downlink flows. The convension used here is, for Ethernet to Wireless,
            # the flow originating from wireless is uplink, downlink otherwise.
            # For Ethernet to Ethernet or Wireless to Wireless, the uplink flow is
            # the flow from the clients in the first group to the second group in the group pair.

            # separate the flows into uplink & downlink groups, each group
            # will be separated based on their APs (or group #)
            if self.trafficDirection in ['Ethernet To Ethernet', 'Wireless To Wireless']:
                for j in range(0, self.numOfVoiceGrpPairs):
                    for k in range(0, self.voiceSearchMax):
                        incr = j * self.voiceSearchMax * 2
                        self.upLinkMainFlowList.append(flowNames[k+incr])
                        upLinkFlowNameList[j].append(flowNames[k+incr]) 
                                                                                   
                        downLinkFlowNameList[j].append(flowNames[k+self.voiceSearchMax+incr])
            else:
                for j in range(0, self.numOfVoiceGrpPairs):
                    for k in range(0, self.voiceSearchMax*2):
                        i = flowNames.pop(0)
                        if self.FlowList[i][0] in self.wifiCardList:
                            # if drops here, it's an uplink flow (wifi to eth)
                            self.upLinkMainFlowList.append(i)
                            upLinkFlowNameList[j].append(i)
                        else:
                            # if drops here, it's a downlink flow (eth to wifi)
                            downLinkFlowNameList[j].append(i)
                                                                          
            # save the uplink & downlink flows          
            self.upLinkMainFlowListPerAP=upLinkFlowNameList
            self.downLinkMainFlowListPerAP=downLinkFlowNameList
            
            # figure out the number of APs
            if len(self.wifiCardList) == 0:
                # If drop here, it's Ethernet to Ethernet traffic 
                # Assumption made: each Ethernet client group pair is connected through 1 AP
                self.numAps = len(self.ethCardList) / 2
            else:
                # Assumption made: each wireless card is connected to 1 AP  
                self.numAps = len(self.wifiCardList) 
        
            self.testParameters['Number of APs'] = self.numAps   
            self.startTest(self.upLinkMainFlowListPerAP, self.downLinkMainFlowListPerAP)
            
            self.MyReport.InsertHeader("Overview")
            
            self.MyReport.InsertParagraph("The VoIP QoS Service Capacity test \
            determines the maximum number of VoIP calls the System Under Test (SUT) \
            can maintain at a specified Service Level Agreement (SLA) in the presence of \
            best effort traffic load. The SLA can be specified as an R-value or \
            as a combination of maximum latency, packet loss and jitter.")
            
            self.MyReport.InsertHeader("Results Summary")
            if self.slaMode == "R-Value":
                slaSpecified = "R-value:%0.1f" % self.slaRvalue
            else:
                slaSpecified = "Maximum Latency(ms):%0.1f, PacketLoss(%%):%0.1f and Jitter(ms):%0.1f" \
                % (self.slaMaxLatency, self.slaMaxPktLoss, self.slaMaxJitter)            
            if self.brokeSlaAtMinCall == True:
                totalPass = 0
                for i in self.trialMaxNumOfCalls:                
                    totalPass += i
                if totalPass == 0:
                    self.MyReport.InsertParagraph("The SLA specified by the user was broken with \
                    the minimum number of calls configured by the user. Please try testing by reducing \
                    the minimum number of calls or the background traffic rate.")
                 #In the print statements below we use (self.resultNumCalls/2 +1), which
                 #is appropriate when we broke the SLA at call x+1 and the statistics 
                 #were collected at call 'x' (i.e., at condition return_flag == True in 
                 #callAnalysis()) but here the statistics were collected at the condition
                 #'or (callCount/2) == self.voiceSearchMin' in callAnalysis(), so
                if self.resultNumCalls > 1:
                    self.resultNumCalls -= 2 
                                     
            if self.Trials > 1:
                minCalls = 4294967295
                maxCalls = 0
                meanCalls = 0
                stdDev = 0
                for i in self.trialMaxNumOfCalls:
                    minCalls = min(minCalls, i)
                    maxCalls = max(maxCalls, i)
                    meanCalls += i
                meanCalls = meanCalls / float(self.Trials)
                for i in self.trialMaxNumOfCalls:
                    stdDev += pow((i-meanCalls),2)
                stdDev = sqrt (1/float(self.Trials) * stdDev) 

                resSummary = [('Num of Trials', 'Min Num of Calls', 'Max Num of Calls', 
                               'Mean Num of Calls', 'Standard Deviation')]
                resultTuple = (self.Trials, minCalls, maxCalls, meanCalls, stdDev)
                resSummary.append(resultTuple)
                self.MyReport.InsertDetailedTable(resSummary, columns=[0.6*inch, 0.8*inch, 0.8*inch, 0.8*inch, 0.8*inch])

            self.MyReport.InsertParagraph("The following graph shows the number of calls that met the specified SLA (%s) for each trial." % (slaSpecified))
            #'adjustedTrailNum' Used for displaying in graph, we want the trial 
            #numbers to start from 1 rather than 0 used in indexing
            adjustedTrialNums = [str((int(val)+1)) for val in range(0, self.Trials)] 
            intCallCount = [] 
            for i in self.trialMaxNumOfCalls:                
                intCallCount.append(i)   
                
            graphSummary = Qlib.GenericGraph (adjustedTrialNums, "Trial Number", [intCallCount,] \
                    , "Number of Calls", "Number of Calls Meeting SLA", ['Bar'], yAxisDigits=1, dataLblDigits=0)
            self.MyReport.InsertObject(graphSummary)
            self.finalGraphs["Number of Calls Meeting SLA"] = graphSummary                    
            
            if self.Trials == 1 and self.brokeSlaAtMinCall == False:  
                self.MyReport.InsertParagraph("The overall maximum number of voice calls with %0.2f Mbps "\
                         " background (BK) traffic is %d." % (self.resultBgLoadMbps, self.trialMaxNumOfCalls[0]) )
                              
                self.MyReport.InsertParagraph("The following table shows the overall maximum number of "\
                                              "voice calls supported by the SUT using the "\
                                              "given performance specifications and the performance "\
                                              "of the voice and low-priority background traffic.")
                                                                    
                resSummary = [('Flow Type', 'Total Flows', 'Min R-value', 'Min MOS', 'Min Fwd Rate (pps)', 'Max Latency (msecs)', 'Max Jitter (msecs)', 'Max % Packet Loss')]
                resultTuple = ('Voice Traffic', self.trialMaxNumOfCalls[0]*2, self.resultRvalue, self.resultMos, self.resultFrate, self.resultAvgLatency, self.resultJitter, self.resultPerPacketLoss)
                resSummary.append(resultTuple)
                if self.bgTrafficBidirFlag == True:
                    bgNumCalls = self.resultBgNumCalls / 2
                else:
                    bgNumCalls = str(self.resultBgNumCalls) + "(Unidirectional)"
                resultTuple = ('BK Traffic', bgNumCalls*2, "    N/A    ", "    N/A    ", self.resultBgFrate, self.resultBgAvgLatency, self.resultBgJitter, self.resultBgPerPacketLoss)
                resSummary.append(resultTuple)
                self.MyReport.InsertDetailedTable(resSummary, columns=[1.0*inch, 1.15*inch, 0.6*inch, 0.55*inch, 0.8*inch, 0.8*inch, 0.8*inch, 0.6*inch])
            self.resultNumCalls=(self.trialCalls_slafailed[0]-1)*2
            if self.maxCapacityReached == False:
                self.MyReport.InsertParagraph("Note: The reported maximum number of voice calls is "\
                                              "not necessarily the maximum capacity for the AP. The "\
                                              "test stopped because it reached the maximum number "\
                                              "of calls specified for the test.")
                                              
            elif self.Trials == 1:
                if self.slaMode == "R-Value":              
                    self.MyReport.InsertParagraph("When %d calls were placed, an R-value of %f was measured"\
                      " on one of the %s voice flows which is below the acceptable R-value of %.2f" % \
                      ((self.resultNumCalls/2 + 1), self.testEndvalue, self.testEndDirection, self.slaRvalue) )   
                else:
                    if self.testEndReason == 2:
                        self.MyReport.InsertParagraph("When %d calls were placed, a Latency of %f msecs was measured"\
                          " on one of the %s voice flows which is above the acceptable latency of %.2f msecs" % \
                       ((self.resultNumCalls/2 + 1), self.testEndvalue, self.testEndDirection, self.slaMaxLatency) )   
                    elif self.testEndReason == 3:
                        self.MyReport.InsertParagraph("When %d calls were placed, a Packet Loss of %f percent was measured"\
                          " on one of the %s voice flows which is above the acceptable packetloss of %.2f percent" % \
                           ((self.resultNumCalls/2 + 1), self.testEndvalue, self.testEndDirection, self.slaMaxPktLoss) ) 
                    else:    
                        self.MyReport.InsertParagraph("When %d calls were placed, a Jitter of %f msecs was measured"\
                          " on one of the %s voice flows which is above the acceptable Jitter of %.2f msecs" % \
                           ((self.resultNumCalls/2 + 1), self.testEndvalue, self.testEndDirection, self.slaMaxJitter) )             
            self.MyReport.InsertParagraph("Note: In this report the reporting structure will be in terms of overall calls meeting the SLA. The maximum calls/AP will depend on the mapping and topolgy.")
            self.MyReport.InsertHeader( "Methodology" )
            self.MyReport.InsertParagraph("The test creates the specified client pairs for VoIP calls and one client pair for background (BK) traffic. Bidirectional VoIP flows are established between the clients on one port and the corresponding clients on another port. VoIP flows must meet the specified service level agreement (SLA). Background flows are created between the corresponding clients using the specified background traffic load.") 
            self.MyReport.InsertParagraph("The test performs a linear search to find the maximum number of voice calls the system under test (SUT) can maintain.")
            self.MyReport.InsertParagraph("Traffic direction can be Ethernet to wireless, Ethernet to Ethernet or wireless to wireless. For Ethernet to wireless traffic, flows originating from the wireless clients are called uplink flows and flows originating from Ethernet clients are called downlink flows. For Ethernet to Ethernet or wireless to wireless flows, flows originating from the clients in the first group in a pair are called uplink flows and flows originating from the clients in the second group are called downlink flows.")
                                          
            self.MyReport.InsertHeader( "Topology" )
            self.MyReport.InsertParagraph("The following diagram shows the test topology. Each box indicates the port identifiers and IP addresses for the test clients; for wireless clients the security mode and channel ID is also shown. The arrows show the direction of the traffic.") 

            self.MyReport.InsertClientMap( self.SourceClients, self.DestClients, True, self.CardMap )
                        
            self.MyReport.InsertPageBreak()            
            
            if self.Trials > 1:              
                trialMinUp = []
                trialMinDown = []
                trialAvgUp = []
                trialAvgDown = []
                trialAvg = []
                trialList = [str((int(val)+1)) for val in range(0, self.Trials)] 
                # Calculate min & avg R-value for uplink & downlink traffic
                for trialNum in trialList:
                    trialMinUp.append(self.testResults[trialNum]['upMinRvalue'][-1])
                    trialMinDown.append(self.testResults[trialNum]['downMinRvalue'][-1])
                    trialAvgUp.append(self.testResults[trialNum]['upRvalue'][-1])
                    trialAvgDown.append(self.testResults[trialNum]['downRvalue'][-1])
                    trialAvg.append(self.testResults[trialNum]['mainRvalue'][-1])
                self.MyReport.InsertParagraph("The following graph plots the minimum and average R-value for voice calls for each trial." )
                graphRVal = Qlib.GenericGraph( 
                    trialList, # x values which is the trial numbers
                    "Trials",  # x label
                    list((trialMinUp,trialAvgUp,trialMinDown,trialAvgDown,trialAvg)), # list of y values
                    "R-value", # y label 
                    "Min & Avg R-value per Trial", # graphtitle
                    ['Bar'], # graph type
                    [["Min Uplink R-value"], ["Avg Uplink R-value"], # legends
                     ["Min Downlink R-value"], ["Avg Downlink R-value"], ["Avg R-value"]]
                )       
                self.MyReport.InsertObject(graphRVal)
                self.finalGraphs['Min & Avg R-value per Trial'] =  graphRVal       
                
                # Calculate min & avg MOS score for uplink & downlink traffic
                trialMinUp = []
                trialMinDown = []
                trialAvgUp = []
                trialAvgDown = []     
                trialAvg = []           
                for trialNum in trialList:
                    trialMinUp.append(self.testResults[trialNum]['upMinMos'][-1])
                    trialMinDown.append(self.testResults[trialNum]['downMinMos'][-1])
                    trialAvgUp.append(self.testResults[trialNum]['upMosScore'][-1])
                    trialAvgDown.append(self.testResults[trialNum]['downMosScore'][-1])
                    trialAvg.append(self.testResults[trialNum]['mainMosScore'][-1])                    
                self.MyReport.InsertParagraph("The following graph plots the minimum and average MOS score for voice calls for each trial." )
                graphMos = Qlib.GenericGraph( 
                    trialList, # x values which is the trial numbers
                    "Trials",  # x label
                    list((trialMinUp,trialAvgUp,trialMinDown,trialAvgDown,trialAvg)), # list of y values
                    "MOS Score", # y label 
                    "Min & Avg MOS Score per Trial", # graphtitle
                    ['Bar'], # graph type
                    [["Min Uplink MOS Score"], ["Avg Uplink MOS Score"], # legends
                     ["Min Downlink MOS Score"], ["Avg Downlink MOS Score"], ["Avg MOS Score"]]
                )       
                self.MyReport.InsertObject(graphMos)
                self.finalGraphs['Min & Avg MOS Score per Trial'] =  graphMos  
                              
                # Calculate max & avg Jitter for uplink & downlink traffic
                trialMinUp = []
                trialMinDown = []
                trialAvgUp = []
                trialAvgDown = []                
                for trialNum in trialList:
                    trialMinUp.append(self.testResults[trialNum]['upMaxJitter'][-1])
                    trialMinDown.append(self.testResults[trialNum]['downMaxJitter'][-1])
                    trialAvgUp.append(self.testResults[trialNum]['upJitter'][-1])
                    trialAvgDown.append(self.testResults[trialNum]['downJitter'][-1])
                self.MyReport.InsertParagraph("The following graph plots the maximum and average jitter for voice calls for each trial." )
                graphJitter = Qlib.GenericGraph( 
                    trialList, # x values which is the trial numbers
                    "Trials",  # x label
                    list((trialMinUp,trialAvgUp,trialMinDown,trialAvgDown)), # list of y values
                    "Jitter(msecs)", # y label 
                    "Max & Avg Voice Jitter per Trial", # graphtitle
                    ['Bar'], # graph type
                    [["Max Uplink Jitter"], ["Avg Uplink Jitter"], # legends
                     ["Max Downlink Jitter"], ["Avg Downlink Jitter"]]
                )       
                self.MyReport.InsertObject(graphJitter)
                self.finalGraphs['Max & Avg Voice Jitter per Trial'] =  graphJitter  
                
                # Calculate max & avg latency for uplink & downlink traffic
                trialAvgUp = []
                trialAvgDown = []
                trialMaxUp = []
                trialMaxDown = []               
                for trialNum in trialList:
                    trialAvgUp.append(self.testResults[trialNum]['upFlowLat'][-1])
                    trialAvgDown.append(self.testResults[trialNum]['downFlowLat'][-1])
                    trialMaxUp.append(self.testResults[trialNum]['upMaxFlowLat'][-1])
                    trialMaxDown.append(self.testResults[trialNum]['downMaxFlowLat'][-1])                                       
                self.MyReport.InsertParagraph("The following graph plots the maximum and average latency for voice calls for each trial." )
                graphLat = Qlib.GenericGraph( 
                    trialList, # x values which is the trial numbers
                    "Trials",  # x label
                    list((trialMaxUp,trialAvgUp,trialMaxDown,trialAvgDown)), # list of y values
                    "Latency(msecs)", # y label 
                    "Max & Avg Voice Latency per Trial", # graphtitle
                    ['Bar'], # graph type
                    [["Max Uplink Latency"], ["Avg Uplink Latency"],
                     ["Max Downlink Latency"], ["Avg Downlink Latency"]]
                )       
                self.MyReport.InsertObject(graphLat)
                self.finalGraphs['Max & Avg Voice Latency per Trial'] =  graphLat                 
                
                # Calculate avg loss burst for uplink traffic
                strLoss1 = []
                strLoss2 = []
                strLoss3 = []
                strLoss4 = []
                strLoss5 = []
                for trialNum in trialList:
                    strLoss1.append(round(self.testResults[trialNum]['upLoss1'][-1], 1))
                    strLoss2.append(round(self.testResults[trialNum]['upLoss2'][-1], 1))
                    strLoss3.append(round(self.testResults[trialNum]['upLoss3'][-1], 1))
                    strLoss4.append(round(self.testResults[trialNum]['upLoss4'][-1], 1))
                    strLoss5.append(round(self.testResults[trialNum]['upLoss5'][-1], 1))                
                self.MyReport.InsertParagraph("The following graph plots the average packet loss burst for uplink voice calls for each trial." )
                graphUpLoss = Qlib.GenericGraph( 
                    trialList, # x values which is the trial numbers
                    "Trials",  # x label
                    list((strLoss1,strLoss2,strLoss3,strLoss4,strLoss5)), # list of y values
                    "Average Packet Loss Burst Count", # y label 
                    "Avg Uplink Voice Packet Loss Burst per Trial", # graphtitle
                    ['Bar'], # graph type
                    [["1 Packet Burst"],["2 Packet Burst"],["3 Packet Burst"],
                     ["4 Packet Burst"],["5 Packet Burst"]],
                    xAxisDigits = 0, yAxisDigits = 1, dataLblDigits = 1
                )       
                self.MyReport.InsertObject(graphUpLoss)
                self.finalGraphs['Avg Uplink Voice Packet Loss Burst per Trial'] =  graphUpLoss                 

                # Calculate avg loss burst for downlink traffic
                strLoss1 = []
                strLoss2 = []
                strLoss3 = []
                strLoss4 = []
                strLoss5 = []
                for trialNum in trialList:
                    strLoss1.append(round(self.testResults[trialNum]['downLoss1'][-1], 1))
                    strLoss2.append(round(self.testResults[trialNum]['downLoss2'][-1], 1))
                    strLoss3.append(round(self.testResults[trialNum]['downLoss3'][-1], 1))
                    strLoss4.append(round(self.testResults[trialNum]['downLoss4'][-1], 1))
                    strLoss5.append(round(self.testResults[trialNum]['downLoss5'][-1], 1))                
                self.MyReport.InsertParagraph("The following graph plots the average packet loss burst for downlink voice calls for each trial." )
                graphDownLoss = Qlib.GenericGraph( 
                    trialList, # x values which is the trial numbers
                    "Trials",  # x label
                    list((strLoss1,strLoss2,strLoss3,strLoss4,strLoss5)), # list of y values
                    "Average Packet Loss Burst Count", # y label 
                    "Avg Downlink Voice Packet Loss Burst per Trial", # graphtitle
                    ['Bar'], # graph type
                    [["1 Packet Burst"],["2 Packet Burst"],["3 Packet Burst"],
                     ["4 Packet Burst"],["5 Packet Burst"]],
                    xAxisDigits = 0, yAxisDigits = 1, dataLblDigits = 1
                )       
                self.MyReport.InsertObject(graphDownLoss)
                self.finalGraphs['Avg Downlink Voice Packet Loss Burst per Trial'] =  graphDownLoss 

                # Calculate avg fwd rate for voice & bk traffic
                avgBk = []
                trialAvgUp = []
                trialAvgDown = []              
                for trialNum in trialList:
                    avgBk.append(self.testResults[trialNum]['bgFlowFrate'][-1])  
                    trialAvgUp.append(self.testResults[trialNum]['upFlowFrate'][-1])
                    trialAvgDown.append(self.testResults[trialNum]['downFlowFrate'][-1])                                                          
                self.MyReport.InsertParagraph("The following graph plots the average forwarding rate for voice and low priority background traffic for each trial." )
                graphFwd = Qlib.GenericGraph( 
                    trialList, # x values which is the trial numbers
                    "Trials",  # x label
                    list((trialAvgUp,trialAvgDown,avgBk,)), # list of y values
                    "Forwarding Rate (pps)", # y label 
                    "Average Voice and Background Traffic Forwarding Rate per Trial", # graphtitle
                    ['Bar'], # graph type
                    [["Avg Uplink Voice Fwd Rate"],["Avg Downlink Voice Fwd Rate"],["Avg Background Fwd Rate"],]
                )       
                self.MyReport.InsertObject(graphFwd)
                self.finalGraphs['Average Voice and Background Traffic Forwarding Rate per Trial'] =  graphFwd   
                                
            else:
                trialNum = '1'
                self.MyReport.InsertParagraph("The following graph plots the minimum and average R-value for voice traffic." )        
                graphRvalue = Qlib.GenericGraph( 
                    self.testResults[trialNum]['callCount'], 
                    "Call Count", 
                    list((self.testResults[trialNum]['upMinRvalue'],
                          self.testResults[trialNum]['upRvalue'],
                          self.testResults[trialNum]['downMinRvalue'],
                          self.testResults[trialNum]['downRvalue'],
                          self.testResults[trialNum]['mainRvalue']
                          )),                          
                    "R-value", 
                    "R-value vs. Number of Calls", 
                    ['Line'], 
                    [["Min Uplink R-value"], ["Avg Uplink R-value"], ["Min Downlink R-value"], 
                     ["Avg Downlink R-value"], ["Avg R-value"]],
                    displayDataLbls = False)                      
                self.MyReport.InsertObject(graphRvalue)
                self.finalGraphs['R-value vs. Number of Calls'] =  graphRvalue   

                self.MyReport.InsertParagraph("The following graph plots the minimum and average MOS Score for voice traffic." )                
                graphMos = Qlib.GenericGraph( 
                    self.testResults[trialNum]['callCount'], 
                    "Call Count", 
                    list((self.testResults[trialNum]['upMinMos'],
                          self.testResults[trialNum]['upMosScore'],
                          self.testResults[trialNum]['downMinMos'],
                          self.testResults[trialNum]['downMosScore'],
                          self.testResults[trialNum]['mainMosScore']
                          )),
                    "MOS Score", 
                    "MOS Score vs. Number of Calls", 
                    ['Line'], 
                    [["Min Uplink MOS Score"], ["Avg Uplink MOS Score"], ["Min Downlink MOS Score"], 
                     ["Avg Downlink MOS Score"], ["Avg MOS Score"]],
                    displayDataLbls = False)                          
                self.MyReport.InsertObject(graphMos)
                self.finalGraphs['MOS Score vs. Number of Calls'] =  graphMos  

                self.MyReport.InsertParagraph("The following graph plots the maximum and average jitter for voice traffic." )
                graphJitter = Qlib.GenericGraph( 
                    self.testResults[trialNum]['callCount'], 
                    "Call Count",
                    list((self.testResults[trialNum]['upMaxJitter'],
                          self.testResults[trialNum]['upJitter'],
                          self.testResults[trialNum]['downMaxJitter'],
                          self.testResults[trialNum]['downJitter']
                          )),
                    "Jitter(msecs)", 
                    "Voice Jitter vs. Number of Calls", 
                    ['Line'], 
                    [["Max Uplink Jitter"], [" Avg Uplink Jitter"], ["Max Downlink Jitter"], 
                     ["Avg Downlink Jitter"]],
                    displayDataLbls = False)                                       
                self.MyReport.InsertObject(graphJitter)
                self.finalGraphs['Voice Jitter vs. Number of Calls'] =  graphJitter  

                self.MyReport.InsertParagraph("The following graph plots the maximum and average latency for voice traffic.")
                graphLat = Qlib.GenericGraph(
                    self.testResults[trialNum]['callCount'], 
                    "Call Count", 
                    list((self.testResults[trialNum]['upMaxFlowLat'], 
                          self.testResults[trialNum]['upFlowLat'],
                          self.testResults[trialNum]['downMaxFlowLat'],
                          self.testResults[trialNum]['downFlowLat']
                          )),  
                    "Latency (msecs)", 
                    "Voice Latency vs. Number of Calls", 
                    ['Line'], 
                    [["Max Uplink Latency"], ["Avg Uplink Latency"], ["Max Downlink Latency"], 
                     ["Avg Downlink Latency"]],
                    displayDataLbls = False)             
                self.MyReport.InsertObject(graphLat)
                self.finalGraphs['Voice Latency vs. Number of Calls'] =  graphLat   
                
                strLoss1 = []
                strLoss2 = []
                strLoss3 = []
                strLoss4 = []
                strLoss5 = []
                for i in range(0, len(self.testResults[trialNum]['upLoss1'])):
                    strLoss1.append(round(self.testResults[trialNum]['upLoss1'][i], 1))
                    strLoss2.append(round(self.testResults[trialNum]['upLoss2'][i], 1))
                    strLoss3.append(round(self.testResults[trialNum]['upLoss3'][i], 1))
                    strLoss4.append(round(self.testResults[trialNum]['upLoss4'][i], 1))
                    strLoss5.append(round(self.testResults[trialNum]['upLoss5'][i], 1))                                                                                
                
                self.MyReport.InsertParagraph("The following graph plots the average packet loss burst for uplink voice traffic." )
                graphUpLossBurst = Qlib.GenericGraph( 
                    self.testResults[trialNum]['callCount'], 
                    "Call Count", 
                    list((strLoss1,strLoss2,strLoss3,strLoss4,strLoss5)),
                    "Avg Packet Loss Burst Count", 
                    "Avg Uplink Voice Packet Loss Burst vs. Number of Calls", 
                    ['Bar'], 
                    [["1 Packet Burst"],["2 Packet Burst"],
                     ["3 Packet Burst"],["4 Packet Burst"],["5 Packet Burst"]],
                    xAxisDigits = 0, yAxisDigits = 1, dataLblDigits = 1)             
                self.MyReport.InsertObject(graphUpLossBurst)
                self.finalGraphs['Avg Uplink Voice Packet Loss Burst vs. Number of Calls'] =  graphUpLossBurst  
 
                strLoss1 = []
                strLoss2 = []
                strLoss3 = []
                strLoss4 = []
                strLoss5 = []
                for i in range(0, len(self.testResults[trialNum]['downLoss1'])):
                    strLoss1.append(round(self.testResults[trialNum]['downLoss1'][i], 1))
                    strLoss2.append(round(self.testResults[trialNum]['downLoss2'][i], 1))
                    strLoss3.append(round(self.testResults[trialNum]['downLoss3'][i], 1))
                    strLoss4.append(round(self.testResults[trialNum]['downLoss4'][i], 1))
                    strLoss5.append(round(self.testResults[trialNum]['downLoss5'][i], 1))                                                                                
                
                self.MyReport.InsertParagraph("The following graph plots the average packet loss burst for downlink voice traffic." )
                graphDownLossBurst = Qlib.GenericGraph( 
                    self.testResults[trialNum]['callCount'], 
                    "Call Count", 
                    list((strLoss1,strLoss2,strLoss3,strLoss4,strLoss5)),
                    "Avg Packet Loss Burst Count", 
                    "Avg Downlink Voice Packet Loss Burst vs. Number of Calls", 
                    ['Bar'], 
                    [["1 Packet Burst"],["2 Packet Burst"],
                     ["3 Packet Burst"],["4 Packet Burst"],["5 Packet Burst"]],
                    xAxisDigits = 0, yAxisDigits = 1, dataLblDigits = 1)             
                self.MyReport.InsertObject(graphDownLossBurst)
                self.finalGraphs['Avg Downlink Voice Packet Loss Burst vs. Number of Calls'] =  graphDownLossBurst 
                
                self.MyReport.InsertParagraph("The following graph plots the average forwarding rate "\
                                              "for voice and low priority background traffic.")
                graphBkFwd = Qlib.GenericGraph(
                    self.testResults[trialNum]['callCount'], 
                    "Call Count", 
                    list((self.testResults[trialNum]['upFlowFrate'],
                          self.testResults[trialNum]['downFlowFrate'],
                          self.testResults[trialNum]['bgFlowFrate'],)), 
                    "Forwarding Rate (pps)",
                    "Voice and Background Traffic Avg. Forwarding Rate vs. Number of Calls", 
                    ['Line'], 
                    [["Avg Uplink Voice Fwd Rate"],["Avg Downlink Voice Fwd Rate"],["Background Fwd Rate"],], 
                    displayDataLbls = False) 
                self.MyReport.InsertObject(graphBkFwd)
                self.finalGraphs['Voice and Background Traffic Avg. Forwarding Rate vs. Number of Calls'] =  graphBkFwd                
            if self.UserPassFailCriteria['user'] == "True":                                            
                CSVline = ('TRIAL NUM', 'CALL COUNT', 'MIN R-VALUE', 'AVG R_VALUE', 'AVG MOS',\
                       'MAX JITTER','MAX VOICE % PKT LOSS',\
                       'MAX VOICE LATENCY(msecs)',\
                           'AVG VOICE FWD RATE(pps)','AVG BK FWD RATE(pps)','USC:CC')
                detResSummary = [ ('Trial Num', 'Call Count', 'Min R-value', 'Avg R-value',\
                                   'Avg MOS', 'Max Jitter', \
                                   'Max Voice % Loss',\
                                   'Max Voice Latency(msecs)',\
                                   'Avg Voice Fwd rate(pps)','Avg BK Fwd rate(pps)','USC:CC')]


            else:
                CSVline = ('TRIAL NUM', 'CALL COUNT', 'MIN R-VALUE', 'AVG R_VALUE', 'AVG MOS',\
                           'MAX JITTER','MAX VOICE % PKT LOSS',\
                           'MAX VOICE LATENCY(msecs)',\
                           'AVG VOICE FWD RATE(pps)','AVG BK FWD RATE(pps)')    
                detResSummary = [ ('Trial Num', 'Call Count', 'Min R-value', 'Avg R-value',\
                              'Avg MOS', 'Max Jitter', \
                              'Max Voice % Loss',\
                              'Max Voice Latency(msecs)',\
                              'Avg Voice Fwd rate(pps)','Avg BK Fwd rate(pps)')]
                    
            self.ResultsForCSVfile.append( CSVline )              
            for i in range(0, self.Trials):
                lCnt = 0 
                i = str(i+1)   
                if self.Trials > 1:
                    # if multiple trials, we display only the results of the last iteration for each trial
                    callNum = self.testResults[i]['callCount'][-1]
                    minRvalue = min(self.testResults[i]['upMinRvalue'][-1], self.testResults[i]['downMinRvalue'][-1]) 
                    avgRvalue = self.testResults[i]['mainRvalue'][-1]
                    avgMos = self.testResults[i]['mainMosScore'][-1]
                    maxJitter = max(self.testResults[i]['upMaxJitter'][-1], self.testResults[i]['downMaxJitter'][-1])
                    maxPktLoss = max(self.testResults[i]['upMaxFlowLoss'][-1], self.testResults[i]['downMaxFlowLoss'][-1])
                    maxLat = max(self.testResults[i]['upMaxFlowLat'][-1], self.testResults[i]['downMaxFlowLat'][-1])                    
                    if self.UserPassFailCriteria['user'] == "True":
                        if int(callNum) >= self.UserPassFailCriteria['ref_min_calls']:
                             TestResult='PASS'
                             WaveEngine.OutputstreamHDL("\nTrial:%s-The test has achieved the user specfied Pass/Criteria: User-%s, Achieved-%s\n" %(i,self.UserPassFailCriteria['ref_min_calls'],callNum),WaveEngine.MSG_SUCCESS)
                        else:
                             TestResult='FAIL'
                             WaveEngine.OutputstreamHDL("\nTrial:%s-The test has failed to achieve the user specfied Pass/Criteria: User-%s, Achieved-%s\n" %(i,self.UserPassFailCriteria['ref_min_calls'],callNum),WaveEngine.MSG_WARNING)  
                        CSVline = (
                            int(i), int(callNum), minRvalue, avgRvalue,\
                            avgMos, maxJitter,\
                            maxPktLoss, maxLat,\
                            self.testResults[i]['mainFlowFrate'][-1],\
                            self.testResults[i]['bgFlowFrate'][-1], \
                            TestResult        
                             )
                    else:  
                        CSVline = (
                             int(i), int(callNum), minRvalue, avgRvalue,\
                             avgMos, maxJitter,\
                             maxPktLoss, maxLat,\
                             self.testResults[i]['mainFlowFrate'][-1],\
                             self.testResults[i]['bgFlowFrate'][-1] 
                             )
                    self.ResultsForCSVfile.append(CSVline) 
                    detResSummary.append(CSVline)
                else:      
                    for callNum in self.testResults[i]['callCount']:                    
                        minRvalue = min(self.testResults[i]['upMinRvalue'][lCnt], self.testResults[i]['downMinRvalue'][lCnt]) 
                        avgRvalue = self.testResults[i]['mainRvalue'][lCnt]
                        avgMos = self.testResults[i]['mainMosScore'][lCnt]
                        maxJitter = max(self.testResults[i]['upMaxJitter'][lCnt], self.testResults[i]['downMaxJitter'][lCnt])
                        maxPktLoss = max(self.testResults[i]['upMaxFlowLoss'][lCnt], self.testResults[i]['downMaxFlowLoss'][lCnt])
                        maxLat = max(self.testResults[i]['upMaxFlowLat'][lCnt], self.testResults[i]['downMaxFlowLat'][lCnt])
                        if self.UserPassFailCriteria['user'] == "True":
                            TestResult=''
                            if int(callNum) == int(self.testResults[i]['callCount'][-1]):
                                 if int(callNum) >= self.UserPassFailCriteria['ref_min_calls']:
                                       TestResult='PASS'
                                       WaveEngine.OutputstreamHDL("\nTotalCalls:%s-The test has achieved the user specfied Pass/Criteria: User-%s, Achieved-%s\n" %(callNum,self.UserPassFailCriteria['ref_min_calls'],callNum),WaveEngine.MSG_SUCCESS)
                                 else:
                                       TestResult='FAIL'
                                       WaveEngine.OutputstreamHDL("\nTotalCalls:%s-The test has failed to achieve the user specfied Pass/Criteria: User-%s, Achieved-%s\n" %(callNum,self.UserPassFailCriteria['ref_min_calls'],callNum),WaveEngine.MSG_WARNING)
                            CSVline = (
                                        int(i), int(callNum), minRvalue, avgRvalue,\
                                        avgMos, maxJitter,\
                                        maxPktLoss, maxLat,\
                                        self.testResults[i]['mainFlowFrate'][lCnt],\
                                        self.testResults[i]['bgFlowFrate'][lCnt], \
                                        TestResult
                                      )
                        else:   
                           CSVline = (
                            int(i), int(callNum), minRvalue, avgRvalue,\
                            avgMos, maxJitter,\
                            maxPktLoss, maxLat,\
                            self.testResults[i]['mainFlowFrate'][lCnt],\
                            self.testResults[i]['bgFlowFrate'][lCnt] 
                        )
                        self.ResultsForCSVfile.append(CSVline) 
                        detResSummary.append(CSVline)
                        lCnt = lCnt + 1
            
            #self.MyReport.InsertPageBreak()            
                     
            self.MyReport.InsertHeader("Detailed Results") 
            self.MyReport.InsertParagraph("The following table shows the detailed results for this test.")
            if self.UserPassFailCriteria['user'] == "True":
                if self.Trials > 1:
                    self.MyReport.InsertDetailedTable(detResSummary,
                                                     columns=[0.5*inch, 0.5*inch, 0.6*inch, 0.5*inch, 0.5*inch,\
                                                             0.5*inch, 0.8*inch, 0.9*inch, 0.7*inch, 0.6*inch,0.6*inch])
                    NoteText=""" Note: Abbreviations used: USC-User Specified Criteria,CC-Call Capacity """
                    self.MyReport.InsertParagraph(NoteText)
                    iteration_count=-1
                    fail_count =0
                    fail_perc  =0
                    for each_tup in  detResSummary:
                        iteration_count=iteration_count+1
                        for each_value in each_tup:
                            if each_value == 'FAIL':
                               fail_count=fail_count+1
                    #fail_perc=float(fail_count/iteration_count)* 100

                    self.MyReport.InsertHeader( "User Specified P/F criteria" )
                    ConfigParameters = [ ( 'Parameter', 'User specified Value', 'Overall Result' ),
                                         ( 'Call Capacity',"%s" %self.UserPassFailCriteria['ref_min_calls'] , "Total:%s, PASS:%s and FAIL:%s"%(iteration_count,(iteration_count-fail_count),fail_count))]
                    if fail_count > 0:
                       self.FinalResult =3
                    self.MyReport.InsertParameterTable( ConfigParameters, columns = [ 1.25*inch, 1.25*inch, 1.75*inch ] ) # 6-inch total
                else:
                   tmp_pdf=[]
                   for each in detResSummary: 
                       tmp_pdf.append(each[:-1])
                   self.MyReport.InsertDetailedTable (tmp_pdf,
                                                  columns=[0.5*inch, 0.5*inch, 0.6*inch, 0.5*inch, 0.5*inch,\
                                                           0.5*inch, 0.8*inch, 0.9*inch, 0.7*inch, 0.6*inch])
                   iteration_count=-1
                   fail_count =0
                   fail_perc  =0
                   for each_tup in  detResSummary:
                        iteration_count=iteration_count+1
                        for each_value in each_tup:
                            if each_value == 'FAIL':
                               fail_count=fail_count+1

                   user_table=[]
                   user_table.append(detResSummary[0])
                   user_table.append(detResSummary[-1])
                   res_trial=detResSummary[-1][-1]
                   self.MyReport.InsertHeader( "Summary Results" )  
                   self.MyReport.InsertDetailedTable(user_table,columns=[0.5*inch, 0.5*inch, 0.6*inch, 0.5*inch, 0.5*inch,\
                                                                         0.5*inch, 0.8*inch, 0.9*inch, 0.7*inch, 0.6*inch,0.6*inch])
                   self.MyReport.InsertHeader( "User Specified P/F criteria" )
                   ConfigParameters = [ ( 'Parameter', 'User defined Value', 'Overall Result' ),
                                        ( 'Call Capacity',"%s" %self.UserPassFailCriteria['ref_min_calls'] , "%s" %res_trial)]
                   if res_trial== 'FAIL':
                       self.FinalResult =3
                   self.MyReport.InsertParameterTable( ConfigParameters, columns = [ 1.25*inch, 1.25*inch, 1.75*inch ] ) # 6-inch total
 
            else:  
                self.MyReport.InsertDetailedTable(detResSummary, 
                                              columns=[0.5*inch, 0.5*inch, 0.6*inch, 0.5*inch, 0.5*inch,\
                                                       0.5*inch, 0.8*inch, 0.9*inch, 0.7*inch, 0.6*inch])
                
            self.MyReport.InsertHeader("Configuration") 
            
            self.MyReport.InsertParagraph("The following table shows the parameters set for the test.")
            
            resSummary = [('Parameter', 'Value')]
            self.testParameters.sort()
            for key in self.testParameters.keys():
                resultTuple = (key, self.testParameters[key])
                resSummary.append(resultTuple)
            self.MyReport.InsertDetailedTable(resSummary, columns=[3.0*inch, 1.5*inch])   
            
            if self.trafficDirection != 'Ethernet To Ethernet':
                self.insertAPinfoTable(self.RSSIFilename)
            self.MyReport.InsertHeader("Other Information") 
            OtherParameters = []
            OtherParameters.append( ( 'Results Directory',  str( self.LoggingDirectory ) )  )
            for item in self.OtherInfoData.items():
                OtherParameters.append( item )
            OtherParameters.append( ( 'WaveTest Version',   str( action.getVclVersionStr() ) ) )
            self.MyReport.InsertGenericTable( OtherParameters , columns = [ 1.5*inch, 4.5*inch ] ) 
            
            self.SaveResults()           
            if self.generatePdfReportF:
                self.printReport()    #This calls the printReport in QosCommon, don't get confused 
                                      #with 'PrintReport' (note the 'P' ) in BaseTest
            #Update the csv results, pdf charts (if opted by the user) in the GUI
            #'Results' page
            self.ExitStatus=self.FinalResult
            self.updateGUIresultsPage()                          
            
        except WE.RaiseException:
            self.Print("WaveEngine terminating the run\n", 'ERR')
            (exc_type, exc_value, exc_traceback) = sys.exc_info()
            self.Print(str(exc_value), 'ERR')
            self.ExitStatus = 2
            self.SaveResults()
        except Exception, e:
            # some other error occured
            (exc_type, exc_value, exc_tb) = sys.exc_info()
            try:
                msg = "Fatal script error:\n"
                for text in traceback.format_exception(exc_type, exc_value,
                        exc_tb):
                    msg += str(text)
                self.Print(str(msg), 'ERR')
            except Exception, e:
                print "ERROR:\n%s\n%s\n" % (str(msg), str(e))
            self.ExitStatus = 1
        self.CloseShop()
        return self.ExitStatus
    #-- End def run() --

        
    def getInfo( self ):
        """
        Returns blurb shown in the GUI describing the test.
        """
        msg = "The VoIP QoS Service Capacity test " \
              "determines the maximum number of VoIP calls the System Under Test (SUT) " \
              "can maintain at a specified Service Level Agreement (SLA) in the presence of " \
              "best effort traffic load. The SLA can be specified as an R-value or " \
              "as a combination of maximum latency, packet loss and jitter."
            
        return msg
    
    def getCharts( self ):
        """
        Returns dictionary of all chart objects supported by this test.
        """
        return self.finalGraphs
 
#-- End Class Test --

#------------ Main() -------------- 
if __name__ == "__main__":
    # Commandline execution starts here
        
    # set up options parser.  -h or --help will print usage.
    usage = "usage: %prog [options] -f FILENAME"
    parser = OptionParser( usage )
    parser.add_option("-f", "--file", dest="filename",
                    help="read configuration from FILE", metavar="FILE")
    parser.add_option("-l", "--savelogs",
                    dest="logs", action="store_true", default=False,
                    help="save hardware logs after test")
    (options, args) = parser.parse_args()
    # ...args is a list of extra arguments, like a wml config file.
    
    # Create the test
    userTest = Test()

    WE.SetOutputStream(PrintToConsole)
    if options.filename != None:
        retval = userTest.loadFile( options.filename )
    if options.logs:
        userTest.SavePCAPfile = True

    #userTest.Print("\rTrying %d calls per AP\n" % numCalls)   
    userTest.run()
    sys.exit(userTest.ExitStatus)
    
