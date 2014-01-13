from vcl import *
from basetest import *
from BaseEventClass import processPreviousRoamStats, saveAndWriteToDetailedLogs,\
                           reportPreviousRoamStatus, \
                           updateDetailedResultsWithPrevRinfo, \
                           getColsWithNumEntries
import WaveEngine as WE
from threading import Thread
import time
import copy
import Queue
import Qlib

#from reportlab.graphics.charts.axes import XValueAxis
#from reportlab.graphics.shapes import Drawing, Line, String, Rect, STATE_DEFAULTS
#from reportlab.graphics.charts.linecharts import HorizontalLineChart
#from reportlab.graphics.charts.linecharts import makeMarker
#from reportlab.graphics import renderPDF
#from reportlab.graphics.charts.barcharts import VerticalBarChart
#from reportlab.lib import colors
#from reportlab.graphics.charts.legends import Legend, LineLegend
#from reportlab.graphics.charts.textlabels import Label

#The classes defined in the module are of new class type
__metaclass__ = type

class RoamingCommon:
    def __init__(self):
        self.CardList = []
        self.FlowList = odict.OrderedDict()
        self.LearnFlowList = odict.OrderedDict()
        #TODO - Change all {} to OrderedDict ? 
        self.Clientgroup = {}
        self.Roamprofiles = {}
        self.Powerprofiles = {}
        self.ClientgrpClients = {}
        self.InvalidClientgrps = []
        self.ClientgrpFlows = {}
        self.ResultsSummaryPerSSID = {}
        self.ClientPortBSSIDList = {}
        self.splitRunF = True  
        self.lastRunTime = 0.0
        self.schedQ = Queue.Queue()
        self.totalRoams = 0
        self.totalClients = 0
        self.ResultsSummaryPerClient = {}
        self.ResultsSummaryPerCG = {}
        self.ResultsSummaryPerTest = {}
        self.testStartTime = 0    
        self.testEndTime = 0
        self.testCharts = {}
        self.UserPassFailCriteria= {}
        self.UserPassFailCriteria['user']='False'

        self.FinalResult=0
  
        self.ResultsSummaryPerCG_PF= {} 
        self.ResultsSummaryPerClient_PF={}
        
    def SetTotalDuration(self, time):
        self.totaltime = time
    def SetSettleTime(self, time):
        self.settletime = time
    def SetARPRetries(self, retry):
        self.arpretries = retry
    def SetARPRate(self, rate):
        self.arprate = rate
    def SetARTTimeout(self, timeout):
        self.arptimeout = timeout
    def SetAgingTime(self, time):
        self.agingtime = time
    def SetLearningTime(self, time):
        self.learningtime = time
        
    def writeAPinformation(self, clientsDict):
        WE.WriteAPinformation(clientsDict)
        
    def getMax(self, mainList):
        #mainList is a list of Lists. We return
        #the list with the maximum number of elements
        maxlen = 0
        maxLenList = []
        for List in mainList:
            if isinstance(List, list) == True:
                if len(List) > maxlen:
                   maxlen = len(List)
                   maxLenList = List 
        return maxLenList
    
    def getTotalRoamClients(self):
        cgNameList = self.Clientgroup.keys()
        totalRoamClients  = 0
        for CGname in cgNameList:
            totalRoamClients += self.Clientgroups[CGname]['NumClients']
        return totalRoamClients
    
    def stripLeftAndRight(self, str):
        tmpStr = str
        #When we write the string in multiple lines using \ at the end of 
        #we get unnecessary spaces added at every instance of \ (and newline) when 
        #the entire string is written to the csv file
        tmpStr = ','.join([(stri.lstrip()).rstrip() for stri in tmpStr.split(',')])
        
        return tmpStr
        
    def PrintRealtimeStats(self, Ethports, Wports):
        for ethport in Ethports:
            (txpkts, rxpkts, txrate, rxrate) = WE.GetPortstats(ethport)
            self.Print("%s : Txpkts - %d, Rxpkts - %d, Txrate - %d, Rxrate - %d\n"  % (ethport, txpkts, rxpkts, txrate, rxrate), 'DBG')
    
        for wport in Wports:
            (txpkts, rxpkts, txrate, rxrate) = WE.GetPortstats(wport)
            self.Print("%s : Txpkts - %d, Rxpkts - %d, Txrate - %d, Rxrate - %d\n" % (wport, txpkts, rxpkts, txrate, rxrate), 'DBG')

    def getLastRoamDetails(self):
        """
        This method must be defined in the super class
        """
        pass
    
    def collectLastRoamDetails(self):
        """
        The last roam event details (of all the roam clients) weren't captured when 
        we 'run' the 'Roam' event (BaseEventClass.py), we get those details in this 
        method for each roam event.
        """
        
        roamedClientDict = self.getRoamedClientList()
                
        #Dictionary to hold the roam delay of every client in the last roam event
        #Used later to construct delaydict etc
        lastRoamDetails = {}    
                           
        for CGName in roamedClientDict:
            secMethod = self.Clientgroup[CGName].Getsecurity()['Method']

            for clientName in roamedClientDict[CGName]:
                lastRDetails = self.getLastRoamDetails(clientName)
                
                if lastRDetails != -1:
                    detailedResults, failedStep =  \
                        processPreviousRoamStats(CGName, clientName, secMethod)
                    
                    detailedResults = \
                        updateDetailedResultsWithPrevRinfo(detailedResults,
                                                           lastRDetails)   
                    
                    columnsWithNumericEntries = getColsWithNumEntries(secMethod)
                         
                    saveAndWriteToDetailedLogs(detailedResults,
                                               columnsWithNumericEntries)

                    roamDelay = detailedResults['AP Roam Delay']
                    reportPreviousRoamStatus(clientName, roamDelay, failedStep)
                    
                    lastRTime, _, _,_,_ = lastRDetails
                    if self.testEndTime < lastRTime:
                        self.testEndTime = lastRTime
                        
                    lastRoamDetails[clientName] = (lastRTime, roamDelay)
        
        return lastRoamDetails
    
    
    def processStats(self, lastRoamDetails):
        """
        Collect the roam details of the last roam event of every client.
        Add the Tx and Rx details of every flow of every client to Detailed Results file. 
        Construct self.ResultsSummaryPerSSID containing some SSID based information. 
        Construct and write 'DataSet 1', 'DataSet 2'  and 'DataSet 3' in Results CSV file (Results_roaming_benchmark.csv).
        """
        #collect stats
        delaydict = {}
        roamcountdict = {}
        roam_time_list = []
        roamDelayTime = []

        clientData = self.getClientData()
        #Compute the total number of roams, total number of clients which are required in 
        #categorizing the reports
        for CGName in clientData.keys():
            for clientname in clientData[CGName].keys():
                self.totalRoams += len (clientData[CGName][clientname])
                self.totalClients += 1

        #Compute some Misc values

        roamDelayTimesDict = {}
        for CGName in clientData.keys():
            if self.totalClients > 25:
                roamDelayTimesDict[CGName] = []
            for clientname in clientData[CGName].keys():
                roamcount = 0
                clientRoamDelayTimes = []
                delaydict[clientname] = []
                for stats in clientData[CGName][clientname]:
                    (rTime, roam_delay, ) =  stats
                                
                    clientRoamDelayTimes.append((rTime, roam_delay))
                    delaydict[clientname].append(roam_delay)
                    roam_time_list.append(rTime)
                    roamcount += 1
                lastRoamTime, lastRoamDelay = lastRoamDetails[clientname]
                delaydict[clientname].append(lastRoamDelay)
                clientRoamDelayTimes.append((lastRoamTime, lastRoamDelay))
                roamcountdict[clientname] = roamcount
                roamDelayTime += clientRoamDelayTimes
            
                if self.totalClients <= 25:
                    roamDelayTimesDict[clientname] = clientRoamDelayTimes
                else:
                    roamDelayTimesDict[CGName] += clientRoamDelayTimes

        #Create roamDelayTimesDict based on SSID
        roamDelayTimesSSID = {}
        if self.totalClients > 25:
            if self.totalRoams > 10:
                for CGName in clientData.keys():
                    ssidname = self.getTestCGsecurity(CGName, 'ssid')
                    if ssidname in roamDelayTimesSSID.keys():
                        roamDelayTimesSSID[ssidname] += roamDelayTimesDict[CGName]
                    else:
                        roamDelayTimesSSID[ssidname] = []
                        roamDelayTimesSSID[ssidname] += roamDelayTimesDict[CGName]
                             
   
        self.Print("\nProcessing Stats. Please wait..\n", 'OK')

        #Add the Tx and Rx details of every flow of every client to Detailed Results file (Detailed_roaming_benchmark.csv)
        #Add 'DataSet 1' ((name, roamcountdict[name], minm, maxm, avg, lost_pkts_per_client_per_roam, LostData) 
        #to Results CSV file (Results_roaming_benchmark.csv)
        #Collect the information required for the report, thus create self.ResultsSummaryPerClient,
        #self.ResultsSummaryPerCG, self.ResultsSummaryPerSSID
        final_roam_delay_list = []
        CGNames = clientData.keys()
        CGNames.sort()
        #Initialisation of variables for holding large-test results
        totalMinDelay = 50001    #50000 is the maximum valid value for roam delay, for sorting, use max value as defualt
        totalAvgDelay = totalMaxDelay = totalPktLoss = totalRoams = totalFailedRoams = 0
        totalAvgDelayList = []
        self.ResultsForCSVfile.append(('Time',))
        if  self.UserPassFailCriteria['user'] == "True":
            self.ResultsForCSVfile.append(('Start DataSet 1',
                                       'Total Roams',
                                       'Min Roam Delay',
                                       'Avg Roam Delay',
                                       'Max Roam Delay',
                                       'Pkt Loss per Roam',
                                       'Failed Roams',
                                       'USC:RF',
                                       'USC:RD'))
        else:
          self.ResultsForCSVfile.append(('Start DataSet 1', 
                                          'Total Roams', 
                                          'Min Roam Delay', 
                                          'Avg Roam Delay', 
                                          'Max Roam Delay', 
                                          'Pkt Loss per Roam', 
                                          'Failed Roams',))

        for CGname in CGNames:
            self.Print("")    #To make sure the GUI is responsive
            self.Print("\nClient Group - %s\n" % CGname)
            if self.testName in ['Roaming Benchmark', 'Roaming Service Quality']:
                roamSourcePort = self.roamSourcePorts[CGname]
            elif self.testName == 'Roaming Delay':
                roamSourcePort = self.Port8023_Name
            detailedCSVResults = []    #One of the set of details written to detailed logs
            detailedCSVResIndex = 0
            detailedCSVresultstmplist = []
            detailedCSVresultsportlist = ['','']    #To count the number of ports on which the MC roams to
            detailedCSVResults.append("Client Group, %s" % CGname) #Write line 1
            WE.WriteDetailedLog([detailedCSVResults[detailedCSVResIndex]])
            detailedCSVResIndex +=1
            clientNames = clientData[CGname].keys()
            clientNames.sort()
            #Initialise group based information variables
            ssidname = self.getTestCGsecurity(CGname, 'ssid')
            groupMinDelay = 50001    #the max roamDelay can be is 50000,
            groupMaxDelay = 0    #ofcourse, min roamDelay can be is 4, but we choose to initialise to 0
            groupAvgDelay = groupPktLoss = groupRoamCount = groupFailedRoams = \
            groupAvgDelayProduct = 0

            for name in clientNames:
                if roamcountdict[name] == 0:
                    continue
                WE.VCLtest("mc.deauthenticate('%s', %d)" % (name, 0))
                detailedCSVresultsportlist = ['','']
                clientflags = self.getTestCGsecurity(CGname, 'otherflags')
                pmk_cache_F = False
                if 'pmkid_cache' in clientflags.keys():
                    pmk_cache_F = clientflags['pmkid_cache']
                if name in delaydict.keys():
                    for flowname in self.FlowList.keys():
                        if self.FlowList[flowname][3] == name:
                            break
                    tx_flow_roam_end = WE.GetTxflowstats(
                            roamSourcePort, flowname)
                    rx_pkts_per_client = 0
                    if name not in self.ClientPortBSSIDList.keys():
                        continue
                    portlist = self.ClientPortBSSIDList[name][0]
                    bssidlist = self.ClientPortBSSIDList[name][1]
                    detailedCSVresultstmplist =[]
                    for j in range(len(portlist)):
                        rx_flow_pkts = WE.GetRxflowstats(
                                portlist[j], flowname)
                        detailedCSVresultsportlist[0] += "%s (Rx%d)," %(portlist[j],(j+1))
                        detailedCSVresultsportlist[1] += "%d,"
                        detailedCSVresultstmplist += [rx_flow_pkts]
                        rx_pkts_per_client += rx_flow_pkts
                    if detailedCSVResIndex == 1:        #Write line 2 of detailedCSVResults
                        detailedCSVResults.append(("Client, %s (Tx)," % roamSourcePort) + \
                        detailedCSVresultsportlist[0] + "Total Rx," + "Lost Pkts" )
                        WE.WriteDetailedLog([detailedCSVResults[detailedCSVResIndex]])
                        detailedCSVResIndex +=1
                    lost_pkts_per_client = (tx_flow_roam_end -
                             rx_pkts_per_client)
                    if lost_pkts_per_client < 0:
                        lost_pkts_per_client = 0
                    #Secstart-Write lines after line 2 of detailedCSVResults
                    detailedCSVResults.append([name, tx_flow_roam_end] + \
                    detailedCSVresultstmplist + [rx_pkts_per_client, lost_pkts_per_client])
                    detailedCSVResults[detailedCSVResIndex] = tuple(detailedCSVResults[detailedCSVResIndex])
                    detailedCSVResults[detailedCSVResIndex] = ("%s,%s," + 
                                                               detailedCSVresultsportlist[1]+ "%d,%d")\
                                                               % detailedCSVResults[detailedCSVResIndex]
                    WE.WriteDetailedLog([detailedCSVResults[detailedCSVResIndex]])
                    detailedCSVResIndex +=1
                    #SecEnd
                    lost_pkts_per_client_per_roam = 0
                    if roamcountdict[name] > 0:
                        lost_pkts_per_client_per_roam = (lost_pkts_per_client /
                                                         roamcountdict[name])
                    invaliddelaycount = 0
                    delaylist = delaydict[name]
                    self.Print("")     #To make sure the GUI is responsive
                    #self.Print("Roaming delays for %s: " % name)
                    if pmk_cache_F == True:
                        delaylist = delaylist[2:]
                    else:
                        delaylist = delaylist[1:]
                    for delay in delaylist:
                        final_roam_delay_list.append(delay)
                    printVals = []
                    for val in delaylist:
                        if not isinstance(val, str):
                            printVals.append("%0.3f"%val)
                        else:
                            printVals.append("%s"%val)
                    #self.Print("%s\n" % str(printVals))
                    for k in range(len(delaylist)):
                        if delaylist[k] == 'Roam Failed':
                            invaliddelaycount += 1
                    validDelayList = [val for val in delaylist if \
                                      not isinstance(val, str)]
                    minm = 0.0; maxm = 0.0; avg = 0.0
                    if len(validDelayList) > 0:
                        minm = min(validDelayList)
                        maxm = max(validDelayList)
                        avg = reduce((lambda x, y: x + y),
                                validDelayList)/float(len(validDelayList))

                    """
                    Remove unncessary print statements to the console
                    
                        #self.Print("min - %.2f, max - %.2f, avg - %.2f," % (
                        #        minm, maxm, avg))
                        #self.Print(" invalid roams - %d\n" % (
                        #    invaliddelaycount))
                    else:
                        #self.Print("No valid roam delay reported\n")
                    """
                    LostData = (self.ClientgrpFlows[CGname].FrameSize * 
                                lost_pkts_per_client_per_roam * 8)/1000.0
                    #self.Print("Avg Lost Pkts - %0.02f," % 
                    #        lost_pkts_per_client_per_roam)
                    #self.Print(" LostData - %0.02f\n" % LostData)
                    

                    
                    #Collect the data required for the reports

                    #Collect client based statistics
                    #if self.totalRoams <= 2500000 :
                    if self.totalClients <= 25:
                        if  self.UserPassFailCriteria['user'] == "True": 
                               	TestResult={}
                                ach_fail_roam_per= float(invaliddelaycount)/roamcountdict[name]
                                if self.UserPassFailCriteria[CGname].has_key('ref_min_fail_roams'):
                                    ref_min_fail_roams=self.UserPassFailCriteria[CGname]['ref_min_fail_roams']
                                else:
                                    ref_min_fail_roams= 0

                                if self.UserPassFailCriteria[CGname].has_key('ref_max_delay'):
                                    ref_max_delay=self.UserPassFailCriteria[CGname]['ref_max_delay']
                                else:
                                    ref_max_delay = 5

                                if  float (ach_fail_roam_per) <= ref_min_fail_roams:
                                      TestResult['USC:RF']= 'PASS'
                                      #WaveEngine.OutputstreamHDL("Test has achieved the Pass/Fail criteria for Acceptable Roam Failures configured by the User:: User-%s,Achieved-%s\n" %(ref_min_fail_roams,ach_fail_roam_per),WaveEngine.MSG_SUCCESS)
                                else:
                                      TestResult['USC:RF']= 'FAIL'
                                      WaveEngine.OutputstreamHDL("Test has failed to  achieve the Pass/Fail criteria for  Acceptable Roam Failures configured by the User:: User-%s,Achieved-%s\n" %(ref_min_fail_roams,ach_fail_roam_per),WaveEngine.MSG_WARNING)
                                if float (maxm) <=float(ref_max_delay):
                                      TestResult['USC:RD']='PASS'
                                      #WaveEngine.OutputstreamHDL("Test has achieved the Pass/Fail criteria for Acceptable Roam Delay configured by the User:: User-%s,Achieved-%s\n" %(ref_max_delay,maxm),WaveEngine.MSG_SUCCESS)
                                else:
                                      TestResult['USC:RD']='FAIL'
                                      WaveEngine.OutputstreamHDL("Test has failed to  achieve the Pass/Fail criteria for Acceptable Roam Delay configured by the User:: User-%s,Achieved-%s\n" %(ref_max_delay,maxm),WaveEngine.MSG_WARNING)
                                self.ResultsSummaryPerClient[name]=dict([('SSID', ssidname),
                                                                              ('TotalRoams', roamcountdict[name]),
                                                                              ('FailedRoams', invaliddelaycount),
                                                                              ('MinDelay', minm),
                                                                              ('MaxDelay', maxm),
                                                                              ('AvgDelay', avg),
                                                                              ('PktLossPerRoam', lost_pkts_per_client_per_roam),
                                                                              ('USC:RF',TestResult['USC:RF']),
                                                                              ('USC:RD',TestResult['USC:RD'])
                                                                              ])

                                csvresult = "%s,%d,%.1f,%.1f,%.1f,%d,%.1f,%s,%s" % \
                                             (name, roamcountdict[name], minm, avg, maxm,
                                               lost_pkts_per_client_per_roam, invaliddelaycount, TestResult['USC:RF'], TestResult['USC:RD'])
                        else:
                            self.ResultsSummaryPerClient[name] = dict([('SSID', ssidname),
                                                                   ('TotalRoams', roamcountdict[name]),
                                                                   ('FailedRoams', invaliddelaycount),
                                                                   ('MinDelay', minm),
                                                                   ('MaxDelay', maxm),
                                                                   ('AvgDelay', avg),
                                                                   ('PktLossPerRoam', lost_pkts_per_client_per_roam)
                                                                   ])
                            csvresult = "%s,%d,%.1f,%.1f,%.1f,%d,%.1f" % \
                                        (name, roamcountdict[name], minm, avg, maxm,
                                        lost_pkts_per_client_per_roam, invaliddelaycount)
                        self.ResultsForCSVfile.append((csvresult,))
                    #Collect Client Group related statistics
                    else:
                        #When a client in a group doesn't have at least one valid roam
                        #we have minm with its initial value 0.0, only in this case we 
                        #have minm value as 0.0, because the min value in validDelayList
                        #would always be >= 4 (as only those values are valid roam delays
                        #So, when collecting groupMinDelay value ignore minm if it is 0.0
                        #otherwise we would see the entire groupMinDelay as 0.0, which
                        #is not correct, an equivalent of the below conditional is
                        #if groupMinDelay > minm and len(validDelayList) > 0, 
                        #avg = 0.0 is also similar
                        if groupMinDelay > minm and minm != 0:
                            groupMinDelay = minm
                        #When calculating group avg we ignore failed roams
                        groupAvgDelayProduct += \
                            ((roamcountdict[name] - invaliddelaycount) * avg)
                        if groupMaxDelay < maxm:
                            groupMaxDelay = maxm
                        groupPktLoss += lost_pkts_per_client
                        groupRoamCount += roamcountdict[name]
                        groupFailedRoams += invaliddelaycount
                        
            #process group specific data required for reports
            if self.totalClients > 25:
                numClients = len(clientNames)
                groupAvgDelay = 0 
                if (groupRoamCount - groupFailedRoams) > 0:
                    groupAvgDelay = groupAvgDelayProduct/(groupRoamCount - groupFailedRoams)
                pktLossPerRoam = 0
                if groupRoamCount > 0:
                    pktLossPerRoam = groupPktLoss/groupRoamCount
                if  self.UserPassFailCriteria['user'] == "True":
                                TestResult={}
                                ach_fail_roam_per= float(groupFailedRoams)/groupRoamCount
                                if  ach_fail_roam_per <= float (ref_min_fail_roams):
                                      TestResult['USC:RF']= 'PASS'
                                      WaveEngine.OutputstreamHDL("Test has achieved the Pass/Fail criteria for Acceptable Roam Failures configured by the User:: User-%s,Achieved-%s\n" %(ref_min_fail_roams,ach_fail_roam_per),WaveEngine.MSG_SUCCESS)
                                else:
                                      TestResult['USC:RF']= 'FAIL'
                                      WaveEngine.OutputstreamHDL("Test has failed to  achieve the Pass/Fail criteria for  Acceptable Roam Failures configured by the User:: User-%s,Achieved-%s\n" %(ref_min_fail_roams,ach_fail_roam_per),WaveEngine.MSG_WARNING) 
                                if groupMaxDelay <=float( ref_max_delay):
                                      TestResult['USC:RD']='PASS'
                                      WaveEngine.OutputstreamHDL("Test has achieved the Pass/Fail criteria for Acceptable Roam Delay configured by the User:: User-%s,Achieved-%s\n" %(ref_max_delay,groupMaxDelay),WaveEngine.MSG_SUCCESS)
                                else:
                                      TestResult['USC:RD']='FAIL'
                                      WaveEngine.OutputstreamHDL("Test has failed to  achieve the Pass/Fail criteria for Acceptable Roam Delay configured by the User:: User-%s,Achieved-%s\n" %(ref_max_delay,groupMaxDelay),WaveEngine.MSG_WARNING) 
                                self.ResultsSummaryPerCG[CGname] = dict([('SSID', ssidname),
                                                                       ('MinDelay', groupMinDelay),
                                                                       ('AvgDelay', groupAvgDelay),
                                                                       ('MaxDelay', groupMaxDelay),
                                                                       ('PktLossPerRoam', pktLossPerRoam),
                                                                       ('TotalRoams', groupRoamCount),
                                                                       ('FailedRoams', groupFailedRoams),
                                                                       ('USC:RF',TestResult['USC:RF']),
                                                                       ('USC:RD',TestResult['USC:RD'])
                                                                       ]) 
                                csvresult = "%s,%d,%.1f,%.1f,%.1f,%d,%d,%s,%s" % \
                                            (CGname, groupRoamCount, groupMinDelay, groupAvgDelay, groupMaxDelay,
                                             pktLossPerRoam, groupFailedRoams,TestResult['USC:RF'],TestResult['USC:RD'])   
                else:
                  self.ResultsSummaryPerCG[CGname] = dict([('SSID', ssidname),
                                                           ('MinDelay', groupMinDelay),
                                                           ('AvgDelay', groupAvgDelay),
                                                           ('MaxDelay', groupMaxDelay),
                                                           ('PktLossPerRoam', pktLossPerRoam),
                                                           ('TotalRoams', groupRoamCount),
                                                           ('FailedRoams', groupFailedRoams)
                                                           ])

                  csvresult = "%s,%d,%.1f,%.1f,%.1f,%d,%d" % \
                               (CGname, groupRoamCount, groupMinDelay, groupAvgDelay, groupMaxDelay,
                                pktLossPerRoam, groupFailedRoams)
                self.ResultsForCSVfile.append((csvresult,))
        self.ResultsForCSVfile.append(('End DataSet 1',))    
        
        #Compute ResultsSummaryPerSSID and ResultsSummaryPerTest
        
        #Initialise ResultsSummaryPerTest
        self.ResultsSummaryPerTest = {'MinDelay': 50001,    #50000 is the max possible roam delay
                                      'AvgDelay': 0,
                                      'MaxDelay': 0,
                                      'TotalRoams': 0,
                                      'FailedRoams': 0,
                                      'PktLossPerRoam': 0,
                                      'PktLossProduct': 0,
                                      'AvgDelayProduct': 0}
        for CGname in self.ResultsSummaryPerCG.keys():
            #Compute ResultsSummaryPerSSID
            ssid = self.ResultsSummaryPerCG[CGname]['SSID']
            if ssid in self.ResultsSummaryPerSSID.keys():
                if self.ResultsSummaryPerSSID[ssid]['MinDelay'] > \
                    self.ResultsSummaryPerCG[CGname]['MinDelay']:
                    self.ResultsSummaryPerSSID[ssid]['MinDelay'] = \
                        self.ResultsSummaryPerCG[CGname]['MinDelay']
                if self.ResultsSummaryPerSSID[ssid]['MaxDelay'] < \
                    self.ResultsSummaryPerCG[CGname]['MaxDelay']:
                    self.ResultsSummaryPerSSID[ssid]['MaxDelay'] = \
                        self.ResultsSummaryPerCG[CGname]['MaxDelay']
                self.ResultsSummaryPerSSID[ssid]['TotalRoams'] += \
                    self.ResultsSummaryPerCG[CGname]['TotalRoams']
                self.ResultsSummaryPerSSID[ssid]['FailedRoams'] += \
                    self.ResultsSummaryPerCG[CGname]['FailedRoams']
            else:
                self.ResultsSummaryPerSSID[ssid] = {}
                self.ResultsSummaryPerSSID[ssid] = copy.deepcopy(self.ResultsSummaryPerCG[CGname])
                self.ResultsSummaryPerSSID[ssid].__delitem__('SSID')
                self.ResultsSummaryPerSSID[ssid].__delitem__('PktLossPerRoam')
                self.ResultsSummaryPerSSID[ssid].__delitem__('AvgDelay')
                self.ResultsSummaryPerSSID[ssid]['AvgDelayProduct'] = 0
                self.ResultsSummaryPerSSID[ssid]['PktLossProduct'] = 0
            successfulRoams = (self.ResultsSummaryPerCG[CGname]['TotalRoams'] - \
                               self.ResultsSummaryPerCG[CGname]['FailedRoams'])
            self.ResultsSummaryPerSSID[ssid]['AvgDelayProduct'] += \
                    (self.ResultsSummaryPerCG[CGname]['AvgDelay'] * successfulRoams)
            self.ResultsSummaryPerSSID[ssid]['PktLossProduct'] += \
                self.ResultsSummaryPerCG[CGname]['PktLossPerRoam'] * \
                self.ResultsSummaryPerCG[CGname]['TotalRoams']
            
            #Compute ResultsSummaryPerTest
            if self.ResultsSummaryPerTest['MinDelay'] > \
                    self.ResultsSummaryPerCG[CGname]['MinDelay']:
                    self.ResultsSummaryPerTest['MinDelay'] = \
                        self.ResultsSummaryPerCG[CGname]['MinDelay']
            if self.ResultsSummaryPerTest['MaxDelay'] < \
                self.ResultsSummaryPerCG[CGname]['MaxDelay']:
                self.ResultsSummaryPerTest['MaxDelay'] = \
                    self.ResultsSummaryPerCG[CGname]['MaxDelay']
            self.ResultsSummaryPerTest['TotalRoams'] += \
                self.ResultsSummaryPerCG[CGname]['TotalRoams']
            self.ResultsSummaryPerTest['FailedRoams'] += \
                self.ResultsSummaryPerCG[CGname]['FailedRoams']
            
            self.ResultsSummaryPerTest['AvgDelayProduct'] += \
                    (self.ResultsSummaryPerCG[CGname]['AvgDelay'] * successfulRoams)
            self.ResultsSummaryPerTest['PktLossProduct'] += \
                (self.ResultsSummaryPerCG[CGname]['PktLossPerRoam'] * \
                self.ResultsSummaryPerCG[CGname]['TotalRoams'])
        
        #Compute 'AvgDelay', 'PktLossPerRoam'
        
        #ResultsSummaryPerSSID
        for ssid in self.ResultsSummaryPerSSID.keys():
            successfulRoams = (self.ResultsSummaryPerSSID[ssid]['TotalRoams'] - \
                               self.ResultsSummaryPerSSID[ssid]['FailedRoams'])
            self.ResultsSummaryPerSSID[ssid]['AvgDelay'] = 0
            self.ResultsSummaryPerSSID[ssid]['PktLossPerRoam'] = 0
            if successfulRoams > 0:
                self.ResultsSummaryPerSSID[ssid]['AvgDelay'] = \
                    (self.ResultsSummaryPerSSID[ssid]['AvgDelayProduct'] / 
                     successfulRoams)
            if self.ResultsSummaryPerSSID[ssid]['TotalRoams'] > 0:
                self.ResultsSummaryPerSSID[ssid]['PktLossPerRoam'] = \
                    (self.ResultsSummaryPerSSID[ssid]['PktLossProduct'] /
                    self.ResultsSummaryPerSSID[ssid]['TotalRoams'])
            
            self.ResultsSummaryPerSSID[ssid].__delitem__('AvgDelayProduct')
            self.ResultsSummaryPerSSID[ssid].__delitem__('PktLossProduct')
        
        
        #ResultsSummaryPerTest
        successfulRoams = (self.ResultsSummaryPerTest['TotalRoams'] - \
                           self.ResultsSummaryPerTest['FailedRoams'])   
        if successfulRoams > 0:
            self.ResultsSummaryPerTest['AvgDelay'] = \
                    (self.ResultsSummaryPerTest['AvgDelayProduct'] /successfulRoams)
        if self.ResultsSummaryPerTest['TotalRoams'] > 0:
            self.ResultsSummaryPerTest['PktLossPerRoam'] = \
                (self.ResultsSummaryPerTest['PktLossProduct'] /
                self.ResultsSummaryPerTest['TotalRoams'])
        
        self.ResultsSummaryPerTest.__delitem__('AvgDelayProduct')
        self.ResultsSummaryPerTest.__delitem__('PktLossProduct')
        
        
        #Write SSID based infor into CSV file 
        self.ResultsForCSVfile.append(("Start- SSID SummaryGraph Dataset",))
        for ssidname in self.ResultsSummaryPerSSID.keys():
            csvresult = "%s,%d,%.1f,%.1f,%.1f,%d,%d" % \
                        (str(ssidname), 
                         self.ResultsSummaryPerSSID[ssidname]['TotalRoams'],
                         self.ResultsSummaryPerSSID[ssidname]['MinDelay'],
                         self.ResultsSummaryPerSSID[ssidname]['AvgDelay'],
                         self.ResultsSummaryPerSSID[ssidname]['MaxDelay'], 
                         self.ResultsSummaryPerSSID[ssidname]['PktLossPerRoam'],
                         self.ResultsSummaryPerSSID[ssidname]['FailedRoams']  )
            self.ResultsForCSVfile.append((csvresult,))
        self.ResultsForCSVfile.append(("End- SSID SummaryGraph Dataset",))
        
        #DataSet 2 in Results CSV file (Results_roaming_benchmark.csv)
        #for RoamDelay distribution graph
        self.ResultsForCSVfile.append(('Start DataSet 2',))
        self.ResultsForCSVfile.append(('Roam Delay buckets interval','Bucket Count',))
        #tmp_list = final_roam_delay_list
        final_roam_delay_list = [val for val in final_roam_delay_list if \
                                 not isinstance(val, str)]
        if len(final_roam_delay_list) > 0:
            minm = min(final_roam_delay_list)
            maxm = max(final_roam_delay_list)
            variance = (maxm - 0.0)    #X-axis ranges from 0 to max
            graph_int = math.ceil(variance/50.0)
            if graph_int <= 0:
                graph_int = 1 #An extra check
            rangeofVals = []
            x_val = 0.0
            while x_val <= maxm + graph_int:
                rangeofVals.append(x_val)
                x_val += graph_int
            for i in range(len(rangeofVals[:-1])):
                bucket_count = 0
                for delay in final_roam_delay_list:
                    if delay >= rangeofVals[i] and delay < rangeofVals[i + 1]:
                        bucket_count += 1
                csvresult = "%.1f,%d" % (rangeofVals[i], bucket_count)
                self.ResultsForCSVfile.append((csvresult,))
        self.ResultsForCSVfile.append(('End DataSet 2',))

        #DataSet 3 in Results CSV file (Results_roaming_benchmark.csv)
        self.ResultsForCSVfile.append(('Start DataSet 3',))
        #final_roam_delay_list = tmp_list
        
        if self.totalRoams <= 2500000:
            if self.totalClients <= 25:
                self.ResultsForCSVfile.append(('Start Client Stats',))
                self.ResultsForCSVfile.append(('','Instance','Average Delay','Failed roams count',))
                for clientName in roamDelayTimesDict.keys():
                    roamDelayTime = roamDelayTimesDict[clientName]
                    self.ResultsForCSVfile.append(('%s'%clientName ,))
                    self.processDelayTimesDataSet(roamDelayTime)
                self.ResultsForCSVfile.append(('End Client Stats',))
            else:
                self.ResultsForCSVfile.append(('Start ClientGroup Stats',))
                self.ResultsForCSVfile.append(('','Instance','Average Delay','Failed roams count',))
                for cgName in roamDelayTimesDict.keys():
                    roamDelayTime = roamDelayTimesDict[cgName]
                    self.ResultsForCSVfile.append(('%s'%cgName ,))
                    self.processDelayTimesDataSet(roamDelayTime)
                self.ResultsForCSVfile.append(('End ClientGroup Stats',))
                if self.totalRoams > 10:
                    self.ResultsForCSVfile.append(('Start SSID Stats',))
                    for ssidName in roamDelayTimesSSID.keys():
                        roamDelayTime = roamDelayTimesSSID[ssidName]
                        self.ResultsForCSVfile.append(('%s'%ssidName ,))
                        self.processDelayTimesDataSet(roamDelayTime)
                    self.ResultsForCSVfile.append(('End SSID Stats',))
        else:
            #No graphs in this case, we only give summary table, ResultsSummaryPerTest
            pass
            
        self.ResultsForCSVfile.append(('End DataSet 3',))
    
    
    def processDelayTimesDataSet(self, roamDelayTime):
        """
        Process the delaytimes list of tuples [(x1, y1), (x2, y2)...] and give the 
        x, y co-ordintes' values for Roam Delay Vs Time, Failed Roam Vs Time graphs
        """
        self.testStartTime = 0.0
        if len(roamDelayTime) > 0:
            roamDelayTime.sort(self.sortOnTime)
            self.graphPlotInterval = (self.testEndTime - self.testStartTime)/20
            prev_val = self.testStartTime
            graph_int = self.graphPlotInterval
            if graph_int <= 0:
                graph_int = 1 #An extra check
            rangeofVals = []
            x_val = float(self.testStartTime)
            while x_val <= self.testEndTime + graph_int:
                rangeofVals.append(x_val)
                x_val += graph_int
            latestRoamDelay = 0
            latestFailedRoamCount = 0
            roamSuccessF = False
            for i in range(len(rangeofVals[:-1])):
                roam_count = 0
                lost_roam_count = 0
                roam_tot = 0
                noRoamEventF = True
                for j in range(len(roamDelayTime)):
                    if roamDelayTime[j][0] >= rangeofVals[i + 1]:
                        break
                    if (roamDelayTime[j][0] >= rangeofVals[i]
                            and roamDelayTime[j][0] < rangeofVals[i + 1]):
                        noRoamEventF = False    #Reaching this part of code means we have a roam Event
                        if (not isinstance(roamDelayTime[j][1], str)):
                            roamSuccessF = True
                            roam_count += 1
                            roam_tot += roamDelayTime[j][1]
                        else:
                            roamSuccessF = False
                            lost_roam_count += 1
                #The graph plotted is a trend analysis, withe the existing architecture for 
                #a line graph we have to have same x-values for all the entities represented
                #by a line (client, client group etc), so, we have to have a value for a client
                #at a point x where it actually didn't roam, since we try to plot a trend analysis
                #we chose a method where, whenever we don't have a roam event 
                #we pick the previous roam events value, when we have a roam event and the
                #roam event succeeds we pick the (avg) roam delay in that time interval and if
                #the roam fails we indicate that by value (ironically) '0' (not a large value)
                if noRoamEventF:
                    avg_delay = latestRoamDelay
                else:
                    if roamSuccessF:   
                        avg_delay = roam_tot/float(roam_count)
                        latestRoamDelay = avg_delay
                    elif not roamSuccessF:
                        avg_delay = 0
                        latestRoamDelay = 0
                if lost_roam_count > 0:
                    latestFailedRoamCount += lost_roam_count
                csvresult = "%s,%.1f,%.1f,%d" % ('',rangeofVals[i], avg_delay, latestFailedRoamCount)
                self.ResultsForCSVfile.append((csvresult,))
   
    
    def ProcessCSVfile(self):
        All_results = []
        chart1_x_vals = []
        chart1_y1_vals = []
        chart1_y2_vals = []
        chart1_y3_vals = []
        chart1A_x_vals = []
        chart1A_y1_vals = []
        chart1A_y2_vals = []
        chart1A_y3_vals = []
        chart1CategoryNames = []
        chart1ACategoryNames = []
        chart2_x_vals = []
        chart2_y_vals = []
        chart3_x_vals = []
        chart3_y_vals = []
        chart4_x_vals = []
        chart4_y_vals = []
        chart4A_x_vals = []
        chart4A_y_vals = []        
        chart4B_x_vals = []
        chart4B_y_vals = []
        chart5_x_vals = []
        chart5_y_vals = []
        chart5A_x_vals = []
        chart5A_y_vals = []

        FullPathFilename = os.path.join(self.LoggingDirectory, self.CSVfilename)
        try:
            f = open(FullPathFilename, 'r')
        except:
            f.close()
            self.Print("Can not open CSV file %s for reading\n" % (
                FullPathFilename), 'ERR')
            raise WE.RaiseException
        lines = f.readlines()
        for ii in range (0,len(lines)):
            lines[ii] = lines[ii].split("\n")[0]
        for ii in range (0,len(lines)):
            if lines[ii] == "Start DataSet 1":
                jj = 0
                ii = ii + 1
                while(lines[ii] != "End DataSet 1"):
                    jj = jj + 1
                    line = lines[ii].split(",")
                    chart1_x_vals.append(str(jj))
                    chart1CategoryNames.append( str(line[0]))
                    chart2_x_vals.append(str(jj))
                    chart1_y1_vals.append(float(line[2]))
                    chart1_y2_vals.append(float(line[3]))
                    chart1_y3_vals.append(float(line[4]))
                    chart2_y_vals.append(float(line[5]))
                    ii = ii + 1
            if lines[ii] == "Start- SSID SummaryGraph Dataset":
                jj = 0
                ii += 1
                while(lines[ii] != "End- SSID SummaryGraph Dataset"):
                    jj = jj + 1
                    line = lines[ii].split(",")
                    chart1A_x_vals.append(str(jj))
                    chart1ACategoryNames.append( str(line[0])) 
                    chart1A_y1_vals.append(float(line[2]))
                    chart1A_y2_vals.append(float(line[3]))
                    chart1A_y3_vals.append(float(line[4]))
                    ii = ii + 1
            if lines[ii] == "Start DataSet 2":
                ii = ii + 1
                while(lines[ii] != "End DataSet 2"):
                    line = lines[ii].split(",")
                    if line[0] == 'Roam Delay buckets interval':
                       pass
                    else: 
                       x_val = int(line[0].split(".")[0])
                       y_val = int(float(line[1]))
                    #Hack. For all the x_vals which are not 0, if the y_val
                    #is 0, remove the point, we don't want to plot those points in 
                    #the graph. For x_val = 0, leave it, it is required to make 0 the 
                    #starting point on x-axis
                       if (x_val == 0) or (y_val > 0 and x_val > 0):
                           chart3_x_vals.append(x_val)
                           chart3_y_vals.append(y_val)
                    ii = ii + 1    
            if lines[ii] == "Start DataSet 3":
                ii = ii + 1
                while(lines[ii] != "End DataSet 3"):
                    if lines[ii] == "Start Client Stats":
                        ii += 1
                        clientIndx = 0
                        while(lines[ii] != "End Client Stats"):
                            
                            line = lines[ii].split(",")
                            if len(line)==4 and line[1]==' Instance' : 
                                pass
                                ii=ii+1 
                            else:
                                  if len(line) == 1:        #It's Client Name
                                       ii += 1
                                       #while(lines[ii].split(",")[0] == '')
                                       chart4_y_vals.append([])
                                       chart5_y_vals.append([])
                                       clientIndx += 1
                                  else:
                                      #chart4_x_vals, chart5_x_vals are the values of 
                                      #time (which is on x-axis), these values are the same 
                                      #for all the clients. Enough to get values of one client
                                      if clientIndx == 1:
                                           timeVal = int(line[1].split(".")[0])
                                           chart4_x_vals.append(timeVal)
                                           chart5_x_vals.append(timeVal)
                                      chart4_y_vals[-1].append(float(line[2]))
                                      chart5_y_vals[-1].append(int(line[3]))
                                      ii = ii + 1
            
                    elif lines[ii] == "Start ClientGroup Stats":
                        ii += 1
                        clientGrpIndx = 0
                        while(lines[ii] != "End ClientGroup Stats"):
                            line = lines[ii].split(",")
                            if len(line)==4 and line[1]==' Instance':
                                ii=ii+1
                                pass
                            else:
                                 if len(line) == 1:        #It's Client Group Name
                                     ii += 1
                                     chart5_y_vals.append([])
                                     clientGrpIndx += 1
                                 else:
                                     #chart5_x_vals are the values of 
                                     #time (which is on x-axis), these values are the same 
                                     #for all the clients. Enough to get values of one client
                                     if clientGrpIndx == 1:
                                         chart5_x_vals.append(int(line[1].split(".")[0]))
                                     chart5_y_vals[-1].append(int(line[3]))
                                     ii += 1 
                        ii += 1
                        #Cumulative Failed Roams per CG Graph x, y axis values can be easily obtained from the
                        #dictionary self.ResultsSummaryPerCG, this code is here for logical
                        #placement   
                        for key in self.ResultsSummaryPerCG.keys():
                            chart4A_x_vals.append( key)
                            chart4A_y_vals.append(self.ResultsSummaryPerCG[key]['FailedRoams'])
                        if lines[ii] == "Start SSID Stats":
                            ii += 1
                            ssidIndx = 0
                            while(lines[ii] != "End SSID Stats"):
                                line = lines[ii].split(",")
                                if len(line) == 1:        #It's SSID Name
                                    ii += 1
                                    chart5A_y_vals.append([])
                                    ssidIndx += 1
                                else:
                                    #chart5_x_vals are the values of 
                                    #time (which is on x-axis), these values are the same 
                                    #for all the clients. Enough to get values of one client
                                    if ssidIndx == 1:
                                        chart5A_x_vals.append(int(line[1].split(".")[0]))
                                    chart5A_y_vals[-1].append(int(line[3]))
                                    ii += 1
                            #Cumulative Failed Roams Vs SSID Graph x, y axis values can be easily obtained from the
                            #dictionary self.ResultsSummaryPerCG, this code is here for logical
                            #placement   
                            for key in self.ResultsSummaryPerSSID.keys():
                                chart4B_x_vals.append( key)
                                chart4B_y_vals.append(self.ResultsSummaryPerSSID[key]['FailedRoams'])
                    ii += 1

        f.close()
        All_results.append(chart1_x_vals)
        All_results.append(chart1_y1_vals)
        All_results.append(chart1_y2_vals)
        All_results.append(chart1_y3_vals)
        All_results.append(chart1A_x_vals)
        All_results.append(chart1A_y1_vals)
        All_results.append(chart1A_y2_vals)
        All_results.append(chart1A_y3_vals)
        All_results.append(chart1CategoryNames)
        All_results.append(chart1ACategoryNames)
        All_results.append(chart2_x_vals)
        All_results.append(chart2_y_vals)
        All_results.append(chart3_x_vals)
        All_results.append(chart3_y_vals)
        All_results.append(chart4_x_vals)
        All_results.append(chart4_y_vals)
        All_results.append(chart4A_x_vals)
        All_results.append(chart4A_y_vals)        
        All_results.append(chart4B_x_vals)
        All_results.append(chart4B_y_vals)
        All_results.append(chart5_x_vals)
        All_results.append(chart5_y_vals)
        All_results.append(chart5A_x_vals)
        All_results.append(chart5A_y_vals)
        return All_results

    #PDF report and the GUI charts use a different format for
    #the CSV file while the Results section of GUI and the final
    #CSV file saved uses a different format. We juggle 
    #between these two formats. Watchout for bad linear dependencies 
    #in these code segments. self.run() -> SaveResults -> PrintReport
    #-> ConvertCSVtoGUIFormat -> MyReport.Print -> getCharts 
    #-> SaveResults.
    def ConvertCSVToGUIFormat(self):
        All_results = self.ProcessCSVfile()
        chart1_x_vals = All_results[0]
        chart1_y1_vals = All_results[1]
        chart1_y2_vals = All_results[2]
        chart1_y3_vals = All_results[3]
        chart2_x_vals = All_results[4]
        chart2_y_vals = All_results[5]
        chart3_x_vals = All_results[6]
        chart3_y_vals = All_results[7]
        chart4_x_vals = All_results[8]
        chart4_y_vals = All_results[9]
        chart5_x_vals = All_results[10]
        chart5_y_vals = All_results[11]
        #We don't want to overwrite the saved CSV file since that
        #is being used in getCharts() to generate the graphs
        self.ResultsForCSVfile = []
        for eachKey in self.DUTinfo.keys():
            self.ResultsForCSVfile.append( (eachKey, self.DUTinfo[eachKey]) )
        self.ResultsForCSVfile.append( (), )
        #To fix a weird quirk in GUI CSV handling 
        #which considers the length of the top row
        #as the max allowed length for all the rows(?)
        ListofXVals = []
        ListofXVals.append(chart1_x_vals)
        ListofXVals.append(chart3_x_vals)
        ListofXVals.append(chart4_x_vals)
        maxLenList = self.getMax(ListofXVals)
        CSVline = ('',)
        for item in maxLenList:
            CSVline += ('',)
        self.ResultsForCSVfile.append( CSVline )
        CSVline = ('CLIENT NUMBER',)
        for number in chart1_x_vals:
            CSVline += (number, )
        self.ResultsForCSVfile.append( CSVline )
        CSVline = ('Min Roam Delay',)
        for number in chart1_y1_vals:
            CSVline += (number, )
        self.ResultsForCSVfile.append( CSVline )
        CSVline = ('Max Roam Delay',)
        for number in chart1_y2_vals:
            CSVline += (number, )
        self.ResultsForCSVfile.append( CSVline )
        CSVline = ('Avg Roam Delay',)
        for number in chart1_y3_vals:
            CSVline += (number, )
        self.ResultsForCSVfile.append( CSVline )
        CSVline = ('Avg Lost pkts/client',)
        for number in chart2_y_vals:
            CSVline += (number, )
        self.ResultsForCSVfile.append( CSVline )
        CSVline = ('',)
        self.ResultsForCSVfile.append( CSVline )
        CSVline = ('TIME(secs)',)
        for time in chart4_x_vals:
            CSVline += (time, )
        self.ResultsForCSVfile.append( CSVline )
        CSVline = ('Roam Delay',)
        for delay in chart4_y_vals:
            CSVline += (delay, )
        self.ResultsForCSVfile.append( CSVline )
        CSVline = ('Failed Roams',)
        for failed_roams in chart5_y_vals:
            CSVline += (failed_roams, )
        self.ResultsForCSVfile.append( CSVline )
        CSVline = ('',)
        self.ResultsForCSVfile.append( CSVline )
        CSVline = ('ROAM DELAY(msecs)',)
        for time in chart3_x_vals:
            CSVline += (time, )
        self.ResultsForCSVfile.append( CSVline )
        CSVline = ('Number of Roams',)
        for roam in chart3_y_vals:
            CSVline += (roam, )
        self.ResultsForCSVfile.append( CSVline )

    def getCharts(self):
        """ Returns test-specific chart objects in a dictionary. """
        
        return self.testCharts
    
    def PrintReport(self):
        #Any cleaner way to do this? 
        All_results = self.ProcessCSVfile()
        Methodology = "After each roam operation, the test measures the time taken to roam and the number of data packets lost during the roam. Roam delay is measured starting at the point when the client transmits the first probe request to the new AP and ending when the first data packet is received from the new AP."                                                                                                                                 

        self.Print("Generating the Graphs. Please wait..\n")
        
        self.MyReport = WaveReport(os.path.join(self.LoggingDirectory, 
                                                self.ReportFilename))
        if self.MyReport.Story == None:
            return
        self.MyReport.Title("%s Report"% self.testName, self.DUTinfo, self.TestID)
        self.MyReport.InsertHeader("Overview")
        self.MyReport.InsertParagraph(self.getInfo())

        self._insertSummaryTables()
        if self.totalRoams <= 2500000:
            self._drawGraphs(All_results)        
                
        """            
        elif self.totalRoams > 2500000 and self.totalRoams <= 5000000:
            self.MyReport.InsertParagraph(summaryTableDescription%'Test')
            
            resSummary = [tuple(resSummaryBasic)]    #A list containing tuples
            resultTuple = ( self.ResultsSummaryPerTest['TotalRoams'], \
                            self.ResultsSummaryPerTest['FailedRoams'], \
                            self.ResultsSummaryPerTest['PktLossPerRoam'], \
                            self.ResultsSummaryPerTest['MinDelay'], \
                            self.ResultsSummaryPerTest['AvgDelay'], \
                            self.ResultsSummaryPerTest['MaxDelay'], \
                           )
            resSummary.append(resultTuple)
            self.MyReport.InsertDetailedTable(resSummary, columns=[1.0*inch, 1.0*inch, 1.0*inch, 1.0*inch, 1.0*inch, 1.0*inch])
        """

        self.MyReport.InsertParagraph("")

        self.MyReport.InsertHeader("Methodology")
        self.MyReport.InsertParagraph(Methodology)
        
        #self.MyReport.InsertHeader("Detailed Results")

        
        #Insert Test Config
        self._insertTestConfig()
        self.MyReport.Print()

    def _drawGraphs(self, All_results):
        chart1_x_vals = All_results[0]
        chart1_y1_vals = All_results[1]
        chart1_y2_vals = All_results[2]
        chart1_y3_vals = All_results[3]
        chart1A_x_vals = All_results[4]
        chart1A_y1_vals = All_results[5]
        chart1A_y2_vals = All_results[6]
        chart1A_y3_vals = All_results[7]
        chart1CategoryNames = All_results[8]
        chart1ACategoryNames = All_results[9]
        chart2_x_vals = All_results[10]
        chart2_y_vals = All_results[11]
        chart3_x_vals = All_results[12]
        chart3_y_vals = All_results[13]
        chart4_x_vals = All_results[14]
        chart4_y_vals = All_results[15]
        chart4A_x_vals = All_results[16]
        chart4A_y_vals = All_results[17]        
        chart4B_x_vals = All_results[18]
        chart4B_y_vals = All_results[19]        
        chart5_x_vals = All_results[20]
        chart5_y_vals = All_results[21]
        chart5A_x_vals = All_results[22]
        chart5A_y_vals = All_results[23]        
        tmp_y_val = []
        tmp_x_val = []
        
        ### text Paragraphs
        roamDelayOverview= "The VeriWave Roaming Delay test emulates the behavior of specified number of real clients moving about within a wireless network. All simulated clients roam independent of each other.  The roaming delays, packet loss, failed roams and the related trends with the SUT under this roaming setup is reported"
        
        roamBenchmarkOverview = "The Roaming Benchmark test determines the number of roams per unit of time that the WLAN controller can support. The test reports the roam delay, failed roams and packet loss for a particular roam rate for the specified configuration. The roaming pattern for a network (SSID) is predefined"
        
        roamDelayDistriText = "The Roaming Delay Distribution graph shows the distribution of roaming delays measured during the test. Ideally the distribution should be a single peak centered on the average roaming delay. Outliers towards larger numbers are indicative of anomalies and should be investigated."  
  
        minAvgMaxGraphText = "The following graph shows the minimum, maximum and average roaming delays for each %s in the test."
                  
        delayOverTimeGraphText = "The profile of roaming delay over time (i.e., a trend analysis) is shown in the next chart. Ideally, roaming delays should remain constant over time when using a uniform roam pattern. Variations in delay indicate periods of congestion that should be investigated. A failed roam is indicated by roaming Delay value zero"
                  
        cumulFailedRoamsOverTimeGraphText = "The following chart shows the profile of failed roams over time. The X-axis represents the time in seconds from the start of the test. The Y-axis is the number of roam attempts that failed."
                  
        pktLossPerClientGraphText = "The next graph shows the average number of packets lost each client over the whole duration of the test"

        #Roam delay distribution graph
        
        self._insertXYgraph(roamDelayDistriText,
                            chart3_x_vals, 
                            "Roam delay(msecs)",
                            [chart3_y_vals], 
                            "Number of Roams", 
                            "Roaming Delay Distribution", 
                            ['Bar'],
                            dataLblAngl = 0,
                            dataLblDgts = 0,
                            yAxsDgts = 0,
                            xAxsDgts = 2
                            )
            
        if self.totalClients <= 25: 
            #Summary graph: Min, Avg, Max roam delays' graphs
            minAvgMaxGrTitle = (self._getMinAvgMaxGrTitle())%"Clients"
            graphDescript = minAvgMaxGraphText%'Client'
            self._insertXYgraph(graphDescript,
                                chart1CategoryNames,
                                "", 
                                [chart1_y1_vals, chart1_y2_vals, chart1_y3_vals],
                                 "Roam Delay(msecs)",
                                 minAvgMaxGrTitle,
                                 ['Bar'], 
                                 [['Min'], ['Avg'],['Max']],
                                 False,
                                 dataLblAngl = 90,
                                 dataLblDgts = 2,
                                 yAxsDgts = 2,
                                 xValsDsplAngle = 80)
            
            #OverTime Graphs
            
            #We don't want to print this graph when we have more than 500 roams
            #as averaging out we do in each time bucket could very well be misleading
            if self.totalRoams <= 500:
                #RoamDelay Vs Time
                self._insertXYgraph(delayOverTimeGraphText,
                                    chart4_x_vals,
                                    "Time(secs)", 
                                    chart4_y_vals, 
                                    "Roam Delay(msecs)",
                                    "Roaming Delay Vs Time", 
                                    ['Line'],
                                    yAxsDgts = 2,
                                    dsplyDataLbls = False,
                                    xAxsDgts = 2
                                    )

            #Cumulative Failed Roams Vs Time    
            self._insertXYgraph(cumulFailedRoamsOverTimeGraphText,
                                chart5_x_vals, 
                                "Time(secs)",
                                chart5_y_vals, 
                                "Failed Roams",
                                "Failed Roams Vs Time", 
                                ['Line'],
                                yAxsDgts = 0,
                                dsplyDataLbls = False,
                                xAxsDgts = 2
                                )
        else:
            minAvgMaxGrTitle = (self._getMinAvgMaxGrTitle())%"Clients Groups"
            graphDescript = minAvgMaxGraphText%'Client Group'
            self._insertXYgraph(graphDescript,
                                chart1CategoryNames,
                                "",
                                [chart1_y1_vals, chart1_y2_vals, chart1_y3_vals],
                                "Roam Delay(msecs)", 
                                minAvgMaxGrTitle,
                                ['Bar'], 
                                [['Min'], ['Avg'],['Max']], 
                                False, 
                                dataLblAngl = 90,
                                dataLblDgts = 2,
                                yAxsDgts = 2,
                                xValsDsplAngle = 80
                                )

            #Failures per Client Group
            clientGroups = self.ResultsSummaryPerCG.keys()
            legends = [[x] for x in clientGroups]
            graphDescript = "The following graph shows the number of failed roams per Client Group."
            self._insertXYgraph(graphDescript,
                                chart4A_x_vals,
                                "Client Group Name",
                                [chart4A_y_vals],
                                "Failed Roams", 
                                "Failed Roams per Client Group",
                                ['Bar'],
                                legends,
                                False,
                                yAxsDgts = 0
                                )
            
            #Cumulative Failed Roams Vs Time
            self._insertXYgraph(cumulFailedRoamsOverTimeGraphText,
                                chart5_x_vals,
                                "Time(secs)", 
                                chart5_y_vals, 
                                "Cumulative Failed Roams", 
                                "Per Client Group Cumulative Failed Roams Vs Time", 
                                ['Line'], 
                                legends,
                                yAxsDgts = 0,
                                dsplyDataLbls = False,
                                xAxsDgts = 2
                                )
            if self.totalRoams > 10:
                #Summary Graph: Min, Avg, Max roam delays' graphs
                minAvgMaxGrTitle = (self._getMinAvgMaxGrTitle())%"Network/SSID"
                graphDescript = minAvgMaxGraphText%'Networks (SSIDs)'
                self._insertXYgraph(graphDescript,
                                    chart1ACategoryNames,
                                    "", 
                                    [chart1A_y1_vals, chart1A_y2_vals, chart1A_y3_vals], 
                                    "Roam Delay(msecs)", 
                                    minAvgMaxGrTitle, 
                                    ['Bar'], 
                                    [['Min'], ['Avg'],['Max']], 
                                    False,
                                    dataLblAngl = 90,
                                    dataLblDgts = 2,
                                    yAxsDgts = 2,
                                    xValsDsplAngle = 80)

                ssids = self.ResultsSummaryPerSSID.keys()
                legends = [[x] for x in ssids]
                
                #Failures per SSID
                graphDescript = "The following graph shows the number of failed roams per SSID."
                self._insertXYgraph(graphDescript,
                                    chart4B_x_vals,
                                    "Network/SSID", 
                                    [chart4B_y_vals],
                                    "Failed Roams", 
                                    "Failed Roams per Network/SSID", 
                                    ['Bar'], 
                                    legends, 
                                    False,
                                    yAxsDgts = 2
                                    )
                
                #Cumulative Failed Roams Vs Time.
                self._insertXYgraph(cumulFailedRoamsOverTimeGraphText,
                                    chart5A_x_vals,
                                    "Time(secs)", 
                                    chart5A_y_vals, 
                                    "Cumulative Failed Roams", 
                                    "Per SSID Cumulative Failed Roams Vs Time", 
                                    ['Line'], 
                                    legends,
                                    yAxsDgts = 2,
                                    xAxsDgts = 2
                                    )
               
    def _getMinAvgMaxGrTitle(self):
        """
        When all the roams failed, we want to place a note near the title of the graph
        explicitly stating that fact, to make sure the user doesn't get confused by 
        the graph with all y-axis data points at zero
        """
        title = "Min/Average/Max Roaming delays for %s"
        allRoamsFailedF = False
        if self.totalClients > 25:
            if (self.ResultsSummaryPerTest['TotalRoams'] == 
                self.ResultsSummaryPerTest['FailedRoams']):
                allRoamsFailedF = True
        else:
            #When self.totalClient <= 25, self.ResultsSummaryPerTest is not populated
            totalRoams = 0
            totalFailedRoams = 0
            for client in self.ResultsSummaryPerClient:
                totalRoams += self.ResultsSummaryPerClient[client]['TotalRoams']
                totalFailedRoams += self.ResultsSummaryPerClient[client]['FailedRoams']
            if totalFailedRoams == totalRoams:
                allRoamsFailedF = True
                
        if allRoamsFailedF:
            title = "Min/Average/Max Roaming delays for %s\n\n[NOTE: ALL THE ROAMS IN THE TEST HAVE FAILED]"
                
        return title
    
    def _insertXYgraph(self, graphDescription, x_vals, x_label, y_vals, y_label, 
                       title, graphTypeList, legends = [], splitGraphsF = False, 
                       dsplyDataLbls = True, dataLblAngl = 45, dataLblDgts = 0, 
                       yAxsDgts = 0, xAxsDgts = 0, xValsDsplAngle = 0, 
                       xValsCategoriesF = False):
        
        #Make sure x-values and y-values are not empty lists
        if len(x_vals) == 0:
            return
            if len(y_vals) == 0:
                return
                if isinstance(y_vals[0], list):
                    for val in y_vals:
                        if len(val) == 0:
                            return

        self.MyReport.InsertParagraph(graphDescription)
        graphObj = Qlib.GenericGraph(x_vals, x_label,
                                     y_vals, y_label, 
                                     title, 
                                     graphTypeList, 
                                     legends,
                                     splitGraphsF,
                                     displayDataLbls = dsplyDataLbls,
                                     dataLabelAngle = dataLblAngl,
                                     dataLblDigits = dataLblDgts,
                                     yAxisDigits = yAxsDgts,
                                     xAxisDigits = xAxsDgts,
                                     xValsDisplayAngle = xValsDsplAngle
                                     #xValsCategoriesF
                                     )
        
        self.MyReport.InsertObject(graphObj) 
        self.testCharts[title] = graphObj

                    
    def _insertTestConfig(self):
        self.MyReport.InsertPageBreak()
        configSummary = self.generateConfigSummary()
        self.MyReport.InsertHeader("Configuration")
        self.MyReport.InsertParagraph("The following table shows the parameters \
                                       set for the test.")

        self.insertTestConfigIntoReport(configSummary)

        #Insert AP information
        self.insertAPinfoTable(self.RSSIfilename)
                 
        #Had to put the following one line here since MyReport.Print()
        #in basetest sends a Test complete indication to GUI which 
        #populates the CSV table.
        
        #self.ConvertCSVToGUIFormat()
        self.MyReport.InsertHeader("Other Information")
        OtherParameters = []
        OtherParameters.append( ( 'Results Directory',  str( self.LoggingDirectory ) )  )
        for item in self.OtherInfoData.items():
            OtherParameters.append( item )
        OtherParameters.append( ( 'WaveTest Version',   str( action.getVclVersionStr() ) ) )
        self.MyReport.InsertGenericTable( OtherParameters , columns = [ 1.5*inch, 4.5*inch ] )
        
    def _insertSummaryTables(self):
        summaryTableDescription = "The summary results below show the number of roams, failed roams and the packet loss per roam per client group. It also shows the minimum, average, maximum roaming delay per each %s"
        if self.UserPassFailCriteria['user'] == 'True':
                resSummaryBasic = ['Total Roams', 'Failed Roams', 'PktLoss per Roam',
                           'Min Roam Delay (msecs)', 'Avg Roam Delay (msecs)',
                           'Max Roam Delay (msecs)','USC:RF','USC:RD']
        else: 
                resSummaryBasic = ['Total Roams', 'Failed Roams', 'PktLoss per Roam', 
                           'Min Roam Delay (msecs)', 'Avg Roam Delay (msecs)', 
                           'Max Roam Delay (msecs)']
        self.MyReport.InsertHeader("Results Summary")    
        self.MyReport.InsertParagraph("The following tables show the summary results.")
        
        if self.totalClients <= 25:
            self._insertClientSummaryTable(summaryTableDescription, resSummaryBasic)
        else: 
            self._insertGroupSummaryTable(summaryTableDescription, resSummaryBasic)
            if self.totalRoams > 10:
                self._insertSSIDsummaryTable(summaryTableDescription, resSummaryBasic)
        NoteText=""" Note: Abbreviations used: USC-User Spefied Criteria,RF:Roaming Failures, RD:Roaming Delay and OA:OverAll """ 
        self.MyReport.InsertParagraph(NoteText)
        CGnames = self.Clientgroup.keys()
        CGnames.sort()
        if self.UserPassFailCriteria['user'] == 'True':
             User_specified_tuple=[]
             User_specified_tuple.append(('Client_Group','Parameter','User Specified Value','Description'))
             for each_cg in CGnames:
                  User_specified_tuple.append((each_cg,'Acceptable Roam Failures',self.UserPassFailCriteria[each_cg]['ref_min_fail_roams'],'The maximum allowable percentage of roams'))
                  User_specified_tuple.append((each_cg,'Acceptable RoamDelay',self.UserPassFailCriteria[each_cg]['ref_max_delay'],'The Maximum Allowable Delay in ms'))
             self.MyReport.InsertHeader( "User Specified P/F criteria" )
             userspecifiedtext= """  With this feature user can decide the criteria for pass or fail of the test.User can configure the acceptable roam failures
                                and acceptable maximum roam delay based on which the test is evaluated to Pass/Fail"""
             self.MyReport.InsertParagraph (userspecifiedtext)
 
             self.MyReport.InsertDetailedTable(User_specified_tuple, columns=
                                          [2*inch, 1*inch, 1*inch,
                                           2*inch])


    def _insertSSIDsummaryTable(self, summaryTableDescription, resSummaryBasic):
        self.MyReport.InsertParagraph(summaryTableDescription%'Network/SSID')
        #Add all the SSIDs results in the first row
        if self.UserPassFailCriteria['user'] == 'True':
                resSummary = [ tuple( ['Network/ SSID'] + resSummaryBasic[:-2]+['USC:OA']) ]
                pass_dic={}
                pass_cnt=0
                ova_pass='' 
                iteration_cnt=-1
                if  self.totalClients <= 25:
                           for each in self.ResultsSummaryPerClient.values():
                               iteration_cnt=iteration_cnt+1
                               for each_lab in each.keys() :
                                   if each[each_lab] == 'PASS':
                                       pass_cnt=pass_cnt+1
                                   else:
                                        pass 
                               if pass_cnt==2:
                                    pass_dic[each['SSID']]='PASS'
                               else:
                                    pass_dic[each['SSID']]='FAIL'
                               pass_cnt=0
                else:
                           for each in self.ResultsSummaryPerCG.values():
                               iteration_cnt=iteration_cnt+1
                               for each_lab in each.keys() :
                                     if each[each_lab] == 'PASS':
                                          pass_cnt=pass_cnt+1
                                     else:
                                          pass
                               if pass_cnt==2:
                                    pass_dic[each['SSID']]='PASS'
                               else:
                                    pass_dic[each['SSID']]='FAIL'
                               pass_cnt=0
                try:
                    pass_dic.values().index('FAIL')
                    ova_pass='FAIL'
                except:
                    ova_pass='PASS'                  
                resultTuple = ("ALL SSIDs",
                       self.ResultsSummaryPerTest['TotalRoams'],
                       self.ResultsSummaryPerTest['FailedRoams'],
                       self.ResultsSummaryPerTest['PktLossPerRoam'],
                       self.ResultsSummaryPerTest['MinDelay'],
                       self.ResultsSummaryPerTest['AvgDelay'],
                       self.ResultsSummaryPerTest['MaxDelay'],
                       ova_pass
                       ) 
                resSummary.append(resultTuple)
                for ssidName in self.ResultsSummaryPerSSID.keys():
                    resultTuple = (ssidName, self.ResultsSummaryPerSSID[ssidName]['TotalRoams'],
                           self.ResultsSummaryPerSSID[ssidName]['FailedRoams'],
                           self.ResultsSummaryPerSSID[ssidName]['PktLossPerRoam'],
                           self.ResultsSummaryPerSSID[ssidName]['MinDelay'],
                           self.ResultsSummaryPerSSID[ssidName]['AvgDelay'],
                           self.ResultsSummaryPerSSID[ssidName]['MaxDelay'],
                           pass_dic[ssidName]
                           )
                resSummary.append(resultTuple)
                self.MyReport.InsertDetailedTable(resSummary, columns=
                                          [0.75*inch, 0.75*inch, 0.75*inch,
                                           0.75*inch, 0.75*inch, 0.75*inch,
                                           0.75*inch,0.75*inch])

        else:
             resSummary = [ tuple( ['Network/ SSID'] + resSummaryBasic) ]  
             resultTuple = ("ALL SSIDs", 
                       self.ResultsSummaryPerTest['TotalRoams'], 
                       self.ResultsSummaryPerTest['FailedRoams'], 
                       self.ResultsSummaryPerTest['PktLossPerRoam'], 
                       self.ResultsSummaryPerTest['MinDelay'], 
                       self.ResultsSummaryPerTest['AvgDelay'], 
                       self.ResultsSummaryPerTest['MaxDelay'] 
                       )
             resSummary.append(resultTuple)
             for ssidName in self.ResultsSummaryPerSSID.keys():
                 resultTuple = (ssidName, self.ResultsSummaryPerSSID[ssidName]['TotalRoams'], 
                           self.ResultsSummaryPerSSID[ssidName]['FailedRoams'],
                           self.ResultsSummaryPerSSID[ssidName]['PktLossPerRoam'], 
                           self.ResultsSummaryPerSSID[ssidName]['MinDelay'], 
                           self.ResultsSummaryPerSSID[ssidName]['AvgDelay'], 
                           self.ResultsSummaryPerSSID[ssidName]['MaxDelay'] 
                           )
             resSummary.append(resultTuple)
        
             self.MyReport.InsertDetailedTable(resSummary, columns=
                                          [0.75*inch, 0.75*inch, 0.75*inch, 
                                           0.75*inch, 0.75*inch, 0.75*inch, 
                                           0.75*inch])
    
    def _insertGroupSummaryTable(self, summaryTableDescription, resSummaryBasic):        
        resSummary = [ tuple(['Client Group', 'Network/ SSID'] + resSummaryBasic) ]    #A list containing tuples
        cgNames = self.ResultsSummaryPerCG.keys()
        cgNames.sort()
        if self.UserPassFailCriteria['user'] == 'True':
               for cgName in cgNames:   
                    #print "\nIn the insert Group summary table\n"
                    resultTuple = (cgName, self.ResultsSummaryPerCG[cgName]['SSID'],
                           self.ResultsSummaryPerCG[cgName]['TotalRoams'],
                           self.ResultsSummaryPerCG[cgName]['FailedRoams'],
                           self.ResultsSummaryPerCG[cgName]['PktLossPerRoam'],
                           self.ResultsSummaryPerCG[cgName]['MinDelay'],
                           self.ResultsSummaryPerCG[cgName]['AvgDelay'],
                           self.ResultsSummaryPerCG[cgName]['MaxDelay'],
                           self.ResultsSummaryPerCG[cgName]['USC:RF'],
                           self.ResultsSummaryPerCG[cgName]['USC:RD'],  
                           )
                    resSummary.append(resultTuple)  
               self.MyReport.InsertDetailedTable(resSummary, columns=[0.75*inch,
                                                               0.75*inch,
                                                               0.75*inch,
                                                               0.75*inch,
                                                               0.75*inch,
                                                               0.75*inch,
                                                               0.75*inch,
                                                               0.75*inch,
                                                               0.75*inch,
                                                               0.75*inch])
               for each_tu in resSummary: 
                     for each in each_tu:
                         if each == 'FAIL':
                              self.FinalResult=3 
                              break

        else: 
           for cgName in cgNames:
              resultTuple = (cgName, self.ResultsSummaryPerCG[cgName]['SSID'],
                              self.ResultsSummaryPerCG[cgName]['TotalRoams'], 
                              self.ResultsSummaryPerCG[cgName]['FailedRoams'], 
                              self.ResultsSummaryPerCG[cgName]['PktLossPerRoam'], 
                              self.ResultsSummaryPerCG[cgName]['MinDelay'], 
                              self.ResultsSummaryPerCG[cgName]['AvgDelay'], 
                              self.ResultsSummaryPerCG[cgName]['MaxDelay'], 
                           )
              resSummary.append(resultTuple)
           self.MyReport.InsertDetailedTable(resSummary, columns=[0.75*inch, 
                                                               0.75*inch, 
                                                               0.75*inch, 
                                                               0.75*inch, 
                                                               0.75*inch, 
                                                               0.75*inch, 
                                                               0.75*inch, 
                                                               0.75*inch])
        
    def _insertClientSummaryTable(self, summaryTableDescription, resSummaryBasic):
        resSummary = [ tuple( ['Client Name', 'Network/ SSID'] + resSummaryBasic) ]    #A list containing tuples
        clientNames = self.ResultsSummaryPerClient.keys()
        clientNames.sort()
        if self.UserPassFailCriteria['user'] == 'True':
               for clientName in clientNames:
                    resultTuple = (clientName,\
                           self.ResultsSummaryPerClient[clientName]['SSID'],\
                           self.ResultsSummaryPerClient[clientName]['TotalRoams'],\
                           self.ResultsSummaryPerClient[clientName]['FailedRoams'],\
                           self.ResultsSummaryPerClient[clientName]['PktLossPerRoam'],\
                           self.ResultsSummaryPerClient[clientName]['MinDelay'],\
                           self.ResultsSummaryPerClient[clientName]['AvgDelay'],\
                           self.ResultsSummaryPerClient[clientName]['MaxDelay'],\
                           self.ResultsSummaryPerClient[clientName]['USC:RF'],\
                           self.ResultsSummaryPerClient[clientName]['USC:RD'],\
                           )
                    resSummary.append(resultTuple)
               self.MyReport.InsertDetailedTable(resSummary, columns=[1.20*inch,
                                                               1.05*inch,
                                                               0.50*inch,
                                                               0.65*inch,
                                                               0.65*inch,
                                                               0.65*inch,
                                                               0.65*inch,
                                                               0.65*inch,
                                                               0.65*inch,
                                                               0.65*inch])
        else:
           for clientName in clientNames:
               resultTuple = (clientName, 
                           self.ResultsSummaryPerClient[clientName]['SSID'],
                           self.ResultsSummaryPerClient[clientName]['TotalRoams'], 
                           self.ResultsSummaryPerClient[clientName]['FailedRoams'], 
                           self.ResultsSummaryPerClient[clientName]['PktLossPerRoam'], 
                           self.ResultsSummaryPerClient[clientName]['MinDelay'], 
                           self.ResultsSummaryPerClient[clientName]['AvgDelay'], 
                           self.ResultsSummaryPerClient[clientName]['MaxDelay'], 
                           )
               resSummary.append(resultTuple)
           self.MyReport.InsertDetailedTable(resSummary, columns=[1.20*inch, 
                                                               1.05*inch, 
                                                               0.50*inch, 
                                                               0.65*inch, 
                                                               0.65*inch, 
                                                               0.65*inch, 
                                                               0.65*inch, 
                                                               0.65*inch])    
    
           for each_tu in resSummary:
                     for each in each_tu:
                         if each == 'FAIL':
                              self.FinalResult=3
                              break
  
    def computeTimeValueAndUnits(self, totalVal):
        if totalVal%3600 == 0:
            val = totalVal/3600
            units = 'hrs'
        elif totalVal%60 == 0:
            val = totalVal/60
            units = 'mins'
        else:
            val = totalVal
            units = 'secs'
        return (val, units)

    
    class Flow:
        def __init__(self, Type = 'IP', Framesize = 256, Phyrate = 54, 
                Ratemode = 'pps', Intendedrate = 100, 
                Numframes = WE.MAXtxFrames, SourcePort  = 8000, 
                DestinationPort  = 69, IcmpType = 0,  IcmpCode = 0):
            self.Type = Type
            self.FrameSize = Framesize
            self.PhyRate = Phyrate
            self.RateMode = Ratemode
            self.IntendedRate = Intendedrate
            self.NumFrames = Numframes
            if self.Type == 'UDP':
                self.srcPort = SourcePort
                self.destPort = DestinationPort
            elif self.Type == 'ICMP':
                self.type = IcmpType
                self.code = IcmpCode
        def SetFramesize(self, size):
            self.FrameSize = size
    
    def createFlowGroups(self):
        if len(self.FlowList) > 0:
            self._createFlowGroup(self.FlowList, "XmitGroup")
        else:
            self.Print("No main transmit flows created\n", 'ERR')
            return -1
        if len(self.LearnFlowList) > 0:
            self._createFlowGroup(self.LearnFlowList, "LearnXGroup")
            self._createFlowGroup({}, "LearnGroup")  
             
    def AddCardmaps(self, cardmap):
        for name in cardmap.keys():
            self.CardMap[name] = cardmap[name]
    
    def AttachRoamprofile(self, CGname, name):
        if name in self.Roamprofiles.keys():
            profile = self.Roamprofiles[name]
        else:
            self.Print("No matching Roam profile for profilenamed %s\n" % name,\
                    'ERR')
            return -1
        if CGname in self.Clientgroup.keys():
            CG = self.Clientgroup[CGname]
        else:
            self.Print("No matching group for clientgroup named %s\n" % CGname,\
                    'ERR')
            return -1
        CG.AttachRoamprofile(profile)
    
    def AttachPowerprofile(self, Rname, powerprofilename):
        if powerprofilename in self.Powerprofiles.keys():
            Pprofile = self.Powerprofiles[powerprofilename]
        else:
            self.Print("No matching Pwr profile for profile named %s\n" % \
                    powerprofilename, 'ERR')
            return -1
        if Rname in self.Roamprofiles.keys():
            Rprofile = self.Roamprofiles[Rname]
        else:
            self.Print("No matching Roam profile for profile named %s\n" % \
                    Rname, 'ERR')
            return -1
        Rprofile.SetPowerprofile(Pprofile)
    
    def CreatePowerprofile(self, name, rampdownlist = [], rampuplist = []):
        self.Powerprofiles[name] =  (rampdownlist, rampuplist)
            
    def getSecClass(self, secMethod):
        if secMethod in ['None', 'WEP-Open-40', 'WEP-Open-128']:
            secClass = 1
        elif secMethod in ['WEP-SharedKey-40', 'WEP-SharedKey-128']:
            secClass = 2
        elif secMethod in ['WPA-PSK', 'WPA2-PSK']:
            secClass = 3
        else:
            secClass = 4
        return secClass
    
    def getList(self, generator):
        retList = []
        while 1:
            for i in range(len(generator)):
                try:
                    p = generator[i].next()
                except StopIteration:
                    pass
                else:
                    retList.append(p)
            yield retList
            retList = []
    
    def getCGEvents(self):
        generator = self.CGGenclients()
        eventList = self.getList(generator)
        tmpList = []
        for listOfEvents in eventList:
            if len(listOfEvents) == 0:
                break
            tmpList += listOfEvents
        eventList = self.getList(tmpList)
        return eventList
    
    def splitGenerateClients(self):
        CGEvents = self.getCGEvents()
        for events in CGEvents:
            if len(events) == 0:
                break
            """
            for CGname in self.Clientgroup.keys():
                clientdict = self.Clientgroup[CGname].GetClientdict()
                print "------------ %s -----------" % CGname
                for clientname in clientdict.keys():
                    roamlist = clientdict[clientname].Getroameventlist()
                    print clientname, roamlist
            print "====================================================="
            """
            yield ''
        
    def generateClientConfig(self):
        for CGname in self.Clientgroup.keys():
            self.Clientgroup[CGname].generateClientConfig()
    
    def createAndConnectRoamClients(self, QoSdefaultF):
        portsToScan = self.getTestWLANportList()
        allClientsDict = {}
        for portName in portsToScan:
            if WE.GetCachePortInfo(portName) in WE.WiFiPortTypes:
                WE.VCLtest("port.scanBssid('%s')" % (portName))
                time.sleep(self.BSSIDscanTime)
        CGnames = self.Clientgroup.keys()
        CGnames.sort()
        for CGname in CGnames:
            if CGname in self.InvalidClientgrps:
                continue
            
            (ClientList, clientPreAuthPortList, 
                         clientPreAuthBSSIDList)    = self.getClientList(CGname,
                                                                         QoSdefaultF)
                
            createdClients = WE.CreateClients(ClientList,
                                              LoginList=self.Logins.get(CGname, None) )
            self.ClientgrpClients[CGname] = createdClients
            self.clientgroupObjs[CGname].addClients(createdClients)
            
            allClientsDict.update(self.ClientgrpClients[CGname])
            ListofClient = self.ClientgrpClients[CGname]
            if len(ListofClient) < 1:
                continue
            
            self._updateClientDelays(ListofClient)
            
            self.connectClients(ListofClient)
            
            self._doGenericUpdate(ListofClient)
            
            preAuthF = self.Clientgroup[CGname].GetFlags()['PreAuth']
            
            security = self.Clientgroup[CGname].Getsecurity()
            self._doMCpreauth(preAuthF, security, clientPreAuthPortList,
                              clientPreAuthBSSIDList,
                              ListofClient)
            
        return allClientsDict
    
    def getClientList(self, CGname, QoSdefaultF):

        ClientList = []
        clientdict = self.Clientgroup[CGname].GetClientdict()
        security = self.Clientgroup[CGname].Getsecurity()
        otherFlags = self.Clientgroup[CGname].GetFlags()
        clientOptions = self._getRoamClientOptions(CGname, QoSdefaultF, otherFlags)
        clientPreAuthPortList = {}
        clientPreAuthBSSIDList = {}
        CGdetails = self.getTestWLANPorts(CGname)

        portList = CGdetails[CGname][0]
        bssidList = CGdetails[CGname][1]
        portbssidList = []
        for i in range(len(portList)):
            portbssidList.append(odict.OrderedDict([(portList[i], 
                bssidList[i])]))
        clientnames = clientdict.keys()
        clientnames.sort()
        for clientname in clientnames:
            clientobj = clientdict[clientname]
            portList, BSSIDList = self._getPortBssidLists(clientobj, 
                                                          portbssidList)
            uniquePortList, uniqueBssidList = self._getUniquePortBssidLists(portList, 
                                                                            BSSIDList)
            clientPreAuthPortList[clientname] = portList[1:]
            clientPreAuthBSSIDList[clientname] = BSSIDList[1:]
            
            MAC = clientobj.GetMAC()
            IP = clientobj.GetIP()
            subnet = clientobj.GetSubnet()
            gateway = clientobj.GetGateway()
            
            incrTuple = self._getIncrTuple(MAC)

            #Mark the Clientgroup as Invalid since we did not find 
            #enough/good BSSIDs for it.
            if (None in BSSIDList or (len(portList) != len(BSSIDList)) or
                '00:00:00:00:00:00' in BSSIDList):
                self.Print("BSSIDs not found for %s\n" 
                        % clientname, 'ERR')
                if CGname not in self.InvalidClientgrps:
                    self.InvalidClientgrps.append(CGname)
                continue
            
            self.ClientPortBSSIDList[clientname] = [portList, BSSIDList]
            ClientList.append( (clientname, uniquePortList, uniqueBssidList,
                                MAC, IP, subnet, gateway, incrTuple, 
                                security, clientOptions) ) 
        return ClientList, clientPreAuthPortList, clientPreAuthBSSIDList
    
    def _getPortBssidLists(self, clientobj, portbssidList):

        uniqueBSSIDPort = []
        uniqueBSSIDPort.append(odict.OrderedDict([(clientobj.firstPort,
            clientobj.firstBSSID)]))
        for portBSSID in portbssidList:
            port = portBSSID.keys()[0] #only one entry
            bssid = portBSSID[port]
            bssidDict = odict.OrderedDict([( port, bssid)])
            if bssidDict not in uniqueBSSIDPort:
                uniqueBSSIDPort.append(bssidDict)
        BSSIDList = []
        portList = []
        for portBSSID in uniqueBSSIDPort:
            port = portBSSID.keys()[0]
            portList.append(port)
            BSSIDList.append(portBSSID[port])
            
        return portList, BSSIDList
    
    def  _getUniquePortBssidLists(self, portList, BSSIDList):
        uniquePortList = []    #Remove any duplicate entries in portList, VPR 4389
        uniqueBssidList = []
        i = 0
        for port in portList:
            if port not in uniquePortList:            #Pick only the first instance, ignore other instances of the same port
                uniquePortList.append(port)           #and thus...  
                uniqueBssidList.append(BSSIDList[i]) #this picks only the first bssid attached to the port
            i +=1
        
        return uniquePortList, uniqueBssidList
    
    def _getIncrTuple(self, MAC):

        incrTuple = (1,)
        if MAC == 'DEFAULT':
            incrTuple += ('DEFAULT',)
        elif MAC == 'AUTO':
            incrTuple += ('AUTO',)
        else:
            incrTuple += ('00:00:00:00:00:00',)
        incrTuple += ('0.0.0.0',)

        
        return incrTuple
    
    def _updateClientDelays(self, ListofClient):
        for clientName in ListofClient.keys():
            if ListofClient[clientName][2] == 'mc':
                WE.VCLtest("mc.read('%s')" % (clientName))
                WE.VCLtest("mc.updateClientDelays('%s', %d)"% (clientName,
                                                                       0))
    
    def _doGenericUpdate(self, ListofClient):
        # update connection information to inactive client instances
        for clientName in ListofClient.keys():
            if ListofClient[clientName][2] == 'mc':
                WE.VCLtest("mc.read('%s')" % (clientName))
                WE.VCLtest("mc.update('%s')" % (clientName))
    
    def _doMCpreauth(self, preAuthF, security, clientPreAuthPortList,
                     clientPreAuthBSSIDList, ListofClient):
        
        securityMethod = 'NONE'
        if 'Method' in security.keys():
            securityMethod = security['Method']
        doPreAuthF = False
        if 'WPA2' in securityMethod:
            if 'PSK' not in securityMethod:
                doPreAuthF = True
        if preAuthF and doPreAuthF:
            for clientName in ListofClient.keys():
                if ListofClient[clientName][2] == 'mc':
                    if ((clientName in clientPreAuthPortList) and 
                            (clientName in clientPreAuthBSSIDList)):
                        portList = clientPreAuthPortList[clientName]
                        BSSIDList = clientPreAuthBSSIDList[clientName]
                        if (len(portList) > 0 and len(BSSIDList) > 0):
                            if len(portList) == len(BSSIDList):
                                returnCode = 0
                                k = 0
                                startTime = time.time()
                                currBssid = ''
                                while k < (len(portList)):
                                    #returnCode will be -313 when the supplicant is
                                    #busy with an already sent PreAuth request, so
                                    #the last preauth request was not entertained,
                                    #wait for a while (we chose 40ms), and retry the 
                                    #previous request
                                    returnCode = WE.MCsetPreAuth(clientName, 
                                                                         portList[k],
                                                                         BSSIDList[k])
                                    k += 1                                    
                                    
                                    if returnCode == -313:
                                        if 5 > time.time() - startTime:
                                            self.Print('Previous PreAuth request was not entertained by the SUT as the SUT was busy. Retrying the request...\n', 'OK')
                                            k -= 1
                                            time.sleep(0.2)
                                        else:
                                            self.Print("Client %s - PreAuth request for BSSID %s failed\n" % (clientName, currBssid), 'ERR')
                                            return
                                    elif returnCode == 0:
                                        currBssid = BSSIDList[k-1]
                                        


    def _getRoamClientOptions(self, CGname, QoSdefaultF, otherFlags):
        clientOptions = odict.OrderedDict()
        flags = otherFlags.keys()
        
        persistReauthF = otherFlags.get('PersistentReauth', False)
        clientOptions['PersistentReauth'] = 'off'
        if persistReauthF:
            clientOptions['PersistentReauth'] = 'on'
            
        if 'Reassoc_when_roam' in flags:
            if otherFlags['Reassoc_when_roam'] == True:
                clientOptions['UseReassociation'] = 'on'
                
        if 'renewDHCP' in flags:
            if otherFlags['renewDHCP'] == 1:
                clientOptions['LeaseDhcpOnRoam'] = 'on'
                
        if 'renewDHCPonConn' in flags:
            if otherFlags['renewDHCPonConn'] == 1:
                clientOptions['LeaseDhcpReconnection'] = 'on'
                
        if CGname in self.Clientgroups.keys():
            if 'MgmtPhyRate' in self.Clientgroups[CGname].keys():
                clientOptions['PhyRate'] = \
                        self.Clientgroups[CGname]['MgmtPhyRate']
            if 'TxPower' in self.Clientgroups[CGname].keys():
                clientOptions['TxPower'] = self.Clientgroups[CGname]['TxPower']
            
            if 'CtsToSelf' in self.Clientgroups[CGname].keys():
                clientOptions['CtsToSelf'] = self.Clientgroups[CGname]['CtsToSelf'] 
                
            if 'BOnlyMode' in self.Clientgroups[CGname].keys():
                clientOptions['BOnlyMode'] = self.Clientgroups[CGname]['BOnlyMode']
                
            if 'AssocProbe' in self.Clientgroups[CGname].keys():
                probeVal = str(self.Clientgroups[CGname]['AssocProbe'])
                if probeVal == 'Broadcast':
                    clientOptions['ProbeBeforeAssoc'] = "bdcast"
                elif probeVal == 'None':
                    clientOptions['ProbeBeforeAssoc'] = "off"
                else:
                    clientOptions['ProbeBeforeAssoc'] = "unicast"
            
            learnOption = "off"                                      
            if 'ClientLearning' in self.Clientgroups[CGname].keys():
                learnOption = self.Clientgroups[CGname]['ClientLearning']
                if learnOption == "on":
                    clientOptions['ClientLearning'] = "on"
            if learnOption == "on":
                """
                we don't have these two options now, thus comment out
                
                if 'LearningIpAddress' in self.Clientgroups[CGname].keys():
                    clientOptions['LearningIpAddress'] = \
                            self.Clientgroups[CGname]['LearningIpAddress']
                if 'LearningMacAddress' in self.Clientgroups[CGname].keys():
                    clientOptions['LearningMacAddress'] = \
                            self.Clientgroups[CGname]['LearningMacAddress']
                """
                if 'LearningRate' in self.Clientgroups[CGname].keys():
                    clientOptions['LearningRate'] = \
                            self.Clientgroups[CGname]['LearningRate']
                            
            wmeFlag = self.Clientgroups[CGname].get('QoSenabledF', QoSdefaultF)
            if wmeFlag:
                clientOptions['WmeEnabled'] = 'on'     
                           
            if 'GratuitousArp' in self.Clientgroups[CGname].keys():
                if self.Clientgroups[CGname]['GratuitousArp'] == 'True':
                    clientOptions['GratuitousArp'] = "on"
            if 'ProactiveKeyCaching' in self.Clientgroups[CGname].keys():
                if self.Clientgroups[CGname]['ProactiveKeyCaching'] == 'True':
                    clientOptions['ProactiveKeyCaching'] = "on"
                else:
                    clientOptions['ProactiveKeyCaching'] = "off"
            
            interfaceOptions = self.clientgroupObjs[CGname].interfaceOptions
            clientOptions.update(interfaceOptions)
            
        return clientOptions
                    
    def setCardLists(self):
        """
        Overriding the method in basetest. 
        FIXME: This should not be needed. Method in Basetest can do the job
        if getClientTuples() is implemented in this script. Since we haven't yet
        implemented it, we are taking this route.
        """
        ethPorts = self.getTestEthPortList()
        wlanPorts = self.getTestWLANportList()

        self.CardList = ethPorts + wlanPorts
        
    def getTestWLANportList(self):
        wlanPortList = []
        CGdetails = self.getTestWLANPorts()
        for CGname in CGdetails.keys():
            if CGname in self.InvalidClientgrps:
                continue
            if len(CGdetails[CGname]) < 2:
                continue
            portList = CGdetails[CGname][0]
            for port in portList:
                if port not in wlanPortList:
                    wlanPortList.append(port)
        return wlanPortList
    
    def getTestWLANPorts(self, CGname = ''):
        CGportBSSID = {}
        if CGname == '':
            listofCGs = self.Clientgroups.keys()
        else:
            listofCGs = [CGname]
        for CGname in listofCGs:
            CGportBSSID[CGname] = []
            CGdetails = self.Clientgroups[CGname]
            if 'Enable' not in CGdetails.keys():
                continue
            if CGdetails['Enable'] != True:
                continue
            if 'Roamprof' not in CGdetails.keys():
                continue
            roamProf = CGdetails['Roamprof']
            if roamProf not in self.Roamlist.keys():
                continue
            roamProfDetails = self.Roamlist[roamProf]
            if 'PortList' not in roamProfDetails.keys():
                continue
            CGportBSSID[CGname].append(roamProfDetails['PortList'][:])
            if 'BSSIDList' not in roamProfDetails.keys():
                continue
            CGportBSSID[CGname].append(roamProfDetails['BSSIDList'][:])
        return CGportBSSID
    
    def getTestCGsecurity(self, CGname, field):
        if CGname not in self.Clientgroups.keys():
            return None
        CGdetails = self.Clientgroups[CGname]
        if 'Security' not in CGdetails.keys():
            return None
        secName = CGdetails['Security']
        if secName not in self.NetworkList:
            return None
        secDetails = self.NetworkList[secName]
        if field not in secDetails.keys():
            return None
        return secDetails[field]
    
    def updateFlows(self, flowDict):
        for flowName in flowDict.keys():
            WE.VCLtest("flow.read('%s')" % (flowName))
            WE.VCLtest("flow.write('%s')" % (flowName))
    
    def Schedule(self, eventlist, FuncRealTime):
        Scheduler = self.makeScheduler(eventlist, FuncRealTime, time.time())
        self.startFlows()
        detailedStr = ["Roam Time, Client Group, Client Name, Dst Port, Dst BSSID, \
                        Total Roam Delay, Client Delay, AP Roam Delay, \
                        Probe Request Timestamp, Probe Response Timestap, \
                        AP Probe Response Delay, 802.11 Auth Request Timestamp, \
                        802.11 Auth Response Timestamp, AP 802.11 Auth Delay, \
                        WEP Auth Request Timestamp, WEP Auth Response Timestamp, \
                        AP WEP Auth Delay, Assoc Request Timestamp, Assoc Response Timestamp,\
                        AP Assoc Delay, EAP ReqIdentity Timestamp, EAPOL Group Key Timestamp,\
                        Auth Time"]
        WE.WriteDetailedLog(detailedStr)
        if Scheduler != None:
            Scheduler.run()
    
    def Printinfo(self):
        self.Print("\n", 'DBG')
        CGnames = self.Clientgroup.keys()
        CGnames.sort()
        for CGname in CGnames:
            if CGname in self.InvalidClientgrps:
                continue
            dict1 = self.Clientgroup[CGname].GetClientdict()
            names = dict1.keys()
            names.sort()
            self.Print("Client group %s\n" % CGname, 'DBG')
            for name in names:
                self.Print(dict1[name].GetClientdetails(), 'DBG')
                self.Print("\n", 'DBG')
            self.Print("\n", 'DBG')
            
    def sortOnTime(self, x, y):
        time1 = x[0]
        time2 = y[0]
        if time1 > time2: return 1
        if time1 == time2: return 0
        if time1 < time2: return -1        
            
    def get_power_event_time(self, profile, event_type):
        tot_time = 0.0
        startpower = profile[0]
        endpower = profile[1]
        powerstep = profile[2]
        if event_type == 'down':
            powerstep = -powerstep
        timeinterval = profile[3]/1000.0
        for i in range(startpower, endpower + powerstep, powerstep):
            if (event_type == 'down'):
                if i < endpower:
                    continue
            if (event_type == 'up'):
                if i >  endpower:
                    continue
            tot_time += timeinterval
        return tot_time
    
    def GetTotPowerprofTime(self, profile):
        total_time = 0.0
        ramp_down_profile = profile[0]
        ramp_up_profile = profile[1]
        ramp_down_time = self.get_power_event_time(ramp_down_profile, 'down')
        ramp_up_time = self.get_power_event_time(ramp_up_profile, 'up')
        total_time = ramp_down_time + ramp_up_time
        return total_time        
            
    def validateInitialConfig(self):
        IPaddrList = []
        MACaddrList = []
        CGnames = self.Clientgroup.keys()
        CGnames.sort()
        for CGname in CGnames:
            if CGname in self.InvalidClientgrps:
                continue
            clientdict = self.Clientgroup[CGname].GetClientdict()
            clientnames = clientdict.keys()
            clientnames.sort()
            for name in clientnames:
                MACaddr = clientdict[name].GetMAC()
                if (MACaddr != 'DEFAULT') and (MACaddr in MACaddrList) \
                        and (MACaddr != 'AUTO'):
                    self.Print("Duplicate MAC addr %s in %s. Invalid\n" %
                            (MACaddr, CGname), 'ERR')
                    if CGname not in self.InvalidClientgrps:
                        self.InvalidClientgrps.append(CGname)
                else:
                    MACaddrList.append(MACaddr)
                IPaddr  = clientdict[name].GetIP()
                if IPaddr == '0.0.0.0':
                    continue
                if IPaddr in IPaddrList:
                    #Duplicate IP address, Mark the entire group Invalid.
                    #Should we get "smarter" and mark each client Invalid?
                    self.Print("Duplicate IP addr %s in %s. Invalid\n" %
                            (IPaddr, CGname), 'ERR')
                    if CGname not in self.InvalidClientgrps:
                        self.InvalidClientgrps.append(CGname)
                else:
                    IPaddrList.append(IPaddr)
    
    def setStartData(self):
        CGnames = self.Clientgroup.keys()
        CGnames.sort()
        for CGname in CGnames:
            if CGname in self.InvalidClientgrps:
                continue
            clientdict = self.Clientgroup[CGname].GetClientdict()
            clientnames = clientdict.keys()
            clientnames.sort()
            for name in clientnames:
                clientdict[name].startTime = clientdict[name].prevDwellTime
                clientdict[name].prevDwellTime = clientdict[name].totDwellTime
                clientdict[name].currRoam = clientdict[name].prevRoam
                roamlist = clientdict[name].Getroameventlist()
                if len(roamlist) > 0:
                    clientdict[name].prevRoam = roamlist[len(roamlist) - 1]
    
    def validateRoamConfig(self):
        CGnames = self.Clientgroup.keys()
        CGnames.sort()
        for CGname in CGnames:
            if CGname in self.InvalidClientgrps:
                continue
            clientdict = self.Clientgroup[CGname].GetClientdict()
            clientnames = clientdict.keys()
            clientnames.sort()
            for name in clientnames:
                Roamlist = clientdict[name].Getroameventlist()
                #Invalid if the total time for power ramp up + down
                #is greater than any dwell time.
                Powerprofile = clientdict[name].Getpowerprof()
                if len(Powerprofile) < 2:
                    #No power profile configured for this client?
                    continue
                Tot_powerprofile_time = self.GetTotPowerprofTime(Powerprofile)
                for i in range(len(Roamlist)):
                    (port, bssid, dwell_time) = Roamlist[i]
                    if Tot_powerprofile_time > dwell_time:
                        print("Power profile time %0.3f > dwell_time %0.3f for %s\n" % (Tot_powerprofile_time, dwell_time, CGname))
                        if CGname not in self.InvalidClientgrps:
                            self.InvalidClientgrps.append(CGname)
                        break
    
    def getSchedObj(self, FuncRealTime, start_time):
        #self.Printinfo()
        R = self.getEventGenerator()
        for CGname in self.Clientgroup.keys():
            if CGname in self.InvalidClientgrps:
                continue
            clientdict = self.Clientgroup[CGname].GetClientdict()
            R.AddClientGroup(clientdict)
        eventlist = R.MakeEventlist()
        Scheduler = self.makeScheduler(eventlist, FuncRealTime, start_time)
        return Scheduler

    def startTest(self, FuncRealTime):
        self.Print("\nGenerating Events. Please wait..\n")
        self.Printinfo()
        R = self.getEventGenerator()
        for CGname in self.Clientgroup.keys():
            if CGname in self.InvalidClientgrps:
                continue
            clientdict = self.Clientgroup[CGname].GetClientdict()
            R.AddClientGroup(clientdict)
        eventlist = R.MakeEventlist()
    
        self.Schedule(eventlist, FuncRealTime)
        
    class RunThread(Thread):
        def __init__(self, splitEventGen, start_time, testClass):
            Thread.__init__(self)
            self.start_time = start_time
            self.TestClass = testClass
            self.splitEventGen = splitEventGen
        def run(self):
            for eventList in self.splitEventGen:
                self.TestClass.validateRoamConfig()
                self.TestClass.setStartData()
                schedObj = self.TestClass.getSchedObj(
                        self.TestClass.RealtimeCallback, self.start_time)
                while self.TestClass.schedQ.qsize() >= 3:
                    time.sleep(0.25)
                self.TestClass.schedQ.put(schedObj)
    
    def startSplitTest(self):
        runThread = None
        schedObj = None
        detailedStr = self.getDetailedLogColumnNames()
        WE.WriteDetailedLog([detailedStr])
        
        start_time = time.time()
        splitEventGen = self.splitGenerateClients()
        runThread = self.RunThread(splitEventGen, start_time, self)
        self.setTestSheduledEndTime(start_time + self.totalduration)
        runThread.setDaemon(True)
        runThread.start()
        #wait until we have a batch of events to start with
        while self.schedQ.empty() == True and len(self.InvalidClientgrps) == 0:
            time.sleep(0.25)
            pass
    
        #bail out even if we have one invalid client group
        if len(self.InvalidClientgrps) != 0:
            self.Print("Invalid Config.",'ERR')
            raise WE.RaiseException

        #TODO - There could be situations where the first event starts
        #later than the maxSplitTime. This could cause a None schedObj
        #to be put in the Queue and we would never run any of the following
        #schedObjs put in the Queue.
        try:
            while self.schedQ.empty() != True:
                runSchedObj = self.schedQ.get()
                if runSchedObj != None:
                    runSchedObj.run()
        except WE.RaiseScheduleException:
            self.Print("Stopping the test as we reached end of test duration. Ignoring the remaining roam events.\n",'ERR')

        runThread.join()
        stop_time = time.time() 
        self.SetTotalDuration(stop_time - start_time)
        
    def setTestSheduledEndTime(self, schedEndtime):
        self.scheduledEndTime = schedEndtime
            
    def clearEvents(self):
        if time.time() > self.scheduledEndTime:
            raise WE.RaiseScheduleException
        
    def checkRoamOppurtunities(self):
        """
        
        Must be implemented in the super class if needed
        """
        pass
    
    def getDetailedLogColumnNames(self):
        """
        
        Must be implemented in the super class if needed
        """
        pass
    
    def doAllArpExchanges(self):
        if len(self.LearnFlowList) > 0:
            self.doArpExchanges(self.LearnFlowList, 
                                "LearnXGroup", 
                                self.ARPRate, self.ARPRetries, self.ARPTimeout)
            self.updateFlows(self.LearnFlowList)
        if len(self.FlowList) > 0:
            self.doArpExchanges(self.FlowList, "XmitGroup", 
                                 self.ARPRate, self.ARPRetries, self.ARPTimeout)

            self.updateFlows(self.FlowList)
            
    def VerifyBSSID_MAC(self, clients):
        # set random seed for psuedo-random MAC addresses that are repeatable.
        if not WE.GroupVerifyBSSID_MAC([clients], self.BSSIDscanTime):
            self.SavePCAPfile = True
            raise WE.RaiseException

    def ConfigureData(self):

        self.createClientGroups()
    
        self.createRoamProfiles()
    
        self.createPowerProfiles()
    
        self.connectRoamAndPowerProfiles()
        
        self.connectRoamProfAndClientGroup()
            
    def createClientGroups(self):
        """
        Create client groups
        """ 
        groupnames = self.Clientgroups.keys()
        groupnames.sort()
        self.totRoamClients = 0    #The total number of roaming Clients, used in categorizing the report
        for name in groupnames:
            Keys = self.Clientgroups[name].keys()
            if 'Enable' in Keys:
                enableF = self.Clientgroups[name]['Enable']
                if enableF != True and enableF != False:
                    self.Print("Unknown Enable value, defaulting to False\n", 
                            'ERR')
                    del self.Clientgroups[name]
                    continue
                if enableF == False:
                    del self.Clientgroups[name]
                    continue
            if 'StartMAC' not in Keys:
                self.Print("Start MAC not defined for %s\n" % name, 'ERR')
                continue
            startMAC = self.Clientgroups[name]['StartMAC']
            if 'MACIncr' not in Keys:
                macIncr = 1
            else:
                macIncr = self.Clientgroups[name]['MACIncr']
            if 'StartIP' not in Keys:
                self.Print("Start IP not defined for %s\n" % name, 'ERR')
                continue
            startIP = self.Clientgroups[name]['StartIP']
            if 'IncrIp' not in Keys:
                ipIncr = '0.0.0.1'
            else:
                ipIncr = self.Clientgroups[name]['IncrIp']
            if 'Gateway' not in Keys:
                self.Print("Gateway not defined for %s\n" % name, 'ERR')
                continue
            gateway = self.Clientgroups[name]['Gateway']
            if 'SubMask' not in Keys:
                self.Print("SubMask not defined for %s\n" % name, 'ERR')
                continue
            subnet  = self.Clientgroups[name]['SubMask']
            if 'NumClients' not in Keys:
                self.Print("NumClients not defined for %s\n" % name, 'ERR')
                continue
            numclients = self.Clientgroups[name]['NumClients']
            self.totRoamClients += numclients
            if 'Security' not in Keys:
                self.Print("Security not defined for %s\n" % name, 'ERR')
                continue    
            network = self.Clientgroups[name]['Security']
            if 'AssocProbe' in Keys:
                assocProbe = self.Clientgroups[name]['AssocProbe']
            self.CreateClientgroup(name, startMAC, startIP, gateway, subnet, 
                    numclients, network, ipIncr, macIncr, assocProbe)
    
    def createRoamProfiles(self):
        """
        Create Roam profiles
        """
        roamnames = self.Roamlist.keys()
        roamnames.sort()
        for name in roamnames:
            Keys = self.Roamlist[name].keys()
            if 'PortList' not in Keys:
                self.Print("PortList not defined for %s\n" % name, 'ERR')
                continue
            portlist = self.Roamlist[name]['PortList']
            if 'BSSIDList' not in Keys:
                self.Print("BSSIDList not defined for %s\n" % name, 'ERR')
                continue
            bssidList = self.Roamlist[name]['BSSIDList']
            
            portbssidMapList = []
            if len(bssidList) != len(portlist):
                self.Print("portlist and bssidlist does not match for %s\n" % 
                        name, 'ERR')
                continue

            if 'DwellTime' not in Keys:
                self.Print("DwellTime not defined for %s\n" % name, 'ERR')
                continue
            dwell_timelist = self.Roamlist[name]['DwellTime']
            if len(dwell_timelist) < 1: #No roam sequence defined for this group
                self.Print("No Roam sequence defined for a group" , 'ERR')
                raise WE.RaiseException

            for i in range(len(portlist)):
                portbssidMapList.append(dict([(portlist[i], bssidList[i])]))
            if 'ClientDistr' not in Keys:
                clientdistributionflag = True
            else:
                clientdistributionflag = self.Roamlist[name]['ClientDistr']
            if (clientdistributionflag != True and 
                    clientdistributionflag != False):
                self.Print("Unknown ClientDistr\n", 'ERR')
                continue
            if 'TimeDistr' not in Keys:
                timedistribution = 'dense'
            else:
                timedistribution = self.Roamlist[name]['TimeDistr']
            if timedistribution != 'even' and timedistribution != 'dense':
                self.Print("Unknown TimeDistr\n", 'ERR')
                continue
            if 'TestType' not in Keys:
                selftype = 'Repeat'
            else:
                selftype = self.Roamlist[name]['TestType']
            if selftype != 'Duration' and selftype != 'Repeat':
                self.Print("Unknown TestType\n", 'ERR')
                continue
            if 'TesttypeValue' not in Keys:
                if selftype == 'Duration':
                    selftypeValue = self.totalduration
                if selftype == 'Repeat':
                    selftypeValue = 1
            else:
                selftypeValue = self.Roamlist[name]['TesttypeValue']
    
            validDwellF, msg = self._checkDwellTimeValidity(portlist, 
                                                           dwell_timelist)
            if not validDwellF:
                self.Print(msg % name, 'ERR')
                continue
            
            roamlist = []
            for i in range(len(portlist)):
                roamlist.append( (portlist[i], bssidList[i],dwell_timelist[i]) )
                
            self.CreateRoamprofile(name, roamlist, clientdistributionflag, 
                                   timedistribution, selftype, selftypeValue, 
                                   portbssidMapList)
    
    def _checkDwellTimeValidity(self, portlist, dwellTimeList):
        """
        Default behavior
        """
        ret = (True, '')

        return ret
    
    def createPowerProfiles(self):
        """
        Create Power profiles
        """
        powerprofnames = self.Powerlist.keys()
        powerprofnames.sort()
        for name in powerprofnames:
            if len(self.Powerlist[name]) < 2:
                self.Print("Power profile %s. not enough params\n" %
                        name, 'ERR')
                continue
            rampdownlist = self.Powerlist[name][0]
            if len(rampdownlist) < 4:
                self.Print("Pwr down config in %s. not enough params\n" %
                    name, 'ERR')
                continue
            rampuplist = self.Powerlist[name][1]
            if len(rampuplist) < 4:
                self.Print("Pwr up config in %s. not enough params\n" %
                    name, 'ERR')
                continue
            #A few system specific checks..
            
            #Power ramp down
            retVal, msg = self._checkPowerRamps(rampdownlist, "down")
            if not retVal:
                self.Print(msg %('Power Down', name), 'ERR')
            #Power ramp up
            retVal, msg = self._checkPowerRamps(rampuplist, "up")
            if not retVal:
                self.Print(msg %('Power Up', name), 'ERR')
                
            self.CreatePowerprofile(name, rampdownlist, rampuplist)
    
    def _checkPowerRamps(self, rampList, direction):
        """
        Sanity check for power ramp (up/down) values
        FIXME: when the dwelltime is not sufficient to complete all the
        power steps we consider it as invalid config and stop the test but 
        do not print any error message. Add that check below 
        """
        
        retVal = (True, "")
        startpower = rampList[0]
        endpower   = rampList[1]
        pstep      = rampList[2]
        interval   = rampList[3]
        
        #interval in msecs, and dwell time always expressed in seconds
        #thus interval/1000 
        #FIXME: Complete this check
        minDwellTime = (abs(startpower - endpower)/pstep) * (interval/1000)
        
        if direction == "up":
            if startpower > endpower:
                retVal = (False, "Pwr start > end of %s prof in %s\n" )
        elif direction == "down":
            if startpower < endpower:
                retVal = (False, "Pwr start < end of %s prof in %s\n" )
                
        if ((startpower < -42) or (startpower > -6)):
            retVal = (False, "Invalid Start power of %s profile in %s.\n\
                                Should be a value between -6 and -42\n")
        if ((endpower < -42) or (endpower > -6)):
            retVal = (False, "Invalid End power of %s profile in %s.\n\
                             Should be a value between -6 and -42\n")
        if pstep < 1:
            retVal = (False, "Invalid Power step of %s profile in %s.\n\
                             Should not be less than 1\n")
        if interval < 100:
            retVal = (False, "Invalid TimeInterval of %s profile in %s.\n\
                              Should not be less than 100\n")
        return retVal
    
    def connectRoamAndPowerProfiles(self):
        """
        Attach power profile to Roam profile
        """
        roamnames = self.Roamlist.keys()
        roamnames.sort()
        for name in roamnames:
            powerprofname = ''
            if 'Powerprof' in self.Roamlist[name].keys():
                powerprofname = self.Roamlist[name]['Powerprof']
            if powerprofname == '':
                continue
            self.AttachPowerprofile(name, powerprofname)   
            
    def connectRoamProfAndClientGroup(self):
        """
        Attach Roam profile to Client group
        """
        groupnames = self.Clientgroups.keys()
        groupnames.sort()
        for name in groupnames:
            if 'Roamprof' not in self.Clientgroups[name].keys():
                self.Print("No Roamprof defined for %s\n" % name, 'ERR')
                continue
            roamprofname = self.Clientgroups[name]['Roamprof']
            if roamprofname not in self.Roamprofiles.keys():
                self.Print("Unknown roam profile %s\n" % roamprofname, 'ERR')
                if name not in self.InvalidClientgrps:
                    self.InvalidClientgrps.append(name)
                continue
            self.AttachRoamprofile(name, roamprofname) 
            
    def enabledGroups(self, clientGroups):
        enabledGroups = {}
        for group in clientGroups:
            if clientGroups[group]['Enable'] in [True, 'True']:
                enabledGroups[group] = clientGroups[group]
        return enabledGroups
    
    def loadData(self, waveChassisStore, wavePortStore, waveClientTableStore,
                 waveSecurityStore, waveTestStore, waveTestSpecificStore,
                 waveMappingStore, waveBlogStore):
        BaseTest.loadData(self, waveChassisStore, wavePortStore, waveClientTableStore,
                          waveSecurityStore, waveTestStore, waveTestSpecificStore,
                          waveMappingStore, waveBlogStore)
        #___________________________________TEL_________________________________________________
        #check for the db key in the waveTestStore['LogsAndResultsInfo'] dictionary if present assign the
        #the corresponding value to DbSupport. Similarly check for the key for pass/fail criteria pf and
        #update the self.UserPassFailCriteria['user'].If user is True then assign the other values for the
        #calculation purpose to judge the pass/fail of the result.
        if waveTestStore['LogsAndResultsInfo'].has_key('db'):
            self.DbSupport = waveTestStore['LogsAndResultsInfo']['db']
        if waveTestStore['LogsAndResultsInfo'].has_key('pf'):
            self.UserPassFailCriteria['user']= waveTestStore['LogsAndResultsInfo']['pf']
            testname=waveTestSpecificStore.keys()[0]
            group_list=waveClientTableStore.keys()
            for t,each in waveClientTableStore.items():
              if each['Interface']=='802.3 Ethernet':
                   del group_list[group_list.index(t)]
            group_list.sort()
            for each_cg in group_list: 
                self.UserPassFailCriteria[each_cg]={}
                tmp=group_list.index(each_cg)
                if testname =='roaming_delay':
                     roam_dict_pf=  waveTestSpecificStore.values()[0].values()[tmp]
                elif (testname =='roaming_benchmark') or (testname == 'voip_roam_quality'):
                     roam_dict_pf=  waveTestSpecificStore.values()[0] 
                    ## Give in Percentage
                if (testname =='roaming_delay') or (testname =='roaming_benchmark'):
                    if self.UserPassFailCriteria['user']=='True':
                         if roam_dict_pf.has_key('AcceptableRoamFailures'):
                            if float(roam_dict_pf['AcceptableRoamFailures']) >= 0: 
                                self.UserPassFailCriteria[each_cg]['ref_min_fail_roams']=float (roam_dict_pf['AcceptableRoamFailures'])/100
                            else:
                                WaveEngine.OutputstreamHDL("\nThe value for the parameter AcceptableRoamFailures should be a positive number\n",WaveEngine.MSG_ERROR)
                                raise  WaveEngine.RaiseException
                         else:
                            WaveEngine.OutputstreamHDL("\nUser has not given the value for <AcceptableRoamFailures> parameter, hence reverting to default value and proceeding further....\n",WaveEngine.MSG_WARNING)
                            self.UserPassFailCriteria[each_cg]['ref_min_fail_roams']=0.0
                         ## Give Delay in ms
                         if roam_dict_pf.has_key('AcceptableRoamDelay'):
                             if float (roam_dict_pf['AcceptableRoamDelay']) >=0: 
                                  self.UserPassFailCriteria[each_cg]['ref_max_delay']=float (roam_dict_pf['AcceptableRoamDelay'])
                             else:
                                   WaveEngine.OutputstreamHDL("\nThe value for the parameter AcceptableRoamDelay should be a positive number\n",WaveEngine.MSG_ERROR)
                                   raise  WaveEngine.RaiseException
                         else:
                             WaveEngine.OutputstreamHDL("\nUser has not given the value for <AcceptableRoamDelay> parameter, hence reverting to default value and proceeding further....\n",WaveEngine.MSG_WARNING)
                             self.UserPassFailCriteria[each_cg]['ref_max_delay']=50
                elif testname == 'voip_roam_quality':
                    if self.UserPassFailCriteria['user']=='True':
                        if roam_dict_pf.has_key('AcceptableDroppedCalls'):
                           if float(roam_dict_pf['AcceptableDroppedCalls']) >=0:  
                                self.UserPassFailCriteria[each_cg]['ref_min_drop_calls']=float (roam_dict_pf['AcceptableDroppedCalls'])/100
                           else:
                                WaveEngine.OutputstreamHDL("\nThe value for the parameter AcceptableRoamDelay should be a positive number\n",WaveEngine.MSG_ERROR)
                                raise  WaveEngine.RaiseException
                        else:
                           WaveEngine.OutputstreamHDL("\nUser has not given the value for <AcceptableDroppedCalls> parameter, hence reverting to default value and proceeding further....\n",WaveEngine.MSG_WARNING)
                           self.UserPassFailCriteria[each_cg]['ref_min_drop_calls']=0.0
                        if roam_dict_pf.has_key('AcceptableRValue'):
                            if float(roam_dict_pf['AcceptableRValue']) >=0: 
                                 self.UserPassFailCriteria[each_cg]['ref_min_rvalue']=roam_dict_pf['AcceptableRValue']
                            else:
                                 WaveEngine.OutputstreamHDL("\nThe value for the parameter AcceptableRValue should be a positive number\n",WaveEngine.MSG_ERROR)
                                 raise  WaveEngine.RaiseException
     
                        else:
                            WaveEngine.OutputstreamHDL("\nUser has not given the value for <AcceptableRValu> parameter, hence reverting to default value and proceeding further....\n",WaveEngine.MSG_WARNING)
                            self.UserPassFailCriteria[each_cg]['ref_min_rvalue']=78 
        #___________________________________TEL_____________________________________
        
    #Make some sense out of all the info. Convert into 
        #script specific format. 
        self.NetworkList = {}
        self.Powerlist = {}
        self.Roamlist = {}
        self.MainFlowlist = {}
        self.LearnFlowlist = {}
        self.profileMap = {}
        self.Clientgroups = {}
        self.Port8023_Name       = ''
        self.Port8023_ClientName = 'Client_8023'
        self.Port8023_IPaddress  = ''
        self.Port8023_Subnet     = ''
        self.Port8023_Gateway    = ''
        self.Port8023_AssocRate = 100
        self.Port8023_AssocTimeout = 1
        self.Port8023_AssocRetry = 1
        self.Port8023_MAC        = ''
        self.testName = ''
        nonRoamClientTableStore = {}
        self.Numofclients = {}
        self.WCTableStore = {}
        self.WCTableStore = waveClientTableStore
        self.nonRoamGroups = {}    
        try:
            self._loadTestKeyAndName()
            if self.testKey == '':
                self.Print("No Roaming config found\n", 'ERR')
                raise WE.RaiseException
        except WE.RaiseException:
            self.Print("WaveEngine terminating the run\n", 'ERR')
            self.CloseShop()
            return -1

        enabledGroups = self.enabledGroups(waveClientTableStore)
        wlanGroups  = self.wlanGroups(waveClientTableStore)
        roamGroups = self.roamGroups(waveClientTableStore)
        
        roaming_data = self._getRoamData(waveTestSpecificStore, 
                                         waveClientTableStore, 
                                         wlanGroups)
        
        self._loadTestSpecificData(waveClientTableStore, waveTestSpecificStore,
                                   waveSecurityStore, roaming_data, 
                                   enabledGroups, wlanGroups, roamGroups)
        
        profMap = self._createPowerlist(roamGroups, roaming_data)
        self._updateProfMap('Powerprof', profMap)
        
        profMap = self._createRoamProfiles(roamGroups, roaming_data)
        self._updateProfMap('Roamprof', profMap)
        
        profMap = self._createSecurityProfiles(roamGroups, roaming_data, 
                                               waveSecurityStore)
        self._updateProfMap('Security', profMap)
        
        profMap = self._createMainFlowList(roamGroups, roaming_data, 
                                           waveClientTableStore, waveTestStore,
                                           waveTestSpecificStore)
        self._updateProfMap('MainFlow', profMap)
        
        #self._createLearnFlowList()
        
        self._createClientGroupProfiles(roamGroups, waveClientTableStore, 
                                        roaming_data)

        self.totalduration = self._getTestTotalDuration()
        
    def _loadTestKeyAndName(self):
        """
        Virtual. Must be defined in the derived class (test module)
        """
        
    def _getRoamData(self):
        """
        Virtual. Must be defined in the derived class (test module)
        """
    
    def _createDummyDictsForWaitTimes():
        """
        Virtual. Must be defined in the derived class (test module)
        """
        
    def _updateProfMap(self, prof, profDict):
        for group in profDict:
            if group not in self.profileMap:
                self.profileMap[group] = {}
            self.profileMap[group][prof] = profDict[group]
                
            
    def _getProf(self, prof, group):
        if group in self.profileMap:
            return self.profileMap[group].get(prof, None)
        else:
            return None
        
    def _createPowerlist(self, roamGroups, roaming_data):
        profMap = {}
        for i, clientgroupName in enumerate(roamGroups):
            clientVals = roaming_data[clientgroupName]
            #Create power profile
            PprofileName = ''
            if clientVals['powerProfileFlag'] == 1: #True
                PprofileName = 'Pprofile' + str(i+1)
                powerprofile = ([clientVals['srcStartPwr'],
                                 clientVals['srcEndPwr'], 
                                 clientVals['srcChangeStep'],
                                 clientVals['srcChangeInt']], 
                                [clientVals['destEndPwr'], 
                                 clientVals['destEndPwr'], 
                                 clientVals['destChangeStep'],
                                 clientVals['destChangeInt']])
                self.Powerlist[PprofileName] = powerprofile
                profMap[clientgroupName] = PprofileName
        return profMap
    
    def _createRoamProfiles(self, roamGroups, roaming_data):
        profMap = {}
        for i, clientgroupName in enumerate(roamGroups):
            clientVals = roaming_data[clientgroupName]
            #Create roam profile
            RprofileName = 'Roam' + str(i+1)
            Rprofile = {}
            Rprofile['PortList'] = clientVals['portNameList'][:]
            Rprofile['BSSIDList'] = clientVals['bssidList'][:]
            #No dwellTimeOption in 'Roaming Benchmark', 'Roaming Service Quality'
            dwellList = self._getDwellList(clientVals)
    
    
            Rprofile['DwellTime'] = dwellList
            #clientDistr, timeDistr are part of legacy code, although we don't use it with
            #roam benchmark test we are not getting rid of it now as we are not sure if we 
            #might want to implement clientDistr sometime in the future the same 
            #with timeDistr
    
            clientDistOption = clientVals.get('clientDistOption', None)
            Rprofile['ClientDistr'] = self._getClientDistr(clientDistOption)
            
            timeDistOption= clientVals.get('timeDistOption', None)
            Rprofile['TimeDistr'] = self._getTimeDistr(timeDistOption)
            
            Rprofile['TestType'] = self._getTestType(clientVals['repeatType'])
            
            Rprofile['TesttypeValue'] = clientVals['repeatValue']
            
            if Rprofile['TestType'] == 'Duration':
                durationUnits = clientVals['durationUnits']
                if durationUnits == 1: #minutes
                    Rprofile['TesttypeValue'] *= 60
                if durationUnits == 2: #hours
                    Rprofile['TesttypeValue'] *= 3600
                   
            PprofileName = self._getProf('Powerprof', clientgroupName)
            if PprofileName:
                Rprofile['Powerprof'] = PprofileName
            
            self.Roamlist[RprofileName] = Rprofile
            
            profMap[clientgroupName] = RprofileName
            self.Numofclients[RprofileName]=self.WCTableStore[clientgroupName]['NumClients']
        return profMap
    
    def _createSecurityProfiles(self, roamGroups, roaming_data, waveSecurityStore):
        profMap = {}
        for i, clientgroupName in enumerate(roamGroups):
            clientVals = roaming_data[clientgroupName]
            SprofileName = 'Security' + str(i+1)
            Sprofile = {}
            Sprofile['ssid'] = clientVals['ssid']
            security = self.Security_None
            if clientgroupName in waveSecurityStore.keys():
                security = waveSecurityStore[clientgroupName]
            Sprofile['security'] = security
              
            Sprofile['otherflags'] = self._getOtherFalgs(clientVals, security)
            
            self.NetworkList[SprofileName] = Sprofile
            
            profMap[clientgroupName] = SprofileName
        return profMap
    
    def _getOtherFalgs(self, clientVals, security):
        otherflags = {}
        otherflags['Disassoc_before_reassoc'] = clientVals['disassociate']
        otherflags['Reassoc_when_roam'] = clientVals['reassoc']
        otherflags['pmkid_cache'] = clientVals['pmkid']
        otherflags['Deauth_before_roam'] = clientVals['deauth']
        otherflags['PreAuth'] = clientVals['preauth']
        otherflags['renewDHCP'] = clientVals['renewDHCP']
        otherflags['renewDHCPonConn'] = clientVals['renewDHCPonConn']
        
        #Set PersistentReauth flag, if the security type is EAP-FAST
        otherflags['PersistentReauth'] = self._PersistentReauthF(security)
        
        return otherflags
    
    def _PersistentReauthF(self, security):
        persistReauthF = False
        if security['NetworkAuthMethod'] == 'EAP/FAST':
            persistReauthF = True
            
        return persistReauthF
    
    def _createMainFlowList(self, roamGroups, roaming_data, waveClientTableStore, 
                            waveTestStore, waveTestSpecificStore):
        profMap = {}
        for i, clientgroupName in enumerate(roamGroups):
            clientVals = roaming_data[clientgroupName]
            MflowName = 'Flow' + str(i+1)
            Mprofile = {}
            
            if waveTestStore['Traffics']['TrafficType'] == 'Udp':
                Mprofile['Type'] = 'UDP' 
                Mprofile['srcPort'] = waveTestStore['Traffics']['SourcePort'] 
                Mprofile['destPort'] = waveTestStore['Traffics']['DestinationPort']
            elif waveTestStore['Traffics']['TrafficType'] == 'Icmp':
                Mprofile['Type'] = 'ICMP'
                Mprofile['code'] = waveTestStore['Traffics']['Code'] 
            Mprofile['Intendedrate'] = clientVals['flowRate']
            Mprofile['Framesize'] = clientVals['flowPacketSize']
            phyrate = float(waveClientTableStore[clientgroupName]['DataPhyRate'])
            Mprofile['Phyrate'] = phyrate
            Mprofile['Ratemode'] = 'pps' 
            Mprofile['Numframes'] = WE.MAXtxFrames
            
            self.MainFlowlist[MflowName] = Mprofile    
            
            profMap[clientgroupName] = MflowName
        return profMap
    
    """
    Commenting out to use the Ministack Learning
    
    def _createLearnFlowList(self, roamGroups, roaming_data, waveClientTableStore):
        #Create LearningFlow profile
        
        for i, clientgroupName in enumerate(roamGroups):
            clientVals = roaming_data[clientgroupName]
    
            
            LflowName = ''
            if clientVals['learningFlowFlag'] == 1: #True
                LflowName = 'Lflow' + str(i)
                Lprofile = {}
                Lprofile['Type'] = 'UDP'
                Lprofile['Framesize'] = clientVals['learningPacketSize']
                #Split into two lines to stick with the max line
                #width of 80 throughout the code. Lame? :)
                clientObj = waveClientTableStore[clientgroupName]
                phyrate = int(clientObj['DataPhyRate'])
                Lprofile['Phyrate'] = phyrate
                Lprofile['Ratemode'] = 'pps'
                Lprofile['Intendedrate'] = clientVals['learningPacketRate']
                Lprofile['Numframes'] = clientVals['learningPacketCount']
                self.LearnFlowlist[LflowName] = Lprofile
    """
    
    def _createClientGroupProfiles(self, roamGroups, waveClientTableStore, 
                                   roaming_data):
        """
        Create ClientGroup profile
        """
        for i, clientgroupName in enumerate(roamGroups):
            clientVals = roaming_data[clientgroupName]
            
            clientGrpObj = waveClientTableStore[clientgroupName]
            clientGrpProfile = {}
            enableF = clientGrpObj['Enable']
            if enableF == True or enableF == 'True':
                clientGrpProfile['Enable'] = True
            else:
                clientGrpProfile['Enable'] = False
            if clientGrpObj['MacAddressMode'] == 'Auto':
                clientGrpProfile['StartMAC'] = 'AUTO'
            elif clientGrpObj['MacAddressMode'] == 'Random':
                clientGrpProfile['StartMAC'] = 'DEFAULT'
            else:
                clientGrpProfile['StartMAC'] = clientGrpObj['MacAddress']
                if clientGrpObj['MacAddressMode'] == 'Decrement':
                    incr = -(int(clientGrpObj['MacAddressIncr']))
                else:
                    incr = int(clientGrpObj['MacAddressIncr'])
                clientGrpProfile['MACIncr'] = incr
            clientGrpProfile['StartIP'] = clientGrpObj['BaseIp']
            clientGrpProfile['IncrIp'] = clientGrpObj['IncrIp']
            if clientGrpObj['Dhcp'] == 'Enable':
                clientGrpProfile['StartIP'] = '0.0.0.0'
            clientGrpProfile['GratuitousArp'] = clientGrpObj['GratuitousArp']
            clientGrpProfile['Gateway'] = clientGrpObj['Gateway']
            clientGrpProfile['SubMask'] = clientGrpObj['SubnetMask']
            clientGrpProfile['NumClients'] = int(clientGrpObj['NumClients'])
            clientGrpProfile['MgmtPhyRate'] = float(clientGrpObj['MgmtPhyRate'])
            clientGrpProfile['ProactiveKeyCaching'] = clientGrpObj['ProactiveKeyCaching']
            #
            clientGrpProfile['Security'] = self._getProf('Security', clientgroupName)
            clientGrpProfile['Roamprof'] = self._getProf('Roamprof', clientgroupName)
            clientGrpProfile['MainFlow'] = self._getProf('MainFlow', clientgroupName)   
            """
            if LflowName != '':
                clientGrpProfile['LearnFlow'] = LflowName
            """
            if clientGrpObj['Interface'] in WE.WiFiInterfaceTypes:
                clientGrpProfile['AssocProbe'] = clientGrpObj['AssocProbe']
                clientGrpProfile['CtsToSelf'] = clientGrpObj['CtsToSelf']
                
            clientGrpProfile['phyInterface'] = clientGrpObj['phyInterface']
            clientGrpProfile['nPhySettings'] = clientGrpObj['nPhySettings']  
              
            self.Clientgroups[clientgroupName] = clientGrpProfile

        self._updateClientGroupProfile(roaming_data)
        
    def _updateClientGroupProfile(self, roaming_data):
        """
        Any test specific attributes to be added to the client group profile would be
        added through this method.
        Virtual. Implement in the derived class
        """
                
    def _updateCGProfLFlowFlag(self, roaming_data):
        """
        Update the 'learningFlowFlag' in the client group profile
        """
        for group in self.Clientgroups:
            clientVals = roaming_data[group]
            clientGrpProfile = self.Clientgroups[group]
            if clientVals['learningFlowFlag'] == 1: #True
                clientGrpProfile['ClientLearning'] = "on"
                if 'learningPacketRate' in clientVals.keys():
                    clientGrpProfile['LearningRate'] = clientVals['learningPacketRate']
                    
    def _getTestTotalDuration(self):
        """
        Test total duration is the same for all the roaming groups. Pick from a group
        """
        groupsDurationList = []
        for group in self.Roamlist:
            if self.Roamlist[group]['TestType'] == 'Duration':
                groupsDurationList.append(self.Roamlist[group]['TesttypeValue'])
            elif self.Roamlist[group]['TestType'] == 'Repeat':
                numCycles = (self.Roamlist[group]['TesttypeValue'] + 1)
                #For a group dwell times are the same on all ports, always
                #(thus self.Roamlist[group]['DwellTime'] always has equal value
                #items, nevertheless using sum() for better readability and later
                #flexibility
                oneCycleTime=sum(self.Roamlist[group]['DwellTime'])
                groupsDurationList.append( numCycles * oneCycleTime* int(self.Numofclients[group]))
        
        if len(groupsDurationList) >= 1:
            if self.Roamlist[group]['TestType'] == 'Repeat':
                return sum(groupsDurationList)
            elif self.Roamlist[group]['TestType'] == 'Duration':
                return max(groupsDurationList) 
        else:
            return 0 
    
    def wlanGroups(self, waveClientTableStore):
        enabledGroups = self.enabledGroups(waveClientTableStore)
        enabledWlanGroups = []
        for groupName in enabledGroups:
            if enabledGroups[groupName]['Interface'] in WE.WiFiInterfaceTypes:
                enabledWlanGroups.append(groupName)
        return enabledWlanGroups
    
    def _loadEthGroupData(self, waveClientTableStore, waveSecurityStore):
        """
        Virtual function. Must be defined in the required derived class
        """
