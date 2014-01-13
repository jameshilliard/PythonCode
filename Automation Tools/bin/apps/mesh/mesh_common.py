#
# MeshCommon is a class which has common functions used in the Mesh test scripts
# All mesh tests extend MeshCommon

#Common imports used in the scripts
import WaveEngine
import struct
import odict
from odict import *
from CommonFunctions import *
from basetest import *
from reportlab.platypus import Flowable
#
#   Create a standard template for the reports
#

#################################### Constants #################################
#

class MeshCommon:     
    def TransmitIteration(self, TXtime, RXtime, UpdateTime, GroupName, StopTX, UpdateFunction, PassedParameters):
        self.HopLastRead = {}
        HopIndex   = 0
        for eachHop in self.HopFlowList:
            self.HopLastRead[HopIndex] = (0,0,0)
            HopIndex += 1
            
        scheduler = sched.scheduler(time.time, time.sleep)
        QuarterTime = TXtime / 4.0

        #               delay, priority,  action, arguments
        scheduler.enter(    0,        1, WaveEngine.VCLtest, ("action.startFlowGroup('%s')" % (GroupName), ))
        if StopTX:
            scheduler.enter(TXtime,     1, WaveEngine.VCLtest, ("action.stopFlowGroup('%s')" % (GroupName), ))
        for n in range(int((TXtime + RXtime) / UpdateTime)):
            ElapsedTime = UpdateTime * (n+1)
            Timeleft    = (TXtime + RXtime) - ElapsedTime
            Transmitting_Flag = ' TX '
            if ElapsedTime > TXtime:
                Transmitting_Flag = ' RX '
            # Do not call the realtime stats when its close to stopping the flows
            if TXtime - ElapsedTime > UpdateTime or ElapsedTime > TXtime:
                scheduler.enter(ElapsedTime,     100, UpdateFunction, (Transmitting_Flag, Timeleft, ElapsedTime, PassedParameters))
        scheduler.enter(TXtime + RXtime, 100, UpdateFunction, (Transmitting_Flag, 0.0, TXtime + RXtime, PassedParameters))

        #Run the Iteration
        scheduler.run()    
             
    def BuildReport(self, MyReport):
        #Hack to stop printing the document
        if self.generatePdfReportF:
            MyReport.Print()
############################ Import_MeshClientLists ############################
# (BaseName, Port, BSSID, Base_MAC,  Base_IP, Subnet, Gateway, (Count=1, Incr_MAC='0:0:0:0:0:0', Incr_IP='0.0.0.0'), Security, Options)    
    def Import_MeshClientLists(self,waveClientTableStore, wavePortStore, waveSecurityStore, waveMappingStore):
        subnetKeyList = waveClientTableStore.keys() # list of client group names
        
        meshGatewayClients = OrderedDict()
        meshHopClients = OrderedDict()
        
        for eachSubnet in subnetKeyList:
            NodeId = str(waveClientTableStore[eachSubnet]['NodeId'])
            NumOfHops = int(waveClientTableStore[eachSubnet]['Hops'])
            if NumOfHops != -1:
                meshHopClients[NodeId] = []
            else:
                meshGatewayClients[NodeId] = []
                
        # Create a Master Client Profile
        ClientProfile = {}
        for eachSubnet in subnetKeyList:
            if waveClientTableStore[eachSubnet]['Enable'] == False or \
               waveClientTableStore[eachSubnet]['Enable'] == 'False':
                continue            
            clientTuple = ()
            newTuple = ()
            clientOptionsDict = {}
            
            NodeId = str(waveClientTableStore[eachSubnet]['NodeId'])
            NumOfHops = int(waveClientTableStore[eachSubnet]['Hops'])
            GroupName   = waveClientTableStore[eachSubnet]['Name']
            clientTuple = clientTuple + (GroupName,)
            clientTuple = clientTuple + (waveClientTableStore[eachSubnet]['PortName'],)
            
            # need to convert 'None' to '00:00:00:00:00:00' for ethernet clients.
            if waveClientTableStore[eachSubnet]['Interface'] == '802.3 Ethernet':
                clientTuple = clientTuple + ('00:00:00:00:00:00',)
            else:
                clientTuple = clientTuple + (waveClientTableStore[eachSubnet]['Bssid'],)
            
            # translate mac address mode
            macAddrMode = str( waveClientTableStore[eachSubnet]['MacAddressMode'] ).upper()
            if macAddrMode == 'AUTO':
                # automatic mode -- assign MAC by cc:ss:pp:ip:ip:ip
                clientTuple = clientTuple + ('AUTO',)
            elif macAddrMode in [ 'DEFAULT', 'RANDOM' ]:
                # default mode -- assign MAC by the IETF draft rr:pp:pp:rr:rr:rr
                # also known as random mode
                macAddrMode = 'DEFAULT'
                clientTuple = clientTuple + ('DEFAULT',)
            else:
                # provided mac
                clientTuple = clientTuple + (str(waveClientTableStore[eachSubnet]['MacAddress']),)
    
            useDhcp = str( waveClientTableStore[eachSubnet]['Dhcp'] )
            if ( useDhcp in [ 'Enable', 'True' ] ):
                clientTuple = clientTuple + ( str( "0.0.0.0" ), )
            else:
                clientTuple = clientTuple + (str(waveClientTableStore[eachSubnet]['BaseIp']),)
            clientTuple = clientTuple + (waveClientTableStore[eachSubnet]['SubnetMask'],)
            clientTuple = clientTuple + (waveClientTableStore[eachSubnet]['Gateway'],)
            newTuple = newTuple + (int(waveClientTableStore[eachSubnet]['NumClients']),)
            
            #This is the MAC addr increment/decrement
            macIncr = str(waveClientTableStore[eachSubnet]['MacAddressIncr'])
            if macIncr.upper() == 'DEFAULT':
                # store AUTO or DEFAULT from base MAC
                if macAddrMode in [ 'DEFAULT', 'AUTO' ]:
                    newTuple = newTuple + (macAddrMode,)
                else:
                    newTuple = newTuple + (macIncr,)
            else:
                macIncrInt = int(macIncr)
                if macAddrMode == 'INCREMENT':
                    macIncrMac = MACaddress().inc(macIncrInt)
                else:
                    macIncrMac = MACaddress().dec(macIncrInt)
                newTuple = newTuple + (macIncrMac.get(),)
            
            #This is the client IP increment field
            newTuple = newTuple + (waveClientTableStore[eachSubnet]['IncrIp'],)
            clientTuple = clientTuple + (newTuple,)
            clientTuple = clientTuple + (waveSecurityStore[eachSubnet],)

            # if flow type is TCP, we need to add 'enableNetworkInterface' to client options
            if len(waveMappingStore) > 2:
                flowType = waveMappingStore[5]['Type']
                if flowType == 'TCP':
                    clientOptionsDict['enableNetworkInterface'] = True
    
            #We don't have to set the PhyRate in case of an Ethernet Card as that shall
            #be set on a per port basis
            if waveClientTableStore[eachSubnet]['Interface'] != "802.3 Ethernet":
                clientOptionsDict['PhyRate'] = float(waveClientTableStore[eachSubnet]['MgmtPhyRate'])
                clientOptionsDict['TxPower'] = int(waveClientTableStore[eachSubnet]['TxPower'])
                # VPR 4267: b-only Mode added
                bOnlyMode = str(waveClientTableStore[eachSubnet].get('BOnlyMode', False))
                if bOnlyMode == 'True':
                    clientOptionsDict['BOnlyMode'] = 'on'
                else:
                    clientOptionsDict['BOnlyMode'] = 'off'   
                
                if waveClientTableStore[eachSubnet]['GratuitousArp'] == "True":
                    clientOptionsDict['GratuitousArp'] = "on"
                else:
                    clientOptionsDict['GratuitousArp'] = "off"
                if str( waveClientTableStore[ eachSubnet ].get( 'ProactiveKeyCaching', "False" ) ) == "True":
                    clientOptionsDict['ProactiveKeyCaching'] = "on"
                else:
                    clientOptionsDict['ProactiveKeyCaching'] = "off"
                probeVal = str( waveClientTableStore[ eachSubnet ].get( 'AssocProbe', "unicast" ) )
                if probeVal == 'Broadcast':
                    clientOptionsDict['ProbeBeforeAssoc'] = "bdcast"
                elif probeVal == 'None':
                    clientOptionsDict['ProbeBeforeAssoc'] = "off"
                else:
                    clientOptionsDict['ProbeBeforeAssoc'] = "unicast"
                # Keep Alive Frames
                keepAlive = str(waveClientTableStore[eachSubnet].get('KeepAlive', False))
                if keepAlive == 'True':
                    clientOptionsDict['ClientLearning'] = 'on'
                else:
                    clientOptionsDict['ClientLearning'] = 'off'   
                clientOptionsDict['LearningRate'] = \
                    int(waveClientTableStore[eachSubnet].get('KeepAliveRate', 10))                         
    
            # Ethernet-only options, such as VLAN
            thisSubnet = waveClientTableStore[ eachSubnet ]
            if thisSubnet[ 'Interface' ] == "802.3 Ethernet":
                # VLAN
                if str( thisSubnet.get( 'VlanEnable', "False" ) ) == "True":
                    # VLAN enabled, parse VLAN values
                    userPriority = int( thisSubnet.get( 'VlanUserPriority', 0 ) )
                    if str( thisSubnet.get( 'VlanCfi', "False" ) ) == "True":
                        cfiBit = 1
                    else:
                        cfiBit = 0
                    vlanId = int( thisSubnet.get( 'VlanId', 0 ) )
                    # assemble parts into the VCAL VLAN Tag
                    # [ 3:UserPriority ][ 1:CFI ][ 12:VlanId ] => 16bit value
                    vlanTag = ( userPriority & 0x7 ) * 2**13 + ( cfiBit & 0x1 ) * 2**12 + ( vlanId & 0xfff )
                    # msg = "%s: assembled VLAN tag = %d ( user = %d, cfi = %d, id = %d )" % ( eachSubnet, vlanTag, userPriority, cfiBit, vlanId )
                    # OutputstreamHDL( msg, MSG_WARNING )
                    clientOptionsDict[ 'VlanTag' ] = vlanTag
                # done with VLAN
            clientTuple = clientTuple + (clientOptionsDict,)
            
            #FIXME...This needs to be fixed when we support multiple gateways
            #If the Hops is -1 it is by default a client tuple on the meshGateway side
            if NumOfHops == -1:
                meshGatewayClients[NodeId].append(clientTuple)
            else:
                meshHopClients[NodeId].append(clientTuple)
            # Store the number of hops to dict
            self.meshNumOfHopsDict[NodeId] = NumOfHops
        
        meshHopClientsSorted = OrderedDict()
        meshHopClientsSortByHop = OrderedDict()
        # Sort the meshHopClients by their hop counts
        for client, hop in self.meshNumOfHopsDict.iteritems():
            if meshGatewayClients.has_key(client) == False:
                if meshHopClientsSortByHop.has_key(hop) == False:
                    meshHopClientsSortByHop[hop] = []
                meshHopClientsSortByHop[hop].append(client)
                
        meshHopClientsKeys = meshHopClientsSortByHop.keys()
        meshHopClientsKeys.sort()
        for key in meshHopClientsKeys:
            for nodeId in meshHopClientsSortByHop[key]:
                meshHopClientsSorted[nodeId] = meshHopClients[nodeId]
                        
        return meshGatewayClients, meshHopClientsSorted

################################ BuildClientTable ##############################
    def BuildClientTable(self):
        self.DestClients   = []
        gwKeys = self.meshGatewayClients.keys()
        self.SourceClients = self.meshGatewayClients[gwKeys[0]] # FIXME: hardwired to the 1st gw in the list, assuming we only support 1 gw 
        for item in self.meshHopClients.keys():
            for eachGroup in self.meshHopClients[item]:
                self.DestClients.append(eachGroup)    

############################### configureMeshFlows #############################        
    def configureMeshFlows(self, perHop=True, connectBiflow=False):
        # Set the flows up initally with the learning paramters
        self.FlowOptions['NumFrames']    = self.FlowOptions.get('NumFrames',int( self.FlowLearningTime * self.FlowLearningRate))
        self.FlowOptions['IntendedRate'] = self.FlowOptions.get('IntendedRate', self.FlowLearningRate)
        self.FlowOptions['RateMode']     = 'pps'

        biflowDict = {}
        Prefix = ''
        hasPorts = False
        if self.trafficParams.has_key('SourcePort') and self.trafficParams.has_key('DestinationPort'):
            self.FlowOptions['srcPort'] = self.trafficParams['SourcePort']
            self.FlowOptions['destPort'] = self.trafficParams['DestinationPort']
            incrSourcePort = 0
            if self.trafficParams.get('IncrSourcePort', 'False') == 'True':
                incrSourcePort = 1
            incrDestPort = 0
            if self.trafficParams.get('IncrDestPort', 'False') == 'True':
                incrDestPort = 1            
            hasPorts = True

        #Create a FlowMap of Round-Robin so that each Side does not need to have the same number of clients
        GatewayClientsNames = self.ListofSrcClient.keys()
        GatewayClientsCount = len(GatewayClientsNames)
        GatewayClientsIndex = 0
        #MaximumHops = len(self.meshHopClients)
        meshHopClientsKeys = self.meshHopClients.keys()
        self.HopFlowList = OrderedDict()

        for node in meshHopClientsKeys:
            if len(self.meshHopClients[node]) > 0:
                SrcClientNames = []
                DesClientNames = [] 
                for eachClient in self.meshHopClients[node]:                   
                    BaseLength = len(eachClient[0])
                    for eachKey in self.ListofDesClient.keys():
                        if eachClient[0] == eachKey[:BaseLength]:
                            #Client belongs to the current hop
                            if self.FlowDirection == self.FlowPattern.both or \
                               self.FlowDirection == self.FlowPattern.down:
                                SrcClientNames.append(GatewayClientsNames[GatewayClientsIndex])
                                DesClientNames.append(eachKey)
                            if self.FlowDirection == self.FlowPattern.both or \
                               self.FlowDirection == self.FlowPattern.up:
                                SrcClientNames.append(eachKey)
                                DesClientNames.append(GatewayClientsNames[GatewayClientsIndex])
                            GatewayClientsIndex += 1
                            # Wrap around if num of gateway clients < num of nodes clients
                            if GatewayClientsIndex >= GatewayClientsCount:
                                GatewayClientsIndex = 0        

                # Per Hop Flow options can be implemented here
                desPhyRate = True
                if SrcClientNames != []:
                    # Find out the correct Flow Phy Rate for the source clients
                    for eachFlowPhyRates in self.flowPhyRates:
                        if eachFlowPhyRates in SrcClientNames[0]:  
                            self.FlowOptions['PhyRate'] = self.flowPhyRates[eachFlowPhyRates] 
                            desPhyRate = False 
                            break
                if DesClientNames != [] and desPhyRate == True:
                    # Find out the correct Flow Phy Rate for the dest clients
                    for eachFlowPhyRates in self.flowPhyRates:                    
                        if eachFlowPhyRates in DesClientNames[0]: 
                            self.FlowOptions['PhyRate'] = self.flowPhyRates[eachFlowPhyRates]  
                            break                            
                if hasPorts == True:                
                    #if incrSourcePort == 0:  
                    self.FlowOptions['srcPort'] = self.trafficParams['SourcePort']
                    #if incrDestPort == 0: 
                    self.FlowOptions['destPort'] = self.trafficParams['DestinationPort']                                                                       
                    
                flowInstanceDict = OrderedDict()                                                                          
                for eachSrcClient, eachDesClient in zip(SrcClientNames, DesClientNames):   
                    if hasPorts == True:
                        Prefix = str(self.FlowOptions['srcPort']) + '_' + str(self.FlowOptions['destPort']) + '_'                                                              
                    flowInstance = WaveEngine.CreateFlows_Custom([eachSrcClient,], [eachDesClient,], 
                                                                 self.ListOfClients, False, self.FlowOptions, 
                                                                 Prefix)
                    flowInstanceDict.update(flowInstance)
                    if self.FlowOptions['Type'] == 'TCP':
                        biflowDict.update(flowInstance)
                    if hasPorts == True:
                        nextSrcPort = (int(self.FlowOptions['srcPort']) + incrSourcePort) & 0xffff
                        nextDestPort = (int(self.FlowOptions['destPort']) + incrDestPort) & 0xffff
                        if nextSrcPort == 0:
                            nextSrcPort = 1
                        if nextDestPort == 0:
                            nextDestPort = 1
                        self.FlowOptions['srcPort'] = str(nextSrcPort)
                        self.FlowOptions['destPort'] = str(nextDestPort)   
                self.HopFlowList[node] = flowInstanceDict                                                                         
            else:
                self.HopFlowList[node] = OrderedDict()

        #Put the individual hop flows into one list
        self.FlowList = OrderedDict()
        for node in self.HopFlowList.keys():
            if len(self.HopFlowList[node]) > 0:
                for eachKey in self.HopFlowList[node].keys():
                    if self.FlowOptions['Type'] != 'TCP':
                        self.ArpList[eachKey] = self.HopFlowList[node][eachKey]
                    self.FlowList[eachKey] = self.HopFlowList[node][eachKey]

        if perHop:                                    
            self._createFlowGroup(self.FlowList, "InactiveGroup")
        else:
            self._createFlowGroup(self.FlowList, "XmitGroup")
                        
        if biflowDict != {} and connectBiflow == True:
            # do biflow.connect
            if WaveEngine.ConnectBiflow(biflowDict.keys()) < 0:
                self.SavePCAPfile = True
                raise WaveEngine.RaiseException        
        self.TotalFlows = len(self.FlowList)


################################## MeshClientMap ###############################                
    class MeshClientMap(Flowable):
        _fixedWidth = 1
        _fixedHeight = 1
        # These set the graphics sizes
        _xPosPercent = [ 0.00, 0.35, 0.42, 0.58, 0.65, 1.00 ]
        _UnitHieght    = 6 
        _Height4Port   = 30
        _Height4Client = 10
        _Height4Group  =  3
        _HeightLabel   = 14

        def __init__(self, GateWayClients, HopClients, direction, CardMap, CanSplit=True, FlowPattern=Enum("up down both")):
            self.ClientGateway = GateWayClients
            self.ClientHops    = HopClients
            self.width     = defaultPageSize[0] - 2 * inch
            self.direction = direction
            self.CardMapRaw = CardMap
            self.CardMap = {}
            self.CanSplit = CanSplit
            self.FlowPattern = FlowPattern
            
            #Estimate the height of the graph
            SrcHeight = 0
            LastPortName = ''
            for gwNode in self.ClientGateway.keys():
                for (BaseName, PortName, BSSID, MAC, IPaddr, Subnet, Gateway, IncrTuple, Security, Options) in self.ClientGateway[gwNode]:
                    SrcHeight += self._Height4Group
                    if PortName != LastPortName:
                        LastPortName = PortName
                        self.CardMap[PortName] = None
                        SrcHeight += self._Height4Port
                    if len(IncrTuple) == 3:
                        if IncrTuple[0] > 4:
                            SrcHeight += self._Height4Client * 4
                        else:
                            SrcHeight += self._Height4Client * IncrTuple[0]
                    else:
                        SrcHeight += self._Height4Client
                
            DesHeight = 0
            #MaximumHops = len(self.ClientHops)
            for hop in self.ClientHops.keys():
                LastPortName = ''
                if len(self.ClientHops[hop]) > 0:
                    #Add height for Hop label
                    DesHeight += self._HeightLabel
                    
                    for (BaseName, PortName, BSSID, MAC, IPaddr, Subnet, Gateway, IncrTuple, Security, Options) in self.ClientHops[hop]:
                        DesHeight += self._Height4Group
                        if PortName != LastPortName:
                            LastPortName = PortName
                            self.CardMap[PortName] = None
                            DesHeight += self._Height4Port
                        if len(IncrTuple) == 3:
                            if IncrTuple[0] > 4:
                                DesHeight += self._Height4Client * 4
                            else:
                                DesHeight += self._Height4Client * IncrTuple[0]
                        else:
                            DesHeight += self._Height4Client
                    
            self.height = SrcHeight
            if DesHeight > self.height:
                self.height = DesHeight

            #Make Icons based on the cardmap
            icon80211      = ICON_80211()
            icon80211.size = 1.5*self._UnitHieght
            icon8023       = ICON_8023()
            icon8023.size  = 1.5*self._UnitHieght
            for key in CardMap.keys():
                #Check for telling Eth to Wifi port, too weak condition check.
                if CardMap[key][5] in ('above', 'below', 'defer'):
                    self.CardMap[key] = (str(CardMap[key][3]), icon80211)
                elif int(CardMap[key][4]) in (10, 100, 1000):
                    if str.upper(CardMap[key][3]) == 'ON':
                        self.CardMap[key] = ('AUTO', icon8023)
                    else:
                        duplex = str.upper(CardMap[key][5])
                        self.CardMap[key] = (str(CardMap[key][4])+duplex[0], icon8023)

        def _drawDebugBox(self, x, y, width, height):
            # For debugging purposes only
            self.canvas.saveState()
            self.canvas.setStrokeColorRGB(0.2,0.5,0.3)
            self.canvas.setDash(1,2)
            self.canvas.rect(x, y, width, height, stroke=1, fill=0)
            self.canvas.restoreState()

        def _DrawArrow(self, x1, y1, x2, y2, Count=0):
            self.canvas.setFillColorRGB(0,0,0)
            self.canvas.line(x1, y1, x2, y2)
            p = self.canvas.beginPath()
            if self.direction == self.FlowPattern.both or self.direction == self.FlowPattern.down:
                p.moveTo(x2, y2)
                p.lineTo(x2 - 3 , y2 + 2 )
                p.lineTo(x2 - 3 , y2 - 2 )
                p.lineTo(x2, y2)
            if self.direction == self.FlowPattern.both or self.direction == self.FlowPattern.up:
                p.moveTo(x1, y1)
                p.lineTo(x1 + 3 , y1 + 2 )
                p.lineTo(x1 + 3 , y1 - 2 )
                p.lineTo(x1, y1)
            self.canvas.drawPath(p, stroke=1, fill=1)
            if Count > 0:
                x_mid = x1 + (x2 - x1)/2.0
                y_mid = y1 + (y2 - y1)/2.0
                self.canvas.line(x_mid-5, y_mid-5, x_mid+5, y_mid+5)
                self.canvas.setFillColorRGB(0,0,0)
                self.canvas.setFont("Helvetica", 9)
                self.canvas.drawCentredString(x_mid, y_mid + 8, str(Count))
        
        def _DrawBottom(self, x1, y1, width, height1, height2):
            R,G,B = VeriwaveBlue
            self.canvas.setFillColorRGB(R,G,B)
            self.canvas.rect(x1, y1, width, height2 - y1, stroke=0, fill=1)
            self.canvas.roundRect(x1, y1 - self._UnitHieght, width, 2*self._UnitHieght, self._UnitHieght, stroke=0, fill=1)
            self.canvas.roundRect(x1, y1 - self._UnitHieght, width, height1 - y1 + self._UnitHieght, self._UnitHieght, stroke=1, fill=0)
            return self._UnitHieght*2
    
        def _DrawTop(self, x1, y1, x2, text):
            from reportlab.graphics import renderPDF
            R,G,B = VeriwaveGreen
            self.canvas.setFillColorRGB(R,G,B)
            self.canvas.roundRect(x1, y1 - 4*self._UnitHieght, x2, 4*self._UnitHieght, self._UnitHieght, stroke=0, fill=1)
            self.canvas.setFillColorRGB(0,0,0)

            _MaxStrLen = x2 - 4.0*self._UnitHieght
            textString = text
            if self._stringWidth(str(textString), "Helvetica",9) > _MaxStrLen:
                while self._stringWidth(str(textString) + "...", "Helvetica",9) > _MaxStrLen:
                    textString = textString[:-1]
                textString = textString + "..."
            self.canvas.setFont("Helvetica",9)
            self.canvas.drawString(x1 + self._UnitHieght , y1 - 2*self._UnitHieght, textString)
    
            # Add Port Icon
            if self.CardMap.has_key(text):
                (textStr, icon) = self.CardMap[text]
                self.canvas.setFont("Helvetica", 5)
                self.canvas.drawCentredString(x1 + x2 - 1.4*self._UnitHieght, y1 - 2.65*self._UnitHieght, textStr)
                d = Drawing(self._UnitHieght, self._UnitHieght)
                d.add(icon)
                renderPDF.draw(d, self.canvas, x1 + x2 - 2.2*self._UnitHieght, y1 - 1.9*self._UnitHieght, showBoundary=False)
        
            return self._UnitHieght*3

        def _stringWidth(self, text, fontName, fontSize):
            from reportlab.pdfbase.pdfmetrics import stringWidth
            SW = lambda text, fN=fontName, fS=fontSize: stringWidth(text, fN, fS)
            return SW(text)

        def _DrawText(self, x1, y1, width, text, font="Helvetica", size=9):
            strLen = self._stringWidth(str(text), font, size)
            while self._stringWidth(str(text), font, size) > width:
                text = text[:-1]
        
            self.DrawStrings.append((x1 + self._UnitHieght, y1 - 1.5*self._UnitHieght, text, font, size), ) 
            return self._Height4Client         


        def _BuildClient(self, cur_y, leftBox, RightBox, LeftArrow, RightArrow, PortName, IPaddr, IncrTuple, Security):
            IPnum = IPv4toInt(IPaddr)
            boxWidth = RightBox - leftBox
            # Print each client out
            cur_y -= self._Height4Group
            Count  = 1
            IPinc  = 0
            if len(IncrTuple) == 3:
                Count  = IncrTuple[0]
                IPinc  = IPv4toInt(IncrTuple[2])
            firstY = cur_y
            MidX = leftBox + (boxWidth / 2.0)
            if Count > 4:
                if IPnum == 0:
                    cur_y -= self._DrawText(leftBox, cur_y, boxWidth, 'DHCP')
                    cur_y -= self._DrawText(leftBox, cur_y, boxWidth, 'DHCP')
                    cur_y -= self._DrawText(leftBox, cur_y, boxWidth, " . . .")
                    cur_y -= self._DrawText(leftBox, cur_y, boxWidth, 'DHCP')
                else:
                    cur_y -= self._DrawText(leftBox, cur_y, boxWidth, int2IPv4(IPnum))
                    cur_y -= self._DrawText(leftBox, cur_y, boxWidth, int2IPv4(IPnum + IPinc))
                    cur_y -= self._DrawText(leftBox, cur_y, boxWidth, "       . . .   ")
                    cur_y -= self._DrawText(leftBox, cur_y, boxWidth, int2IPv4(IPnum + IPinc * (Count -1 )))
                lineY = cur_y + (firstY - cur_y)/2.0
                self._DrawArrow(LeftArrow, lineY, RightArrow, lineY, Count)
            else:
                for RepeatClient in range(Count):
                    self._DrawArrow(LeftArrow, cur_y - self._UnitHieght, RightArrow, cur_y - self._UnitHieght)
                    if IPnum == 0:
                        cur_y -= self._DrawText(leftBox , cur_y, boxWidth/2.0, 'DHCP')
                    else:
                        cur_y -= self._DrawText(leftBox , cur_y, boxWidth/2.0, int2IPv4(IPnum))
                    IPnum += IPinc
            MidY = (firstY + cur_y + self._Height4Client + 2.0 ) / 2.0
            if isnum(self.CardMap[PortName][0]):
                if str( Security['Method'] ).upper() == 'NONE':
                    textString = 'No security'
                else:
                    textString = Security['Method']
                self._DrawText(MidX, MidY, boxWidth/2.0 - 3, textString, size=6)
                if Count > 1:
                    self.DrawBrackets.append((MidX, firstY, cur_y),)
            return cur_y
        
        def BuildGatewayClients(self, cur_y, leftBox, RightBox, LeftArrow, RightArrow, Clients):
            topOfBox     = 0
            topOfClients = 0
            boxWidth = RightBox - leftBox
            LastPortName = ''
            if len(Clients) == 0:
                return 0
            for client in Clients.values():
                for (BaseName, PortName, BSSID, MAC, IPaddr, Subnet, Gateway, IncrTuple, Security, Options) in client:
                    IPnum = IPv4toInt(IPaddr)
                    if PortName != LastPortName:
                        if LastPortName != '':  #Draw Bottom
                            cur_y -= self._DrawBottom(leftBox, cur_y, boxWidth, topOfBox, topOfClients)
                        #Draw Top
                        topOfBox = cur_y
                        cur_y -= self._DrawTop(leftBox , cur_y, boxWidth, PortName)
                        topOfClients = cur_y
                        LastPortName = PortName
                    cur_y = self._BuildClient(cur_y, leftBox, RightBox, LeftArrow, RightArrow, PortName, IPaddr, IncrTuple, Security)
                cur_y -= self._DrawBottom(leftBox, cur_y, boxWidth, topOfBox, topOfClients)
                return cur_y
    
        def BuildHopClients(self, cur_y, leftBox, RightBox, LeftArrow, RightArrow, Clients):
            topOfBox     = 0
            topOfClients = 0
            boxWidth = RightBox - leftBox
            if len(Clients) == 0:
                return 0

            MaximumHops = len(Clients)
            for hop in Clients.keys():
                if len(Clients[hop]) > 0:
                    R,G,B = VeriwaveBlue
                    self.canvas.setFillColorRGB(R,G,B)
                    self.canvas.setFont("Helvetica",9)
                    self.canvas.drawRightString(RightBox - 1.4*self._UnitHieght, cur_y - self._HeightLabel/2.0 , "%s" % (hop))
                    cur_y -= self._HeightLabel
                    LastPortName = ''
                    
                    for (BaseName, PortName, BSSID, MAC, IPaddr, Subnet, Gateway, IncrTuple, Security, Options) in Clients[hop]:
                        if PortName != LastPortName:
                            if LastPortName != '':  #Draw Bottom
                                cur_y -= self._DrawBottom(leftBox, cur_y, boxWidth, topOfBox, topOfClients)
                            #Draw Top
                            topOfBox = cur_y
                            cur_y -= self._DrawTop(leftBox , cur_y, boxWidth, PortName)
                            topOfClients = cur_y
                            LastPortName = PortName
                        cur_y = self._BuildClient(cur_y, leftBox, RightBox, LeftArrow, RightArrow, PortName, IPaddr, IncrTuple, Security)
                    cur_y -= self._DrawBottom(leftBox, cur_y, boxWidth, topOfBox, topOfClients)
            return cur_y

        
        def drawOn(self, canv, x, y, _sW=0):
            self.canvas = canv
            #self._drawDebugBox(x, y, self.width, self.height)
            SrcLeft_x   = self._xPosPercent[0] * self.width + x
            SrcRight_x  = self._xPosPercent[1] * self.width + x
            DUTLeft_x   = self._xPosPercent[2] * self.width + x
            DUTRight_x  = self._xPosPercent[3] * self.width + x
            DesLeft_x   = self._xPosPercent[4] * self.width + x
            DesRight_x  = self._xPosPercent[5] * self.width + x
            self.DrawStrings = []
            self.DrawBrackets = []
            DUTbottom = self.BuildGatewayClients(y + self.height, SrcLeft_x, SrcRight_x, SrcRight_x, DUTLeft_x, self.ClientGateway)
            n         = self.BuildHopClients(    y + self.height, DesLeft_x, DesRight_x, DUTRight_x, DesLeft_x, self.ClientHops)
            if DUTbottom < n:
                DUTbottom = n

            # Place the DUT
            R,G,B = VeriwaveLtBlue
            widthDUT = DUTRight_x - DUTLeft_x
            self.canvas.setFillColorRGB(R,G,B)
            self.canvas.roundRect(DUTLeft_x, y, widthDUT, self.height, self._UnitHieght, stroke=1, fill=1)
            self.canvas.setFillColorRGB(0,0,0)
            self.canvas.setFont("Helvetica",12)
            self.canvas.drawCentredString(DUTLeft_x + widthDUT/2.0, y + self.height/2.0, 'SUT')

            # Print the text over the graphics
            self.canvas.setFillColorRGB(1,1,1)
            for (x1, y1, text, font, size) in self.DrawStrings:
                self.canvas.setFont(font, size)
                if y1 >= y:
                    self.canvas.drawString(x1, y1, text)
                
            self.canvas.setStrokeColorRGB(1,1,1)
            self.canvas.setLineWidth(0.5)
            _arcSize = 2.5
            for (x1, y1, y2) in self.DrawBrackets:
                y1 -= 0.5
                y2 -= 0.5
                midy = (y1 + y2) / 2.0
                pathobject = self.canvas.beginPath()
                pathobject.moveTo(x1 - _arcSize, y1)
                pathobject.arcTo (x1 - 2.0*_arcSize, y1 - 2.0*_arcSize           , x1           , y1 , startAng=90, extent=-90)
                pathobject.lineTo(x1           , midy + _arcSize)
                pathobject.arcTo (x1           , midy                , x1 + 2.0*_arcSize, midy + 2.0*_arcSize, startAng=180, extent=90)
                pathobject.arcTo (x1           , midy - 2.0*_arcSize , x1 + 2.0*_arcSize, midy , startAng=90, extent=90)
                pathobject.lineTo(x1           , y2 + _arcSize)
                pathobject.arcTo (x1 - 2.0*_arcSize, y2              , x1 , y2 + 2.0*_arcSize, startAng=0, extent=-90)
                self.canvas.drawPath(pathobject, fill=0, stroke=1)

        def wrap(self, availWidth, availHeight):
            self.width = availWidth
            return (self.width, self.height)       

        def split(self, availWidth, availHeight):
            if not self.CanSplit:
                return []
            #Only split if the image fills more than 3/4 of a page 
            if self.height < (defaultPageSize[1] - 2.35 * inch) * 0.75:
                return []

            #Do the split here
            SrcP1 = {}
            ListSrcSplits = []
            Height = 0
            LastHeight = 0
            LastPortName = ''
            for node, client in self.ClientGateway.iteritems():
                for eachLine in client:
                    (BaseName, PortName, BSSID, MAC, IPaddr, Subnet, Gateway, IncrTuple, Security, Options) = eachLine
                    Height += self._Height4Group
                    if PortName != LastPortName:
                        LastPortName = PortName
                        Height += self._Height4Port
                    if len(IncrTuple) == 3:
                        if IncrTuple[0] > 4:
                            Height += self._Height4Client * 4
                        else:
                            Height += self._Height4Client * IncrTuple[0]
                    else:
                        Height += self._Height4Client
                    if Height > availHeight:
                        ListSrcSplits.append(SrcP1)
                        SrcP1 = {}
                        SrcP1[node] = client
                        Height -= LastHeight
                        LastHeight  = 0
                        availHeight = defaultPageSize[1] - 2.35 * inch
                    else:
                        SrcP1[node] = client
                        LastHeight = Height
            ListSrcSplits.append(SrcP1)
        
            DesP1 = {}
            ListDesSplits = []
            Height = 0
            LastPortName = ''
            LastHeight = 0
            for node, client in self.ClientHops.iteritems():
                for eachLine in client:
                    (BaseName, PortName, BSSID, MAC, IPaddr, Subnet, Gateway, IncrTuple, Security, Options) = eachLine
                    Height += self._Height4Group
                    if PortName != LastPortName:
                        LastPortName = PortName
                        Height += self._Height4Port
                    if len(IncrTuple) == 3:
                        if IncrTuple[0] > 4:
                            Height += self._Height4Client * 4
                        else:
                            Height += self._Height4Client * IncrTuple[0]
                    else:
                        Height += self._Height4Client
                    if Height > availHeight:
                        ListDesSplits.append(DesP1)
                        DesP1 = {}
                        DesP1[node] = client
                        Height -= LastHeight
                        LastHeight  = 0
                        availHeight = defaultPageSize[1] - 2.35 * inch
                    else:
                        DesP1[node] = client
                        LastHeight = Height
            ListDesSplits.append(DesP1)
    
            TotalObjects = len(ListSrcSplits)
            if len(ListDesSplits) > TotalObjects:
                TotalObjects = len(ListDesSplits)

            ReturnedObjects = []
            for n in range(TotalObjects):
                SrcP1 = []
                DesP1 = []
                if n < len(ListSrcSplits):
                    SrcP1 = ListSrcSplits[n]
                if n < len(ListDesSplits):
                    DesP1 = ListDesSplits[n]
                ReturnedObjects.append( self.__class__(SrcP1, DesP1, self.direction, self.CardMapRaw, False) ) 
            return ReturnedObjects

        def getSpaceAfter(self):
           return (4/16.0) * inch
                
                