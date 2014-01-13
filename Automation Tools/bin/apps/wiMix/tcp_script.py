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
from tcpScriptInputs import testInputParameters

class Test(BaseTest):
    
    def __init__(self):
        BaseTest.__init__(self)
                
        (waveChassisStore, wavePortStore, waveClientTableStore,waveSecurityStore, waveTestStore, waveTestSpecificStore,
          waveMappingStore, waveBlogStore,wimixTrafficStore,wimixServerStore, clientAnalysisStore) = testInputParameters()
        
        self.loadData(waveChassisStore, wavePortStore, waveClientTableStore,waveSecurityStore, waveTestStore, waveTestSpecificStore,
                      waveMappingStore, waveBlogStore,wimixTrafficStore,wimixServerStore, clientAnalysisStore)
        
        
#------------------------ End of User Configuration --------------------------
    
                                
        
    def loadData(self, waveChassisStore, wavePortStore, waveClientTableStore,
           waveSecurityStore, waveTestStore, waveTestSpecificStore,
           waveMappingStore, waveBlogStore,wimixTrafficStore,wimixServerStore, clientAnalysisStore):
        
                 
        self.wifiCards = []       
        self.ethCards = []  
        self.monWifiCards = []       
        self.monEthCards = [] 
        self.secondaryChannelDict = {}      
         
        self.testParameters = odict.OrderedDict()           
        
        self.clientOptions ={}
        self.clientOptions['enableNetworkInterface'] = True
        #self.clientOptions['GratuitousArp'] = "on"
        self.finalGraphs = {}
        
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
        for chassis in waveChassisStore.keys():
            for cards in waveChassisStore[chassis].keys():
            	if 'BindStatus' not in waveChassisStore[chassis][cards]:
            	    for prts in waveChassisStore[chassis][cards]:            	    	
            	    	            	    	
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
                                    self.monWifiCards.append(str(waveChassisStore[chassis][cards][prts]['PortName'])) 
                                elif waveChassisStore[chassis][cards][prts]['CardMode'] == "IG":
                                    self.igWifiCards.append(str(waveChassisStore[chassis][cards][prts]['PortName']))   
                                else:
                                    self.wifiCards.append(str(waveChassisStore[chassis][cards][prts]['PortName'])) 
                                     
                                self.secondaryChannelDict[str(waveChassisStore[chassis][cards][prts]['PortName'])] = int(waveChassisStore[chassis][cards][prts]['secChannel'])
                else:
            	    if waveChassisStore[chassis][cards]['BindStatus'] == "True":            	    	
            	    	
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
        
                            
                   
        self.CardList = []
        
        for crd in self.CardMap.keys():
            if crd not in self.blogPortList:
                 self.CardList.append(crd)	
        
        
        
        self.serverList = wimixServerStore
        
        
        self.testType = "TCP Scaling Test"
        
            
        self.CSVfilename      = 'Results_' + self.testType + '.csv'
        self.CSVOTRfilename   = 'Results_' + self.testType + '_over_time.csv'
        self.ReportFilename   = 'Report_' + self.testType + '.pdf'
        self.DetailedFilename = 'Detailed_Results_' + self.testType + '.csv'
        self.ConsoleLogFileName = "Console_" + self.testType + "_script.html"
        self.TimeLogFileName = "Timelog_" + self.testType + "_script.txt"
        self.RSSILogFileName = "RSSI_" + self.testType + "_script.csv"
                	
         
        
        self.clientGroups = {}
        for cltGrps in waveClientTableStore.keys():
            
            grpName = waveClientTableStore[cltGrps]['Name'] 
            self.clientGroups[grpName] = {}
            self.clientGroups[grpName]['enable'] = waveClientTableStore[cltGrps]['Enable']            
            self.clientGroups[grpName]['type'] = waveClientTableStore[cltGrps]['Interface']    
            self.clientGroups[grpName]['portName'] = waveClientTableStore[cltGrps]['PortName']            
            if waveClientTableStore[cltGrps]['Dhcp'] == "Enable":
                self.clientGroups[grpName]['ipMode'] = 0
            elif waveClientTableStore[cltGrps]['Dhcp'] == "Disable":  
            	self.clientGroups[grpName]['ipMode'] = 1
            self.clientGroups[grpName]['ipAddress'] = waveClientTableStore[cltGrps]['BaseIp'] 	
            self.clientGroups[grpName]['gateway'] = waveClientTableStore[cltGrps]['Gateway']  
            self.clientGroups[grpName]['subnetMask'] = waveClientTableStore[cltGrps]['SubnetMask']   
            self.clientGroups[grpName]['BehindNat'] = waveClientTableStore[cltGrps]['BehindNat']
            self.clientGroups[grpName]['NumClients'] = waveClientTableStore[cltGrps]['NumClients'] 
            
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
                                           
                      
            if waveClientTableStore[cltGrps]['MacAddressMode'] == "Auto":
                self.clientGroups[grpName]['macAddress'] = "AUTO"
            else:
                self.clientGroups[grpName]['macAddress'] = waveClientTableStore[cltGrps]['MacAddress']  	 
                
        
        
                
        #self.PortOptions['ContentionProbability'] = int(waveTestStore['TestParameters']['ClientContention'])
        self.PortOptions = {}
        
        testData = waveTestSpecificStore['tcp_script']
        
        ###### Test Specific Config Data        
        
        self.clientServerFlowList = testData['flowList']
        self.lastClientIpAddrInGroup = {}
        self.lastServerIpAddrInGroup = {}
        
        grpNum = 0
        for grp in self.clientServerFlowList:
            grpName = "Grp_%s_%s" % (grp['client'], grp['server'])
            grp['groupName'] = grpName
            grpNum += 1
            clGrpName = grp['client']
            srGrpName = grp['server']
            
            if clGrpName in self.clientGroups:
                grp['clientStartIp'] = self.clientGroups[clGrpName]['ipAddress']
                self.lastClientIpAddrInGroup[grpName] = self.clientGroups[clGrpName]['ipAddress']
                grp['clNetmask'] = self.clientGroups[clGrpName]['subnetMask']
                grp['clGateway'] = self.clientGroups[clGrpName]['gateway']
                
            if srGrpName in self.serverList:
                grp['serverStartIp'] = self.serverList[srGrpName]['ipAddress']
                self.lastServerIpAddrInGroup[grpName] = self.serverList[srGrpName]['ipAddress']
                grp['srNetmask'] = self.serverList[srGrpName]['netmask']
                grp['srGateway'] = self.serverList[srGrpName]['gateway']
                
        
        self.flowSegSize = int(testData['segSize'])
        self.flowRate = int(testData['flowRate'])
        self.flowDuration = int(testData['flowDur']) 
        self.flowDirection = int(testData['flowDir'])
        self.rxWinSize = int(testData['rxWinSize']) 
        self.flowSrcPortNum = int(testData['srcPort'])
        self.flowDstPortNum = int(testData['dstPort'])
        self.connRetryLimit = int(testData['retryLimit']) 
        self.numFailedConn = int(testData['failedConn'])
        self.resultMetricsType = int(testData['resType'])
        
        self.maxCurrentFlows = int(testData['conFlows'])
        self.resultFlowCount = int(testData['resFlows'])        
        self.realTimeChartingFlag = bool(int(testData['realTimeFlag']))
        self.slaPercent = int(testData['slaVal'])  
           
        
        self.totalNumFlows = 0
        
        for flwItem in self.clientServerFlowList:
            if flwItem['client'] in self.clientGroups:
                flwItem['numFlows'] = self.clientGroups[flwItem['client']]['NumClients']
            self.totalNumFlows += int(flwItem['numFlows'])   
        
        
        self.biFlowConnectTimeout = int(waveTestStore['L4to7Connection']['ConnectionTimeout'])
        self.biFlowConnectRate = int(waveTestStore['L4to7Connection']['ConnectionRate'])
         
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
        
        
        #Test results must be stored in the test specific results directory, the directory name is testName
        testName = waveTestSpecificStore.keys()[0]
        
        # set the logging directory
        self.LoggingDirectory = waveTestStore['LogsAndResultsInfo']['LogsDir']
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
        
                        
        if waveTestStore['LogsAndResultsInfo'].get('GeneratePdfReport', 'True') == "True":
            self.generatePdfReportF = True
        else:
            self.generatePdfReportF = False
         
        try:
            if 'tcp_script' not in waveTestSpecificStore.keys():
                self.Print("No Test config found\n", 'ERR')
                raise WaveEngine.RaiseException
        except WaveEngine.RaiseException:
            self.Print("WaveEngine terminating the run\n", 'ERR')
            self.CloseShop()
            return -1     	
    
    
    ##################################### int2IPv4 ###################################
    # Converts an integer number into IPv4 dot notation
    #
    def int2IPv4(self, ip4):
        ip1 = int( ip4 / 16777216)
        ip4 -= ip1 * 16777216
        ip2 = int( ip4 / 65536)
        ip4 -= ip2 * 65536
        ip3 = int( ip4 / 256)
        ip4 -= ip3 * 256
        return "%d.%d.%d.%d" % (ip1, ip2, ip3, ip4)

    ##################################### IPv4toInt ##################################
    # Converts an IPv4 dot notation into integer number 
    #
    def IPv4toInt(self, ip):
        REvalue = re.search("(\d+)\.(\d+)\.(\d+)\.(\d+)", ip)
        try:
            n = int(REvalue.group(1))*16777216 + int(REvalue.group(2))*65536 + int(REvalue.group(3))*256 + int(REvalue.group(4))
        except:
            print "IPv4toInt() input error: %s is not in the form x.x.x.x" % (ip)
            n = -1
        return n
    
        
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
        
            
    def setupBiFlow( self, srcClient, dstClient, src_port, dst_port):
      
        srcPort = self.flowSrcPortNum
        dstPort = self.flowDstPortNum        
        
        if self.flowDirection == 0:        
            loadType = "upload"
        else:
            loadType = "download"
        
        #iRate = self.flowRate * 1000 / ((self.flowSegSize + 58) * 8)
        iRate = self.flowRate * 1000 / (self.flowSegSize * 8)
        
    	biFlowName = "F_%s_%s:" % (srcClient, dstClient)
        WaveEngine.VCLtest("biflow.create('%s')"  % (biFlowName))
        WaveEngine.VCLtest("biflow.set( 'RX Window', str(%d))" % self.rxWinSize)
        WaveEngine.VCLtest("biflow.setSrcClient('%s')" % (srcClient))
        WaveEngine.VCLtest("biflow.setDestClient('%s')" % (dstClient))
                 
        WaveEngine.VCLtest("biflow.setIntendedRate(%f)" % iRate)
        WaveEngine.VCLtest("biflow.setFrameSize(%d)" % (self.flowSegSize + 58))
        WaveEngine.VCLtest("biflow.setNumFrames(%d)" % (10000000)) 
        WaveEngine.VCLtest("biflow.setInsertSignature('on')")                
                
        
        #WaveEngine.VCLtest("biflow.write('%s')" % (biFlowName))
        
        if biflow.write(biFlowName) < 0:
            time.sleep(0.5)
            WaveEngine.VCLtest("biflow.write('%s')" % (biFlowName))
            
                
        if self.resultMetricsType == 1:        
            WaveEngine.VCLtest("biflow.read('%s')" % (biFlowName))
               
            WaveEngine.VCLtest("flowStats.read('%s','%s')" % (src_port, biFlowName))         
            TXframes = flowStats.txFlowFramesOk        
        
            WaveEngine.VCLtest("flowStats.read('%s','%s')" % (dst_port, biFlowName))
            RXframes = flowStats.rxFlowFramesOk
               
            latSum = flowStats.getRxFlowSumLatencyOverall()
            latCount = flowStats.getRxFlowLatencyCountOverall()
        
            self.flowStartStatVals[biFlowName] = {'txFrames' : TXframes, 'rxFrames' : RXframes, 'latSum' : latSum, 'latCount' : latCount}
        
        WaveEngine.VCLtest("biflow.read('%s')" % (biFlowName))
        WaveEngine.VCLtest("biflowTcp.readBiflow()")             	        
        WaveEngine.VCLtest("biflowTcp.setMss(%d)" % (self.flowSegSize))
        
        WaveEngine.VCLtest("biflowTcp.setWindow(%d)" % (self.rxWinSize))           
        WaveEngine.VCLtest("biflowTcp.modifyBiflow()")  
        WaveEngine.VCLtest("biflow.write('%s')" % (biFlowName))
         
        return biFlowName
    
      
    def destroyBiflows(self):
    	biflowTuple = biflow.getNames()
        myList = list( biflowTuple )
        for flowName in myList:
            WaveEngine.VCLtest("biflow.destroy('%s')" % flowName)    
    
    
    def MeasureFlow_Goodput(self, grpName, Flowname):
        src_port = self.listOfAllFlowsInGroup[grpName][Flowname]['srcPort']
        src_client = self.listOfAllFlowsInGroup[grpName][Flowname]['srcClient']
        des_port = self.listOfAllFlowsInGroup[grpName][Flowname]['dstPort']
        des_client = self.listOfAllFlowsInGroup[grpName][Flowname]['dstClient']                     
        TestDuration = time.time() - self.listOfAllFlowsInGroup[grpName][Flowname]['startTime']
        
        goodput_BPS = 0
        
        WaveEngine.VCLtest("ec.read('%s')" % (src_client))
        srcIp = ec.getIpAddress()
        srcMac = ec.getMacAddress()
        
        WaveEngine.VCLtest("ec.read('%s')" % (des_client))
        dstIp = ec.getIpAddress()
        dstMac = ec.getMacAddress()
        
        endPoints = (srcIp, srcMac, dstIp, dstMac)           
        
        WaveEngine.VCLtest("biflow.read('%s')" % (Flowname))        
        TxTcpOct = long(biflow.get("Total TCP Bytes TX"))  
        
        if TestDuration > 0:        
            goodput_BPS = round(TxTcpOct * 8 / float(TestDuration), 2)                       
        
        return (goodput_BPS, endPoints)
    
    
    def MeasureFlow_OLOAD_Goodput_LossRate(self, grpName, Flowname):     
        
        src_port = self.listOfAllFlowsInGroup[grpName][Flowname]['srcPort']
        src_client = self.listOfAllFlowsInGroup[grpName][Flowname]['srcClient']
        des_port = self.listOfAllFlowsInGroup[grpName][Flowname]['dstPort']
        des_client = self.listOfAllFlowsInGroup[grpName][Flowname]['dstClient']                     
        TestDuration = time.time() - self.listOfAllFlowsInGroup[grpName][Flowname]['startTime']
        
        iTxFrames = self.flowStartStatVals[Flowname]['txFrames']
        iRxFrames = self.flowStartStatVals[Flowname]['rxFrames']
        iLatSum   = self.flowStartStatVals[Flowname]['latSum']
        iLatCount = self.flowStartStatVals[Flowname]['latCount']
        
        WaveEngine.VCLtest("ec.read('%s')" % (src_client))
        srcIp = ec.getIpAddress()
        srcMac = ec.getMacAddress()
        
        WaveEngine.VCLtest("ec.read('%s')" % (des_client))
        dstIp = ec.getIpAddress()
        dstMac = ec.getMacAddress()
        
        endPoints = (srcIp, srcMac, dstIp, dstMac)        
            	    	
        WaveEngine.VCLtest("biflow.read('%s')" % (Flowname))
        frmSize = biflow.getFrameSize()
        
                
        WaveEngine.VCLtest("flowStats.read('%s','%s')" % (src_port, Flowname))         
        TXframes = flowStats.txFlowFramesOk - iTxFrames       
        
        WaveEngine.VCLtest("flowStats.read('%s','%s')" % (des_port, Flowname))
        RXframes = flowStats.rxFlowFramesOk - iRxFrames
        
        avgLatency = 0.0
        jitter = 0.0
        
        latSum = flowStats.getRxFlowSumLatencyOverall() - iLatSum
        latCount = flowStats.getRxFlowLatencyCountOverall() - iLatCount
        if latCount > 0:
                avgLatency = latSum / latCount
                avgLatency = avgLatency / 1000000.0        
        jitter = flowStats.getRxFlowSmoothedInterarrivalJitter() / 1000000.0
                    
        WaveEngine.VCLtest("biflow.read('%s')" % (Flowname))        
        TxTcpOct = long(biflow.get("Total TCP Bytes TX"))  
                
        if TXframes > 0:
            FrameLossRate = 100.0 * (TXframes - RXframes) / TXframes
        else:
            FrameLossRate = 0.0
        
            
        if TestDuration > 0:        
            OLOAD = round(TXframes * frmSize * 8 / float(TestDuration), 2)
            ALOAD = round(RXframes * frmSize * 8 / float(TestDuration), 2)                
            goodput_BPS = round(TxTcpOct * 8 / float(TestDuration), 2)                       
        else:
            OLOAD = 0
            ALOAD = 0             
            goodput_BPS = 0          
        
        if FrameLossRate <= 100:
            FrameLossRate = round(FrameLossRate, 2)
        else:
            FrameLossRate = 100    
        
        
        #print "Flow Name : %s, TX Frame : %d, RX Frames : %d, ALOAD : %f" % (Flowname, TXframes, RXframes, ALOAD )
         
        
        return (OLOAD, ALOAD, goodput_BPS, FrameLossRate, avgLatency, jitter, endPoints)     
        
    
    
    def getCharts( self ):
        """
        Returns dictionary of all chart objects supported by this test.
        """
        return self.finalGraphs
        
    
    def getInfo(self):
    	return """ TCP Scaling Test """
        
    
    
    def CloseCapture(self): 
        # Have to destroy all TCP connections before we created the capture files
        try:
            if self.SavePCAPfile:
                if self.PCAPFilename == None:
                    ScriptName = re.search("([.0-9a-zA-Z_-]+).py", sys._getframe(1).f_code.co_filename)
                    #self.PCAPFilename = "Hdwrlog_" + ScriptName.group(1)   
                    self.PCAPFilename = "Hdwrlog_" + self.testType + "_script"
                    WaveEngine.GetLogFile(self.CardList, self.PCAPFilename)  
                            	           
        except WaveEngine.RaiseException:
            WaveEngine.OutputstreamHDL('\n', WaveEngine.MSG_OK)
            (exc_type, exc_value, exc_traceback) = sys.exc_info()
            WaveEngine.OutputstreamHDL(str(exc_value), WaveEngine.MSG_ERROR)
        #WaveEngine.OutputstreamHDL("Thank you for using VeriWave (http://www.veriwave.com)\n", WaveEngine.MSG_OK)
    
    
    def validateTest(self):   	
    	
    	try:    	
    	    if len(self.waveClientTableStore.keys()) == 0:
    	        WaveEngine.OutputstreamHDL("Error: No client groups Configured", WaveEngine.MSG_ERROR)
                return -1
    	     
    	    self.numWifiGroups = 0
    	    self.numEthGroups = 0    	
    	      
    	    
            if ((self.numEthGroups * self.numWifiGroups) != 0) and (self.clientGroupTestMode == 0):
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
    	    
            for flwItem in self.clientServerFlowList:
                if int(flwItem['numFlows']) < self.maxCurrentFlows:
                    WaveEngine.OutputstreamHDL("Error: The number of concurrent flows per Port cannot be greater than\n       the number of number of flows configured in the test.", WaveEngine.MSG_ERROR)
                    return -1      
            
            return 0
            
        except:
            return 0    
    
    
    def createClientServer(self, clProfileName, port, clNum, lastClientIp, netmask, gateway, cType):
      
        clName = "%s_%d" % (clProfileName, clNum)        
        ipVal = self.IPv4toInt(lastClientIp)
        ip_addr = self.int2IPv4(ipVal + 1)
        ipBytes = ip_addr.split(".")
        if int(ipBytes[3]) in [0, 255]:
            ip_addr = self.int2IPv4(ipVal + 3)
            ipBytes = ip_addr.split(".")
             
        mac_addr = "00:00:%02x:%02x:%02x:%02x" % (int(ipBytes[0]),int(ipBytes[1]),int(ipBytes[2]),int(ipBytes[3]))
        
        clientData = [(clName, port, '00:00:00:00:00:00', mac_addr, ip_addr, netmask, gateway, (1, 'AUTO', '0.0.0.1'), {'Method': 'NONE'}, self.clientOptions)]
        WaveEngine.CreateClients(clientData)        
        WaveEngine.VCLtest("ec.doConnectEc('%s')" % (clName))     
        
        #WaveEngine.OutputstreamHDL("Connected %s : %s" % (cType, clName), WaveEngine.MSG_OK)            
        
        return (clName, ip_addr)
    
        
    def destroyClientServer(self, name):
        WaveEngine.VCLtest("ec.destroy('%s')" % (name))
        
        
    def startSingleFlow(self, fName):  
    	WaveEngine.VCLtest("flowGroup.read('startFlowGroup')")    	 
    	for flname in flowGroup.getFlowNames('startFlowGroup'):
           WaveEngine.VCLtest("flowGroup.remove('%s')" % (flname))      	 
        WaveEngine.VCLtest("flowGroup.add('%s')" % (fName))
        WaveEngine.VCLtest("flowGroup.write('startFlowGroup')")   
        WaveEngine.VCLtest("action.startFlowGroup('%s')" % ("startFlowGroup"))
        #WaveEngine.OutputstreamHDL("\nStarting Flow %s" % (fName), WaveEngine.MSG_OK)                   	    
    
    
    def stopSingleFlow(self, fName):  
    	WaveEngine.VCLtest("flowGroup.read('stopFlowGroup')")
        #for flname in flowGroup.getFlowNames('stopFlowGroup'):
        #   WaveEngine.VCLtest("flowGroup.remove('%s')" % (flname))
        WaveEngine.VCLtest("flowGroup.add('%s')" % (fName))
        WaveEngine.VCLtest("flowGroup.write('stopFlowGroup')")   
        WaveEngine.VCLtest("action.stopFlowGroup('%s')" % ("stopFlowGroup"))
        #WaveEngine.OutputstreamHDL("\nStopping Flow %s" % (fName), WaveEngine.MSG_OK)    
    
    
    def connectDisconnectBiFlow(self, flwName, op, connState):
        return WaveEngine.ConnectBiflow([flwName,], expectedState=connState, operation= op, noSummary=True)
        #retval = WaveEngine.ConnectBiflow([flwName,], expectedState=connState, operation= op, noSummary=True)
        #if retval < 0:
            #WaveEngine.OutputstreamHDL("TCP %s operation failed for Flow : %s\n" % (op, flwName), WaveEngine.MSG_ERROR)
        #    raise WaveEngine.RaiseException
        #WaveEngine.OutputstreamHDL("TCP %s operation Successful for Flow : %s\n" % (op, flwName), WaveEngine.MSG_OK)
        
        
    def destroyBiFlow(self, flowName):
    	WaveEngine.VCLtest("biflow.destroy('%s')" % flowName)    
    
    
    def initReport(self):
    	self.MyReport = WaveReport(os.path.join(self.LoggingDirectory, self.ReportFilename))
        if self.MyReport.Story == None:
            return
        
        reportTitle = "TCP Scaling Test Report"           
        self.MyReport.Title(reportTitle, self.DUTinfo)
    
    
    def distributionForList(self, dList, numSteps = 20):
        xValList = []
        yValList = []
        minVal = 0
        maxVal = self.mma(dList, 1)[1]
        
        stepSize = (maxVal - minVal) / numSteps
        
        if minVal == maxVal:
            return ([0,], [len(dList),])
         
        maxVal = maxVal + 2*stepSize 
        
        xValList.append(minVal)
        yValList.append(0)
        
        currStartVal = minVal
        currEndVal = minVal + stepSize
        
        while currEndVal <= maxVal:
            xValList.append(currEndVal)            
            yCount = 0
            for itm in dList:
                if (itm > currStartVal) and (itm <= currEndVal):
                    yCount += 1
                    
            yValList.append(yCount)
            
            currStartVal = currEndVal
            currEndVal += stepSize
        
        
        return (xValList, yValList)        
         
    
    
    def stopTest(self, val):
      if val == 1:
          self.stopTheTest = True   
    
    def mma(self, dList, md = 0, rd = 3):
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
        
        if md == 0:
            return round(avgVal,2)
        else:    
            return (round(minVal,rd), round(maxVal,rd), round(avgVal,rd)) 
        
    
    def printReport(self):
      
        self.gputList = []
        self.connTimeList = []
        self.lossList = []
        self.latencyList = []
        self.jitterList = []
        self.slaList = []
        passFailValsList = []
        
        if self.resultMetricsType == 1:
            rIndex = 13
        else:
            rIndex = 7
        
        startIndex = 0        
        while len(self.ResultsForCSVfile[startIndex]) < rIndex:
            startIndex += 1
        startIndex += 1
        
        for ii in range(startIndex, len(self.ResultsForCSVfile)):            
            
            self.connTimeList.append(float(self.ResultsForCSVfile[ii][5]))            
            gput_Kbps = float(self.ResultsForCSVfile[ii][6])
            self.gputList.append(gput_Kbps)
            if self.resultMetricsType == 1:
                self.lossList.append(float(self.ResultsForCSVfile[ii][10]))
                self.latencyList.append(float(self.ResultsForCSVfile[ii][11]))
                self.jitterList.append(float(self.ResultsForCSVfile[ii][12]))
            
            gputPer = (gput_Kbps * 100.0) / self.flowRate
            if gputPer < self.slaPercent:
                self.slaList.append(0)
            else:
                self.slaList.append(1)
        
        #self.distributionForList(self.gputList)        
        
        passCount = (sum(self.slaList) * 100.0) / len(self.slaList)
        
        passFailValsList.append(( passCount, (100 - passCount)) )
          	
    	self.MyReport.InsertHeader("Overview")
    	
    	testDisc = """This test allows the user to setup and generate TCP traffic from upto 80,000 stateful TCP flows through the Device Under Test (DUT). The test will allow the user to setup upto 500 concurrent TCP sessions per port and then add new sessions one at a time by destroying the oldest session. The test will compute the performance of each indivudual TCP flow and report the summary and detailed results of the Goodput, Latency, Packet Loss, Jitter, Connection Time metrics."""
                
        self.MyReport.InsertParagraph(testDisc)
        
        self.MyReport.InsertHeader("Result Summary")
        
        self.MyReport.InsertParagraph("")
        
        if len(passFailValsList) > 0:
            summaryGraph1 = PassFailGraph(6*inch, 2.5*inch,['TCP',], passFailValsList, 'PASS/FAIL Percentages for Flows that met SLA', options=PF_OPTION_SHOWPERCENT | PF_OPTION_LEGENDRIGHT)
            self.MyReport.InsertObject(summaryGraph1)
            self.finalGraphs['PASS/FAIL Percentages of Traffic Types that met SLA'] = summaryGraph1  
        
                      
        ##### Summary results table ############
        self.MyReport.InsertParagraph("")
        self.MyReport.InsertParagraph("")
        
        self.MyReport.InsertParagraph("The Table below shows the average results of all the flows in the test:") 
        
        if self.resultMetricsType == 1:
            wsResSummary = [('Num Flows', 'Num Connection Failures', 'TCP Goodput (Kbps)', 'TCP Connect Times(msces)', 'Latency (msec)', 'Jitter (msec)', ' % Packet Loss')]        
            wsResSummary.append((len(self.gputList), self.numConnectFails, self.mma(self.gputList), self.mma(self.connTimeList), self.mma(self.latencyList), self.mma(self.jitterList), self.mma(self.lossList)))
            self.MyReport.InsertDetailedTable(wsResSummary, columns=[0.6*inch, 0.6*inch, 1.0*inch, 1.0*inch, 0.8*inch, 0.8*inch, 1.0*inch])
        else:
            wsResSummary = [('Num Flows', 'Num Connection Failures', ' TCP Goodput (Kbps)', 'TCP Connect Times(msces)')]        
            wsResSummary.append((len(self.gputList), self.numConnectFails , self.mma(self.gputList), self.mma(self.connTimeList)))
            self.MyReport.InsertDetailedTable(wsResSummary, columns=[1.0*inch, 1.0*inch, 2.0*inch, 2.0*inch])
        
        
        
        
        self.MyReport.InsertPageBreak()
        
        
        self.MyReport.InsertHeader("Detailed Results and Charts")
        
        self.MyReport.InsertParagraph("")
        self.MyReport.InsertParagraph("")
        
        self.MyReport.InsertParagraph("The chart below shows the distribution of Goodput of all the flows.")
        
        (xvals, yvals) = self.distributionForList(self.gputList)
        
        graphSummary = Qlib.GenericGraph(xvals, "GoodPut (Kbps)", [yvals,] ,"GoodPut Distribution", "GoodPut Distribution for all flows", ['Bar'])
        self.MyReport.InsertObject(graphSummary)         
        self.finalGraphs['GoodPut Distribution for all flows'] = graphSummary    
        
                
        self.MyReport.InsertParagraph("")
        self.MyReport.InsertParagraph("")
        
        self.MyReport.InsertParagraph("The chart below shows the distribution of TCP Connection Times of all the flows.")
        (xvals, yvals) = self.distributionForList(self.connTimeList)
        
        graphSummary = Qlib.GenericGraph(xvals, "Connection Time (msecs) ", [yvals,] ,"TCP Connection Time Distribution", "TCP Connection Time Distribution for all flows", ['Bar'])
        self.MyReport.InsertObject(graphSummary)         
        self.finalGraphs['TCP Connection Time Distribution for all flows'] = graphSummary         
        
        
        if self.resultMetricsType == 1: 
        
            self.MyReport.InsertParagraph("")
            self.MyReport.InsertParagraph("")
        
            self.MyReport.InsertParagraph("The chart below shows the distribution of Latency Values of all the flows.")
            (xvals, yvals) = self.distributionForList(self.latencyList)
        
            graphSummary = Qlib.GenericGraph(xvals, "Latency (msecs) ", [yvals,] ,"Layer2 Latency Distribution", "Layer2 Latency Distribution for all flows", ['Bar'])
            self.MyReport.InsertObject(graphSummary)         
            self.finalGraphs['Layer2 Latency Distribution for all flows'] = graphSummary
        
        
            self.MyReport.InsertParagraph("")
            self.MyReport.InsertParagraph("")
        
            self.MyReport.InsertParagraph("The chart below shows the distribution of Jitter Values of all the flows.")
            (xvals, yvals) = self.distributionForList(self.jitterList)
        
            graphSummary = Qlib.GenericGraph(xvals, "Jitter (msecs) ", [yvals,] ,"Layer2 Jitter Distribution", "Layer2 Jitter Distribution for all flows", ['Bar'])
            self.MyReport.InsertObject(graphSummary)         
            self.finalGraphs['Layer2 Jitter Distribution for all flows'] = graphSummary
        
        
            self.MyReport.InsertParagraph("")
            self.MyReport.InsertParagraph("")
        
            self.MyReport.InsertParagraph("The chart below shows the distribution of Percentage Packet Loss Values of all the flows.")
            
            (xvals, yvals) = self.distributionForList(self.lossList)
        
            graphSummary = Qlib.GenericGraph(xvals, "% Packet Loss ", [yvals,] ,"% Packet Loss Distribution", "% Packet Loss Distribution for all flows", ['Bar'])
            self.MyReport.InsertObject(graphSummary)         
            self.finalGraphs['% Packet Loss Distribution for all flows'] = graphSummary  
        
        
        self.MyReport.InsertHeader("Other Information") 
        OtherParameters = []
        OtherParameters.append( ( 'Results Directory',  str( self.LoggingDirectory ) )  )
        #for item in self.OtherInfoData.items():
        #    OtherParameters.append( item )
        OtherParameters.append( ( 'WaveTest Version',   str( action.getVclVersionStr() ) ) )
        self.MyReport.InsertGenericTable( OtherParameters , columns = [ 1.5*inch, 4.5*inch ] ) 
                       
        
        if self.generatePdfReportF:        
            self.MyReport.Print() 
    
    
    
    def run(self):
    	try:
    	    self.ExitStatus = 0
            self.stopTheTest = False
    	    startTime = time.time()            
    	    #return  
    	      	    
    	    if self.validateTest() == -1:
    	        WaveEngine.OutputstreamHDL("\n\nAborting the Test", WaveEngine.MSG_ERROR)
               	return self.ExitStatus
             
            self.initReport()    
    	    self.initailizeCSVfile()   
            WaveEngine.OpenLogging(Path=self.LoggingDirectory, Timelog = self.TimeLogFileName, Console = self.ConsoleLogFileName, RSSI = self.RSSILogFileName, Detailed = self.DetailedFilename)   	         	
    	    chassisName = self.CardMap[self.CardMap.keys()[0]][0]
            
    	    WaveEngine.VCLtest("chassis.connect('%s')" % chassisName)
            
    	    WaveEngine.OutputstreamHDL("WaveEngine Version %s\n" % WaveEngine.full_version, WaveEngine.MSG_OK)
            WaveEngine.OutputstreamHDL("Framework Version %s\n" % WaveEngine.action.getVclVersionStr(), WaveEngine.MSG_OK)
            WaveEngine.OutputstreamHDL("Firmware Version %s\n\n\n" % chassis.version, WaveEngine.MSG_OK)
    	            
    	    WaveEngine.VCLtest("chassis.disconnect('%s')" % chassisName)
                       
    	           
    	    #WaveEngine.ConnectPorts(self.CardList, self.CardMap, self.PortOptions)
            self.connectWimixPorts(self.CardList, self.CardMap, self.PortOptions) 
    	    
            if WaveEngine.WaitforEthernetLink(self.CardList) == -1:
                raise WaveEngine.RaiseException
                        
            WaveEngine.ClearAllCounter(self.CardList)
            
            flowNum = 0
            self.currFlowNumFlowGroup = {}
            self.listOfActiveClientsInGroup = {}
            self.listOfAllClientsInGroup = {}
            self.listOfActiveServersInGroup = {}
            self.listOfAllServerInGroup = {}
            self.lastIpAddrInClientGroup = {}
            self.lastIpAddrInServerGroup = {}
            self.flowConnectTimes = {}
            self.numClientsPerPort = {}
            self.flowStartStatVals = {}
            
            iRatePps = self.flowRate * 1000 / (self.flowSegSize * 8)
            self.layer2FlowRate = iRatePps * ((self.flowSegSize + 58) * 8) / 1000.0
            
            
            for prts in self.CardMap.keys():
                self.numClientsPerPort[prts] = 0       
            
            
            self.listOfActiveFlowsInGroup = {}
            self.listOfAllFlowsInGroup = {}
            
            WaveEngine.VCLtest("flowGroup.create('startFlowGroup')")   	
    	    WaveEngine.VCLtest("flowGroup.write('startFlowGroup')")
            
            WaveEngine.VCLtest("flowGroup.create('stopFlowGroup')")   	
    	    WaveEngine.VCLtest("flowGroup.write('stopFlowGroup')")       	
    	
                    
            for eachFlowGroup in self.clientServerFlowList:
               groupName = eachFlowGroup['groupName']
               self.currFlowNumFlowGroup[groupName] = 0
               self.lastIpAddrInClientGroup[groupName] = eachFlowGroup['clientStartIp']
               self.lastIpAddrInServerGroup[groupName] = eachFlowGroup['serverStartIp']
            
            self.testStartTime = time.time()
            self.tNumClients = 0
            self.tActiveClients = 0
            self.tNumServers = 0
            self.tActiveServers = 0
            self.tNumFlows = 0
            self.tActiveFlows = 0
            self.lastGput = 'N/A'
            self.minGput = 'N/A'
            self.maxGput = 'N/A'
            self.avgGput = 'N/A'
            self.numConnectFails = 0
            self.numDisconnectFails = 0
            startFlw = 0
            stopFlw = 0
            numFlows = 0
                      
            #WaveEngine.OutputstreamHDL("\tTIME\tT_CLTs\tA_CLTs\tT_SRVs\tA_SRVs\tT_FLWs\tA_FLWs\tL_GPUT \n", WaveEngine.MSG_OK)
            
            WaveEngine.OutputstreamHDL("\tTIME\tTOTAL\tACTIVE\tTOTAL\tACTIVE\tTOTAL\tACTIVE\tCONN\tLAST_FLOW\n", WaveEngine.MSG_OK)
            WaveEngine.OutputstreamHDL("\t\tCLIENTs\tCLIENTs\tSERVERs\tSERVERs\tFLOWs\tFLOWs\tFAILs\tGPUT(Kbps)\n\n", WaveEngine.MSG_OK)
            
            if self.resultMetricsType == 1: 
                self.ResultsForCSVfile.append(['flowName', 'srcIp', 'srcMac', 'dstIp', 'dstMac', 'TCP Conn Time (msecs)', 'Goodput (Kbps)', 'Layer2_ILOAD (Kbps)', 'Layer2_OLOAD (Kbps)', 'Layer2_Frate (Kbps)', 'Layer2_%Loss', 'Avg Latency (msecs)', 'Jitter (msecs)'],)
            else:
                self.ResultsForCSVfile.append(['flowName', 'srcIp', 'srcMac', 'dstIp', 'dstMac', 'TCP Conn Time (msecs)', 'Goodput (Kbps)'],)
            
            
            self.gPutValList = []
                              
            while flowNum < (self.totalNumFlows + self.maxCurrentFlows):
               
               if self.stopTheTest:
                   #self.printReport()
                   raise WaveEngine.RaiseException
                   
               
               for eachFlowGroup in self.clientServerFlowList:
                  grpName = eachFlowGroup['groupName']
                  clProfileName = eachFlowGroup['client']
                  srProfileName = eachFlowGroup['server']
                  clPortName = eachFlowGroup['clientPort']
                  
                  if grpName not in self.listOfActiveClientsInGroup:
                      self.listOfActiveClientsInGroup[grpName] = []
                      
                  if grpName not in self.listOfAllClientsInGroup:    
                      self.listOfAllClientsInGroup[grpName] = []
                  
                  if grpName not in self.listOfActiveServersInGroup:     
                      self.listOfActiveServersInGroup[grpName] = []
                  
                  if grpName not in self.listOfAllServerInGroup:     
                      self.listOfAllServerInGroup[grpName] = []
                   
                  if grpName not in self.listOfActiveFlowsInGroup:      
                      self.listOfActiveFlowsInGroup[grpName] = []
                  
                  if grpName not in self.listOfAllFlowsInGroup: 
                      self.listOfAllFlowsInGroup[grpName] = {}
                  
                               
                  
                  #if flowNum >= self.maxCurrentFlows:
                  if self.numClientsPerPort[clPortName] >= self.maxCurrentFlows:
                     
                      flowRemoveName = self.listOfActiveFlowsInGroup[grpName][0]
                      self.stopSingleFlow(flowRemoveName)
                      
                      if self.resultMetricsType == 1:                       
                          (OLOAD, ALOAD, goodput_BPS, FrameLossRate, avgLatency, jitter, endPoints) = self.MeasureFlow_OLOAD_Goodput_LossRate(grpName, flowRemoveName)
                      else:
                          (goodput_BPS, endPoints) = self.MeasureFlow_Goodput(grpName, flowRemoveName) 
                      
                      (srcIp, srcMac, dstIp, dstMac) = endPoints
                      gput_Kbps = goodput_BPS / 1000.0
                      self.gPutValList.append(gput_Kbps)
                      if flowRemoveName in self.flowConnectTimes:
                          connTime = self.flowConnectTimes[flowRemoveName]
                      else:
                          #connTime = "N/A"
                          connTime = -1
                          
                      
                        
                      
                      if self.resultMetricsType == 1:    
                          self.ResultsForCSVfile.append([flowRemoveName, srcIp, srcMac, dstIp, dstMac, connTime, round(gput_Kbps, 2), round(self.layer2FlowRate, 2), round(OLOAD / 1000.0, 2), round(ALOAD / 1000.0, 2), FrameLossRate, avgLatency, jitter])
                      else:
                          self.ResultsForCSVfile.append([flowRemoveName, srcIp, srcMac, dstIp, dstMac, connTime, gput_Kbps])
                      
                      
                      if self.realTimeChartingFlag:
                          if (numFlows - self.maxCurrentFlows) >= self.resultFlowCount:
                              del self.gPutValList[0]
                              #del self.ResultsForCSVfile[0]
                              startFlw += 1
                              stopFlw += 1
                          else:
                              startFlw = 0
                              stopFlw = len(self.gPutValList)
                      
                      
                          rNums = [str((int(val)+1)) for val in range(startFlw, stopFlw)]
                      
                          cTitle = "Goodput For last " + str(self.resultFlowCount) + " TCP Flows" 
                          gputGraph = Qlib.GenericGraph(rNums, "Flow Number", [self.gPutValList,] ,"Goodput (Kbps)", cTitle, ['Line'])
                          self.finalGraphs['Goodput For TCP Flows']= gputGraph
                
            
                      if self.connectDisconnectBiFlow(flowRemoveName, "disconnect", 'IDLE') < 0:
                          self.numDisconnectFails += 1
                          if self.numDisconnectFails > self.numFailedConn:
                              WaveEngine.OutputstreamHDL("Number of Failed DisConnections exceeded user specified Limit..Exiting the Test", WaveEngine.MSG_ERROR)
                              raise WaveEngine.RaiseException
                      
                      self.connectDisconnectBiFlow(flowRemoveName, "resetConnection", 'IDLE')
                      
                      
                      self.tActiveFlows -= 1
                      self.lastGput = str(round(goodput_BPS / 1000.0, 0))
                      
                      #(self.minGput,self.maxGput,self.avgGput) = self.mma(self.gPutValList, 1, 0) 
                      
                      
                      #self.Print("\r%s : ILOAD = %0.3f Kbps OLOAD = %0.3f Kbps GOODPUT = %0.3f Kbps Layer2 Loss = %d" % (flowRemoveName, self.flowRate, OLOAD / 1000.0, goodput_BPS / 1000.0, FrameLossRate))  
                      self.destroyBiFlow(flowRemoveName)
                      del self.listOfActiveFlowsInGroup[grpName][0]
                      
                      clRemoveName = self.listOfActiveClientsInGroup[grpName][0]
                      srRemoveName = self.listOfActiveServersInGroup[grpName][0]
                      self.destroyClientServer(clRemoveName)
                      self.destroyClientServer(srRemoveName)
                      del self.listOfActiveClientsInGroup[grpName][0]
                      del self.listOfActiveServersInGroup[grpName][0]
                      self.tActiveClients -= 1
                      self.tActiveServers -= 1
                     
                  
                  if flowNum < self.totalNumFlows:                    
                       
                      clNum = len(self.listOfActiveClientsInGroup[grpName])
                      numClients = len(self.listOfAllClientsInGroup[grpName])
                      lastClientIp = self.lastClientIpAddrInGroup[grpName]                
                      lastServerIp = self.lastServerIpAddrInGroup[grpName]
                      clPort = eachFlowGroup['clientPort']
                      srPort = eachFlowGroup['serverPort']
                  
                      (clName, ipAddr) = self.createClientServer(clProfileName, clPort, (numClients + 1), lastClientIp, eachFlowGroup['clNetmask'], eachFlowGroup['clGateway'], 'client')
                      self.lastClientIpAddrInGroup[grpName] = ipAddr
                      self.listOfActiveClientsInGroup[grpName].append(clName)
                      self.listOfAllClientsInGroup[grpName].append(clName)
                  
                      self.tNumClients += 1
                      self.tActiveClients += 1
                      
                      self.numClientsPerPort[clPort] += 1
                      self.numClientsPerPort[srPort] += 1                     
                      
                      (srName, ipAddr) = self.createClientServer(srProfileName, srPort, (numClients + 1), lastServerIp, eachFlowGroup['srNetmask'], eachFlowGroup['srGateway'], 'server')
                      self.lastServerIpAddrInGroup[grpName] = ipAddr
                      self.listOfActiveServersInGroup[grpName].append(srName)
                      self.listOfAllServerInGroup[grpName].append(srName)
                  
                      self.tNumServers += 1
                      self.tActiveServers += 1
                      
                      
                                    
                      numFlows = len(self.listOfAllFlowsInGroup[grpName]) 
                                   
                      if self.flowDirection == 0:
                          flwName = self.setupBiFlow(clName, srName, clPort, srPort)
                          flowDetails = {'flwName' : flwName, 'srcClient' : clName, 'srcPort' : eachFlowGroup['clientPort'], 'dstClient' : srName, 'dstPort' : eachFlowGroup['serverPort'], 'startTime' : time.time() }
                      else:
                          flwName = self.setupBiFlow(srName, clName, srPort, clPort)
                          flowDetails = {'srcClient' : srName, 'srcPort' : eachFlowGroup['serverPort'], 'dstClient' : clName, 'dstPort' : eachFlowGroup['clientPort'], 'startTime' : time.time() }
                  
                      self.listOfActiveFlowsInGroup[grpName].append(flwName)                                 
                      self.listOfAllFlowsInGroup[grpName][flwName] = flowDetails
                      
                      connStartTime = time.time() 
                      if self.connectDisconnectBiFlow(flwName, "connect", 'READY') < 0:
                          self.numConnectFails += 1
                      else:    
                          self.flowConnectTimes[flwName] = round((time.time() - connStartTime) * 1000.0, 2)
                          self.numConnectFails = 0
                      
                      if self.numConnectFails > self.numFailedConn:
                          WaveEngine.OutputstreamHDL("\n\n ERROR: Number of Consecutive Failed Connections exceeded user specified Limit..Exiting the Test", WaveEngine.MSG_ERROR)
                          raise WaveEngine.RaiseException
                              
                      self.tNumFlows += 1
                      self.tActiveFlows += 1
                                    
                      self.startSingleFlow(flwName)
                  
                      self.listOfAllFlowsInGroup[grpName][flwName]['startTime'] == time.time()
                  
                  
                  tElapsed = time.time() - self.testStartTime
                  
                  if self.realTimeChartingFlag:
                      WaveEngine.OutputstreamHDL("\rCurrent:%0.2f\t%4d\t%4d\t%4d\t%4d\t%4d\t%4d\t%4d\t%s " % (tElapsed, self.tNumClients, self.tActiveClients, self.tNumServers, self.tActiveServers, self.tNumFlows, self.tActiveFlows, self.numConnectFails, self.lastGput), WaveEngine.MSG_SUCCESS)
                  else:
                      WaveEngine.OutputstreamHDL("\rCurrent:%0.2f\t%4d\t%4d\t%4d\t%4d\t%4d\t%4d\t%4d\t%s " % (tElapsed, self.tNumClients, self.tActiveClients, self.tNumServers, self.tActiveServers, self.tNumFlows, self.tActiveFlows, self.numConnectFails, self.lastGput), WaveEngine.MSG_OK)
                  #if flowNum > self.totalNumFlows:
                  #   break
                  
                  flowNum += 1
                                              
            #self.CloseCapture()
            #WaveEngine.CloseLogging()
            WaveEngine.OutputstreamHDL("\n\n", WaveEngine.MSG_OK)
            self.SaveResults()
            if self.printReport() == -1:
                raise WaveEngine.RaiseException
            self.CloseShop()
                 
            
        except WaveEngine.RaiseException:
            WaveEngine.OutputstreamHDL('\n', WaveEngine.MSG_OK)
            (exc_type, exc_value, exc_traceback) = sys.exc_info()
            WaveEngine.OutputstreamHDL(str(exc_value), WaveEngine.MSG_ERROR)
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
    
