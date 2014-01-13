#Imports

import time, datetime, telnetlib
import math
import sys, os
import sched
import traceback
import copy
import thread
import random
import vcl
from optparse import OptionParser
if os.name == 'nt':
   import win32con
import subprocess

from reportlab.graphics.charts.axes import XValueAxis
from reportlab.graphics.shapes import Drawing, Line, String, Rect, PolyLine, STATE_DEFAULTS
from reportlab.graphics.charts.linecharts import HorizontalLineChart
from reportlab.graphics.charts.linecharts import makeMarker
from reportlab.graphics import renderPDF
from reportlab.graphics.charts.barcharts import VerticalBarChart
from reportlab.graphics.charts.barcharts import HorizontalBarChart
from reportlab.lib import colors
from reportlab.graphics.charts.legends import Legend, LineLegend
from reportlab.graphics.charts.piecharts import *
from reportlab.graphics.charts.textlabels import *
from reportlab.platypus import Flowable
from reportlab.lib.units import inch
from reportlab.rl_config import defaultPageSize
from reportlab.graphics.charts.textlabels import Label
from reportlab.lib.colors import Color

sys.path.append("C:\\Program Files\\VeriWave\\scripts\\python\\vcl")
sys.path.append("..\\we_lib")

from vcl import *
from basetest import *
import Qlib
import WaveEngine
from CommonFunctions import *
from odict import *
import captureAnalysis as cap

class Test(BaseTest):
    
    def __init__(self):
        BaseTest.__init__(self)
        
        #### Trial duration in secs ####
        self.trialDuration  = 5
        self.numResultUnits = 10
        self.resultSampleTime = 1 
        
        #### Number of Trails #######
        self.numTrials = 1
        
        #### The Load per AP in Kbps or num of clients#######
        self.numTotalClients = 10
        self.loadInKbps = 10000
        
        
        #self.latencyBucketMin = 0.0001
        #self.latencyBucketMax = 0.0010
        
        self.CardMap = { 'WT90_E1': ( 'wt-tga-10-28', 1, 0, 'on', 100, 'full' ),
                         'WT90_W1': ( 'wt-tga-10-28', 7, 0, 1 )
                       }
        
        self.CardList = self.CardMap.keys()
        self.clientAnalysisPortsList = []
        
        self.wifiCards = ['WT90_W1']         
        self.ethCards = ['WT90_E1']         
        self.monWifiCards = []  
        self.igWifiCards = []       
        self.monEthCards = [] 
        self.check_flag=0 
        self.UserPassFailCriteria={}
        self.UserPassFailCriteria['User']='False'
        self.user_table=[] 
        self.FinalResult=0 
        self.TestResult= {}

        self.Security_None = {'Method': 'NONE'}  
        self.Security_WPA2 = {'Method': 'WPA2-EAP-TLS', 'Identity': 'anonymous', 'Password' : 'whatever'}

                
        self.TrafficTypes = {
                            'VOIPG711'  : {  'Type'          : 'VOIP', 
                                              'Phyrate'      : 11, 
                                              'Direction'    : 'bidirectional',
                                              'Server'       : 'VOIPserver',
                                              'layer2Qos'    : {'enable' : 0, 'wlanUp' : 7, 'ethUp' : 7, 'mpduAggregation' : 0, 'mpduAggregationLimit' : 8 },
                                              'layer3Qos'    : {'enable' : 1, 'dscp' : 40},
                                              'ipProtocolNum': 119,                                               
                                              'sipSignaling' : 0,
                                              'Layer4to7'    : {'SrcPort' : 5004 , 'DestPort' : 5003},
                                              'SLA'          : {'slaMode' : 0, 'value' : 78 },
                                           },                                      
                             
                             'HTTP'     : {   'Type'         : 'HTTP', 
                                              'Framesize'    : 1500,
                                              'Phyrate'      : 54, 
                                              'RateMode'     : 0,
                                              'Intendedrate' : 1000, 
                                              'NumFrames'    : 4294967290,
                                              'Direction'    : 'downlink',
                                              'layer2Qos'    : {'enable' : 0, 'wlanUp' : 0, 'ethUp' : 0, 'mpduAggregation' : 0, 'mpduAggregationLimit' : 8 },
                                              'layer3Qos'    : {'enable' : 0, 'dscp' : 0},
                                              'ipProtocolNum': 'Auto',                                               
                                              'Server'       : 'HTTPserver',
                                              'Layer4to7'    : {'SrcPort' : 80 , 'DestPort' : 80, 'Operation' : 'http get'},
                                              'SLA'          : {'Goodput' : 1 },
                                           },  
                                           
                             'FTP'     : {    'Type'         : 'FTP', 
                                              'Framesize'    : 1500,
                                              'Phyrate'      : 54, 
                                              'RateMode'     : 0,
                                              'Intendedrate' : 5000, 
                                              'NumFrames'    : 4294967290,
                                              'Direction'    : 'downlink',
                                              'layer2Qos'    : {'enable' : 0, 'wlanUp' : 0, 'ethUp' : 0, 'mpduAggregation' : 0, 'mpduAggregationLimit' : 8 },
                                              'layer3Qos'    : {'enable' : 0, 'dscp' : 0},
                                              'ipProtocolNum': 'Auto',                                               
                                              'Server'       : 'FTPserver',
                                              'Layer4to7'    : {'SrcPort' : 21 , 'DestPort' : 21, 'Operation' : 'ftp get', 'FileSize' :                     
                                                                10, 'FileName' : 'veriwave.txt' , 'UserName': 'anonymous', 'Password' : 'anonymous' }, 
                                              'SLA'          : {'fTransferTime' : 10 },
                                           },                                            
                            
                             'rawUDP'     : {    'Type'          : 'UDP', 
                                              'Framesize'    : 1500,
                                              'Phyrate'      : 54, 
                                              'RateMode'     : 0,
                                              'Intendedrate' : 500, 
                                              'NumFrames'    : 4294967290,
                                              'Direction'    : 'downlink',
                                              'layer2Qos'    : {'enable' : 0, 'wlanUp' : 0, 'ethUp' : 0, 'mpduAggregation' : 0, 'mpduAggregationLimit' : 8 },
                                              'layer3Qos'    : {'enable' : 0, 'dscp' : 0},
                                              'ipProtocolNum': 'Auto',                                               
                                              'Server'       : 'GPserver',
                                              'Layer4to7'    : {'SrcPort' : 20000 , 'DestPort' : 30000},                                               
                                              'SLA'          : {'Latency' : 10000, 'Jitter' : 500, 'PacketLoss' : 10 }, 
                                           }, 
                            
                             'rawTCP'     : { 'Type'         : 'TCP', 
                                              'Framesize'    : 1500,
                                              'Phyrate'      : 54, 
                                              'RateMode'     : 0,
                                              'Intendedrate' : 500, 
                                              'NumFrames'    : 4294967290,
                                              'Direction'    : 'downlink',
                                              'layer2Qos'    : {'enable' : 0, 'wlanUp' : 0, 'ethUp' : 0, 'mpduAggregation' : 0, 'mpduAggregationLimit' : 8 },
                                              'layer3Qos'    : {'enable' : 0, 'dscp' : 0},
                                              'ipProtocolNum': 'Auto',                                               
                                              'Server'       : 'GPserver',
                                              'Layer4to7'    : {'SrcPort' : 40000 , 'DestPort' : 50000}, 
                                              'SLA'          : {'Goodput' : 10 },

                                           },                               
                              
                            'VOIPG723'  : {   'Type'         : 'VOIPG723', 
                                              'Phyrate'      : 54, 
                                              'Direction'    : 'bidirectional',
                                              'sipSignaling' : 0,
                                              'Server'       : 'VOIPserver',
                                              'NumFrames'    : 4294967290,
                                              'layer2Qos'    : {'enable' : 0, 'wlanUp' : 0, 'ethUp' : 0, 'mpduAggregation' : 0, 'mpduAggregationLimit' : 8 },
                                              'layer3Qos'    : {'enable' : 0, 'dscp' : 0},
                                              'ipProtocolNum': 'Auto',                                               
                                              'Layer4to7'    : {'SrcPort' : 5004 , 'DestPort' : 5003},
                                              'SLA'          : {'slaMode' : 0, 'value' : 70 },
                                           },
                            
                            'VOIPG729'  : {   'Type'         : 'VOIPG729', 
                                              'Phyrate'      : 54, 
                                              'Direction'    : 'bidirectional',
                                              'Server'       : 'VOIPserver',
                                              'NumFrames'    : 4294967290,
                                              'layer2Qos'    : {'enable' : 0, 'wlanUp' : 0, 'ethUp' : 0, 'mpduAggregation' : 0, 'mpduAggregationLimit' : 8 },
                                              'layer3Qos'    : {'enable' : 0, 'dscp' : 0},
                                              'ipProtocolNum': 'Auto',                                               
                                              'sipSignaling' : 0,
                                              'Layer4to7'    : {'SrcPort' : 5004 , 'DestPort' : 5003},
                                              'SLA'          : {'slaMode' : 0, 'value' : 70 },
                                           },
                            
                           'MPEG2'  : {       'Type'         : 'RTPVideo', 
                                              'Phyrate'      : 54, 
                                              'Framesize'    : 1500,
                                              'RateMode'     : 0,
                                              'Intendedrate' : 1000,                                               
                                              'Direction'    : 'downlink',
                                              'NumFrames'    : 4294967290,
                                              'Server'       : 'VIDEOserver',
                                              'layer2Qos'    : {'enable' : 0, 'wlanUp' : 0, 'ethUp' : 0, 'mpduAggregation' : 0, 'mpduAggregationLimit' : 8 },
                                              'layer3Qos'    : {'enable' : 0, 'dscp' : 0},
                                              'ipProtocolNum': 'Auto',                                               
                                              'Layer4to7'    : {'SrcPort' : 3155 , 'DestPort' : 3155},
                                              'SLA'          : {'Df' : 50, 'Mlr' : 1},
                                           },      
                           'MulticastVideo'  : { 'Type'      : 'MPEG2', 
                                              'Phyrate'      : 54, 
                                              'Framesize'    : 1500,
                                              'RateMode'     : 0,
                                              'Intendedrate' : 1000,    
                                              'NumFrames'    : 4294967290,
                                              'layer2Qos'    : {'enable' : 0, 'wlanUp' : 0, 'ethUp' : 0, 'mpduAggregation' : 0, 'mpduAggregationLimit' : 8 },
                                              'layer3Qos'    : {'enable' : 0, 'dscp' : 0},
                                              'ipProtocolNum': 'Auto',                                                                                          
                                              'Direction'    : 'multicast(downlink)',
                                              'Server'       : 'MULTICASTserver',
                                              'MulticastAddr': {'ipAddress': '224.1.1.1', 'macAddress' : '01:00:5e:01:01:01'},
                                              'Layer4to7'    : {'SrcPort' : 3155 , 'DestPort' : 3155},
                                              'SLA'          : {'Df' : 50, 'Mlr' : 1 },
                                           },                                
                          }

                
        self.clientGroups = {
                               'Handsets' : {
                                             'enable' : True, 
                                             'ssid' : 'cisco',
                                             'Qos'  : 'Disable',
                                             'security' : self.Security_None,
                                             'ipMode' : 1,
                                             'AssocProbe' : "Unicast",
                                             'BOnlyMode' : "off",
                                             'ipAddress' : "192.168.1.2", 	
                                             'gateway' : "192.168.1.1", 
                                             'subnetMask' : "255.255.0.0"
                                            },
                                            
                               'Laptops' : {
                                             'enable' : True, 
                                             'ssid' : 'cisco',
                                             'Qos'  : 'Disable',
                                             'security' : self.Security_None,
                                             'ipMode' : 1,
                                             'AssocProbe' : "Unicast",
                                             'BOnlyMode' : "off",
                                             'ipAddress' : "192.168.2.2", 	
                                             'gateway' : "192.168.1.1", 
                                             'subnetMask' : "255.255.0.0"
                                            },
                                            
                               'VideoCameras' : {
                                             'enable' : True, 
                                             'ssid' : 'cisco',
                                             'Qos'  : 'Disable',
                                             'security' : self.Security_None,
                                             'ipMode' : 1,
                                             'AssocProbe' : "Unicast",
                                             'BOnlyMode' : "off",
                                             'ipAddress' : "192.168.3.2", 	
                                             'gateway' : "192.168.1.1", 
                                             'subnetMask' : "255.255.0.0"
                                            },    
                               'BarcodeScanners' : {
                                             'enable' : True, 
                                             'ssid' : 'cisco',
                                             'Qos'  : 'Disable',
                                             'security' : self.Security_None,
                                             'ipMode' : 1,
                                             'AssocProbe' : "Unicast",
                                             'BOnlyMode' : "off",
                                             'ipAddress' : "192.168.4.2", 	
                                             'gateway' : "192.168.1.1", 
                                             'subnetMask' : "255.255.0.0"
                                            },                                           
                             }                         
        
        
        
        self.serverList = {
                            'VOIPserver' : {  'ipMode'      : 1,
                                              'ipAddress'   : '192.168.1.200',
                                              'macMode'     : 0,
                                              'vlan'        : { 'enable' : 0, 'id' : 0},
                                              'macAddress'  : '00:11:22:33:aa:01',
                                              'ethPort'     :  'WT90_E1',
                                              'netmask'     : '255.255.0.0',
                                              'gateway'     : '192.168.1.1',
                                              
                                           },         
                                
                             'FTPserver' : {  'ipMode'      : 1,
                                              'ipAddress'   : '192.168.2.200',
                                              'macMode'     : 0,
                                              'vlan'        : { 'enable' : 0, 'id' : 0},
                                              'macAddress'  : '00:11:22:33:bb:01',
                                              'ethPort'     :  'WT90_E1',
                                              'netmask'     : '255.255.0.0',
                                              'gateway'     : '192.168.1.1',
                                              
                                           },                                                   
                                               
                             'HTTPserver' : { 'ipMode'      : 1,
                                              'ipAddress'   : '192.168.3.200',
                                              'macMode'     : 0,
                                              'vlan'        : { 'enable' : 0, 'id' : 0},
                                              'macAddress'  : '00:11:22:33:cc:01',
                                              'ethPort'     :  'WT90_E1',
                                              'netmask'     : '255.255.0.0',
                                              'gateway'     : '192.168.1.1',
                                              
                                           },   
                             
                             'GPserver' : {   'ipMode'      : 1,
                                              'ipAddress'   : '192.168.4.200',
                                              'macMode'     : 0,
                                              'vlan'        : { 'enable' : 0, 'id' : 0},
                                              'macAddress'  : '00:11:22:33:dd:01',
                                              'ethPort'     :  'WT90_E1',
                                              'netmask'     : '255.255.0.0',
                                              'gateway'     : '192.168.1.1',
                                              
                                           },   
                             
                             'VIDEOserver' : {'ipMode'      : 1,
                                              'ipAddress'   : '192.168.5.200',
                                              'macMode'     : 0,
                                              'vlan'        : { 'enable' : 0, 'id' : 0},
                                              'macAddress'  : '00:11:22:33:ff:01',
                                              'ethPort'     :  'WT90_E1',
                                              'netmask'     : '255.255.0.0',
                                              'gateway'     : '192.168.1.1',
                                              
                                           },      
                             
                             'MULTICASTserver' : {'ipMode'      : 1,
                                              'ipAddress'   : '192.168.6.200',
                                              'macMode'     : 0,
                                              'vlan'        : { 'enable' : 0, 'id' : 0},
                                              'macAddress'  : '00:11:22:33:ff:01',
                                              'ethPort'     :  'WT90_E1',
                                              'netmask'     : '255.255.0.0',
                                              'gateway'     : '192.168.1.1',
                                              
                                           },                                            
                                   
                           }
                         
        
        self.wimixMode = 1
        
        self.wimixClientCentricProfiles = {
                                           'testProfile': 'Enterprise',
                                           'profiles': {
                                                  
                                                  'Enterprise' : {
                                                           'clientList': ['Laptops'], 
                                           	           'trafficList': self.TrafficTypes.keys(),
                                           	           'perClients': [100],
                                           	           'numClients': [24],
                                           	           'loadMode': 0, 
                                                           'loadVal': 24,   
                                                           'totalLoadPer' : 100,                                        
                                           
                                           	        },
                                                    },
                                           }          
        
              
        self.wimixTrafficCentricProfiles = {
                                     'testProfile' : 'Enterprise',
                                      'profiles' : {
                                      
                                              'Enterprise' : {
                                                      'trafficList' : ['VOIPG711', 'CRM App', 'Http1.0 Get PC', 'Http1.0 Get PDA', 'Http1.0 Post PC',
                                                                      'Http1.0 Post PDA',  'FTP Get', 'FTP Put',  'Win Browser Announcement', 
                                                                       'NetBios', 'WinMx', 'SMTP PC', 'SMTP PDA', 'DNS Req PC', 'DNS Req PDA',
                                                                        'DNS Resp PC', 'DNS Resp PDA', 'RTSP', 'MPEG-2 Webcast', 
                                                                        'unclassified Traffic PDA', 'unclassified Traffic PC'],

                                                      'clientGroupList': ['Handset', 'Laptop', 'Laptop', 'PDA', 'Laptop', 'PDA', 'Laptop', 
                                                                         'Laptop', 'Laptop', 'Laptop', 'Laptop', 'Laptop', 'PDA', 'Laptop',
                                                                          'PDA', 'Laptop', 'PDA', 'Laptop', 'Laptop', 'PDA', 'Laptop'],
                                                                          
                                                      'perTraffic': [7,8,10,5,10,8,8,2,0.5,0.5,8,6,5,0.5,0.5,0.5,0.5,2,10,3,5],
                                                      
                                                      'loadPps': [50,224,512,256,512,410,327,91,53,110,330,547,456,107,107,43,43,397,180,26,128],
                                                      'loadMode': 0, 
                                                      'loadVal': 20000,
                                                      'totalLoadPer' : 100,
                                                            
                                                            },
                                               
                                                  },
                                          }
                                         
                
        self.testProfileList = []
        if self.wimixMode == 0:
            self.testProfileList.append(self.wimixTrafficCentricProfiles['testProfile'])
        elif self.wimixMode == 1:
            self.testProfileList.append(self.wimixClientCentricProfiles['testProfile']) 
             
        self.progAttenTestTime = 0
        self.enableClientLearning = True
        self.ClientLearningTime = 1
        self.ClientLearningRate = 10
        
        self.enableFlowLearning = False
        self.FlowLearningTime   = 1
        self.FlowLearningRate   = 100
        
        self.ARPRate           =  10.0
        self.ARPRetries        =   3
        self.ARPTimeout        =  10.0

        self.BSSIDscanTime    = 1.5
        self.AssociateRate    = 10
        self.AssociateTimeout = 10 
        self.AssociateRetries = 0
        
        self.biFlowConnectTimeout = 20
        self.biFlowDisconnectTimeout = 10
        self.biFlowConnectRate = 10
        
        self.enableOverTimeResults = 0
               
        self.CSVfilename      = 'Results_wimix.csv'
        self.CSVOTRfilename   = 'Results_wimix_over_time.csv'
        self.ReportFilename   = 'Report_wimix.pdf'
        self.DetailedFilename = 'Detailed_Results_wimix.csv'
        self.ConsoleLogFileName = "Console_wimix_script.html"
        self.TimeLogFileName = "Timelog_wimix_script.txt"
        self.RSSILogFileName = "RSSI_wimix_script.csv"
        self.LoggingDirectory = "logs"
        
        self.SavePCAPfile     = False
        self.captureFormat = 0
        self.testType = "WiMix"
        
        self.insertTestTopoDiagram = True
        self.biFlowConnectMode = 1
        
        self.settleTime = 2
        self.agingTime = 2
        self.testParameters = odict.OrderedDict()   
        self.blogScheduleDict = odict.OrderedDict()
        
        self.initializeVars()
        self.CutOffForDistributionGraphs = 10
        self.slaReqMetForTrail = True
        self.generatePdfReportF = True
        self.continueTestOnFail = False
        self.continueTestOnAdminControlFail = True
        
        self.reconnectClientsForTrial = 1
        self.numFlowRuns = 1
        
        self.staggerStartEnabled = False
        self.staggerStartCustomEnabled = False
        self.staggerStopCustomEnabled = False
        self.dynamicBlogModeflag = False
        self.staggerStartInt = 1
        
        self.brandLogoFlag = False
        self.brandLogoFilePath = ""
        
        self.waveAgentFlowsExist = False
        self.postProcessingNeeded = False
        self.ecoSystemClientsExist = True
        self.filterFlowFrames = False
        
        self.flowsPerClientsDict = dict()
        self.loadPerTrafficProfileDict = dict()
        self.flowResultsDict = dict()
        self.waveAgentRoamingDelayStats = dict()
        self.progAttenScheduleDict = odict.OrderedDict()
        self.attScheduleOnly = odict.OrderedDict()
        
        #### Video RTP Payload Codes 
        #0 MPEG2 33
        #1 H261 31
        #2 MPV 32
        #3 H263 34
        #4 jpeg 26       
        self.rtpVideoPayloadCodes = {0:33, 1:31, 2:32, 3:34, 4:26}
        
        #### Audio RTP Payload Codes
        #0 G711 8
        #1 G722 9
        #2 G723 4
        #3 G728 15
        #4 G729 18
        #5 GSM 3
        #6 LPC 7
        #7 QCELP 12
        self.rtpAudioPayloadCodes = {0:8, 1:9, 2:4, 3:15, 4:18, 5:3, 6:7, 7:12}
        
        #### Payload Pattern codes
        #0 fixed
        #1 incrByte
        #2 repeating
        #3 random
        self.appPayloadCodes = {0:"fixed", 1:"incrByte", 2:"repeating", 3:"random"}
        
        ### Min PHY Rate for TSPEC
        #{0 1 Mbps}, {1, 2 Mbps}, {2, 5.5 Mbps}, {3, 6 Mbps}, {4, 9 Mbps} , {5, 11 Mbps}, {6, 12 Mbps}, {7, 18 Mbps}, {8, 24 Mbps}, {9, 36 Mbps}, {10, 48 Mbps}, {11, 54Mbps} 
        self.tspecMinPhyRates = {0:1, 1:2, 2:5.5, 3:6, 4:9, 5:11, 6:12, 7:18, 8:24, 9:36, 10:48, 11:54}
        
#------------------------ End of User Configuration --------------------------
    
    def initializeVars(self):   	
    	
        self.finalGraphs = odict.OrderedDict()          
        self.flowTypeDict = odict.OrderedDict()    
        self.waveClientResultsDict = odict.OrderedDict()     
        self.waveClientRoamDict = odict.OrderedDict()       
        self.ftpClientNames = []
        self.httpClientNames = []
        self.rawClientNames = []
        self.ftpServerNames = []
        self.httpServerNames = []
        self.rawServerNames = []
        self.overTimeResultsDict = {}
        self.clientPowerSaveOptionsDict = {}
        self.overTimeFlowResults = {}
        self.timeSampleList = []
        self.ResultsForCSVOTRfile = []
        self.igmpResponderList =[]
                
        self.numClientPerGroup = {}
        self.destroyedBiFlows = False
        self.destroyedAppServers = False
        self.destroyedMulticastStuff = False
        self.destroyedUnicastStuff = False
        
        self.realTimeChartXData = []
        self.realTimeChartYData = []
        self.resultSampleTimeVal = 0
        self.trafficFlowsStarted = False
        self.trafficFlowsEnded = False
        self.multicastTrafficExistsFlag = True
        self.unicastTrafficExistsFlag = False
        #self.mcastIp = "224.1.1.1"
        self.mcastIpList = []
        self.ucastIpList = []
        self.mcastDummyClientDict = {}
        self.ucastDummyClientDict = {}
        self.burstModeScheduleDict = {}
        self.burstModeTrafficFlag = False
        self.clientsWithAggregation = []
        self.wifiServerList = []
        
                            
        
    def loadData(self, waveChassisStore, wavePortStore, waveClientTableStore,
           waveSecurityStore, waveTestStore, waveTestSpecificStore,
           waveMappingStore, waveBlogStore,wimixTrafficStore,wimixServerStore, clientAnalysisStore):
         
        self.wifiCards = []       
        self.ethCards = []  
        self.monWifiCards = []       
        self.monEthCards = [] 
        self.secondaryChannelDict = {}
        
        self.clientGroupTestMode = 0
        
        if 'Mode' in waveClientTableStore:
            self.clientGroupTestMode = int(waveClientTableStore['Mode'])
    	    del waveClientTableStore['Mode']
    	    
        self.waveChassisStore = waveChassisStore
        self.wavePortStore = wavePortStore
        self.waveClientTableStore = waveClientTableStore
        self.waveTestSpecificStore = waveTestSpecificStore
        self.waveBlogStore = waveBlogStore
        self.clientAnalysisStore = clientAnalysisStore
        self.waveTestStore = waveTestStore
        
        self.ecoSystemClientExist = True
        self.isClientRoamingTest = False
        
        self.perPortOptions = {}
        #print "Info in the wimix test..."
        
        #print "\n\nWave Chassis Store"
        #print waveChassisStore
        #print "\n\nWave port Store"
        #print wavePortStore
        #print "\n\nWave Client Store"
        #print waveClientTableStore
        #print "\n\nWave Security Store"
        #print waveSecurityStore
        #print "\n\nWave test Store"
        #print waveTestStore
        #print "\n\nWave Test Specific Store"
        #print waveTestSpecificStore,
        #print "\n\nWave Traffic Store"
        #print wimixTrafficStore
        #print "\n\nWave Server Store"
        #print wimixServerStore
        #print "Blog Store"
        #print waveBlogStore
        #print "Client Analysis Store"
        #print clientAnalysisStore
        self.blogPortList = []
        self.monitorPortList = []
        self.dynamicIntScheduleFlag = False
        self.CardMap = dict()
        self.loadDatabasedicts( waveChassisStore, wavePortStore, waveClientTableStore,waveSecurityStore, waveTestStore, waveTestSpecificStore,waveMappingStore, waveBlogStore,wimixTrafficStore,wimixServerStore)
        traffic_list=['VOIP','RTPAudio','RTPVideo','ftp','TCPAudio','TCPVideo','http' ,'tcp','udp','rtp']
        for each in traffic_list:
               self.UserPassFailCriteria[each] ={} 
        for chassis in waveChassisStore.keys():
            for cards in waveChassisStore[chassis].keys():
            	if 'BindStatus' not in waveChassisStore[chassis][cards]:
            	    for prts in waveChassisStore[chassis][cards]:                        
                        
            	    	if waveChassisStore[chassis][cards][prts]['CardMode'] == "MONITOR":
            	    	    if waveChassisStore[chassis][cards][prts]['BindStatus'] == "True":	
            	    	    	if waveChassisStore[chassis][cards][prts]['Channel'] == "Unknown":
            	    	    	    WaveEngine.OutputstreamHDL("\nChannel for Port %s cannot be Unknown\n" % (prts), WaveEngine.MSG_ERROR)
                                    raise WaveEngine.RaiseException	
            	    	    	     	
            	    	        self.monitorPortList.append(waveChassisStore[chassis][cards][prts]['PortName'])
                        
                        if prts in waveBlogStore:
                            if waveBlogStore[prts]['BlogMode'] == "True":
            	    	        if waveChassisStore[chassis][cards][prts]['BindStatus'] == "True":	
            	    	    	    if waveChassisStore[chassis][cards][prts]['Channel'] == "Unknown":
            	    	    	        WaveEngine.OutputstreamHDL("\nChannel for Port %s cannot be Unknown\n" % (prts), WaveEngine.MSG_ERROR)
                                        raise WaveEngine.RaiseException
            	    	    	    self.blogPortList.append(prts)
                                    
            	    	            if int(waveBlogStore[prts]['BlogIntType']) == 1:
            	    	                self.dynamicIntScheduleFlag = True    
            	    	
                        if waveChassisStore[chassis][cards][prts]['BindStatus'] == "True":
                            if waveChassisStore[chassis][cards][prts]['PortType'] == "8023":
                                cardParamsList = []
                                cardParamsList.append(chassis)
                                cardParamsList.append(int(waveChassisStore[chassis][cards][prts]['CardID']))
                                cardParamsList.append(int(waveChassisStore[chassis][cards][prts]['PortID']))
                                cardParamsList.append(waveChassisStore[chassis][cards][prts]['Autonegotiation'])
                                cardParamsList.append(int(waveChassisStore[chassis][cards][prts]['EthernetSpeed']))
                                cardParamsList.append(waveChassisStore[chassis][cards][prts]['Duplex']) 
                                self.CardMap[waveChassisStore[chassis][cards][prts]['PortName']] = cardParamsList  
                                if waveChassisStore[chassis][cards][prts]['CardMode'] != "MONITOR":
                                    self.ethCards.append(waveChassisStore[chassis][cards][prts]['PortName'])   
                                else:
                                    self.monEthCards.append(waveChassisStore[chassis][cards][prts]['PortName'])                              
                            else:
                                cardParamsList = []
                                cardParamsList.append(chassis)
                                cardParamsList.append(int(waveChassisStore[chassis][cards][prts]['CardID']))
                                cardParamsList.append(int(waveChassisStore[chassis][cards][prts]['PortID']))
                                
                                if waveChassisStore[chassis][cards][prts]['Channel'] == "Unknown":
            	    		    WaveEngine.OutputstreamHDL("\nChannel for Port %s cannot be Unknown\n" % (prts), WaveEngine.MSG_ERROR)
                                    raise WaveEngine.RaiseException
                                
                                cardParamsList.append(int(waveChassisStore[chassis][cards][prts]['Channel']))  
                                cardParamsList.append(int(waveChassisStore[chassis][cards][prts]['secChannel']))  
                                self.CardMap[waveChassisStore[chassis][cards][prts]['PortName']] = cardParamsList
                                
                                if waveChassisStore[chassis][cards][prts]['CardMode'] == "MONITOR":
                                    rxAtten = waveChassisStore[chassis][cards][prts]['MonRxAttenuation']
                                else:
                                    rxAtten = waveChassisStore[chassis][cards][prts]['RxAttenuation']
                                clBackoff = waveChassisStore[chassis][cards][prts]['ClientBackoff']
                                partCode = str(waveChassisStore[chassis][cards][prts]['PartCode'])                                
                                self.perPortOptions[prts] = {'rxAttenuation' : rxAtten, 'clientBackoff' : clBackoff, 'partCode' : partCode}            	    	
                                
                                if waveChassisStore[chassis][cards][prts]['CardMode'] == "MONITOR":
                                    self.monWifiCards.append(str(waveChassisStore[chassis][cards][prts]['PortName'])) 
                                elif waveChassisStore[chassis][cards][prts]['CardMode'] == "IG":
                                    self.igWifiCards.append(str(waveChassisStore[chassis][cards][prts]['PortName']))   
                                else:
                                    self.wifiCards.append(str(waveChassisStore[chassis][cards][prts]['PortName'])) 
                                     
                                self.secondaryChannelDict[str(waveChassisStore[chassis][cards][prts]['PortName'])] = int(waveChassisStore[chassis][cards][prts]['secChannel'])
                else:
            	    if waveChassisStore[chassis][cards]['BindStatus'] == "True":            	    	
            	    	if waveChassisStore[chassis][cards]['CardMode'] == "MONITOR":
            	    	    self.monitorPortList.append(waveChassisStore[chassis][cards]['PortName'])
            	    	
                        if waveChassisStore[chassis][cards]['PortType'] == "8023":
                            cardParamsList = []
                            cardParamsList.append(chassis)
                            cardParamsList.append(int(waveChassisStore[chassis][cards]['CardID']))
                            cardParamsList.append(int(waveChassisStore[chassis][cards]['PortID']))
                            cardParamsList.append(waveChassisStore[chassis][cards]['Autonegotiation'])
                            cardParamsList.append(int(waveChassisStore[chassis][cards]['EthernetSpeed']))
                            cardParamsList.append(waveChassisStore[chassis][cards]['Duplex']) 
                            self.CardMap[waveChassisStore[chassis][cards]['PortName']] = cardParamsList  
                            if waveChassisStore[chassis][cards]['CardMode'] != "MONITOR":
                                self.ethCards.append(waveChassisStore[chassis][cards]['PortName'])                     
                        else:
                            cardParamsList = []
                            cardParamsList.append(chassis)
                            cardParamsList.append(int(waveChassisStore[chassis][cards]['CardID']))
                            cardParamsList.append(int(waveChassisStore[chassis][cards]['PortID']))
                            
                            if waveChassisStore[chassis][cards]['Channel'] == "Unknown":
            	    	    	    WaveEngine.OutputstreamHDL("\nChannel for Port %s cannot be Unknown\n" % (cards), WaveEngine.MSG_ERROR)
                                    raise WaveEngine.RaiseException
                            
                            cardParamsList.append(int(waveChassisStore[chassis][cards]['Channel']))  
                            cardParamsList.append(int(waveChassisStore[chassis][cards]['secChannel']))  
                            self.CardMap[waveChassisStore[chassis][cards]['PortName']] = cardParamsList
                            if waveChassisStore[chassis][cards]['CardMode'] != "MONITOR":
                                self.wifiCards.append(str(waveChassisStore[chassis][cards]['PortName'])) 
        
                            
        if self.dynamicIntScheduleFlag:
            self.generateInterferenceSchedule(waveBlogStore)
                    
        self.CardList = []
        
        
        for crd in self.CardMap.keys():
            #if crd not in self.blogPortList:
            self.CardList.append(crd)	
        
        
        if len(self.clientAnalysisStore['clientFlowList'].keys()) > 0:            
            for itm in self.clientAnalysisStore['clientFlowList']:
                if self.clientAnalysisStore['clientFlowList'][itm]['srcPort1'] not in self.clientAnalysisPortsList:
                    self.clientAnalysisPortsList.append(self.clientAnalysisStore['clientFlowList'][itm]['srcPort1'])
                if self.clientAnalysisStore['clientFlowList'][itm]['dstPort1'] not in self.clientAnalysisPortsList:
                    self.clientAnalysisPortsList.append(self.clientAnalysisStore['clientFlowList'][itm]['dstPort1'])
                if int(self.clientAnalysisStore['clientFlowList'][itm]['idMode']) in [0,1]:
                    self.postProcessingNeeded  = True
                if self.clientAnalysisStore['clientFlowList'][itm]['metric'] == "Roaming Delay":
                    self.isClientRoamingTest = True
                if 'ap1Bssid' not in self.clientAnalysisStore['clientFlowList'][itm]:
                    self.clientAnalysisStore['clientFlowList'][itm]['ap1Bssid'] = "any"
                if 'ap2Bssid' not in self.clientAnalysisStore['clientFlowList'][itm]:
                    self.clientAnalysisStore['clientFlowList'][itm]['ap2Bssid'] = "any"    
            
        
        testData = waveTestSpecificStore['wimix_script']              
        self.TrafficTypes =  wimixTrafficStore
        self.serverList = wimixServerStore
        
        for srv in self.serverList:
            if 'serverType' not in self.serverList[srv]:
            	self.serverList[srv]['serverType'] = 0
        
        
        self.wimixMode = int(testData['wimixMode'])     
        
        self.testName = testData['wimixTestName']
        
        if self.testName == "WiMix":
            self.testType = "WiMix"
        else:
            self.testType = "WaveClient"
         
            
        self.CSVfilename      = 'Results_' + self.testType + '.csv'
        self.CSVOTRfilename   = 'Results_' + self.testType + '_over_time.csv'
        self.ReportFilename   = 'Report_' + self.testType + '.pdf'
        self.DetailedFilename = 'Detailed_Results_' + self.testType + '.csv'
        self.ConsoleLogFileName = "Console_" + self.testType + "_script.html"
        self.TimeLogFileName = "Timelog_" + self.testType + "_script.txt"
        self.RSSILogFileName = "RSSI_" + self.testType + "_script.csv"
        
        
        if self.testType == "WaveClient":
            if self.SavePCAPfile == False:
                self.filterFlowFrames = True
        
        self.setTestTypeInBaseTest(self.testType)
        
        if self.testType == "WiMix":
            if self.wimixMode == 0:
                self.testParameters['WiMix Mode'] = "TrafficMix"
            else:
                self.testParameters['WiMix Mode'] = "ClientMix"    
           
        self.wimixClientCentricProfiles = testData['clientWimix']
        self.wimixTrafficCentricProfiles = testData['trafficWimix']
        
        
        self.testProfileList = []
        
        self.loadList = []
        
        self.trialDuration = int(waveTestStore['TestParameters']['TrialDuration'])
        
        self.settleTime = int(waveTestStore['TestParameters']['SettleTime'])
        
        self.testParameters['Trial Duration'] = str(self.trialDuration) + " secs"        
        self.testParameters['Settle Time'] = str(self.settleTime) + " secs"
        
        if 'AgingTime' in waveTestStore['Learning']:
            self.agingTime = int(waveTestStore['Learning']['AgingTime'])        
        
        self.testParameters['Aging Time'] = str(self.agingTime) + " secs"
        
        if 'ReconnectClients' in waveTestStore['TestParameters']:
            self.reconnectClientsForTrial = int(waveTestStore['TestParameters']['ReconnectClients'])                    
        
        self.testParameters['Reconnect Clients each Trial'] = str(bool(self.reconnectClientsForTrial))
                   
        self.numTrials = int(waveTestStore['TestParameters']['NumTrials'])
        self.testParameters['Number of Trials'] = str(self.numTrials) + "  Trial(s)"
        
        if self.wimixMode == 0:
            
            if 'profiles' not in self.wimixTrafficCentricProfiles:
                return               	
            if 'testProfile' not in self.wimixTrafficCentricProfiles:
                return               	
            if len(self.wimixTrafficCentricProfiles['profiles'][self.wimixTrafficCentricProfiles['testProfile']]['trafficList']) == 0:
                return
            
            tstProfile = self.wimixTrafficCentricProfiles['testProfile']
            self.testProfileList.append(tstProfile)
            if  self.wimixTrafficCentricProfiles['profiles'][tstProfile]['loadMode'] == 0: 
                self.testParameters['Search Mode'] = "None"
                self.loadInKbps = self.wimixTrafficCentricProfiles['profiles'][tstProfile]['loadVal']
                self.testParameters['Traffic Load Per Port'] = str(self.loadInKbps) + " Kbps"
                if self.reconnectClientsForTrial == 1:
                    for ii in range(0, self.numTrials):
                        self.loadList.append(self.loadInKbps)
                        self.numFlowRuns = 1
                else:
                    self.loadList.append(self.loadInKbps)     
                    self.numFlowRuns = self.numTrials   
            elif self.wimixTrafficCentricProfiles['profiles'][tstProfile]['loadMode'] == 1:
                self.testParameters['Search Mode'] = "Linear Search"
                self.startLoadKbps = self.wimixTrafficCentricProfiles['profiles'][tstProfile]['loadSweepStart']
                self.endLoadKbps = self.wimixTrafficCentricProfiles['profiles'][tstProfile]['loadSweepEnd']
                self.loadStepKbps = self.wimixTrafficCentricProfiles['profiles'][tstProfile]['loadSweepStep']                    
                
                self.testParameters['Linear Search Start Load'] = str(self.startLoadKbps) + " Kbps"
                self.testParameters['Linear Search End Load'] = str(self.endLoadKbps) + " Kbps"
                self.testParameters['Linear Search Load Step'] = str(self.loadStepKbps) + " Kbps"                
                
                loadVal = self.startLoadKbps
                self.loadList.append(loadVal)                
                while loadVal < self.endLoadKbps:                    
                    loadVal += self.loadStepKbps
                    if loadVal > self.endLoadKbps:
                       loadVal = self.endLoadKbps
                    self.loadList.append(loadVal)              
            
            if 'continueFlag' in self.wimixTrafficCentricProfiles['profiles'][tstProfile]:              
                self.continueTestOnFail = bool(int(self.wimixTrafficCentricProfiles['profiles'][tstProfile]['continueFlag']))   
            
            if 'contAdminControlFlag' in self.wimixTrafficCentricProfiles['profiles'][tstProfile]:              
                self.continueTestOnAdminControlFail = bool(int(self.wimixTrafficCentricProfiles['profiles'][tstProfile]['contAdminControlFlag']))       
            
            if 'staggerStart' in self.wimixTrafficCentricProfiles['profiles'][tstProfile]: 
                self.staggerStartEnabled = bool(int(self.wimixTrafficCentricProfiles['profiles'][tstProfile]['staggerStart']))
            
            if 'staggerStartInt' in self.wimixTrafficCentricProfiles['profiles'][tstProfile]:
                self.staggerStartInt = int(self.wimixTrafficCentricProfiles['profiles'][tstProfile]['staggerStartInt'])
                     
                              
        elif self.wimixMode == 1:
        
            if 'profiles' not in self.wimixClientCentricProfiles:
                return               	
            if 'testProfile' not in self.wimixClientCentricProfiles:
                return               	
            if len(self.wimixClientCentricProfiles['profiles'][self.wimixClientCentricProfiles['testProfile']]['clientList']) == 0:
                return
        
            tstProfile = self.wimixClientCentricProfiles['testProfile']            
            self.testProfileList.append(tstProfile)  
            if  self.wimixClientCentricProfiles['profiles'][tstProfile]['loadMode'] == 0: 
                self.testParameters['Search Mode'] = "None"
                #self.numTotalClients = self.wimixClientCentricProfiles['profiles'][tstProfile]['loadVal']
                numClients  = self.wimixClientCentricProfiles['profiles'][tstProfile]['loadVal']
                self.testParameters['Client Load Per Port'] = numClients
                if self.reconnectClientsForTrial == 1:
                    for ii in range(0, self.numTrials):
                        self.loadList.append(numClients)
                        self.numFlowRuns = 1
                else:
                    self.loadList.append(numClients)  
                    self.numFlowRuns = self.numTrials      
            elif self.wimixClientCentricProfiles['profiles'][tstProfile]['loadMode'] == 1:
                self.testParameters['Search Mode'] = "Linear Search"
                self.startClientLoad = self.wimixClientCentricProfiles['profiles'][tstProfile]['loadSweepStart']
                self.endClientLoad = self.wimixClientCentricProfiles['profiles'][tstProfile]['loadSweepEnd']
                self.clientLoadStep = self.wimixClientCentricProfiles['profiles'][tstProfile]['loadSweepStep']
                
                self.testParameters['Linear Search Start Client Load'] = self.startClientLoad
                self.testParameters['Linear Search End Client Load'] = self.endClientLoad
                self.testParameters['Linear Search Load Step'] = self.clientLoadStep
                
                loadVal = self.startClientLoad
                self.loadList.append(loadVal)                
                while loadVal < self.endClientLoad:                    
                    loadVal += self.clientLoadStep
                    if loadVal > self.endClientLoad:
                       loadVal = self.endClientLoad
                    self.loadList.append(loadVal)
            
            if 'continueFlag' in self.wimixClientCentricProfiles['profiles'][tstProfile]:
                self.continueTestOnFail = bool(int(self.wimixClientCentricProfiles['profiles'][tstProfile]['continueFlag']))
            
            if 'contAdminControlFlag' in self.wimixClientCentricProfiles['profiles'][tstProfile]:
                self.continueTestOnAdminControlFail = bool(int(self.wimixClientCentricProfiles['profiles'][tstProfile]['contAdminControlFlag']))    
            
            if 'staggerStart' in self.wimixClientCentricProfiles['profiles'][tstProfile]: 
                self.staggerStartEnabled = bool(int(self.wimixClientCentricProfiles['profiles'][tstProfile]['staggerStart']))
            
            if 'staggerStartInt' in self.wimixClientCentricProfiles['profiles'][tstProfile]:
                self.staggerStartInt = int(self.wimixClientCentricProfiles['profiles'][tstProfile]['staggerStartInt'])
            
            self.testParameters['Continue Test On Fail Run'] = self.continueTestOnFail    
        
        #if self.testType == "WaveClient":
        #    loadVal = self.loadList[0]
        #    for ii in range(2, self.numTrials):
        #        self.loadList.append(loadVal)
       
        self.clientGroups = {}
        for cltGrps in waveClientTableStore.keys():
            
            grpName = waveClientTableStore[cltGrps]['Name'] 
            self.clientGroups[grpName] = {}
            self.clientGroups[grpName]['enable'] = waveClientTableStore[cltGrps]['Enable']            
            self.clientGroups[grpName]['type'] = waveClientTableStore[cltGrps]['Interface']    
            self.clientGroups[grpName]['portName'] = waveClientTableStore[cltGrps]['PortName']            
            self.clientGroups[grpName]['ssid'] = waveClientTableStore[cltGrps]['Ssid']  
            self.clientGroups[grpName]['bssid'] = waveClientTableStore[cltGrps]['Bssid'].split(" ")[0]  
            self.clientGroups[grpName]['Qos'] = waveClientTableStore[cltGrps]['Qos']	
            self.clientGroups[grpName]['Uapsd'] = waveClientTableStore[cltGrps]['Uapsd']
            self.clientGroups[grpName]['UapsdFlags'] = waveClientTableStore[cltGrps]['UapsdFlags']
            self.clientGroups[grpName]['UapsdSp'] = waveClientTableStore[cltGrps]['UapsdSp']
            self.clientGroups[grpName]['ListenInt'] = waveClientTableStore[cltGrps]['ListenInt']
            self.clientGroups[grpName]['LegacyPs'] = waveClientTableStore[cltGrps]['LegacyPs']    
            self.clientGroups[grpName]['DataPhyRate'] = float(waveClientTableStore[cltGrps]['DataPhyRate'])
            self.clientGroups[grpName]['MgmtPhyRate'] = float(waveClientTableStore[cltGrps]['MgmtPhyRate'])
            self.clientGroups[grpName]['security'] = waveSecurityStore[grpName]
            if waveClientTableStore[cltGrps]['Dhcp'] == "Enable":
                self.clientGroups[grpName]['ipMode'] = 0
            elif waveClientTableStore[cltGrps]['Dhcp'] == "Disable":  
            	self.clientGroups[grpName]['ipMode'] = 1
            self.clientGroups[grpName]['ipAddress'] = waveClientTableStore[cltGrps]['BaseIp'] 	
            self.clientGroups[grpName]['gateway'] = waveClientTableStore[cltGrps]['Gateway']  
            self.clientGroups[grpName]['subnetMask'] = waveClientTableStore[cltGrps]['SubnetMask']   
            self.clientGroups[grpName]['AssocProbe'] = waveClientTableStore[cltGrps]['AssocProbe']            
            self.clientGroups[grpName]['CtsToSelf'] = waveClientTableStore[cltGrps]['CtsToSelf'] 	
            self.clientGroups[grpName]['TransmitDeference'] = waveClientTableStore[cltGrps]['TransmitDeference']  
            self.clientGroups[grpName]['MgmtRetries'] = waveClientTableStore[cltGrps]['MgmtRetries']   
            self.clientGroups[grpName]['DataRetries'] = waveClientTableStore[cltGrps]['DataRetries'] 
            self.clientGroups[grpName]['CwMin'] = waveClientTableStore[cltGrps]['CwMin'] 	
            self.clientGroups[grpName]['CwMax'] = waveClientTableStore[cltGrps]['CwMax']  
            self.clientGroups[grpName]['Sifs'] = waveClientTableStore[cltGrps]['Sifs']   
            self.clientGroups[grpName]['Difs'] = waveClientTableStore[cltGrps]['Difs'] 
            self.clientGroups[grpName]['SlotTime'] = waveClientTableStore[cltGrps]['SlotTime'] 	
            self.clientGroups[grpName]['AckTimeout'] = waveClientTableStore[cltGrps]['AckTimeout']  
            self.clientGroups[grpName]['TxPower'] = waveClientTableStore[cltGrps]['TxPower']  
            self.clientGroups[grpName]['HpTxPower'] = waveClientTableStore[cltGrps]['HpTxPower'] 
            self.clientGroups[grpName]['FerVal'] = waveClientTableStore[cltGrps]['FerVal']    
            self.clientGroups[grpName]['BehindNat'] = waveClientTableStore[cltGrps]['BehindNat']
            self.clientGroups[grpName]['IncrIp'] = waveClientTableStore[cltGrps]['IncrIp'] 
            #self.clientGroups[grpName]['BOnlyMode'] = waveClientTableStore[cltGrps]['BOnlyMode']             
            self.clientGroups[grpName]['NumClients'] = waveClientTableStore[cltGrps]['NumClients']
            self.clientGroups[grpName]['GratuitousArp'] = waveClientTableStore[cltGrps]['GratuitousArp']
            
            if 'VlanEnable' in waveClientTableStore[cltGrps]:
            	self.clientGroups[grpName]['VlanEnable'] = waveClientTableStore[cltGrps]['VlanEnable']                
            else:
                self.clientGroups[grpName]['VlanEnable'] = False
                
            if 'VlanUserPriority' in waveClientTableStore[cltGrps]:
                self.clientGroups[grpName]['VlanUserPriority'] = int(waveClientTableStore[cltGrps]['VlanUserPriority'])
            else:
                self.clientGroups[grpName]['VlanUserPriority'] = 0
            
            if 'VlanId' in waveClientTableStore[cltGrps]:
                self.clientGroups[grpName]['VlanId'] = int(waveClientTableStore[cltGrps]['VlanId'])
            else:
                self.clientGroups[grpName]['VlanId'] = 0            
                       
                                    
            phyType = waveClientTableStore[cltGrps]['phyInterface']
            if phyType == '802.11ag':
                phyType = '11ag'
            elif phyType == '802.11b':
                phyType = '11b'
            elif phyType == '802.11n':
                phyType = '11n'                           
                self.clientGroups[grpName]['dataMcsIndex'] = waveClientTableStore[cltGrps]['nPhySettings']['DataMcsIndex']
                self.clientGroups[grpName]['channelBandwidth'] = waveClientTableStore[cltGrps]['nPhySettings']['ChannelBandwidth']
                self.clientGroups[grpName]['guardInterval'] = waveClientTableStore[cltGrps]['nPhySettings']['GuardInterval']
                self.clientGroups[grpName]['plcpConfiguration'] = waveClientTableStore[cltGrps]['nPhySettings']['PlcpConfiguration']
                self.clientGroups[grpName]['channelModel'] = waveClientTableStore[cltGrps]['nPhySettings']['ChannelModel']
                self.clientGroups[grpName]['enableAMPDUaggregation'] = waveClientTableStore[cltGrps]['nPhySettings']['EnableAMPDUaggregation']
                
            
            self.clientGroups[grpName]['phyType'] = phyType     
                       
            if waveClientTableStore[cltGrps]['MacAddressMode'] == "Auto":
                self.clientGroups[grpName]['macAddress'] = "AUTO"
            else:
                self.clientGroups[grpName]['macAddress'] = waveClientTableStore[cltGrps]['MacAddress']  	 
                
        self.overTimeResultsSampleOption = int(waveTestStore['TestParameters']['wimixResultSampleOption'])
        self.overTimeResultsSampleVal = int(waveTestStore['TestParameters']['wimixResultSampleVal'])
        self.overTimeResultType = int(waveTestStore['TestParameters']['wimixResultOption'])
        self.enableOverTimeResults = int(waveTestStore['TestParameters']['overTimeGraphs'])
        
        
        
        #for cltGrps in waveClientTableStore.keys():
        #    if waveClientTableStore[cltGrps]['IncrIp'] != "WaveAgent":
        #        self.ecoSystemClientExist = True
        
                
        if self.overTimeResultsSampleOption == 0:
            self.numResultUnits = self.overTimeResultsSampleVal
            if self.trialDuration > self.numResultUnits:
                self.resultSampleTime = self.trialDuration / self.numResultUnits                
            else:
                self.resultSampleTime = 1  
        else:
            if self.overTimeResultsSampleVal > self.trialDuration:
                self.overTimeResultsSampleVal = self.trialDuration
            self.resultSampleTime = self.overTimeResultsSampleVal           
        
        self.PortOptions['ContentionProbability'] = int(waveTestStore['TestParameters']['ClientContention'])
              
        
        self.openedJfWLink = False
        
        if int(waveTestStore['TestParameters']['progAttenFlag']) == 1:
            self.progAttenFlag = True	
            self.createAttenSchedule(waveTestStore['ProgAttenuation'])
            self.progAttenIp = waveTestStore['ProgAttenuation']['IpAddress']
            self.progAttenTestTime = waveTestStore['ProgAttenuation']['TestTime']
            self.openConnectionToJFW(self.progAttenIp)
        else:
            self.progAttenFlag = False    
            self.progAttenScheduleDict = {}
            
                
        
        self.AssociateRate    = int(waveTestStore['Connection']['AssocRate'])
        self.AssociateTimeout = int(waveTestStore['Connection']['AssocTimeout']) 
        self.ClientConnectionType = waveTestStore['Connection']['ConnectionType']
        self.ConnectionType = waveTestStore['Connection']['ConnectionType']
        
        self.biFlowConnectTimeout = int(waveTestStore['L4to7Connection']['ConnectionTimeout'])
        self.biFlowConnectRate = int(waveTestStore['L4to7Connection']['ConnectionRate'])
        if 'ConnectionPattern' in waveTestStore['L4to7Connection']:
            self.biFlowConnectMode = int(waveTestStore['L4to7Connection']['ConnectionPattern'])
         
                
        self.ClientLearningTime = int(waveTestStore['Learning']['ClientLearningTime'])        
        self.FlowLearningTime = int(waveTestStore['Learning']['FlowLearningTime'])
        
        self.ARPTimeout = int(waveTestStore['Learning']['ArpTimeout'])
        self.ARPRetries = int(waveTestStore['Learning']['ArpNumRetries'])
        self.ARPRate = int(waveTestStore['Learning']['ArpRate'])
        
        #self.KeepAliveMessagesFlag = waveTestStore['Learning']['KeepAliveMessages']
        
        self.DUTinfo = {}
        self.labelSplit = "@|#^&"
        
        switchModelStrList = waveTestStore['DutInfo']['WLANSwitchModel'].split(self.labelSplit)
        if len(switchModelStrList) == 1:
            self.DUTinfo['WLAN Switch Model'] = switchModelStrList[0]
        else:
            self.DUTinfo[switchModelStrList[0]] = switchModelStrList[1]
        
        switchSwVerStrList = waveTestStore['DutInfo']['WLANSwitchSWVersion'].split(self.labelSplit)
        if len(switchSwVerStrList) == 1:
            self.DUTinfo['WLAN Switch Version'] = switchSwVerStrList[0]
        else:
            self.DUTinfo[switchSwVerStrList[0]] = switchSwVerStrList[1]
        
        apModelStrList = waveTestStore['DutInfo']['APModel'].split(self.labelSplit)
        if len(apModelStrList) == 1:
            self.DUTinfo['AP Model'] = apModelStrList[0]
        else:
            self.DUTinfo[apModelStrList[0]] = apModelStrList[1]    
        
        apVerStrList = waveTestStore['DutInfo']['APSWVersion'].split(self.labelSplit)
        if len(apVerStrList) == 1:
            self.DUTinfo['AP SW Version'] = apVerStrList[0]
        else:
            self.DUTinfo[apVerStrList[0]] = apVerStrList[1]           
        
        # set the random seed
        self.RandomSeed = int( waveTestStore['TestParameters']['RandomSeed'] )
        
        #Test results must be stored in the test specific results directory, the directory name is testName
        testName = waveTestSpecificStore.keys()[0]
        
        # set the logging directory
        self.LoggingDirectory = waveTestStore['LogsAndResultsInfo']['LogsDir']
        if 'LogFormat' in waveTestStore['LogsAndResultsInfo']:
            self.captureFormat = int(waveTestStore['LogsAndResultsInfo']['LogFormat'])
        if waveTestStore['LogsAndResultsInfo']['CoBrandFlag'] == "True":
            self.brandLogoFlag = True
        else:
            self.brandLogoFlag = False        
        self.brandLogoFilePath = str(waveTestStore['LogsAndResultsInfo']['BrandDir'])
        if waveTestStore['LogsAndResultsInfo'].get('TestNameDir', 'False') == "True":    #Using .get() for backward compatibility with existing wml files which won't have this key
            self.LoggingDirectory = os.path.join(self.LoggingDirectory, self.testDir[testName])
        if waveTestStore['LogsAndResultsInfo']['TimeStampDir'] == "True":
            timeStr = time.strftime("%Y%m%d-%H%M%S", time.localtime(time.time()))
            self.LoggingDirectory = os.path.join(self.LoggingDirectory, timeStr)

        # create the logging directory
        if self.LoggingDirectory != '':
            if not os.path.exists(self.LoggingDirectory):
                try:
                    # create new logging directory
                    os.makedirs(self.LoggingDirectory)
                    if not os.path.exists(self.LoggingDirectory):
                        raise Exception, "Directory was not created."
                except Exception, e:
                    # error creating logging directory
                    msg = "Unable to create logging directory %s.\n%s\n" % ( self.LoggingDirectory, str(e) )
                    raise Exception, msg
        
        self.Logins = {}
        if len(waveClientTableStore.keys()) != 0:
            for clientGroup in waveClientTableStore.keys():
                # loop thru all client groups and extract login info
                if waveSecurityStore.has_key( clientGroup ):
                    loginMethod = str( waveSecurityStore[ clientGroup ].get( 'LoginMethod', 'Single' ) )
                    loginFile   = str( waveSecurityStore[ clientGroup ].get( 'LoginFile', '' ) )
                    baseUser    = str( waveSecurityStore[ clientGroup ].get( 'Identity', '' ) )
                    basePass    = str( waveSecurityStore[ clientGroup ].get( 'Password', '' ) )
                    numClients  = int( str( waveClientTableStore[ clientGroup ][ 'NumClients' ] ) )
                    loginList   = []

                    if loginMethod.lower() == 'increment':
                        # auto-increment
                        # generate list of logins
                        groupName = str( clientGroup )
                        for c in range( 0, numClients ):
                            # generate new username and password from base values
                            newUser = str( baseUser + "%04d" % ( c + 1 ) )
                            newPass = str( basePass + "%04d" % ( c + 1 ) )
                            loginList.append( ( newUser, newPass ) )
                        # save this client's list of logins to the main dictionary.
                        self.Logins[ clientGroup ] = loginList[:]

                    elif loginMethod.lower() == 'file':
                        # load login data from file.
                        # FIXME
                        msg = "Login File Mode not implemented."
                        raise Exception, msg
                    
                    # else single mode and nothing to add
                # else no security
            # next group
        
                
        if waveTestStore['LogsAndResultsInfo'].get('GeneratePdfReport', 'True') == "True":
            self.generatePdfReportF = True
        else:
            self.generatePdfReportF = False
         
        try:
            if 'wimix_script' not in waveTestSpecificStore.keys():
                self.Print("No WiMix config found\n", 'ERR')
                raise WaveEngine.RaiseException
        except WaveEngine.RaiseException:
            self.Print("WaveEngine terminating the run\n", 'ERR')
            self.CloseShop()
            return -1     	
    
        
    def Print(self, msg, itype = 'OK'):
        if itype == 'ERR':
            msgtype = WaveEngine.MSG_ERROR
        elif itype == 'OK':
            msgtype = WaveEngine.MSG_OK
        elif itype == 'SUCC':
            msgtype = WaveEngine.MSG_SUCCESS
        else:
            msgtype = WaveEngine.MSG_OK
        WaveEngine.OutputstreamHDL(msg, itype)   
        
    
    def openConnectionToJFW(self, ipAddr):
    	WaveEngine.OutputstreamHDL("Opening Telnet session with Attenuator\n", WaveEngine.MSG_OK) 
    	PORT = '3001' 
    	#return
    	self.JfwPointer = telnetlib.Telnet(ipAddr,PORT)
        
        self.JfwPointer.write("SA1 " + str(36) + "\n")
        self.JfwPointer.write("RA1" + "\n")
        attVal = self.JfwPointer.read_until("dB",1)
        if attVal != "36dB":
            WaveEngine.OutputstreamHDL("Error: Attenuator is not accepting remote commands.\n       Please make sure the attenuator is configured in remote Ethernet mode\n", WaveEngine.MSG_ERROR)
            raise WaveEngine.RaiseException     
        self.JfwPointer.write("SA1 " + str(0) + "\n")
        self.JfwPointer.write("SA2 " + str(63) + "\n")
        self.openedJfWLink = True
    
    def closeConnectionToJFW(self):
    	WaveEngine.OutputstreamHDL("Closing Telnet session with Attenuator\n", WaveEngine.MSG_OK)
    	#return
    	self.JfwPointer.write("SA1 " + str(0) + "\n")
        self.JfwPointer.write("SA2 " + str(63) + "\n")
        time.sleep(1)
    	self.JfwPointer.close()
    	self.openedJfWLink = False
    
    def sendCommandToJFW(self, attId, val):
    	if attId == 1:
    	    attStr = "SA1 " + str(val) + "\n"    	    
    	else:
    	    attStr = "SA2 " + str(val) + "\n"     
    	
    	WaveEngine.OutputstreamHDL("Setting up %d dB Attenuation on Attenuator # %d \n" % (val,attId), WaveEngine.MSG_OK) 
    	#return
    	self.JfwPointer.write(attStr)  	
    
        
    def sendMarkerPacketOnPorts(self, portList, markerStr, roamB, roamNum):
        ClientName = "markerMc"     	  	
    	membuf.clear()  
        membuf.assign(markerStr)
        for prt in portList:
            if self.isClientRoamingTest:
                WaveEngine.OutputstreamHDL("Transmitting %s roam marker packet on port : %s for roam # %d \n" % (roamB, prt, roamNum), WaveEngine.MSG_OK)                        
            WaveEngine.VCLtest("mc.create('%s')"        % (ClientName))
            WaveEngine.VCLtest("mc.setMacAddress('%s')" % ("aa:aa:aa:aa:aa:aa"))
            WaveEngine.VCLtest("mc.setIpAddressMode('static')")
            WaveEngine.VCLtest("mc.setIpAddress('%s')"  % ("192.168.1.1"))
            WaveEngine.VCLtest("mc.setSubnetMask('%s')" % ("255.255.255.0"))
            WaveEngine.VCLtest("mc.setGateway('%s')"    % ("192.168.1.1"))
            WaveEngine.VCLtest("mc.setPortList(['%s'])" % (prt))
            WaveEngine.VCLtest("mc.setBssidList(['%s'])" % ("bb:bb:bb:bb:bb:bb"))
            WaveEngine.VCLtest("mc.setSsid('%s')"  % ("veriwave"))
            WaveEngine.VCLtest("mc.write('%s')"         % (ClientName))                          
                              
            WaveEngine.VCLtest("mc.read('%s')" % (ClientName)) 
            WaveEngine.VCLtest("mc.sendFrame('%s',membuf)" % ClientName)
            WaveEngine.VCLtest("mc.destroy('%s')" % (ClientName))
    
        
    def createAttenSchedule(self, attenStore):
        self.attScheduleOnly = odict.OrderedDict()
        
        
        testType = int(attenStore['TestType'])
        att1Type = str(attenStore['Att1Type'])
        att2Type = str(attenStore['Att2Type'])         
        att1PermVal = int(attenStore['Att1Val'])
        att2PermVal = int(attenStore['Att2Val'])
        
        customAttenSchedule = attenStore['CustomSchedule']
    	
        if testType == 0:
    	    repeatCount = int(attenStore['RepeatCount'])
        else:
            repeatCount = 1
        roamInt = int(attenStore['RoamInt'])
        
    	tm = 0
    	minAtt = int(attenStore['MinVal'])
    	maxAtt = int(attenStore['MaxVal'])	
    	attStep = int(attenStore['ChangeStep'])
        attTime = int(attenStore['ChangeInt']) 
                
        att1 = minAtt
        att2 = maxAtt
        
        roamIdStr = "bbbbbbbbbbbbaaaaaaaaaaaa0000"
        
        if testType == 0:    	
    	    for jj in range(0, repeatCount):               
                roamBeginStr = "08020000" + "01005e0001" + ("%02x" % (jj + 1)) + roamIdStr	
            		
    	        smallAdd = tm + 0.0001
                self.progAttenScheduleDict[smallAdd] = {'attenId' : 3, 'attVal' : roamBeginStr, 'roamB' : "Start", 'roamNum' : (jj + 1) }
            	         
    	        if jj%2 == 0:
                    exitCount = 0
                    while exitCount != 2:
                        tm += attTime
                    
                        att1SetVal = att1
                        att2SetVal = att2

                        self.progAttenScheduleDict[tm] = {'attenId' : 1, 'attVal' : att1SetVal }                    
                        self.attScheduleOnly[tm] = {'att1' : att1SetVal, 'att2' : att2SetVal }                    
                        smallAdd = tm + 0.0001
                        self.progAttenScheduleDict[smallAdd] = {'attenId' : 2, 'attVal' : att2SetVal }
                    
                        att1 += attStep
                        att2 -= attStep
                    
                        if att2 <= minAtt:
                            att2 = minAtt
                            exitCount += 1
                        
                        if att1 >= maxAtt:
                            att1 = maxAtt   
                           
                else:
                    exitCount = 0
                    while exitCount != 2:
                        tm += attTime
                    
                        att1SetVal = att1
                        att2SetVal = att2
                        
                        self.progAttenScheduleDict[tm] = {'attenId' : 1, 'attVal' : att1SetVal }
                        self.attScheduleOnly[tm] = {'att1' : att1SetVal, 'att2' : att2SetVal }
                        smallAdd = tm + 0.0001
                        self.progAttenScheduleDict[smallAdd] = {'attenId' : 2, 'attVal' : att2SetVal }
                    
                        att1 -= attStep
                        att2 += attStep
                    
                        if att1 <= minAtt:
                            att1 = minAtt
                            exitCount += 1
                        
                        if att2 >= maxAtt:
                           att2 = maxAtt   
            
                offset =  0
                if roamInt > 4:
                    offset = 4
                    tm += (roamInt - offset)
            
                smallAdd = tm + 0.0001
            
                roamEndStr = "08020000" + "01005e0002" + ("%02x" % (jj + 1)) + roamIdStr
                self.progAttenScheduleDict[smallAdd] = {'attenId' : 3, 'attVal' : roamEndStr, 'roamB' : "End", 'roamNum' : (jj + 1) }
            
                tm+= 2

                smallAdd = tm + 0.0001
                self.progAttenScheduleDict[smallAdd] = {'attenId' : 4, 'attVal' : "", 'roamB' : "", 'roamNum' : (jj + 1) }
                
                tm+= 2  
        
        else:
            tm = 0
            for ii in range(0, len(customAttenSchedule)):
                att1SetVal = int(customAttenSchedule[ii][0])
                att2SetVal = int(customAttenSchedule[ii][1])
                dur = int(customAttenSchedule[ii][2])
                
                if dur != 0:
                    tm += dur                    
                    self.progAttenScheduleDict[tm] = {'attenId' : 1, 'attVal' : att1SetVal }                    
                    smallAdd = tm + 0.0001
                    self.progAttenScheduleDict[smallAdd] = {'attenId' : 2, 'attVal' : att2SetVal }
                    self.attScheduleOnly[tm] = {'att1' : att1SetVal, 'att2' : att2SetVal }                    
            
    
    def generateInterferenceSchedule(self, blogStore):    	
    	for prt in blogStore:
    	    absTime = 0
    	    if blogStore[prt]['BlogMode'] == "True":
    	        if int(blogStore[prt]['BlogIntType']) == 1:
    	            for ii in range(0, (int(blogStore[prt]['BlogRepeatCount'])+1)):
    	            	for itm in blogStore[prt]['BlogSchedule']:
    	    	            absTime = absTime + int(blogStore[prt]['BlogSchedule'][itm]['intDur']) 	
    	    	            if absTime not in self.blogScheduleDict:
    	    	                self.blogScheduleDict[absTime] = {'port' : prt, 'intPer' : int(blogStore[prt]['BlogSchedule'][itm]['intPer']), 'channel' : blogStore[prt]['BlogChannel']}
    	    	            else:
    	    	                smallAdd = absTime + 0.1
    	    	                self.blogScheduleDict[smallAdd] = {'port' : prt, 'intPer' : int(blogStore[prt]['BlogSchedule'][itm]['intPer']), 'channel' : blogStore[prt]['BlogChannel']}     
    	    	                
    	if len(self.blogScheduleDict.keys()) > 0:
    	    #self.staggerStartCustomEnabled = True
    	    self.dynamicBlogModeflag = True
    	        	
    	#print"\n\n"
    	#print self.blogScheduleDict     	    	
    
    
    
    def createNetworkMap(self):
        self.networkMap = dict()
        bssid_dict = WaveEngine.GetBSSIDdictonary(self.wifiCards, 10)
        if len(bssid_dict.keys()) == 0:
            WaveEngine.OutputstreamHDL("No BSSIDs found on any of the ports..exiting the test", WaveEngine.MSG_ERROR)
            return -1            
        for PortName in bssid_dict.keys():
                WaveEngine.VCLtest("port.read('%s')" % (PortName))
                bssid_list = []
                ssid_list = []
                bssidSsidDict = dict()
                if len(bssid_dict[PortName]) == 0:
                    if self.continueTestOnFail == False:
                        WaveEngine.OutputstreamHDL("No BSSIDs found on Port %s..exiting the test" % (PortName), WaveEngine.MSG_ERROR)                    
                        return -1
                    else:
                        WaveEngine.OutputstreamHDL("No BSSIDs found on Port %s..moving on with the test" % (PortName), WaveEngine.MSG_ERROR)    
                for bssid in bssid_dict[PortName]:
                    bssid_list.append(bssid)             
                    ssid_list.append(port.getBssidSsid(bssid))
                    #if port.getBssidSsid(bssid):
                    #    ssid_list.append(port.getBssidSsid(bssid))
                    #else:
                    #    if PortName in self.wavePortStore:
                    #        if bssid in self.wavePortStore[PortName]:
                    #            ssid_list.append(self.wavePortStore[PortName][bssid])
                
                bssidSsidDict['ssid'] = ssid_list
                bssidSsidDict['bssid'] = bssid_list
                self.networkMap[PortName] = bssidSsidDict
                WaveEngine.VCLtest("port.write('%s')" % (PortName))
    
    
    def findPortsWithSsid(self, ssid):
        returnPortList = []
        for ports in self.networkMap.keys():
                if ssid in self.networkMap[ports]['ssid']:
                    returnPortList.append(ports) 
                else:
                    WaveEngine.OutputstreamHDL("Warning: SSID %s not found on Port %s.." % (ssid,ports), WaveEngine.MSG_WARNING)
                    #return -1
                            
        return returnPortList
        
    
    def RandomMAC(self):
        value1 = 0
        value2 = 1
        value3 = 2
        value4 = int(random.random()*256)
        value5 = int(random.random()*256)
        value6 = int(random.random()*256)
        return "%02X:%02X:%02X:%02X:%02X:%02X" % (value1, value2, value3, value4, value5, value6)    
    
    
    def createDummyWifiClientsForWaveAgentServers(self):  
    	self.wifiServerList = []  	
    	for srvName in self.serverList:
    	    if self.serverList[srvName]['serverType'] == 1:
    	        if self.serverList[srvName]['ethPort'] not in self.ethCards:
    	            prt =  self.wavePortStore.keys()[0]
    	            bssid = self.wavePortStore[prt].keys()[0].split("(")[0].rstrip()
    	            mac_addr = self.serverList[srvName]['macAddress']
    	            ip_addr = self.serverList[srvName]['ipAddress']
    	            netmask = self.serverList[srvName]['netmask']
    	            gateway = self.serverList[srvName]['gateway']    	            
    	            clientData = [(srvName, prt, bssid, mac_addr, ip_addr, netmask, gateway, (1, "AUTO", '0.0.0.1'), {}, {})]
                    WaveEngine.CreateClients(clientData)
                    self.wifiServerList.append(srvName)
                    self.serverList[srvName]['ethPort'] = prt
                    self.clientPortDict[srvName] = (port, 'wa')
                    	            
        
    def createServers(self, activeServerNames):   
    	#for server in self.serverList.keys():   
    	for server in activeServerNames:
            eClName = server
    	    port =  self.serverList[server]['ethPort']	
    	    
    	    if len(self.igmpResponderClientList) != 0:
    	        respExists = 0
    	        for resps in self.igmpResponderClientList:
    	            if resps[2] == port:
    	               respExists = 1
    	        if respExists == 0:
    	            self.igmpResponderClientList.append((eClName,"", port,1))      	       
    	        
    	    
    	    if int(self.serverList[server]['ipMode']) == 0:
    	        ip_addr = "0.0.0.0"
    	    else:
    	        ip_addr = self.serverList[server]['ipAddress']
    	    
    	    if int(self.serverList[server]['macMode']) == 1:
    	        mac_addr = "AUTO"
    	        
    	    else:
    	        mac_addr = self.serverList[server]['macAddress']      	            
    	    
    	    netmask = self.serverList[server]['netmask']
    	    gateway = self.serverList[server]['gateway']
    	    
    	    clientOptions = {}
    	    if int(self.serverList[server]['vlan']['enable']) == 1:
    	        clientOptions['VlanTag'] = (0 & 0x7 )* 2**13 + (0 & 0x1 ) * 2**12 + (int(self.serverList[server]['vlan']['id']) & 0xfff )  
    	        
    	    clientOptions['enableNetworkInterface'] = True
    	    
    	    clientData = [(eClName, port, '00:00:00:00:00:00', mac_addr, ip_addr, netmask, gateway, (1, 'AUTO', '0.0.0.1'), {'Method': 'NONE'}, clientOptions)]
            cl_dict = WaveEngine.CreateClients(clientData)
            
            self.ClientsDict[eClName] = clientData            
            self.destClients[eClName] = clientData
            
            self.clientPortDict[eClName] = (port, 'ec')
            
            if int(self.serverList[server]['serverType']) == 0:
                for kys in cl_dict.keys():
                    self.clientList[kys] = cl_dict[kys]
    
    
    def setupIgmpResponders(self):
    	if len(self.igmpResponderClientList) == 0:
    	    print("No clients in the IGMP responder list...")
    	    return
    	doneSsidPortPairList = []
    	self.igmpResponderList = []
    	for ii in range(0, len(self.igmpResponderClientList)):
    	    clName = self.igmpResponderClientList[ii][0] 
    	    ssid = self.igmpResponderClientList[ii][1]	
    	    clientPort = self.igmpResponderClientList[ii][2]    	    
    	    if (ssid,clientPort) not in doneSsidPortPairList:   
    	        for mcastIp in self.mcastDummyClientDict:	    
    	            igmpName = "IGMP_%s_%s" % (clName, self.mcastDummyClientDict[mcastIp][0])
                    WaveEngine.VCLtest("igmp.create('%s')" % (igmpName))
                    WaveEngine.VCLtest("igmp.setIpMulticastAddress('%s')" % (mcastIp))
                    WaveEngine.VCLtest("igmp.setMacMulticastAddress('%s')" % (self.mcastDummyClientDict[mcastIp][1]))
                    WaveEngine.VCLtest("igmp.setPort('%s')" % (clientPort))
                    WaveEngine.VCLtest("igmp.setDefaultClient('%s')" % (clName))
                    WaveEngine.VCLtest("igmp.write('%s')" % (igmpName))
                    self.Print("Setup IGMP Responder: %s" % (igmpName))
                    self.igmpResponderList.append(igmpName)
                ssidPortPair = (ssid,clientPort)
                doneSsidPortPairList.append(ssidPortPair)
    
    
    def tearDownFlowQoSHandshake(self): 
    	for clientName in mc.getNames():
    	    if (clientName in self.clientsWithAggregation) or (clientName in self.clientsWithAdminControl):
    	        WaveEngine.VCLtest("mc.read('%s')" % clientName)
                WaveEngine.VCLtest("mc.teardownQosHandshake('%s')" % clientName)
                WaveEngine.OutputstreamHDL("Teardown QoS Handshake message sent for Client %s\n\n" % (clientName), WaveEngine.MSG_OK)    
    
    def doFlowQoSHandshake(self): 
    	for clientName in mc.getNames():
    	    if (clientName in self.clientsWithAggregation) or (clientName in self.clientsWithAdminControl):
    	        WaveEngine.VCLtest("mc.read('%s')" % clientName)
                WaveEngine.VCLtest("mc.doQosHandshake('%s')" % clientName)
                if not self.pollMCstatus(clientName, 7, 5.0):
                    WaveEngine.OutputstreamHDL("Warning:Client %s didn't succeed with the QoS Handshake needed for aggregation/admission control\n\n" % (clientName), WaveEngine.MSG_ERROR)
                    if self.continueTestOnAdminControlFail == False:
                        return -1
                else:
                    WaveEngine.OutputstreamHDL("Client %s QoS Handshake successful" % (clientName), WaveEngine.MSG_OK)    
    
    def pollMCstatus(self, clientName, expectedState, timeout):
        timeStart = time.time()
        while True:
            state = WaveEngine.VCLtest("mc.checkStatus('%s')"%clientName)
            if state >= expectedState:
                return True
            else:
                time.sleep(0.1)
            if time.time() > timeStart + timeout:
                return False
         
    
    def setQosForFlows(self):
    	for flwName in self.flowTypeDict.keys():
            srcPort = self.flowTypeDict[flwName][1]
            srcClient = self.flowTypeDict[flwName][3]
            qosMetrics = self.flowTypeDict[flwName][7]	
            
            flowType = self.flowTypeDict[flwName][9]   
            direction = self.flowTypeDict[flwName][10][5]  
                                              
            if int(qosMetrics['layer2Qos']['enable']) == 1:	     
    	        if srcPort in self.wifiCards:
    	            layer2Up = int(qosMetrics['layer2Qos']['wlanUp'])
    	            if srcClient in self.clientsWithAggregation:
    	                aggregation = 1 
    	            else:    
    	                aggregation = 0
    	            
    	            if 'adControl' in qosMetrics['layer2Qos']:      
    	                adminControl = int(qosMetrics['layer2Qos']['adControl'])
    	            else:
    	                adminControl = 0
    	                	                    
    	            flDir = int(qosMetrics['layer2Qos']['flDir'])
    	            if flDir == 0:
    	                flDirStr = "uplink-only"
    	            elif flDir == 1:
    	                flDirStr = "downlink-only" 
    	            else:
    	                flDirStr = "bidirectional"        
    	                
    	            if flowType in ["flow", "mcastflow"]:      
    	            	WaveEngine.VCLtest("flow.read('%s')" % (flwName))     
                        WaveEngine.VCLtest("wlanQos.readFlow()")    
                                            
                        WaveEngine.VCLtest("wlanQos.setTgaPriority(%s)" % layer2Up)
                        WaveEngine.VCLtest("wlanQos.setUserPriority(%s)" % layer2Up)
                    
                        if aggregation != 0:
                            WaveEngine.VCLtest("wlanQos.setMPDUAggregationEnable('%s')" % ('on'))
                            WaveEngine.VCLtest("wlanQos.setAcParamFromBss('%s')" % ('off'))                        
                            WaveEngine.VCLtest("wlanQos.setAckPolicy('block')")  
                            
                                                    
                        if adminControl != 0:                          
                            minPhyRateVal = self.tspecMinPhyRates[int(qosMetrics['layer2Qos']['minPhyRate'])]
                            WaveEngine.VCLtest("wlanQos.setAdmissionControl('on', 'off')")
                            WaveEngine.VCLtest("wlanQos.setTid(%d)" % int(qosMetrics['layer2Qos']['tid']))
                            WaveEngine.VCLtest("wlanQos.setMsduSize(%d)" % int(qosMetrics['layer2Qos']['msduSize']))
                            WaveEngine.VCLtest("wlanQos.setMeanDataRate(%d)" % int(qosMetrics['layer2Qos']['mDataRate']))
                            WaveEngine.VCLtest("wlanQos.setMinPhyRate(%f)" % float(minPhyRateVal))
                            WaveEngine.VCLtest("wlanQos.setBandwidth(%d)" % int(qosMetrics['layer2Qos']['surBand']))                            
                            WaveEngine.VCLtest("wlanQos.setDirection('%s')" % flDirStr )
                            self.clientsWithAdminControl.append(srcClient) 

                        WaveEngine.VCLtest("wlanQos.modifyFlow()")  
                        WaveEngine.VCLtest("flow.write('%s')" % (flwName))
                                        
                    elif flowType == "biFlow":
                    	
                    	WaveEngine.VCLtest("biflow.read('%s')" % (flwName))
            	        WaveEngine.VCLtest("biflowQos.readBiflow('Forward')")
            	                    	        
    	                WaveEngine.VCLtest("biflowQos.setTgaPriority(%s)" % layer2Up)
                        WaveEngine.VCLtest("biflowQos.setUserPriority(%s)" % layer2Up)
                    
                        if aggregation != 0:
                            WaveEngine.VCLtest("biflowQos.setMPDUAggregationEnable('%s')" % ('on'))
                            WaveEngine.VCLtest("biflowQos.setAcParamFromBss('%s')" % ('off'))                        
                            WaveEngine.VCLtest("biflowQos.setAckPolicy('block')")  
                            
                        if adminControl != 0:  
                            minPhyRateVal = self.tspecMinPhyRates[int(qosMetrics['layer2Qos']['minPhyRate'])]
                            WaveEngine.VCLtest("biflowQos.setAdmissionControl('on', 'off')")
                            WaveEngine.VCLtest("biflowQos.setTid(%d)" % int(qosMetrics['layer2Qos']['tid']))
                            WaveEngine.VCLtest("biflowQos.setMsduSize(%d)" % int(qosMetrics['layer2Qos']['msduSize']))
                            WaveEngine.VCLtest("biflowQos.setMeanDataRate(%d)" % int(qosMetrics['layer2Qos']['mDataRate']))
                            WaveEngine.VCLtest("biflowQos.setMinPhyRate(%f)" % float(minPhyRateVal))
                            WaveEngine.VCLtest("biflowQos.setBandwidth(%d)" % int(qosMetrics['layer2Qos']['surBand']))                            
                            WaveEngine.VCLtest("biflowQos.setDirection('%s')" % flDirStr )
                            self.clientsWithAdminControl.append(srcClient) 
                        
                        WaveEngine.VCLtest("biflowQos.modifyBiflow('Forward')")  
            	        WaveEngine.VCLtest("biflow.write('%s')" % (flwName))            	        
            	                    	        
            	        WaveEngine.VCLtest("biflow.read('%s')" % (flwName))
            	        WaveEngine.VCLtest("biflowQos.readBiflow('Reverse')")            	                    	        
    	                WaveEngine.VCLtest("biflowQos.setTgaPriority(%s)" % layer2Up)
                        WaveEngine.VCLtest("biflowQos.setUserPriority(%s)" % layer2Up)                        
                        WaveEngine.VCLtest("biflowQos.modifyBiflow('Reverse')")  
            	        WaveEngine.VCLtest("biflow.write('%s')" % (flwName))            	        
                                       
    	        elif srcPort in self.ethCards:
    	            
    	            if direction == "Uplink":
    	                layer2Up = int(qosMetrics['layer2Qos']['wlanUp'])
    	            else:
    	                layer2Up = int(qosMetrics['layer2Qos']['ethUp'])    
    	            
    	            if flowType in ["flow", "mcastflow"]:           
    	            	WaveEngine.VCLtest("flow.read('%s')" % (flwName))
                        WaveEngine.VCLtest("enetQos.readFlow()")
                        
                        WaveEngine.VCLtest("enetQos.setTgaPriority(%s)" % layer2Up)
                        WaveEngine.VCLtest("enetQos.setUserPriority(%s)" % layer2Up)
                        
                        WaveEngine.VCLtest("enetQos.modifyFlow()")  
                        WaveEngine.VCLtest("flow.write('%s')" % (flwName))
                        
                    elif flowType == 'biFlow':
                    	WaveEngine.VCLtest("biflow.read('%s')" % (flwName))
            	        WaveEngine.VCLtest("biflowQos.readBiflow('Forward')")    	            
    	                WaveEngine.VCLtest("biflowQos.setTgaPriority(%s)" % layer2Up)
                        WaveEngine.VCLtest("biflowQos.setUserPriority(%s)" % layer2Up)                        
                        WaveEngine.VCLtest("biflowQos.modifyBiflow('Forward')")  
            	        WaveEngine.VCLtest("biflow.write('%s')" % (flwName))
            	        
            	        WaveEngine.VCLtest("biflow.read('%s')" % (flwName))
            	        WaveEngine.VCLtest("biflowQos.readBiflow('Reverse')")    	            
    	                WaveEngine.VCLtest("biflowQos.setTgaPriority(%s)" % layer2Up)
                        WaveEngine.VCLtest("biflowQos.setUserPriority(%s)" % layer2Up)                        
                        WaveEngine.VCLtest("biflowQos.modifyBiflow('Reverse')")  
            	        WaveEngine.VCLtest("biflow.write('%s')" % (flwName))          	        
                               
                       
            if int(qosMetrics['layer3Qos']['enable']) == 1:
    	        dscpVal =  int(qosMetrics['layer3Qos']['dscp'])
    	           	        
    	        if flowType in ["flow", "mcastflow"]:   
    	            WaveEngine.VCLtest("flow.read('%s')" % (flwName))
                    WaveEngine.VCLtest("ipv4.readFlow()")  
                    WaveEngine.VCLtest("ipv4.setDscpMode('on')") 
                    WaveEngine.VCLtest("ipv4.setDscp(%d)" % dscpVal) 
                    WaveEngine.VCLtest("ipv4.modifyFlow()")  
                    WaveEngine.VCLtest("flow.write('%s')" % (flwName))                  
                elif flowType == 'biFlow':
                    WaveEngine.VCLtest("biflow.read('%s')" % (flwName))
            	    WaveEngine.VCLtest("biflowIpv4.readBiflow('Forward')")             	        
            	    WaveEngine.VCLtest("biflowIpv4.setDscpMode('on')") 
                    WaveEngine.VCLtest("biflowIpv4.setDscp(%d)" % dscpVal) 
                    WaveEngine.VCLtest("biflowIpv4.modifyBiflow('Forward')")  
                    WaveEngine.VCLtest("biflow.write('%s')" % (flwName))  
                    
                    WaveEngine.VCLtest("biflow.read('%s')" % (flwName))
                    WaveEngine.VCLtest("biflowIpv4.readBiflow('Reverse')")             	        
            	    WaveEngine.VCLtest("biflowIpv4.setDscpMode('on')") 
                    WaveEngine.VCLtest("biflowIpv4.setDscp(%d)" % dscpVal) 
                    WaveEngine.VCLtest("biflowIpv4.modifyBiflow('Reverse')")                          
            	    WaveEngine.VCLtest("biflow.write('%s')" % (flwName))      	                    
                
            if qosMetrics['ipProtocolNum'] != 'Auto':
                ipProtocolNum =  int(qosMetrics['ipProtocolNum'])                
                if flowType in ["flow", "mcastflow"]: 
                    WaveEngine.VCLtest("flow.read('%s')" % (flwName))          
                    WaveEngine.VCLtest("ipv4.readFlow()")  
                    WaveEngine.VCLtest("ipv4.setProtocol(%d)" % ipProtocolNum)
                    WaveEngine.VCLtest("ipv4.modifyFlow()")  
                    WaveEngine.VCLtest("flow.write('%s')" % (flwName))                    
                elif flowType == 'biFlow':
                    WaveEngine.OutputstreamHDL("Warning: Protocol number setting does not work for TCP/HTTP/UDP flows in this release.\n\n", WaveEngine.MSG_ERROR)	
                    #WaveEngine.VCLtest("biflow.read('%s')" % (flwName))	
            	    #WaveEngine.VCLtest("biflowIpv4.readBiflow('Forward')")     
            	    #WaveEngine.VCLtest("biflowIpv4.setProtocol(%d)" % ipProtocolNum) 
            	    
                    #WaveEngine.VCLtest("biflowIpv4.modifyBiflow('Forward')")
                    #WaveEngine.VCLtest("biflowIpv4.readBiflow('Reverse')")     
            	    #WaveEngine.VCLtest("biflowIpv4.setProtocol(%d)" % ipProtocolNum) 
                    #WaveEngine.VCLtest("biflowIpv4.modifyBiflow('Reverse')")
            	    #WaveEngine.VCLtest("biflow.write('%s')" % (flwName)) 
            
    
    def updateClientPowerSaveModes(self):    	
    	for clnt in self.clientList:
    	    if self.clientList[clnt][2] == "mc": 
    	    	WaveEngine.VCLtest("mc.read('%s')" % (clnt))    
    	    	if len(self.clientPowerSaveOptionsDict[clnt].keys()) > 0:       	    	
    	    	    #for opts in self.clientPowerSaveOptionsDict[clnt].keys():    	    	    	    	    
    	    	    #    if opts == "WmeUapsd":
    	    	    #    	WaveEngine.VCLtest("mc.setWmeUapsd('%s')" % (self.clientPowerSaveOptionsDict[clnt][opts]))    	    	    
    	    	    #    if opts == "WmeUapsdAcFlags":
    	    	    #    	WaveEngine.VCLtest("mc.setWmeUapsdAcFlags(%d)" % (self.clientPowerSaveOptionsDict[clnt][opts]))    	    	    
    	    	    #    if opts == "WmeUapsdSpLength":
    	    	    #    	WaveEngine.VCLtest("mc.setWmeUapsdSpLength(%d)" % (self.clientPowerSaveOptionsDict[clnt][opts]))    	    	    
    	    	    #    if opts == "ListenInterval":
    	    	    #    	WaveEngine.VCLtest("mc.setListenInterval(%d)" % (self.clientPowerSaveOptionsDict[clnt][opts]))    	    	    
    	    	    #    if opts == "PowerSave":
    	    	    #    	WaveEngine.VCLtest("mc.setPowerSave('%s')" % (self.clientPowerSaveOptionsDict[clnt][opts]))    	    	
    	    	    WaveEngine.VCLtest("mc.updatePowerSaveMode('%s', '%s')" % (clnt, "on"))    
    	    	    
        
    def createFlowBurstSchedule(self, FlowName, burstDataDict):
    	burstInt = int(burstDataDict['ibg'])	
        numFrames = int(burstDataDict['burstDur'])
        iRate = int(burstDataDict['burstRate'])
        burstTime = (numFrames / iRate) * 1.0
        sTime = 0        
        numIter = 0
        while sTime <= self.trialDuration:
            if sTime in self.burstModeScheduleDict:
                useTime = sTime + 0.001 * random.random()
            else:
                useTime = sTime    
            self.burstModeScheduleDict[useTime] = {'flowName' : FlowName, 'numFrames' : numFrames, 'flowRate' : iRate }
            numIter += 1
            sTime = sTime + burstInt + burstTime
        
        return (numFrames * numIter)
    
    def setupBiDirectionalVoiceFlow(self, wClName, eClName, phyRate, trafficType, direction, options, 
                   wimixProfile, trailNum, slaReq, qosDict, flwNum,flowDiagInfo,delayVal,endTime,numFrames,clIntType,ttlVal,appPayload,tType,burstDataDict):   
    	
    	if 'SrcPort' in options.keys():
            srcPort = int(options['SrcPort'])
        else:
            srcPort = 5003  
        
        if 'DestPort' in options.keys():
            dstPort = int(options['DestPort'])
        else:
            dstPort = 5004       
        
        if int(options['voipCodec']) == 0:
            codecType = "VOIPG711"
        elif int(options['voipCodec']) == 1: 
            codecType = "VOIPG7231"
        elif int(options['voipCodec']) == 2:    
            codecType = "VOIPG729A"
        
        payPatten = self.appPayloadCodes[appPayload['payPattern']]
        payData = appPayload['payData']
                
        sipFlag = int(options['voipSignaling'])    
            
        if sipFlag != 0:
            self.sipClientPairs.append((wClName, eClName,srcPort,dstPort,qosDict,clIntType))
        
        flwList = []
        
        #if trafficType == "VOIPG711":
        #    codecType = "VOIPG711"
        #elif trafficType == "VOIPG729":
        #    codecType = "VOIPG729A"	
        #elif trafficType == "VOIPG723":
        #    codecType = "VOIPG7231"		
        
            
    	if direction in ["downlink", "unicast(downlink)", "bidirectional"]:  	
            FlowName = "F_%s_%s-->%s_%d" % (trafficType, eClName, wClName, flwNum)
            
            self.flowNameTrafficProfileNameDict[FlowName] = tType            
            WaveEngine.VCLtest("flow.create('%s')"        % (FlowName))
            WaveEngine.VCLtest("flow.setSrcClient('%s')"  % (eClName))
            WaveEngine.VCLtest("flow.setDestClient('%s')" % (wClName))
            
            WaveEngine.VCLtest("flow.setType('%s')" % (codecType))
            WaveEngine.VCLtest("flow.setNumFrames(%d)" % (numFrames))  
            WaveEngine.VCLtest("flow.setPhyRate(%f)" % phyRate)   
            WaveEngine.VCLtest("flow.setInsertSignature('on')")
            
            WaveEngine.VCLtest("flow.setPayloadMode('%s')" % payPatten)            
            if payData != "None" and len(payData) > 0:
                WaveEngine.VCLtest("flow.setPayload('%s')" % payData)
            
            if wClName in self.clientsBehindNatList:
                WaveEngine.VCLtest("flow.setNatEnable('on')")   
            else:
                WaveEngine.VCLtest("flow.setNatEnable('off')")                  
            
            WaveEngine.VCLtest("ipv4.readFlow()")
            WaveEngine.VCLtest("ipv4.setTtl(%d)" % (ttlVal) )     
            
            #WaveEngine.VCLtest("ipv4.setPrecedence(%d)" % (7) )
            #WaveEngine.VCLtest("ipv4.setTos('delay')")
            #WaveEngine.VCLtest("ipv4.setTos('throughput')")
                  
            WaveEngine.VCLtest("ipv4.modifyFlow()")
                   
            WaveEngine.VCLtest("udp.readFlow()")
            WaveEngine.VCLtest("udp.setSrcPort(%d)" % (dstPort) )
            WaveEngine.VCLtest("udp.setDestPort(%d)" % (srcPort) )
            WaveEngine.VCLtest("udp.modifyFlow()")        
            
            WaveEngine.VCLtest("flow.write('%s')"        % (FlowName))
            
            WaveEngine.VCLtest("flowGroup.read('mainFlowGroup')")
            WaveEngine.VCLtest("flowGroup.add('%s')" % (FlowName))
            WaveEngine.VCLtest("flowGroup.write('mainFlowGroup')")   
            
            WaveEngine.VCLtest("flow.read('%s')"        % (FlowName))
            frmSize = flow.getFrameSize()
            frmRate = flow.getIntendedRate()
            
            
            iLoadKbps = (frmSize * 8.0 * frmRate) / 1000.0
            #iLoadKbps = 94.4
            
            self.arpFlowList.append(FlowName) 
            
            #flowDiagInfo = (clIp,srvIp,clMac,srvMac,clPort,srvPort,ssid,bssid)
            ipFlow = flowDiagInfo[1] + " to " + flowDiagInfo[0]
            macFlow = flowDiagInfo[3] + " to " + flowDiagInfo[2]
            portFlow = flowDiagInfo[5] + " to " + flowDiagInfo[4]
            network = flowDiagInfo[6] + ", " + flowDiagInfo[7]
            flowDiag = (FlowName,ipFlow,macFlow,portFlow,network,"Downlink")
            
            self.arpFlowList.append(FlowName)
            flwList.append(FlowName)
            self.flowTypeDict[FlowName] = (trafficType, self.clientPortDict[eClName][0], \
                    self.clientPortDict[wClName][0], eClName, wClName, iLoadKbps, slaReq, qosDict, options, 'flow',flowDiag,delayVal,endTime) 
        
        if direction == "uplink" or  direction == "bidirectional":
            FlowName = "F_%s_%s-->%s_%d" % (trafficType, wClName, eClName, flwNum)
            self.flowNameTrafficProfileNameDict[FlowName] = tType
            WaveEngine.VCLtest("flow.create('%s')"        % (FlowName))
            WaveEngine.VCLtest("flow.setSrcClient('%s')"  % (wClName))
            WaveEngine.VCLtest("flow.setDestClient('%s')" % (eClName))
            WaveEngine.VCLtest("flow.setType('%s')" % (codecType))
            WaveEngine.VCLtest("flow.setNumFrames(%d)" % (numFrames))
            WaveEngine.VCLtest("flow.setPhyRate(%f)" % phyRate) 
            WaveEngine.VCLtest("flow.setInsertSignature('on')") 
            
            WaveEngine.VCLtest("flow.setPayloadMode('%s')" % payPatten)            
            if payData != "None" and len(payData) > 0:
                WaveEngine.VCLtest("flow.setPayload('%s')" % payData)
            
            #if wClName in self.clientsBehindNatList:
            #    WaveEngine.VCLtest("flow.setNatEnable('on')")   
            #else:
            #    WaveEngine.VCLtest("flow.setNatEnable('off')")  
            
            WaveEngine.VCLtest("ipv4.readFlow()")
            WaveEngine.VCLtest("ipv4.setTtl(%d)" % (ttlVal) )            
            WaveEngine.VCLtest("ipv4.modifyFlow()")
                                
            WaveEngine.VCLtest("udp.readFlow()")
            WaveEngine.VCLtest("udp.setSrcPort(%d)" % (srcPort) )
            WaveEngine.VCLtest("udp.setDestPort(%d)" % (dstPort) )
            WaveEngine.VCLtest("udp.modifyFlow()")  
                           
            WaveEngine.VCLtest("flow.write('%s')"        % (FlowName))
                 
            WaveEngine.VCLtest("flowGroup.read('mainFlowGroup')")
            WaveEngine.VCLtest("flowGroup.add('%s')" % (FlowName))
            WaveEngine.VCLtest("flowGroup.write('mainFlowGroup')") 
            
            WaveEngine.VCLtest("flow.read('%s')"        % (FlowName))
            frmSize = flow.getFrameSize()
            frmRate = flow.getIntendedRate()
            
            
            iLoadKbps = (frmSize * 8.0 * frmRate) / 1000.0
            #iLoadKbps = 94.4
            
            self.arpFlowList.append(FlowName)
            flwList.append(FlowName)
            
            ipFlow = flowDiagInfo[0] + " to " + flowDiagInfo[1]
            macFlow = flowDiagInfo[2] + " to " + flowDiagInfo[3]
            portFlow = flowDiagInfo[4] + " to " + flowDiagInfo[5] 
            network = flowDiagInfo[6] + ", " + flowDiagInfo[7]
            flowDiag = (FlowName,ipFlow,macFlow,portFlow,network,"Uplink")
             
            self.flowTypeDict[FlowName] = (trafficType, self.clientPortDict[wClName][0], self.clientPortDict[eClName][0], \
                              wClName, eClName, iLoadKbps, slaReq, qosDict, options,'flow',flowDiag,delayVal,endTime)
        
        return flwList
    	
    def setupRTPVideoAudioFlows(self, wClName, eClName, fSize, phyRate, iRate, iRateKbps, trafficType, direction, options, 
                  wimixProfile, trailNum, slaReq, qosDict, portsWithSsid, flwNum,flowDiagInfo,mcastIP,delayVal,endTime,clIntType,numFrames,ttlVal,appPayload,tType,burstDataDict):
    	
    	if 'SrcPort' in options.keys():
            srcPort = int(options['SrcPort'])
        else:
            srcPort = 5003  
        
        if 'DestPort' in options.keys():
            dstPort = int(options['DestPort'])
        else:
            dstPort = 5004  
        
        payPatten = self.appPayloadCodes[appPayload['payPattern']]
        payData = appPayload['payData']
        
        if trafficType == "RTPVideo":
            rtpPayloadType = int(self.rtpVideoPayloadCodes[int(options['rtpVideoCoding'])])
        elif trafficType == "RTPAudio":    
            rtpPayloadType = int(self.rtpAudioPayloadCodes[int(options['rtpAudioCoding'])])
        else:
            rtpPayloadType = 0
        
        if direction == "multicast(downlink)":
            if mcastIP in self.mcastDummyClientDict:
                wClName = self.mcastDummyClientDict[mcastIP][0]	
            else:       	
                wClName = "mcastDummyClient"	
            
            self.setupMulticastFlowFlag = False           
            for fmName in self.flowTypeDict:
    	        if self.flowTypeDict[fmName][4] == wClName:
    	            self.setupMulticastFlowFlag = True             
    	
    	flwList = []
        
        if direction == "multicast(downlink)"  and self.setupMulticastFlowFlag == True:
            FlowName = "F_%s_%s-->%s_%d" % (trafficType, eClName, wClName, flwNum)
            flwList.append(FlowName)
        
    	
    	if direction == "multicast(downlink)"  and self.setupMulticastFlowFlag == False:  
    	    #wClName = "mcastDummyClient"
    	    
    	    if direction == "multicast(downlink)": 		
                FlowName = "F_%s_%s-->%s_%d" % (trafficType, eClName, wClName, flwNum)
                self.flowNameTrafficProfileNameDict[FlowName] = tType
                WaveEngine.VCLtest("flow.create('%s')"        % (FlowName))
                WaveEngine.VCLtest("flow.setSrcClient('%s')"  % (eClName))
                WaveEngine.VCLtest("flow.setDestClient('%s')" % (wClName))
                
                if len(burstDataDict.keys()) > 0:
                    numFrames = int(burstDataDict['burstDur'])
                    iRate = int(burstDataDict['burstRate'])
                    tNumFrames = self.createFlowBurstSchedule(FlowName,burstDataDict)
                    iRateKbps = (tNumFrames * fSize * 8) / (self.trialDuration * 1000.0)                       
                                    
            WaveEngine.VCLtest("flow.setType('%s')" % ("IP UDP RTP"))
            WaveEngine.VCLtest("flow.setIntendedRate(%f)" % iRate)
            WaveEngine.VCLtest("flow.setPhyRate(%f)" % phyRate)
            WaveEngine.VCLtest("flow.setFrameSize(%d)" % fSize)
            WaveEngine.VCLtest("flow.setNumFrames(%d)" % (numFrames))             
            WaveEngine.VCLtest("flow.setInsertSignature('on')")
            
            WaveEngine.VCLtest("flow.setPayloadMode('%s')" % payPatten)            
            if payData != "None" and len(payData) > 0:
                WaveEngine.VCLtest("flow.setPayload('%s')" % payData)
            
            if wClName in self.clientsBehindNatList:
                WaveEngine.VCLtest("flow.setNatEnable('on')")   
            else:
                WaveEngine.VCLtest("flow.setNatEnable('off')")    
            
            #lengthMac = 18
            #WaveEngine.VCLtest("ec.read('%s')" % eClName)    
            #if ec.getVlanTag() != -1:  
            #    lengthMac = 22
            
            WaveEngine.VCLtest("ipv4.readFlow()")
            #WaveEngine.VCLtest("ipv4.setTotalLength(%d)" % (fSize-lengthMac) )  
            WaveEngine.VCLtest("ipv4.setTtl(%d)" % (ttlVal) )            
            WaveEngine.VCLtest("ipv4.modifyFlow()") 
                        
            WaveEngine.VCLtest("rtp.readFlow()")
            WaveEngine.VCLtest("rtp.setPayloadType(%d)" % rtpPayloadType)
            WaveEngine.VCLtest("rtp.setInitialTimestamp(0)")
            WaveEngine.VCLtest("rtp.setInitialSeqNum(0)")
            WaveEngine.VCLtest("rtp.modifyFlow()")
            
            WaveEngine.VCLtest("udp.readFlow()")
            WaveEngine.VCLtest("udp.setSrcPort(%d)" % (srcPort) )
            WaveEngine.VCLtest("udp.setDestPort(%d)" % (dstPort) )
            WaveEngine.VCLtest("udp.modifyFlow()")        
            
            WaveEngine.VCLtest("flow.write('%s')"        % (FlowName))
            
                   
            WaveEngine.VCLtest("flowGroup.read('mainFlowGroup')")
            WaveEngine.VCLtest("flowGroup.add('%s')" % (FlowName))
            WaveEngine.VCLtest("flowGroup.write('mainFlowGroup')")    
            
            self.setupMulticastFlowFlag = True      
            
            if clIntType == 1:
                WaveEngine.VCLtest("ec.read('%s')" % (wClName))
                mcastClIp = ec.getIpAddress()
                mcastClMac = ec.getMacAddress()
            else:
                WaveEngine.VCLtest("mc.read('%s')" % (wClName))
                mcastClIp = mc.getIpAddress()
                mcastClMac = mc.getMacAddress()
            
            ipFlow = flowDiagInfo[1] + " to " + mcastClIp
            macFlow = flowDiagInfo[3] + " to " + mcastClMac
            portFlow = flowDiagInfo[5] + " to " +  "All Wireless Ports" 
            network = flowDiagInfo[6] + ", " + flowDiagInfo[7]
            flowDiag = (FlowName,ipFlow,macFlow,portFlow,network,"Multicast")      
            
            self.flowTypeDict[FlowName] = (trafficType, self.clientPortDict[eClName][0], self.wifiCards, \
                        eClName, wClName, iRateKbps, slaReq, qosDict, options,'mcastflow',flowDiag,delayVal,endTime)
            flwList.append(FlowName)
            self.multicastFlowList.append((FlowName,eClName,self.clientPortDict[eClName][0],portsWithSsid,slaReq))
            
            
    	
    	if direction in ["downlink", "unicast(downlink)", "bidirectional"]:  	
            FlowName = "F_%s_%s-->%s_%d" % (trafficType, eClName, wClName, flwNum)
            self.flowNameTrafficProfileNameDict[FlowName] = tType
            WaveEngine.VCLtest("flow.create('%s')"        % (FlowName))
            WaveEngine.VCLtest("flow.setSrcClient('%s')"  % (eClName))
            WaveEngine.VCLtest("flow.setDestClient('%s')" % (wClName))
            
            if len(burstDataDict.keys()) > 0:
                numFrames = int(burstDataDict['burstDur'])
                iRate = int(burstDataDict['burstRate'])
                tNumFrames = self.createFlowBurstSchedule(FlowName,burstDataDict)
                iRateKbps = (tNumFrames * fSize * 8) / (self.trialDuration * 1000.0)   
            
            WaveEngine.VCLtest("flow.setType('%s')" % ("IP UDP RTP"))                 
            WaveEngine.VCLtest("flow.setIntendedRate(%f)" % iRate)
            WaveEngine.VCLtest("flow.setPhyRate(%f)" % phyRate)
            WaveEngine.VCLtest("flow.setFrameSize(%d)" % fSize)
            WaveEngine.VCLtest("flow.setNumFrames(%d)" % (numFrames))
            WaveEngine.VCLtest("flow.setInsertSignature('on')")
            
            WaveEngine.VCLtest("flow.setPayloadMode('%s')" % payPatten)            
            if payData != "None" and len(payData) > 0:
                WaveEngine.VCLtest("flow.setPayload('%s')" % payData)
            
            if wClName in self.clientsBehindNatList:
                WaveEngine.VCLtest("flow.setNatEnable('on')")   
            else:
                WaveEngine.VCLtest("flow.setNatEnable('off')")    
            
            #lengthMac = 18
            #WaveEngine.VCLtest("ec.read('%s')" % eClName)    
            #if ec.getVlanTag() != -1:  
            #    lengthMac = 22
            
            WaveEngine.VCLtest("ipv4.readFlow()")
            #WaveEngine.VCLtest("ipv4.setTotalLength(%d)" % (fSize-lengthMac) )   
            WaveEngine.VCLtest("ipv4.setTtl(%d)" % (ttlVal) )            
            WaveEngine.VCLtest("ipv4.modifyFlow()")
                        
            WaveEngine.VCLtest("rtp.readFlow()")
            WaveEngine.VCLtest("rtp.setPayloadType(%d)" % rtpPayloadType)      
            WaveEngine.VCLtest("rtp.setInitialTimestamp(0)")
            WaveEngine.VCLtest("rtp.setInitialSeqNum(0)")
            WaveEngine.VCLtest("rtp.modifyFlow()")
            
            WaveEngine.VCLtest("udp.readFlow()")
            WaveEngine.VCLtest("udp.setSrcPort(%d)" % (srcPort) )
            WaveEngine.VCLtest("udp.setDestPort(%d)" % (dstPort) )
            WaveEngine.VCLtest("udp.modifyFlow()")        
            
            WaveEngine.VCLtest("flow.write('%s')"        % (FlowName))
            
                   
            WaveEngine.VCLtest("flowGroup.read('mainFlowGroup')")
            WaveEngine.VCLtest("flowGroup.add('%s')" % (FlowName))
            WaveEngine.VCLtest("flowGroup.write('mainFlowGroup')")    
            
            self.arpFlowList.append(FlowName) 
            flwList.append(FlowName) 
            
            ipFlow = flowDiagInfo[1] + " to " + flowDiagInfo[0]
            macFlow = flowDiagInfo[3] + " to " + flowDiagInfo[2]
            portFlow = flowDiagInfo[5] + " to " + flowDiagInfo[4]
            network = flowDiagInfo[6] + ", " + flowDiagInfo[7]
            flowDiag = (FlowName,ipFlow,macFlow,portFlow,network,"Downlink")
                 
            self.flowTypeDict[FlowName] = (trafficType, self.clientPortDict[eClName][0], self.clientPortDict[wClName][0], \
                        eClName, wClName, iRateKbps, slaReq, qosDict, options,'flow',flowDiag,delayVal,endTime)
                    
        if direction == "uplink" or  direction == "bidirectional":
            FlowName = "F_%s_%s-->%s_%d" % (trafficType, wClName, eClName, flwNum)
            self.flowNameTrafficProfileNameDict[FlowName] = tType
            WaveEngine.VCLtest("flow.create('%s')"        % (FlowName))
            WaveEngine.VCLtest("flow.setSrcClient('%s')"  % (wClName))
            WaveEngine.VCLtest("flow.setDestClient('%s')" % (eClName))
            
            if len(burstDataDict.keys()) > 0:
                numFrames = int(burstDataDict['burstDur'])
                iRate = int(burstDataDict['burstRate'])
                tNumFrames = self.createFlowBurstSchedule(FlowName,burstDataDict)
                iRateKbps = (tNumFrames * fSize * 8) / (self.trialDuration * 1000.0)   
            
            WaveEngine.VCLtest("flow.setType('%s')" % ("IP UDP RTP"))            
            WaveEngine.VCLtest("flow.setIntendedRate(%f)" % iRate)
            WaveEngine.VCLtest("flow.setPhyRate(%f)" % phyRate)
            WaveEngine.VCLtest("flow.setFrameSize(%d)" % fSize)
            WaveEngine.VCLtest("flow.setNumFrames(%d)" % (numFrames))
            WaveEngine.VCLtest("flow.setInsertSignature('on')")
            
            WaveEngine.VCLtest("flow.setPayloadMode('%s')" % payPatten)            
            if payData != "None" and len(payData) > 0:
                WaveEngine.VCLtest("flow.setPayload('%s')" % payData)
            
            
            #if eClName in self.clientsBehindNatList:
            #    WaveEngine.VCLtest("flow.setNatEnable('on')")   
            #else:
            #    WaveEngine.VCLtest("flow.setNatEnable('off')") 
            
            
            WaveEngine.VCLtest("ipv4.readFlow()")
            #WaveEngine.VCLtest("ipv4.setTotalLength(%d)" % (fSize-18) )  
            WaveEngine.VCLtest("ipv4.setTtl(%d)" % (ttlVal) )            
            WaveEngine.VCLtest("ipv4.modifyFlow()") 
            
            WaveEngine.VCLtest("rtp.readFlow()")
            WaveEngine.VCLtest("rtp.setPayloadType(%d)" % rtpPayloadType)       
            WaveEngine.VCLtest("rtp.setInitialTimestamp(0)")
            WaveEngine.VCLtest("rtp.setInitialSeqNum(0)")
            WaveEngine.VCLtest("rtp.modifyFlow()")
                    
            WaveEngine.VCLtest("udp.readFlow()")
            WaveEngine.VCLtest("udp.setSrcPort(%d)" % (dstPort) )
            WaveEngine.VCLtest("udp.setDestPort(%d)" % (srcPort) )
            WaveEngine.VCLtest("udp.modifyFlow()")  
                           
            WaveEngine.VCLtest("flow.write('%s')"        % (FlowName))
                    
            WaveEngine.VCLtest("flowGroup.read('mainFlowGroup')")
            WaveEngine.VCLtest("flowGroup.add('%s')" % (FlowName))
            WaveEngine.VCLtest("flowGroup.write('mainFlowGroup')") 
            
            self.arpFlowList.append(FlowName) 
            flwList.append(FlowName)
            
            ipFlow = flowDiagInfo[0] + " to " + flowDiagInfo[1]
            macFlow = flowDiagInfo[2] + " to " + flowDiagInfo[3]
            portFlow = flowDiagInfo[4] + " to " + flowDiagInfo[5]
            network = flowDiagInfo[6] + ", " + flowDiagInfo[7]
            flowDiag = (FlowName,ipFlow,macFlow,portFlow,network,"Uplink")
            
            self.flowTypeDict[FlowName] = (trafficType, self.clientPortDict[wClName][0], self.clientPortDict[eClName][0], wClName, \
            eClName, iRateKbps, slaReq, qosDict, options,'flow', flowDiag,delayVal,endTime)
        
        return flwList
    
    def setupUdpRtpFlows(self, wClName, eClName, fSize, phyRate, iRate, iRateKbps, trafficType, direction, options, 
                     wimixProfile, trailNum, slaReq, qosDict, flwNum,flowDiagInfo,delayVal,endTime,numFrames,ttlVal,appPayload,tType,burstDataDict):
    	
    	if 'SrcPort' in options.keys():
            srcPort = int(options['SrcPort'])
        else:
            srcPort = int(random.random()*10000)  
        
        if 'DestPort' in options.keys():
            dstPort = int(options['DestPort'])
        else:
            dstPort = int(random.random()*10000)    
        
        if self.clientPortDict[wClName][1] == "wa"  or self.serverList[eClName]['serverType'] == 1:    
            fSize = (fSize / 4) * 4 + 2
            WaveEngine.OutputstreamHDL("\n Setting the payload size to %d inorder to ensure a compatible frame size for WaveAgent Flows.\n" % (fSize), WaveEngine.MSG_OK)
                    
           	
    	payPatten = self.appPayloadCodes[appPayload['payPattern']]
        payData = appPayload['payData']       
    	
    	flwList = []
    	
    	if direction in ["downlink", "unicast(downlink)", "bidirectional"]:  	
            FlowName = "F_%s_%s-->%s_%d" % (trafficType, eClName, wClName, flwNum)
            self.flowNameTrafficProfileNameDict[FlowName] = tType
            
            WaveEngine.VCLtest("flow.create('%s')"        % (FlowName))
            WaveEngine.VCLtest("flow.setSrcClient('%s')"  % (eClName))
            WaveEngine.VCLtest("flow.setDestClient('%s')" % (wClName))
            if len(burstDataDict.keys()) > 0:
                numFrames = int(burstDataDict['burstDur'])
                iRate = int(burstDataDict['burstRate'])
                tNumFrames = self.createFlowBurstSchedule(FlowName,burstDataDict)
                iRateKbps = (tNumFrames * fSize * 8) / (self.trialDuration * 1000.0)    
                                        
            if trafficType == "UDP":
                WaveEngine.VCLtest("flow.setType('%s')" % ("UDP"))
                flType = "udp"
            elif trafficType == "RTP":
            	WaveEngine.VCLtest("flow.setType('%s')" % ("RTP"))    
            	flType = "rtp"
            WaveEngine.VCLtest("flow.setIntendedRate(%f)" % iRate)
            WaveEngine.VCLtest("flow.setPhyRate(%f)" % phyRate)
            WaveEngine.VCLtest("flow.setFrameSize(%d)" % fSize)
            WaveEngine.VCLtest("flow.setInsertSignature('on')")
            WaveEngine.VCLtest("flow.setNumFrames(%d)" % (numFrames))  
            
            #WaveEngine.VCLtest("flow.setUpdateData1('00000001')")  
            #WaveEngine.VCLtest("flow.setUpdateOffset1(%d)" % (2))  
            #WaveEngine.VCLtest("flow.setUpdateTarget1('mac')")  
            #WaveEngine.VCLtest("flow.setUpdateType1('increment')")  
            
            #WaveEngine.VCLtest("flow.setUpdateData2('00000001')")  
            #WaveEngine.VCLtest("flow.setUpdateOffset2(%d)" % (30))  
            #WaveEngine.VCLtest("flow.setUpdateTarget2('mac')")  
            #WaveEngine.VCLtest("flow.setUpdateType2('increment')") 
                    
            
            	            
                        	
            WaveEngine.VCLtest("flow.setPayloadMode('%s')" % payPatten)            
            if payData != "None" and len(payData) > 0:
                WaveEngine.VCLtest("flow.setPayload('%s')" % payData)
            
            
            if wClName in self.clientsBehindNatList:
                WaveEngine.VCLtest("flow.setNatEnable('on')")   
            else:
                WaveEngine.VCLtest("flow.setNatEnable('off')")                    
            
            #lengthMac = 18
            #WaveEngine.VCLtest("ec.read('%s')" % eClName)    
            #if ec.getVlanTag() != -1:  
            #    lengthMac = 22
            
            WaveEngine.VCLtest("ipv4.readFlow()")
            #WaveEngine.VCLtest("ipv4.setTotalLength(%d)" % (fSize-lengthMac) )    
            WaveEngine.VCLtest("ipv4.setTtl(%d)" % (ttlVal) )            
            WaveEngine.VCLtest("ipv4.modifyFlow()") 
            
            WaveEngine.VCLtest("udp.readFlow()")
            WaveEngine.VCLtest("udp.setSrcPort(%d)" % (srcPort) )
            WaveEngine.VCLtest("udp.setDestPort(%d)" % (dstPort) )
            WaveEngine.VCLtest("udp.modifyFlow()")        
            
            WaveEngine.VCLtest("flow.write('%s')"        % (FlowName))
             
            ipFlow = flowDiagInfo[1] + " to " + flowDiagInfo[0]
            macFlow = flowDiagInfo[3] + " to " + flowDiagInfo[2]
            portFlow = flowDiagInfo[5] + " to " + flowDiagInfo[4]
            network = flowDiagInfo[6] + ", " + flowDiagInfo[7]
            flowDiag = (FlowName,ipFlow,macFlow,portFlow,network,"Downlink")
            
            flwType = "flow"
            
            
            if self.serverList[eClName]['serverType'] == 1:
                self.waveAgentFlowsExist = True
                
                if direction == "downlink":
                    FlowName = self.createWaveAgentCommandFlow(FlowName, wClName, eClName, iRate, fSize, numFrames, "UDP", "source", srcPort, dstPort, flwNum)
                    self.flowNameTrafficProfileNameDict[FlowName] = tType
                    self.arpFlowList.append(FlowName)                 
                    flwList.append(FlowName)        
            
                    self.flowTypeDict[FlowName] = (flType, self.clientPortDict[wClName][0], self.clientPortDict[wClName][0], \
                         eClName, eClName, iRateKbps, slaReq, qosDict, options,"waSrcFlow",flowDiag,delayVal,endTime)
            else:    
                if self.clientPortDict[wClName][1] == "wa":    
                    self.waveAgentFlowsExist = True 	 
                    
                    if direction == "downlink":
                    	payStr = self.createWaveAgentCommandFlow(FlowName, eClName, wClName, iRate, fSize, numFrames, "UDP", "sink")       
                    	flwType = "waSinkFlow"                 
                    elif direction == "bidirectional":
                    	payStr = self.createWaveAgentCommandFlow(FlowName, eClName, wClName, iRate, fSize, numFrames, "UDP", "loopback")  
                    	flwType = "waLoopFlow"
                    	                  	                  
                    
                    WaveEngine.VCLtest("flow.read('%s')" % FlowName)
                    WaveEngine.VCLtest("flow.setPayload('%s')" % payStr)
                    WaveEngine.VCLtest("flow.write('%s')" % FlowName)
                
                WaveEngine.VCLtest("flowGroup.read('mainFlowGroup')")
                WaveEngine.VCLtest("flowGroup.add('%s')" % (FlowName))
                WaveEngine.VCLtest("flowGroup.write('mainFlowGroup')")  
                         
                self.arpFlowList.append(FlowName)  
                
                flwList.append(FlowName)
           
                self.flowTypeDict[FlowName] = (flType, self.clientPortDict[eClName][0], self.clientPortDict[wClName][0], \
                         eClName, wClName, iRateKbps, slaReq, qosDict, options,flwType,flowDiag,delayVal,endTime)
            
        
        if direction == "uplink" or  direction == "bidirectional":
            FlowName = "F_%s_%s-->%s_%d" % (trafficType, wClName, eClName, flwNum)
            self.flowNameTrafficProfileNameDict[FlowName] = tType
            WaveEngine.VCLtest("flow.create('%s')"        % (FlowName))
            WaveEngine.VCLtest("flow.setSrcClient('%s')"  % (wClName))
            WaveEngine.VCLtest("flow.setDestClient('%s')" % (eClName))
            if len(burstDataDict.keys()) > 0:
                numFrames = int(burstDataDict['burstDur'])
                iRate = int(burstDataDict['burstRate'])
                tNumFrames = self.createFlowBurstSchedule(FlowName,burstDataDict)
                iRateKbps = (tNumFrames * fSize * 8) / (self.trialDuration * 1000.0)
                
            if trafficType == "UDP":
                WaveEngine.VCLtest("flow.setType('%s')" % ("UDP"))
                flType = "udp"
            elif trafficType == "RTP":
            	WaveEngine.VCLtest("flow.setType('%s')" % ("RTP"))    
            	flType = "rtp"
            WaveEngine.VCLtest("flow.setNumFrames(%d)" % (numFrames))
            WaveEngine.VCLtest("flow.setIntendedRate(%f)" % iRate)
            WaveEngine.VCLtest("flow.setPhyRate(%f)" % phyRate)
            
            WaveEngine.VCLtest("flow.setFrameSize(%d)" % fSize)            
            WaveEngine.VCLtest("flow.setInsertSignature('on')")   
            
            WaveEngine.VCLtest("flow.setPayloadMode('%s')" % payPatten)            
            if payData != "None" and len(payData) > 0:
                WaveEngine.VCLtest("flow.setPayload('%s')" % payData)
             
            #if wClName in self.clientsBehindNatList:
            #    WaveEngine.VCLtest("flow.setNatEnable('on')")   
            #else:
            #    WaveEngine.VCLtest("flow.setNatEnable('off')")         
            
            WaveEngine.VCLtest("flow.write('%s')"        % (FlowName))
            WaveEngine.VCLtest("flow.read('%s')"        % (FlowName))
            
            #lengthMac = 18            
            
            
            WaveEngine.VCLtest("ipv4.readFlow()")
            #WaveEngine.VCLtest("ipv4.setTotalLength(%d)" % (fSize-lengthMac))    
            WaveEngine.VCLtest("ipv4.setTtl(%d)" % (ttlVal) )            
            WaveEngine.VCLtest("ipv4.modifyFlow()") 
                    
            WaveEngine.VCLtest("udp.readFlow()")
            WaveEngine.VCLtest("udp.setSrcPort(%d)" % (srcPort) )
            WaveEngine.VCLtest("udp.setDestPort(%d)" % (dstPort) )
            WaveEngine.VCLtest("udp.modifyFlow()")  
                           
            WaveEngine.VCLtest("flow.write('%s')"        % (FlowName))
            
            
            ipFlow = flowDiagInfo[0] + " to " + flowDiagInfo[1]
            macFlow = flowDiagInfo[2] + " to " + flowDiagInfo[3]
            portFlow = flowDiagInfo[4] + " to " + flowDiagInfo[5]
            network = flowDiagInfo[6] + ", " + flowDiagInfo[7]
            flowDiag = (FlowName,ipFlow,macFlow,portFlow,network,"Uplink")
            
            flwType = "flow"
            
            if self.clientPortDict[wClName][1] == "wa":
            	self.waveAgentFlowsExist = True 
            	
                if direction == "uplink":
                    FlowName = self.createWaveAgentCommandFlow(FlowName, eClName, wClName, iRate, fSize, numFrames, "UDP", "source", srcPort, dstPort, flwNum) 
                    self.flowNameTrafficProfileNameDict[FlowName] = tType
                    self.arpFlowList.append(FlowName)                 
                    flwList.append(FlowName)        
            
                    self.flowTypeDict[FlowName] = (flType, self.clientPortDict[eClName][0], self.clientPortDict[eClName][0], \
                         eClName, eClName, iRateKbps, slaReq, qosDict, options,"waSrcFlow",flowDiag,delayVal,endTime)
                                  
            elif self.serverList[eClName]['serverType'] == 1:   
                    self.waveAgentFlowsExist = True 
                    
                    if direction == "uplink":
                        payStr = self.createWaveAgentCommandFlow(FlowName, wClName, eClName, iRate, fSize, numFrames, "UDP", "sink")  
                        flwType = "waSinkFlow"
                    elif direction == "bidirectional":
                    	payStr = self.createWaveAgentCommandFlow(FlowName, wClName, eClName, iRate, fSize, numFrames, "UDP", "loopback")   
                    	flwType = "waLoopFlow"              
                
                    WaveEngine.VCLtest("flow.read('%s')" % FlowName)
                    WaveEngine.VCLtest("flow.setPayload('%s')" % payStr)
                    WaveEngine.VCLtest("flow.write('%s')" % FlowName)
                    
                
                    WaveEngine.VCLtest("flowGroup.read('mainFlowGroup')")
                    WaveEngine.VCLtest("flowGroup.add('%s')" % (FlowName))
                    WaveEngine.VCLtest("flowGroup.write('mainFlowGroup')")  
                        
                    self.arpFlowList.append(FlowName)                 
                    flwList.append(FlowName)        
            
                    self.flowTypeDict[FlowName] = (flType, self.clientPortDict[wClName][0], self.clientPortDict[wClName][0], \
                         wClName, eClName, iRateKbps, slaReq, qosDict, options,flwType,flowDiag,delayVal,endTime)
                
            else:
                    
                WaveEngine.VCLtest("flowGroup.read('mainFlowGroup')")
                WaveEngine.VCLtest("flowGroup.add('%s')" % (FlowName))
                WaveEngine.VCLtest("flowGroup.write('mainFlowGroup')")  
                      
                self.arpFlowList.append(FlowName)                 
                flwList.append(FlowName)        
            
                self.flowTypeDict[FlowName] = (flType, self.clientPortDict[wClName][0], self.clientPortDict[eClName][0], \
                       wClName, eClName, iRateKbps, slaReq, qosDict, options,flwType,flowDiag,delayVal,endTime)            
    
        return flwList
    
    
    
    def generateWaveAgentStats(self, FlowName, Portname, ii):
    	
    	if self.SavePCAPfile == False:    	    
    	    WaveEngine.VCLtest("capture.disable('%s')" % (Portname))
            WaveEngine.VCLtest("capture.clear('%s')"   % (Portname))
            WaveEngine.VCLtest("capture.enable('%s')"  % (Portname))
    	
    	self.getWaveAgentStatsFlow(FlowName)
    	WaveEngine.VCLtest("action.startFlowGroup('%s')" % ("waGetStatsFlowGroup"))
        time.sleep(0.2)
        WaveEngine.VCLtest("action.stopFlowGroup('%s')" % ("waGetStatsFlowGroup"))
                           
    	
    	Filename = "stripFlow_in_" + str(ii)
        txtFileName = "stripFlow_out_" + str(ii) + ".txt"
        WaveEngine.VCLtest("capture.setFileName(r'%s')" % (Filename))
        WaveEngine.VCLtest("capture.write('%s')"       % (Portname))
        WaveEngine.VCLtest("capture.save('%s')"       % (Portname))
        #WaveEngine.VCLtest("capture.grabLog('%s', 'pcap')" % (Portname))
        
        textFileName = "stripFlowErr.txt"
        fn = open(textFileName, 'w')    
    
        strFlow = r".\stripFlow.exe"
        execStr = " -w " + Filename + ".vwr " + txtFileName
        retVal = subprocess.Popen(execStr, executable=strFlow, stdout=fn, stderr = fn, stdin = subprocess.PIPE, creationflags = win32con.CREATE_NO_WINDOW)
        retVal.wait()
        fn.close()
        
        waTxFrames = 0
        waTxOctets = 0
        waRxFrames = 0
        waRxOctets = 0
        waMaxIpg = -1
        
        fn = open(txtFileName, 'r') 
        
        for line in fn:            
            word = line.split(':')
            if len(word) > 1:
               if word[0].lstrip().rstrip() in ["TX data packets", "Total packets transferred"]:
                   waTxFrames = int( word[1].lstrip().rstrip().split(" ")[0] )  	
	       if word[0].lstrip().rstrip() in ["TX data bytes", "Total data transferred"]:
                   waTxOctets = int( word[1].lstrip().rstrip().split(" ")[0] )   
	       if word[0].lstrip().rstrip() == "RX data packets":
                   waRxFrames = int( word[1].lstrip().rstrip().split(" ")[0] )
               if word[0].lstrip().rstrip() == "RX data bytes":
                   waRxOctets = int( word[1].lstrip().rstrip().split(" ")[0] )
               if word[0].lstrip().rstrip() == "Max VW_TS-based IPG":
                   waMaxIpg =  int( word[1].lstrip().rstrip().split(" ")[0] )
	    
        fn.close()
                
        return (waTxFrames, waTxOctets, waRxFrames, waRxOctets, waMaxIpg)
    
    
    def getWaveAgentStatsFlow(self, FlowName):
        # leave room for the signature, and add the fixed WaveAgent pattern
	payStr = "000000000000000000000000000000000F87C3A500000000"
	# transaction number is 3
	payStr = payStr + "00000003"	
	# control word is always 0x0021
	payStr = payStr + "00000021"
	
        WaveEngine.VCLtest("flow.read('%s')"        % (FlowName))
        WaveEngine.VCLtest("flow.setNumFrames(%d)" % (5))
        WaveEngine.VCLtest("flow.setIntendedRate(%f)" % 100)
        #WaveEngine.VCLtest("flow.setFrameSize(%d)" % (56 + 8 + 20 + 18 + 12))           
        WaveEngine.VCLtest("flow.setPayload('%s')" % payStr)        
        WaveEngine.VCLtest("flow.write('%s')"        % (FlowName))
        
        WaveEngine.VCLtest("flowGroup.read('waGetStatsFlowGroup')")
        WaveEngine.VCLtest("flowGroup.add('%s')" % (FlowName))
        WaveEngine.VCLtest("flowGroup.write('waGetStatsFlowGroup')")  
        
    
        
    def resetWaveAgentStatsFlow(self, FlowName):
        # leave room for the signature, and add the fixed WaveAgent pattern
	payStr = "000000000000000000000000000000000F87C3A500000000"
	
	# transaction number is 1
	payStr = payStr + "00000001"	
	# control word is always 0x0020
	payStr = payStr + "00000020"
	
	#FlowName = "F_WaveAgent_Reset_Stats_%s_%s-->%s_%d" % (trafficType, dstClient, srcClient, flwNum)
        #WaveEngine.VCLtest("flow.create('%s')"        % (FlowName))
        WaveEngine.VCLtest("flow.read('%s')"        % (FlowName))
        WaveEngine.VCLtest("flow.setNumFrames(%d)" % (1))
        WaveEngine.VCLtest("flow.setIntendedRate(%f)" % 1)
        #WaveEngine.VCLtest("flow.setFrameSize(%d)" % (56 + 8 + 20 + 18 + 12)) 
        WaveEngine.VCLtest("flow.setPayload('%s')" % payStr)
        WaveEngine.VCLtest("flow.write('%s')"      % (FlowName))
        
        WaveEngine.VCLtest("flowGroup.read('waResetStatsFlowGroup')")
        WaveEngine.VCLtest("flowGroup.add('%s')" % (FlowName))
        WaveEngine.VCLtest("flowGroup.write('waResetStatsFlowGroup')")  
        
        WaveEngine.VCLtest("action.startFlowGroup('%s')" % ("waResetStatsFlowGroup"))
        time.sleep(0.2)
        WaveEngine.VCLtest("action.stopFlowGroup('%s')" % ("waResetStatsFlowGroup"))
        
	
    
    
    def createWaveAgentCommandFlow(self, FlowName, srcClient, dstClient, iRate, fSize, numFrames, trafficType, trafficMode, srcPort = 0, dstPort = 0, flwNum = 0):    	
    	        
        # leave room for the signature and add fixed WaveAgent pattern
        payStr = "000000000000000000000000000000000F87C3A5"
        
        ### append WaveAgent Payload Length
        if trafficMode == "source":
            waveAgentPayLen = 16
        else:
            waveAgentPayLen = fSize - 16 - 16 - 12    	
            
        payStr = payStr + "%08x" % waveAgentPayLen
        
        ## Transaction Number force to 2
        payStr = payStr + "00000002"
        
        if trafficMode == "source":
            # WaveAgent control word (set to 0x00000011 for data source command)
            payStr = payStr + "00000011"            
            #### Payload Fill 
            payStr = payStr + "00000000"
            payStr = payStr + "%08x" % (fSize - 14 - 4 - 20 - 8 - 16 - 16 - 12)
            payStr = payStr + "%08x" % (iRate * (fSize - 14 - 4 - 20 - 8))
            payStr = payStr + "%08x" % (self.trialDuration * iRate * (fSize - 14 - 4 - 20 - 8))  
            
            
            FlowName = "F_WaveAgent_%s_%s-->%s_%s_%d" % (trafficType, dstClient, srcClient, trafficMode, flwNum)
            WaveEngine.VCLtest("flow.create('%s')"        % (FlowName))
            WaveEngine.VCLtest("flow.setSrcClient('%s')"  % (srcClient))
            WaveEngine.VCLtest("flow.setDestClient('%s')" % (dstClient))
            WaveEngine.VCLtest("flow.setType('%s')" % (trafficType))        
            WaveEngine.VCLtest("flow.setNumFrames(%d)" % (5))
            WaveEngine.VCLtest("flow.setIntendedRate(%f)" % 1)
            WaveEngine.VCLtest("flow.setPhyRate(%f)" % 54.0)        
            WaveEngine.VCLtest("flow.setFrameSize(%d)" % (fSize))           
            WaveEngine.VCLtest("flow.setInsertSignature('on')")   
            WaveEngine.VCLtest("flow.setPayload('%s')" % payStr)
            
                    
            
            WaveEngine.VCLtest("udp.readFlow()")
            WaveEngine.VCLtest("udp.setSrcPort(%d)" % (srcPort) )
            WaveEngine.VCLtest("udp.setDestPort(%d)" % (dstPort) )
            WaveEngine.VCLtest("udp.modifyFlow()")
            
            WaveEngine.VCLtest("flow.write('%s')"        % (FlowName))
            
            WaveEngine.VCLtest("flowGroup.read('mainFlowGroup')")
            WaveEngine.VCLtest("flowGroup.add('%s')" % (FlowName))
            WaveEngine.VCLtest("flowGroup.write('mainFlowGroup')")  
            
            return FlowName
                
                     
        elif trafficMode == "loopback":
            # WaveAgent control word (set to 0x00000002 for data loopback)
            payStr = payStr + "00000002"
        elif trafficMode == "sink":
            # WaveAgent control word (set to 0x00000002 for data sink)
            payStr = payStr + "00000001"     
        
        return payStr 
    
    
    
    
        
    def setupBiFlow( self, wClName, eClName, fSize, phyRate, iRate, iRateKbps, trafficType, direction, options, 
                     wimixProfile, trailNum, slaReq, qosDict, flwNum,flowDiagInfo,delayVal,endTime,numFrames,ttlVal,appPayload,tType,burstDataDict,tcpWinSize):	
    	
    	if 'SrcPort' in options.keys():
            srcPort = int(options['SrcPort'])
        else:
            srcPort = int(random.random()*10000)  
        
        if 'DestPort' in options.keys():
            dstPort = int(options['DestPort'])
        else:
            dstPort = int(random.random()*10000)    
        
        payPatten = self.appPayloadCodes[appPayload['payPattern']]
        payData = appPayload['payData']
            
        #if trafficType == "FTP":
        #    if 'FileSize' in options.keys():
        #    	bytesToTransmit = int(options['FileSize']) * 1000000
        #    	ftpBytesPerFrame = fSize - 14 - 20 - 20
        #    	numFrames =  bytesToTransmit / ftpBytesPerFrame 
        #else:
              
        flwList = []     
        
    	if direction in ["downlink", "unicast(downlink)", "bidirectional"]:    		
            biFlowName = "F_%s_%s:%d-->%s:%d_%d" % (trafficType, eClName, dstPort, wClName, srcPort, flwNum)
            self.flowNameTrafficProfileNameDict[biFlowName] = tType
            WaveEngine.VCLtest("biflow.create('%s')"  % (biFlowName))
            WaveEngine.VCLtest("biflow.set( 'RX Window', str(65535))")
            WaveEngine.VCLtest("biflow.setSrcClient('%s')" % (eClName))
            WaveEngine.VCLtest("biflow.setDestClient('%s')" % (wClName))
            
            ipFlow = flowDiagInfo[1] + " to " + flowDiagInfo[0]
            macFlow = flowDiagInfo[3] + " to " + flowDiagInfo[2]
            portFlow = flowDiagInfo[5] + " to " + flowDiagInfo[4]
            network = flowDiagInfo[6] + ", " + flowDiagInfo[7]
            flowDiag = (biFlowName,ipFlow,macFlow,portFlow,network,"Downlink")
            
            
            if trafficType == "FTP":
                self.setupFtpApp(biFlowName, options, dstPort, srcPort, wimixProfile, trailNum, "download")
                self.flowTypeDict[biFlowName] = ("ftp", self.clientPortDict[eClName][0], self.clientPortDict[wClName][0], eClName, wClName, iRateKbps, slaReq, qosDict, options,'biFlow',flowDiag,delayVal,endTime)                
                WaveEngine.VCLtest("appSession.setClientNetIf('%s')" % (eClName))
                WaveEngine.VCLtest("appSession.setServerNetIf('%s')" % (wClName))
                WaveEngine.VCLtest("appSession.modifyBiflow()")
            elif trafficType == "HTTP":
                self.setupHttpApp(biFlowName, options, dstPort, srcPort, wimixProfile, trailNum, "download")
                self.flowTypeDict[biFlowName] = ("http", self.clientPortDict[eClName][0], self.clientPortDict[wClName][0], eClName, wClName, iRateKbps, slaReq, qosDict, options,'biFlow',flowDiag,delayVal,endTime)
                WaveEngine.VCLtest("appSession.setClientNetIf('%s')" % (eClName))
                WaveEngine.VCLtest("appSession.setServerNetIf('%s')" % (wClName))
                WaveEngine.VCLtest("appSession.modifyBiflow()")
            elif trafficType == "TCP":
                self.setupRawApp(biFlowName, options, dstPort, srcPort, wimixProfile, trailNum, "download")
                WaveEngine.VCLtest("appSession.setClientNetIf('%s')" % (eClName))
                WaveEngine.VCLtest("appSession.setServerNetIf('%s')" % (wClName))
                WaveEngine.VCLtest("appSession.modifyBiflow()")
                self.flowTypeDict[biFlowName] = ("tcp", self.clientPortDict[eClName][0], self.clientPortDict[wClName][0], eClName, wClName, iRateKbps, slaReq, qosDict, options,'biFlow',flowDiag,delayVal,endTime)
            elif trafficType in ["TCPVideo", "TCPAudio"]:            	
            	if int(options['mediaProtocol']) == 0:
            	    self.setupHttpApp(biFlowName, options, dstPort, srcPort, wimixProfile, trailNum, "download")
                    self.flowTypeDict[biFlowName] = (trafficType, self.clientPortDict[eClName][0], self.clientPortDict[wClName][0], eClName, wClName, iRateKbps, slaReq, qosDict, options,'biFlow',flowDiag,delayVal,endTime)
                    WaveEngine.VCLtest("appSession.setClientNetIf('%s')" % (eClName))
                    WaveEngine.VCLtest("appSession.setServerNetIf('%s')" % (wClName))
                    WaveEngine.VCLtest("appSession.modifyBiflow()")
                elif int(options['mediaProtocol']) == 1:
                    self.setupRawApp(biFlowName, options, dstPort, srcPort, wimixProfile, trailNum, "download")
                    WaveEngine.VCLtest("appSession.setClientNetIf('%s')" % (eClName))
                    WaveEngine.VCLtest("appSession.setServerNetIf('%s')" % (wClName))
                    WaveEngine.VCLtest("appSession.modifyBiflow()")
                    self.flowTypeDict[biFlowName] = (trafficType, self.clientPortDict[eClName][0], self.clientPortDict[wClName][0], eClName, wClName, iRateKbps, slaReq, qosDict, options,'biFlow',flowDiag,delayVal,endTime)
                
                        
            WaveEngine.VCLtest("biflow.setIntendedRate(%f)" % iRate)
            WaveEngine.VCLtest("biflow.setPhyRate(%f)" % phyRate)
            WaveEngine.VCLtest("biflow.setFrameSize(%d)" % fSize)
            WaveEngine.VCLtest("biflow.setInsertSignature('on')")   
            WaveEngine.VCLtest("biflow.setNumFrames(%d)" % numFrames)  
            
            WaveEngine.VCLtest("biflow.setPayloadMode('%s')" % payPatten)            
            if payData != "None" and len(payData) > 0:
                WaveEngine.VCLtest("biflow.setPayload('%s')" % payData) 
            
            #if wClName in self.clientsBehindNatList:
            #    WaveEngine.VCLtest("biflow.setNatEnable('on')")   
            #else:
            #    WaveEngine.VCLtest("biflow.setNatEnable('off')") 
            
                  
            WaveEngine.VCLtest("biflow.write('%s')" % (biFlowName)) 
            
            #WaveEngine.VCLtest("biflow.read('%s')" % (biFlowName))
            #WaveEngine.VCLtest("biflowIpv4.readBiflow('Forward')")             	        
            #WaveEngine.VCLtest("biflowIpv4.setTtl(%d)" % ttlVal) 
            #WaveEngine.VCLtest("biflowIpv4.setPrecedence(%d)" % (7) )
            #WaveEngine.VCLtest("biflowIpv4.setTos('throughput')")
            #WaveEngine.VCLtest("biflowIpv4.setTosField(56)")
            #WaveEngine.VCLtest("biflowIpv4.modifyBiflow('Forward')")  
            #WaveEngine.VCLtest("biflow.write('%s')" % (biFlowName))  
               
            
            WaveEngine.VCLtest("biflow.read('%s')" % (biFlowName))
            WaveEngine.VCLtest("biflowTcp.readBiflow()")             	        
            WaveEngine.VCLtest("biflowTcp.setMss(%d)" % (fSize - 58))
            WaveEngine.VCLtest("biflowTcp.setWindow(%d)" % (tcpWinSize))           
            WaveEngine.VCLtest("biflowTcp.modifyBiflow()")  
            WaveEngine.VCLtest("biflow.write('%s')" % (biFlowName))
                       
            
            WaveEngine.VCLtest("flowGroup.read('mainFlowGroup')")
            WaveEngine.VCLtest("flowGroup.add('%s')" % (biFlowName))
            WaveEngine.VCLtest("flowGroup.write('mainFlowGroup')")  
            
            flwList.append(biFlowName)
        
        if direction == "uplink" or  direction == "bidirectional":    	
            biFlowName = "F_%s_%s:%d-->%s:%d_%d" % (trafficType, wClName, srcPort, eClName, dstPort, flwNum) 
            self.flowNameTrafficProfileNameDict[biFlowName] = tType           	
            WaveEngine.VCLtest("biflow.create('%s')"  % (biFlowName))
            WaveEngine.VCLtest("biflow.set( 'RX Window', str(65535))")
            WaveEngine.VCLtest("biflow.setSrcClient('%s')" % (wClName))
            WaveEngine.VCLtest("biflow.setDestClient('%s')" % (eClName))
            WaveEngine.VCLtest("biflow.setInsertSignature('on')")
            
            ipFlow = flowDiagInfo[0] + " to " + flowDiagInfo[1]
            macFlow = flowDiagInfo[2] + " to " + flowDiagInfo[3]
            portFlow = flowDiagInfo[4] + " to " + flowDiagInfo[5]
            network = flowDiagInfo[6] + ", " + flowDiagInfo[7]
            flowDiag = (biFlowName,ipFlow,macFlow,portFlow,network,"Uplink")
            
            if trafficType == "FTP":
                self.setupFtpApp(biFlowName, options, srcPort, dstPort, wimixProfile, trailNum, "upload")
                self.flowTypeDict[biFlowName] = ("ftp", self.clientPortDict[wClName][0], self.clientPortDict[eClName][0], wClName, eClName, iRateKbps, slaReq, qosDict, options,'biFlow',flowDiag,delayVal,endTime)
                WaveEngine.VCLtest("appSession.setClientNetIf('%s')" % (wClName))
                WaveEngine.VCLtest("appSession.setServerNetIf('%s')" % (eClName))
                WaveEngine.VCLtest("appSession.modifyBiflow()")
            elif trafficType == "HTTP":
                self.setupHttpApp(biFlowName, options, srcPort, dstPort, wimixProfile, trailNum, "upload")
                self.flowTypeDict[biFlowName] = ("http", self.clientPortDict[wClName][0], self.clientPortDict[eClName][0], wClName, eClName, iRateKbps, slaReq, qosDict, options,'biFlow',flowDiag,delayVal,endTime)
                WaveEngine.VCLtest("appSession.setClientNetIf('%s')" % (wClName))
                WaveEngine.VCLtest("appSession.setServerNetIf('%s')" % (eClName))
                WaveEngine.VCLtest("appSession.modifyBiflow()")
            elif trafficType == "TCP":
                self.setupRawApp(biFlowName, options, srcPort, dstPort, wimixProfile, trailNum, "upload")
                WaveEngine.VCLtest("appSession.setClientNetIf('%s')" % (wClName))
                WaveEngine.VCLtest("appSession.setServerNetIf('%s')" % (eClName))
                WaveEngine.VCLtest("appSession.modifyBiflow()")
                self.flowTypeDict[biFlowName] = ("tcp", self.clientPortDict[wClName][0], self.clientPortDict[eClName][0], wClName, eClName, iRateKbps, slaReq, qosDict, options,'biFlow',flowDiag,delayVal,endTime)
            elif trafficType in ["TCPVideo", "TCPAudio"]:            	
            	if options['mediaProtocol'] == 0:
            	    self.setupHttpApp(biFlowName, options, srcPort, dstPort, wimixProfile, trailNum, "upload")
                    self.flowTypeDict[biFlowName] = (trafficType, self.clientPortDict[wClName][0], self.clientPortDict[eClName][0], wClName, eClName, iRateKbps, slaReq, qosDict, options,'biFlow',flowDiag,delayVal,endTime)
                    WaveEngine.VCLtest("appSession.setClientNetIf('%s')" % (wClName))
                    WaveEngine.VCLtest("appSession.setServerNetIf('%s')" % (eClName))
                    WaveEngine.VCLtest("appSession.modifyBiflow()")
                elif options['mediaProtocol'] == 1:
                    self.setupRawApp(biFlowName, options, srcPort, dstPort, wimixProfile, trailNum, "upload")
                    WaveEngine.VCLtest("appSession.setClientNetIf('%s')" % (wClName))
                    WaveEngine.VCLtest("appSession.setServerNetIf('%s')" % (eClName))
                    WaveEngine.VCLtest("appSession.modifyBiflow()")
                    self.flowTypeDict[biFlowName] = (trafficType, self.clientPortDict[wClName][0], self.clientPortDict[eClName][0], wClName, eClName, iRateKbps, slaReq, qosDict, options,'biFlow',flowDiag,delayVal,endTime)
            
                         
            WaveEngine.VCLtest("biflow.setIntendedRate(%f)" % iRate)
            WaveEngine.VCLtest("biflow.setPhyRate(%f)" % phyRate)
            WaveEngine.VCLtest("biflow.setFrameSize(%d)" % fSize)
            WaveEngine.VCLtest("biflow.setNumFrames(%d)" % numFrames)
            
            WaveEngine.VCLtest("biflow.setPayloadMode('%s')" % payPatten)            
            if payData != "None" and len(payData) > 0:
                WaveEngine.VCLtest("biflow.setPayload('%s')" % payData) 
            
            #if wClName in self.clientsBehindNatList:
            #    WaveEngine.VCLtest("biflow.setNatEnable('on')")   
            #else:
            #    WaveEngine.VCLtest("biflow.setNatEnable('off')") 
            
            
            WaveEngine.VCLtest("biflow.write('%s')" % (biFlowName)) 
            
            #WaveEngine.VCLtest("biflow.read('%s')" % (biFlowName))
            #WaveEngine.VCLtest("biflowIpv4.readBiflow('Forward')")             	        
            #WaveEngine.VCLtest("biflowIpv4.setTtl(%d)" % ttlVal) 
            #WaveEngine.VCLtest("biflowIpv4.modifyBiflow('Forward')")  
            #WaveEngine.VCLtest("biflow.write('%s')" % (biFlowName)) 
             
            
            WaveEngine.VCLtest("biflow.read('%s')" % (biFlowName))
            WaveEngine.VCLtest("biflowTcp.readBiflow()")             	        
            WaveEngine.VCLtest("biflowTcp.setMss(%d)" % (fSize - 58))
            WaveEngine.VCLtest("biflowTcp.setWindow(%d)" % (tcpWinSize)) 
            WaveEngine.VCLtest("biflowTcp.modifyBiflow()")  
            WaveEngine.VCLtest("biflow.write('%s')" % (biFlowName))
            
            WaveEngine.VCLtest("flowGroup.read('mainFlowGroup')")
            WaveEngine.VCLtest("flowGroup.add('%s')" % (biFlowName))
            WaveEngine.VCLtest("flowGroup.write('mainFlowGroup')")  
            
            flwList.append(biFlowName)
        
        return flwList

    def setupRawApp(self, biflowName, options, srcPort, dstPort, wimixProfile, trailNum, loadType):
        sname = "rawserver::%s::%s::%d" % (biflowName, wimixProfile, trailNum)
        WaveEngine.VCLtest("rawServer.create('%s')" % (sname))
        WaveEngine.VCLtest("rawServer.setPort(%d)" % (dstPort))
        WaveEngine.VCLtest("rawServer.write('%s')" % (sname))
        
        self.rawServerNames.append(sname)
        
        cname = "rawclient::%s::%s::%d" % (biflowName, wimixProfile, trailNum)
        WaveEngine.VCLtest("rawClient.create('%s')" % (cname))
        WaveEngine.VCLtest("rawClient.setPort(%d)" % (srcPort))
        WaveEngine.VCLtest("rawClient.setDataFlow('%s')" % (loadType))
        WaveEngine.VCLtest("rawClient.write('%s')" % (cname))
        
        self.rawClientNames.append(cname)
        
        WaveEngine.VCLtest("appSession.readBiflow()")
        WaveEngine.VCLtest("appSession.setClientApp('%s')" % cname)
        WaveEngine.VCLtest("appSession.setServerApp('%s')" % sname)
        
    
    def setupHttpApp(self, biflowName, options, srcPort, dstPort, wimixProfile, trailNum, loadType):
        sname = "httpserver::%s::%s::%d" % (biflowName, wimixProfile, trailNum)
        WaveEngine.VCLtest("httpServer.create('%s')" % sname)
        WaveEngine.VCLtest("httpServer.setPort(%d)" % dstPort)
        WaveEngine.VCLtest("httpServer.write('%s')" % sname)
        
        self.httpServerNames.append(sname)
        
        cname = "httpclient::%s::%s::%d" % (biflowName, wimixProfile, trailNum)
        WaveEngine.VCLtest("httpClient.create('%s')" % cname)
        WaveEngine.VCLtest("httpClient.setPort(%d)" % srcPort)
        
        if 'Operation' in options.keys():
            operation = options['Operation']
            if options['Operation'] == "http post":
            	operation = "http put"
        else:
            operation = "http get" 
        
        if 'TransSize' in options.keys():
            transSize = int(options['TransSize'])
        else:
            transSize = 1000    
        
        WaveEngine.VCLtest("httpClient.setOperation('%s')" % operation)     
        #WaveEngine.VCLtest("httpClient.setContentLength(%d)" % transSize) 
        WaveEngine.VCLtest("httpClient.setContentLength(%d)" % 100000000) 
        WaveEngine.VCLtest("httpClient.setDataFlow('%s')" % (loadType))        
        WaveEngine.VCLtest("httpClient.write('%s')" % cname)
        
        self.httpClientNames.append(cname)
        
        WaveEngine.VCLtest("appSession.readBiflow()")
        WaveEngine.VCLtest("appSession.setClientApp('%s')" % cname)
        WaveEngine.VCLtest("appSession.setServerApp('%s')" % sname)
        
    def setupFtpApp(self, biflowName, options, srcPort, dstPort, wimixProfile, trailNum, loadType):
        sname = "ftpserver::%s::%s::%d" % (biflowName, wimixProfile, trailNum)
        WaveEngine.VCLtest("ftpServer.create('%s')" % sname)
        WaveEngine.VCLtest("ftpServer.setControlPort(%d)" % (dstPort))
        WaveEngine.VCLtest("ftpServer.setDataPort(%d)" % (dstPort + 100))
    
        WaveEngine.VCLtest("ftpServer.write('%s')" % sname)
        
        self.ftpServerNames.append(sname)        
    
        cname = "ftpclient::%s::%s::%d" % (biflowName, wimixProfile, trailNum)        
        
        WaveEngine.VCLtest("ftpClient.create('%s')" % cname)
        WaveEngine.VCLtest("ftpClient.setControlPort(%d)" % (srcPort))
        WaveEngine.VCLtest("ftpClient.setDataPort(%d)" % (srcPort + 100))
        WaveEngine.VCLtest("ftpClient.setDataFlow('%s')" % (loadType))      
       
                
        if 'Operation' in options.keys():
            operation = options['Operation']
        else:
            operation = "ftp get"  
        
        if 'FileSize' in options.keys():
            filesize = int(options['FileSize'])
        else:
            filesize = 1501 
        
        if 'FileName' in options.keys():
            filename = options['FileName']
        else:
            filename = "anything.txt" 
        
        if 'Username' in options.keys():
            username = options['Username']
        else:
            username = "anonymous"
        
        if 'Password' in options.keys():
            password = options['Password']
        else:
            password = "anonymous"
        
        WaveEngine.VCLtest("ftpClient.setOperation('%s')" % operation)
        #WaveEngine.VCLtest("ftpClient.setFileSize(%d)" % filesize)
        WaveEngine.VCLtest("ftpClient.setFileSize(%d)" % 100000000)
        WaveEngine.VCLtest("ftpClient.setFileName('%s')" % filename)
        WaveEngine.VCLtest("ftpClient.setUserName('%s')" % username)
        WaveEngine.VCLtest("ftpClient.setPassword('%s')" % password)
        
        WaveEngine.VCLtest("ftpClient.write('%s')" % cname)
        
        self.ftpClientNames.append(cname)
        
        WaveEngine.VCLtest("appSession.readBiflow()")
        WaveEngine.VCLtest("appSession.setClientApp('%s')" % cname)
        WaveEngine.VCLtest("appSession.setServerApp('%s')" % sname)
        
    
    
    def destroyAppServers(self):
    	
    	for cname in self.ftpClientNames:
    	    WaveEngine.VCLtest("ftpClient.destroy('%s')" % cname)
    	
    	for cname in self.httpClientNames:
    	    WaveEngine.VCLtest("httpClient.destroy('%s')" % cname)
    	
    	for cname in self.rawClientNames:
    	    WaveEngine.VCLtest("rawClient.destroy('%s')" % cname)    
    	
    	for sname in self.rawServerNames:
    	    WaveEngine.VCLtest("rawServer.destroy('%s')" % sname)   
    	    
        for sname in self.httpServerNames:
    	    WaveEngine.VCLtest("httpServer.destroy('%s')" % sname) 
    	
    	for sname in self.ftpServerNames:
    	    WaveEngine.VCLtest("ftpServer.destroy('%s')" % sname)     	    
    
        
    def recreateAppServers(self, trailNum):    	
        for flw in self.flowTypeDict:
            trafficType = self.flowTypeDict[flw][0]
            options = self.flowTypeDict[flw][8]
            biFlowName = flw
            srcPort = int(options['SrcPort'])
            dstPort = int(options['DestPort'])
            wimixProfile = self.testProfileList[0]
            srcClient = self.flowTypeDict[flw][3]
            dstClient = self.flowTypeDict[flw][4]
            if trafficType == "ftp":
            	WaveEngine.VCLtest("biflow.read('%s')" % (flw)) 
                self.setupFtpApp(biFlowName, options, srcPort, dstPort, wimixProfile, trailNum)
                WaveEngine.VCLtest("appSession.setClientNetIf('%s')" % (srcClient))
                WaveEngine.VCLtest("appSession.setServerNetIf('%s')" % (dstClient))
                WaveEngine.VCLtest("appSession.modifyBiflow()")
                WaveEngine.VCLtest("biflow.write('%s')" % (flw)) 
            elif trafficType == "http":
            	WaveEngine.VCLtest("biflow.read('%s')" % (flw)) 
                self.setupHttpApp(biFlowName, options, srcPort, dstPort, wimixProfile, trailNum)
                WaveEngine.VCLtest("appSession.setClientNetIf('%s')" % (srcClient))
                WaveEngine.VCLtest("appSession.setServerNetIf('%s')" % (dstClient))
                WaveEngine.VCLtest("appSession.modifyBiflow()")
                WaveEngine.VCLtest("biflow.write('%s')" % (flw)) 
            elif trafficType == "tcp":
            	WaveEngine.VCLtest("biflow.read('%s')" % (flw)) 
                self.setupRawApp(biFlowName, options, srcPort, dstPort, wimixProfile, trailNum)
                WaveEngine.VCLtest("appSession.setClientNetIf('%s')" % (srcClient))
                WaveEngine.VCLtest("appSession.setServerNetIf('%s')" % (dstClient))
                WaveEngine.VCLtest("appSession.modifyBiflow()")
                WaveEngine.VCLtest("biflow.write('%s')" % (flw)) 
            #elif trafficType in ["TCPVideo", "TCPAudio"]:            	
            # 	if self.TrafficTypes[tType]['Layer4to7']['mediaProtocol'] == 0:
            #	    WaveEngine.VCLtest("biflow.read('%s')" % (flw)) 
            #        self.setupHttpApp(biFlowName, options, srcPort, dstPort, wimixProfile, trailNum)
            #        WaveEngine.VCLtest("appSession.setClientNetIf('%s')" % (srcClient))
            #        WaveEngine.VCLtest("appSession.setServerNetIf('%s')" % (dstClient))
            #        WaveEngine.VCLtest("appSession.modifyBiflow()")
            #        WaveEngine.VCLtest("biflow.write('%s')" % (flw)) 
            #    if self.TrafficTypes[tType]['Layer4to7']['mediaProtocol'] == 1:
            #        WaveEngine.VCLtest("biflow.read('%s')" % (flw)) 
            #        self.setupRawApp(biFlowName, options, srcPort, dstPort, wimixProfile, trailNum)
            #        WaveEngine.VCLtest("appSession.setClientNetIf('%s')" % (srcClient))
            #        WaveEngine.VCLtest("appSession.setServerNetIf('%s')" % (dstClient))
            #        WaveEngine.VCLtest("appSession.modifyBiflow()")
            #        WaveEngine.VCLtest("biflow.write('%s')" % (flw)) 
    
    def connectBiflows(self, timeout, rate):   
        biflowTuple = biflow.getNames()        
        myList = list( biflowTuple )
        
        if len(myList) == 0:
            return 0
        tTimeout = len(myList)* timeout
                
        if self.biFlowConnectMode == 0:
            for mybiflow in myList:
                if self.numTrials != 1 and self.reconnectClientsForTrial != 1:
                    WaveEngine.VCLtest("biflow.read('%s')" % mybiflow)               
                    WaveEngine.VCLtest("biflowTcp.readBiflow()")
                    WaveEngine.VCLtest("biflowTcp.setWindow(65535)")
                    WaveEngine.VCLtest("biflowTcp.modifyBiflow()")   
                    WaveEngine.VCLtest("biflow.write('%s')" % mybiflow)  
                retval = WaveEngine.ConnectBiflow([mybiflow,], clientTimeOut=timeout, totalTimeOut=0, expectedState="READY", operation='connect', noSummary=False)
                if retval < 0:
                    WaveEngine.OutputstreamHDL("\nTCP/FTP/HTTP connect operation failed for Flow : %s\n" % (mybiflow), WaveEngine.MSG_ERROR)
                    return retval
        else:
            return WaveEngine.ConnectBiflow(myList, clientTimeOut=timeout, totalTimeOut=0, connectRate = rate, expectedState="READY", operation='connect', noSummary=False)
                   
        return 0           
          
        
    def disconnectBiflows(self, timeout, rate):
    	timeout = 10
        biflowTuple = biflow.getNames()
        myList = list( biflowTuple )
        tTimeout = len(myList)* timeout 
        
        if len(myList) == 0:
            return 0        
        
        if self.numTrials == 1 or self.reconnectClientsForTrial == 1:
            return WaveEngine.ConnectBiflow(myList, clientTimeOut=timeout, totalTimeOut=tTimeout, expectedState="IDLE", operation='resetConnection', noSummary=False)
        else:
            return WaveEngine.ConnectBiflow(myList, clientTimeOut=timeout, totalTimeOut=tTimeout, expectedState="IDLE", operation='disconnect', noSummary=False)    
        
        
       
    def destroyBiflows(self):
    	biflowTuple = biflow.getNames()
        myList = list( biflowTuple )
        for flowName in myList:
            WaveEngine.VCLtest("biflow.destroy('%s')" % flowName)
        
    
    def clientLearning(self):
    	cltDict = dict()
    	for clt in self.clientPortDict.keys():
    	    if 	self.clientPortDict[clt][1] != "wa":
    	        cltDict[clt] = (1, self.clientPortDict[clt][0], self.clientPortDict[clt][1])	
    	WaveEngine.ClientLearning(cltDict, self.ClientLearningTime, self.ClientLearningRate)
    
    def doARPExchange(self):  
    	arpFlowDict = dict()  	
    	for flw in self.arpFlowList:
    	    WaveEngine.VCLtest("flow.read('%s')"  % (flw))
    	    src_client = flow.getSrcClient()
    	    des_client = flow.getDestClient()    	    
    	    src_port = self.clientPortDict[src_client][0]
    	    des_port = self.clientPortDict[des_client][0]
    	    arpFlowDict[flw] = (src_port, src_client, des_port, des_client)
    	    
    	return WaveEngine.ExchangeARP(arpFlowDict, "arpFlows", self.ARPRate, self.ARPRetries, self.ARPTimeout)     	
    
    
    def voiceCallSetupTeardown(self, sipType):
    	if len(self.sipClientPairs) == 0:
    	    return
    	    
    	if sipType == 0:    
    	    self.Print("Setting up SIP Sessions.....Please Wait\n")     
    	elif sipType == 1: 
    	    self.Print("Tearing down SIP Sessions.....Please Wait\n")
    	   	
    	sipInvite = "INVITE sip:f:5060 SIP/2.0\r\nVia: SIP/2.0/UDP 200.57.7.195;branch=z\r\nFrom: <sip:200.57.7.195:5061;user=p>;tag=G\r\nTo: \"f\" <sip:f:5060>\r\nCall-ID:1@200.57.7.195\r\nCSeq:1 INVITE\r\nContent-Type: application/sdp\r\nContent-Length: 22\r\n\r\nm=audio 40376 RTP/AVP 8"
    	sipTrying = "SIP/2.0 100 Trying\r\nVia: SIP/2.0/UDP 200.57.7.195;branch=z\r\nFrom: <sip:200.57.7.195:5061;user=p>;tag=G\r\nTo: \"f@b\" <sip:f@b:5060>;tag=2\r\nCall-ID: 1@200.57.7.195\r\nCSeq: 1 INVITE\r\nServer: X\r\nContent-Length:0\r\n\r\n"
    	sipRinging = "SIP/2.0 180 Ringing\r\nVia: SIP/2.0/UDP200.57.7.195;branch=z\r\nFrom: <sip:200.57.7.195:5061;user=p>;tag=G\r\nTo: \"f@b\" <sip:f@b:5060>;tag=2\r\nCall-ID: 1@200.57.7.195\r\nCSeq: 1 INVITE\r\nServer:X\r\nContent-Length: 0\r\n\r\n"
        sipOk = "SIP/2.0 200 Ok\r\nVia: SIP/2.0/UDP 200.57.7.195;branch=z\r\nFrom: <sip:200.57.7.195:5061;user=p>;tag=G\r\nTo: \"f@b\" <sip:f@b:5060>;tag=2\r\nCall-ID: 1@200.57.7.195\r\nCSeq: 1 INVITE\r\nContent-Type: application/sdp\r\nServer:X\r\nContent-Length: 22\r\n\r\nm=audio 40376 RTP/AVP 8"
        sipAck = "ACK sip:f@200.57.7.204:5061 SIP/2.0\r\nVia: SIP/2.0/UDP 200.57.7.195;branch=z\r\nFrom: <sip:200.57.7.195:5061;user=p>;tag=G\r\nTo: \"f@b\" <sip:f@b:5060>;tag=2\r\nCall-ID: 1@200.57.7.195\r\nCSeq: 1 ACK\r\nContent-Length:0\r\n\r\n"
    	sipBye = "BYE sip:f@b:5060;transport=UDP SIP/2.0\r\nVia: SIP/2.0/UDP 200.57.7.195:5060;branch=z\r\nCSeq: 2 BYE\r\nTo: <sip:f@b:5060>;tag=82\r\nFrom: <tel:p>;tag=2\r\nCall-ID: 1@200.57.7.195\r\nRoute: <sip:f@b:5060;transport=UDP;lr>\r\nContent-Length: 0\r\n\r\n"
        sipByeOk = "SIP/2.0 200 OK\r\nVia: SIP/2.0/UDP 200.57.7.195:5060;branch=z\r\nTo: <sip:f@b:5060>;tag=8\r\nFrom: <tel:1>;tag=2\r\nCall-ID: 1@200.57.7.195\r\nCSeq: 2 BYE\r\nContent-Length: 0\r\n\r\n"
    	
    	sipTransList = (sipInvite, sipTrying, sipRinging,sipOk, sipAck, sipBye, sipByeOk)
    	sipTransNames = ("sipInvite", "sipTrying", "sipRinging", "sipOk", "sipAck", "sipBye", "sipByeOk") 
    	sipTransDirList = (0,1,1,1,0,0,1)
    	sipTransTypeList = (0,0,0,0,0,1,1)    	    	
    	
    	for clPair in self.sipClientPairs:
    	    (wClName, eClName, wUdpPort, eUdpPort, qosInfo,clIntType) = clPair
    	    wlanUp = qosInfo['layer2Qos']['wlanUp']   
    	    ethUp = qosInfo['layer2Qos']['ethUp']  
    	    if clIntType == 1: 
    	        WaveEngine.VCLtest("ec.read('%s')" % (wClName))
    	        wlanIp = ec.getIpAddress()
    	        qosEnabled = ec.getVlanTag()
    	    else:    	    	    
    	        WaveEngine.VCLtest("mc.read('%s')" % (wClName))
    	        wlanIp = mc.getIpAddress()
    	        qosEnabled = mc.getWmeEnabled()
    	    WaveEngine.VCLtest("ec.read('%s')" % (eClName))
    	    ethIp = ec.getIpAddress()
    	    vlanTag = ec.getVlanTag()
    	    sipFlowList = []
    	    for ii in range(0, len(sipTransList)):    	    	
    	    	if sipTransTypeList[ii] == sipType:    	    	
    	    	    if sipTransDirList[ii] == 0:
    	                srcUdpPort = 5060
    	                dstUdpPort = 5061
    	                srcClient = wClName
    	                dstClient = eClName
    	            elif sipTransDirList[ii] == 1:
    	                srcUdpPort = 5061
    	                dstUdpPort = 5060
    	                srcClient = eClName
    	                dstClient = wClName  
    	                
    	            sipPkt = sipTransList[ii].replace("200.57.7.195", wlanIp)
    	            sipPkt = sipPkt.replace("200.57.7.204", ethIp)
    	            sipPkt = sipPkt.replace("40376", str(wUdpPort))    	    
    	            sipPkt = unicode(sipPkt).encode('hex')
    	            sipPayloadLen = len(sipPkt)/2
    	            #if sipPayloadLen > 256:
    	            #    sipPayloadLen = 256
    	            pLength = 32 - 14 + 28 + sipPayloadLen
    	                	         
    	            FlowName = "%s_%s:%s-->%s:%s" % (sipTransNames[ii], srcClient, srcUdpPort, dstClient,dstUdpPort)    	        
                    WaveEngine.VCLtest("flow.create('%s')"        % (FlowName))
                    WaveEngine.VCLtest("flow.setSrcClient('%s')"  % (srcClient))
                    WaveEngine.VCLtest("flow.setDestClient('%s')" % (dstClient))
                    WaveEngine.VCLtest("flow.setType('IP UDP')")
                    WaveEngine.VCLtest("flow.setNumFrames(%d)" % (1))  
                    WaveEngine.VCLtest("flow.setIntendedRate(%d)" % (1))
                    WaveEngine.VCLtest("flow.setInsertSignature('off')")   
                    WaveEngine.VCLtest("flow.setFrameSize(%d)" % (pLength))           
                    WaveEngine.VCLtest("flow.setPayload('%s')" % (sipPkt)) 
                    WaveEngine.VCLtest("flow.setPayloadLen(%d)" % (sipPayloadLen)) 
                    
                    if dstClient in self.clientsBehindNatList:
                        WaveEngine.VCLtest("flow.setNatEnable('on')")   
                    else:
                        WaveEngine.VCLtest("flow.setNatEnable('off')") 
                    
                    WaveEngine.VCLtest("ipv4.readFlow()")
                    WaveEngine.VCLtest("ipv4.setTotalLength(%d)" % (pLength - 32 + 14) )
                    WaveEngine.VCLtest("ipv4.modifyFlow()") 
                    
                    if clIntType != 1: 
                        if sipTransDirList[ii] == 0 and qosEnabled == "on": 
                            WaveEngine.VCLtest("wlanQos.readFlow()")
                            WaveEngine.VCLtest("wlanQos.setTgaPriority(%s)" % wlanUp)
                            WaveEngine.VCLtest("wlanQos.setUserPriority(%s)" % wlanUp)
                            WaveEngine.VCLtest("wlanQos.modifyFlow()")  
                    
                    if sipTransDirList[ii] == 1 and vlanTag > 0:
                        WaveEngine.VCLtest("enetQos.readFlow()")
                        WaveEngine.VCLtest("enetQos.setTgaPriority(%s)" % ethUp)
                        WaveEngine.VCLtest("enetQos.setUserPriority(%s)" % ethUp)
                        WaveEngine.VCLtest("enetQos.modifyFlow()")  
                    
                    
                    WaveEngine.VCLtest("udp.readFlow()")
                    WaveEngine.VCLtest("udp.setSrcPort(%d)" % (srcUdpPort) )
                    WaveEngine.VCLtest("udp.setDestPort(%d)" % (dstUdpPort) )
                    WaveEngine.VCLtest("udp.modifyFlow()") 
                    
                    WaveEngine.VCLtest("flow.write('%s')"        % (FlowName))
                    
                    sipFlowList.append(FlowName)                
                                 
            for flws in sipFlowList:
                WaveEngine.VCLtest("flowGroup.create('%s')" % ("sipFlowGroup"))
                WaveEngine.VCLtest("flowGroup.read('sipFlowGroup')")
                WaveEngine.VCLtest("flowGroup.add('%s')" % (flws))
                WaveEngine.VCLtest("flowGroup.write('sipFlowGroup')")    	
    	        WaveEngine.VCLtest("action.startFlowGroup('%s')" % ("sipFlowGroup"))
                time.sleep(0.1) 
                WaveEngine.VCLtest("action.stopFlowGroup('%s')" % ("sipFlowGroup"))  
                WaveEngine.VCLtest("flow.destroy('%s')" % flws) 
                WaveEngine.VCLtest("flowGroup.destroy('sipFlowGroup')")           
    
    
    def getRealTimeClientStats(self):
    	print "Client Stats Print...."
    	for clName in mc.getNames(): 
    	    WaveEngine.VCLtest("clientStats.read('%s')" % clName)
    	    print clientStats.getPhyBitRateOfLast80211DataPacketReceived()
    	    print clientStats.getProbeHandshakesPerformed()
    	    print clientStats.getSuccessfulAuthenticationHandshakes()
    	    print clientStats.getRssiOfLast80211DataPacketReceived()	
    	      
        
    def getClientStatus(self):
    	StateDict = { 0: 3, 1: 4, 2: 5, 3: 6, 4: 7, 5: 8, 8: 9, 20: 10, 21: 11, 'EthernetClientCode': 12, -101: 3}
    	clStatusList = []
    	for clName in mc.getNames():    
    	    clEntry = []
    	    clEntry.append(clName)
    	    state = mc.checkStatus(clName)
    	    WaveEngine.VCLtest("mc.read('%s')"%clName)    	    
    	    clEntry.append(mc.getMacAddress())
    	    clEntry.append(mc.getIpAddress())   	    
    	    #print state
    	    if state in StateDict:
                clEntry.append(StateDict[state])  
            else:
                clEntry.append(-1)     
            clStatusList.append(clEntry)
        
        for clName in ec.getNames():    
    	    clEntry = []
    	    clEntry.append(clName)
    	    WaveEngine.VCLtest("ec.read('%s')"%clName)    	    
    	    clEntry.append(mc.getMacAddress())
    	    clEntry.append(mc.getIpAddress())    	    			
    	    state = ec.checkStatus(clName)
    	    if state in StateDict:
                clEntry.append(StateDict[state]) 
            else:
                clEntry.append(-1)     
            clStatusList.append(clEntry)
        
        return clStatusList
    
    
    def measureIloadOverTime(self, sampTime):
    	tIload = 0
    	for flw in self.startedFlowsList:
    	    if flw not in self.stoppedFlowsList:
    	        tIload += self.flowTypeDict[flw][5]    
    	self.tIloadOverTime[sampTime] = round(tIload, 2)   
    
    def saveOverTimeResults(self, sampTime):
    	self.tOloadPerSample = 0
    	self.tAloadPerSample = 0
    	
        for flw in self.flowTypeDict:
            if flw not in self.overTimeFlowResults:
                self.overTimeFlowResults[flw] = {}   
            else:                
                if self.flowTypeDict[flw][0] == "VOIP": 
                	
                	if flw in self.startedFlowsList:
    	                    (oload, frate, perPacketLoss, OfferedLoadKbps, frateKbps) = self.MeasureFlow_OLOAD_FR_LossRate(flw, self.flowTypeDict[flw][1], 
        	                                                                   self.flowTypeDict[flw][2], (time.time() - self.flowStartTimes[flw] * 1.0),1)
                            if self.overTimeResultType == 0:
                                self.tOloadPerSample += OfferedLoadKbps
                                self.tAloadPerSample += frateKbps     
                        else:
                            frateKbps = 0                  	
                	
                	if "Forwarding Rate" not in self.overTimeFlowResults[flw]:
                	    self.overTimeFlowResults[flw]['Forwarding Rate'] = []
                	self.overTimeFlowResults[flw]['Forwarding Rate'].append(frateKbps)   
                	
                	if "MoS Score" not in self.overTimeFlowResults[flw]:
                	    self.overTimeFlowResults[flw]['MoS Score'] = []
                	self.overTimeFlowResults[flw]['MoS Score'].append(self.getIntermediateFlowStats(flw, "MoS Score"))
                	
                	if "R-value" not in self.overTimeFlowResults[flw]:
                	    self.overTimeFlowResults[flw]['R-value'] = []
                	self.overTimeFlowResults[flw]['R-value'].append(self.getIntermediateFlowStats(flw, "R-value"))    
                	    
                elif self.flowTypeDict[flw][0] in ["http", "tcp", "ftp", "TCPVideo", "TCPAudio"]:
                	if "Goodput" not in self.overTimeFlowResults[flw]:
                	    self.overTimeFlowResults[flw]['Goodput'] = []
                	self.overTimeFlowResults[flw]['Goodput'].append(self.getIntermediateFlowStats(flw, "Goodput"))
                        
                        if "Forwarding Rate" not in self.overTimeFlowResults[flw]:
                	    	self.overTimeFlowResults[flw]['Forwarding Rate'] = []
                	self.overTimeFlowResults[flw]['Forwarding Rate'].append(self.getIntermediateFlowStats(flw, "Forwarding Rate"))
                	
                elif self.flowTypeDict[flw][0] == "udp" or self.flowTypeDict[flw][0] == "rtp": 
                	
                	if flw in self.startedFlowsList:
                	    
                	    if self.flowTypeDict[flw][9] in ["waSrcFlow", "waSinkFlow", "waloopFlow"]:
                	    	(oload, frate, perPacketLoss, OfferedLoadKbps, frateKbps, avgLatency, jitter) = self.MeasureFlow_WaveAgent_udp_Metrics(flw, self.flowTypeDict[flw][1], self.flowTypeDict[flw][2], self.flowTypeDict[flw][9], (time.time() - self.flowStartTimes[flw] * 1.0),1)
            	            else:             	    
                	        (oload, frate, perPacketLoss, OfferedLoadKbps, frateKbps) = self.MeasureFlow_OLOAD_FR_LossRate(flw, self.flowTypeDict[flw][1], 
        	                                                                   self.flowTypeDict[flw][2], (time.time() - self.flowStartTimes[flw] * 1.0),1)
                                avgLatency = self.MeasureFlow_Latency(flw, self.flowTypeDict[flw][2],1)
                                (jitter, loss1, loss2, loss3, loss4, loss5) =  self.MeasureFlow_Jitter_Lossburst(flw, self.flowTypeDict[flw][2])                            
                            
                            if self.overTimeResultType == 0:
                                self.tOloadPerSample += OfferedLoadKbps
                                self.tAloadPerSample += frateKbps
                        else:
                            frateKbps = 0 
                            avgLatency = 0
                            jitter = 0
                            perPacketLoss = 0  
                	
                	if "Forwarding Rate" not in self.overTimeFlowResults[flw]:
                	    self.overTimeFlowResults[flw]['Forwarding Rate'] = []
                	#self.overTimeFlowResults[flw]['Forwarding Rate'].append(self.getIntermediateFlowStats(flw, "Forwarding Rate"))
                	self.overTimeFlowResults[flw]['Forwarding Rate'].append(frateKbps)                	
                	
                	if "Latency" not in self.overTimeFlowResults[flw]:
                	    self.overTimeFlowResults[flw]['Latency'] = []
                	#self.overTimeFlowResults[flw]['Latency'].append(self.getIntermediateFlowStats(flw, "Latency"))
                	self.overTimeFlowResults[flw]['Latency'].append(avgLatency / 1000.0)
                	
                	if "Packet Loss" not in self.overTimeFlowResults[flw]:
                	    self.overTimeFlowResults[flw]['Packet Loss'] = []
                	#self.overTimeFlowResults[flw]['Packet Loss'].append(self.getIntermediateFlowStats(flw, "Packet Loss"))
                	self.overTimeFlowResults[flw]['Packet Loss'].append(perPacketLoss)
                	
                	if "Jitter" not in self.overTimeFlowResults[flw]:
                	    self.overTimeFlowResults[flw]['Jitter'] = []
                	#self.overTimeFlowResults[flw]['Jitter'].append(self.getIntermediateFlowStats(flw, "Jitter"))
                	self.overTimeFlowResults[flw]['Jitter'].append(jitter / 1000.0)
                	
                elif self.flowTypeDict[flw][0] == "RTPVideo" or self.flowTypeDict[flw][0] == "RTPAudio":     	                	
                	
                	if flw in self.startedFlowsList:
                	    if self.flowTypeDict[flw][9] == "mcastflow":        
        	                for itms in self.multicastFlowList:
                                    if flw == itms[0]:
        	                        mcastInfo = itms               	  		            	
                                    (oload, frate, perPacketLoss, OfferedLoadKbps, frateKbps, avgLatency, jitter) = self.MeasureMulticastFlowStats(mcastInfo, (time.time() - self.flowStartTimes[flw]))
                                    df = self.MeasureMcastFlow_DelayFactor(mcastInfo)
                	    else:
    	                        (oload, frate, perPacketLoss, OfferedLoadKbps, frateKbps) = self.MeasureFlow_OLOAD_FR_LossRate(flw, self.flowTypeDict[flw][1], 
        	                                                                   self.flowTypeDict[flw][2], (time.time() - self.flowStartTimes[flw] * 1.0),1)
                                avgLatency = self.MeasureFlow_Latency(flw, self.flowTypeDict[flw][2],1)
                                (jitter, loss1, loss2, loss3, loss4, loss5) =  self.MeasureFlow_Jitter_Lossburst(flw, self.flowTypeDict[flw][2])  
                                df = self.MeasureFlow_DelayFactor(flw, self.flowTypeDict[flw][2])                          
                            
                            if self.overTimeResultType == 0:
                                self.tOloadPerSample += OfferedLoadKbps
                                self.tAloadPerSample += frateKbps
                        else:
                            frateKbps = 0 
                            avgLatency = 0
                            jitter = 0
                            perPacketLoss = 0 
                            df = 0
                	
                	
                	if "Forwarding Rate" not in self.overTimeFlowResults[flw]:
                	    self.overTimeFlowResults[flw]['Forwarding Rate'] = []
                	#self.overTimeFlowResults[flw]['Latency'].append(self.getIntermediateFlowStats(flw, "Latency"))
                	self.overTimeFlowResults[flw]['Forwarding Rate'].append(frateKbps)                	
                	
                	if "Latency" not in self.overTimeFlowResults[flw]:
                	    self.overTimeFlowResults[flw]['Latency'] = []
                	#self.overTimeFlowResults[flw]['Latency'].append(self.getIntermediateFlowStats(flw, "Latency"))
                	self.overTimeFlowResults[flw]['Latency'].append(avgLatency / 1000.0)
                	
                	if "Media Loss Ratio" not in self.overTimeFlowResults[flw]:
                	    self.overTimeFlowResults[flw]['Media Loss Ratio'] = []
                	#self.overTimeFlowResults[flw]['Media Loss Ratio'].append(self.getIntermediateFlowStats(flw, "Media Loss Ratio"))
                	self.overTimeFlowResults[flw]['Media Loss Ratio'].append(perPacketLoss)
                	
                	if "Jitter" not in self.overTimeFlowResults[flw]:
                	    self.overTimeFlowResults[flw]['Jitter'] = []
                	#self.overTimeFlowResults[flw]['Jitter'].append(self.getIntermediateFlowStats(flw, "Jitter"))
                	self.overTimeFlowResults[flw]['Jitter'].append(jitter / 1000.0)
                	
                	if "Delay Factor" not in self.overTimeFlowResults[flw]:
                	    self.overTimeFlowResults[flw]['Delay Factor'] = []
                	#self.overTimeFlowResults[flw]['Delay Factor'].append(self.getIntermediateFlowStats(flw, "Delay Factor"))   
                	self.overTimeFlowResults[flw]['Delay Factor'].append(df) 
        
        if self.overTimeResultType == 0:
            self.tOloadOverTime[sampTime] = round(self.tOloadPerSample,2)
            self.tAloadOverTime[sampTime] = round(self.tAloadPerSample,2)
    
    
    def getOverTimeStatsData(self):
    	statsDataDict = dict()
    	for flw in self.flowTypeDict:
    	    WaveEngine.VCLtest("flowStats.read('%s','%s')" % (self.flowTypeDict[flw][1], flw))
            TXframes = flowStats.txFlowFramesOk
            WaveEngine.VCLtest("flowStats.read('%s','%s')" % (self.flowTypeDict[flw][2], flw))
            RXframes = flowStats.rxFlowFramesOk
            statsDataDict[flw] = (TXframes, RXframes)
        return statsDataDict         	
        
    def getIntermediateFlowStats(self, flw, mName):   
    	if flw not in self.startedFlowsList:
    	    return 0
    	        	
    	if self.flowTypeDict[flw][0] == "VOIP":    	    	
    	    
    	    rvalue =  self.Measure_rvalue(flw, self.flowTypeDict[flw][2], (time.time() - self.flowStartTimes[flw])) 
    	    #rvalue =  self.Measure_rvalue(flw, self.flowTypeDict[flw][2], self.resultSampleTime, 1) 
            R = float(rvalue)
            
            if mName == "MoS Score":
                mosScore = 0.0
                if R < 6.5:
                    mosScore = 1.0
                elif R > 100:
                    mosScore = 4.5
                else:                          
                    mosScore = 1.0 - (7.0 * R / 1000.0) +  (7.0 * (R ** 2.0) / 6250.0) - (7.0 * (R ** 3.0)/ 1000000.0)
                self.realTimeChartYData.append(mosScore)   
                return mosScore 
            else:            
                self.realTimeChartYData.append(R)  
                return R 
            
        if self.flowTypeDict[flw][0] in ["http", "tcp", "ftp", "TCPVideo", "TCPAudio"]:              	
            WaveEngine.VCLtest("biflow.read('%s')"  % (flw))
            srcClient = biflow.getSrcClient()
            dstClient = biflow.getDestClient()
            srcPort = self.flowTypeDict[flw][1]
            dstPort = self.flowTypeDict[flw][2]    
            frameSize = biflow.getFrameSize()
            MSegSize = frameSize - 72
            flowParams = (srcPort, srcClient, dstPort, dstClient)                     	           	          	 
            (OLOAD, ALOAD, goodput_BPS, totalBytes, FrameLossRate, unAckedSegments) = self.MeasureFlow_OLOAD_Goodput_LossRate(flw, flowParams, MSegSize, (time.time() - self.flowStartTimes[flw]), 1)
            
            self.realTimeChartYData.append(goodput_BPS / 1000.0)  
            
            if self.overTimeResultType == 0:
                self.tOloadPerSample += (OLOAD / 1000.0)
                self.tAloadPerSample += (goodput_BPS / 1000.0)
            
            if mName == "Goodput":
                return (goodput_BPS / 1000.0)
            else:
                return (ALOAD / 1000.0)
                  
        if self.flowTypeDict[flw][0] == "udp" or self.flowTypeDict[flw][0] == "rtp":    
        	
            if self.flowTypeDict[flw][9] in ["waSrcFlow", "waSinkFlow", "waloopFlow"]:
                (oload, frate, perPacketLoss, OfferedLoadKbps, frateKbps, avgLatency, jitter) = self.MeasureFlow_WaveAgent_udp_Metrics(flw, self.flowTypeDict[flw][1], self.flowTypeDict[flw][2], self.flowTypeDict[flw][9], (time.time() - self.flowStartTimes[flw] * 1.0),1)
            else:    
                (oload, frate, perPacketLoss, OfferedLoadKbps, frateKbps) = self.MeasureFlow_OLOAD_FR_LossRate(flw, self.flowTypeDict[flw][1], 
        	                                                               self.flowTypeDict[flw][2], (time.time() - self.flowStartTimes[flw] * 1.0),1)
                avgLatency = self.MeasureFlow_Latency(flw, self.flowTypeDict[flw][2],1)
                (jitter, loss1, loss2, loss3, loss4, loss5) =  self.MeasureFlow_Jitter_Lossburst(flw, self.flowTypeDict[flw][2])
                       
                        
            if mName == "Packet Loss":
                self.realTimeChartYData.append(avgLatency / 1000.0) 
                return (avgLatency / 1000.0) 
            elif mName == "Jitter":     
            	self.realTimeChartYData.append(jitter / 1000.0) 
            	return (jitter / 1000.0) 
            elif mName == "Forwarding Rate":     
            	self.realTimeChartYData.append(frateKbps) 
            	return (frateKbps) 	
            else: 	
                self.realTimeChartYData.append(perPacketLoss) 
                return perPacketLoss
                
                               
        if self.flowTypeDict[flw][0] == "RTPVideo" or self.flowTypeDict[flw][0] == "RTPAudio":
            if self.flowTypeDict[flw][9] == "mcastflow":        
        	for itms in self.multicastFlowList:
                    if flw == itms[0]:
        	        mcastInfo = itms               	  		            	
                (oload, frate, perPacketLoss, OfferedLoadKbps, frateKbps, avgLatency, jitter) = self.MeasureMulticastFlowStats(mcastInfo, (time.time() - self.flowStartTimes[flw]))
                df = self.MeasureMcastFlow_DelayFactor(mcastInfo)
            else:           	
        	(oload, frate, perPacketLoss, OfferedLoadKbps, frateKbps) = self.MeasureFlow_OLOAD_FR_LossRate(flw, self.flowTypeDict[flw][1], 
        	                                                                                                      self.flowTypeDict[flw][2], (time.time() - self.flowStartTimes[flw]),1)
                avgLatency = self.MeasureFlow_Latency(flw, self.flowTypeDict[flw][2],1)
                (jitter, loss1, loss2, loss3, loss4, loss5) =  self.MeasureFlow_Jitter_Lossburst(flw, self.flowTypeDict[flw][2])
                df = self.MeasureFlow_DelayFactor(flw, self.flowTypeDict[flw][2])
            
            if self.overTimeResultType == 0:
                self.tOloadPerSample += OfferedLoadKbps
                self.tAloadPerSample += frateKbps
            
            if mName == "Media Loss Ratio":
                self.realTimeChartYData.append(perPacketLoss) 
                return perPacketLoss
            elif mName == "Latency":     
            	self.realTimeChartYData.append(avgLatency / 1000.0) 
            	return (avgLatency / 1000.0) 
            elif mName == "Jitter":     
            	self.realTimeChartYData.append(jitter / 1000.0)  	
            	return (jitter / 1000.0)
            else: 	
                self.realTimeChartYData.append(df) 
                return df
            
                   
    
    def getFlowStats(self):
    	self.flowResultsDict = dict()  
    	self.IOAloadPerFlowDict = dict() 
    	
    	self.slaCountDict = dict()
    	self.slaReqDict = dict()	
        
        self.voiceRvalueList = [] 
        self.voiceMosList = []
        self.voiceFrateList = []
        self.voiceJitterList = []
        self.voiceLatencyList = []
        self.voicePacketLossList = []
        self.voiceOloadList = []
        self.voiceIloadList = []
        self.voiceAloadList = []
        self.voiceDiagList = []
        self.voiceProfList = []
                        
        self.rtpVideoFrateList = []
        self.rtpVideoJitterList = []
        self.rtpVideoLatencyList = []
        self.rtpVideoPacketLossList = []
        self.rtpVideoDfList = []
        self.rtpVideoOloadList = []
        self.rtpVideoIloadList = []
        self.rtpVideoAloadList = []
        self.rtpVideoDiagList = []
        self.rtpVideoProfList = []
        
        self.rtpAudioFrateList = []
        self.rtpAudioJitterList = []
        self.rtpAudioLatencyList = []
        self.rtpAudioPacketLossList = []
        self.rtpAudioOloadList = []
        self.rtpAudioIloadList = []
        self.rtpAudioAloadList = []
        self.rtpAudioDiagList = []
        self.rtpAudioProfList = []
        
        self.ftpGputList = []
        self.ftpSlaReqList = []
        self.ftpPacketLossList =[]
        self.ftpOloadList = []
        self.ftpIloadList = []
        self.ftpAloadList = []
        self.ftpFttList = []
        self.ftpDiagList = []
        self.ftpProfList = []
        
        self.httpGputList = []
        self.httpSlaReqList = []
        self.httpPacketLossList =[]
        self.httpOloadList = []
        self.httpIloadList = []
        self.httpAloadList = []
        self.httpDiagList = []
        self.httpProfList = []
        
        self.tcpVideoGputList = []
        self.tcpVideoPacketLossList =[]
        self.tcpVideoOloadList = []
        self.tcpVideoIloadList = []
        self.tcpVideoAloadList = []
        self.tcpVideoDiagList = []
        self.tcpVideoProfList = []
        
        self.tcpAudioGputList = []
        self.tcpAudioPacketLossList =[]
        self.tcpAudioOloadList = []
        self.tcpAudioIloadList = []
        self.tcpAudioAloadList = []
        self.tcpAudioDiagList = []
        self.tcpAudioProfList = []
        
        self.tcpGputList = []
        self.tcpSlaReqList = []
        self.tcpOloadList = []       
        self.tcpPacketLossList =[]
        self.tcpIloadList = [] 
        self.tcpAloadList = [] 
        self.tcpDiagList = []
        self.tcpProfList = []
        
        self.udpFrateList = []
        self.udpJitterList = []
        self.udpLatencyList = []
        self.udpPacketLossList = []
        self.udpOloadList = []
        self.udpIloadList = []
        self.udpAloadList = []
        self.udpDiagList = []
        self.udpProfList = []
        
        self.rtpFrateList = []
        self.rtpJitterList = []
        self.rtpLatencyList = []
        self.rtpPacketLossList = []
        self.rtpOloadList = []
        self.rtpIloadList = []
        self.rtpAloadList = []
        self.rtpDiagList = []
        self.rtpProfList = []
                
    	for flw in self.flowTypeDict.keys():
    	    self.slaReqDict[self.flowTypeDict[flw][0]] = self.flowTypeDict[flw][6]
    	    self.TestResult[flw]= {}
            if self.flowTypeDict[flw][0] == "VOIP":    	    	
    	    	
    	    	if self.flowTypeDict[flw][6]['slaMode'] == 0:
    	    	    slaRval = self.flowTypeDict[flw][6]['value']
    	    	else:
    	    	    slaMosVal = self.flowTypeDict[flw][6]['value']    
    	    	
    	    	#slaMode = self.flowTypeDict[flw][6]['slaMode']
    	    	#slaVal = self.flowTypeDict[flw][6]['value']
    	    	 
            	
            	flowTypeResDict = dict()
            	IOAloadDict = dict()
            	
            	flowTypeResDict['type'] = self.flowTypeDict[flw][0]
            	(oload, frate, perPacketLoss,OfferedLoadKbps, frateKbps) = self.MeasureFlow_OLOAD_FR_LossRate(flw, self.flowTypeDict[flw][1], self.flowTypeDict[flw][2], (self.flowStopTimes[flw] - self.actualFlowStartTimes[flw]))
                avgLatency = self.MeasureFlow_Latency(flw, self.flowTypeDict[flw][2])
                (jitter, loss1, loss2, loss3, loss4, loss5) =  self.MeasureFlow_Jitter_Lossburst(flw, self.flowTypeDict[flw][2])
                rvalue =  self.Measure_rvalue(flw, self.flowTypeDict[flw][2],  (self.flowStopTimes[flw] - self.actualFlowStartTimes[flw])) 
                R = float(rvalue)
                mosScore = 0.0
                if R < 6.5:
                    mosScore = 1.0
                elif R > 100:
                    mosScore = 4.5
                else:                          
                    mosScore = 1.0 - (7.0 * R / 1000.0) +  (7.0 * (R ** 2.0) / 6250.0) - (7.0 * (R ** 3.0)/ 1000000.0)
                
                
                if self.flowTypeDict[flw][6]['slaMode'] == 0:
                    if self.flowTypeDict[flw][0] in self.slaCountDict.keys():
                        if R >= slaRval:	
                            self.slaCountDict[self.flowTypeDict[flw][0]] += 1
                            IOAloadDict['sla'] = True
                            if self.UserPassFailCriteria['User']=='True': 
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['RVALUE',slaRval,R,'PASS']
                        else:
                            IOAloadDict['sla'] = False   
                            self.slaReqMetForTrail = False
                            if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['RVALUE',slaRval,R,'FAIL'] 
                    else:
                        if R >= slaRval:
                            self.slaCountDict[self.flowTypeDict[flw][0]] = 1 
                            IOAloadDict['sla'] = True
                            if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['RVALUE',slaRval,R,'PASS']
                        else:
                            self.slaCountDict[self.flowTypeDict[flw][0]] = 0    
                            IOAloadDict['sla'] = False  
                            self.slaReqMetForTrail = False   
                            if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['RVALUE',slaRval,R,'FAIL']
                else:
                    if self.flowTypeDict[flw][0] in self.slaCountDict.keys():
                        if mosScore >= slaMosVal:	
                            self.slaCountDict[self.flowTypeDict[flw][0]] += 1
                            IOAloadDict['sla'] = True
                            if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['MOS SCORE',slaMosVal,mosScore,'PASS']
                        else:
                            IOAloadDict['sla'] = False    
                            self.slaReqMetForTrail = False
                            if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['MOS SCORE',slaMosVal,mosScore,'FAIL']
                    else:
                        if mosScore >= slaMosVal:
                            self.slaCountDict[self.flowTypeDict[flw][0]] = 1 
                            IOAloadDict['sla'] = True
                            if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['MOS SCORE',slaMosVal,mosScore,'PASS']
                        else:
                            self.slaCountDict[self.flowTypeDict[flw][0]] = 0    
                            IOAloadDict['sla'] = False   
                            self.slaReqMetForTrail = False          	
                            if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['MOS SCORE',slaMosVal,mosScore,'FAIL']
                
                
                if self.flowTypeDict[flw][5] < OfferedLoadKbps :
                    iLoadVal = OfferedLoadKbps
                else:	
                    iLoadVal = self.flowTypeDict[flw][5]
                
                
                if self.flowTypeDict[flw][0] == "VOIP":  
                    self.voiceRvalueList.append(R)
                    self.voiceMosList.append(mosScore)
                    self.voiceFrateList.append(frateKbps)
                    self.voiceJitterList.append(jitter)
                    self.voiceLatencyList.append(avgLatency)
                    self.voicePacketLossList.append(perPacketLoss)  
                    self.voiceOloadList.append(OfferedLoadKbps)
                    self.voiceIloadList.append(iLoadVal)
                    self.voiceAloadList.append(frateKbps)                    
                    self.voiceDiagList.append(self.flowTypeDict[flw][10])  
                    self.voiceProfList.append(flw)                                            
                                
                IOAloadDict['iload'] = iLoadVal
                IOAloadDict['oload'] = OfferedLoadKbps                
                IOAloadDict['aload'] = frateKbps
                
                self.IOAloadPerFlowDict[flw] = IOAloadDict
                
                flowTypeResDict['results'] = { 'rValue' : R, 'mosScore' : mosScore, 'offeredLoad' : OfferedLoadKbps, '1LossBrst' : loss1, 
                                   '2LossBrst' : loss2, '3LossBrst' : loss3, '4LossBrst' : loss4, '5LossBrst' : loss5, 
                                    'jitter' : jitter, 'ForwadingRate' : frateKbps, 'avgLatency' : avgLatency, '%PacketLoss' : perPacketLoss,
                                    'Flow IP' :  self.flowTypeDict[flw][10][1], 'Flow MAC' : self.flowTypeDict[flw][10][2],
                                    'Flow Ports' : self.flowTypeDict[flw][10][3], 'Flow Network' : self.flowTypeDict[flw][10][4],
                                    'Flow Direction' : self.flowTypeDict[flw][10][5]}
                flowCSVResN = []
                flowCSVResV = []
                flowCSVResN.append('Type')
                flowCSVResV.append(flowTypeResDict['type'])
                for resType in flowTypeResDict['results'].keys():
                    flowCSVResN.append(resType)    	
                    flowCSVResV.append(flowTypeResDict['results'][resType])
                
                self.ResultsForCSVfile.append( flowCSVResN ) 
                self.ResultsForCSVfile.append( flowCSVResV )
                
                if self.flowTypeDict[flw][6]['slaMode'] == 0:
                    self.Print("\r%s : R-value = %0.3f MOS Score = %0.3f OLOAD = %d kbps, LOSS BURSTS = %d,%d,%d,%d,%d JITTER = %0.2f FWD RATE = %d kbps, AVG LATENCY = %0.3f msecs PKT LOSS = %0.3f, SLA Req R-val = %d, slaMet = %s\n" % (flw, R, mosScore, OfferedLoadKbps, loss1, loss2, loss3, loss4, loss5, jitter, frateKbps, avgLatency, perPacketLoss, slaRval, bool(IOAloadDict['sla'])))  
                else:
                    self.Print("\r%s : R-value = %0.3f MOS Score = %0.3f OLOAD = %d kbps, LOSS BURSTS = %d,%d,%d,%d,%d JITTER = %0.2f FWD RATE = %d kbps, AVG LATENCY = %0.3f msecs PKT LOSS = %0.3f, SLA Req MoS Score = %d, slaMet = %s\n" % (flw, R, mosScore, OfferedLoadKbps, loss1, loss2, loss3, loss4, loss5, jitter, frateKbps, avgLatency, perPacketLoss, slaMosVal, bool(IOAloadDict['sla'])))  
                
                
                self.flowResultsDict[flw] = flowTypeResDict
            
                        
            if self.flowTypeDict[flw][0] in ["TCPVideo", "TCPAudio"]:       
            	
            	if 'playDelay' in self.flowTypeDict[flw][6]:
    	    	    slaPlayDelayVal = self.flowTypeDict[flw][6]['playDelay']
    	    	else:
    	    	    slaPlayDelayVal = 1000 
    	        
    	        if 'contPlay' in self.flowTypeDict[flw][6]:
    	    	    slaContPlay = self.flowTypeDict[flw][6]['contPlay']
    	    	else:
    	    	    slaContPlay = 1 	    
    	    	    	    	
    	    	bufferSize = int(self.flowTypeDict[flw][8]['bufferSize'])  # in KBytes
    	    	fileSize = int(self.flowTypeDict[flw][8]['mediaFileSize']) # in KBytes
    	    	playTime = int(self.flowTypeDict[flw][8]['playTime']) # in secs
    	    	medProtocol = int(self.flowTypeDict[flw][8]['mediaProtocol'])
    	    	
    	    	if slaContPlay == 1:
    	    	    playRateKbps = 0
    	    	else:
    	    	    playRateKbps = ((fileSize - bufferSize) * 8) / playTime
    	    	    
    	        startRateReqKbps = (bufferSize * 8) / slaPlayDelayVal    
    	    	    	    	    	    	
    	    	flowTypeResDict = dict()
            	IOAloadDict = dict()
            	
            	flowTypeResDict['type'] = self.flowTypeDict[flw][0]  
            	WaveEngine.VCLtest("biflow.read('%s')"  % (flw))
                srcClient = biflow.getSrcClient()
                dstClient = biflow.getDestClient()
                srcPort = self.flowTypeDict[flw][1]
                dstPort = self.flowTypeDict[flw][2]    
                frameSize = biflow.getFrameSize()
                MSegSize = frameSize - 72
                flowParams = (srcPort, srcClient, dstPort, dstClient)         
                
                         	          	 
                (OLOAD, ALOAD, goodput_BPS, totalBytes, FrameLossRate, unAckedSegments) = self.MeasureFlow_OLOAD_Goodput_LossRate(flw, flowParams, MSegSize, (self.flowStopTimes[flw] - self.actualFlowStartTimes[flw]))
                
                
                if self.flowTypeDict[flw][5] < (OLOAD / 1000):
                    iloadVal = OLOAD / 1000.0
                else:                    
                    iloadVal = self.flowTypeDict[flw][5]  
                
                if self.flowTypeDict[flw][0] == "TCPVideo": 
                    self.tcpVideoGputList.append(goodput_BPS / 1000.0)
                    self.tcpVideoPacketLossList.append(FrameLossRate)  
                    self.tcpVideoOloadList.append(OLOAD/ 1000.0)                      
                    self.tcpVideoIloadList.append(iloadVal)  
                    self.tcpVideoAloadList.append(ALOAD / 1000.0)  
                    self.tcpVideoDiagList.append(self.flowTypeDict[flw][10])
                    self.tcpVideoProfList.append(flw) 
                elif self.flowTypeDict[flw][0] == "TCPAudio":
                    self.tcpAudioGputList.append(goodput_BPS / 1000.0)    
                    self.tcpAudioPacketLossList.append(FrameLossRate)  
                    self.tcpAudioOloadList.append(OLOAD/ 1000.0)                       
                    self.tcpAudioIloadList.append(iloadVal)                   
                    self.tcpAudioAloadList.append(ALOAD / 1000.0) 
                    self.tcpAudioDiagList.append(self.flowTypeDict[flw][10])
                    self.tcpAudioProfList.append(flw) 
                
                goodPutKbps = goodput_BPS / 1000.0
                
                if self.flowTypeDict[flw][0] in self.slaCountDict.keys():
                    if goodPutKbps >= startRateReqKbps and goodPutKbps >= playRateKbps:	
                        self.slaCountDict[self.flowTypeDict[flw][0]] += 1
                        IOAloadDict['sla'] = True
                        if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['Allowable Goodput','%s Kbps:%s Kbps' %(startRateReqKbps,playRateKbps),goodPutKbps,'PASS'] 
                    else:
                        IOAloadDict['sla'] = False   
                        self.slaReqMetForTrail = False  
                        if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['Allowable Goodput','%s Kbps:%s Kbps' %(startRateReqKbps,playRateKbps),goodPutKbps,'FAIL']
                else:
                    if goodPutKbps >= startRateReqKbps and goodPutKbps >= playRateKbps:
                        self.slaCountDict[self.flowTypeDict[flw][0]] = 1 
                        IOAloadDict['sla'] = True
                        if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['Allowable Goodput','%s Kbps:%s Kbps' %(startRateReqKbps,playRateKbps),goodPutKbps,'PASS']
                    else:
                        self.slaCountDict[self.flowTypeDict[flw][0]] = 0  
                        IOAloadDict['sla'] = False   
                        self.slaReqMetForTrail = False
                        if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['Allowable Goodput','%s Kbps:%s Kbps' %(startRateReqKbps,playRateKbps),goodPutKbps,'FAIL']
                
                IOAloadDict['iload'] = iloadVal
                IOAloadDict['oload'] = OLOAD/ 1000.0
                IOAloadDict['aload'] = OLOAD/ 1000.0
                                
                self.IOAloadPerFlowDict[flw] = IOAloadDict
                
                self.Print("\r%s : ILOAD = %0.3f Kbps OLOAD = %0.3f Kbps GOODPUT = %0.3f Kbps Layer2 Loss = %d, slaMet = %s\n" % (flw, iloadVal, OLOAD / 1000.0, goodput_BPS / 1000.0, FrameLossRate, IOAloadDict['sla']))  
                flowTypeResDict['results'] = { 'offeredLoad' : OLOAD, 'goodput' : goodput_BPS, 'totalBytes' : totalBytes, 
                                                '%PacketLoss' : FrameLossRate, 'slaReq' : IOAloadDict['sla'],
                                                'Flow IP' :  self.flowTypeDict[flw][10][1], 'Flow MAC' : self.flowTypeDict[flw][10][2],
                                               'Flow Ports' : self.flowTypeDict[flw][10][3], 'Flow Network' : self.flowTypeDict[flw][10][4],
                                               'Flow Direction' : self.flowTypeDict[flw][10][5]}
                
                flowCSVResN = []
                flowCSVResV = []
                flowCSVResN.append('Type')
                flowCSVResV.append(flowTypeResDict['type'])
                for resType in flowTypeResDict['results'].keys():
                    flowCSVResN.append(resType)    	
                    flowCSVResV.append(flowTypeResDict['results'][resType])
                
                self.ResultsForCSVfile.append( flowCSVResN ) 
                self.ResultsForCSVfile.append( flowCSVResV )
                
                
                self.flowResultsDict[flw] = flowTypeResDict
                
                                      
            if self.flowTypeDict[flw][0] == "http" or self.flowTypeDict[flw][0] == "tcp":       
            	
            	if 'perLoad' in self.flowTypeDict[flw][6].keys():
    	    	    slaGputval = self.flowTypeDict[flw][6]['perLoad'] * self.flowTypeDict[flw][5] / 100.0
    	    	else:
    	    	    slaGputval = 0  
    	    	    	    	
    	    	flowTypeResDict = dict()
            	IOAloadDict = dict()
                
                flowTypeResDict['type'] = self.flowTypeDict[flw][0]  
            	WaveEngine.VCLtest("biflow.read('%s')"  % (flw))
                srcClient = biflow.getSrcClient()
                dstClient = biflow.getDestClient()
                srcPort = self.flowTypeDict[flw][1]
                dstPort = self.flowTypeDict[flw][2]
                frameSize = biflow.getFrameSize()
                MSegSize = frameSize - 72
                flowParams = (srcPort, srcClient, dstPort, dstClient)         
                
                if 'perLoad' in self.flowTypeDict[flw][6].keys():
    	    	    slaGputval = self.flowTypeDict[flw][6]['perLoad'] * self.flowTypeDict[flw][5] * MSegSize / ( 100.0 * frameSize)
    	    	else:
    	    	    slaGputval = 0                
                              	           	          	 
                (OLOAD, ALOAD, goodput_BPS, totalBytes, FrameLossRate, unAckedSegments) = self.MeasureFlow_OLOAD_Goodput_LossRate(flw, flowParams, MSegSize, (self.flowStopTimes[flw] - self.actualFlowStartTimes[flw]))
                
                if self.flowTypeDict[flw][5] < (OLOAD / 1000):
                    iloadVal = OLOAD / 1000.0
                else:                    
                    iloadVal = self.flowTypeDict[flw][5]  
                
                if self.flowTypeDict[flw][0] == "http": 
                    self.httpGputList.append(goodput_BPS / 1000.0)
                    self.httpPacketLossList.append(FrameLossRate)  
                    self.httpOloadList.append(OLOAD/ 1000.0)                      
                    self.httpIloadList.append(iloadVal)  
                    self.httpAloadList.append(ALOAD / 1000.0)  
                    self.httpSlaReqList.append(slaGputval) 
                    self.httpDiagList.append(self.flowTypeDict[flw][10])
                    self.httpProfList.append(flw) 
                elif self.flowTypeDict[flw][0] == "tcp":
                    self.tcpGputList.append(goodput_BPS / 1000.0)    
                    self.tcpPacketLossList.append(FrameLossRate)  
                    self.tcpOloadList.append(OLOAD/ 1000.0)                       
                    self.tcpIloadList.append(iloadVal)                   
                    self.tcpAloadList.append(ALOAD / 1000.0) 
                    self.tcpSlaReqList.append(slaGputval)   
                    self.tcpDiagList.append(self.flowTypeDict[flw][10])
                    self.tcpProfList.append(flw) 
                
                goodPutKbps = goodput_BPS / 1000.0
                
                if self.flowTypeDict[flw][0] in self.slaCountDict.keys():
                    if goodPutKbps >= slaGputval:	
                        self.slaCountDict[self.flowTypeDict[flw][0]] += 1
                        IOAloadDict['sla'] = True
                        self.TestResult[flw][self.flowTypeDict[flw][0]]=['GOOD PUT','%s Kbps' %slaGputval,'%s Kbps' %goodPutKbps,'PASS']
                    else:
                        IOAloadDict['sla'] = False   
                        self.slaReqMetForTrail = False  
                        self.TestResult[flw][self.flowTypeDict[flw][0]]=['GOOD PUT','%s Kbps' %slaGputval,'%s Kbps' %goodPutKbps,'FAIL']
                else:
                    if goodPutKbps >= slaGputval:
                        self.slaCountDict[self.flowTypeDict[flw][0]] = 1 
                        IOAloadDict['sla'] = True
                        self.TestResult[flw][self.flowTypeDict[flw][0]]=['GOOD PUT','%s Kbps' %slaGputval,'%s Kbps' %goodPutKbps,'PASS'] 
                    else:
                        self.slaCountDict[self.flowTypeDict[flw][0]] = 0  
                        IOAloadDict['sla'] = False   
                        self.slaReqMetForTrail = False
                        self.TestResult[flw][self.flowTypeDict[flw][0]]=['GOOD PUT','%s Kbps' %slaGputval,'%s Kbps' %goodPutKbps,'FAIL']
                
                IOAloadDict['iload'] = iloadVal
                IOAloadDict['oload'] = OLOAD/ 1000.0
                IOAloadDict['aload'] = OLOAD/ 1000.0
                                
                self.IOAloadPerFlowDict[flw] = IOAloadDict
                
                self.Print("\r%s : ILOAD = %0.3f Kbps OLOAD = %0.3f Kbps GOODPUT = %0.3f Kbps Layer2 Loss = %d  SLA Req Gput = %0.3f, slaMet = %s\n" % (flw, iloadVal, OLOAD / 1000.0, goodput_BPS / 1000.0, FrameLossRate, slaGputval, IOAloadDict['sla']))  
                flowTypeResDict['results'] = { 'offeredLoad' : OLOAD, 'goodput' : goodput_BPS, 'totalBytes' : totalBytes, 
                                                '%PacketLoss' : FrameLossRate, 'slaReq' : IOAloadDict['sla'],
                                                'Flow IP' :  self.flowTypeDict[flw][10][1], 'Flow MAC' : self.flowTypeDict[flw][10][2],
                                               'Flow Ports' : self.flowTypeDict[flw][10][3], 'Flow Network' : self.flowTypeDict[flw][10][4],
                                               'Flow Direction' : self.flowTypeDict[flw][10][5]}
                
                flowCSVResN = []
                flowCSVResV = []
                flowCSVResN.append('Type')
                flowCSVResV.append(flowTypeResDict['type'])
                for resType in flowTypeResDict['results'].keys():
                    flowCSVResN.append(resType)    	
                    flowCSVResV.append(flowTypeResDict['results'][resType])
                
                self.ResultsForCSVfile.append( flowCSVResN ) 
                self.ResultsForCSVfile.append( flowCSVResV )
                
                
                self.flowResultsDict[flw] = flowTypeResDict
                
            
            if self.flowTypeDict[flw][0] == "ftp":            	
            	
    	    	
    	    	ftpFileSize = int(self.flowTypeDict[flw][8]['FileSize']) * 1000
            	
            	flowTypeResDict = dict()
            	IOAloadDict = dict()
            	
            	flowTypeResDict['type'] = self.flowTypeDict[flw][0]  
            	WaveEngine.VCLtest("biflow.read('%s')"  % (flw))
                srcClient = biflow.getSrcClient()
                dstClient = biflow.getDestClient()
                srcPort = self.flowTypeDict[flw][1]
                dstPort = self.flowTypeDict[flw][2]
                frameSize = biflow.getFrameSize()
                MSegSize = frameSize - 72
                flowParams = (srcPort, srcClient, dstPort, dstClient)   
                
                if 'perLoad' in self.flowTypeDict[flw][6].keys():
    	    	    slaGputval = int(self.flowTypeDict[flw][6]['perLoad']) * self.flowTypeDict[flw][5] * MSegSize / ( 100.0 * frameSize )
    	    	else:
    	    	    slaGputval = 0 
                
                      	           	          	 
                (OLOAD, ALOAD, goodput_BPS, totalBytes, FrameLossRate, unAckedSegments) = self.MeasureFlow_OLOAD_Goodput_LossRate(flw, flowParams, MSegSize, (self.flowStopTimes[flw] - self.actualFlowStartTimes[flw]))
                
                
                if self.flowTypeDict[flw][5] < (OLOAD / 1000):
                    iLoadVal = OLOAD / 1000.0  	
                else:
                    iLoadVal = self.flowTypeDict[flw][5]  
                               
                self.ftpGputList.append(goodput_BPS / 1000.0)
                self.ftpSlaReqList.append(slaGputval)
                
                
                self.ftpPacketLossList.append(FrameLossRate)  
                self.ftpOloadList.append(OLOAD/ 1000.0)                 
                self.ftpIloadList.append(iLoadVal)                  
                self.ftpAloadList.append(ALOAD/ 1000.0)     
                self.ftpProfList.append(flw) 
                
                self.ftpDiagList.append(self.flowTypeDict[flw][10])     
                                
                goodPutKbps = goodput_BPS / 1000.0
                
                if goodPutKbps > 0:
                    fTransTime = ftpFileSize / goodPutKbps
                else:
                    fTransTime = -1     
                
                self.ftpFttList.append(fTransTime)         
                
                if self.flowTypeDict[flw][0] in self.slaCountDict.keys():
                    if goodPutKbps >= slaGputval:	
                        self.slaCountDict[self.flowTypeDict[flw][0]] += 1
                        IOAloadDict['sla'] = True
                        if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['Allowable Goodput','%s Kbps' %slaGputval,'%s Kbps' %goodPutKbps,'PASS'] 
                    else:
                        IOAloadDict['sla'] = False   
                        self.slaReqMetForTrail = False
                        if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['Allowable Goodput','%s Kbps' %slaGputval,'%s Kbps' %goodPutKbps,'FAIL'] 
                else:
                    if goodPutKbps >= slaGputval:
                        self.slaCountDict[self.flowTypeDict[flw][0]] = 1 
                        IOAloadDict['sla'] = True
                        if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['Allowable Goodput','%s Kbps' %slaGputval,'%s Kbps' %goodPutKbps,'PASS']
                    else:
                        self.slaCountDict[self.flowTypeDict[flw][0]] = 0  
                        IOAloadDict['sla'] = False   
                        self.slaReqMetForTrail = False
                        if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['Allowable Goodput','%s Kbps' %slaGputval,'%s Kbps' %goodPutKbps,'FAIL'] 
                
                IOAloadDict['iload'] = iLoadVal
                IOAloadDict['oload'] = OLOAD/ 1000.0
                IOAloadDict['aload'] = ALOAD/ 1000.0
                
                
                self.IOAloadPerFlowDict[flw] = IOAloadDict
                
                
                self.Print("\r%s : ILOAD = %0.3f OLOAD = %0.3f Kbps FILE TRANSFER TIME = %0.3f secs GOODPUT = %0.3f Kbps Layer2 Loss = %d  SLA Req Gput = %d Kbps, slaMet = %s\n" % (flw, iLoadVal, OLOAD / 1000.0, fTransTime, goodput_BPS / 1000.0, FrameLossRate, slaGputval, bool(IOAloadDict['sla'])))  
                flowTypeResDict['results'] = { 'offeredLoad' : OLOAD, 'goodput' : goodput_BPS, 'totalBytes' : totalBytes, 
                                              '%PacketLoss' : FrameLossRate, 'fileTransferTime' : fTransTime, 'slaReq' : IOAloadDict['sla'],
                                              'Flow IP' :  self.flowTypeDict[flw][10][1], 'Flow MAC' : self.flowTypeDict[flw][10][2],
                                              'Flow Ports' : self.flowTypeDict[flw][10][3], 'Flow Network' : self.flowTypeDict[flw][10][4],
                                              'Flow Direction' : self.flowTypeDict[flw][10][5]}
                
                
                flowCSVResN = []
                flowCSVResV = []
                flowCSVResN.append('Type')
                flowCSVResV.append(flowTypeResDict['type'])
                for resType in flowTypeResDict['results'].keys():
                    flowCSVResN.append(resType)    	
                    flowCSVResV.append(flowTypeResDict['results'][resType])
                
                self.ResultsForCSVfile.append( flowCSVResN ) 
                self.ResultsForCSVfile.append( flowCSVResV )
                
                self.flowResultsDict[flw] = flowTypeResDict
            
                      
            if self.flowTypeDict[flw][0] == "udp":
            	
            	if 'Latency' in self.flowTypeDict[flw][6].keys():
    	    	    slaLatval = self.flowTypeDict[flw][6]['Latency']
    	    	else:
    	    	    slaLatval = 100000
    	    	    
    	    	if 'Jitter' in self.flowTypeDict[flw][6].keys():
    	    	    slaJitval = self.flowTypeDict[flw][6]['Jitter']
    	    	else:
    	    	    slaJitval = 100000    
            	
            	if 'PacketLoss' in self.flowTypeDict[flw][6].keys():
    	    	    slaPlval = self.flowTypeDict[flw][6]['PacketLoss']
    	    	else:
    	    	    slaPlval = 100    
            	
            	flowTypeResDict = dict()
            	IOAloadDict = dict()
            	
            	flowTypeResDict['type'] = self.flowTypeDict[flw][0]
            	if self.flowTypeDict[flw][9] in ["waSrcFlow", "waSinkFlow", "waloopFlow"]:
            	    (oload, frate, perPacketLoss, OfferedLoadKbps, frateKbps, avgLatency, jitter) = self.MeasureFlow_WaveAgent_udp_Metrics(flw, self.flowTypeDict[flw][1], self.flowTypeDict[flw][2], self.flowTypeDict[flw][9], (self.flowStopTimes[flw] - self.actualFlowStartTimes[flw]))
            	else:           	
            	    (oload, frate, perPacketLoss, OfferedLoadKbps, frateKbps) = self.MeasureFlow_OLOAD_FR_LossRate(flw, self.flowTypeDict[flw][1], self.flowTypeDict[flw][2], (self.flowStopTimes[flw] - self.actualFlowStartTimes[flw]))
            	    avgLatency = self.MeasureFlow_Latency(flw, self.flowTypeDict[flw][2])
                    (jitter, loss1, loss2, loss3, loss4, loss5) =  self.MeasureFlow_Jitter_Lossburst(flw, self.flowTypeDict[flw][2])
                    
                flowTypeResDict['results'] = { 'offeredLoad' : oload, 'jitter' : jitter, 'ForwadingRate' : frateKbps, 
                                               'avgLatency' : avgLatency, '%PacketLoss' : perPacketLoss,
                                               'Flow IP' :  self.flowTypeDict[flw][10][1], 'Flow MAC' : self.flowTypeDict[flw][10][2],
                                               'Flow Ports' : self.flowTypeDict[flw][10][3], 'Flow Network' : self.flowTypeDict[flw][10][4],
                                               'Flow Direction' : self.flowTypeDict[flw][10][5]}
                
                flowCSVResN = []
                flowCSVResV = []
                flowCSVResN.append('Type')
                flowCSVResV.append(flowTypeResDict['type'])
                for resType in flowTypeResDict['results'].keys():
                    flowCSVResN.append(resType)    	
                    flowCSVResV.append(flowTypeResDict['results'][resType])
                
                self.ResultsForCSVfile.append( flowCSVResN ) 
                self.ResultsForCSVfile.append( flowCSVResV )
                
                if self.flowTypeDict[flw][5] < OfferedLoadKbps :
                    iLoadVal = OfferedLoadKbps
                else:	
                    iLoadVal = self.flowTypeDict[flw][5]
                                    
                self.udpFrateList.append(frateKbps)
                self.udpJitterList.append(jitter)
                self.udpLatencyList.append(avgLatency)
                self.udpPacketLossList.append(perPacketLoss)
                self.udpOloadList.append(OfferedLoadKbps)                
                self.udpIloadList.append(iLoadVal) 
                self.udpProfList.append(flw) 
                     
                self.udpAloadList.append(frateKbps)
                
                self.udpDiagList.append(self.flowTypeDict[flw][10])
                    
                if self.flowTypeDict[flw][0] in self.slaCountDict.keys():
                    if avgLatency <= slaLatval and jitter <= slaJitval and perPacketLoss <= slaPlval:	
                        self.slaCountDict[self.flowTypeDict[flw][0]] += 1
                        IOAloadDict['sla'] = True
                        if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['Latency:Jitter:Packet Loss','%s msecs:%s msecs:%s' %(slaLatval,slaJitval,slaPlval),'%s msecs:%s msecs:%s' %(avgLatency,jitter,perPacketLoss),'PASS']
                    else:
                        IOAloadDict['sla'] = False  
                        self.slaReqMetForTrail = False  
                        if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['Latency:Jitter:Packet Loss','%s msecs:%s msecs:%s' %(slaLatval,slaJitval,slaPlval),'%s msecs:%s msecs:%s' %(avgLatency,jitter,perPacketLoss),'FAIL']
                else:
                    if avgLatency <= slaLatval and jitter <= slaJitval and perPacketLoss <= slaPlval:	
                        self.slaCountDict[self.flowTypeDict[flw][0]] = 1 
                        IOAloadDict['sla'] = True
                        if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['Latency:Jitter:Packet Loss','%s msecs:%s msecs:%s' %(slaLatval,slaJitval,slaPlval),'%s msecs:%s msecs:%s' %(avgLatency,jitter,perPacketLoss),'PASS']
                    else:
                        self.slaCountDict[self.flowTypeDict[flw][0]] = 0 
                        IOAloadDict['sla'] = False  
                        self.slaReqMetForTrail = False
                        if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['Latency:Jitter:Packet Loss','%s msecs:%s msecs:%s' %(slaLatval,slaJitval,slaPlval),'%s msecs:%s msecs:%s' %(avgLatency,jitter,perPacketLoss),'FAIL']
                
                IOAloadDict['iload'] = iLoadVal
                IOAloadDict['oload'] = OfferedLoadKbps
                IOAloadDict['aload'] = frateKbps
                                
                self.IOAloadPerFlowDict[flw] = IOAloadDict                
                
                self.Print("\r%s : ILOAD = %0.3f Kbps OLOAD = %d kbps, JITTER = %0.2f FWD RATE = %d kbps, AVG LATENCY = %0.3f msecs PKT LOSS = %0.3f, sla Latency = %0.3f msec, sla Jitter = %0.3f msecs, sla Loss = %0.2f, slaMet = %s \n" % (flw, iLoadVal, OfferedLoadKbps, jitter, frateKbps, avgLatency, perPacketLoss, slaLatval, slaJitval, slaPlval, bool(IOAloadDict['sla'])))  
                self.flowResultsDict[flw] = flowTypeResDict    
            
            
            
            if self.flowTypeDict[flw][0] == "rtp":
            	
            	if 'Latency' in self.flowTypeDict[flw][6].keys():
    	    	    slaLatval = self.flowTypeDict[flw][6]['Latency']
    	    	else:
    	    	    slaLatval = 100000
    	    	    
    	    	if 'Jitter' in self.flowTypeDict[flw][6].keys():
    	    	    slaJitval = self.flowTypeDict[flw][6]['Jitter']
    	    	else:
    	    	    slaJitval = 100000    
            	
            	if 'PacketLoss' in self.flowTypeDict[flw][6].keys():
    	    	    slaPlval = self.flowTypeDict[flw][6]['PacketLoss']
    	    	else:
    	    	    slaPlval = 100    
            	
            	flowTypeResDict = dict()
            	IOAloadDict = dict()
            	
            	flowTypeResDict['type'] = self.flowTypeDict[flw][0]
            	(oload, frate, perPacketLoss, OfferedLoadKbps, frateKbps) = self.MeasureFlow_OLOAD_FR_LossRate(flw, self.flowTypeDict[flw][1], self.flowTypeDict[flw][2], (self.flowStopTimes[flw] - self.actualFlowStartTimes[flw]))
                avgLatency = self.MeasureFlow_Latency(flw, self.flowTypeDict[flw][2])
                (jitter, loss1, loss2, loss3, loss4, loss5) =  self.MeasureFlow_Jitter_Lossburst(flw, self.flowTypeDict[flw][2])
                flowTypeResDict['results'] = { 'offeredLoad' : oload, 'jitter' : jitter, 'ForwadingRate' : frateKbps, 
                                               'avgLatency' : avgLatency, '%PacketLoss' : perPacketLoss,
                                               'Flow IP' :  self.flowTypeDict[flw][10][1], 'Flow MAC' : self.flowTypeDict[flw][10][2],
                                               'Flow Ports' : self.flowTypeDict[flw][10][3], 'Flow Network' : self.flowTypeDict[flw][10][4],
                                               'Flow Direction' : self.flowTypeDict[flw][10][5]}
                
                flowCSVResN = []
                flowCSVResV = []
                flowCSVResN.append('Type')
                flowCSVResV.append(flowTypeResDict['type'])
                for resType in flowTypeResDict['results'].keys():
                    flowCSVResN.append(resType)    	
                    flowCSVResV.append(flowTypeResDict['results'][resType])
                
                self.ResultsForCSVfile.append( flowCSVResN ) 
                self.ResultsForCSVfile.append( flowCSVResV )
                
                
                if self.flowTypeDict[flw][5] < OfferedLoadKbps :
                    iLoadVal = OfferedLoadKbps
                else:	
                    iLoadVal = self.flowTypeDict[flw][5]
                    
                self.rtpFrateList.append(frateKbps)
                self.rtpJitterList.append(jitter)
                self.rtpLatencyList.append(avgLatency)
                self.rtpPacketLossList.append(perPacketLoss)
                self.rtpOloadList.append(OfferedLoadKbps)
                self.rtpIloadList.append(iLoadVal)                 
                self.rtpAloadList.append(frateKbps)
                self.rtpProfList.append(flw) 
                
                self.rtpDiagList.append(self.flowTypeDict[flw][10])
                    
                if self.flowTypeDict[flw][0] in self.slaCountDict.keys():
                    if avgLatency <= slaLatval and jitter <= slaJitval and perPacketLoss <= slaPlval:	
                        self.slaCountDict[self.flowTypeDict[flw][0]] += 1
                        IOAloadDict['sla'] = True
                        if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['Latency:Jitter:Packet Loss','%s msecs:%s msecs:%s' %(slaLatval,slaJitval,slaPlval),'%s msecs:%s msecs:%s' %(avgLatency,jitter,perPacketLoss),'PASS']
                    else:
                        IOAloadDict['sla'] = False   
                        self.slaReqMetForTrail = False  
                        if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['Latency:Jitter:Packet Loss','%s msecs:%s msecs:%s' %(slaLatval,slaJitval,slaPlval),'%s msecs:%s msecs:%s' %(avgLatency,jitter,perPacketLoss),'FAIL']
                else:
                    if avgLatency <= slaLatval and jitter <= slaJitval and perPacketLoss <= slaPlval:	
                        self.slaCountDict[self.flowTypeDict[flw][0]] = 1 
                        IOAloadDict['sla'] = True
                        if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['Latency:Jitter:Packet Loss','%s msecs:%s msecs:%s' %(slaLatval,slaJitval,slaPlval),'%s msecs:%s msecs:%s' %(avgLatency,jitter,perPacketLoss),'PASS']
                    else:
                        self.slaCountDict[self.flowTypeDict[flw][0]] = 0 
                        IOAloadDict['sla'] = False 
                        self.slaReqMetForTrail = False
                        if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['Latency:Jitter:Packet Loss','%s msecs:%s msecs:%s' %(slaLatval,slaJitval,slaPlval),'%s msecs:%s msecs:%s' %(avgLatency,jitter,perPacketLoss),'FAIL']
                
                IOAloadDict['iload'] = iLoadVal
                IOAloadDict['oload'] = OfferedLoadKbps
                IOAloadDict['aload'] = frateKbps
                
                
                self.IOAloadPerFlowDict[flw] = IOAloadDict                
                
                self.Print("\r%s : ILOAD = %0.3f Kbps OLOAD = %d kbps, JITTER = %0.2f FWD RATE = %d kbps, AVG LATENCY = %0.3f msecs PKT LOSS = %0.3f, sla Latency = %0.3f msec, sla Jitter = %0.3f msecs, sla Loss = %0.2f, slaMet = %s \n" % (flw, iLoadVal, OfferedLoadKbps, jitter, frateKbps, avgLatency, perPacketLoss, slaLatval, slaJitval, slaPlval, bool(IOAloadDict['sla'])))  
                self.flowResultsDict[flw] = flowTypeResDict    
            
           
            
            if self.flowTypeDict[flw][0] == "RTPVideo" or self.flowTypeDict[flw][0] == "RTPAudio":
            	
            	if 'Df' in self.flowTypeDict[flw][6].keys():
    	    	    slaDf = self.flowTypeDict[flw][6]['Df']
    	    	else:
    	    	    slaDf = 500000
    	    	    
    	    	if 'Mlr' in self.flowTypeDict[flw][6].keys():
    	    	    slaMlr = self.flowTypeDict[flw][6]['Mlr']
    	    	else:
    	    	    slaMlr = 100 
            	
            	if 'Latency' in self.flowTypeDict[flw][6].keys():
    	    	    slaLatval = self.flowTypeDict[flw][6]['Latency']
    	    	else:
    	    	    slaLatval = 100000
    	    	    
    	    	if 'Jitter' in self.flowTypeDict[flw][6].keys():
    	    	    slaJitval = self.flowTypeDict[flw][6]['Jitter']
    	    	else:
    	    	    slaJitval = 100000    
            	
            	if 'PacketLoss' in self.flowTypeDict[flw][6].keys():
    	    	    slaPlval = self.flowTypeDict[flw][6]['PacketLoss']
    	    	else:
    	    	    slaPlval = 100    
            	           	
            	flowTypeResDict = dict()
            	IOAloadDict = dict()
            	
            	flowTypeResDict['type'] = self.flowTypeDict[flw][0]
            	            	
            	if self.flowTypeDict[flw][9] == "mcastflow":        
            	    for itms in self.multicastFlowList:
            	        if flw == itms[0]:
            	            mcastInfo = itms               	  		            	
                    (oload, frate, perPacketLoss, OfferedLoadKbps, frateKbps, avgLatency, jitter) = self.MeasureMulticastFlowStats(mcastInfo,  (self.flowStopTimes[flw] - self.actualFlowStartTimes[flw]))
                    self.Print("Multicast Flow Results: OLoad :- %0.3f Kbps, FRate :- %0.3f Kbps, per packet Loss :- %0.3f, Avg Latency :- %0.3f msecs" % (OfferedLoadKbps, frateKbps, perPacketLoss, avgLatency))
                    df = self.MeasureMcastFlow_DelayFactor(mcastInfo)
                    
                else:           	
            	    (oload, frate, perPacketLoss, OfferedLoadKbps, frateKbps) = self.MeasureFlow_OLOAD_FR_LossRate(flw, self.flowTypeDict[flw][1], self.flowTypeDict[flw][2],  (self.flowStopTimes[flw] - self.actualFlowStartTimes[flw]))
                    avgLatency = self.MeasureFlow_Latency(flw, self.flowTypeDict[flw][2])
                    (jitter, loss1, loss2, loss3, loss4, loss5) =  self.MeasureFlow_Jitter_Lossburst(flw, self.flowTypeDict[flw][2])
                    df = self.MeasureFlow_DelayFactor(flw, self.flowTypeDict[flw][2])
                
                               
                flowTypeResDict['results'] = { 'offeredLoad' : oload, 'jitter' : jitter, 'ForwadingRate' : frateKbps, 
                                               'avgLatency' : avgLatency, '%PacketLoss' : perPacketLoss , 'mlr' : perPacketLoss , 'delayFactor' : df,
                                               'Flow IP' :  self.flowTypeDict[flw][10][1], 'Flow MAC' : self.flowTypeDict[flw][10][2],
                                               'Flow Ports' : self.flowTypeDict[flw][10][3], 'Flow Network' : self.flowTypeDict[flw][10][4],
                                               'Flow Direction' : self.flowTypeDict[flw][10][5]}
                
                flowCSVResN = []
                flowCSVResV = []
                flowCSVResN.append('Type')
                flowCSVResV.append(flowTypeResDict['type'])
                for resType in flowTypeResDict['results'].keys():
                    flowCSVResN.append(resType)    	
                    flowCSVResV.append(flowTypeResDict['results'][resType])
                
                self.ResultsForCSVfile.append( flowCSVResN ) 
                self.ResultsForCSVfile.append( flowCSVResV )
                
                
                if self.flowTypeDict[flw][5] < OfferedLoadKbps :
                    iLoadVal = OfferedLoadKbps
                else:	
                    iLoadVal = self.flowTypeDict[flw][5]
                
                if self.flowTypeDict[flw][0] == "RTPVideo":
                    self.rtpVideoFrateList.append(frateKbps)
                    self.rtpVideoJitterList.append(jitter)
                    self.rtpVideoLatencyList.append(avgLatency)
                    self.rtpVideoPacketLossList.append(perPacketLoss)
                    self.rtpVideoOloadList.append(OfferedLoadKbps)       
                    self.rtpVideoIloadList.append(iLoadVal)                 
                
                    self.rtpVideoAloadList.append(frateKbps)
                    self.rtpVideoDfList.append(df)
                    self.rtpVideoProfList.append(flw)
                
                    self.rtpVideoDiagList.append(self.flowTypeDict[flw][10])
                
                              
                    if self.flowTypeDict[flw][0] in self.slaCountDict.keys():
                        if df <= slaDf and perPacketLoss <= slaMlr:	
                            self.slaCountDict[self.flowTypeDict[flw][0]] += 1
                            IOAloadDict['sla'] = True                        
                            if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['MLR:DF','%s:%s msecs' %(slaMlr,slaDf),'%s:%s msecs' %(perPacketLoss,df),'PASS']
                        else:
                            IOAloadDict['sla'] = False   
                            self.slaReqMetForTrail = False                     
                            if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['MLR:DF','%s:%s msecs' %(slaMlr,slaDf),'%s:%s msecs' %(perPacketLoss,df),'FAIL']
                    else:
                        if df <= slaDf and perPacketLoss <= slaMlr:	
                            self.slaCountDict[self.flowTypeDict[flw][0]] = 1 
                            IOAloadDict['sla'] = True                        
                            if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['MLR:DF','%s:%s msecs' %(slaMlr,slaDf),'%s:%s msecs' %(perPacketLoss,df),'PASS'] 
                        else:
                            self.slaCountDict[self.flowTypeDict[flw][0]] = 0 
                            IOAloadDict['sla'] = False 
                            self.slaReqMetForTrail = False
                            if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['MLR:DF','%s:%s msecs' %(slaMlr,slaDf),'%s:%s msecs' %(perPacketLoss,df),'FAIL']
                
                if self.flowTypeDict[flw][0] == "RTPAudio":
                    self.rtpAudioFrateList.append(frateKbps)
                    self.rtpAudioJitterList.append(jitter)
                    self.rtpAudioLatencyList.append(avgLatency)
                    self.rtpAudioPacketLossList.append(perPacketLoss)
                    self.rtpAudioOloadList.append(OfferedLoadKbps)       
                    self.rtpAudioIloadList.append(iLoadVal)                 
                
                    self.rtpAudioAloadList.append(frateKbps)
                    self.rtpAudioProfList.append(flw)
                    
                    self.rtpAudioDiagList.append(self.flowTypeDict[flw][10])
                
                              
                    if self.flowTypeDict[flw][0] in self.slaCountDict.keys():
                        if avgLatency <= slaLatval and jitter <= slaJitval and perPacketLoss <= slaPlval:	
                            self.slaCountDict[self.flowTypeDict[flw][0]] += 1
                            IOAloadDict['sla'] = True
                            if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['Latency:Jitter:Packet Loss','%s msecs:%s msecs:%s' %(slaLatval,slaJitval,slaPlval),'%s msecs:%s msecs:%s' %(avgLatency,jitter,perPacketLoss),'PASS']
                        else:
                            IOAloadDict['sla'] = False   
                            self.slaReqMetForTrail = False  
                            if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['Latency:Jitter:Packet Loss','%s msecs:%s msecs:%s' %(slaLatval,slaJitval,slaPlval),'%s msecs:%s msecs:%s' %(avgLatency,jitter,perPacketLoss),'FAIL']
                    else:
                        if avgLatency <= slaLatval and jitter <= slaJitval and perPacketLoss <= slaPlval:	
                            self.slaCountDict[self.flowTypeDict[flw][0]] = 1 
                            IOAloadDict['sla'] = True
                            if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['Latency:Jitter:Packet Loss','%s msecs:%s msecs:%s' %(slaLatval,slaJitval,slaPlval),'%s msecs:%s msecs:%s' %(avgLatency,jitter,perPacketLoss),'PASS']
                        else:
                            self.slaCountDict[self.flowTypeDict[flw][0]] = 0 
                            IOAloadDict['sla'] = False 
                            self.slaReqMetForTrail = False    
                            if self.UserPassFailCriteria['User']=='True':
                                self.TestResult[flw][self.flowTypeDict[flw][0]]=['Latency:Jitter:Packet Loss','%s msecs:%s msecs:%s' %(slaLatval,slaJitval,slaPlval),'%s msecs:%s msecs:%s' %(avgLatency,jitter,perPacketLoss),'FAIL']
                
                IOAloadDict['iload'] = iLoadVal
                IOAloadDict['oload'] = OfferedLoadKbps
                IOAloadDict['aload'] = frateKbps
                
               
                self.IOAloadPerFlowDict[flw] = IOAloadDict                
                
                self.Print("\r%s : ILOAD = %0.3f OLOAD = %d kbps, MDI Score = %0.2f:%0.2f JITTER = %0.2f FWD RATE = %d kbps, AVG LATENCY = %0.3f msecs, SlaDf = %d, slaMLR = %d, slaMet = %s \n" % (flw, iLoadVal, OfferedLoadKbps, df, perPacketLoss, jitter, frateKbps, avgLatency, slaDf, slaMlr, bool(IOAloadDict['sla'])))  
                self.flowResultsDict[flw] = flowTypeResDict    
        
        
        WaveEngine.WriteDetailedLog(['Flow Name', 'src_port', 'des_port', 'txFlowFramesOk', 'rxFlowFramesOk'])    
        for flw in self.flowTypeDict.keys():
            srcPort = self.flowTypeDict[flw][1]
            dstPort = self.flowTypeDict[flw][2]	             
            WaveEngine.VCLtest("flowStats.read('%s','%s')" % (srcPort, flw))
            TXframes = flowStats.txFlowFramesOk
            if (type(dstPort) is type([]) ) == True:
                for ii in range(0, len(dstPort)):
                    WaveEngine.VCLtest("flowStats.read('%s','%s')" % (dstPort[ii], flw))
                    RXframes = flowStats.rxFlowFramesOk            
                    WaveEngine.WriteDetailedLog([flw, srcPort, dstPort[ii], TXframes, RXframes])   	
            else:
                WaveEngine.VCLtest("flowStats.read('%s','%s')" % (dstPort, flw))
                RXframes = flowStats.rxFlowFramesOk            
                WaveEngine.WriteDetailedLog([flw, srcPort, dstPort, TXframes, RXframes])   
     
    
    def MeasureMcastFlow_DelayFactor(self, flowEntry, mode = 0):    	
    	(flowName,srcClient,srcPortName,destPorts, sla) = flowEntry    	
    	
    	tDf = 0
    	resCount = 0
    	
        for destPortName in destPorts:
            WaveEngine.VCLtest("flowStats.read('%s','%s')" % (destPortName, flowName))
            WaveEngine.VCLtest("flowStats.read('%s','%s')" % (destPortName, flowName))            
                         
            if flowStats.getRxFlowLatencyCountOverall() != 0:
                latencySum = flowStats.getRxFlowSumLatencyOverall()
                latencyCount = flowStats.getRxFlowLatencyCountOverall()
                latencymax = flowStats.getRxFlowMaxLatencyOverall()
                avgLatency = latencySum / latencyCount
                df = ((latencymax - avgLatency) / 1000000.0)  
                tDf += df
                resCount += 1
                         
        if tDf > 0 and resCount > 0:       
            return round((tDf / resCount), 2) 
        else:                
            return  -1   
        
        
    def MeasureFlow_DelayFactor(self, flowName, portName, mode = 0):
    	
        ### Use math in RFC 4445 
        WaveEngine.VCLtest("flowStats.read('%s','%s')" % (portName, flowName))
        latencySum = flowStats.getRxFlowSumLatencyOverall()
        latencyCount = flowStats.getRxFlowLatencyCountOverall()
        latencymax = flowStats.getRxFlowMaxLatencyOverall()
                
        if latencyCount != 0:
            avgLatency = latencySum / latencyCount
        else:
            avgLatency = -1  
            return -1
        
        df = ((latencymax - avgLatency) / 1000000.0)  
        
        if df < 0:
            df = 0
                
        return  round(df,2)
        
           
    def MeasureMulticastFlowStats(self, flowEntry, TestDuration, mode = 0):
    	(flowName,srcClient,srcPortName,destPorts, sla) = flowEntry    
    	    	
    	WaveEngine.VCLtest("flowStats.read('%s','%s')" % (srcPortName, flowName))
        TXframes = flowStats.txFlowFramesOk
        TxOctets = flowStats.txFlowOctetsOk
        
        WaveEngine.VCLtest("flow.read('%s')" % (flowName))
        frmSize = flow.getFrameSize()        
        
        tPLoss = 0
        tFrate = 0
        tFrateKbps = 0
        tLatencySum = 0
        tLatencyCount = 0
        tJitter = 0
        
        for destPortName in destPorts:
            WaveEngine.VCLtest("flowStats.read('%s','%s')" % (destPortName, flowName))
            WaveEngine.VCLtest("flowStats.read('%s','%s')" % (destPortName, flowName))            
        
            RXframes = flowStats.rxFlowFramesOk
            RxOctets = flowStats.rxFlowOctetsOk
            
            frate = RXframes / float(TestDuration)
            
            frateKbps = (RXframes * frmSize * 8) / (float(TestDuration) * 1000.0)
            
            tFrate = tFrate + frate
            tFrateKbps = tFrateKbps + frateKbps          
            
            pLoss = TXframes - RXframes
            tPLoss = tPLoss + pLoss
            
            if flowStats.getRxFlowLatencyCountOverall() != 0:
                latencySum = flowStats.getRxFlowSumLatencyOverall()
                latencyCount = flowStats.getRxFlowLatencyCountOverall()
                tLatencySum = tLatencySum + latencySum
                tLatencyCount = tLatencyCount + latencyCount
            
            jitter = flowStats.getRxFlowSmoothedInterarrivalJitter() / 1000000.0
            tJitter = tJitter + jitter
            
                   
        avgPLoss = tPLoss / len(destPorts)
        
        if TXframes > 0:
            perLoss = ( avgPLoss * 100.0 ) / TXframes     
        else:
            perLoss = 0
                   
        if perLoss > 100:
            perLoss = 100        
        avgFrate = tFrate / len(destPorts)
        avgFrateKbps = tFrateKbps / len(destPorts)
        
        if TestDuration > 0:
            OfferedLoad = TXframes / float(TestDuration)
            OfferedLoadKbps = (TXframes * frmSize * 8) / (float(TestDuration) * 1000.0)
        else:
            OfferedLoad = 0
            OfferedLoadKbps = 0 
        
        if tLatencyCount != 0:
            avgLatency = tLatencySum / ( tLatencyCount * 1000000.0)
        else:
            avgLatency = -1    
                 
        jitter = tJitter / len(destPorts)
        
        return (round(OfferedLoad,2), round(avgFrate,2), round(perLoss,2), round(OfferedLoadKbps,2), round(avgFrateKbps,2), round(avgLatency,2), round(jitter,2))
    
    
    
    def getRealTimeRoamDelayStats(self, roamNum, md):
        
        if md == -1:
            return
        for flw in self.flowTypeDict:            
            if self.flowTypeDict[flw][9] in ["waSrcFlow", "waSinkFlow", "waloopFlow"]:
                if flw not in self.waveAgentRoamingDelayStats:
                    self.waveAgentRoamingDelayStats[flw] = []
                (waTxFrames, waTxOctets, waRxFrames, waRxOctets, roamDelay) = self.generateWaveAgentStats(flw, self.flowTypeDict[flw][1], roamNum)
                self.waveAgentRoamingDelayStats[flw].append(roamDelay/1000.0)                                   
                self.resetWaveAgentStatsFlow(flw)
                
                rNums = [str((int(val)+1)) for val in range(0, len(self.waveAgentRoamingDelayStats[flw]))]
                cTitle = "Roaming Delay Chart for " + flw
                roamGraph = Qlib.GenericGraph(rNums, "Roam Number", [self.waveAgentRoamingDelayStats[flw],] ,"Roaming Delay (secs)", cTitle, ['Line'])
                self.finalGraphs['Roaming Delay for WaveAgent Flow']= roamGraph
                
                WaveEngine.OutputstreamHDL("Roaming Delay for roam # %d is %f secs\n" % (roamNum, roamDelay/1000.0), WaveEngine.MSG_SUCCESS)   
        
        
    
    def MeasureFlow_WaveAgent_udp_Metrics(self, flowName, srcPortName, destPortName, waDir, TestDuration, mode = 0):
    	
    	(waTxFrames, waTxOctets, waRxFrames, waRxOctets, waMaxIpg) = self.generateWaveAgentStats(flowName, srcPortName, 0)    	
    	     	
        #WaveEngine.WriteDetailedLog(['Flow Name', 'src_port', 'des_port', 'txFlowFramesOk', 'rxFlowFramesOk'])
        if 'txFrames' not in self.flowOldResults[flowName]:
            self.flowOldResults[flowName]['txFrames'] = 0
        
        if 'rxFrames' not in self.flowOldResults[flowName]:
            self.flowOldResults[flowName]['rxFrames'] = 0
        
        if 'txOctets' not in self.flowOldResults[flowName]:
            self.flowOldResults[flowName]['txOctets'] = 0           	
        
        if 'rxOctets' not in self.flowOldResults[flowName]:
            self.flowOldResults[flowName]['rxOctets'] = 0
        
        WaveEngine.VCLtest("flow.read('%s')" % (flowName))
        frmSize = flow.getFrameSize()
        
        if mode == 1:      
        
            if waDir == "waSrcFlow":
            	currTxFrames = waTxFrames
                currTxOctects = waTxOctets
            else:    
                WaveEngine.VCLtest("flowStats.read('%s','%s')" % (srcPortName, flowName))            
                currTxFrames = flowStats.txFlowFramesOk
                currTxOctects = flowStats.txFlowOctetsOk
            
            TXframes = (currTxFrames - self.flowOldResults[flowName]['txFrames'])            
            TxOctets = (currTxOctects - self.flowOldResults[flowName]['txOctets'])
            
            if waDir == "waSinkFlow":
                currRxFrames = waRxFrames
                currRxOctets = waRxOctets
            else:    
                WaveEngine.VCLtest("flowStats.read('%s','%s')" % (destPortName, flowName))
                currRxFrames = flowStats.rxFlowFramesOk
                currRxOctets = flowStats.rxFlowOctetsOk
            
            
            RXframes = ( currRxFrames - self.flowOldResults[flowName]['rxFrames'])            
            RxOctets = ( currRxOctets - self.flowOldResults[flowName]['rxOctets'])        
        
            self.flowStartTimes[flowName] = time.time()
            self.flowOldResults[flowName]['txFrames'] = currTxFrames
            self.flowOldResults[flowName]['rxFrames'] = currRxFrames
            self.flowOldResults[flowName]['txOctets'] = currTxOctects           	
            self.flowOldResults[flowName]['rxOctets'] = currRxOctets 
        else:            
        
            if waDir == "waSrcFlow":
            	TXframes = waTxFrames
                TxOctets = waTxOctets
            else:	
                WaveEngine.VCLtest("flowStats.read('%s','%s')" % (srcPortName, flowName))            
                TXframes = flowStats.txFlowFramesOk
                TxOctets = flowStats.txFlowOctetsOk
            
            if waDir == "waSinkFlow":
                RXframes = waRxFrames
                RxOctets = waRxOctets
            else:
                WaveEngine.VCLtest("flowStats.read('%s','%s')" % (destPortName, flowName))
                RXframes = flowStats.rxFlowFramesOk
                RxOctets = flowStats.rxFlowOctetsOk
                
        #print "TX stats..", TXframes, TxOctets  
        #print "RX stats..", RXframes, RxOctets         
            
        if TestDuration > 0:        
            OfferedLoad = TXframes / float(TestDuration)
            OfferedLoadKbps = (TXframes * frmSize * 8) / (float(TestDuration) * 1000.0)
            frate = RXframes / float(TestDuration)
            frateKbps = (RXframes * frmSize * 8) / (float(TestDuration) * 1000.0)
        else:
            OfferedLoad = 0
            OfferedLoadKbps = 0
            frate = 0
            frateKbps = 0 
        
        flowType = 'flow'
        WaveEngine.VCLtest("%s.read('%s')" % (flowType, flowName), globals())
        intendedRate = flow.getIntendedRate()
        #txLoss = (intendedRate*TestDuration) - TXframes
        txLoss = 0
        if txLoss < 0:
            txLoss = 0
        lossOnChannel = (TXframes - RXframes)
        if lossOnChannel < 0:
            lossOnChannel = 0
        
        if TXframes == 0:
            perTotalLoss = 0.0
        else:            
            perTotalLoss = ( (txLoss + lossOnChannel) * 100.0 )/ TXframes
            
        if perTotalLoss > 100:
            perTotalLoss = 100        
        #WaveEngine.WriteDetailedLog([flowName, srcPortName, destPortName, TXframes, RXframes])       
        
        
        Jitter = round(flowStats.getRxFlowSmoothedInterarrivalJitter() / 1000000.0, 2)
                         
        return (round(OfferedLoad,2), round(frate,2), round(perTotalLoss,2), round(OfferedLoadKbps,2), round(frateKbps,2), 0.0, Jitter)
    
       
    	
        
    def MeasureFlow_OLOAD_FR_LossRate(self, flowName, srcPortName, destPortName, TestDuration, mode = 0):
    	
    	#WaveEngine.WriteDetailedLog(['Flow Name', 'src_port', 'des_port', 'txFlowFramesOk', 'rxFlowFramesOk'])
        if 'txFrames' not in self.flowOldResults[flowName]:
            self.flowOldResults[flowName]['txFrames'] = 0
        
        if 'rxFrames' not in self.flowOldResults[flowName]:
            self.flowOldResults[flowName]['rxFrames'] = 0
        
        if 'txOctets' not in self.flowOldResults[flowName]:
            self.flowOldResults[flowName]['txOctets'] = 0           	
        
        if 'rxOctets' not in self.flowOldResults[flowName]:
            self.flowOldResults[flowName]['rxOctets'] = 0
        
        WaveEngine.VCLtest("flow.read('%s')" % (flowName))
        frmSize = flow.getFrameSize()
        
        if mode == 1:      
            WaveEngine.VCLtest("flowStats.read('%s','%s')" % (srcPortName, flowName))
            currTxFrames = flowStats.txFlowFramesOk
            TXframes = (currTxFrames - self.flowOldResults[flowName]['txFrames'])
            currTxOctects = flowStats.txFlowOctetsOk
            TxOctets = (currTxOctects - self.flowOldResults[flowName]['txOctets'])
            WaveEngine.VCLtest("flowStats.read('%s','%s')" % (destPortName, flowName))
            currRxFrames = flowStats.rxFlowFramesOk
            RXframes = ( currRxFrames - self.flowOldResults[flowName]['rxFrames'])
            currRxOctets = flowStats.rxFlowOctetsOk
            RxOctets = ( currRxOctets - self.flowOldResults[flowName]['rxOctets'])        
        
            self.flowStartTimes[flowName] = time.time()
            self.flowOldResults[flowName]['txFrames'] = currTxFrames
            self.flowOldResults[flowName]['rxFrames'] = currRxFrames
            self.flowOldResults[flowName]['txOctets'] = currTxOctects           	
            self.flowOldResults[flowName]['rxOctets'] = currRxOctets 
        else:            
            WaveEngine.VCLtest("flowStats.read('%s','%s')" % (srcPortName, flowName))
            
            TXframes = flowStats.txFlowFramesOk
            TxOctets = flowStats.txFlowOctetsOk
            
            WaveEngine.VCLtest("flowStats.read('%s','%s')" % (destPortName, flowName))
            RXframes = flowStats.rxFlowFramesOk
            RxOctets = flowStats.rxFlowOctetsOk
            
        if TestDuration > 0:        
            OfferedLoad = TXframes / float(TestDuration)
            OfferedLoadKbps = (TXframes * frmSize * 8) / (float(TestDuration) * 1000.0)
            frate = RXframes / float(TestDuration)
            frateKbps = (RXframes * frmSize * 8) / (float(TestDuration) * 1000.0)
        else:
            OfferedLoad = 0
            OfferedLoadKbps = 0
            frate = 0
            frateKbps = 0 
        
        flowType = 'flow'
        WaveEngine.VCLtest("%s.read('%s')" % (flowType, flowName), globals())
        intendedRate = flow.getIntendedRate()
        #txLoss = (intendedRate*TestDuration) - TXframes
        txLoss = 0
        if txLoss < 0:
            txLoss = 0
        lossOnChannel = (TXframes - RXframes)
        if lossOnChannel < 0:
            lossOnChannel = 0
        
        if TXframes == 0:
            perTotalLoss = 0.0
        else:            
            perTotalLoss = ( (txLoss + lossOnChannel) * 100.0 )/ TXframes
            
        if perTotalLoss > 100:
            perTotalLoss = 100        
        #WaveEngine.WriteDetailedLog([flowName, srcPortName, destPortName, TXframes, RXframes])       
        #print "\nFlow Name : %s, src_port : %s, des_port: %s, txFlowFramesOk: %d, rxFlowFramesOk: %d" % (flowName, srcPortName, destPortName, TXframes, RXframes)
                         
        return (round(OfferedLoad,2), round(frate,2), round(perTotalLoss,2), round(OfferedLoadKbps,2), round(frateKbps,2))
        
   
    def MeasureFlow_Jitter_Lossburst(self, flowName, portName):
    	
        WaveEngine.VCLtest("flowStats.read('%s','%s')" % (portName, flowName))
        WaveEngine.VCLtest("flowStats.read('%s','%s')" % (portName, flowName))
        
        jitter = flowStats.getRxFlowSmoothedInterarrivalJitter() / 1000000.0
        loss2 = flowStats.getRxFlow2PacketLossNumber()
        loss3 = flowStats.getRxFlow3PacketLossNumber()
        loss4 = flowStats.getRxFlow4PacketLossNumber()
        loss5 = flowStats.getRxFlow5PacketLossNumber()
        loss1 = ( flowStats.getRxFlowOutOfSequenceFrames() - (loss2 +loss3 + loss4 +loss5) )
        
        return (round(jitter,2), loss1, loss2, loss3, loss4, loss5)

    
    def MeasureFlow_Latency(self, flowName, portName, mode = 0):
    	
        WaveEngine.VCLtest("flowStats.read('%s','%s')" % (portName, flowName))
        WaveEngine.VCLtest("flowStats.read('%s','%s')" % (portName, flowName))
        
        if 'latencySum' not in self.flowOldResults[flowName]:
            self.flowOldResults[flowName]['latencySum'] = 0
        
        if 'latencyCount' not in self.flowOldResults[flowName]:
            self.flowOldResults[flowName]['latencyCount'] = 0        
        
        if flowStats.getRxFlowLatencyCountOverall() != 0:
        
            if mode == 1:            
                currLatSum = flowStats.getRxFlowSumLatencyOverall()
                currLatCount = flowStats.getRxFlowLatencyCountOverall()
                latSum = currLatSum - self.flowOldResults[flowName]['latencySum']
                latCount = currLatCount - self.flowOldResults[flowName]['latencyCount']
            
                self.flowOldResults[flowName]['latencySum'] = currLatSum
                self.flowOldResults[flowName]['latencyCount'] = currLatCount   
            else:
                latSum = flowStats.getRxFlowSumLatencyOverall()
                latCount = flowStats.getRxFlowLatencyCountOverall()
                
            
            if latCount > 0:
                avgLatency = latSum/latCount
                avgLatency = avgLatency / 1000000.0
            else:
                avgLatency = 0    
        else:
            avgLatency = 0    
        
           
            
        return round(avgLatency, 2)
    
    
    def Measure_rvalue(self, flowName, portName, duration, mode = 0):
        rvalue = 0.0
        
        WaveEngine.VCLtest("flowStats.read('%s','%s')" % (portName, flowName))
        if mode == 0:
            rvalue = flowStats.calcCumulativeRValue(flowName, duration, 0, 0)
        else:    
            rvalue = flowStats.calcInterimRValue(flowName, duration, 0, 0)   
            self.flowStartTimes[flowName] = time.time()             
        if rvalue < 0: 
            return 0         
        rVal = round(rvalue,2)
        
        return rVal        
    
    
    def MeasureFlow_OLOAD_Goodput_LossRate(self, Flowname, flowParams, MSegSize, TestDuration, mode = 0):
    	
    	if 'txFrames' not in self.flowOldResults[Flowname]:
            self.flowOldResults[Flowname]['txFrames'] = 0
        
        if 'rxFrames' not in self.flowOldResults[Flowname]:
            self.flowOldResults[Flowname]['rxFrames'] = 0
        
        if 'txOctets' not in self.flowOldResults[Flowname]:
            self.flowOldResults[Flowname]['txOctets'] = 0           	
        
        if 'rxOctets' not in self.flowOldResults[Flowname]:
            self.flowOldResults[Flowname]['rxOctets'] = 0
            
        if 'txTcpOctets' not in self.flowOldResults[Flowname]:
            self.flowOldResults[Flowname]['txTcpOctets'] = 0
        
        WaveEngine.VCLtest("biflow.read('%s')" % (Flowname))
        frmSize = biflow.getFrameSize()
                
        (src_port, src_client, des_port, des_client) = flowParams
                
        if mode == 1:
            WaveEngine.VCLtest("flowStats.read('%s','%s')" % (src_port, Flowname))      
        
            currTxFrames = flowStats.txFlowFramesOk
            TXframes = (currTxFrames - self.flowOldResults[Flowname]['txFrames'])
            currTxOctects = flowStats.txFlowOctetsOk
            TXoctets = (currTxOctects - self.flowOldResults[Flowname]['txOctets'])
        
            biflow.checkStatus(Flowname)  
        
            currTxTcpOct = long(biflow.get("Total TCP Bytes TX"))  
            TxTcpOct = (currTxTcpOct - self.flowOldResults[Flowname]['txTcpOctets'])        
        
            unAckedSegments = int(biflow.get("Unacknowledged Segments"))
            MSS             = int(biflow.get("MSS"))
            if MSS == 0:
                MSS = MSegSize
            TxTcpPkts      = TxTcpOct / MSS
            WaveEngine.VCLtest("flowStats.read('%s','%s')" % (des_port, Flowname))
        
            currRxFrames = flowStats.rxFlowFramesOk
            RXframes = ( currRxFrames - self.flowOldResults[Flowname]['rxFrames'])
            currRxOctets = flowStats.rxFlowOctetsOk
            RXoctets = ( currRxOctets - self.flowOldResults[Flowname]['rxOctets'])
                
            OutOfSequence  = flowStats.rxFlowOutOfSequenceFrames
            
            self.flowStartTimes[Flowname] = time.time()
            self.flowOldResults[Flowname]['txFrames'] = currTxFrames
            self.flowOldResults[Flowname]['rxFrames'] = currRxFrames
            self.flowOldResults[Flowname]['txOctets'] = currTxOctects           	
            self.flowOldResults[Flowname]['rxOctets'] = currRxOctets  
            self.flowOldResults[Flowname]['txTcpOctets'] = currTxTcpOct
        else:              
            WaveEngine.VCLtest("flowStats.read('%s','%s')" % (src_port, Flowname))      
        
            TXframes = flowStats.txFlowFramesOk
            TXoctets = flowStats.txFlowOctetsOk
            
            biflow.checkStatus(Flowname)  
        
            TxTcpOct = long(biflow.get("Total TCP Bytes TX"))              
        
            unAckedSegments = int(biflow.get("Unacknowledged Segments"))
            MSS             = int(biflow.get("MSS"))
            if MSS == 0:
                MSS = MSegSize
            TxTcpPkts      = TxTcpOct / MSS
            WaveEngine.VCLtest("flowStats.read('%s','%s')" % (des_port, Flowname))
        
            RXframes = flowStats.rxFlowFramesOk
            RXoctets = flowStats.rxFlowOctetsOk
            
            OutOfSequence  = flowStats.rxFlowOutOfSequenceFrames        
            
                
        if TXframes > 0:
            FrameLossRate = 100.0 * (TXframes - RXframes) / TXframes
        else:
            FrameLossRate = 0.0
            #WaveEngine.OutputstreamHDL("\nWarning: No frames were transmitted; Frame Loss Rate is invalid.\n", WaveEngine.MSG_WARNING)
        #if RXframes == 0:
        #    WaveEngine.OutputstreamHDL("\nWarning: No frames were received; Forwarding Rate is zero.\n", WaveEngine.MSG_WARNING)
        
        if TestDuration > 0:        
            OLOAD = round(TXframes * frmSize * 8 / float(TestDuration), 2)
            ALOAD = round(RXframes * frmSize * 8 / float(TestDuration), 2)                
            goodput_BPS = round(TxTcpOct * 8 / float(TestDuration), 2)
        else:
            OLOAD = 0
            ALOAD = 0             
            goodput_BPS = 0  
        
        
        totalBytes = round(TxTcpOct, 2)
        if FrameLossRate <= 100:
            FrameLossRate = round(FrameLossRate, 2)
        else:
            FrameLossRate = 100    
        
        return (OLOAD, ALOAD, goodput_BPS, totalBytes, FrameLossRate, unAckedSegments)     
        
           
    def initReport(self):
    	self.MyReport = WaveReport(os.path.join(self.LoggingDirectory, self.ReportFilename))
        if self.MyReport.Story == None:
            return
        if self.testType == "WiMix":    
            reportTitle = self.testProfileList[0] + " WiMiX Report"
        else:
            reportTitle = self.testName + "\n" + self.testType + " Report"     
        self.MyReport.Title(reportTitle, self.DUTinfo)
        
    def mma(self, dList):
    	minVal = 100000000.0
    	maxVal = 0.0
    	avgVal = 0.0
    	
    	if len(dList) == 0:
    	    return 0    	
    	for val in dList:
    	    if val < minVal:
    	        minVal = val
    	    if val > maxVal:
    	        maxVal = val
    	    avgVal = avgVal + val        
        avgVal = avgVal / len(dList)
        
        #retVal = str(round(minVal,1)) + "," + str(round(maxVal,1)) + "," + str(round(avgVal,1)) 
        retVal = round(avgVal,2)
        return retVal
        
    def sumList(self, sumLst):    	
    	if len(sumLst) == 0:
    	    return 0
        lSum = 0
        for val in sumLst:
            lSum = lSum + val
        return lSum
    
    
    def getPieChartObject(self, chartDict1, chartDict2, chartDict3, tIload, tOload, tAload):
        d = Drawing(200, 150)
        
        pc1 = Pie()
        pc1.x = 0
        pc1.y = 25
        pc1.width = 100
        pc1.height = 80
        pc1.data = chartDict1.values()
        pc1.labels = chartDict1.keys()
        
        ii = 0
        for ii in range(0, len(chartDict1.keys())):
            pc1.slices[ii].popout = 5
            pc1.slices[ii].strokeWidth = 1
            pc1.slices[ii].labelRadius = 1.25
            pc1.slices[ii].fillColor = Qlib.colorList[ii]
                        
        d.add(pc1)
        
        
        pc2 = Pie()
        pc2.x = 170
        pc2.y = 25
        pc2.width = 100
        pc2.height = 80
        pc2.data = chartDict2.values()
        pc2.labels = chartDict2.keys()
         
        ii = 0
        for ii in range(0, len(chartDict2.keys())):
            pc2.slices[ii].popout = 5
            pc2.slices[ii].strokeWidth = 1
            pc2.slices[ii].labelRadius = 1.25
            pc2.slices[ii].fillColor = Qlib.colorList[ii]

            
        d.add(pc2)
        
        
        pc3 = Pie()
        pc3.x = 350
        pc3.y = 25
        pc3.width = 100
        pc3.height = 80
        pc3.data = chartDict3.values()
        pc3.labels = chartDict3.keys()
         
        ii = 0
        for ii in range(0, len(chartDict3.keys())):
            pc3.slices[ii].popout = 5
            pc3.slices[ii].strokeWidth = 1
            pc3.slices[ii].labelRadius = 1.25
            pc3.slices[ii].fillColor = Qlib.colorList[ii]

            
        d.add(pc3)
                
        lab1 = Label()
        lab1.setOrigin(50,0)
        lab1.setText("iLoad (Total %0.2f Mbps)" % round((tIload / 1000.0),2))
        
        lab2 = Label()
        lab2.setOrigin(220,0)
        lab2.setText("oLoad (Total %0.2f Mbps)" % round((tOload / 1000.0),2))
        
        lab3 = Label()
        lab3.setOrigin(390,0)
        lab3.setText("Achieved Load (Total %0.2f Mbps)" % round((tAload / 1000.0),2))
        
        d.add(lab1)
        d.add(lab2)
        d.add(lab3)
        
        return d
    
    def getCharts( self ):
        """
        Returns dictionary of all chart objects supported by this test.
        """
        return self.finalGraphs
        
    def getOverTimeCharts( self, flwNameList, metricName, resetFlag ):     
    	
    	if len(flwNameList) == 0: 
    	    return (-1, True) 
        
        for flwItm in flwNameList:
            if flwItm not in self.startedFlowsList:
                if flwItm not in ["All Flows", "Min/Max/Avg of All Flows"]:
                    return (-1, True)
        	
    	if metricName == "":
    	    return (-1, True)	   
    	            	
    	if metricName in ["Goodput", "Forwarding Rate"]:
    	    metricUnits = " (Kbps)"
    	elif metricName in ["Latency", "Jitter", "Delay Factor"]:
    	    metricUnits = " (msecs)"
    	elif metricName in ["Packet Loss", "Media Loss Ratio"]:
    	    metricUnits = " (%)"
    	else:
    	    metricUnits = ""    	    	    
    	
    	addLegend = False
    	legendList = []	
    	if self.overTimeResultType == 1:    
    	    flwName = flwNameList[0]	
    	    if self.trafficFlowsStarted != True:
    	        return (-1, False)  
    	        
    	    if resetFlag:
    	        self.realTimeChartXData = []
    	        self.realTimeChartYData = []
    	        self.resultSampleTimeVal = 0   	
    	       	       	
            self.realTimeChartXData.append(self.resultSampleTimeVal) 
            self.resultSampleTimeVal += self.resultSampleTime      
               	
    	    self.getIntermediateFlowStats(flwName, metricName)   	
    	    cTitle = metricName + metricUnits + " for " + flwName
    	    ylab = metricName + metricUnits
    	    
    	    if len(self.realTimeChartXData) > 10:
    	        n = len(self.realTimeChartXData)
    	        self.realTimeChartXData = self.realTimeChartXData[(n-10):n]
    	    	self.realTimeChartYData = self.realTimeChartYData[(n-10):n]
    	    
    	    chart_obj = Qlib.GenericGraph(self.realTimeChartXData, "Time(secs)", [self.realTimeChartYData,] ,ylab, cTitle, ['Line'])
    	    return (chart_obj, self.trafficFlowsStarted)
    	else:    	    
    	    if self.trafficFlowsEnded != True: 
    	        return (-1, True) 
    	    else:
    	        overTimeChartXData = []
    	        overTimeChartYDataList = []    	        
    	            	        
    	        if ("All Flows" in flwNameList) or ("Min/Max/Avg of All Flows" in flwNameList):
    	            flwName = "All Flows"
    	            for jj in range(0, (len(flwNameList) - 1)):
    	            	overTimeChartYDataList.append(self.overTimeFlowResults[flwNameList[jj]][metricName])   	            	          	      
    	            if "Min/Max/Avg of All Flows" in flwNameList:
    	                flwName = "Min/Max/Avg of All Flows"
    	                overTimeChartYDataList = self.minMaxAvgYValsList(overTimeChartYDataList)    
    	                addLegend = True	
    	                legendList = [["Min"],["Max"],["Avg"]]   
    	            elif "All Flows" in flwNameList: 
    	                addLegend = True	
    	                legendList = [] 
    	                for itm in flwNameList:
    	                    if itm not in ["All Flows", "Min/Max/Avg of All Flows"]:
    	                        lList = []
    	                        lList.append(itm)
    	                        legendList.append(lList)  
    	        else:
    	            flwName = flwNameList[0]
    	            overTimeChartYDataList = [self.overTimeFlowResults[flwName][metricName],]
    	        
    	        overTimeResultSampleTimeVal = 0  
    	            	        
    	        #for ii in range(0, len(overTimeChartYDataList[0])):	
    	        #    overTimeChartXData.append(overTimeResultSampleTimeVal) 
                #    overTimeResultSampleTimeVal += self.resultSampleTime  
                #print overTimeChartYDataList                
                #for itms in range(0,len(overTimeChartYDataList)):
                #    for nn in range(0, len(overTimeChartYDataList[itms])):                    	
                #        if overTimeChartYDataList[itms][nn] < 0:
                #            del overTimeChartYDataList[itms][nn]
                #            del self.timeSampleList[itms][nn]
                        
                
    	        cTitle = metricName + metricUnits + " for " + flwName
    	        ylab = metricName + metricUnits
    	        if addLegend:
    	            chart_obj = Qlib.GenericGraph(self.timeSampleList, "Time(secs)", overTimeChartYDataList,ylab, cTitle, ['Line'], legendList)
    	        else:
    	            chart_obj = Qlib.GenericGraph(self.timeSampleList, "Time(secs)", overTimeChartYDataList,ylab, cTitle, ['Line'])
    	        return (chart_obj, True)  	        
    
    
    def mmaVals(self, dList):
    	minVal = 100000000.0
    	maxVal = 0.0
    	avgVal = 0.0
    	    	
    	if len(dList) == 0:
    	    return 0    	
    	for val in dList:
    	    if val < minVal:
    	        minVal = val
    	    if val > maxVal:
    	        maxVal = val
    	    avgVal = avgVal + val        
        avgVal = avgVal / len(dList)
        
        
        return (minVal, maxVal, avgVal)
    
    
    def minMaxAvgYValsList(self,overTimeChartYDataList):
    	minList = []
    	maxList = []
    	avgList = []
    	
    	reorgList = []
    	for ii in range(0, len(overTimeChartYDataList[0])):
    	    intList = []	
    	    for jj in range(0, len(overTimeChartYDataList)):
    	    	intList.append(overTimeChartYDataList[jj][ii])
    	    reorgList.append(intList)	
    	
    	for lItems in reorgList:
    	    (minVal, maxVal, avgVal) = self.mmaVals(lItems)
    	    minList.append(minVal)    
    	    maxList.append(maxVal) 
    	    avgList.append(avgVal) 		
    	
    	return (minList, maxList, avgList)
    
    
    def setFlowDictFromFile(self,overTimeFlowResults):
    	self.overTimeFlowResults = overTimeFlowResults
   
            
    def getOptionsForSelectType(self, clssName):
    	optList = []
    	if len(self.flowTypeDict.keys()) == 0:
    	    return []
        
        if clssName == "Flow Type":
            for flw in self.flowTypeDict:
                if self.flowTypeDict[flw][0] not in optList:
                    optList.append(self.flowTypeDict[flw][0]) 
                    	
        elif clssName == "Flow Direction":
            for flw in self.flowTypeDict:
                if self.flowTypeDict[flw][10][5] not in optList:
                    optList.append(self.flowTypeDict[flw][10][5]) 	
        	
        elif clssName == "Src IP":
            for flw in self.flowTypeDict:
                (srcIp, destIp) = self.flowTypeDict[flw][10][1].split(" to ")
                if srcIp not in optList:
                    optList.append(srcIp) 
                    	
        elif clssName == "Dest IP":	
            for flw in self.flowTypeDict:
                (srcIp, destIp) = self.flowTypeDict[flw][10][1].split(" to ")
                if destIp not in optList:
                    optList.append(destIp) 
                    	
        elif clssName == "SSID":	
            for flw in self.flowTypeDict:
                (ssid, bssid) = self.flowTypeDict[flw][10][4].split(", ")   
                if ssid not in optList:
                    optList.append(ssid) 	
        	
        elif clssName == "BSSID":
            for flw in self.flowTypeDict:
                (ssid, bssid) = self.flowTypeDict[flw][10][4].split(", ")   
                if bssid not in optList:
                    optList.append(bssid) 
                    	
        elif clssName == "Src vwPort":	
            for flw in self.flowTypeDict:
                (srcPort, destPort) = self.flowTypeDict[flw][10][3].split(" to ")    
                if srcPort not in optList:
                    optList.append(srcPort)  	
        	
        elif clssName == "Dest vwPort":
            for flw in self.flowTypeDict:
                (srcPort, destPort) = self.flowTypeDict[flw][10][3].split(" to ")    
                if destPort not in optList:
                    optList.append(destPort) 	
                    
        return optList
    
   
    def getFlowsForOptions(self, clssName, optName):  
    	
    	flwList = []
    	
    	if len(self.flowTypeDict.keys()) == 0:
    	    return []
        
        if clssName == "Flow Type":
            for flw in self.flowTypeDict:
                if self.flowTypeDict[flw][0] == optName:
                    flwList.append(flw) 
                    
            if len(flwList) > 1:
                if len(flwList) <= 20 and self.overTimeResultType == 0:
                    flwList.append("All Flows")
            
                if self.overTimeResultType == 0:
                    flwList.append("Min/Max/Avg of All Flows")     
                    
                    	
        elif clssName == "Flow Direction":
            for flw in self.flowTypeDict:
                if self.flowTypeDict[flw][10][5] == optName:
                    flwList.append(flw) 	
        	
        elif clssName == "Src IP":
            for flw in self.flowTypeDict:
                (srcIp, destIp) = self.flowTypeDict[flw][10][1].split(" to ")
                if srcIp == optName:
                    flwList.append(flw) 
                    	
        elif clssName == "Dest IP":	
            for flw in self.flowTypeDict:
                (srcIp, destIp) = self.flowTypeDict[flw][10][1].split(" to ")
                if destIp == optName:
                    flwList.append(flw) 
                    	
        elif clssName == "SSID":	
            for flw in self.flowTypeDict:
                (ssid, bssid) = self.flowTypeDict[flw][10][4].split(", ")   
                if ssid == optName:
                    flwList.append(flw) 	
        	
        elif clssName == "BSSID":
            for flw in self.flowTypeDict:
                (ssid, bssid) = self.flowTypeDict[flw][10][4].split(", ")   
                if bssid == optName:
                    flwList.append(flw) 
                    	
        elif clssName == "Src vwPort":	
            for flw in self.flowTypeDict:
                (srcPort, destPort) = self.flowTypeDict[flw][10][3].split(" to ")    
                if srcPort == optName:
                    flwList.append(flw) 
        	
        elif clssName == "Dest vwPort":
            for flw in self.flowTypeDict:
                (srcPort, destPort) = self.flowTypeDict[flw][10][3].split(" to ")    
                if destPort == optName:
                    flwList.append(flw) 
           
        return flwList
    	
        
    def getOverTimeChartsData( self):    	
    	return self.overTimeResultsDict    	
    
    
    def runClientAnalysis(self, clientAnalysisStore, logDir, processType):
    	self.clientAnalysisStore = clientAnalysisStore
    	self.LoggingDirectory = logDir
    	self.waveClientPostAnalysis(processType, logDir)  
    	
    	if processType == 1:    	
    	    self.testName = ""
            self.testType = "WaveClient"
            self.ReportFilename = "Report_WaveClient_Result_Archive.pdf"    
    	    
        self.LoggingDirectory = logDir       
    	
    	self.initReport()      	
    	if self.printReport(processType) == -1:
            raise WaveEngine.RaiseException
        
        rptPath = os.path.join( logDir, self.ReportFilename)
        os.startfile( rptPath )
    
    def waveClientPostAnalysis(self, processType, logDir):
    	
    	clientAnlysStartTime = time.time()
    	self.waveClientResultsDict = odict.OrderedDict()
    	self.waveClientRoamDict = odict.OrderedDict()
    	
    	portLogFileMap = WaveEngine._portToLogFileNameMap
    	    	
    	if len(self.clientAnalysisStore['clientFlowList'].keys()) != 0:   	
    	    WaveEngine.OutputstreamHDL("\nBegin Client Analysis...this may take a while...please wait.", WaveEngine.MSG_OK)   
    	    clientFlowList = self.clientAnalysisStore['clientFlowList'] 
    	    logFileType = int(self.clientAnalysisStore['capMode'])
    	    for prt in portLogFileMap:
    	        if self.SavePCAPfile == True:   	        
    	            portLogFileMap[prt] = portLogFileMap[prt] + ".vwr"
    	        else:
    	            portLogFileMap[prt] = portLogFileMap[prt] + ".paf"        	            
    	else:
    	    return         
                
        for clFlow in clientFlowList:   
            clientResultsDict = {}     
            idMode = clientFlowList[clFlow]['idMode']
            srcNode = clientFlowList[clFlow]['srcNode'] 
            srcPort = clientFlowList[clFlow]['srcPort1']
            ap1Bssid = clientFlowList[clFlow]['ap1Bssid']
            dstNode = clientFlowList[clFlow]['dstNode']
            dstPort = clientFlowList[clFlow]['dstPort1']
            ap2Bssid = clientFlowList[clFlow]['ap2Bssid']
            metric = clientFlowList[clFlow]['metric']
            l4SrcPort = clientFlowList[clFlow]['l4SrcPort']
            l4DstPort = clientFlowList[clFlow]['l4DstPort']
            l4Protocol = clientFlowList[clFlow]['l4Protocol']
            
            if idMode == 2:
                return
            
            if srcPort in self.wifiCards + self.monWifiCards + self.igWifiCards:
            	srcType = "wlan"
            else:
                srcType = "eth"
                	
            if dstPort in self.wifiCards + self.monWifiCards + self.igWifiCards:
            	dstType = "wlan"
            else:
                dstType = "eth"
            
            if processType == 0:                
                if srcPort not in self.wifiCards + self.ethCards + self.monitorPortList + self.blogPortList:
                    WaveEngine.OutputstreamHDL("\n\nError: SRC Port : %s for client Flow %s not in the list of enabled ports in the test.\n" % (srcPort,clFlow), WaveEngine.MSG_ERROR)
                    raise WaveEngine.RaiseException
                
                if metric == "Roaming Delay":
                    if dstPort not in self.wifiCards + self.ethCards + self.monitorPortList + self.blogPortList:
                        WaveEngine.OutputstreamHDL("\n\nError: DST Port : %s for client Flow %s not in the list of enabled ports in the test.\n" % (dstPort,clFlow), WaveEngine.MSG_ERROR)
                        raise WaveEngine.RaiseException    	
                    
            
            if processType == 0:
                srcLogFile = portLogFileMap[srcPort]
                dstLogFile = portLogFileMap[dstPort]    
            else:
                srcLogFile = os.path.join( logDir, srcPort) 
                dstLogFile = os.path.join( logDir, dstPort)   
            
                
            if metric == "Forwarding Rate,Packet Loss":
            	 retVal = cap.MeasureFlow_OLOAD_FR_LossRate(idMode, srcNode, srcLogFile, srcType, dstNode, dstLogFile, dstType, self.LoggingDirectory, False)   
            	 if retVal != -1:
            	    (OLOADKbps,frateKbps, perPacketLoss) = retVal
            	    clientResultsDict['Offered Load'] = round(OLOADKbps,2)   
            	    clientResultsDict['Forwarding Rate'] = round(frateKbps,2)
            	    clientResultsDict['Percentage Packet Loss'] = round(perPacketLoss,2)
            elif metric == "Forwarding Rate,Packet Loss,Latency,Jitter": 
            	 retVal = cap.MeasureFlow_OLOAD_FR_LossRate(idMode, srcNode, srcLogFile, srcType, dstNode, dstLogFile, dstType, self.LoggingDirectory, True)	   
            	 if retVal != -1:    	          	
                    (OLOADKbps,frateKbps, perPacketLoss,latMin,latMax,latAvg,smoothJitter) = retVal
                    clientResultsDict['Offered Load'] = round(OLOADKbps,2)   
            	    clientResultsDict['Forwarding Rate'] = round(frateKbps,2) 
            	    clientResultsDict['Percentage Packet Loss'] = round(perPacketLoss,2)
            	    #clientResultsDict['Latency'] = str(round(latMin,2)) + ", " + str(round(latMax,2)) + ", " + str(round(latAvg,2))  
            	    clientResultsDict['Latency'] = round(latAvg,2)  
            	    clientResultsDict['Jitter'] = round(smoothJitter,2)            	     
            elif metric == "Roaming Delay":
                (roamDelayList, apDataRateList, apAttenList) = cap.MeasureFlow_Roaming_Stats(idMode, srcNode, l4SrcPort, srcLogFile, ap1Bssid, dstNode, l4DstPort, dstLogFile, ap2Bssid, l4Protocol, self.LoggingDirectory, self.progAttenScheduleDict)  
            	failedRoamCount = 0
            	
            	for roam in roamDelayList:
            	    if roam == -1:
            	        failedRoamCount += 1
            	        #roamDelayList.remove(roam)
            	        
            	if len(roamDelayList) != 0:	
            	    #clientResultsDict['Roaming Delay'] = str(round(min(roamDelayList),2))+ ", " + str(round( max(roamDelayList),2)) + ", " + str(round(sum(roamDelayList)* 1.0 / len(roamDelayList),2))
            	    clientResultsDict['Roaming Delay'] = round(sum(roamDelayList)* 1.0 / len(roamDelayList),2)            	    
            	    clientResultsDict['Failed Roams'] = failedRoamCount
            	    clientResultsDict['AP PHY Rates'] = apDataRateList
                    clientResultsDict['AP Atten Vals'] = apAttenList
            	    self.waveClientRoamDict[clFlow] = roamDelayList
            elif metric == "Rate Vs Range":
                (roamDelayList, apDataRateList, apAttenList) = cap.MeasureFlow_Roaming_Stats(idMode, srcNode, l4SrcPort, srcLogFile, dstNode, l4DstPort, -1, l4Protocol, self.LoggingDirectory, self.progAttenScheduleDict)
                if len(apDataRateList) > 0:
                    clientResultsDict['AP PHY Rates'] = apDataRateList
                    clientResultsDict['AP Atten Vals'] = apAttenList
            
            if len(clientResultsDict) != 0:
                self.waveClientResultsDict[clFlow] = clientResultsDict	      
            
            WaveEngine.OutputstreamHDL("\nClient Analysis took %f secs\n\n" % round((time.time() - clientAnlysStartTime), 2), WaveEngine.MSG_OK)     	    
            	                  
    	    WaveEngine.OutputstreamHDL("\n\nThank you for using VeriWave (http://www.veriwave.com)\n", WaveEngine.MSG_OK)
  
    
    def printReport(self, processType=0):  	
    	
    	self.MyReport.InsertHeader("Overview")
        
    	if self.testType == "WaveClient":
    	    testDisc = """WaveClient allows wireless device manufacturers to create the actual network eco-system surrounding the device including specific mixes of equipment, applications and traffic conditions in the lab and measure how devices will coexist, how well a system will scale, and how consistently traffic will be prioritized."""
        else:    
            testDisc = """The WiMix Real-World Deployment Test accurately replicates the complex interaction of clients, servers and traffic profiles in wireless LANs. By creating usage profiles and traffic mixtures that were found to be representative in various network environments, the test measures and reports key application layer metrics that affect end-user Quality of Experience. The test also reports if the Service Level Agreement criteria set by the user for the different application layer traffic types have been met. The real-world networks replicated include: health-care, education, airports, warehouses, retail, hot spots, and service provider managed services. Each deployment model is characterized by a mix of clients, servers, client locations and behavior, traffic mix and other characteristics. These clients and servers can be configured to use different security schemes, run various higher layer applications, and utilize different QoS functions of the network. Users may also create their own application and client mixes if so desired."""
                
        self.MyReport.InsertParagraph(testDisc)
        
        if self.brandLogoFlag:            
            self.MyReport.setCobrandingLogo(self.brandLogoFilePath)
        
        
        self.MyReport.InsertHeader("Result Summary") 
        
        ##### WaveClient summary results table ############
        self.roamingCharts = odict.OrderedDict()
        self.perRoamDownTime = {}
        for clFlw in self.waveClientResultsDict:
            if 'AP PHY Rates' in self.waveClientResultsDict[clFlw]:
                
                attTimes = []
                att1Vals = []
                att2Vals = []
                lastTime = 0
                for kys in self.attScheduleOnly:
                    attTimes.append(kys)
                    att1Vals.append(self.attScheduleOnly[kys]['att1'])
                    att2Vals.append(self.attScheduleOnly[kys]['att2'])
                    lastTime =kys
                
                    
            	fNums = []
            	ap1PhyRates = []
            	ap2PhyRates = []
                ap1AckedPhyRates = []
            	ap2AckedPhyRates = []
                for ky in self.waveClientResultsDict[clFlw]['AP PHY Rates']:
                    #if float(ky) <= lastTime:
                    fNums.append(round(ky, 0))
            	    ap1PhyRates.append(self.waveClientResultsDict[clFlw]['AP PHY Rates'][ky]['ap1'])
            	    ap2PhyRates.append(self.waveClientResultsDict[clFlw]['AP PHY Rates'][ky]['ap2'])
                    ap1AckedPhyRates.append(self.waveClientResultsDict[clFlw]['AP PHY Rates'][ky]['ap1Acked'])
                    ap2AckedPhyRates.append(self.waveClientResultsDict[clFlw]['AP PHY Rates'][ky]['ap2Acked'])
                    #print ky, self.waveClientResultsDict[clFlw]['AP PHY Rates'][ky]
                                        
                
                currVal = min(fNums) + 1
                indx = 0
                ap1AvgPhyRates = []
                ap2AvgPhyRates = []
                ap1AvgAckedPhyRates = []
                ap2AvgAckedPhyRates = []
                fNumsTime = []                
                while currVal <= max(fNums):
                    currSampleCount = 0
                    currSampleTot1 = 0
                    currSampleTot2 = 0
                    currSampleTot3 = 0
                    currSampleTot4 = 0
                    if indx < len(fNums):
                        while fNums[indx] <= currVal:
                            currSampleTot1 = currSampleTot1 + ap1PhyRates[indx]
                            currSampleTot2 = currSampleTot2 + ap2PhyRates[indx]
                            currSampleTot3 = currSampleTot3 + ap1AckedPhyRates[indx]
                            currSampleTot4 = currSampleTot4 + ap2AckedPhyRates[indx]                             
                            indx += 1
                            if indx >= len(fNums):
                                break
                            currSampleCount += 1
                            
                        if currSampleCount > 0:    
                            ap1PhyRate = currSampleTot1 / currSampleCount * 1.0
                            ap2PhyRate = currSampleTot2 / currSampleCount * 1.0
                            ap1AckPhyRate = currSampleTot3
                            ap2AckPhyRate = currSampleTot4
                        else:
                            ap1PhyRate = 0
                            ap2PhyRate = 0
                            ap1AckPhyRate = 0
                            ap2AckPhyRate = 0
                    
                        ap1AvgPhyRates.append(ap1PhyRate)
                        ap2AvgPhyRates.append(ap2PhyRate)
                        ap1AvgAckedPhyRates.append(ap1AckPhyRate)
                        ap2AvgAckedPhyRates.append(ap2AckPhyRate)                        
                    fNumsTime.append(currVal)    
                    currVal += 1
                    
                
                downTime = 0
                for ii in range(0, len(ap1AvgAckedPhyRates)):
                    if ap1AvgAckedPhyRates[ii] == 0 and ap2AvgAckedPhyRates[ii] == 0:
                        downTime += 1
                
                self.perRoamDownTime[clFlw] = downTime * 100.0 /  len(ap1AvgAckedPhyRates)
                
                graphDesc = """The graph below shows how the attenuation on AP1 and AP1 are changed over time."""    
                dataRateGraph = Qlib.GenericGraph(attTimes, "Time (secs)", [att1Vals, att2Vals] ,"Attenuation (dB)", "Attenuation on APs Vs Time", ['Line'], [['Attenuation on AP1'],['Attenuation on AP2']])
                self.roamingCharts['Attenuation Vs Time']= {'graph': dataRateGraph, 'desc' : graphDesc }
                self.finalGraphs['Attenuation Vs Time']= dataRateGraph
                
                graphDesc = """The graph show the Average PHY Data rate over time (as attenuation changes) of packets trasnmitted by the client to AP1 and AP2 in 1 sec intervals. This graph gives the user insight into the rate adaptation methodology of the client as the client roams between APs"""
                dataRateGraph = Qlib.GenericGraph(fNumsTime, "Time (secs)", [ap1AvgPhyRates,ap2AvgPhyRates] ,"PHY Data Rate (Mbps)", "Client PHY Data Rates Vs Time", ['Line'], [['Client Connected to AP1'],['Client Connected to AP2']])
                self.roamingCharts['Client PHY Data Rates Vs Time']= {'graph': dataRateGraph, 'desc' : graphDesc }
                self.finalGraphs['Client PHY Data Rates Vs Time']= dataRateGraph                            
                
                graphDesc = """The Graph below shows over time the number of packets trasnmitted by the client that were successfully ACKed by the AP in 1 sec intervals. As the attenuation increases on  AP1 and decreases on AP2, the time on this graph for which there were no ACKs seen will represent the down time of the client during the roam."""
                dataRateGraph = Qlib.GenericGraph(fNumsTime, "Time (secs)", [ap1AvgAckedPhyRates,ap2AvgAckedPhyRates] ,"Number of ACKed Frames", "ACKed Frames Vs Time", ['Bar'], [['ACKed on AP1'],['ACKed on AP2']])
                self.roamingCharts['Client ACKed Frames Vs Time']= {'graph': dataRateGraph, 'desc' : graphDesc }
                self.finalGraphs['Client ACKed Frames Vs Time']= dataRateGraph
                
                
                #self.ResultsForCSVfile.append( ("Time", "Attenuator1", "Attenuator2" ))
                #for ii in range(0, len(attTimes)):
                #    self.ResultsForCSVfile.append( ( attTimes[ii], att1Vals[ii], att2Vals[ii] ))
                        
        
        wcResSummary = [('Flow Name', 'Num Flows', ' Avg Roam Delay(secs)', ' % Down Time', 'ILOAD (Kbps)' , 'OLOAD (Kbps)', 'Fwd Rate (Kbps)', 'Avg Latency (msec)', 'Jitter (msec)', ' % Packet Loss')]
        
        for clFlw in self.waveClientResultsDict:
            
            if 'Roaming Delay' in self.waveClientResultsDict[clFlw]:
            	rDelay = self.waveClientResultsDict[clFlw]['Roaming Delay']
            else:
                rDelay = "-"
             
            if clFlw in self.perRoamDownTime:
                dTime = self.perRoamDownTime[clFlw]
            else:
                dTime = "-"
            
            if 'Intended Load' in self.waveClientResultsDict[clFlw]:
            	iLoad = self.waveClientResultsDict[clFlw]['Intended Load']
            else:
                iLoad = "-" 
            
            if 'Offered Load' in self.waveClientResultsDict[clFlw]:
            	oLoad = self.waveClientResultsDict[clFlw]['Offered Load']
            else:
                oLoad = "-" 	
                
            if 'Forwarding Rate' in self.waveClientResultsDict[clFlw]:
            	fRate = self.waveClientResultsDict[clFlw]['Forwarding Rate']
            else:
                fRate = "-" 
            
            if 'Latency' in self.waveClientResultsDict[clFlw]:
            	latency = self.waveClientResultsDict[clFlw]['Latency']
            else:
                latency = "-" 
            
            if 'Jitter' in self.waveClientResultsDict[clFlw]:
            	jitter = self.waveClientResultsDict[clFlw]['Jitter']
            else:
                jitter = "-"              
            
            if 'Percentage Packet Loss' in self.waveClientResultsDict[clFlw]:
            	pLoss = self.waveClientResultsDict[clFlw]['Percentage Packet Loss']
            else:
                pLoss = "-"         
            
            wcResSummary.append((clFlw, 1, rDelay, dTime, iLoad, oLoad, fRate, latency, jitter, pLoss))
            
                   
        if len(wcResSummary) > 1:
            for roamList in self.waveClientRoamDict:
                if len(self.waveClientRoamDict[roamList]) > 0:
                    fNums = [str((int(val)+1)) for val in range(0, len(self.waveClientRoamDict[roamList]))] 
                    roamGraph = Qlib.GenericGraph(fNums, "Roam Number", [self.waveClientRoamDict[roamList],] ,"Roaming Delay (secs)", "Roaming Delay Chart", ['Line'])
                    self.MyReport.InsertObject(roamGraph)
                    self.finalGraphs['Roaming Delay']= roamGraph
                    
            self.MyReport.InsertParagraph("The Table below shows the performance of the client Flows:") 
            self.MyReport.InsertDetailedTable(wcResSummary, columns=[0.8*inch, 0.5*inch, 0.8*inch, 0.7*inch, 0.6*inch, 0.6*inch, 0.7*inch, 0.7*inch, 0.6*inch, 0.6*inch])
        
        for itm in self.roamingCharts:
            self.MyReport.InsertParagraph(self.roamingCharts[itm]['desc'])
            self.MyReport.InsertObject(self.roamingCharts[itm]['graph'])
        
        
        for flw in self.waveAgentRoamingDelayStats:
            if len(self.waveAgentRoamingDelayStats[flw]) > 0:
                rNums = [str((int(val)+1)) for val in range(0, len(self.waveAgentRoamingDelayStats[flw]))]
                cTitle = "Roaming Delay Chart for " + flw
                roamGraph = Qlib.GenericGraph(rNums, "Roam Number", [self.waveAgentRoamingDelayStats[flw],] ,"Roaming Delay (secs)", cTitle, ['Line'])
                self.MyReport.InsertObject(roamGraph)
                self.finalGraphs['Roaming Delay for WaveAgent Flow']= roamGraph
                            
        
        #if len(self.flowResultsDict) == 0 or self.ecoSystemClientExist == False: 
        #    self.MyReport.Print()
        #    return                     
        
        if processType == 1:
            self.MyReport.Print()
            return 
        
        self.graphList = []
        self.diagTableList = []
        if  self.UserPassFailCriteria['User']== 'True':
                 resSummary = [('Flow Type', 'Num Flows', 'Layer7 Results', 'ILOAD (Kbps)' , 'OLOAD (Kbps)', 'Fwd Rate (Kbps)', 'Latency (msec)', 'Jitter (msec)', ' % Packet Loss','USC')]
                 self.ResultsForCSVfile.append( ('Flow Type', 'Num Flows', 'Layer7 Results', 'ILOAD (Kbps)' , 'OLOAD (Kbps)', 'Fwd Rate (Kbps)', 'Latency (msec)', 'Jitter (msec)', ' % Packet Loss','USC') )
        else:
        	resSummary = [('Flow Type', 'Num Flows', 'Layer7 Results', 'ILOAD (Kbps)' , 'OLOAD (Kbps)', 'Fwd Rate (Kbps)', 'Latency (msec)', 'Jitter (msec)', ' % Packet Loss')]
        	self.ResultsForCSVfile.append( ('Flow Type', 'Num Flows', 'Layer7 Results', 'ILOAD (Kbps)' , 'OLOAD (Kbps)', 'Fwd Rate (Kbps)', 'Latency (msec)', 'Jitter (msec)', ' % Packet Loss') )
        
        flowTypesList = []
        for flwNames in self.flowResultsDict.keys():
            flowTypesList.append(self.flowResultsDict[flwNames]['type'])	
        
        
        totalOLoad = self.sumList(self.voiceOloadList)+ self.sumList(self.rtpVideoOloadList) + self.sumList(self.rtpAudioOloadList) + self.sumList(self.ftpOloadList) + \
                     self.sumList(self.httpOloadList) + self.sumList(self.tcpOloadList) + self.sumList(self.udpOloadList) + self.sumList(self.rtpOloadList) + \
                     self.sumList(self.tcpVideoOloadList) + self.sumList(self.tcpAudioOloadList)
        
        
        totalILoad = self.sumList(self.voiceIloadList)+ self.sumList(self.rtpVideoIloadList) + self.sumList(self.rtpAudioIloadList) + self.sumList(self.ftpIloadList) + \
                     self.sumList(self.httpIloadList) + self.sumList(self.tcpIloadList) + self.sumList(self.udpIloadList) + self.sumList(self.rtpIloadList) + \
                     self.sumList(self.tcpVideoIloadList) + self.sumList(self.tcpAudioIloadList)
        
        totalALoad = self.sumList(self.voiceAloadList) + self.sumList(self.rtpVideoAloadList)  + self.sumList(self.rtpAudioAloadList) + self.sumList(self.ftpAloadList) + \
                     self.sumList(self.httpAloadList) + self.sumList(self.tcpAloadList) + self.sumList(self.udpAloadList) + self.sumList(self.rtpAloadList) + self.sumList(self.tcpVideoAloadList) + self.sumList(self.tcpAudioAloadList)
        
        if len(self.flowResultsDict) != 0:
            
            if totalOLoad <=0:
                WaveEngine.OutputstreamHDL("\nWarning: The total offered load in the test is zero..\n cannot generate a report....exiting the test", WaveEngine.MSG_WARNING)
                return -1
        
            if totalILoad <=0:
                WaveEngine.OutputstreamHDL("\nWarning: The total Intended load in the test is zero..\n cannot generate a report....exiting the test", WaveEngine.MSG_WARNING)
                return -1
        
            if totalALoad <=0:
                 WaveEngine.OutputstreamHDL("\nWarning: The total Achieved load in the test is zero..\n cannot generate a report....exiting the test", WaveEngine.MSG_WARNING)
                 return -1        
        
        oLoadPieDict = dict()
        iLoadPieDict = dict()
        aLoadPieDict = dict()
        
        if "VOIP" in flowTypesList:   
            
            oLoadPieDict["VOIP"] = round(self.sumList(self.voiceOloadList)* 100.0/ totalOLoad, 2)
            iLoadPieDict["VOIP"] = round(self.sumList(self.voiceIloadList)* 100.0/ totalILoad, 2)
            aLoadPieDict["VOIP"] = round(self.sumList(self.voiceAloadList)* 100.0/ totalALoad, 2)
            
            layer7res = "MOS Score: " + str(self.mma(self.voiceMosList)) + ", R-Value: " + str(self.mma(self.voiceRvalueList))
            if  self.UserPassFailCriteria['User']== 'True':
                 TestResult='PASS'
                 for flw in self.flowTypeDict.keys():
                         for traffictype in self.TestResult[flw].keys():
                              if traffictype == "VOIP":
                                    for each in self.TestResult[flw][traffictype]:
                                         if each == 'FAIL':
                                               TestResult='FAIL'
                              else:
                                   pass                                        
                 resultTuple = ('VOIP', flowTypesList.count("VOIP"), layer7res, self.mma(self.voiceIloadList), 
                           self.mma(self.voiceOloadList), self.mma(self.voiceFrateList),self.mma(self.voiceLatencyList), 
                           self.mma(self.voiceJitterList), self.mma(self.voicePacketLossList),TestResult) 
            else:
            	resultTuple = ('VOIP', flowTypesList.count("VOIP"), layer7res, self.mma(self.voiceIloadList), \
                           self.mma(self.voiceOloadList), self.mma(self.voiceFrateList),self.mma(self.voiceLatencyList), \
                           self.mma(self.voiceJitterList), self.mma(self.voicePacketLossList))
            resSummary.append(resultTuple)
            self.ResultsForCSVfile.append(resultTuple)
            
            if len(self.voiceMosList) <= self.CutOffForDistributionGraphs:
                
                fNums = [str(str((int(val)+1)) + " (" + self.flowNameTrafficProfileNameDict[self.voiceProfList[val]] + ")") for val in range(0, len(self.voiceMosList))]   
                            
                graphSummary = Qlib.GenericGraph(fNums, "Flow Numbers", [self.voiceMosList,] ,"MoS Score", "MoS Score for all VOIP flows", ['Bar'])
                self.graphList.append(graphSummary)            
                self.finalGraphs['MoS Score for all VOIP flows'] = graphSummary            
                            
                diagInfo = [('Flow Num', 'IP', 'MAC', 'Port', 'Network', 'Direction')]
                for ii in range (0, len(self.voiceDiagList)):
                    diagInfo.append(((ii+1), self.voiceDiagList[ii][1], self.voiceDiagList[ii][2], self.voiceDiagList[ii][3], self.voiceDiagList[ii][4], self.voiceDiagList[ii][5]))            
                
                self.diagTableList.append(diagInfo)
            else:
                xvals = [1,1.2,1.4,1.6,1.8,2,2.2,2.4,2.6,2.8,3,3.2,3.4,3.6,3.8,4,4.2,4.4,4.6,4.8,5]
                yvals = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
                for val in self.voiceMosList:
                    for mm in range(1,20):
                    	if val <= 1:
                    	    yvals[0] += 1                    	    
                        elif val > xvals[mm-1] and val <= xvals[mm]:
                            yvals[mm] += 1
                                                   
                graphSummary = Qlib.GenericGraph(xvals, "MoS Score", [yvals,] ,"MoS Score Distribution", "MoS Score Distribution for all VOIP flows", ['Bar'])
                self.graphList.append(graphSummary)            
                self.finalGraphs['MoS Score Distribution VOIP flows'] = graphSummary    
                self.diagTableList.append("None") 
                
            
            
            #self.MyReport.InsertDetailedTable(diagInfo, columns=[0.5*inch, 1.5*inch, 1.5*inch, 1.5*inch, 1.5*inch, 0.8*inch])            
                
        if "RTPAudio" in flowTypesList: 
        
            oLoadPieDict["RTPAudio"] = round(self.sumList(self.rtpAudioOloadList)* 100.0 / totalOLoad, 2)
            iLoadPieDict["RTPAudio"] = round(self.sumList(self.rtpAudioIloadList)* 100.0 / totalILoad, 2)  
            aLoadPieDict["RTPAudio"] = round(self.sumList(self.rtpAudioAloadList)* 100.0 / totalALoad, 2) 
            if  self.UserPassFailCriteria['User']== 'True':
                 TestResult='PASS'
                 for flw in self.flowTypeDict.keys():
                         for traffictype in self.TestResult[flw].keys():
                              if traffictype == "RTPAudio":
                                    for each in self.TestResult[flw][traffictype]:
                                         if each == 'FAIL':
                                               TestResult='FAIL'
                              else:
                                   pass
                 resultTuple = ('RTPAudio', flowTypesList.count("RTPAudio"), '-', self.mma(self.rtpAudioIloadList), self.mma(self.rtpAudioOloadList),self.mma(self.rtpAudioFrateList), self.mma(self.rtpAudioLatencyList), self.mma(self.rtpAudioJitterList), self.mma(self.rtpAudioPacketLossList),TestResult)
            else:
            	resultTuple = ('RTPAudio', flowTypesList.count("RTPAudio"), '-', self.mma(self.rtpAudioIloadList), self.mma(self.rtpAudioOloadList), \
                          self.mma(self.rtpAudioFrateList), self.mma(self.rtpAudioLatencyList), self.mma(self.rtpAudioJitterList), self.mma(self.rtpAudioPacketLossList))
            resSummary.append(resultTuple)
            self.ResultsForCSVfile.append(resultTuple)
            
            if len(self.rtpAudioLatencyList) <= 10:
                fNums = [str(str((int(val)+1))+ " (" + self.flowNameTrafficProfileNameDict[self.rtpAudioProfList[val]] + ")") for val in range(0, len(self.rtpAudioLatencyList))] 
            else:
                fNums = [(int(val)+1) for val in range(0, len(self.rtpAudioLatencyList))]      
            
            graphSummary1 = Qlib.GenericGraph(fNums, "Flow Numbers", [self.rtpAudioLatencyList,self.rtpAudioJitterList] , "Latency/Jitter (msecs)", "Latency and Jitter for RTPAudio flows", ['Line'], [['Latency'],['Jitter']])
            self.graphList.append(graphSummary1) 
            self.finalGraphs['Latency and Jitter for RTPAudio flows'] = graphSummary1
            
            if len(self.rtpAudioPacketLossList) <= 10:                           
                fNums = [str(str((int(val)+1))+ " (" + self.flowNameTrafficProfileNameDict[self.rtpAudioProfList[val]] + ")") for val in range(0, len(self.rtpAudioPacketLossList))] 
                graphSummary2 = Qlib.GenericGraph(fNums, "Flow Numbers", [self.rtpAudioPacketLossList,] , "% Packet Loss", "Percentage Packet Loss for RTPAudio flows", ['Bar'])
            else:
                fNums = [(int(val)+1) for val in range(0, len(self.rtpAudioPacketLossList))]     
                graphSummary2 = Qlib.GenericGraph(fNums, "Flow Numbers", [self.rtpAudioPacketLossList,] , "% Packet Loss", "Percentage Packet Loss for RTPAudio flows", ['Line'])
                
            self.graphList.append(graphSummary2)   
            self.finalGraphs['Percentage Packet Loss for RTPAudio flows'] = graphSummary2   
            
            self.diagTableList.append("None")   
            
            if len(self.rtpLatencyList) > self.CutOffForDistributionGraphs:
                self.diagTableList.append("None")
            else:
                diagInfo = [('Flow Num', 'IP', 'MAC', 'Port', 'Network', 'Direction')]
                for ii in range (0, len(self.rtpAudioDiagList)):
                    diagInfo.append(((ii+1), self.rtpAudioDiagList[ii][1], self.rtpAudioDiagList[ii][2], self.rtpAudioDiagList[ii][3], self.rtpAudioDiagList[ii][4], self.rtpAudioDiagList[ii][5]))            
                self.diagTableList.append(diagInfo)
           
                    
        if "RTPVideo" in flowTypesList:      
        
            oLoadPieDict["RTPVideo"] = round(self.sumList(self.rtpVideoOloadList)* 100.0 / totalOLoad, 2)
            iLoadPieDict["RTPVideo"] = round(self.sumList(self.rtpVideoIloadList)* 100.0 / totalILoad, 2)
            aLoadPieDict["RTPVideo"] = round(self.sumList(self.rtpVideoAloadList)* 100.0 / totalALoad, 2)
            
            layer7res = "MDI Score - " + str(self.mma(self.rtpVideoDfList)) + " msecs :" + str(self.mma(self.rtpVideoPacketLossList))
            if  self.UserPassFailCriteria['User']== 'True':
                 TestResult='PASS'
                 for flw in self.flowTypeDict.keys():
                         for traffictype in self.TestResult[flw].keys():
                              if traffictype == "RTPVideo":
                                    for each in self.TestResult[flw][traffictype]:
                                         if each == 'FAIL':
                                               TestResult='FAIL'
                              else:
                                   pass
                 resultTuple = ('RTPVideo', flowTypesList.count("RTPVideo"), layer7res, self.mma(self.rtpVideoIloadList), self.mma(self.rtpVideoOloadList),self.mma(self.rtpVideoFrateList), self.mma(self.rtpVideoLatencyList) , self.mma(self.rtpVideoJitterList), self.mma(self.rtpVideoPacketLossList),TestResult)

            else:
            	resultTuple = ('RTPVideo', flowTypesList.count("RTPVideo"), layer7res, self.mma(self.rtpVideoIloadList), self.mma(self.rtpVideoOloadList), \
                            self.mma(self.rtpVideoFrateList), self.mma(self.rtpVideoLatencyList) \
                         , self.mma(self.rtpVideoJitterList), self.mma(self.rtpVideoPacketLossList))
            resSummary.append(resultTuple)      
            self.ResultsForCSVfile.append(resultTuple)       
            
            if len(self.rtpVideoLatencyList) <= 10:
                fNums = [str(str((int(val)+1))+ " (" + self.flowNameTrafficProfileNameDict[self.rtpVideoProfList[val]] + ")") for val in range(0, len(self.rtpVideoLatencyList))]
            else:
                fNums = [(int(val)+1) for val in range(0, len(self.rtpVideoLatencyList))] 
            
            
            dfForRtpVideoGraph = Qlib.GenericGraph(fNums, "Flow Numbers", [self.rtpVideoDfList,] , "DF (msecs)", "Delay Factor for RTP Video flows", ["Line"])
            self.graphList.append(dfForRtpVideoGraph)
            self.finalGraphs['Delay Factor (DF) for RTP Video flows'] = dfForRtpVideoGraph
            
            if len(self.rtpVideoPacketLossList) <= 10:
                fNums = [str(str((int(val)+1))+ " (" + self.flowNameTrafficProfileNameDict[self.rtpVideoProfList[val]] + ")") for val in range(0, len(self.rtpVideoPacketLossList))] 
                mlrForRtpVideoGraph = Qlib.GenericGraph(fNums, "Flow Numbers", [self.rtpVideoPacketLossList,] , "MLR", "Media Loss Ratio (MLR) for RTP Video Flows", ['Bar'])
            else:
                fNums = [(int(val)+1) for val in range(0, len(self.rtpVideoPacketLossList))]    
                mlrForRtpVideoGraph = Qlib.GenericGraph(fNums, "Flow Numbers", [self.rtpVideoPacketLossList,] , "MLR", "Media Loss Ratio (MLR) for RTP Video Flows", ['Line'])
                        
            self.graphList.append(mlrForRtpVideoGraph)
            self.finalGraphs['Media Loss Ratio(MLR) for RTP Video flows'] = mlrForRtpVideoGraph                          
            
            if len(self.rtpVideoLatencyList) <= 10:
                fNums = [str(str((int(val)+1))+ " (" + self.flowNameTrafficProfileNameDict[self.rtpVideoProfList[val]] + ")") for val in range(0, len(self.rtpVideoLatencyList))] 
            else:
                fNums = [(int(val)+1) for val in range(0, len(self.rtpVideoLatencyList))] 
            
            
            graphSummary = Qlib.GenericGraph(fNums, "Flow Numbers", [self.rtpVideoLatencyList,self.rtpVideoJitterList] , "Latency/Jitter (msecs)", "Latency and Jitter for RTP Video flows", ["Line"], [["Latency"],["Jitter"]])
            self.graphList.append(graphSummary) 
            self.finalGraphs['Latency and Jitter for RTP Video flows'] = graphSummary
            
            self.diagTableList.append("None")
            self.diagTableList.append("None")
            
            if len(self.rtpVideoDfList) > self.CutOffForDistributionGraphs:
                self.diagTableList.append("None")
            else:           
                diagInfo = [('Flow Num', 'IP', 'MAC', 'Port', 'Network', 'Direction')]
                for ii in range (0, len(self.rtpVideoDiagList)):
                    diagInfo.append(((ii+1), self.rtpVideoDiagList[ii][1], self.rtpVideoDiagList[ii][2], self.rtpVideoDiagList[ii][3], self.rtpVideoDiagList[ii][4], self.rtpVideoDiagList[ii][5]))            
                self.diagTableList.append(diagInfo)
            
        if 'ftp' in flowTypesList:  
            
            oLoadPieDict["ftp"] = round(self.sumList(self.ftpOloadList)* 100.0 / totalOLoad, 2)
            iLoadPieDict["ftp"] = round(self.sumList(self.ftpIloadList)* 100.0 / totalILoad, 2)
            aLoadPieDict["ftp"] = round(self.sumList(self.ftpAloadList)* 100.0 / totalALoad, 2)
            
            layer7res = "File Transfer Time: " + str(self.mma(self.ftpFttList)) + " secs, " + "Goodput: " + str(self.mma(self.ftpGputList)) +" Kbps"
              
            if  self.UserPassFailCriteria['User']== 'True':
                 TestResult='PASS'
                 for flw in self.flowTypeDict.keys():
                         for traffictype in self.TestResult[flw].keys():
                              if traffictype == "ftp":
                                    for each in self.TestResult[flw][traffictype]:
                                         if each == 'FAIL':
                                               TestResult='FAIL'
                              else:
                                   pass
                 resultTuple = ('ftp', flowTypesList.count("ftp"), layer7res, self.mma(self.ftpIloadList), self.mma(self.ftpOloadList),'-', '-' , '-' , self.mma(self.ftpPacketLossList),TestResult)
            else: 
            	resultTuple = ('ftp', flowTypesList.count("ftp"), layer7res, self.mma(self.ftpIloadList), self.mma(self.ftpOloadList),\
                           '-', '-' , '-' , self.mma(self.ftpPacketLossList))
            resSummary.append(resultTuple)  	
            self.ResultsForCSVfile.append(resultTuple)
            
            if len(self.ftpFttList) <= 10:            
                fNums = [str(str((int(val)+1))+ " (" + self.flowNameTrafficProfileNameDict[self.ftpProfList[val]] + ")") for val in range(0, len(self.ftpFttList))] 
            else:
                fNums = [(int(val)+1) for val in range(0, len(self.ftpFttList))] 
                    
            graphSummary = Qlib.GenericGraph(fNums, "Flow Numbers", [self.ftpGputList, self.ftpSlaReqList] , "Goodput (Kbps)", "FTP Goodput", ['Bar'], [['Goodput'],['SLA Requirements(Kbps)']])
            self.graphList.append(graphSummary) 
            self.finalGraphs['FTP Goodput'] = graphSummary
            
            if len(self.ftpGputList) > self.CutOffForDistributionGraphs:
                self.diagTableList.append("None")
            else:
                diagInfo = [('Flow Num', 'IP', 'MAC', 'Port', 'Network', 'Direction')]
                for ii in range (0, len(self.ftpDiagList)):
                    diagInfo.append(((ii+1), self.ftpDiagList[ii][1], self.ftpDiagList[ii][2], self.ftpDiagList[ii][3], self.ftpDiagList[ii][4], self.ftpDiagList[ii][5]))            
                self.diagTableList.append(diagInfo)
                
        if 'TCPVideo' in flowTypesList:   
            
            oLoadPieDict["TCPVideo"] = round(self.sumList(self.tcpVideoOloadList)* 100.0 / totalOLoad, 2)
            iLoadPieDict["TCPVideo"] = round(self.sumList(self.tcpVideoIloadList)* 100.0 / totalILoad, 2)   
            aLoadPieDict["TCPVideo"] = round(self.sumList(self.tcpVideoAloadList)* 100.0 / totalALoad, 2)          
            
            layer7res = "Goodput - " + str(self.mma(self.tcpVideoGputList)) + " Kbps"
            
            if  self.UserPassFailCriteria['User']== 'True':
                 TestResult='PASS'
                 for flw in self.flowTypeDict.keys():
                         for traffictype in self.TestResult[flw].keys():
                              if traffictype == "TCPVideo":
                                    for each in self.TestResult[flw][traffictype]:
                                         if each == 'FAIL':
                                               TestResult='FAIL'
                              else:
                                   pass
                 resultTuple = ('TCPVideo', flowTypesList.count("TCPVideo"), layer7res, self.mma(self.tcpVideoIloadList), self.mma(self.tcpVideoOloadList),'-', '-' , '-' , self.mma(self.tcpVideoPacketLossList),TestResult)
            else:  
           		resultTuple = ('TCPVideo', flowTypesList.count("TCPVideo"), layer7res, self.mma(self.tcpVideoIloadList), self.mma(self.tcpVideoOloadList), \
                          '-', '-' , '-' , self.mma(self.tcpVideoPacketLossList))
            resSummary.append(resultTuple)    
            self.ResultsForCSVfile.append(resultTuple)
            
            if len(self.tcpVideoGputList) <= 10:
                fNums = [str(str((int(val)+1))+ " (" + self.flowNameTrafficProfileNameDict[self.tcpVideoProfList[val]] + ")") for val in range(0, len(self.tcpVideoGputList))] 
            else:
                fNums = [(int(val)+1) for val in range(0, len(self.tcpVideoGputList))] 
                    
            graphSummary = Qlib.GenericGraph(fNums, "Flow Numbers", [self.tcpVideoGputList,] , "Goodput (Kbps)", "TCPVideo Goodput", ['Bar'], [['Goodput'],])
            self.graphList.append(graphSummary) 
            self.finalGraphs['TCPVideo Goodput'] = graphSummary  
            
            if len(self.tcpVideoGputList) > self.CutOffForDistributionGraphs:
                self.diagTableList.append("None")
            else:
                diagInfo = [('Flow Num', 'IP', 'MAC', 'Port', 'Network', 'Direction')]
                for ii in range (0, len(self.tcpVideoDiagList)):
                    diagInfo.append(((ii+1), self.tcpVideoDiagList[ii][1], self.tcpVideoDiagList[ii][2], self.tcpVideoDiagList[ii][3], self.tcpVideoDiagList[ii][4], self.tcpVideoDiagList[ii][5]))            
                self.diagTableList.append(diagInfo)    
        
        if 'TCPAudio' in flowTypesList:   
            
            oLoadPieDict["TCPAudio"] = round(self.sumList(self.tcpAudioOloadList)* 100.0 / totalOLoad, 2)
            iLoadPieDict["TCPAudio"] = round(self.sumList(self.tcpAudioIloadList)* 100.0 / totalILoad, 2)   
            aLoadPieDict["TCPAudio"] = round(self.sumList(self.tcpAudioAloadList)* 100.0 / totalALoad, 2)          
            
            layer7res = "Goodput - " + str(self.mma(self.tcpAudioGputList)) + " Kbps"
            
            if  self.UserPassFailCriteria['User']== 'True':
                 TestResult='PASS'
                 for flw in self.flowTypeDict.keys():
                         for traffictype in self.TestResult[flw].keys():
                              if traffictype == "TCPAudio":
                                    for each in self.TestResult[flw][traffictype]:
                                         if each == 'FAIL':
                                               TestResult='FAIL'
                              else:
                                   pass
                 resultTuple = ('TCPAudio', flowTypesList.count("TCPAudio"), layer7res, self.mma(self.tcpAudioIloadList), self.mma(self.tcpAudioOloadList),'-', '-' , '-' , self.mma(self.tcpAudioPacketLossList),TestResult)
            else:
            	resultTuple = ('TCPAudio', flowTypesList.count("TCPAudio"), layer7res, self.mma(self.tcpAudioIloadList), self.mma(self.tcpAudioOloadList), \
                          '-', '-' , '-' , self.mma(self.tcpAudioPacketLossList))
            resSummary.append(resultTuple)    
            self.ResultsForCSVfile.append(resultTuple)
            
            if len(self.tcpAudioGputList) <= 10:
                fNums = [str(str((int(val)+1))+ " (" + self.flowNameTrafficProfileNameDict[self.tcpAudioProfList[val]] + ")") for val in range(0, len(self.tcpAudioGputList))] 
            else:
                fNums = [(int(val)+1) for val in range(0, len(self.tcpAudioGputList))] 
                    
            graphSummary = Qlib.GenericGraph(fNums, "Flow Numbers", [self.tcpAudioGputList,] , "Goodput (Kbps)", "TCPAudio Goodput", ['Bar'], [['Goodput'],])
            self.graphList.append(graphSummary) 
            self.finalGraphs['TCPAudio Goodput'] = graphSummary  
            
            if len(self.tcpAudioGputList) > self.CutOffForDistributionGraphs:
                self.diagTableList.append("None")
            else:
                diagInfo = [('Flow Num', 'IP', 'MAC', 'Port', 'Network', 'Direction')]
                for ii in range (0, len(self.tcpAudioDiagList)):
                    diagInfo.append(((ii+1), self.tcpAudioDiagList[ii][1], self.tcpAudioDiagList[ii][2], self.tcpAudioDiagList[ii][3], self.tcpAudioDiagList[ii][4], self.tcpAudioDiagList[ii][5]))            
                self.diagTableList.append(diagInfo) 
        
        
        if 'http' in flowTypesList:   
            
            oLoadPieDict["http"] = round(self.sumList(self.httpOloadList)* 100.0 / totalOLoad, 2)
            iLoadPieDict["http"] = round(self.sumList(self.httpIloadList)* 100.0 / totalILoad, 2)   
            aLoadPieDict["http"] = round(self.sumList(self.httpAloadList)* 100.0 / totalALoad, 2)          
            
            layer7res = "Goodput - " + str(self.mma(self.httpGputList)) + " Kbps"
            
            if  self.UserPassFailCriteria['User']== 'True':
                 TestResult='PASS'
                 for flw in self.flowTypeDict.keys():
                         for traffictype in self.TestResult[flw].keys():
                              if traffictype == "http":
                                    for each in self.TestResult[flw][traffictype]:
                                         if each == 'FAIL':
                                               TestResult='FAIL'
                              else:
                                   pass
                 resultTuple = ('http', flowTypesList.count("http"), layer7res, self.mma(self.httpIloadList), self.mma(self.httpOloadList), '-', '-' , '-' , self.mma(self.httpPacketLossList),TestResult)
            else:
            	resultTuple = ('http', flowTypesList.count("http"), layer7res, self.mma(self.httpIloadList), self.mma(self.httpOloadList), \
                          '-', '-' , '-' , self.mma(self.httpPacketLossList))
            resSummary.append(resultTuple)    
            self.ResultsForCSVfile.append(resultTuple)
            
            if len(self.httpGputList) <= 10:
                fNums = [str(str((int(val)+1))+ " (" + self.flowNameTrafficProfileNameDict[self.httpProfList[val]] + ")") for val in range(0, len(self.httpGputList))] 
            else:
                fNums = [(int(val)+1) for val in range(0, len(self.httpGputList))] 
                    
            graphSummary = Qlib.GenericGraph(fNums, "Flow Numbers", [self.httpGputList, self.httpSlaReqList] , "Goodput (Kbps)", "HTTP Goodput", ['Bar'], [['Goodput'],['SLA Requirements(Kbps)']])
            self.graphList.append(graphSummary) 
            self.finalGraphs['HTTP Goodput'] = graphSummary  
            
            if len(self.httpGputList) > self.CutOffForDistributionGraphs:
                self.diagTableList.append("None")
            else:
                diagInfo = [('Flow Num', 'IP', 'MAC', 'Port', 'Network', 'Direction')]
                for ii in range (0, len(self.httpDiagList)):
                    diagInfo.append(((ii+1), self.httpDiagList[ii][1], self.httpDiagList[ii][2], self.httpDiagList[ii][3], self.httpDiagList[ii][4], self.httpDiagList[ii][5]))            
                self.diagTableList.append(diagInfo)    
        
        if 'tcp' in flowTypesList:
            
            oLoadPieDict["tcp"] = round(self.sumList(self.tcpOloadList)* 100.0 / totalOLoad, 2)
            iLoadPieDict["tcp"] = round(self.sumList(self.tcpIloadList)* 100.0 / totalILoad, 2)
            aLoadPieDict["tcp"] = round(self.sumList(self.tcpAloadList)* 100.0 / totalALoad, 2)
            
            layer7res = "Goodput - " + str(self.mma(self.tcpGputList)) + " Kbps"
            if  self.UserPassFailCriteria['User']== 'True':
                 TestResult='PASS'
                 for flw in self.flowTypeDict.keys():
                         for traffictype in self.TestResult[flw].keys():
                              if traffictype == "tcp":
                                    for each in self.TestResult[flw][traffictype]:
                                         if each == 'FAIL':
                                               TestResult='FAIL'
                              else:
                                   pass
                 resultTuple = ('tcp', flowTypesList.count("tcp"), layer7res, self.mma(self.tcpIloadList), self.mma(self.tcpOloadList),'-', '-' , '-' , self.mma(self.tcpPacketLossList),TestResult) 
            else:  
            	resultTuple = ('tcp', flowTypesList.count("tcp"), layer7res, self.mma(self.tcpIloadList), self.mma(self.tcpOloadList),  
                          '-', '-' , '-' , self.mma(self.tcpPacketLossList))
            resSummary.append(resultTuple)
            self.ResultsForCSVfile.append(resultTuple)
            
            if len(self.tcpGputList) <= 10:
                fNums = [str(str((int(val)+1))+ " (" + self.flowNameTrafficProfileNameDict[self.tcpProfList[val]] + ")") for val in range(0, len(self.tcpGputList))] 
            else:
                fNums = [(int(val)+1) for val in range(0, len(self.tcpGputList))]
                    
            graphSummary = Qlib.GenericGraph(fNums, "Flow Numbers", [self.tcpGputList, self.tcpSlaReqList] ,"Goodput (Kbps)", "TCP Goodput", ['Bar'], [['Goodput'],['SLA Requirements(Kbps)']])
            self.graphList.append(graphSummary)  
            self.finalGraphs['TCP Goodput'] = graphSummary     
            
            if len(self.tcpGputList) > self.CutOffForDistributionGraphs:
                self.diagTableList.append("None")
            else:
                diagInfo = [('Flow Num', 'IP', 'MAC', 'Port', 'Network', 'Direction')]
                for ii in range (0, len(self.tcpDiagList)):
                    diagInfo.append(((ii+1), self.tcpDiagList[ii][1], self.tcpDiagList[ii][2], self.tcpDiagList[ii][3], self.tcpDiagList[ii][4], self.tcpDiagList[ii][5]))            
                self.diagTableList.append(diagInfo)
        
        if "udp" in flowTypesList: 
        
            oLoadPieDict["udp"] = round(self.sumList(self.udpOloadList)* 100.0 / totalOLoad, 2)
            iLoadPieDict["udp"] = round(self.sumList(self.udpIloadList)* 100.0 / totalILoad, 2)  
            aLoadPieDict["udp"] = round(self.sumList(self.udpAloadList)* 100.0 / totalALoad, 2) 
                   
            if  self.UserPassFailCriteria['User']== 'True':
                 TestResult='PASS'
                 for flw in self.flowTypeDict.keys():
                         for traffictype in self.TestResult[flw].keys():
                              if traffictype == "udp":
                                    for each in self.TestResult[flw][traffictype]:
                                         if each == 'FAIL':
                                               TestResult='FAIL'
                              else:
                                   pass
                 resultTuple = ('udp', flowTypesList.count("udp"), '-', self.mma(self.udpIloadList), self.mma(self.udpOloadList), self.mma(self.udpFrateList), self.mma(self.udpLatencyList), self.mma(self.udpJitterList), self.mma(self.udpPacketLossList),TestResult)
            else: 
            	resultTuple = ('udp', flowTypesList.count("udp"), '-', self.mma(self.udpIloadList), self.mma(self.udpOloadList), \
                          self.mma(self.udpFrateList), self.mma(self.udpLatencyList), self.mma(self.udpJitterList), self.mma(self.udpPacketLossList))
            resSummary.append(resultTuple)
            self.ResultsForCSVfile.append(resultTuple)
            
            if len(self.udpFrateList) <= 10:
                fNums = [str(str((int(val)+1))+ " (" + self.flowNameTrafficProfileNameDict[self.udpProfList[val]] + ")") for val in range(0, len(self.udpFrateList))] 
                graphSummary1 = Qlib.GenericGraph(fNums, "Flow Numbers", [self.udpFrateList,] , "Forwarding Rate (Kbps)", "Forwarding Rate for UDP flows", ['Bar'])
            else:
                fNums = [(int(val)+1) for val in range(0, len(self.udpFrateList))]     
                graphSummary1 = Qlib.GenericGraph(fNums, "Flow Numbers", [self.udpFrateList,] , "Forwarding Rate (Kbps)", "Forwarding Rate for UDP flows", ['Line'])
                
            self.graphList.append(graphSummary1) 
            self.finalGraphs['Forwarding Rate for UDP flows'] = graphSummary1
            
            if len(self.udpLatencyList) <= 10:
                fNums = [str(str((int(val)+1))+ " (" + self.flowNameTrafficProfileNameDict[self.udpProfList[val]] + ")") for val in range(0, len(self.udpLatencyList))] 
            else:
                fNums = [(int(val)+1) for val in range(0, len(self.udpLatencyList))]     
            
            graphSummary2 = Qlib.GenericGraph(fNums, "Flow Numbers", [self.udpLatencyList,self.udpJitterList] , "Latency/Jitter (msecs)", "Latency and Jitter for UDP flows", ['Line'], [['Latency'],['Jitter']])
            self.graphList.append(graphSummary2) 
            self.finalGraphs['Latency and Jitter for UDP flows'] = graphSummary2
            
            if len(self.udpPacketLossList) <= 10:                           
                fNums = [str(str((int(val)+1))+ " (" + self.flowNameTrafficProfileNameDict[self.udpProfList[val]] + ")") for val in range(0, len(self.udpPacketLossList))] 
                graphSummary3 = Qlib.GenericGraph(fNums, "Flow Numbers", [self.udpPacketLossList,] , "% Packet Loss", "Percentage Packet Loss for UDP flows", ['Bar'])
            else:
                fNums = [(int(val)+1) for val in range(0, len(self.udpPacketLossList))]    
                graphSummary3 = Qlib.GenericGraph(fNums, "Flow Numbers", [self.udpPacketLossList,] , "% Packet Loss", "Percentage Packet Loss for UDP flows", ['Line'])
                
            self.graphList.append(graphSummary3)   
            self.finalGraphs['Percentage Packet Loss for UDP flows'] = graphSummary3      
            
            self.diagTableList.append("None")
            self.diagTableList.append("None")
            
            if len(self.udpJitterList) > self.CutOffForDistributionGraphs:
                self.diagTableList.append("None")
            else:
                diagInfo = [('Flow Num', 'IP', 'MAC', 'Port', 'Network', 'Direction')]
                for ii in range (0, len(self.udpDiagList)):
                    diagInfo.append(((ii+1), self.udpDiagList[ii][1], self.udpDiagList[ii][2], self.udpDiagList[ii][3], self.udpDiagList[ii][4], self.udpDiagList[ii][5]))            
                self.diagTableList.append(diagInfo)
            
            
        if "rtp" in flowTypesList: 
        
            oLoadPieDict["rtp"] = round(self.sumList(self.rtpOloadList)* 100.0 / totalOLoad, 2)
            iLoadPieDict["rtp"] = round(self.sumList(self.rtpIloadList)* 100.0 / totalILoad, 2)  
            aLoadPieDict["rtp"] = round(self.sumList(self.rtpAloadList)* 100.0 / totalALoad, 2) 
                   
            if  self.UserPassFailCriteria['User']== 'True':
                 TestResult='PASS'
                 for flw in self.flowTypeDict.keys():
                         for traffictype in self.TestResult[flw].keys():
                              if traffictype == "rtp":
                                    for each in self.TestResult[flw][traffictype]:
                                         if each == 'FAIL':
                                               TestResult='FAIL'
                              else:
                                   pass
                 resultTuple = ('rtp', flowTypesList.count("rtp"), '-', self.mma(self.rtpIloadList), self.mma(self.rtpOloadList),self.mma(self.rtpFrateList), self.mma(self.rtpLatencyList), self.mma(self.rtpJitterList), self.mma(self.rtpPacketLossList),TestResult)
            else: 
            	resultTuple = ('rtp', flowTypesList.count("rtp"), '-', self.mma(self.rtpIloadList), self.mma(self.rtpOloadList), \
                          self.mma(self.rtpFrateList), self.mma(self.rtpLatencyList), self.mma(self.rtpJitterList), self.mma(self.rtpPacketLossList))
            resSummary.append(resultTuple)
            self.ResultsForCSVfile.append(resultTuple)
            
            if len(self.rtpLatencyList) <= 10:
                fNums = [str(str((int(val)+1))+ " (" + self.flowNameTrafficProfileNameDict[self.rtpProfList[val]] + ")") for val in range(0, len(self.rtpLatencyList))] 
            else:
                fNums = [(int(val)+1) for val in range(0, len(self.rtpLatencyList))]      
            
            graphSummary1 = Qlib.GenericGraph(fNums, "Flow Numbers", [self.rtpLatencyList,self.rtpJitterList] , "Latency/Jitter (msecs)", "Latency and Jitter for RTP flows", ['Line'], [['Latency'],['Jitter']])
            self.graphList.append(graphSummary1) 
            self.finalGraphs['Latency and Jitter for RTP flows'] = graphSummary1
            
            if len(self.rtpPacketLossList) <= 10:                           
                fNums = [str(str((int(val)+1))+ " (" + self.flowNameTrafficProfileNameDict[self.rtpProfList[val]] + ")") for val in range(0, len(self.rtpPacketLossList))] 
                graphSummary2 = Qlib.GenericGraph(fNums, "Flow Numbers", [self.rtpPacketLossList,] , "% Packet Loss", "Percentage Packet Loss for RTP flows", ['Bar'])
            else:
                fNums = [(int(val)+1) for val in range(0, len(self.rtpPacketLossList))]     
                graphSummary2 = Qlib.GenericGraph(fNums, "Flow Numbers", [self.rtpPacketLossList,] , "% Packet Loss", "Percentage Packet Loss for RTP flows", ['Line'])
                
            self.graphList.append(graphSummary2)   
            self.finalGraphs['Percentage Packet Loss for RTP flows'] = graphSummary2   
            
            self.diagTableList.append("None")   
            
            if len(self.rtpLatencyList) > self.CutOffForDistributionGraphs:
                self.diagTableList.append("None")
            else:
                diagInfo = [('Flow Num', 'IP', 'MAC', 'Port', 'Network', 'Direction')]
                for ii in range (0, len(self.rtpDiagList)):
                    diagInfo.append(((ii+1), self.rtpDiagList[ii][1], self.rtpDiagList[ii][2], self.rtpDiagList[ii][3], self.rtpDiagList[ii][4], self.rtpDiagList[ii][5]))            
                self.diagTableList.append(diagInfo)
                               
        self.MyReport.InsertParagraph("")
        self.MyReport.InsertParagraph("")
        
        if self.dynamicBlogModeflag:
            blogPortList = []
            for kys in self.blogScheduleDict:
                if self.blogScheduleDict[kys]['port'] not in blogPortList:
                    blogPortList.append(self.blogScheduleDict[kys]['port'])
            
            xValList = []
            yValList = [] 
            for eachPort in blogPortList:
                xVals = []
                yVals = []
                for kys in self.blogScheduleDict:
                    if self.blogScheduleDict[kys]['port'] == eachPort:
                        yVals.append(self.blogScheduleDict[kys]['intPer'])             
    	                xVals.append(kys)
    	        xValList.append(xVals)
    	        yValList.append(yVals)
    	    
    	    for ii in range(0, len(xValList)):
    	    	titName = "Interference Schedule for IG port " + blogPortList[ii]
    	        graphSummary1 = Qlib.GenericGraph(xValList[ii], "Time (secs)", [yValList[ii],] , "% of Interference", titName, ['Line'])
                self.graphList.append(graphSummary1) 
                self.finalGraphs[titName] = graphSummary1
                self.diagTableList.append("None")  
                
    	 
        resSla = [('Flow Type', 'SLA Requirement', '% of Flows that met SLA')]
        self.ResultsForCSVfile.append(resSla[0])
        passFailValsList = []

        for kys in self.slaCountDict.keys():
            resStr = []
            resStr.append(kys)
            reqStr = ""
            for reqKys in self.slaReqDict[kys].keys():
            	if reqKys == "Latency" or reqKys == "Jitter":
                    units = "msecs"
                elif reqKys == "Goodput":
                    units = "Kbps"
                elif reqKys == "PacketLoss": 
                    units = "%"
                else:
                    units = ""    	    	     
            	reqStr = reqStr + reqKys + " : " + str(self.slaReqDict[kys][reqKys]) + units + "    "
            resStr.append(reqStr)
            
            passPer = self.slaCountDict[kys] * 100 / flowTypesList.count(kys)   
            
            if kys == "slaMode":
            	if self.slaCountDict[kys] == 0:
            	    resStr.append("R-Value")
            	else:
            	    resStr.append("MOS Score")    
            else: 	
                resStr.append(passPer)
                        
            passFailValsList.append((passPer, 100 - passPer))
            resSla.append(resStr)
            self.ResultsForCSVfile.append(resStr)		
               
        if len(passFailValsList) > 0:
            summaryGraph1 = PassFailGraph(6*inch, 2.5*inch,self.slaCountDict.keys(),passFailValsList, 'PASS/FAIL Percentages of Traffic Types that met SLA', options=PF_OPTION_SHOWPERCENT | PF_OPTION_LEGENDRIGHT)
            self.MyReport.InsertObject(summaryGraph1)
            self.finalGraphs['PASS/FAIL Percentages of Traffic Types that met SLA'] = summaryGraph1  
        
        
        
        
        #self.MyReport.InsertParagraph("The Table below shows the percentage of Traffic flows of each traffic type that satisfied the SLA")        
        #self.MyReport.InsertDetailedTable(resSla, columns=[1.0*inch, 3.5*inch, 1.0*inch])
        
        if len(self.flowResultsDict) != 0:
            self.MyReport.InsertParagraph("The summary table below shows the per flow average performance measurements of each traffic type")       
            if self.UserPassFailCriteria['User']== 'True':
                    self.user_table=[('FlowType_FlowNo','Parameter','SLA set by the user','Achieved Value','Results per Flow')]
                    summary_table=[('FlowType','Parameter','SLA set by the user','Achieved Value/Flow','Summary Result')]
                    #voip_overall_results=rtp_overall_results=RTPVideo_overall_results=RTPAudio_overall_results=udp_overall_results=tcp_overall_results=ftp_overall_results=http_overall_results=TCPVideo_overall_results=TCPAudio_overall_results=tuple()
                    tmp=tuple()
                    for flw in self.flowTypeDict.keys():
                        if self.TestResult.has_key(flw): 
                             tmp=tuple() 
                             traffictype= self.TestResult[flw].keys()[0]  
                             ### For Per flow results table 
                             ### For Per flow results table 
                             temp_s='%s_%s'%(traffictype,self.flowTypeDict.keys().index(flw)+1)
                             tmp=tmp+(temp_s,)
                             for each_val in self.TestResult[flw][traffictype]:
                                  tmp=tmp+(each_val,)
                             self.user_table=self.user_table+[tmp]
                             ## Done with per flow SLA table, now change the Type value in the 
                             ## format of the per flow SLA results table for merging them later
                             ## for data export module.
                             if 0:
                               tmp_sep=self.ResultsForCSVfile.index(())
                               for each in self.ResultsForCSVfile[tmp_sep+2:]:     
                                     if each[0] == traffictype:
                                          tmp_each=self.ResultsForCSVfile.index(each)
                                          #print "Temp each is %s\n" %tmp_each
                                          break
                                     elif each[0] == 'Type':
                                          each [0]='FlowType_FlowNo'
                               self.ResultsForCSVfile[tmp_each][0]='%s_%s'%(traffictype,(self.flowTypeDict.keys().index(flw)+1))                             

                        else:
                           pass
                    self.MyReport.InsertDetailedTable(resSummary, columns=[0.8*inch, 0.5*inch, 1.5*inch, 0.6*inch, 0.6*inch, 0.7*inch, 0.7*inch, 0.6*inch, 0.6*inch,0.75*inch])
                    explaintext=""" If atleast one flow per traffic type fails to achieve the SLA set by the user, then the entire traffic type is \
                                    considered as FAIL.If and only if all the flows per traffic type achieve the SLA set by the user then and only then
                                    that particular traffic type is considered as PASS.
                                    Note: For detailed per flow results related to SLA, please refer the below USC table"""
                    notetext= """ Note: Abbreviations used are USC:: User Specified criteria"""
                    self.MyReport.InsertParagraph(explaintext)
                    self.MyReport.InsertParagraph(notetext)
                    ## Limit the number of flows to 25 in the per flow reporting
                    ## if total flows >25 then no per flow reporting
                    if len(self.user_table) <= 26:
                        self.MyReport.InsertHeader("User Specified Criteria")
                        self.MyReport.InsertDetailedTable(self.user_table,columns=[1*inch,1.5*inch,1.5*inch,1.5*inch,1*inch,])
                        for each in self.user_table[1:]:
                           print "\nThe Summary Results for Traffic type--%s is Parameter--%s,SLA SET--%s,SLA Achieved--%s and Result--%s\n" %(each[0],each[1],each[2],each[3],each[4])  
                    #self.MyReport.InsertHeader("Overall Summary Results/Traffic Type")
                    #self.MyReport.InsertDetailedTable(summary_table,columns=[1.5*inch,2*inch,1*inch,1*inch,1*inch,])  
            else:
            	self.MyReport.InsertDetailedTable(resSummary, columns=[0.8*inch, 0.5*inch, 1.5*inch, 0.6*inch, 0.6*inch, 0.7*inch, 0.7*inch, 0.6*inch, 0.6*inch])
         
            self.MyReport.InsertParagraph("The Total Intended Load is %0.2f Mbps, offered load is %0.2f Mbps and achieved load is %0.2f Mbps" % \
            (round((totalILoad / 1000.0),2), round((totalOLoad / 1000.0),2), round((totalALoad / 1000.0),2)))
        
        
            summaryGraph2 = self.getPieChartObject(iLoadPieDict, oLoadPieDict, aLoadPieDict, totalILoad, totalOLoad, totalALoad)
            self.MyReport.InsertObject(summaryGraph2)
            #self.finalGraphs['Pie Charts for IOA Loads per Flow Type'] = summaryGraph2
                
            iLoadList = []
            oLoadList = []
            aLoadList = []
            flowList = []
            for kys in iLoadPieDict.keys():
                iLoadList.append(round(iLoadPieDict[kys] * totalILoad / 100))
                oLoadList.append(round(oLoadPieDict[kys] * totalOLoad / 100))
                aLoadList.append(round(aLoadPieDict[kys] * totalALoad / 100))
                flowList.append(kys)	
            	 
            summaryGraph3 = Qlib.GenericGraph(flowList, "Flow Types", [iLoadList,oLoadList,aLoadList ] ,"Load Values in Kbps", "iLoad, oLoad and aLoad per Traffic Type", ['Bar'], [["iLoad"],["0Load"], ["aLoad"]])
            self.MyReport.InsertObject(summaryGraph3)
            self.finalGraphs['Bar Charts for iLoad, oLoad and aLoad per Traffic Type'] = summaryGraph3
                
            if self.enableOverTimeResults == 1:
                if self.overTimeResultType == 0:
                    iLoadListT = []
                    oLoadListT = []
                    aLoadListT = []
                    sampleList = []
                    for tim in self.tIloadOverTime:
                        sampleList.append(tim)
                        iLoadListT.append(self.tIloadOverTime[tim])
                        oLoadListT.append(self.tOloadOverTime[tim])
                        aLoadListT.append(self.tAloadOverTime[tim])    
                
                    ##### Disabling for now due to some bugs                     
                    #summaryGraph4 = Qlib.GenericGraph(sampleList, "Time(secs)", [iLoadListT,oLoadListT,aLoadListT ] ,"Load Values in Kbps", "Total intented Load, offered Load and achieved Load Vs Time", ['Line'], [["iLoad"],["0Load"], ["aLoad"]])
                    #self.MyReport.InsertObject(summaryGraph4)
                    #self.finalGraphs['Total intented Load, offered Load and achieved Load Vs Time'] = summaryGraph4
                
            if self.wimixMode == 1:
                self.clientMixGetClientTypeResults(totalOLoad, totalILoad, totalALoad)
        
            #self.MyReport.InsertHeader( "Test Topology" )
            #self.MyReport.InsertObject("wimix_graphic.PNG")
            #self.MyReport.InsertParagraph("The test topology is shown below. Traffic is transmitted \
            #    in the direction of the arrows. The test client port identifiers and IP addresses \
            #    are indicated in the boxes, together with the security mode and channel number for \
            #    WLAN clients")
                
            #self.MyReport.InsertClientMap( self.srcClients, self.destClients, False, self.CardMap )
        
            self.MyReport.InsertHeader("Graphs")  
            self.MyReport.InsertParagraph("The Graphs below show the per traffic flow performance measurements of each traffic type")
        
        
            for ii in range(0, len(self.graphList)):
                self.MyReport.InsertObject(self.graphList[ii])
                if self.diagTableList[ii] != "None":
            	    self.MyReport.InsertParagraph("The following table shows more information about each flow of this traffic type for debugging purposes.")
                    self.MyReport.InsertDetailedTable(self.diagTableList[ii], columns=[0.5*inch, 1.0*inch, 1.5*inch, 2.0*inch, 1.5*inch, 0.8*inch])            
                 
            self.MyReport.InsertPageBreak()  
        
        #if self.insertTestTopoDiagram:
        #    self.MyReport.InsertParagraph("")
        #    self.MyReport.InsertHeader( "Test Topology" )
        #    print "1"
        #    self.MyReport.InsertObject("topo.jpg")
        
        if self.progAttenFlag:
            self.MyReport.InsertHeader("Programmable Attenuator Parameters")
            
            if 'Attenuation Vs Time' not in self.finalGraphs:
                attTimes = []
                att1Vals = []
                att2Vals = []
                for kys in self.attScheduleOnly:
                    attTimes.append(kys)
                    att1Vals.append(self.attScheduleOnly[kys]['att1'])
                    att2Vals.append(self.attScheduleOnly[kys]['att2'])             
                    
                self.MyReport.InsertParagraph("""The graph below shows how the attenuation on AP1 and AP1 are changed over time.""")    
                dataRateGraph = Qlib.GenericGraph(attTimes, "Time (secs)", [att1Vals, att2Vals] ,"Attenuation (dB)", "Attenuation on APs Vs Time", ['Line'], [['Attenuation on AP1'],['Attenuation on AP2']])
                self.MyReport.InsertObject(dataRateGraph)
                self.finalGraphs['Attenuation Vs Time']= dataRateGraph  
            
            self.MyReport.InsertParagraph("The table below shows the input parameters for the Programmable Attenuation")
            resSummary = [('Parameter', 'Value')]
            for key in self.waveTestStore['ProgAttenuation'].keys():
                if key != "CustomSchedule":
                    resultTuple = (key, self.waveTestStore['ProgAttenuation'][key])
                    resSummary.append(resultTuple)
            self.MyReport.InsertDetailedTable(resSummary, columns=[3.0*inch, 1.5*inch])   
            
        
        if len(self.clientAnalysisStore['clientFlowList'].keys()) > 0:
            self.MyReport.InsertParagraph("")
            self.MyReport.InsertHeader("Client Analysis Parameters") 
            self.MyReport.InsertParagraph("The table below shows the input parameters for Client Analysis")
            resSummary = [('Client Flw Name', 'Src IP/MAC', 'Src Port', 'Dst IP/MAC', 'Dst Port', 'Metric')]
            for itm in self.clientAnalysisStore['clientFlowList']:
                resultTuple = []
                resultTuple.append(itm)
                resultTuple.append(self.clientAnalysisStore['clientFlowList'][itm]['srcNode'])
                resultTuple.append(self.clientAnalysisStore['clientFlowList'][itm]['srcPort1'])
                resultTuple.append(self.clientAnalysisStore['clientFlowList'][itm]['dstNode'])
                resultTuple.append(self.clientAnalysisStore['clientFlowList'][itm]['dstPort1'])
                resultTuple.append(self.clientAnalysisStore['clientFlowList'][itm]['metric'])
                resSummary.append(resultTuple)
            self.MyReport.InsertDetailedTable(resSummary, columns=[0.8*inch, 1.0*inch, 1.6*inch, 1.0*inch, 1.6*inch, 0.8*inch])
            self.MyReport.InsertParagraph("")

        
        if self.ecoSystemClientExist or self.testType == "WiMix":
            
            self.MyReport.InsertHeader("Test Parameters") 
            self.MyReport.InsertParagraph("The table below shows the input parameters for the test")            
            resSummary = [('Parameter', 'Value')]
            for key in self.testParameters.keys():
                resultTuple = (key, self.testParameters[key])
                resSummary.append(resultTuple)
            self.MyReport.InsertDetailedTable(resSummary, columns=[3.0*inch, 1.5*inch])   
        
            self.MyReport.InsertParagraph("")
            
            
            if self.wimixMode == 0:
                self.MyReport.InsertParagraph("The table below shows the Traffic Mix for the test")            
                resSummary = [('Traffic Profile', 'Type', 'Client Type', '% Traffic', 'Traffic in Kbps', 'Traffic in pps')]
            
                mixProfile = self.wimixTrafficCentricProfiles['profiles'][self.wimixTrafficCentricProfiles['testProfile']]
                totLoad = mixProfile['loadVal']
                for ii in range (0, len(mixProfile['trafficList'])):
            	    tProf = mixProfile['trafficList'][ii]
            	    tType =  self.TrafficTypes[tProf]['Type']
            	    cType = mixProfile['clientGroupList'][ii]
            	    ptraffic = mixProfile['perTraffic'][ii]
            	    trafKbps = ptraffic * totLoad / 100     
            	    trafPps = mixProfile['loadPps'][ii]       	
                    resultTuple = (tProf,tType,cType,ptraffic,trafKbps,trafPps)
                    resSummary.append(resultTuple)
                self.MyReport.InsertDetailedTable(resSummary, columns=[2.0*inch, 0.75*inch, 1.0*inch, 0.5*inch, 0.75*inch, 0.75*inch])   
        
            elif self.wimixMode == 1:
                self.MyReport.InsertParagraph("The table below shows the Client Mix for the test")    
                if self.testType == "WaveClient":        
                    resSummary = [('Client Type', 'Traffic Profiles', 'Num Clients')]
                else: 
                    resSummary = [('Client Type', 'Traffic Profiles', '% Clients', 'Num Clients')]    
            
                mixProfile = self.wimixClientCentricProfiles['profiles'][self.wimixClientCentricProfiles['testProfile']]
                totLoad = mixProfile['loadVal']
                for ii in range (0, len(mixProfile['clientList'])):
            	    ctype = mixProfile['clientList'][ii]
            	    tProfs = mixProfile['trafficList'][ii]
            	    pClients = mixProfile['perClients'][ii]
            	    #numClients = pClients * totLoad / 100      
            	    numClients = mixProfile['numClients'][ii]
            	    if self.testType == "WaveClient": 
            	        resultTuple = (ctype,tProfs,numClients)
            	    else:
            	        resultTuple = (ctype,tProfs,pClients,numClients)    
                    resSummary.append(resultTuple)
                if self.testType == "WaveClient":     
            	    self.MyReport.InsertDetailedTable(resSummary, columns=[1.0*inch, 4.0*inch, 0.5*inch])  
                else:	
                    self.MyReport.InsertDetailedTable(resSummary, columns=[1.0*inch, 4.0*inch, 0.5*inch, 0.5*inch])  
        
            self.MyReport.InsertParagraph("")  
        
            self.MyReport.InsertParagraph("The table below shows SLA Specifications for the Traffic Flows in the Test")            
            resSummary = [('Traffic profile', 'SLA Metrics and Requirement')]
        
                
            for key in self.loadPerTrafficProfileDict:
                slaStr = ""
                for met in self.TrafficTypes[key]['SLA']:
            	    vFlag = False
            	    if met == "Latency" or met == "Jitter" or met == "Df" or met == "Mlr":
                        units = " msecs "
                    elif met == "Goodput":
                        units = "Kbps "
                    elif met == "PacketLoss" or met == "perLoad": 
                        units = " % "
                    elif met == "slaMode": 
                        vFlag = True	
                        if self.TrafficTypes[key]['SLA'][met] == 0:
                            slaStr = slaStr + met + " = " + "R-value  , " 
                        else:
                            slaStr = slaStr + met + " = " + "MoS Score , "        
                    elif met == "playDelay":
                        units = " secs"
                    else:
                        units = ""   
                    if vFlag == False: 
                       if met == "perLoad":
                           slaInKbps = self.TrafficTypes[key]['SLA'][met] * self.loadPerTrafficProfileDict[key] / 100.0
                           slaStr = slaStr + met + " = " + str(self.TrafficTypes[key]['SLA'][met]) + units +  " (" + str(slaInKbps) + " Kbps)"
                       elif met == "contPlay":
                           if int(self.TrafficTypes[key]['SLA'][met]) == 0:
                               slaStr = slaStr + met + " = " + " Yes" + " , "	
                           else:
                               slaStr = slaStr + met + " = " + " No" + " , "    
                       else:                   	     
            	           slaStr = slaStr + met + " = " + str(self.TrafficTypes[key]['SLA'][met]) + units + " , "
            	   
                resultTuple = (key, slaStr)
                resSummary.append(resultTuple)
            self.MyReport.InsertDetailedTable(resSummary, columns=[2.0*inch, 4.0*inch])   
        
        
            self.MyReport.InsertPageBreak()
        
            self.insertAPinfoTable(RSSIfileName = self.RSSILogFileName,reportObject = self.MyReport)
        
        self.MyReport.InsertHeader("Other Information") 
        OtherParameters = []
        OtherParameters.append( ( 'Results Directory',  str( self.LoggingDirectory ) )  )
        for item in self.OtherInfoData.items():
            OtherParameters.append( item )
        OtherParameters.append( ( 'WaveTest Version',   str( action.getVclVersionStr() ) ) )
        self.MyReport.InsertGenericTable( OtherParameters , columns = [ 1.5*inch, 4.5*inch ] ) 
               
        
        if self.generatePdfReportF:        
            self.MyReport.Print() 
    
    
    def clientMixGetClientTypeResults(self, totalOLoad, totalILoad, totalALoad):
    	self.clientTypeResultsDict = dict()
                
        #for clType in self.wimixProfiles[self.testProfileList[0]].keys():
        for clType in self.wimixClientCentricProfiles['profiles'][self.testProfileList[0]]['clientList']:
            clIload = 0
            clOload = 0
            clAload = 0
            slaCount = 0
            clcount = 0
            flwTypeStr = ""
            clIndx = self.wimixClientCentricProfiles['profiles'][self.testProfileList[0]]['clientList'].index(clType)
            tList = self.wimixClientCentricProfiles['profiles'][self.testProfileList[0]]['trafficList'][clIndx].split(",")
            #for flwTypes in self.wimixProfiles[self.testProfileList[0]][clType]['traffic']:
            for flwTypes in tList:
            	flwTypeStr = flwTypeStr + self.TrafficTypes[flwTypes]['Type'] + ", "
            for fckeys in self.flowsPerClientsDict.keys():
            	slaFalseFlag = 0            	
            	if self.flowsPerClientsDict[fckeys]['type'] == clType:
            	    clcount += 1
            	    for flwName in self.flowsPerClientsDict[fckeys]['flows']:
            	    	clIload += self.IOAloadPerFlowDict[flwName]['iload']
                        clOload += self.IOAloadPerFlowDict[flwName]['oload']
                        clAload += self.IOAloadPerFlowDict[flwName]['aload']
                        if self.IOAloadPerFlowDict[flwName]['sla'] == False:
                            slaFalseFlag = 1
            	    if slaFalseFlag == 0:
            	        slaCount += 1
            
            if clcount != 0:
               perSla = slaCount * 100 / clcount 
            else:
               perSla = 0    
            
            if totalOLoad != 0:
                perOLoad = clOload * 100 / totalOLoad
            else:
                perOLoad = 0    
            
            if totalILoad != 0:
                perILoad = clIload * 100 / totalILoad
            else:
                perILoad = 0
            
            if totalALoad != 0:
                perALoad = clAload * 100 / totalALoad
            else:
                perALoad = 0    
            
            self.clientTypeResultsDict[clType] = {'periload' : perILoad, 'peroload' : perOLoad, \
                                'peraload' : perALoad, 'persla' : perSla, 'clcount' : clcount, 'flowtypes' :flwTypeStr }	  	 
        
        coLoadPieDict = dict()
        ciLoadPieDict = dict()
        caLoadPieDict = dict()        
        for kkys in self.clientTypeResultsDict.keys():
            coLoadPieDict[kkys] = self.clientTypeResultsDict[kkys]['peroload']
            ciLoadPieDict[kkys] = self.clientTypeResultsDict[kkys]['periload']
            caLoadPieDict[kkys] = self.clientTypeResultsDict[kkys]['peraload']	
        
        
        self.MyReport.InsertHeader("Per Client Type Results")
        
                     
        self.MyReport.InsertParagraph("")
        self.MyReport.InsertParagraph("")
        
        resSla = [('Client Type', 'Number of Clients', 'Flow Types', '% of Clients that met SLA')]
        
        self.ResultsForCSVfile.append( resSla[0] )
        
        passFailValsList =[]
        passFailClientNames = []
        for kkeys in self.clientTypeResultsDict.keys():
            if int(self.clientTypeResultsDict[kkeys]['clcount']) > 0:
                resSla.append([kkeys, self.clientTypeResultsDict[kkeys]['clcount'], self.clientTypeResultsDict[kkeys]['flowtypes'], self.clientTypeResultsDict[kkeys]['persla']])    	
                self.ResultsForCSVfile.append( [kkeys, self.clientTypeResultsDict[kkeys]['clcount'], self.clientTypeResultsDict[kkeys]['flowtypes'], self.clientTypeResultsDict[kkeys]['persla']] )
                passFailValsList.append((self.clientTypeResultsDict[kkeys]['persla'], 100 - self.clientTypeResultsDict[kkeys]['persla']))
                passFailClientNames.append(kkeys)
        
        if len(passFailValsList) > 0:
            clPassFailGraph = PassFailGraph(6*inch, 2.5*inch,passFailClientNames,passFailValsList, 'PASS/FAIL Percentages of Clients that met SLA', options=PF_OPTION_SHOWPERCENT | PF_OPTION_LEGENDRIGHT)
            self.MyReport.InsertObject(clPassFailGraph)
            self.finalGraphs['PASS/FAIL Percentages for Client Types that met SLA'] = clPassFailGraph
        
        self.MyReport.InsertParagraph("The Table below shows the percentage of Clients of each client type that satisfied the SLA") 
        self.MyReport.InsertParagraph("Note: If any of the traffic flows on a client dont meet the SLA the client is considered to not meet SLA")        
        
        self.MyReport.InsertDetailedTable(resSla, columns=[1.5*inch, 1.0*inch, 2.0*inch, 1.0*inch])
        
        
        clSummaryGraph2 = self.getPieChartObject(ciLoadPieDict, coLoadPieDict, caLoadPieDict, totalILoad, totalOLoad, totalALoad)
        self.MyReport.InsertObject(clSummaryGraph2)
        #self.finalGraphs['Pie Charts for IOA Loads per Client Type'] = clSummaryGraph2
        
        ciLoadList = []
        coLoadList = []
        caLoadList = []
        clList = []
        for kys in ciLoadPieDict.keys():
            ciLoadList.append(round(ciLoadPieDict[kys] * totalILoad / 100))
            coLoadList.append(round(coLoadPieDict[kys] * totalOLoad / 100))
            caLoadList.append(round(caLoadPieDict[kys] * totalALoad / 100))
            clList.append(kys)	
        
        
        clTypeAbsIOAResults = Qlib.GenericGraph(ciLoadPieDict.keys(), "Client Types", [ciLoadList,coLoadList,caLoadList ] , \
                         "Load Values in Kbps", "iLoad, oLoad and aLoad per Client Type", ['Bar'], [["iLoad"],["oLoad"], ["aLoad"]])
        self.MyReport.InsertObject(clTypeAbsIOAResults)
        self.finalGraphs['Bar Charts for IOA Loads per Client Type'] = clTypeAbsIOAResults
    
    
    def getInfo(self):
    	Method = """The WiMix Real-World Deployment Test accurately replicates the complex interaction of clients, servers and traffic profiles in wireless LANs. By creating usage profiles and traffic mixtures that were found to be representative in various network environments, the test measures and reports key application layer metrics that affect end-user Quality of Experience. The test also reports if the Service Level Agreement criteria set by the user for the different application layer traffic types have been met. The real-world networks replicated include: enterprise, health-care, education and retail. Each deployment model is characterized by a mix of clients, servers, client locations and behavior, traffic mix and other characteristics. These clients and servers can be configured to use different security schemes, run various higher layer applications, and utilize different QoS functions of the network. Users may also create their own application and client mixes if so desired."""
        return Method
        
    
    def createClientsForFlows(self,cType, numClientsPerPort, tList, wimixProfile, trailNum, derPps, clNum):   	
    	
    	if cType not in self.numClientPerGroup.keys():
    	    self.numClientPerGroup[cType] = 0    		    
    	
    	biFlowList = []    	
    	clIntType = 0
    	
    	ssid = self.clientGroups[cType]['ssid']
    	
    	if self.clientGroups[cType]['type'] == "802.3 Ethernet":
    	    clIntType = 1
    	    portsWithSsid = [self.clientGroups[cType]['portName'],]
    	    clBaseName = "ethClient"
    	elif self.clientGroups[cType]['type'] == "WaveAgent" or self.clientGroups[cType]['IncrIp'] == "WaveAgent":
    	    clIntType = 2
    	    portsWithSsid = self.ethCards
    	    clBaseName = "waveAgentClient"    
    	else:    	
    	    clIntType = 0
    	    if self.clientGroupTestMode	== 0:
    	        portsWithSsid = self.findPortsWithSsid(ssid)  
    	        if portsWithSsid == -1:
    	            raise WaveEngine.RaiseException 
    	    else:
    	        portsWithSsid = [self.clientGroups[cType]['portName'],]        
    	    clBaseName = "wifiClient"       
        
        port_num = 0                            
        for prt in portsWithSsid:      
            port_num += 1          
            for ii in range(0,numClientsPerPort):
            	
            	if self.wimixMode == 1:
                    #currClName = clBaseName + "_"  + prt + "_"  + cType + "_"  + tList[0] + str(ii)
                    currClName = clBaseName + "_"  + prt + "_"  + cType + "_" + str(ii)
                elif self.wimixMode == 0:
                    currClName = clBaseName + "_"  + prt + "_"  + cType + "_"  + tList[0] + "_"  + str(ii)    
                
                igmp_client_Flag = False
                
                if ii == 0:
                    for tType in tList:                    
                        direction = self.TrafficTypes[tType]['Direction']             
                        if direction == "multicast(downlink)":
                            igmp_client_Flag = True
                
                if igmp_client_Flag:
                    self.igmpResponderClientList.append((currClName,ssid, prt,clIntType))    
                
                #### Create the wireless client ########
                       
                
                if clIntType in [1, 2]:
                    bssid = "00:00:00:00:00:00"
                else:  
                    if self.clientGroupTestMode	== 0:   
                        ssidIndex = self.networkMap[prt]['ssid'].index(ssid)
                        bssid = self.networkMap[prt]['bssid'][ssidIndex]
                    else:
                        bssid = self.clientGroups[cType]['bssid']   
                
                
                if int(self.clientGroups[cType]['ipMode']) == 0:
                    startIP = "0.0.0.0" 
                else:
                    startIP = self.clientGroups[cType]['ipAddress']  
                                                      
                netmask = self.clientGroups[cType]['subnetMask']
                gateway = self.clientGroups[cType]['gateway']
                
                if startIP == "0.0.0.0":
                	ip_addr = startIP
                else:
                    ipBytes = startIP.split('.')
                    ip_addr = ipBytes[0] + "." + ipBytes[1] + "." + ipBytes[2] + "." + str(int(ipBytes[3]) + self.numClientPerGroup[cType])     
                                
                self.numClientPerGroup[cType] += 1
                
                clOptions = odict.OrderedDict()
                if self.clientGroups[cType]['Qos'] == "Enable":
                    clOptions['WmeEnabled'] = "on"
                
                
                clPsOptions = {}
                
                if int(self.clientGroups[cType]['Uapsd']) == 1:
                    clPsOptions['WmeUapsd'] = "on"
                    clPsOptions['WmeUapsdAcFlags'] = int(self.clientGroups[cType]['UapsdFlags'])
                    clPsOptions['WmeUapsdSpLength'] = int(self.clientGroups[cType]['UapsdSp'])
                    clPsOptions['ListenInterval'] = int(self.clientGroups[cType]['ListenInt'])
                    
                    clOptions['WmeUapsd'] = "on"
                    clOptions['WmeUapsdAcFlags'] = int(self.clientGroups[cType]['UapsdFlags'])
                    clOptions['WmeUapsdSpLength'] = int(self.clientGroups[cType]['UapsdSp'])
                    clOptions['ListenInterval'] = int(self.clientGroups[cType]['ListenInt'])
                    
                elif int(self.clientGroups[cType]['LegacyPs']) == 1:                    
                    clPsOptions['PowerSave'] = "on"
                    clPsOptions['ListenInterval'] = int(self.clientGroups[cType]['ListenInt'])   
                    
                    clOptions['PowerSave'] = "on"
                    clOptions['ListenInterval'] = int(self.clientGroups[cType]['ListenInt'])   
                
                self.clientPowerSaveOptionsDict[currClName] = clPsOptions     
                                   
                
                clOptions['enableNetworkInterface'] = True
                
                if self.clientGroups[cType]['AssocProbe'] == "Unicast":                
                    clOptions['ProbeBeforeAssoc'] = "unicast"
                elif self.clientGroups[cType]['AssocProbe'] == "Broadcast":
                    clOptions['ProbeBeforeAssoc'] = "bdcast"
                else:
                    clOptions['ProbeBeforeAssoc'] = "off"
                
                clOptions['PhyType'] = self.clientGroups[cType]['phyType']
                
                #clOptions['FerLevel'] = "50"    
                if self.clientGroups[cType]['CtsToSelf'] in ["True", "1"]:               
                    clOptions['CtsToSelf'] = "on"
                elif self.clientGroups[cType]['CtsToSelf'] in ["False", "0"]:               
                    clOptions['CtsToSelf'] = "off"    
                elif int(self.clientGroups[cType]['CtsToSelf']) == 1:
                    clOptions['CtsToSelf'] = "on"
                else:
                    clOptions['CtsToSelf'] = "off"
                                    
                if self.clientGroups[cType]['TransmitDeference'] in ["True", "1"]: 
                    clOptions['TxDeference'] = "on"
                elif self.clientGroups[cType]['TransmitDeference'] in ["False", "0"]: 
                    clOptions['TxDeference'] = "off"    
                elif int(self.clientGroups[cType]['TransmitDeference']) == 1:
                    clOptions['TxDeference'] = "on"
                else:
                    clOptions['TxDeference'] = "off"
                     
                clOptions['RetryMgmt'] = int(self.clientGroups[cType]['MgmtRetries'])
                clOptions['RetryData'] = int(self.clientGroups[cType]['DataRetries'])
                
                if self.clientGroups[cType]['CwMin'] != "default":
                    clOptions['CwMin'] = int(self.clientGroups[cType]['CwMin'])
                
                if self.clientGroups[cType]['CwMax'] != "default":     
                    clOptions['CwMax'] = int(self.clientGroups[cType]['CwMax'])
                
                if int(self.clientGroups[cType]['Sifs']) != 0:     
                    clOptions['Sifs'] = int(self.clientGroups[cType]['Sifs'])
                    
                if int(self.clientGroups[cType]['Difs']) != 0:
                    clOptions['Aifs'] = int(self.clientGroups[cType]['Difs'])
                
                if int(self.clientGroups[cType]['SlotTime']) != 0:
                    clOptions['SlotTime'] = int(self.clientGroups[cType]['SlotTime'])
                    
                if int(self.clientGroups[cType]['AckTimeout']) != 0:    
                    clOptions['AckTimeout'] = int(self.clientGroups[cType]['AckTimeout'])
                
                
                clOptions['TxPower'] = int(self.clientGroups[cType]['TxPower'])
                
                if self.clientGroups[cType]['GratuitousArp'] == "True":
                    clOptions['GratuitousArp'] = "on"
                else:
                    clOptions['GratuitousArp'] = "off" 
                
                                
                WaveEngine.VCLtest("port.read('%s')" % (prt))
                if port.getRadioMaxPower() == 15:                
                    clOptions['TxPower'] = int(self.clientGroups[cType]['HpTxPower'])   
                               
                clOptions['FerLevel'] = int(self.clientGroups[cType]['FerVal'])
                
                if 'BehindNat' in self.clientGroups[cType]:
                    if int(self.clientGroups[cType]['BehindNat']) != 0:
                        self.clientsBehindNatList.append(currClName)    
                               
                
                if self.clientGroups[cType]['phyType'] == "11n":
                    clOptions['WmeEnabled'] = "on"
                    clOptions['DataMcsIndex'] = self.clientGroups[cType]['dataMcsIndex']
                    clOptions['ChannelBandwidth'] = self.clientGroups[cType]['channelBandwidth']
                    clOptions['GuardInterval'] = self.clientGroups[cType]['guardInterval']
                    clOptions['PlcpConfiguration'] = str(self.clientGroups[cType]['plcpConfiguration'])
                    clOptions['ChannelModel'] = str(self.clientGroups[cType]['channelModel'])
                    if int(self.clientGroups[cType]['enableAMPDUaggregation']) == 0:
                        clOptions['AggregationEnabled'] = "off"
                    else:
                        clOptions['AggregationEnabled'] = "on"    
                        self.clientsWithAggregation.append(currClName)
                else:
                    clOptions['PhyRate'] = float(self.clientGroups[cType]['MgmtPhyRate']) 
                 
                if self.clientGroups[cType]['macAddress'] == "AUTO":
                    #mac_addr = self.RandomMAC()	
                    mac_addr = self.clientGroups[cType]['macAddress']                                  
                else: 
                    startMac = self.clientGroups[cType]['macAddress']	
                    mBytes = startMac.split(':')                    
                    mBytes[5] = str('%0.2x' % (int(mBytes[5]) + self.currMacIncrCountDict[cType]))
                    self.currMacIncrCountDict[cType] += 1                    
                    mac_addr = mBytes[0] + ":" + mBytes[1] + ":" + mBytes[2] + ":" + mBytes[3] + ":" + mBytes[4] + ":" + mBytes[5]
                                    
                if clIntType in [1, 2]:
                    clientOptions = {}
                    if self.clientGroups[cType]['VlanEnable'] == "True":
    	                clientOptions['VlanTag'] = (0 & 0x7 )* 2**13 + (0 & 0x1 ) * 2**12 + (self.clientGroups[cType]['VlanId'] & 0xfff )     	        
    	            clientOptions['enableNetworkInterface'] = True
                    clientData = [(currClName, prt, '00:00:00:00:00:00', mac_addr, ip_addr, netmask, gateway, (1, "AUTO", '0.0.0.1'), {'Method': 'NONE'}, clientOptions)]
                else:                       
                    clientData = [(currClName, prt, bssid, mac_addr, ip_addr, netmask, gateway, (1, "AUTO", '0.0.0.1'), self.clientGroups[cType]['security'], clOptions)]
                
                self.ClientsDict[currClName] = clientData 
                self.srcClients[currClName] = clientData
                cl_dict = WaveEngine.CreateClients(clientData)
                
                if clIntType == 1:
                    self.clientPortDict[currClName] = (prt, 'ec') 
                if clIntType == 2:
                    self.clientPortDict[currClName] = (prt, 'wa')     
                elif clIntType == 0:
                    self.clientPortDict[currClName] = (prt, 'mc')                
                    self.ApScanClientDict[currClName] = (1, prt, 'mc')
                
                ### Add wireless clients to the list #####
                if clIntType != 2:
                    for kys in cl_dict.keys():
                        self.clientList[kys] = cl_dict[kys]
                else:
                    for kys in cl_dict.keys():
                        self.waClientList[kys] = cl_dict[kys]        
                
                
                for tType in tList:                    
                    direction = self.TrafficTypes[tType]['Direction']             
                                                        
                    if direction == "multicast(downlink)":
                    	self.multicastTrafficExistsFlag = True
                    	
                    	if self.TrafficTypes[tType]['MulticastAddr']['ipAddress'] not in self.mcastIpList:
                    	    self.multicastDummyDestCreated = False
                    	
                    	if self.multicastDummyDestCreated == False:
                    	    mcastIp = self.TrafficTypes[tType]['MulticastAddr']['ipAddress']
                    	    self.mcastIpList.append(self.TrafficTypes[tType]['MulticastAddr']['ipAddress'])
                    	    self.mcastMac = self.TrafficTypes[tType]['MulticastAddr']['macAddress']
                    	    
                    	    mstClName = "mcastDummy_" + str(mcastIp)
                    	    
                    	    if mcastIp not in self.mcastDummyClientDict:
                    	        self.mcastDummyClientDict[mcastIp] = (mstClName, self.mcastMac,clIntType)
                    	    
                    	    if clIntType == 1:
                    	        clientData = [(mstClName, prt, '00:00:00:00:00:00', self.mcastMac, mcastIp, netmask, \
                    	               gateway, (1, '00:00:00:00:10:02', '0.0.0.1'), {'Method': 'NONE'}, {})]
                    	    else:
                    	        clientData = [(mstClName, prt, bssid, self.mcastMac, mcastIp, netmask, \
                    	               gateway, (1, '00:00:00:00:10:02', '0.0.0.1'), self.clientGroups[cType]['security'], {})]
                    	    
                    	    
                            WaveEngine.CreateClients(clientData)
                            self.multicastDummyDestCreated = True
                    
                    
                    if direction == "unicast(downlink)":
                    	self.unicastTrafficExistsFlag = True
                    	
                    	if self.TrafficTypes[tType]['MulticastAddr']['ipAddress'] not in self.ucastIpList:
                    	    self.unicastDummyDestCreated = False
                    	
                    	if self.unicastDummyDestCreated == False:
                    	    ucastIp = self.TrafficTypes[tType]['MulticastAddr']['ipAddress']
                    	    self.ucastIpList.append(self.TrafficTypes[tType]['MulticastAddr']['ipAddress'])
                    	    ucastMac = self.TrafficTypes[tType]['MulticastAddr']['macAddress']
                    	    
                    	    ustClName = "ucastDummy_" + str(ucastIp)
                    	    
                    	    if ucastIp not in self.ucastDummyClientDict:
                    	        self.ucastDummyClientDict[ucastIp] = (ustClName, ucastMac, clIntType)
                    	    
                    	    if clIntType == 1:
                    	        clientData = [(ustClName, prt, '00:00:00:00:00:00', ucastMac, ucastIp, netmask, \
                    	               gateway, (1, '00:00:00:00:10:02', '0.0.0.1'), {'Method': 'NONE'}, {})]
                    	    else:
                    	        clientData = [(ustClName, prt, bssid, ucastMac, ucastIp, netmask, \
                    	               gateway, (1, '00:00:00:00:10:02', '0.0.0.1'), self.clientGroups[cType]['security'], {})]
                    	    
                    	    
                            WaveEngine.CreateClients(clientData)
                            self.unicastDummyDestCreated = True
                    
                              
                                                   
        return 0            
     
    def createClientsFlows(self,cType, numClientsPerPort, tList, wimixProfile, trailNum, derPps,delayVal,endTime):   	
    	
    	if cType not in self.numClientPerGroup.keys():
    	    self.numClientPerGroup[cType] = 0    		    
    	    	
    	biFlowList = []
    	clIntType = 0
    	
    	##### Find all the ports on which SSID exisits
    	ssid = self.clientGroups[cType]['ssid']
    	
    	if self.clientGroups[cType]['type'] == "802.3 Ethernet":
    	    clIntType = 1
    	    portsWithSsid = [self.clientGroups[cType]['portName'],]
    	    clBaseName = "ethClient"
    	    flowPhyRate = 54
    	elif self.clientGroups[cType]['type'] == "WaveAgent" or self.clientGroups[cType]['IncrIp'] == "WaveAgent":
    	    clIntType = 2
    	    portsWithSsid = self.ethCards
    	    clBaseName = "waveAgentClient"   
    	    flowPhyRate = 54     
    	else:    	
    	    clIntType = 0
    	    if self.clientGroupTestMode	== 0:	
    	        portsWithSsid = self.findPortsWithSsid(ssid)  
    	        if portsWithSsid == -1:
    	            raise WaveEngine.RaiseException 
    	    else:
    	        portsWithSsid = [self.clientGroups[cType]['portName'],]        
    	    clBaseName = "wifiClient"   
            flowPhyRate = self.clientGroups[cType]['DataPhyRate']
                                           
        for port in portsWithSsid:                
            for ii in range(0,numClientsPerPort):
            	if self.wimixMode == 1:
                    #currClName = clBaseName + "_"  + port + "_"  + cType + "_"  + tList[0] + str(ii)  
                    currClName = clBaseName + "_"  + port + "_"  + cType + "_" + str(ii)                                 
                elif self.wimixMode == 0:
                    currClName = clBaseName + "_"  + port + "_"  + cType + "_"  + tList[0] + "_"  + str(ii)    
                clFlowList = []
                                
                #### Create traffic flows ####################
                
                #tList = self.wimixClientCentricProfiles['profiles'][self.testProfileList[0]]['trafficList'][clIndx].split(",")
                jj = 0
                
                
                for tType in tList:
                    trafficType = self.TrafficTypes[tType]['Type']
                                                  
                    if 'Framesize' in self.TrafficTypes[tType].keys():
                        fSize = int(self.TrafficTypes[tType]['Framesize'])
                    else:
                        fSize = 256
                        
                    
                    if 'NumFrames' in self.TrafficTypes[tType].keys():
                        numFrames = int(self.TrafficTypes[tType]['NumFrames'])
                    else:
                        numFrames = 100000000
                                        
                    phyRate = flowPhyRate
                        
                    if 'Intendedrate' in self.TrafficTypes[tType].keys():
                     	if derPps == "Auto":                    	
                            iRate = int(self.TrafficTypes[tType]['Intendedrate'])
                        else:
                            iRate = derPps 
                            rateMode = 1   
                    else:
                        iRate = 100                                       
                    
                    if 'RateMode' in self.TrafficTypes[tType].keys():
                        rateMode = int(self.TrafficTypes[tType]['RateMode'])
                    else:
                        rateMode = 1 
                    
                    if 'Ttl' in self.TrafficTypes[tType].keys():
                        ttlVal = int(self.TrafficTypes[tType]['Ttl'])
                    else:
                        ttlVal = 64
                    
                    if 'tcpWinSize' in self.TrafficTypes[tType].keys():
                        tcpWinSize = int(self.TrafficTypes[tType]['tcpWinSize'])
                    else:
                        tcpWinSize = 65535
                    
                    
                    if derPps != "Auto":   
                    	rateMode = 1       
                    
                    burstDataDict = {}                         
                    if self.wimixMode == 1:
                        if 'RateBehaviour' in self.TrafficTypes[tType]:
                            if int(self.TrafficTypes[tType]['RateBehaviour']) == 1:	
                                if 'burstData' in self.TrafficTypes[tType]:
                                    #burstInt = self.TrafficTypes[tType]['burstData']['ibg']	
                                    #burstDur = self.TrafficTypes[tType]['burstData']['burstDur']
                                    #burstRate = self.TrafficTypes[tType]['burstData']['burstRate']
                                    burstDataDict = self.TrafficTypes[tType]['burstData'].copy()
                    
                    if 'payPattern' in self.TrafficTypes[tType].keys():
                        payPattern = int(self.TrafficTypes[tType]['payPattern'])
                    else:
                        payPattern = 0
                    
                    if 'payData' in self.TrafficTypes[tType].keys():
                        payData = str(self.TrafficTypes[tType]['payData'])
                    else:
                        payData = ""
                    
                    appPayload = {'payPattern':payPattern, 'payData': payData}    
                    
                    options = self.TrafficTypes[tType]['Layer4to7']
                    
                    direction = self.TrafficTypes[tType]['Direction']
                    
                    mcastIp = ""
                    if direction == "multicast(downlink)" or direction == "multicast(uplink)":
                    	mcastIp = self.TrafficTypes[tType]['MulticastAddr']['ipAddress']
                                        
                    qosDict = {}
                    qosDict['layer2Qos'] = self.TrafficTypes[tType]['layer2Qos']
                    qosDict['layer3Qos'] = self.TrafficTypes[tType]['layer3Qos']
                    qosDict['ipProtocolNum'] = self.TrafficTypes[tType]['ipProtocolNum']
                    
                    if rateMode == 1:
                        iRatePps = iRate
                        iRateKbps = round(iRate * fSize * 8 / 1000, 0)
                    elif rateMode == 0:     
                        iRatePps = round(iRate * 1000 / (fSize * 8), 0)
                        iRateKbps = iRate                    
                    
                    eClName = self.TrafficTypes[tType]['Server']
                    
                    if tType not in self.loadPerTrafficProfileDict:
                        self.loadPerTrafficProfileDict[tType] = iRateKbps
                    
                    
                    if 'SLA' in self.TrafficTypes[tType].keys():
                    	slaReq = self.TrafficTypes[tType]['SLA']
                    	for kys in slaReq:
                    	    slaReq[kys] = int(slaReq[kys])
                    else:
                        slaReq = {}
                    
                    flwList = [] 
                    
                    if clIntType in [1, 2]:
                        WaveEngine.VCLtest("ec.read('%s')" % (currClName))
                        clIp = ec.getIpAddress()
                        clMac = ec.getMacAddress()
                        bssid = "00:00:00:00:00:00"
                    else:
                        WaveEngine.VCLtest("mc.read('%s')" % (currClName))
                        clIp = mc.getIpAddress()
                        clMac = mc.getMacAddress()
                        bssid = mc.getBssidList()[0]
                    
                    
                    if eClName in self.wifiServerList:
                        WaveEngine.VCLtest("mc.read('%s')" % (eClName))
                        srvIp = mc.getIpAddress()
                        srvMac = mc.getMacAddress()
                    else:
                        WaveEngine.VCLtest("ec.read('%s')" % (eClName))
                        srvIp = ec.getIpAddress()
                        srvMac = ec.getMacAddress()
                    
                    clPort = port
                    srvPort = self.serverList[eClName]['ethPort']
                    
                    flowDiagInfo = (clIp,srvIp,clMac,srvMac,clPort,srvPort,ssid,bssid)
                    
                    
                    if direction == "unicast(downlink)":
                    	ucastIp = self.TrafficTypes[tType]['MulticastAddr']['ipAddress'] 
                        if ucastIp in self.ucastDummyClientDict:
                            currClName = self.ucastDummyClientDict[ucastIp][0]	
                        else:       	
                            currClName = "ucastDummyClient"
                        
                        self.clientPortDict[currClName] = self.wifiCards    
                    
                    
                    if self.serverList[eClName]['serverType'] == 1 and self.clientPortDict[currClName][1] == "wa":
                    	self.Print("Both Client and Server cannot of Interface Type WaveAgent..Exiting the Test...\n")
                        raise WaveEngine.RaiseException 
                    
                                        	                                    
                    if trafficType == "VOIP":
                    	flwList = self.setupBiDirectionalVoiceFlow(currClName, eClName, phyRate, trafficType, direction, options, wimixProfile, trailNum, slaReq, qosDict,jj,flowDiagInfo,delayVal,endTime,numFrames,clIntType,ttlVal,appPayload,tType,burstDataDict)                            	
                    elif trafficType in ["FTP", "HTTP", "TCP", "TCPVideo", "TCPAudio"]:
                    	#biFlowList.append((currClName, eClName, fSize, phyRate, iRatePps, iRateKbps, trafficType, direction, options, wimixProfile, trailNum, slaReq, qosDict))
                        flwList = self.setupBiFlow(currClName, eClName, fSize, phyRate, iRatePps, iRateKbps, trafficType, direction, options, wimixProfile, trailNum, slaReq, qosDict,jj,flowDiagInfo,delayVal,endTime,numFrames,ttlVal,appPayload,tType,burstDataDict,tcpWinSize)
                    elif trafficType == "UDP" or trafficType == "RTP":
                        flwList = self.setupUdpRtpFlows(currClName, eClName, fSize, phyRate, iRatePps, iRateKbps, trafficType, direction, options, wimixProfile, trailNum, slaReq, qosDict,jj,flowDiagInfo,delayVal,endTime,numFrames,ttlVal,appPayload,tType,burstDataDict)
                    elif trafficType == "RTPVideo" or trafficType == "RTPAudio":  
                    	flwList = self.setupRTPVideoAudioFlows(currClName, eClName, fSize, phyRate, iRatePps, iRateKbps, trafficType, direction, options, wimixProfile, trailNum, slaReq, qosDict, portsWithSsid,jj,flowDiagInfo,mcastIp,delayVal,endTime,clIntType,numFrames,ttlVal,appPayload,tType,burstDataDict)
                    
                    jj += 1
                    
                    if flwList != None:
                        for flwNm in flwList:
                            clFlowList.append(flwNm) 
                                                                                    
                clientInfoDict = {}
                clientInfoDict['type'] = cType
                clientInfoDict['flows'] = clFlowList    
                                               
                self.flowsPerClientsDict[currClName] = clientInfoDict
    
        
    def createTrafficMixTest(self, wimixProfile, trailNum, flg):   
    	tfList = self.wimixTrafficCentricProfiles['profiles'][wimixProfile]['trafficList']
    	
    	for ii in range(0, len(tfList)):
    	    fType = self.wimixTrafficCentricProfiles['profiles'][wimixProfile]['trafficList'][ii]
    	    cType = self.wimixTrafficCentricProfiles['profiles'][wimixProfile]['clientGroupList'][ii]
    	    delayVal = int(self.wimixTrafficCentricProfiles['profiles'][wimixProfile]['delay'][ii])  
    	    if self.wimixTrafficCentricProfiles['profiles'][wimixProfile]['endTime'][ii] == "END":
    	    	endTime = 100000000
    	    else: 	
    	        endTime = int(self.wimixTrafficCentricProfiles['profiles'][wimixProfile]['endTime'][ii])
    	        self.staggerStopCustomEnabled = True  	    
    	    if delayVal > 0:
    	        self.staggerStartCustomEnabled = True
    	         	          
    	    totalFlowLoadKbps = self.wimixTrafficCentricProfiles['profiles'][wimixProfile]['perTraffic'][ii] * self.loadInKbps / 100   
    	        	    	    
    	    direction = self.TrafficTypes[fType]['Direction']
    	    if direction == "bidirectional":
    	    	dirFactor = 2
    	    else:
    	        dirFactor = 1	
    	    
    	    derivedPps = self.wimixTrafficCentricProfiles['profiles'][wimixProfile]['loadPps'][ii]
    	    
    	    flowType = self.TrafficTypes[fType]['Type']
    	        	        	    
    	    if flowType == "VOIP":    	    	
    	    	if int(self.TrafficTypes[fType]['Layer4to7']['voipCodec']) == 0:
    	    	    loadPerClientFlow = 50 * 236 * dirFactor * 8 / 1000
    	    	    numClientsPerPort = int(totalFlowLoadKbps / loadPerClientFlow)    	    		    	
    	        elif int(self.TrafficTypes[fType]['Layer4to7']['voipCodec']) == 2:
    	    	    loadPerClientFlow = 50 * 96 * dirFactor * 8 / 1000
    	    	    numClientsPerPort = int(totalFlowLoadKbps / loadPerClientFlow)    	    	 
    	        elif int(self.TrafficTypes[fType]['Layer4to7']['voipCodec']) == 1:
    	    	    loadPerClientFlow = 33 * 96 * dirFactor * 8 / 1000
    	    	    numClientsPerPort = int(totalFlowLoadKbps / loadPerClientFlow)    	    		 	
    	    else:
    	        fixedPps = self.TrafficTypes[fType]['Intendedrate']
    	        numClientsPerPort = 1
    	        #numFlows = derivedPps / fixedPps
    	        #derivedPps = fixedPps
    	        #tList = []
    	        #for kk in range(0,numFlows):
    	        #    tList.append(fType)	
    	    
    	    tList = (fType,) 
    	    
    	    if flg == 0:                
    	        self.createClientsForFlows(cType, numClientsPerPort, tList, wimixProfile, trailNum, derivedPps, ii) 
    	    else:    
                self.createClientsFlows(cType, numClientsPerPort, tList, wimixProfile, trailNum, derivedPps,delayVal,endTime)
    
    def createClientMixTest(self, wimixProfile, trailNum, flg):	
    	ii = 0
    	for cType in self.wimixClientCentricProfiles['profiles'][wimixProfile]['clientList']:    
            clIndx = self.wimixClientCentricProfiles['profiles'][wimixProfile]['clientList'].index(cType)            
            delayVal = int(self.wimixClientCentricProfiles['profiles'][wimixProfile]['delay'][ii])    	
            if self.wimixClientCentricProfiles['profiles'][wimixProfile]['endTime'][ii] == "END":
    	    	endTime = 100000000
    	    else: 	
    	        endTime = int(self.wimixClientCentricProfiles['profiles'][wimixProfile]['endTime'][ii]) 
    	        self.staggerStopCustomEnabled = True    
    	        
            if delayVal > 0:
    	        self.staggerStartCustomEnabled = True
            ii += 1
            
            if self.testType == "WaveClient":
            	numClientsPerPort = int(self.clientGroups[cType]['NumClients'])            
            	self.wimixClientCentricProfiles['profiles'][wimixProfile]['numClients'][clIndx]	= numClientsPerPort
            else:	
                numClientsPerPort = int(self.wimixClientCentricProfiles['profiles'][wimixProfile]['perClients'][clIndx]) * self.numTotalClients / 100
            #numClientsPerPort = int(self.wimixClientCentricProfiles['profiles'][wimixProfile]['numClients'][clIndx])
            tList = self.wimixClientCentricProfiles['profiles'][self.testProfileList[0]]['trafficList'][clIndx].split(",")
            if flg == 0:
    	        self.createClientsForFlows(cType, numClientsPerPort, tList, wimixProfile, trailNum, "Auto", ii)
    	    else:    
                self.createClientsFlows(cType, numClientsPerPort, tList, wimixProfile, trailNum, "Auto",delayVal,endTime)
     
    
    def SaveOverTimeResultsToFile(self):
    	titleLine = ["Flow Name", "Metric"]
    	for samp in self.timeSampleList:
    	    titleLine.append(str(samp) + " secs")          
        self.ResultsForCSVOTRfile.append(titleLine)
        
        for flw in self.overTimeFlowResults:
            for mtric in self.overTimeFlowResults[flw]:
            	dataLine = []
                dataLine.append(flw)
                dataLine.append(mtric)
                for itm in self.overTimeFlowResults[flw][mtric]:
                    dataLine.append(itm)	
                self.ResultsForCSVOTRfile.append(dataLine)
                        
        WaveEngine.CreateCSVFile(os.path.join(self.LoggingDirectory, self.CSVOTRfilename), self.ResultsForCSVOTRfile)
    
    
    def CloseCapture(self): 
        # Have to destroy all TCP connections before we created the capture files
        if self.SavePCAPfile == False:
            if self.postProcessingNeeded == True:
               self.CardList = self.clientAnalysisPortsList   
        try:
            if self.SavePCAPfile or self.postProcessingNeeded:
                if self.PCAPFilename == None:
                    ScriptName = re.search("([.0-9a-zA-Z_-]+).py", sys._getframe(1).f_code.co_filename)
                    #self.PCAPFilename = "Hdwrlog_" + ScriptName.group(1)   
                    self.PCAPFilename = "Hdwrlog_" + self.testType + "_script"
                    if self.postProcessingNeeded and self.SavePCAPfile == False:
                        WaveEngine.GetLogFile(self.CardList, self.PCAPFilename, True, self.captureFormat)
                    else: 	
                        WaveEngine.GetLogFile(self.CardList, self.PCAPFilename, False, self.captureFormat)  
                            	           
        except WaveEngine.RaiseException:
            WaveEngine.OutputstreamHDL('\n', WaveEngine.MSG_OK)
            (exc_type, exc_value, exc_traceback) = sys.exc_info()
            WaveEngine.OutputstreamHDL(str(exc_value), WaveEngine.MSG_ERROR)
        #WaveEngine.OutputstreamHDL("Thank you for using VeriWave (http://www.veriwave.com)\n", WaveEngine.MSG_OK)
    
    
    
    def closeWimixShop(self):  
    	
    	if self.openedJfWLink:
    	    self.closeConnectionToJFW()
    		   	
    	if self.destroyedBiFlows == False:
            self.destroyBiflows()
            self.destroyedBiFlows = True
        if self.destroyedAppServers == False:
            self.destroyAppServers()   
            self.destroyedAppServers = True 
        
        if self.destroyedMulticastStuff == False:
            if self.multicastTrafficExistsFlag  == True:
                for igmpName in self.igmpResponderList:
                    WaveEngine.VCLtest("igmp.destroy('%s')" % igmpName)
                for dummyClient in self.mcastDummyClientDict: 
                    if self.mcastDummyClientDict[dummyClient][2] == 1:
                        WaveEngine.VCLtest("ec.destroy('%s')" % self.mcastDummyClientDict[dummyClient][0])
                    else:
                        WaveEngine.VCLtest("mc.destroy('%s')" % self.mcastDummyClientDict[dummyClient][0])    
                self.destroyedMulticastStuff = True   
        
        if self.destroyedUnicastStuff == False:
            if self.unicastTrafficExistsFlag  == True:
                for dummyClient in self.ucastDummyClientDict: 
                    if self.ucastDummyClientDict[dummyClient][2] == 1:
                        WaveEngine.VCLtest("ec.destroy('%s')" % self.ucastDummyClientDict[dummyClient][0])
                    else:
                        WaveEngine.VCLtest("mc.destroy('%s')" % self.ucastDummyClientDict[dummyClient][0])    
                self.destroyedUnicastStuff = True         
        
                                     
        self.SaveResults()
        self.SaveOverTimeResultsToFile()        
        if self.UserPassFailCriteria['User']== 'True':  
           if self.check_flag==0: 
              self.logintoDatabase()      
              self.check_flag=1
            
    
    def validateWimix(self):
    	
    	if 'clientFlowList' in self.clientAnalysisStore:
            for clFlow in self.clientAnalysisStore['clientFlowList']:
                if int(self.clientAnalysisStore['clientFlowList'][clFlow]['idMode']) not in [0,1]:
                    continue
                
                if len(self.clientAnalysisStore['clientFlowList'][clFlow]['srcNode']) < 8 and self.clientAnalysisStore['clientFlowList'][clFlow]['srcNode'] != "any":
                    WaveEngine.OutputstreamHDL("Error: The SRC IP/MAC address for the clientFlow %s should be a valid address" % (clFlow), WaveEngine.MSG_ERROR)
               	    return -1 
                if self.clientAnalysisStore['clientFlowList'][clFlow]['srcPort1'] == "None":
                    WaveEngine.OutputstreamHDL("Error: The SRC Log Port for the clientFlow %s should not be None" % (clFlow), WaveEngine.MSG_ERROR)
               	    return -1
                
                if len(self.clientAnalysisStore['clientFlowList'][clFlow]['dstNode']) < 8 and self.clientAnalysisStore['clientFlowList'][clFlow]['dstNode'] != "any":
                    WaveEngine.OutputstreamHDL("Error: The DST IP/MAC address for the clientFlow %s should a valid address" % (clFlow), WaveEngine.MSG_ERROR)
               	    return -1
                
                if len(self.clientAnalysisStore['clientFlowList'][clFlow]['ap1Bssid']) < 8 and self.clientAnalysisStore['clientFlowList'][clFlow]['ap1Bssid'] != "any":
                    WaveEngine.OutputstreamHDL("Error: The AP1 MAC address for the clientFlow %s should a valid address" % (clFlow), WaveEngine.MSG_ERROR)
               	    return -1 
                
                if self.clientAnalysisStore['clientFlowList'][clFlow]['metric'] == "Roaming Delay":                    
                    if self.clientAnalysisStore['clientFlowList'][clFlow]['dstPort1'] == "None":
                        WaveEngine.OutputstreamHDL("Error: The DST Log Port for the clientFlow %s should not be None" % (clFlow), WaveEngine.MSG_ERROR)
               	        return -1
                   
                    if len(self.clientAnalysisStore['clientFlowList'][clFlow]['ap2Bssid']) < 8 and self.clientAnalysisStore['clientFlowList'][clFlow]['ap2Bssid'] != "any":
                        WaveEngine.OutputstreamHDL("Error: The AP2 MAC address for the clientFlow %s should a valid address" % (clFlow), WaveEngine.MSG_ERROR)
               	        return -1  
                
                allAnys = True
                
                if self.clientAnalysisStore['clientFlowList'][clFlow]['srcNode'] != "any":
                    allAnys = False
                if self.clientAnalysisStore['clientFlowList'][clFlow]['dstNode'] != "any":
                    allAnys = False
                if int(self.clientAnalysisStore['clientFlowList'][clFlow]['l4SrcPort']) != 0:
                    allAnys = False
                if int(self.clientAnalysisStore['clientFlowList'][clFlow]['l4DstPort']) != 0:
                    allAnys = False    
                if self.clientAnalysisStore['clientFlowList'][clFlow]['l4Protocol'] != "any":
                    allAnys = False
                
                if allAnys:
                    WaveEngine.OutputstreamHDL("Error: Atleast one of the 5 filters (SRC IP/MAC, DST IP/MAC, Layer4 Protocol, Layer 4 SRC/DST port numbers) for the clientFlow %s should not be set to ANY" % (clFlow), WaveEngine.MSG_ERROR)
               	    return -1 
                
                
                srcPort = self.clientAnalysisStore['clientFlowList'][clFlow]['srcPort1']
                dstPort = self.clientAnalysisStore['clientFlowList'][clFlow]['dstPort1']
                
                if srcPort not in self.wifiCards + self.ethCards + self.monitorPortList + self.blogPortList:
                    WaveEngine.OutputstreamHDL("\n\nError: SRC Port : %s for client Flow %s not in the list of enabled ports in the test.\n" % (srcPort,clFlow), WaveEngine.MSG_ERROR)
                    return -1  
                
                if self.clientAnalysisStore['clientFlowList'][clFlow]['metric'] == "Roaming Delay":
                    if  dstPort not in self.wifiCards + self.ethCards + self.monitorPortList + self.blogPortList:
                        WaveEngine.OutputstreamHDL("\n\nError: DST Port : %s for client Flow %s not in the list of enabled ports in the test.\n" % (dstPort,clFlow), WaveEngine.MSG_ERROR)
                        return -1      
    	        
        if int(self.waveTestStore['TestParameters']['overTimeGraphs']) == 1 and int(self.waveTestStore['TestParameters']['progAttenFlag']) == 1:
            WaveEngine.OutputstreamHDL("\n\nWarning: Both Over-time charting and Programmble attenuation cannot be enabled at the same time in the test. This may lead to scheduling problems\n", WaveEngine.MSG_ERROR)
            #return -1
                
        if self.progAttenFlag:
            if self.trialDuration < self.progAttenTestTime:
                WaveEngine.OutputstreamHDL("\n\nError: The Trial Duration %d secs should not be less than % secs which is the time it takes to execute the programmable attenuation cycle.\n" % (self.trialDuration, self.progAttenTestTime), WaveEngine.MSG_ERROR)
                return -1
        
    	if len(self.monitorPortList) > 0 or  len(self.blogPortList) :
    	    if len(self.wifiCards) == 0 and len(self.ethCards) == 0:
    	        return 	    	
    	try:    	
    	    availableSsisList = []
    	    for prt in self.wavePortStore:
    	        for ssid in self.wavePortStore[prt].values():
    	            if ssid not in availableSsisList:
    	                availableSsisList.append(ssid)
    	    
    	    if len(self.waveClientTableStore.keys()) == 0:
    	        WaveEngine.OutputstreamHDL("Error: No client groups Configured", WaveEngine.MSG_ERROR)
                return -1
    	     
    	    self.numWifiGroups = 0
    	    self.numEthGroups = 0    	
    	    
    	    if self.numTrials > 1:
    	        if self.testParameters['Search Mode'] == "Linear Search":
    	            WaveEngine.OutputstreamHDL("Error: Cannot run a test with multiple trials when linear search is enabled.", WaveEngine.MSG_ERROR)
                    return -1
    	        
    	       	            	    	
    	    for clnt in self.waveClientTableStore:
    	        
    	        if self.waveClientTableStore[clnt]['Interface'].startswith("802.11") and self.waveClientTableStore[clnt]['IncrIp'] != "WaveAgent":
    	            self.numWifiGroups += 1
                    if self.waveClientTableStore[clnt]['IncrIp'] != "WaveAgent" and int(self.waveClientTableStore[clnt]['NumClients']) != 0:
    	                if self.waveClientTableStore[clnt]['Ssid'] not in availableSsisList:
    	        	    WaveEngine.OutputstreamHDL("SSID : %s configured for Client Group %s is not available in the list of available networks. \n Please select an SSID from the networks scanned on the Port Page" % (self.waveClientTableStore[clnt]['Ssid'], clnt), WaveEngine.MSG_ERROR)
                            return -1
                        
                    if self.waveClientTableStore[clnt]['PortName'] not in self.wifiCards:
                        if self.clientGroupTestMode != 0:
    	        	    WaveEngine.OutputstreamHDL("Port configured for Client Group %s is not available in the list of 802.11a/b/g/n Ports. \nPlease select a valid port\n" % (clnt), WaveEngine.MSG_ERROR)
                            return -1    
                else:
                    self.numEthGroups += 1
                
                if self.waveClientTableStore[clnt]['MacAddressMode'] == "Increment":
                    if len(self.waveClientTableStore[clnt]['MacAddress']) < 17:
                        WaveEngine.OutputstreamHDL("Error: Base MAC address of Client %s should be a valid MAC address.\n" % (clnt), WaveEngine.MSG_ERROR)
                        return -1
                               
            
            if ((self.numEthGroups * self.numWifiGroups) != 0) and (self.clientGroupTestMode == 0) and self.testType != "WaveClient":
                WaveEngine.OutputstreamHDL("Error: All Client Groups need to be of the same Interface Type (Ethernet or Wireless) when Port Assignment mode is set to Auto", WaveEngine.MSG_ERROR)
                return -1             	    
    	    
    	    for srvs in self.serverList:
    	        if self.serverList[srvs]['serverType'] == 0:
    	            if self.serverList[srvs]['ethPort'] not in self.ethCards:
    	                WaveEngine.OutputstreamHDL("Server: %s is configured on port %s which is not available in the list of ports on the port page." % (srvs, self.serverList[srvs]['ethPort']), WaveEngine.MSG_ERROR)
                        return -1 
    	    
    	    srvIpList = []
    	    srvMacList = []
    	    for srvs in self.serverList:
    	        if self.serverList[srvs]['ipMode'] == 1:
    	            srvIpList.append(self.serverList[srvs]['ipAddress'])
    	        if self.serverList[srvs]['macMode'] == 0:
    	            srvMacList.append(self.serverList[srvs]['macAddress'])
    	    
    	    if len(srvIpList) != 0:
    	        if len(srvIpList) != len(set(srvIpList)):
    	            WaveEngine.OutputstreamHDL("Server: Duplicate IP addresses detected in server profiles.", WaveEngine.MSG_ERROR)
                    return -1      
            
            if len(srvMacList) != 0:
    	        if len(srvMacList) != len(set(srvMacList)):
    	            WaveEngine.OutputstreamHDL("Server: Duplicate MAC addresses detected in server profiles.", WaveEngine.MSG_ERROR)
                    return -1       	
    	            
    	        	    	
    	    for tfTyp in self.TrafficTypes:
    	        if self.TrafficTypes[tfTyp]['Server'] not in self.serverList.keys():
    	            WaveEngine.OutputstreamHDL("Server Name: %s for Traffic Flow : %s is not available in the list of servers from the server page." % (self.TrafficTypes[tfTyp]['Server'], tfTyp), WaveEngine.MSG_ERROR)
                    return -1   	
    	    
                #if self.TrafficTypes[tfTyp]['Direction'] == "multicast(downlink)" or self.TrafficTypes[tfTyp]['Direction'] == "multicast(uplink)":
                #    if self.TrafficTypes[tfTyp]['Type'] not in ["RTpVideo", "RTPAudio"]:
                #        WaveEngine.OutputstreamHDL("Traffic Flow : %s is configured for multicast traffic. This test supports multicast only for RTP Video/Audio flows. \n Please change your config and run the test." % (tfTyp), WaveEngine.MSG_ERROR)
                #   	    return -1
                
                if self.TrafficTypes[tfTyp]['Framesize'] < 76:
                    if self.TrafficTypes[tfTyp]['Type'] != "UDP":
                        WaveEngine.OutputstreamHDL("All Traffic Flows except for Type UDP should have a minimim frame size of 76 bytes", WaveEngine.MSG_ERROR)
                   	return -1 
                
                if self.TrafficTypes[tfTyp]['Direction'] == "bidirectional":
                    if self.TrafficTypes[tfTyp]['Type'] == "FTP" or self.TrafficTypes[tfTyp]['Type'] == "HTTP" or self.TrafficTypes[tfTyp]['Type'] == "TCP":
                        WaveEngine.OutputstreamHDL("Traffic Flow : %s is configured for bi-directional traffic which is not supported. Please create two seperate traffic flows for uplink and downlink." % (tfTyp), WaveEngine.MSG_ERROR)
                   	return -1   	    
            
            if self.wimixMode == 1:   
                
                if 'profiles' not in self.wimixClientCentricProfiles:
                    WaveEngine.OutputstreamHDL("No Client Mix Defined in the test", WaveEngine.MSG_ERROR)
                    return -1
                
                if 'testProfile' not in self.wimixClientCentricProfiles:
                    WaveEngine.OutputstreamHDL("No Test Profile defined in Client Mix test", WaveEngine.MSG_ERROR)
                    return -1
                
                if len(self.wimixClientCentricProfiles['profiles'][self.wimixClientCentricProfiles['testProfile']]['clientList']) == 0:
                    WaveEngine.OutputstreamHDL("No Client Types selected in the Client Mix", WaveEngine.MSG_ERROR)
                    return -1            	
                
                          
                for tN in self.wimixClientCentricProfiles['profiles'][self.wimixClientCentricProfiles['testProfile']]['trafficList']: 
                    for tItem in tN.split(","):	
                        if tItem not in self.TrafficTypes.keys():
                            WaveEngine.OutputstreamHDL("Traffic Profile %s is not available from the Traffic Page" % (tItem), WaveEngine.MSG_ERROR)
                   	    return -1
                
                lCount = 0   	    
                for cL in self.wimixClientCentricProfiles['profiles'][self.wimixClientCentricProfiles['testProfile']]['clientList']: 
                    if cL not in self.waveClientTableStore.keys():
                        WaveEngine.OutputstreamHDL("Client Type %s is not available from the Client Page" % (cL), WaveEngine.MSG_ERROR)
                   	return -1
                    
                    if self.waveClientTableStore[cL]['IncrIp'] == "WaveAgent":
                        tN = self.wimixClientCentricProfiles['profiles'][self.wimixClientCentricProfiles['testProfile']]['trafficList'][lCount]
                        for tItem in tN.split(","):
                            if self.TrafficTypes[tItem]['Direction'] != "bidirectional":
                                WaveEngine.OutputstreamHDL("Error: Traffic Profile %s set to be created on the WaveAgent client group %s needs to be bidirectional \n    traffic stream which sets the WaveAgent flow in loopback mode which is the only mode supported in this version. " % (tItem,cL), WaveEngine.MSG_ERROR)
                   	        return -1
                                
                        
                    lCount += 1    
                
                for ii in range(0, len(self.wimixClientCentricProfiles['profiles'][self.wimixClientCentricProfiles['testProfile']]['numClients'])):
                    ld = self.wimixClientCentricProfiles['profiles'][self.wimixClientCentricProfiles['testProfile']]['numClients'][ii]
                    delay = int(self.wimixClientCentricProfiles['profiles'][self.wimixClientCentricProfiles['testProfile']]['delay'][ii])
                    if delay >= self.trialDuration:
                	WaveEngine.OutputstreamHDL("Error:Atleast one of the Client Start Delays is greater than the Trial Duration. .", WaveEngine.MSG_ERROR)
                        return -1
                    if ld < 1 and self.testType != "WaveClient":
                        clType = self.wimixClientCentricProfiles['profiles'][self.wimixClientCentricProfiles['testProfile']]['clientList'][ii]
                        WaveEngine.OutputstreamHDL("The number of clients for Client Type %s cannot be less than 1" % (clType), WaveEngine.MSG_ERROR)
                   	return -1 
                    	                  	
            elif self.wimixMode == 0:  
            
               if 'profiles' not in self.wimixTrafficCentricProfiles:
                    WaveEngine.OutputstreamHDL("No Traffic Mix Defined in the test", WaveEngine.MSG_ERROR)
                    return -1
               
               if 'testProfile' not in self.wimixTrafficCentricProfiles:
                    WaveEngine.OutputstreamHDL("No Test Profile defined in Traffix Mix test", WaveEngine.MSG_ERROR)
                    return -1
               
               if len(self.wimixTrafficCentricProfiles['profiles'][self.wimixTrafficCentricProfiles['testProfile']]['trafficList']) == 0:
                    WaveEngine.OutputstreamHDL("No Traffic Profiles selected in the Traffic Mix", WaveEngine.MSG_ERROR)
                    return -1      	
                        	
               for tN in self.wimixTrafficCentricProfiles['profiles'][self.wimixTrafficCentricProfiles['testProfile']]['trafficList']: 
                    if tN not in self.TrafficTypes.keys():
                        WaveEngine.OutputstreamHDL("Traffic Profile %s is not available from the Traffic Page" % (tN), WaveEngine.MSG_ERROR)
                   	return -1
                   	
               for cL in self.wimixTrafficCentricProfiles['profiles'][self.wimixTrafficCentricProfiles['testProfile']]['clientGroupList']: 
                    if cL not in self.waveClientTableStore.keys():
                        WaveEngine.OutputstreamHDL("Client Type %s is not available from the Client Page" % (cL), WaveEngine.MSG_ERROR)
                   	return -1 
               
               for ii in range(0, len(self.wimixTrafficCentricProfiles['profiles'][self.wimixTrafficCentricProfiles['testProfile']]['perTraffic'])):
                    ld = self.wimixTrafficCentricProfiles['profiles'][self.wimixTrafficCentricProfiles['testProfile']]['perTraffic'][ii]
                    delay = int(self.wimixTrafficCentricProfiles['profiles'][self.wimixTrafficCentricProfiles['testProfile']]['delay'][ii])
                    if delay >= self.trialDuration:
                	WaveEngine.OutputstreamHDL("Error:Atleast on of the Traffic Start Delays is greater than the Trial Duration. .", WaveEngine.MSG_ERROR)
                        return -1
                    if ld <= 0:
                        tfType = self.wimixTrafficCentricProfiles['profiles'][self.wimixTrafficCentricProfiles['testProfile']]['trafficList'][ii]
                        WaveEngine.OutputstreamHDL("Error: The percentage Load for Traffic Type %s cannot be zero." % (tfType), WaveEngine.MSG_ERROR)
                   	return -1      	    	
                    lPps = self.wimixTrafficCentricProfiles['profiles'][self.wimixTrafficCentricProfiles['testProfile']]['loadPps'][ii]
                    if lPps <= 0:
                        tfType = self.wimixTrafficCentricProfiles['profiles'][self.wimixTrafficCentricProfiles['testProfile']]['trafficList'][ii]
                        WaveEngine.OutputstreamHDL("Error: The Load in Pps for Traffic Type %s cannot be zero." % (tfType), WaveEngine.MSG_ERROR)
                   	return -1 
              
            return 0
            
        except:
            return 0    
    
    
    def setTrafficMixPpsForNewLoad(self, wimixProfile):    	
    	tfList = self.wimixTrafficCentricProfiles['profiles'][wimixProfile]['trafficList']
    	currLoadVal = self.wimixTrafficCentricProfiles['profiles'][wimixProfile]['loadVal']
    	for ii in range(0, len(tfList)):
    	    fProfType = self.wimixTrafficCentricProfiles['profiles'][wimixProfile]['trafficList'][ii]    	    
    	    fType = self.TrafficTypes[fProfType]['Type']    	    
    	    if fType not in ("G711", "G723", "G729"):
    	        newPps = round(self.wimixTrafficCentricProfiles['profiles'][wimixProfile]['loadPps'][ii] * ( self.loadInKbps * 1.0 / currLoadVal ), 0)   	        
    	        self.wimixTrafficCentricProfiles['profiles'][wimixProfile]['loadPps'][ii] = newPps
    	
    	self.wimixTrafficCentricProfiles['profiles'][wimixProfile]['loadVal'] = self.loadInKbps
    	
    	
    def initiateOverTimeResDict(self):
    	self.overTimeResultsDict = {}
        
        for fName in self.flowTypeDict:
            fType = self.flowTypeDict[fName][0]
            oTimeSubDict = {}
            
            if fType == "VOIP":
            	oTimeSubDict['Forwarding Rate'] = [] 
            	oTimeSubDict['R-value'] = []
            	oTimeSubDict['MoS Score'] = []
            elif fType in ["http", "ftp", "tcp", "TCPAudio", "TCPVideo"]: 
            	oTimeSubDict['Goodput'] = []
                oTimeSubDict['Forwarding Rate'] = [] 
            elif fType in ["RTPVideo", "RTPAudio"]: 
            	oTimeSubDict['Forwarding Rate'] = [] 
            	oTimeSubDict['Delay Factor'] = []  
            	oTimeSubDict['Media Loss Ratio'] = []  
            	oTimeSubDict['Latency'] = []   
            	oTimeSubDict['Jitter'] = []            	
            elif fType in ["udp", "rtp"]: 
            	oTimeSubDict['Forwarding Rate'] = [] 
            	oTimeSubDict['Latency'] = []   
            	oTimeSubDict['Jitter'] = []
            	oTimeSubDict['Packet Loss'] = []             		
            
            self.overTimeResultsDict[fName] = oTimeSubDict             
        #self.overTimeResultsDict['sampleTime'] = self.resultSampleTime
    
    
    def startStaggerFlow(self, fName):  
    	WaveEngine.VCLtest("flowGroup.read('staggerFlowGroup')")    	 
    	for fgname in flowGroup.getNames():
           WaveEngine.VCLtest("flowGroup.remove('%s')" % (fgname))      	 
        WaveEngine.VCLtest("flowGroup.add('%s')" % (fName))
        WaveEngine.VCLtest("flowGroup.write('staggerFlowGroup')")   
        WaveEngine.VCLtest("action.startFlowGroup('%s')" % ("staggerFlowGroup"))
        WaveEngine.OutputstreamHDL("\nStarting Flow %s" % (fName), WaveEngine.MSG_OK)                   	    
    
    
    def stopStaggerFlow(self, fName):  
    	WaveEngine.VCLtest("flowGroup.read('staggerFlowGroup')")    	 
    	for fgname in flowGroup.getNames():
           WaveEngine.VCLtest("flowGroup.remove('%s')" % (fgname))      	 
        WaveEngine.VCLtest("flowGroup.add('%s')" % (fName))
        WaveEngine.VCLtest("flowGroup.write('staggerFlowGroup')")   
        WaveEngine.VCLtest("action.stopFlowGroup('%s')" % ("staggerFlowGroup"))
        WaveEngine.OutputstreamHDL("\nStopping Flow %s" % (fName), WaveEngine.MSG_OK)    
         
   
    def startStaggerStart(self):
    	WaveEngine.VCLtest("flowGroup.create('staggerFlowGroup')")   	
    	WaveEngine.VCLtest("flowGroup.write('staggerFlowGroup')")       	
    	step = 0
    	scheduler = sched.scheduler(time.time, time.sleep)      	
    	for ii in range(0, len(self.flowTypeDict)):
    	    scheduler.enter(step,0, self.startStaggerFlow,(ii,))
    	    step += self.staggerStartInt
        scheduler.run()                        
    	
    
    def stopTest(self, val):
        return
    	if val == 3: 
    	    if self.staggerStopCustomEnabled:
                for flName in self.flowTypeDict:
                    if flName not in self.stoppedFlowsList:
    	                self.stopStaggerFlow(flName)
    	                self.flowStopTimes[flName] = time.time()
            else:                             
                WaveEngine.VCLtest("action.stopFlowGroup('%s')" % ("mainFlowGroup"))  
                for flName in self.flowTypeDict:
                    self.flowStopTimes[flName] = time.time()
    	
    	    
    	    self.testDurationStop = time.time()                   
                        
            self.trialDuration = round((self.testDurationStop - self.testDurationStart),0)
            
                                                                                 
            self.trafficFlowsStarted = False
            self.trafficFlowsEnded = True
            
            self.voiceCallSetupTeardown(1)
                                           
            WaveEngine.Sleep(self.settleTime,  "System Settle Time.....") 
            
            self.slaReqMetForTrail = True
            self.Print("Getting the Flow Stats and Computing the results...Please Wait...\n")
            self.getFlowStats() 
                        
            self.disconnectBiflows(self.biFlowDisconnectTimeout, self.biFlowConnectRate) 
                                                
            WaveEngine.Sleep(self.agingTime,  "System Aging Time.....") 
            
            #### End of flows ......" 
            
            if self.printReport() == -1:
                if self.continueTestOnFail == False:
                    raise WaveEngine.RaiseException
                    
            self.closeWimixShop() 
            self.CloseCapture()                   
            self.DisconnectFlowsAndClients()                       
            WaveEngine.CloseLogging()
    	    
    
    def DisconnectFlowsAndClients(self):
        for fgname in flowGroup.getNames():
            action.stopFlowGroup(fgname)
            WaveEngine.VCLtest("flowGroup.destroy('%s')" % (fgname))        
        for flowname in flow.getNames():
            WaveEngine.VCLtest("flow.destroy('%s')" % (flowname))
        for name in mc.getNames():
            WaveEngine.VCLtest("mc.deauthenticate('%s', %d)" % (name, 1)) 
            WaveEngine.VCLtest("mc.destroy('%s')" % (name))
        for name in ec.getNames():
            WaveEngine.VCLtest("ec.destroy('%s')" % (name))
        for portname in port.getNames():
            WaveEngine.VCLtest("port.destroy('%s')" % (portname))    
    
    
    def setupBlogPort(self, Portname, intPer, channel):
    	
    	bin4High = 2340
        bin4Low  = 1765
        bin3High = 1765
        bin3Low  = 1190
        bin2High = 1190
        bin2Low  =  615
        bin1High =  615
        bin1Low  =   40
        
            	
    	WaveEngine.OutputstreamHDL("Setting up %d percent Interference on IG Port %s \n\n" % (intPer,Portname), WaveEngine.MSG_SUCCESS)
    	
    	#for prt in self.createdDynamicBlogPortList:
    	#    WaveEngine.VCLtest("port.destroy('%s')" %(prt))
        WaveEngine.VCLtest("port.destroy('%s')" %(Portname))
    	self.createdDynamicBlogPortList = []
    	ChassisName = str(Portname.split('_')[0])
        card_str = str(Portname.split('_')[1])
        CardNumber = int(card_str.lstrip('card'))
        port_str = str(Portname.split('_')[2])
        PortNumber = int(port_str.lstrip('port')) - 1
        
        #print Portname, ChassisName, CardNumber, PortNumber
        
        WaveEngine.VCLtest("port.create('%s')" % (Portname))
        WaveEngine.VCLtest("port.bind('%s', '%s', %s, %s)" % (Portname, ChassisName, CardNumber, PortNumber) )
        WaveEngine.VCLtest("port.reset('%s')" % (Portname))
        WaveEngine.VCLtest("port.setRadio('on')")
        WaveEngine.VCLtest("port.write('%s')" %(Portname))
        
        WaveEngine.VCLtest("port.read('%s')" %(Portname))    
        WaveEngine.VCLtest("port.setOperationalMode('og')")
        
        if int(channel) in [1,2,3,4,5,6,7,8,9,10,11,12,13,14]:
            WaveEngine.VCLtest( "port.setRadioBand( %d )" % 2400 )  
        else:
            WaveEngine.VCLtest( "port.setRadioBand( %d )" % 5000 )        
        WaveEngine.VCLtest("port.setRadioChannel(%d)" % int(channel))    
        
        #WaveEngine.VCLtest("port.setChannel(%d)" % int(channel))
        WaveEngine.VCLtest("port.write('%s')" %(Portname))
        
        WaveEngine.VCLtest("port.read('%s')" %(Portname))           
        
        WaveEngine.VCLtest("port.setOgBin4Low(%d)" % bin4Low, globals())
        WaveEngine.VCLtest("port.setOgBin4High(%d)" % bin4High, globals())
        WaveEngine.VCLtest("port.setOgBin4Probability(%d)" % intPer, globals())
        
        WaveEngine.VCLtest("port.setOgBin3Low(%d)" % bin3Low, globals())
        WaveEngine.VCLtest("port.setOgBin3High(%d)" % bin3High, globals())
        WaveEngine.VCLtest("port.setOgBin3Probability(%d)" % intPer, globals())
        
        WaveEngine.VCLtest("port.setOgBin2Low(%d)" % bin2Low, globals())
        WaveEngine.VCLtest("port.setOgBin2High(%d)" % bin2High, globals())
        WaveEngine.VCLtest("port.setOgBin2Probability(%d)" % intPer, globals())
        
        WaveEngine.VCLtest("port.setOgBin1Low(%d)" % bin1Low, globals())
        WaveEngine.VCLtest("port.setOgBin1High(%d)" % bin1High, globals())
        WaveEngine.VCLtest("port.setOgBin1Probability(%d)" % intPer, globals())      
                     
        WaveEngine.VCLtest("port.write('%s')" %(Portname))
    
        
    def startBurstFlow(self, fName, numFrames):      	
    	WaveEngine.VCLtest("flow.read('%s')" % (fName))
    	WaveEngine.VCLtest("flow.setNumFrames(%d)" % (numFrames))
    	WaveEngine.VCLtest("flow.write('%s')" % (fName))
    	
    	WaveEngine.VCLtest("flowGroup.read('burstFlowGroup')")    	 
    	for fgname in flowGroup.getNames():
           WaveEngine.VCLtest("flowGroup.remove('%s')" % (fgname))      	 
        WaveEngine.VCLtest("flowGroup.add('%s')" % (fName))
        WaveEngine.VCLtest("flowGroup.write('burstFlowGroup')")   
        WaveEngine.VCLtest("action.startFlowGroup('%s')" % ("burstFlowGroup"))
        #WaveEngine.OutputstreamHDL("\nStarting Burst Flow %s" % (fName), WaveEngine.MSG_OK)   
        
    
    def stopBurstFlow(self, fName):  
    	WaveEngine.VCLtest("flowGroup.read('burstFlowGroup')")    	 
    	for fgname in flowGroup.getNames():
           WaveEngine.VCLtest("flowGroup.remove('%s')" % (fgname))      	 
        WaveEngine.VCLtest("flowGroup.add('%s')" % (fName))
        WaveEngine.VCLtest("flowGroup.write('burstFlowGroup')")   
        WaveEngine.VCLtest("action.stopFlowGroup('%s')" % ("burstFlowGroup"))
        #WaveEngine.OutputstreamHDL("\nStopping Burst Flow %s" % (fName), WaveEngine.MSG_OK)   
        
       
    def stopAndStartBurstFlow(self, schedItems):    
    	flowsThisTime = []	
    	for itm in schedItems:
    	    flName = itm['flowName']
    	    if flName not in flowsThisTime:
    	        flowsThisTime.append(flName)
    	        numFrames = itm['numFrames']
    	        if flName in self.currentListOfStartedFlows:
    	            self.stopBurstFlow(flName)
    	            self.startBurstFlow(flName, numFrames)    	        
    	        else:
    	            self.startBurstFlow(flName, numFrames) 
    	            self.currentListOfStartedFlows.append(flName) 
    	
    
    def setSecondaryChannelOnPorts(self):
    	for PortName in self.secondaryChannelDict:
    	    WaveEngine.VCLtest("port.read('%s')" % (PortName))
    	    secChannel = self.secondaryChannelDict[PortName]
    	    if secChannel == 0:
                WaveEngine.VCLtest("port.setSecondaryChannelPlacement('defer')")
            elif secChannel == 1:     
                WaveEngine.VCLtest("port.setSecondaryChannelPlacement('below')")
            else:
                WaveEngine.VCLtest("port.setSecondaryChannelPlacement('above')")    
    	    WaveEngine.VCLtest("port.write('%s')" % (PortName))
        
    
    def run(self):
    	try:
    	    self.ExitStatus = 0 
    	    startTime = time.time()
    	        	      	    
    	    if self.validateWimix() == -1:
    	        WaveEngine.OutputstreamHDL("\n\nAborting the Test", WaveEngine.MSG_ERROR)
               	return self.ExitStatus
    	    tSTimer = time.time()
    	    for wimixProfile in self.testProfileList: 
    	        trailNum = 0  
    	        trlNum = 1  
    	        self.ClientsDict = dict()
    	        
    	        for tNum in range(0, len(self.loadList)): 
    	        	
    	            
    	            self.initializeVars()	
    	            if self.continueTestOnFail == False:	
    	                if self.slaReqMetForTrail == False:
    	                    print "exiting..." 
    	                    self.closeWimixShop()                    
                            self.DisconnectFlowsAndClients()   
    	                    return self.ExitStatus       
    	              	                                	   	        	 
                    biFlowList = []
                    self.clientList = dict()
                    self.waClientList = dict()
    	            self.clientPortDict = dict()
    	            self.flowTypeDict = dict()
    	            self.flowIloadDict = dict()
    	            self.flowsPerClientsDict = dict()
    	            self.arpFlowList = []
    	            self.srcClients = dict()
    	            self.destClients = dict()
    	            self.ApScanClientDict = dict()
    	            self.igmpResponderClientList = []
    	            self.multicastTrafficExistsFlag = False
    	            self.unicastTrafficExistsFlag = False
    	            self.multicastDummyDestCreated = False
    	            self.unicastDummyDestCreated = False
    	            self.setupMulticastFlowFlag = False
    	            
    	            self.sipClientPairs = []
    	            self.multicastFlowList = []    
    	            
    	            self.loadPerTrafficProfileDict = {}	 
    	            self.clientsBehindNatList = []           
    	            
    	            if self.testType == "WiMix":
    	                if self.wimixMode == 0:
    	                    self.loadInKbps = self.loadList[tNum]
                            if self.numTrials > 1:
                                self.ReportFilename = "Report_" + self.testType + "_" + str(self.loadInKbps) + "_Kbps" + "_trial" + str(trlNum) + ".pdf"
                            else:    
    	                        self.ReportFilename = "Report_" + self.testType + "_" + str(self.loadInKbps) + "_Kbps" + ".pdf"
    	                    self.CSVfilename = "Results_" + self.testType + "_" + str(self.loadInKbps) + "_Kbps" + ".csv"
    	                    self.CSVOTRfilename = "Results_" + self.testType + "_over_time_" + str(self.loadInKbps) + "_Kbps" + ".csv"
                            self.DetailedFilename = "Detailed_Results_" + self.testType + "_" + str(self.loadInKbps) + "_Kbps" + ".csv"    
                            self.ConsoleLogFileName = "Console_" + self.testType + "_script_"  + str(self.loadInKbps) + "_Kbps" + ".html"
                            self.TimeLogFileName = "Timelog_" + self.testType + "_script_"  + str(self.loadInKbps) + "_Kbps" + ".txt"   
                            self.RSSILogFileName = "RSSI_" + self.testType + "_script_"  + str(self.loadInKbps) + "_Kbps" + ".csv"                    	            
    	                    self.setTrafficMixPpsForNewLoad(wimixProfile)
    	                elif self.wimixMode == 1:
    	                    self.numTotalClients = self.loadList[tNum]  
    	                    self.ReportFilename = "Report_" + self.testType + "_" + str(self.numTotalClients) + "_clients"  + ".pdf"
    	                    self.CSVfilename = "Results_" + self.testType + "_" + str(self.numTotalClients) + "_clients"  + ".csv"
    	                    self.CSVOTRfilename = "Results_" + self.testType + "_over_time_" + str(self.numTotalClients) + "_clients"  + ".csv"
                            self.DetailedFilename = "Detailed_Results_" + self.testType + "_" + str(self.numTotalClients) + "_clients"  + ".csv"    
                            self.ConsoleLogFileName = "Console_" + self.testType + "_script_"  + str(self.numTotalClients) + "_clients"   + ".html"
                            self.TimeLogFileName = "Timelog_" + self.testType + "_script_"  + str(self.numTotalClients) + "_clients"   + ".txt"  
                            self.RSSILogFileName = "RSSI_" + self.testType + "_script_"  + str(self.numTotalClients) + "_clients"   + ".csv" 
                    else:
                        if self.numTrials > 1:
                            self.ReportFilename = "Report_" + self.testType + "_trial" + str(trlNum) + ".pdf"
                        else:    
    	                    self.ReportFilename = "Report_" + self.testType  + ".pdf"                       
    	                self.CSVfilename = "Results_" + self.testType  + ".csv"
    	                self.CSVOTRfilename = "Results_" + self.testType  + ".csv"
                        self.DetailedFilename = "Detailed_Results_" + self.testType  + ".csv"    
                        self.ConsoleLogFileName = "Console_" + self.testType + ".html"
                        self.TimeLogFileName = "Timelog_" + self.testType + ".txt"  
                        self.RSSILogFileName = "RSSI_" + self.testType + ".csv" 
                                    
    	            self.ExitStatus = 0  
    	            self.initReport()
    	            if tNum == 0:
    	                self.initailizeCSVfile()   
                    WaveEngine.OpenLogging(Path=self.LoggingDirectory, Timelog = self.TimeLogFileName, Console = self.ConsoleLogFileName, RSSI = self.RSSILogFileName, Detailed = self.DetailedFilename)   	         	
    	            trailNum = 1
    	            
    	            chassisName = self.CardMap[self.CardMap.keys()[0]][0]
    	            WaveEngine.VCLtest("chassis.connect('%s')" % chassisName)
    	            
                    # wimix verion info declared in GUI and not available to 
                    # automation
    	            try:
                        WaveEngine.OutputstreamHDL("WiMix version %s \n" % self.OtherInfoData['WiMix Version'], WaveEngine.MSG_OK)    	            
                    except:
                        pass
    	            WaveEngine.OutputstreamHDL("WaveEngine Version %s\n" % WaveEngine.full_version, WaveEngine.MSG_OK)
                    WaveEngine.OutputstreamHDL("Framework Version %s\n" % WaveEngine.action.getVclVersionStr(), WaveEngine.MSG_OK)
                    WaveEngine.OutputstreamHDL("Firmware Version %s\n\n\n" % chassis.version, WaveEngine.MSG_OK)
    	            
    	            WaveEngine.VCLtest("chassis.disconnect('%s')" % chassisName)
    	            
    	            if self.reconnectClientsForTrial == 1:    	            
    	                if self.wimixMode == 0:
    	                    WaveEngine.OutputstreamHDL("Trial %d (Date/Time): %s (%d seconds into the test): Running Test for %s Traffic Mix Profile, for %d Kbps Load per AP/Port\n\n" % (trlNum,datetime.datetime.fromtimestamp(time.time()), int(time.time() - tSTimer), wimixProfile, self.loadInKbps), WaveEngine.MSG_OK)  
    	                    trialStr = "Trial %d (Date/Time): %s (%d seconds into the test): Running Test for %s Traffic Mix Profile, for %d Kbps Load per AP/Port" % (trlNum,datetime.datetime.fromtimestamp(time.time()), int(time.time() - tSTimer), wimixProfile, self.loadInKbps)
    	                    self.ResultsForCSVfile.append([trialStr,],)      
    	                else:
    	                    WaveEngine.OutputstreamHDL("Trial %d (Date/Time): %s (%d seconds into the test): Running Test for %s Client Mix Profile, for %d clients per AP/Port\n\n" % (trlNum, datetime.datetime.fromtimestamp(time.time()), int(time.time() - tSTimer),wimixProfile, self.numTotalClients), WaveEngine.MSG_OK)
                            trialStr = "Trial %d (Date/Time): %s (%d seconds into the test): Running Test for %s Client Mix Profile, for %d clients per AP/Port" % (trlNum, datetime.datetime.fromtimestamp(time.time()), int(time.time() - tSTimer),wimixProfile, self.numTotalClients)
                   	    self.ResultsForCSVfile.append([trialStr,],)
                   	         	            
    	            if self.numTrials > 1:
    	                trlNum += 1
                         	            
    	            self.connectWimixPorts(self.CardList, self.CardMap, self.PortOptions, self.filterFlowFrames)
                    
                    if self.progAttenFlag:
                        if self.openedJfWLink == False:
    	                    self.openConnectionToJFW(self.progAttenIp)   
                    
                    for prt in self.perPortOptions:
                        partCode = self.perPortOptions[prt]['partCode']
                        WaveEngine.VCLtest("port.read('%s')" % (prt))
                                                
                        if len(partCode) > 5:
                            if partCode[0] != '1' and partCode[5] != '1':
                                if self.perPortOptions[prt]['rxAttenuation'] == "True":
                                    WaveEngine.VCLtest("port.setEnableRxAttenuation('on')")
                                else:
                                    WaveEngine.VCLtest("port.setEnableRxAttenuation('off')")
                            
                            if partCode[0] != '1' or partCode[5] != '0':
                                if self.perPortOptions[prt]['clientBackoff'] == "True":
                                    WaveEngine.VCLtest("port.setEnableBackoff('on')")
                                else:
                                    WaveEngine.VCLtest("port.setEnableBackoff('off')")
                        
                        WaveEngine.VCLtest("port.write('%s')" % (prt))
                        
    	            if len(self.monitorPortList) > 0 or len(self.blogPortList) > 0:
    	                
    	                if len(self.monitorPortList) > 0:
    	                    WaveEngine.OutputstreamHDL("Port Monitor running on Ports %s\n" % self.monitorPortList, WaveEngine.MSG_OK)   
    	                
    	                if len(self.blogPortList) > 0:
    	                    WaveEngine.OutputstreamHDL("Interference Generation running on Ports %s\n" % self.blogPortList, WaveEngine.MSG_OK)       	                    
    	                
    	                if len(self.wifiCards) == 0 and len(self.ethCards) == 0:
                            self.ecoSystemClientExist = False
                             
    	                    if self.progAttenFlag or self.dynamicBlogModeflag:    
    	                        attDoneKeyList = []
    	                        donekeyList = []
    	                        startTime = time.time()
                                extraTimeLag = 0
                                stopTime = startTime + self.trialDuration + extraTimeLag    
                                self.createdDynamicBlogPortList = []
                                                                    
                                while time.time() < stopTime:  
                                    if self.progAttenFlag: 	                    
    	                                for keyVal in self.progAttenScheduleDict:
                                            if keyVal not in attDoneKeyList:
                                                if (time.time() - startTime) >= (keyVal + extraTimeLag):
                                                    attId = self.progAttenScheduleDict[keyVal]['attenId']
                                                    attVal = self.progAttenScheduleDict[keyVal]['attVal']
                                                    if attId == 3:
                                                        roamB = self.progAttenScheduleDict[keyVal]['roamB']
                                                        roamNum = self.progAttenScheduleDict[keyVal]['roamNum']
                                                        self.sendMarkerPacketOnPorts(self.monitorPortList, attVal, roamB, roamNum)
                                                    elif attId == 4:
                                                        roamNum = self.progAttenScheduleDict[keyVal]['roamNum']
                                                        roamStatsStartTime = time.time()
                                                        #self.getRealTimeRoamDelayStats(roamNum, -1)
                                                        extraTimeLag += (time.time() - roamStatsStartTime)                                                        
                                                    else:    
                                                        self.sendCommandToJFW(attId,attVal)
                                                    attDoneKeyList.append(keyVal)                                                                                
                                    
                                    if self.dynamicBlogModeflag:
                                        for keyVal in self.blogScheduleDict:
                                            if keyVal not in donekeyList:
                                                if (time.time() - startTime) >= keyVal:
                                                    self.setupBlogPort(self.blogScheduleDict[keyVal]['port'], self.blogScheduleDict[keyVal]['intPer'], self.blogScheduleDict[keyVal]['channel'])  
                                                    self.createdDynamicBlogPortList.append(self.blogScheduleDict[keyVal]['port'])
                                                    donekeyList.append(keyVal)    
                                                                        
                                                                 
                                    WaveEngine.Sleep(1, "Test in progress...%d secs left"% (stopTime - time.time())) 
    	                    else:    	
    	                        if len(self.blogPortList) > 0 and len(self.monitorPortList) == 0:   
    	                            WaveEngine.Sleep(self.trialDuration, "Interference Generation in progress...")
    	                        elif len(self.blogPortList) == 0 and len(self.monitorPortList) > 0:             
    	                            WaveEngine.Sleep(self.trialDuration, "Port Monitoring in progress...") 
    	                        else:
    	                            WaveEngine.Sleep(self.trialDuration, "Port Monitoring/Interference Generation in progress...")      
    	                        	                    
                            if self.openedJfWLink:
    	                        self.closeConnectionToJFW()    
    	                    self.CloseCapture()   
    	                    WaveEngine.CloseLogging()      	                      
                            WaveEngine.DisconnectAll()   
                            #self.waveClientPostAnalysis(0, self.LoggingDirectory)  
                            self.getFlowStats()
                            
                            if ('clientFlowList' in self.clientAnalysisStore) and (len(self.clientAnalysisStore['clientFlowList'].keys()) > 0):
                                self.runClientAnalysis(self.clientAnalysisStore, self.LoggingDirectory, 0) 
                            else:    
                                if self.printReport() == -1:
                                    raise WaveEngine.RaiseException                                        
    	                    #return
                            continue
                            
    	            
    	            #for prts in self.blogPortList:
    	            #    WaveEngine.ConfigureBlogPorts(prts, self.waveBlogStore)    	            
    	            
    	            if WaveEngine.WaitforEthernetLink(self.CardList) == -1:
                        raise WaveEngine.RaiseException
               	    
               	    
               	    if self.clientGroupTestMode == 0:               	    
               	        if self.numWifiGroups > 0:        
                            if self.createNetworkMap() == -1:
                                if self.continueTestOnFail == False:
                                    raise WaveEngine.RaiseException    
                                else:
                                    self.closeWimixShop() 
                                    self.CloseCapture()                   
                                    self.DisconnectFlowsAndClients()                       
                                    WaveEngine.CloseLogging()
                                    continue    
                        
                    self.setSecondaryChannelOnPorts()
                    
                    activeServerNames = []              
                    
                    if self.wimixMode == 1:      
                        for tN in self.wimixClientCentricProfiles['profiles'][self.wimixClientCentricProfiles['testProfile']]['trafficList']: 
                    	    for tItem in tN.split(','):
                    	    	srvName = self.TrafficTypes[tItem]['Server']
                    	    	if srvName not in activeServerNames:
                    	    	    if self.serverList[srvName]['ethPort'] in self.ethCards:
                    	                activeServerNames.append(srvName)
                    elif self.wimixMode == 0:
                        for tItem in self.wimixTrafficCentricProfiles['profiles'][self.wimixTrafficCentricProfiles['testProfile']]['trafficList']: 
                            srvName = self.TrafficTypes[tItem]['Server']	
                    	    if srvName not in activeServerNames:
                    	        if self.serverList[srvName]['ethPort'] in self.ethCards:
                    	            activeServerNames.append(srvName)	        
                    
                    
                    ### setting the Waveengine mac counter for auto mode to zero so that we can use the same MAC on DHCP for the same client on each test run.
                    WaveEngine.SetClientMACCounter()   
                                        
                    self.createServers(activeServerNames)
                    
                    self.createDummyWifiClientsForWaveAgentServers()      
                    
                    
                    self.currMacIncrCountDict = {}
                    
                    for grpName in self.clientGroups:
                        self.currMacIncrCountDict[grpName] = 0
                    
                    if self.wimixMode == 1:  
                        self.createClientMixTest(wimixProfile, trailNum, 0)                             
                    elif self.wimixMode == 0:
                        self.createTrafficMixTest(wimixProfile, trailNum, 0)    
                    
                    
                    if self.multicastTrafficExistsFlag == True:
                        self.setupIgmpResponders()
                         
                    self.ListOfClients = self.clientList
                    self.TotalClients  = len(self.ListOfClients)
                    self.AssociateRetries = 10
                    
                    if self.connectClients() < 0:
                        if self.continueTestOnFail == False:
                            raise WaveEngine.RaiseException    
                        else:
                            WaveEngine.OutputstreamHDL("Warning: One or more clients did not connect successfully...moving on to the next trial", WaveEngine.MSG_ERROR)                   	
                            self.closeWimixShop() 
                            self.CloseCapture()                   
                            self.DisconnectFlowsAndClients()                       
                            WaveEngine.CloseLogging()
                            continue                          
                    
                    for resp in self.igmpResponderList:
                        WaveEngine.VCLtest("igmp.report('%s')" % (resp)) 
                    
                    if self.enableClientLearning:             
                        self.clientLearning()
                    
                    
                    WaveEngine.VCLtest("flowGroup.create('%s')" % ("mainFlowGroup"))
                    WaveEngine.VCLtest("flowGroup.write('%s')" % ("mainFlowGroup"))
                    
                    WaveEngine.VCLtest("flowGroup.create('%s')" % ("waResetStatsFlowGroup"))
                    WaveEngine.VCLtest("flowGroup.write('%s')" % ("waResetStatsFlowGroup"))
                    
                    WaveEngine.VCLtest("flowGroup.create('%s')" % ("waGetStatsFlowGroup"))
                    WaveEngine.VCLtest("flowGroup.write('%s')" % ("waGetStatsFlowGroup"))
                    
                    
                    self.flowNameTrafficProfileNameDict = {}
                    
                    #raise WaveEngine.RaiseException
                    
                    if self.wimixMode == 1:    
                        self.createClientMixTest(wimixProfile, trailNum, 1)
                    elif self.wimixMode == 0:
                        self.createTrafficMixTest(wimixProfile, trailNum, 1)   
                    
                    if len(self.burstModeScheduleDict.keys()) > 0:
                        self.burstModeTrafficFlag = True
                        WaveEngine.VCLtest("flowGroup.create('burstFlowGroup')")   	
    	                WaveEngine.VCLtest("flowGroup.write('burstFlowGroup')") 
                    
                    if len(self.flowTypeDict) == 0:
                        WaveEngine.OutputstreamHDL("No Traffic Flows in the test", WaveEngine.MSG_ERROR)
                   	raise WaveEngine.RaiseException  
                                           
                    self.clientsWithAdminControl = []                                                                                                   
                    self.setQosForFlows()
                    
                    if self.doFlowQoSHandshake() == -1:
                        raise WaveEngine.RaiseException
                    
                    for ll in range (0,self.numFlowRuns):    
                    	
                    	if self.reconnectClientsForTrial != 1:
                    	    if self.wimixMode == 0:
    	                        WaveEngine.OutputstreamHDL("\n\nTrial %d (Date/Time): %s (%d seconds into the test): Running Test for %s Traffic Mix Profile, for %d Kbps Load per AP/Port\n\n" % ((ll+1), datetime.datetime.fromtimestamp(time.time()), int(time.time() - tSTimer), wimixProfile, self.loadInKbps), WaveEngine.MSG_OK)  
    	                        trialStr = "Trial %d (Date/Time): %s (%d seconds into the test): Running Test for %s Traffic Mix Profile, for %d Kbps Load per AP/Port" % ((ll+1), datetime.datetime.fromtimestamp(time.time()), int(time.time() - tSTimer), wimixProfile, self.loadInKbps)
    	                        self.ResultsForCSVfile.append([trialStr,],) 
    	                    else:
    	                        WaveEngine.OutputstreamHDL("\n\nTrial %d (Date/Time): %s (%d seconds into the test): Running Test for %s Client Mix Profile, for %d clients per AP/Port\n\n" % ((ll+1), datetime.datetime.fromtimestamp(time.time()), int(time.time() - tSTimer), wimixProfile, self.numTotalClients), WaveEngine.MSG_OK)
                   	        trialStr = "Trial %d (Date/Time): %s (%d seconds into the test): Running Test for %s Client Mix Profile, for %d clients per AP/Port" % ((ll+1), datetime.datetime.fromtimestamp(time.time()), int(time.time() - tSTimer), wimixProfile, self.numTotalClients)
                   	        self.ResultsForCSVfile.append([trialStr,],)
                   	                   	 
                        ##### Start The Flowsss...."                          
                        WaveEngine.ClearAllCounter(self.CardList)  
                        
                        self.writeRSSIinfo()                        
                       
                        if self.connectBiflows(self.biFlowConnectTimeout, self.biFlowConnectRate)  < 0:
                            if self.continueTestOnFail == False:
                                raise WaveEngine.RaiseException
                            else:
                                continue    
                        
                        if self.doARPExchange() < 0:
                            if self.continueTestOnFail:
                                self.Print("Warning: One or more ARPs failed...moving on with the test\n")                                
                            else:    
                                self.Print("One or more ARPs failed...Exiting the test\n")
                                raise WaveEngine.RaiseException                        
                                            
                        self.updateClientPowerSaveModes()
                        
                        self.voiceCallSetupTeardown(0)
                        
                        WaveEngine.VCLtest("flowGroup.read('mainFlowGroup')")
                        flowNames = flowGroup.getFlowNames('mainFlowGroup')
                        
                        for resp in self.igmpResponderList:
                            WaveEngine.VCLtest("igmp.report('%s')" % (resp))           
                    
                        
                        if self.staggerStartCustomEnabled == False:
                            self.Print("Starting the following flows.....\n")
                            for names in self.flowTypeDict:
                                self.Print ("\t%s\n" % names)                          
                        
                        self.initiateOverTimeResDict()   
                        
                        self.startedFlowsList = []   
                        self.stoppedFlowsList = [] 
                        self.flowStartTimes = odict.OrderedDict() 
                        self.actualFlowStartTimes = odict.OrderedDict() 
                        self.flowStopTimes = odict.OrderedDict() 
                        self.tIloadOverTime = odict.OrderedDict() 
                        self.tOloadOverTime = odict.OrderedDict() 
                        self.tAloadOverTime = odict.OrderedDict() 
                        
                        #### Old flow results 
                        self.flowOldResults = {}
                        for name in self.flowTypeDict:
                            self.flowOldResults[name] = {}  
                        
                                                
                        if self.staggerStartCustomEnabled == False and self.burstModeTrafficFlag == False:                                    
                            WaveEngine.VCLtest("action.startFlowGroup('%s')" % ("mainFlowGroup"))
                            self.startedFlowsList = self.flowTypeDict.keys()
                            for flw in self.flowTypeDict:
                                self.flowStartTimes[flw] = time.time()  
                                self.actualFlowStartTimes[flw] = time.time()                             
                        else:
                            if self.staggerStartCustomEnabled:
                                WaveEngine.VCLtest("flowGroup.create('staggerFlowGroup')")   	
    	                        WaveEngine.VCLtest("flowGroup.write('staggerFlowGroup')") 
    	                        for flName in self.flowTypeDict:
    	                            if self.flowTypeDict[flName][11] == 0:
    	                                if flName not in self.startedFlowsList:
    	                                    self.startStaggerFlow(flName)
    	                                    self.startedFlowsList.append(flName)
    	                                    self.flowStartTimes[flName] = time.time()
    	                                    self.actualFlowStartTimes[flName] = time.time()   
    	                    else:
    	                        self.startedFlowsList = self.flowTypeDict.keys()
                                for flw in self.flowTypeDict:
                                    self.flowStartTimes[flw] = time.time()  
                                    self.actualFlowStartTimes[flw] = time.time()                    
    	                                         
                        self.testDurationStart = time.time()
                        self.trafficFlowsStarted = True
                        self.trafficFlowsEnded = False
                        
                        self.trafficStartTime = time.time()
                        stopTime = self.trafficStartTime + self.trialDuration             
                                                        
                        sampleNum = 0
                        if self.enableOverTimeResults == 1:
                            sampTime = 0
                            donekeyList = []
                            doneBurstList = []
                            attDoneKeyList = []
                            self.createdDynamicBlogPortList = []
                            self.currentListOfStartedFlows = []
                            extraTimeLag = 0
                            while time.time() < stopTime:
                                remTime = stopTime - time.time()
                                if remTime < self.resultSampleTime:
                                    if remTime < 1:
                                        slpTime = 1
                                    else:    
                                        slpTime = remTime
                                else:
                                    slpTime = self.resultSampleTime 
                                
                                if self.staggerStartCustomEnabled or self.staggerStopCustomEnabled:
                                    for flName in self.flowTypeDict:
                                        if flName not in self.startedFlowsList:
    	                                    if (time.time() - self.testDurationStart) >= self.flowTypeDict[flName][11]:
    	                                    	self.startStaggerFlow(flName) 
                                                self.startedFlowsList.append(flName)  
                                                self.flowStartTimes[flName] = time.time()  
                                                self.actualFlowStartTimes[flName] = time.time()     
                                        if flName not in self.stoppedFlowsList:          
                                            if (time.time() - self.testDurationStart) >= self.flowTypeDict[flName][12]:
    	                                    	self.stopStaggerFlow(flName) 
                                                self.stoppedFlowsList.append(flName)  
                                                self.flowStopTimes[flName] = time.time()                                   
                                
                                                                      
                                if self.burstModeTrafficFlag:
                                    flowsToStart = []  
                                    for keyVal in self.burstModeScheduleDict:
                                        if keyVal not in doneBurstList:
                                            if (time.time() - self.testDurationStart) >= keyVal:
                                                flowsToStart.append(self.burstModeScheduleDict[keyVal])
                                                doneBurstList.append(keyVal)
                                    if len(flowsToStart) > 0:            
                                        self.stopAndStartBurstFlow(flowsToStart)
                                                
                                    
                                if self.dynamicBlogModeflag:    
                                    for keyVal in self.blogScheduleDict:
                                        if keyVal not in donekeyList:
                                            if (time.time() - self.testDurationStart) >= keyVal:
                                                self.setupBlogPort(self.blogScheduleDict[keyVal]['port'], self.blogScheduleDict[keyVal]['intPer'], self.blogScheduleDict[keyVal]['channel'])  
                                                self.createdDynamicBlogPortList.append(self.blogScheduleDict[keyVal]['port'])
                                                donekeyList.append(keyVal)   
                                
                                
                                if self.progAttenFlag:    
                                    for keyVal in self.progAttenScheduleDict:
                                        if keyVal not in attDoneKeyList:
                                            if (time.time() - self.testDurationStart) >= (keyVal + extraTimeLag):
                                                attId = self.progAttenScheduleDict[keyVal]['attenId']
                                                attVal = self.progAttenScheduleDict[keyVal]['attVal']
                                                if attId == 3:
                                                    roamB = self.progAttenScheduleDict[keyVal]['roamB']
                                                    roamNum = self.progAttenScheduleDict[keyVal]['roamNum']
                                                    self.sendMarkerPacketOnPorts(self.wifiCards + self.monitorPortList, attVal, roamB, roamNum)
                                                elif attId == 4:
                                                    roamNum = self.progAttenScheduleDict[keyVal]['roamNum']
                                                    roamStatsStartTime = time.time()
                                                    #self.getRealTimeRoamDelayStats(roamNum, 0)
                                                    extraTimeLag += (time.time() - roamStatsStartTime)
                                                    stopTime += (time.time() - roamStatsStartTime)
                                                else:    
                                                    self.sendCommandToJFW(attId,attVal)
                                                attDoneKeyList.append(keyVal)  
                                                                               
                                    
                                WaveEngine.Sleep(slpTime, "Test in progress...%d secs left"% (stopTime - time.time())) 
                                sampleNum += 1 
                                if self.overTimeResultType == 0:                                                              
                                    WaveEngine.OutputstreamHDL("Result Sample # %d : %d seconds left in the test.\n\n" % (sampleNum, remTime), WaveEngine.MSG_OK)  
                                    sampTime =  time.time() - self.trafficStartTime
                                    self.timeSampleList.append(round(sampTime,0))
                                    self.saveOverTimeResults(sampTime) 
                                    self.measureIloadOverTime(sampTime)
                                else:
                                    WaveEngine.OutputstreamHDL("Result Sample # %d : %d seconds left in the test.\n\n" % (sampleNum, remTime), WaveEngine.MSG_SUCCESS)        
                        else:
                            if self.staggerStartCustomEnabled or self.staggerStopCustomEnabled or self.dynamicBlogModeflag or self.burstModeTrafficFlag or self.progAttenFlag:
                                donekeyList = []
                                doneBurstList = []
                                attDoneKeyList = []
                                self.createdDynamicBlogPortList = []
                                self.currentListOfStartedFlows = []
                                extraTimeLag = 0
                                while time.time() < stopTime:                                
                                    if self.staggerStartCustomEnabled or self.staggerStopCustomEnabled:
                                        for flName in self.flowTypeDict:
                                            if flName not in self.startedFlowsList:
    	                                        if (time.time() - self.testDurationStart) >= self.flowTypeDict[flName][11]:
                                                   self.startStaggerFlow(flName)
                                                   self.startedFlowsList.append(flName) 
                                                   self.flowStartTimes[flName] = time.time()
                                                   self.actualFlowStartTimes[flName] = time.time()   
                                            if flName not in self.stoppedFlowsList:    
                                                if (time.time() - self.testDurationStart) >= self.flowTypeDict[flName][12]:
    	                                    	    self.stopStaggerFlow(flName) 
                                                    self.stoppedFlowsList.append(flName)  
                                                    self.flowStopTimes[flName] = time.time()     
                                    
                                    if self.burstModeTrafficFlag:
                                        flowsToStart = []  
                                        for keyVal in self.burstModeScheduleDict:
                                            if keyVal not in doneBurstList:
                                                if (time.time() - self.testDurationStart) >= keyVal:
                                                    flowsToStart.append(self.burstModeScheduleDict[keyVal])
                                                    doneBurstList.append(keyVal)
                                        if len(flowsToStart) > 0:            
                                            self.stopAndStartBurstFlow(flowsToStart)
                                    
                                    if self.dynamicBlogModeflag:
                                        for keyVal in self.blogScheduleDict:
                                            if keyVal not in donekeyList:
                                                if (time.time() - self.testDurationStart) >= keyVal:
                                                    self.setupBlogPort(self.blogScheduleDict[keyVal]['port'], self.blogScheduleDict[keyVal]['intPer'], self.blogScheduleDict[keyVal]['channel'])  
                                                    self.createdDynamicBlogPortList.append(self.blogScheduleDict[keyVal]['port'])
                                                    donekeyList.append(keyVal)                                      
                                    
                                    if self.progAttenFlag:    
                                        for keyVal in self.progAttenScheduleDict:
                                            if keyVal not in attDoneKeyList:
                                                if (time.time() - self.testDurationStart) >= (keyVal + extraTimeLag):
                                                    attId = self.progAttenScheduleDict[keyVal]['attenId']
                                                    attVal = self.progAttenScheduleDict[keyVal]['attVal']
                                                    if attId == 3:
                                                        roamB = self.progAttenScheduleDict[keyVal]['roamB']
                                                        roamNum = self.progAttenScheduleDict[keyVal]['roamNum']
                                                        self.sendMarkerPacketOnPorts(self.wifiCards + self.monitorPortList, attVal, roamB, roamNum)
                                                    elif attId == 4:
                                                        roamNum = self.progAttenScheduleDict[keyVal]['roamNum']
                                                        roamStatsStartTime = time.time()
                                                        #self.getRealTimeRoamDelayStats(roamNum, 0)
                                                        extraTimeLag += (time.time() - roamStatsStartTime)
                                                        stopTime += (time.time() - roamStatsStartTime)
                                                    else:    
                                                        self.sendCommandToJFW(attId,attVal)
                                                    attDoneKeyList.append(keyVal)                                      
                                    
                                               
                                    WaveEngine.Sleep(1, "Test in progress...%d secs left" % (stopTime - time.time()))                                                 
                            else:
                                WaveEngine.Sleep(self.trialDuration, "Test in progress...")            
                        
                        
                        if self.staggerStopCustomEnabled:
                            for flName in self.flowTypeDict:
                                if flName not in self.stoppedFlowsList:
    	                            self.stopStaggerFlow(flName)
    	                            self.flowStopTimes[flName] = time.time()
    	                else:                             
                            WaveEngine.VCLtest("action.stopFlowGroup('%s')" % ("mainFlowGroup"))  
                            for flName in self.flowTypeDict:
                                self.flowStopTimes[flName] = time.time()
                          
                        self.testDurationStop = time.time()                   
                        
                        self.trialDuration = round((self.testDurationStop - self.testDurationStart),0)
                        
                                                                                             
                        self.trafficFlowsStarted = False
                        self.trafficFlowsEnded = True
                        
                        self.voiceCallSetupTeardown(1)
                        
                        #if self.tearDownFlowQoSHandshake() == -1:
                        #    raise WaveEngine.RaiseException
                                                       
                        WaveEngine.Sleep(self.settleTime,  "System Settle Time.....") 
                        
                        self.slaReqMetForTrail = True                        
                        self.Print("Getting the Flow Stats and Computing the results...Please Wait...\n")
                        time.sleep(2)
                        self.getFlowStats() 
                                                
                        #### Reset the stats on WaveEngine based flows
                        for flw in self.flowTypeDict:
                           if self.flowTypeDict[flw][9] in ["waSrcFlow", "waSinkFlow", "waLoopFlow"]:
                           	self.resetWaveAgentStatsFlow(flw)
                           	
                        
                        #self.getRealTimeClientStats()
                        
                        #self.Print("\n\nInitiating the Disconnection of all TCP sessions...Please Wait...\n")
                        self.disconnectBiflows(self.biFlowDisconnectTimeout, self.biFlowConnectRate) 
                        
                        #if ll != self.numFlowRuns: 
                        #    self.destroyAppServers()
                        #    self.recreateAppServers(ll)
                                                
                        WaveEngine.Sleep(self.agingTime,  "System Aging Time.....") 
                                                
                        #### End of flows ......" 
                   
                                       
                    #trailNum += 1
                    #WaveEngine.WriteAPinformation(self.ApScanClientDict) 
                    self.closeWimixShop()
                    self.CloseCapture()
                    self.DisconnectFlowsAndClients()
                    WaveEngine.CloseLogging()
                    #self.waveClientPostAnalysis(0, self.LoggingDirectory)
                    if ('clientFlowList' in self.clientAnalysisStore) and (len(self.clientAnalysisStore['clientFlowList'].keys()) > 0):
                        self.runClientAnalysis(self.clientAnalysisStore, self.LoggingDirectory, 0) 
                    else:
                        if self.printReport() == -1:
                            if self.continueTestOnFail == False:
                                raise WaveEngine.RaiseException
              
                    
            #WaveEngine.WriteAPinformation(self.ApScanClientDict)  
            #self.closeWimixShop()                    
            #self.CloseShop()  
                  
        except WaveEngine.RaiseException:
            WaveEngine.OutputstreamHDL('\n', WaveEngine.MSG_OK)
            (exc_type, exc_value, exc_traceback) = sys.exc_info()
            WaveEngine.OutputstreamHDL(str(exc_value), WaveEngine.MSG_ERROR)
            #if self.testType == "WaveClient":
            # 	return
            self.closeWimixShop()
            self.CloseShop()
            self.ExitStatus = 2
        except Exception, e:
            # some other error occured
            (exc_type, exc_value, exc_tb) = sys.exc_info()
            try:
                # print out nice traceback and error strings
                msg = "Fatal script error:\n"
                for text in traceback.format_exception(exc_type, exc_value, exc_tb):
                    msg += str(text)
                WaveEngine.OutputstreamHDL(str(msg), WaveEngine.MSG_ERROR)
            except Exception, e:
                # just incase the exception handler blows up
                print "ERROR:\n%s\n%s\n" % (str(msg), str(e))
            self.ExitStatus = 1
            self.closeWimixShop()    
            self.CloseShop() 
        return self.ExitStatus


# Options
PF_OPTION_NONE        = 0
#
# Show percentages inside the bar graph
PF_OPTION_SHOWPERCENT = 1
#
# Turn on legend and set alignemt to left, center right
PF_OPTION_LEGENDLEFT   = 2
PF_OPTION_LEGENDCENTER = 4
PF_OPTION_LEGENDRIGHT  = 8


class PassFailGraph(Flowable):
    """
    Pass Fail Graph
    """
    _BarGapY = 4
    
    def __init__(self, width=640, height=400, names=['Test',],  bar=[(1,1),], title='', options=PF_OPTION_NONE):
        #self.PassColor = Color(0, 1, 0)
        #self.FailColor = Color(1, 0, 0)
        
        self.PassColor = Color(186/255.0, 210/255.0, 10/255.0)
        self.FailColor = Color(187/255.0,  70/255.0, 67/255.0)

        
        self.width = width
        self.height = height
        self.offset    = (defaultPageSize[0] - 2 * inch - width) / 2.0
        self.legend    = String(0,0,'')
        self.title     = Label()
        self.title.setText(title)
        self.title.boxAnchor = 'n'
        self.title.dx = width/2
        self.title.dy = height
        self.options  = options
        #Sanitize the data
        numOfNames     = len(names)
        numOfValues    = len(bar)
        self.numOfBars = numOfNames
        if numOfValues > numOfNames:
            self.numOfBars = numOfValues
        self.dataNames = []
        self.dataBar   = []
        for Index in range(self.numOfBars):
            name = ''
            if Index < numOfNames:
                name = names[Index]
            value = (0,1)
            if Index < numOfValues:
                value = bar[Index]
            if len(value) > 2:
                value = (value[0], value[1])
            elif len(value) == 1:
                value = (value[0], 0)
            elif len(value) == 0:
                value = (0, 1)
            self.dataNames.append(name)
            self.dataBar.append(value)

    def _drawBox(self, x, y, width, height):
        # For debugging purposes only
        self.canvas.saveState()
        self.canvas.setStrokeColorRGB(0.2,0.5,0.3)
        self.canvas.setDash(1,2)
        self.canvas.rect(x, y, width, height, stroke=1, fill=0)
        self.canvas.restoreState()

    def _stringWidth(self, text, fontName, fontSize):
        from reportlab.pdfbase.pdfmetrics import stringWidth
        SW = lambda text, fN=fontName, fS=fontSize: stringWidth(text, fN, fS)
        return SW(text)

    # Default behavior
    def _rawDraw(self, x, y):
        SizeYtitle = 0.0
        SizeXaxis  = 0.0
        self.drawing = Drawing(self.width, self.height)
        
        #Subtract Title hieght from Graph area
        if len(self.title._text) > 0:
            SizeYtitle = 1.5 * self.title.fontSize
            self.drawing.add(self.title)
        for eachLabel in self.dataNames:
            n = self._stringWidth(eachLabel, self.legend.fontName, self.legend.fontSize)
            if n > SizeXaxis:
                SizeXaxis = n
        
        # Split up the Y 
        if SizeXaxis > 0.0:
            _CurrentX = SizeXaxis + self.legend.fontSize
        else:
            _CurrentX = 0
        _CurrentY  = self.height - SizeYtitle
        _BarWidth  = self.width - _CurrentX
        _AvailableY =  self.height - SizeYtitle - self._BarGapY * (self.numOfBars-1)

        if self.options & (PF_OPTION_LEGENDLEFT | PF_OPTION_LEGENDCENTER | PF_OPTION_LEGENDRIGHT)  :
            _BarHeight = (_AvailableY- 2*self.title.fontSize) / self.numOfBars 
        else:
            _BarHeight = _AvailableY / self.numOfBars
        
        for dIndex in range(len(self.dataNames)):
            self.drawing.add(String(0, _CurrentY- _BarHeight/2, self.dataNames[dIndex], fontName=self.legend.fontName, fontSize=self.legend.fontSize))
            
            _data = self.dataBar[dIndex]
            _dataTotal = float(_data[0]) + float(_data[1])
            
            X1 = _data[0]*_BarWidth/_dataTotal
            self.drawing.add(Rect(_CurrentX,      _CurrentY-_BarHeight, X1, _BarHeight,           fillColor=self.PassColor, strokeWidth=0))
            self.drawing.add(Rect(_CurrentX + X1, _CurrentY-_BarHeight, _BarWidth-X1, _BarHeight, fillColor=self.FailColor, strokeWidth=0))
            self.drawing.add(Rect(_CurrentX + X1, _CurrentY-_BarHeight, _BarWidth-X1, _BarHeight, fillColor=self.FailColor, strokeWidth=0))

            self.drawing.add(PolyLine([_CurrentX,_CurrentY, _CurrentX + _BarWidth,_CurrentY,_CurrentX+_BarWidth,_CurrentY-_BarHeight,
                                        _CurrentX,_CurrentY-_BarHeight, _CurrentX,_CurrentY],
                                       strokeWidth=1, strokeColor=Color() ) )

            if self.options & PF_OPTION_SHOWPERCENT :
                _TextFontName = 'Times-Roman'
                _TextFontSize = int(_BarHeight/2.5)
                if _TextFontSize > 18:
                    _TextFontSize = 18
                _yOffset = _CurrentY - _BarHeight/2 - _TextFontSize/2
                
                TextPass = "%.1f%%" % (100*_data[0]/_dataTotal)
                n = self._stringWidth(TextPass, _TextFontName, _TextFontSize)
                if X1 > n:
                    xOffset = _CurrentX + X1/2 - n/2
                    self.drawing.add(String(xOffset, _yOffset, TextPass, fontName=_TextFontName, fontSize=_TextFontSize))

            
                TextFail = "%.1f%%" % (100*_data[1]/_dataTotal)
                n = self._stringWidth(TextFail, _TextFontName, _TextFontSize)
                if _BarWidth-X1 > n:
                    xOffset = _CurrentX + X1 + (_BarWidth-X1)/2 - n/2 - 2
                    self.drawing.add(String(xOffset, _yOffset, TextFail, fontName=_TextFontName, fontSize=_TextFontSize))
            
            _CurrentY -= _BarHeight + self._BarGapY

        if self.options & (PF_OPTION_LEGENDLEFT | PF_OPTION_LEGENDCENTER | PF_OPTION_LEGENDRIGHT) :
            _boxSize = self.legend.fontSize - 2
            _CurrentY -= self.title.fontSize 
            Str1Width = self._stringWidth('PASS', self.legend.fontName, self.legend.fontSize)
            Str2Width = self._stringWidth('FAIL', self.legend.fontName, self.legend.fontSize)
            _LegendXspacing = self.legend.fontSize
            TotalX = self.legend.fontSize + Str1Width +_LegendXspacing + self.legend.fontSize + Str2Width
            if self.options & PF_OPTION_LEGENDLEFT :
                LegendX = _CurrentX
            elif self.options & PF_OPTION_LEGENDCENTER :
                LegendX = _CurrentX + _BarWidth/2 - TotalX/2
            else:
                LegendX = _CurrentX + _BarWidth - TotalX
                
            self.drawing.add(Rect(LegendX,   _CurrentY, _boxSize, _boxSize, fillColor=self.PassColor, strokeWidth=1))
            LegendX += self.legend.fontSize
            self.drawing.add(String(LegendX, _CurrentY, 'PASS',  fontName=self.legend.fontName, fontSize=self.legend.fontSize))
            LegendX += self._stringWidth('PASS', self.legend.fontName, self.legend.fontSize) + _LegendXspacing
            self.drawing.add(Rect(LegendX,   _CurrentY, _boxSize, _boxSize, fillColor=self.FailColor, strokeWidth=1))
            LegendX += self.legend.fontSize
            
            xOffset = _CurrentX + _BarWidth - self._stringWidth('FAIL', self.legend.fontName, self.legend.fontSize)
            self.drawing.add(String(LegendX, _CurrentY, 'FAIL',  fontName=self.legend.fontName, fontSize=self.legend.fontSize))
        
    def drawOn(self, canvas, x, y, _sW=0):
        from reportlab.graphics import renderPDF
        self.canvas = canvas
        self._rawDraw(x, y)
        renderPDF.draw(self.drawing, canvas, x, y, showBoundary=False)
        
        #For debuging boundries
        #self._drawBox(x, y, self.width, self.height)

    def drawFile(self, width, height, Filename, format='PNG', dpi=72):
        from reportlab.graphics import renderPM
        self.width  = width
        self.height = height
        self._rawDraw(0, 0)
        renderPM.drawToFile(self.drawing, Filename, fmt=format, dpi=dpi ) 

    def drawTo(self, width, height, dpi=72, format='PNG'):
        from reportlab.graphics import renderPM
        self.width  = width * (72.0 / dpi)  # maintain size
        self.height = height * (72.0 / dpi)
        self._rawDraw(0, 0)
        return renderPM.drawToString(self.drawing, fmt = format, dpi=dpi )
 
    def wrap(self, availWidth, availHeight):
        #the caller may decide it does not fit.
        return (availWidth, self.height)       

    def getSpaceAfter(self):
       return (1/16.0) * inch
        
               

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

    WaveEngine.SetOutputStream(PrintToConsole)
    if options.filename != None:
        retval = userTest.loadFile( options.filename )
    if options.logs:
        userTest.SavePCAPfile = True
    
    userTest.run()
    sys.exit(userTest.ExitStatus)
    
