import sys, string, os
import time
from qt import *
from qttable import *
from roamprofile import *

import sys, string, os, time, thread, datetime, operator, copy

### Class containing the logic for the roaming screen
class roam(roamprofile):
    def __init__(self,parent = None,name = None,fl = 0):
        roamprofile.__init__(self,parent,name,fl)

        global selectedPortName
        global roam_dict
        global client_groups_dict
        
        self.roam_dict = dict()
        self.client_groups_dict = dict()
        self.roam_profile_num = 0
        
        self.prevValue = 0

        self.connect(self.moveSelectedToolButton,SIGNAL("released()"),self.addToPortList)  
        self.connect(self.moveAllToolButton,SIGNAL("released()"),self.addAllToPortList) 
        self.connect(self.upToolButton,SIGNAL("released()"),self.moveUpPortList) 
        self.connect(self.downToolButton,SIGNAL("released()"),self.moveDownPortList) 
        self.connect(self.deleteSelectedToolButton,SIGNAL("released()"),self.deleteSelectedPortList)
        self.connect(self.deleteAllToolButton,SIGNAL("released()"),self.deleteAllPortList)   
        self.connect(self.clientgroupListBox,SIGNAL("clicked( QListBoxItem *) "),self.loadRoamProfile) 
        self.connect(self.learningFramesGroupBox,SIGNAL("toggled(bool) "),self.updateLearnFrameFlag)  
        self.connect(self.powerProfileGroupBox,SIGNAL("toggled(bool) "),self.updateEnablePowerProfileFlag) 
        self.connect(self.timeDistButtonGroup,SIGNAL("clicked(int)"),self.updateTimeDistOption)   
        self.connect(self.clientDistButtonGroup,SIGNAL("clicked(int)"),self.updateClientDistOption)   
        self.connect(self.additionalOptionsButtonGroup,SIGNAL("clicked(int)"),self.updateAdditionalOptions)
        self.connect(self.fastRoamingButtonGroup,SIGNAL("clicked(int)"),self.updateFastRoamingOptions)      
        self.connect(self.repeatButtonGroup,SIGNAL("clicked(int)"),self.updateRepeatType)
        self.connect(self.fixedTimeSpinBox,SIGNAL("valueChanged(int)"),self.updateDwellTime)
        self.connect(self.repeatCountSpinBox,SIGNAL("valueChanged(int)"),self.updateRepeatValue)
        self.connect(self.durationSpinBox,SIGNAL("valueChanged(int)"),self.updateRepeatValue)
        self.connect(self.srcStartPrwSpinBox,SIGNAL("valueChanged(int)"),self.updateSrcStartPrwValue)
        self.connect(self.srcEndPwrSpinBox,SIGNAL("valueChanged(int)"),self.updateSrcEndPwrValue)
        self.connect(self.srcChangeStepSpinBox,SIGNAL("valueChanged(int)"),self.updateSrcChangeStepValue)
        self.connect(self.srcChangeIntSpinBox,SIGNAL("valueChanged(int)"),self.updateSrcChangeIntValue)
        self.connect(self.destStartPwrSpinBox,SIGNAL("valueChanged(int)"),self.updateDestStartPwrValue)
        self.connect(self.destEndPwrSpinBox,SIGNAL("valueChanged(int)"),self.updateDestEndPwrValue)
        self.connect(self.destChangeStepSpinBox,SIGNAL("valueChanged(int)"),self.updateDestChangeStepValue)
        self.connect(self.destChangeIntSpinBox,SIGNAL("valueChanged(int)"),self.updateDestChangeIntValue)
        self.connect(self.flowPacketSizeSpinBox,SIGNAL("valueChanged(int)"),self.updateFlowPacketSize)
        self.connect(self.flowRateSpinBox,SIGNAL("valueChanged(int)"),self.updateFlowRate)
        self.connect(self.learningPacketRateSpinBox,SIGNAL("valueChanged(int)"),self.updateLearningPacketRate)
        
        #self.connect(self.learningPacketCountSpinBox,SIGNAL("valueChanged(int)"),self.updateLearningPacketCount)      
        #self.connect(self.learningPacketSizeSpinBox,SIGNAL("valueChanged(int)"),self.updateLearningPacketSize)
        
        self.connect(self.learnDestIpComboBox,SIGNAL("textChanged(const QString &)"),self.updateLearningIpAddress)     
        self.connect(self.learnDestMacComboBox,SIGNAL("textChanged(const QString &)"),self.updateLearningMacAddress)     
        
        
        self.connect(self.applyPushButton,SIGNAL("released()"),self.generateRoamSchedule)
        self.connect(self.availablePortListView,SIGNAL("clicked(QListViewItem *)"),self.enableSelectButton)
        self.connect(self.roamProfileTabWidget,SIGNAL("currentChanged (QWidget *)"),self.updateScheduleCheck)
        self.connect(self.timeUnitComboBox,SIGNAL("activated(int)"),self.updateDurationUnits)   
        
        
        
        self.roamStepsTable.setReadOnly(1)
        self.numRoamsLineEdit.setReadOnly(1)
        self.avgRoamsLineEdit.setReadOnly(1)
        self.numClientsLineEdit.setReadOnly(1)
        self.roamStepsTable.setColumnWidth(0,100)
        self.roamStepsTable.setColumnWidth(1,195)
        self.roamStepsTable.setColumnWidth(2,195)
        self.roamStepsTable.setColumnWidth(3,110)    
        
        macExp = QRegExp("[0-f]{2,2}[:][0-f]{2,2}[:][0-f]{2,2}[:][0-f]{2,2}[:][0-f]{2,2}[:][0-f]{2,2}")
        macValid = QRegExpValidator(macExp, parent, "macvalidator" )
        self.learnDestMacComboBox.setValidator(macValid)
        
        ipExp = QRegExp("((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[0-9]{2}|[0-9]{0,1})[\\.\\x20]){3}(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])")
        ipValid = QRegExpValidator(ipExp, parent, "ipvalidator" )
        self.learnDestIpComboBox.setValidator(ipValid)
        
        #self.learnDestIpComboBox.setCurrentText("239.255.255.250")        
        #self.learnDestMacComboBox.setCurrentText("01:00:5e:7f:ff:fa") 
        #We no more use the learnDestIP, learnDestMacaddress. Hide them until we do the clean up of
        #the learning frames (Client & Flow learning)
        self.textLabel4.hide()
        self.textLabel6.hide()
        self.learnDestIpComboBox.hide()
        self.learnDestMacComboBox.hide()

        #Hide Custome Dwell time options which we don't currently support
        self.customDwellOptionsGroupBox.hide()
        self.customDwellTimeRadioButton.hide()
        
    ### Form the port scan dictionary get all the unique ssid values and display them in the SSID combo box
    def setPortList(self, portDict):
        global wifiPortDict
        self.wifiPortDict = portDict 
              
                   
    ### When the user clicks on a group in the List, the groups SSID is retrived and this procedure 
    #finds all the Port, BSSID pairs with this SSID and populates them in the available port list 
    #box as a tree of ports and BSSIDs    
    def selectPortsPerSsid(self, ssid_text):  
        global roam_dict
        global client_groups_dict
        
        currentGroupName = str(self.clientgroupListBox.currentText())
        
        if currentGroupName == "":
            return  
                    
        self.roam_dict[currentGroupName]['ssid'] = str(ssid_text)
                  
        self.availablePortListView.clear()
        self.selectedPortList.clear()  
        
        portsBssids = self._getPortsBssids(ssid_text)
        
        selectedGroupPortList = portsBssids.keys()

        for ports in selectedGroupPortList:
            self.availablePortListViewItem = QListViewItem(self.availablePortListView)
            self.availablePortListViewItem.setText(0,ports)
            self.availablePortListViewItem.setOpen(1)
            for bssids in portsBssids[ports]:
                self.availablePortListViewSubItem = QListViewItem(self.availablePortListViewItem)
                self.availablePortListViewSubItem.setText(0,bssids)
        if self.availablePortListView.childCount() != 0:
            self.moveAllToolButton.setEnabled(1)
            self.moveSelectedToolButton.setEnabled(1)
        else:
            self.moveAllToolButton.setEnabled(0)
            self.moveSelectedToolButton.setEnabled(0)
    
    def _getPortsBssids(self, ssid):
        """
        Given a network (SSID), give the dictionary of port mapping to the list of BSSIDs
        which are on that network
        """
        portsBssids = {}
        for ports in self.wifiPortDict:
            for bssids in self.wifiPortDict[ports]:
                  if self.wifiPortDict[ports][bssids] == ssid:
                       if portsBssids.has_key(ports):
                           portsBssids[ports].append(bssids)
                       else:
                           portsBssids[ports] = [bssids]
        return portsBssids
    
    def populateRoamSequence(self, currentGroupName):
        self.selectedPortList.clear()
        ssidTxt = self.roam_dict[currentGroupName]['ssid']
        portList = self.roam_dict[currentGroupName]['portNameList']
        bssidList = self.roam_dict[currentGroupName]['bssidList']
        portsBssids = self._getPortsBssids(ssidTxt)
        removeList = []
        for ii in range(len(portList)):
            removeItemF = False
            prt = portList[ii]
            bssid = bssidList[ii]
            if (prt in portsBssids) and (bssid in portsBssids[prt]):
                dispItem = "{" + prt + ", " +  bssid + "}"
                self.selectedPortList.insertItem(dispItem)
            else:    #If they are not valid entries change the values in the loaded wml
                removeList.append(ii)
        
        #There could be cases when the entries present in the 'Selected Roam Sequence' box
        #are no more valid (e.g., load a wml file whose config is around a chassis 'X', 
        #in ports page change the chassis to a different chassis, goto clients page, make
        #necessary changes to reflect proper port, SSID. Goto test page, available port
        #list is properly populated but 'selected roam sequence' entries are based on  
        #those from the wml file initially loaded), in which case clear those entries.
        if removeList:
            newPrtList = []
            newBssidList = []
            for i, prtName in enumerate(portList):
                if i not in removeList:
                    newPrtList = portList[i]
                    newBssidList = bssidList[i]
            self.roam_dict[currentGroupName]['portNameList'] =  newPrtList
            self.roam_dict[currentGroupName]['bssidList'] = newBssidList  
            
    ### This prodecure adds a selected entry from the available port list to the Selected roam sequence
    ### Also makes sure that two consecutive networks in the list are not the same.Also update the roam_dict                    
    def addToPortList(self):
        global roam_dict    
        currentGroupName = str(self.clientgroupListBox.currentText())
        
        if currentGroupName == "" or self.availablePortListView.selectedItem() == None:
            return  
        
        portName = str(self.availablePortListView.selectedItem().parent().text(0))
        bssidName = str(self.availablePortListView.selectedItem().text(0))
        
        selectStr = "{" + portName + ", " + bssidName + "}"
        
        if str(self.selectedPortList.text(self.selectedPortList.numRows()-1)) != selectStr:
            self.roam_dict[currentGroupName]['portNameList'].append(portName)
            self.roam_dict[currentGroupName]['bssidList'].append(bssidName)    
            self.selectedPortList.insertItem(selectStr)
        else:
            QMessageBox.warning(self, "Warning", "Cannot Roam to the Same Network", QMessageBox.Ok)
               
    ### This prodecure adds all entries from the available port list to the Selected roam sequence
    ### Also makes sure that two consecutive networks in the list are not the same.Also update the roam_dict          
    def addAllToPortList(self):
        global wifiPortDict
        global roam_dict    
        currentGroupName = str(self.clientgroupListBox.currentText())
        
        if currentGroupName == "":
            return  
        
        if self.availablePortListView.childCount() == 0:
            QMessageBox.warning(self, "Warning", "No Ports Available to Select", QMessageBox.Ok) 
            return
        
        for ports in self.wifiPortDict.keys():
            for bssids in self.wifiPortDict[ports].keys():
                if self.wifiPortDict[ports][bssids] == \
                self.roam_dict[str(self.clientgroupListBox.currentText())]['ssid']:
                    selectStr = "{" + ports + ", " + bssids + "}"
                    if str(self.selectedPortList.text(self.selectedPortList.numRows()-1)) != selectStr:
                        self.roam_dict[currentGroupName]['portNameList'].append(ports)
                        self.roam_dict[currentGroupName]['bssidList'].append(bssids)   
                        self.selectedPortList.insertItem(selectStr)
                    else:
                        QMessageBox.warning(self, "Warning", "Cannot Roam to the Same Network", QMessageBox.Ok)
                        return
        
    ### Move an Entry one step up in the list and update the roam_dict           
    def moveUpPortList(self):
        global roam_dict  
        currentGroupName = str(self.clientgroupListBox.currentText())
        
        if currentGroupName == "":
            return  
             
        tempSelPortList = []
        for ii in range(0,self.selectedPortList.numRows()):
            tempSelPortList.append(str(self.selectedPortList.text(ii)))
            
        if self.selectedPortList.currentItem() != self.selectedPortList.topItem():
            foo = self.selectedPortList.currentText()
            foo_index = self.selectedPortList.currentItem()
            self.selectedPortList.removeItem(foo_index)
            self.selectedPortList.insertItem(foo,foo_index-1)
            self.selectedPortList.setSelected(foo_index-1, True)
        else:
            return
        
        if self.checkListForInvalidOrder(tempSelPortList) == -1:
            return
    
        self.roam_dict[currentGroupName]['portNameList'][foo_index-1], self.roam_dict[currentGroupName]['portNameList'][foo_index]\
         = self.roam_dict[currentGroupName]['portNameList'][foo_index], self.roam_dict[currentGroupName]['portNameList'][foo_index-1]
        self.roam_dict[currentGroupName]['bssidList'][foo_index-1], self.roam_dict[currentGroupName]['bssidList'][foo_index]\
         = self.roam_dict[currentGroupName]['bssidList'][foo_index], self.roam_dict[currentGroupName]['bssidList'][foo_index-1]
       
           
    ### Move an Entry one step below in the list and update the roam_dict  
    def moveDownPortList(self):
        global roam_dict    
        currentGroupName = str(self.clientgroupListBox.currentText())  
        
        if currentGroupName == "":
            return  
            
        tempSelPortList = []
        for ii in range(0,self.selectedPortList.numRows()):
            tempSelPortList.append(str(self.selectedPortList.text(ii)))
                
        if self.selectedPortList.currentItem() != (self.selectedPortList.numRows()-1):
            foo = self.selectedPortList.currentText()
            foo_index = self.selectedPortList.currentItem()
            self.selectedPortList.removeItem(foo_index)
            self.selectedPortList.insertItem(foo,foo_index+1)
            self.selectedPortList.setSelected(foo_index+1, True)
        else:
            return
            
        if self.checkListForInvalidOrder(tempSelPortList) == -1:
            return
    
        self.roam_dict[currentGroupName]['portNameList'][foo_index], self.roam_dict[currentGroupName]['portNameList'][foo_index+1]\
          = self.roam_dict[currentGroupName]['portNameList'][foo_index+1], self.roam_dict[currentGroupName]['portNameList'][foo_index]
        self.roam_dict[currentGroupName]['bssidList'][foo_index], self.roam_dict[currentGroupName]['bssidList'][foo_index+1]\
         = self.roam_dict[currentGroupName]['bssidList'][foo_index+1], self.roam_dict[currentGroupName]['bssidList'][foo_index]
           
        
    ###Procedure to check if two consecutive networks in the list are the same. If so return -1     
    def checkListForInvalidOrder(self, tempSelPortList):
        
        for ii in range(0,(self.selectedPortList.numRows()-1)):
            if str(self.selectedPortList.text(ii)) == str(self.selectedPortList.text(ii+1)):
                QMessageBox.warning(self, "Warning", "Cannot Roam to the Same Network", QMessageBox.Ok)
                self.selectedPortList.clear()
                self.selectedPortList.insertStrList(tempSelPortList, -1) 
                return -1  
    
    ### This prodecure deletes a selected entry from the available port list to the Selected roam sequence
    ### Also makes sure that two consecutive networks in the list are not the same.Also update the roam_dict        
    def deleteSelectedPortList(self):
        global roam_dict    
        currentGroupName = str(self.clientgroupListBox.currentText())
        
        if currentGroupName == "":
            return  
        
        if self.selectedPortList.numRows() == 0:
            return
        
        currPortList = self.roam_dict[currentGroupName]['portNameList'] 
        currBssidList = self.roam_dict[currentGroupName]['bssidList'] 
        
        finalPortList = []
        finalBssidList = []
        
        tempSelPortList = []
        for ii in range(0,self.selectedPortList.numRows()):
            tempSelPortList.append(str(self.selectedPortList.text(ii)))
        
        for ii in range(len(currPortList)):
            if ii != int(self.selectedPortList.currentItem()):
                finalPortList.append(currPortList[ii])
                finalBssidList.append(currBssidList[ii])
         
        self.selectedPortList.removeItem(self.selectedPortList.currentItem())
        
        if self.checkListForInvalidOrder(tempSelPortList) == -1:
            return
        
        
        self.roam_dict[currentGroupName]['portNameList'] = finalPortList
        self.roam_dict[currentGroupName]['bssidList'] = finalBssidList
                        
        
    ### This prodecure deletes all selected entries from the available port list to the Selected roam sequence    
    def deleteAllPortList(self):
        global roam_dict    
        currentGroupName = str(self.clientgroupListBox.currentText())
        
        if currentGroupName == "":
            return  
        
        if self.selectedPortList.numRows() == 0:
            return
        
        self.selectedPortList.clear()
        self.roam_dict[currentGroupName]['portNameList'] = []
        self.roam_dict[currentGroupName]['bssidList'] = []
        
    ### Create a default roam profile for all the client group in the test.
    def createDefaultRoamProfile(self, roamClientGroups):
        global client_groups_dict
        global client_group_names
        global client_group_nums_dict
        global roam_dict
        
              
        self.client_groups_dict = roamClientGroups
        clnt_grps = roamClientGroups.copy()        
        eth_client_group_names = []
               
        for grpNames in clnt_grps.keys():
            if clnt_grps[grpNames]['Interface'] == "802.3 Ethernet":
                eth_client_group_names.append(grpNames)
                del clnt_grps[grpNames]
        
        self.client_group_nums_dict = dict()
        self.client_group_names = clnt_grps.keys()  
        
        for clName in  self.client_group_names:
                self.client_group_nums_dict[clName] = int(clnt_grps[clName]['NumClients'])
                
        for eth_client_group in eth_client_group_names:
            if str(self.clientgroupListBox.findItem(eth_client_group)) != "None":
                self.clientgroupListBox.takeItem(self.clientgroupListBox.findItem(eth_client_group))
                del self.roam_dict[eth_client_group]
        #VPR 5258
        for clientGroupName in self.roam_dict.keys():
            if clientGroupName not in self.client_group_names:
                del self.roam_dict[clientGroupName]
        #We delete items in the list we are iterating through, so using normal for loop 
        #wouldn't work properly                
        ii = 0        
        while self.clientgroupListBox.numRows() > 0 and ii < self.clientgroupListBox.numRows():
            if self.clientgroupListBox.text(ii) not in self.client_group_names:
                self.clientgroupListBox.removeItem(ii)  
            else:
                ii += 1
        
        for clientGroupName in self.client_group_names:
            if clientGroupName not in self.roam_dict:
                self.roam_dict[clientGroupName] = {}
            self.roam_dict[clientGroupName]['ssid'] =  clnt_grps[clientGroupName]['Ssid']
            if str(self.clientgroupListBox.findItem(clientGroupName)) == "None" or \
            not self.roam_dict.has_key(clientGroupName):                        #VPR 4765
                if str(self.clientgroupListBox.findItem(clientGroupName)) == "None":
                    self.clientgroupListBox.insertItem(clientGroupName,-1) 
                        
                roam_profile = dict()
                port_name_list = []
                bssid_list = []
                roam_profile['portNameList']= port_name_list
                roam_profile['bssidList']= bssid_list
                roam_profile['clientDistOption'] = 1
                roam_profile['timeDistOption'] = 1
                roam_profile['dwellTimeOption'] = 1
                roam_profile['dwellTime'] = 1
                roam_profile['powerProfileFlag'] = 0
                roam_profile['srcStartPwr'] = -6
                roam_profile['srcEndPwr'] = -20
                roam_profile['srcChangeStep'] = 1
                roam_profile['srcChangeInt'] = 1000
                roam_profile['destStartPwr'] = -6
                roam_profile['destEndPwr'] = -40
                roam_profile['destChangeStep'] = 2
                roam_profile['destChangeInt'] = 1000
                roam_profile['disassociate'] = 0
                roam_profile['deauth'] = 0
                roam_profile['reassoc'] = 0
                roam_profile['renewDHCP'] = 0
                roam_profile['renewDHCPonConn'] = 0
                roam_profile['pmkid'] = 0
                roam_profile['preauth'] = 0
                roam_profile['flowPacketSize'] = 256
                roam_profile['flowRate'] = 100
                roam_profile['learningFlowFlag'] = 1
                roam_profile['learningDestIp'] = "239.255.255.250"
                roam_profile['learningPacketRate'] = 100
                roam_profile['learningDestMac'] = "01:00:5e:7f:ff:fa"
                roam_profile['repeatType'] = 1
                roam_profile['repeatValue'] = 0
                roam_profile['durationUnits'] = 0

                for key in roam_profile:
                    if not self.roam_dict[clientGroupName].has_key(key):
                        self.roam_dict[clientGroupName][key] = roam_profile[key]

        if self.clientgroupListBox.count() > 0:
            self.clientgroupListBox.setSelected(self.clientgroupListBox.topItem(), True)
            self.loadRoamProfile()     
        else:
            self.availablePortListView.clear()
            self.selectedPortList.clear()
        
        
    ### When clicked on any group name, this procedure loads the roam profile for that group from the roam_dict
    ### and populates the widgets.        
    def loadRoamProfile(self):
        global roam_dict
        global ssidList
                
        currentGroupName = str(self.clientgroupListBox.currentText())
        if currentGroupName == '':
            return
                    
        
        self.availablePortListView.clear()
        ssidTxt = self.roam_dict[currentGroupName]['ssid']
        self.selectPortsPerSsid(ssidTxt)

        self.populateRoamSequence(currentGroupName)
    
        if self.roam_dict[currentGroupName]['clientDistOption'] == 1:
            self.clientDistRadio1.setChecked(1)
        else:
            self.clientDistRadio2.setChecked(1)
        
        if self.roam_dict[currentGroupName]['timeDistOption'] == 1:
            self.timeDistRadio1.setChecked(1)
        else:
            self.timeDistRadio2.setChecked(1)
     
        if self.roam_dict[currentGroupName]['dwellTimeOption'] == 1:
            self.fixedDwellTimeRadioButton.setChecked(1)
        
        self.fixedTimeSpinBox.setValue(self.roam_dict[currentGroupName]['dwellTime'])
        self.powerProfileGroupBox.setChecked(self.roam_dict[currentGroupName]['powerProfileFlag'])
        self.srcStartPrwSpinBox.setValue(self.roam_dict[currentGroupName]['srcStartPwr'])
        self.srcEndPwrSpinBox.setValue(self.roam_dict[currentGroupName]['srcEndPwr'])
        self.srcChangeStepSpinBox.setValue(self.roam_dict[currentGroupName]['srcChangeStep'])
        self.srcChangeIntSpinBox.setValue(self.roam_dict[currentGroupName]['srcChangeInt'])
        self.destStartPwrSpinBox.setValue(self.roam_dict[currentGroupName]['destStartPwr'])
        self.destEndPwrSpinBox.setValue(self.roam_dict[currentGroupName]['destEndPwr'])
        self.destChangeStepSpinBox.setValue(self.roam_dict[currentGroupName]['destChangeStep'])
        self.destChangeIntSpinBox.setValue(self.roam_dict[currentGroupName]['destChangeInt'])
        self.disassociateCheckBox.setChecked(self.roam_dict[currentGroupName]['disassociate'])
        self.deauthCheckBox.setChecked(self.roam_dict[currentGroupName]['deauth'])
        self.reassocCheckBox.setChecked(self.roam_dict[currentGroupName]['reassoc'])
        renewDHCP = self.roam_dict[currentGroupName].get('renewDHCP', 0)    #For backward compatibility with existing wml files
        self.renewDhcpCheckBox.setChecked(renewDHCP)    
        renewDHCPonConn = self.roam_dict[currentGroupName].get('renewDHCPonConn', 0)    #For backward compatibility with existing wml files
        self.renewDhcpOnConnCheckBox.setChecked(renewDHCPonConn)
        self.pmkidCheckBox.setChecked(self.roam_dict[currentGroupName]['pmkid'])
        self.preauthCheckBox.setChecked(self.roam_dict[currentGroupName]['preauth'])
        self.flowPacketSizeSpinBox.setValue(self.roam_dict[currentGroupName]['flowPacketSize']) 
        self.flowRateSpinBox.setValue(self.roam_dict[currentGroupName]['flowRate'])
        self.learningFramesGroupBox.setChecked(self.roam_dict[currentGroupName]['learningFlowFlag'])
        self.learningPacketRateSpinBox.setValue(self.roam_dict[currentGroupName]['learningPacketRate'])       
        
        #self.learningPacketCountSpinBox.setValue(self.roam_dict[currentGroupName]['learningPacketCount'])        
        #self.learningPacketSizeSpinBox.setValue(self.roam_dict[currentGroupName]['learningPacketSize'])        
        
        #quick, bad fix for 4193. What do we do when we add new entries in GUI and load an 
        #old wml file which does not have those configs? These if-else aint pretty.
        if 'learningDestIp' not in self.roam_dict[currentGroupName].keys():
            self.roam_dict[currentGroupName]['learningDestIp'] = "239.255.255.250"
            self.learnDestIpComboBox.setCurrentText("239.255.255.250")        
        else:
            self.learnDestIpComboBox.setCurrentText(self.roam_dict[currentGroupName]['learningDestIp'])        
        if 'learningDestMac' not in self.roam_dict[currentGroupName].keys():
            self.roam_dict[currentGroupName]['learningDestMac'] = "01:00:5e:7f:ff:fa"
            self.learnDestMacComboBox.setCurrentText("01:00:5e:7f:ff:fa") 
        else:
            self.learnDestMacComboBox.setCurrentText(self.roam_dict[currentGroupName]['learningDestMac']) 
        
        
                
        if self.roam_dict[currentGroupName]['repeatType'] == 1:
            self.repeatCountRadioButton.setChecked(1)
            self.durationSpinBox.setEnabled(0)  
            self.timeUnitComboBox.setEnabled(0)          
            self.repeatCountSpinBox.setEnabled(1)
            self.repeatCountSpinBox.setValue(self.roam_dict[currentGroupName]['repeatValue'])
            
        else:
            self.durationRadioButton.setChecked(1)
            self.durationSpinBox.setEnabled(1)
            self.timeUnitComboBox.setEnabled(1)
            self.repeatCountSpinBox.setEnabled(0)
            self.durationSpinBox.setValue(self.roam_dict[currentGroupName]['repeatValue'])
            self.timeUnitComboBox.setCurrentItem(self.roam_dict[currentGroupName]['durationUnits'])
        
        print self.roam_dict 
        
    ### Update the TimeDistOption
    def updateTimeDistOption(self, val):
        global roam_dict    
        currentGroupName = str(self.clientgroupListBox.currentText())
        
        if currentGroupName == "":
            return  
        
        if val == 1:
            self.roam_dict[currentGroupName]['timeDistOption'] = 1
        if val == 2:
            self.roam_dict[currentGroupName]['timeDistOption'] = 2
        
    ### Update the ClientDistOption  
    def updateClientDistOption(self, val):
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())
        
        if currentGroupName == "":
            return  
        
        if val == 1:
            self.roam_dict[currentGroupName]['clientDistOption'] = 1
        if val == 2:
            self.roam_dict[currentGroupName]['clientDistOption'] = 2        
        
    def updateAdditionalOptions(self, val):
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())
        
        if currentGroupName == "":
            return  
        
        if val == 1:
            self.roam_dict[currentGroupName]['disassociate'] = int(self.disassociateCheckBox.isChecked())
        if val == 2:
            self.roam_dict[currentGroupName]['deauth'] = int(self.deauthCheckBox.isChecked())
        if val == 3:
            self.roam_dict[currentGroupName]['reassoc'] = int(self.reassocCheckBox.isChecked())        
        if val == 4:
            self.roam_dict[currentGroupName]['renewDHCP'] = int(self.renewDhcpCheckBox.isChecked())       
        if val == 5:
            self.roam_dict[currentGroupName]['renewDHCPonConn'] = int(self.renewDhcpOnConnCheckBox.isChecked())
            
    def updateFastRoamingOptions(self, val):         
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())
        
        if currentGroupName == "":
            return  
        
        if val == 0:
            self.roam_dict[currentGroupName]['pmkid'] = int(self.pmkidCheckBox.isChecked())
        if val == 1:
            self.roam_dict[currentGroupName]['preauth'] = int(self.preauthCheckBox.isChecked())      
    
    
    def updateRepeatType(self, val):
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())
        
        if currentGroupName == "":
            return  
        
        if val == 1:
            self.roam_dict[currentGroupName]['repeatType'] = 1
            self.roam_dict[currentGroupName]['repeatValue'] = self.repeatCountSpinBox.value()
            self.durationSpinBox.setEnabled(0)
            self.timeUnitComboBox.setEnabled(0)
            self.repeatCountSpinBox.setEnabled(1)
        if val == 2:
            self.roam_dict[currentGroupName]['repeatType'] = 2           
            self.roam_dict[currentGroupName]['repeatValue'] = self.durationSpinBox.value()
            self.durationSpinBox.setEnabled(1)
            self.timeUnitComboBox.setEnabled(1)
            self.repeatCountSpinBox.setEnabled(0)
    
        
    def updateRepeatValue(self, val):
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())
        if currentGroupName == "":
            return            
                   
        if self.durationRadioButton.isOn() == True:
            self.roam_dict[currentGroupName]['repeatValue'] = self.durationSpinBox.value()  
                         
        if self.repeatCountRadioButton.isOn() == True:
            self.roam_dict[currentGroupName]['repeatValue'] = self.repeatCountSpinBox.value()  
                      
     
    def updateDurationUnits(self,val):
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())
        if currentGroupName == "":
            return 
    
        self.roam_dict[currentGroupName]['durationUnits'] = val        
        self.roam_dict[currentGroupName]['repeatValue'] = self.durationSpinBox.value()
        
           
    def updateDwellTime(self, val):
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())
        
        if currentGroupName == "":
            return  
            
        self.roam_dict[currentGroupName]['dwellTime'] = val
    
        
    def updateSrcStartPrwValue(self, val): 
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())
        if currentGroupName == "":
            return  
            
        self.roam_dict[currentGroupName]['srcStartPwr'] = val
        
                
    def updateSrcEndPwrValue(self, val): 
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())
        if currentGroupName == "":
            return  
            
        self.roam_dict[currentGroupName]['srcEndPwr'] = val
        
                    
    def updateSrcChangeStepValue(self, val):
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())
        if currentGroupName == "":
            return  
            
        self.roam_dict[currentGroupName]['srcChangeStep'] = val
        
             
    def updateSrcChangeIntValue(self, val):
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())
        if currentGroupName == "":
            return  
            
        self.roam_dict[currentGroupName]['srcChangeInt'] = val
        
               
    def updateDestStartPwrValue(self, val):  
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())
        if currentGroupName == "":
            return  
            
        self.roam_dict[currentGroupName]['destStartPwr'] = val
        
            
    def updateDestEndPwrValue(self, val):
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())
        if currentGroupName == "":
            return  
            
        self.roam_dict[currentGroupName]['destEndPwr'] = val
        
                   
    def updateDestChangeStepValue(self, val): 
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())
        if currentGroupName == "":
            return  
            
        self.roam_dict[currentGroupName]['destChangeStep'] = val
                
          
    def updateDestChangeIntValue(self, val):
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())
        if currentGroupName == "":
            return  
            
        self.roam_dict[currentGroupName]['destChangeInt'] = val
          
    
    def updateFlowPacketSize(self, val):
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())
        if currentGroupName == "":
            return  
            
        self.roam_dict[currentGroupName]['flowPacketSize'] = val
        
                          
    def updateFlowRate(self, val):        
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())
        if currentGroupName == "":
            return  
            
        self.roam_dict[currentGroupName]['flowRate'] = val
        
    
    def updateLearningPacketRate(self, val): 
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())
        if currentGroupName == "":
            return  
            
        self.roam_dict[currentGroupName]['learningPacketRate'] = val
        
                       
    def updateLearningIpAddress(self, val): 
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())   
        if currentGroupName == "":
            return  
            
        self.roam_dict[currentGroupName]['learningDestIp'] = str(val)
        
    def updateLearningMacAddress(self, val):  
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())
        if currentGroupName == "":
            return  
            
        self.roam_dict[currentGroupName]['learningDestMac'] = str(val)
    
                                                
    def updateLearnFrameFlag(self, val):
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText())
        if currentGroupName == "":
            return  
        
        self.roam_dict[currentGroupName]['learningFlowFlag'] = val
              
        
    def updateEnablePowerProfileFlag(self, val):
        global roam_dict
        currentGroupName = str(self.clientgroupListBox.currentText()) 
        if currentGroupName == "":
            return  
        
        self.roam_dict[currentGroupName]['powerProfileFlag'] = val
       
   
    def updateScheduleCheck(self, val):
        if self.roamProfileTabWidget.currentPageIndex() == 1:
            if self.autoUpdateCheckBox.isChecked() == True:
                self.generateRoamSchedule()
    
    
    def enableSelectButton(self, item):
        if str(item) != "None":        
            if str(item.parent()) != "None":
                self.moveSelectedToolButton.setEnabled(1)
            else:
                self.moveSelectedToolButton.setEnabled(0)
        
    ### Generates the roam schedule in absolute time from the roam profile and displays it on the GUI
    def generateRoamSchedule(self):
        global roam_dict
        global client_group_nums_dict
        
        currentGroupName = str(self.clientgroupListBox.currentText()) 
        if currentGroupName == "":
            return 
            
        roamList =[]
        
        numClients = self.client_group_nums_dict[currentGroupName]
        portList = self.roam_dict[currentGroupName]['portNameList']
        bssidList = self.roam_dict[currentGroupName]['bssidList']
        clientDistFlag = self.roam_dict[currentGroupName]['clientDistOption']
        timeDistFlag = self.roam_dict[currentGroupName]['timeDistOption'] 
        dwellTime = self.roam_dict[currentGroupName]['dwellTime'] 
        repeatType = self.roam_dict[currentGroupName]['repeatType'] 
        repeatVal = self.roam_dict[currentGroupName]['repeatValue']        
        repeatUnits = self.roam_dict[currentGroupName]['durationUnits']
        
                       
        dispRoamList = []
        
        for ii in range(len(portList)):
            roamStr = "{" + portList[ii] + "," + bssidList[ii] + "}"
            roamList.append((roamStr, dwellTime))
                
        #### Case#1 and 2 ########
        if clientDistFlag == 1:
            if timeDistFlag == 1:
                for i in range(numClients):
                    test_time = 0.0
                    total_test_time = 0.0
                    if repeatType == 2:
                        total_test_time = repeatVal
                        
                    elif repeatType == 1:
                        Iterationtime = 0
                        for j in range(len(roamList)):
                            (port, time) = roamList[j]
                            Iterationtime += time
                        total_test_time = Iterationtime * (repeatVal+1)
                    
                    clientName = currentGroupName + '_' + 'Client' + str(i + 1).zfill(3)
                    roamindx = 0
                    
                    while test_time < total_test_time:
                        (port, time) = roamList[roamindx]
                        time = abs(time) #no -ve dwell time
                        timeleft = total_test_time - test_time
                        tmproamlist = (clientName, port, time)
                        if timeleft < time:
                            tmproamlist = (clientName, port, timeleft)
                                               
                        dispRoamList.append( tmproamlist )
                        test_time += time
                        roamindx += 1
                        if roamindx == len(roamList):
                           roamindx = 0
             
        
            if timeDistFlag == 2:
                if (1):
                    (port, config_dwell_time) = roamList[0]
                    if repeatType == 2:
                        if config_dwell_time > repeatVal:
                            config_dwell_time = repeatVal
                    max_roam_delay = 0.100 
                    delta = ((abs(config_dwell_time) - max_roam_delay) / numClients)
                    for i in range(numClients):
                        firstroundF = True; roamindx = 0
                        total_test_time = 0.0
                        if repeatType == 2:
                            total_test_time = repeatVal
                        elif repeatType == 1:
                            total_test_time = ((delta + (i * delta) + config_dwell_time * (len(roamList) - 1)) +
                                (config_dwell_time * len(roamList) *repeatVal))
                        curr_tot_time = 0; dwell_time = delta + (i * delta)
                        while curr_tot_time < total_test_time:
                            (port, time) = roamList[roamindx]
                            clientName = currentGroupName + '_' + 'Client' + str(i + 1).zfill(3)
                            dwell_time_str = str("%0.3f" % dwell_time)
                            tmproamlist = (clientName, port, dwell_time_str)
                            
                            dispRoamList.append(tmproamlist)
                            roamindx += 1
                            if roamindx == len(roamList):
                                roamindx = 0
                            curr_tot_time += dwell_time
                            if firstroundF == True:
                                dwell_time = config_dwell_time
                                firstroundF = False
                            if ((total_test_time - curr_tot_time) 
                                    < config_dwell_time):
                                dwell_time = total_test_time - curr_tot_time 
                            
        
        #### Case#3 and 4 ########
        if clientDistFlag == 2:
            if timeDistFlag == 1:
                Indx = 0
                for i in range(numClients):
                    clientName = currentGroupName + '_' + 'Client' + str(i+1).zfill(3)
                    roamindx = Indx
                    stopF = False
                    curr_tot_time = 0; 
                    total_test_time = 0.0
                    if repeatType == 2:
                        total_test_time = repeatVal
                    elif repeatType == 1:
                        Iterationtime = 0
                        for j in range(len(roamList)):
                            (port, time) = roamList[j]
                            Iterationtime += time
                        total_test_time = Iterationtime * (repeatVal+1)
                    while curr_tot_time < total_test_time:
                        (port, dwell_time) = roamList[roamindx]
                        dwell_time = abs(dwell_time)
                        timeleft = total_test_time - curr_tot_time
                        if timeleft < dwell_time:
                            dwell_time = timeleft
                        if stopF == True:
                            dwell_time = next_dwell_time
                            
                        dwell_time_str = str("%0.3f" % dwell_time)
                        tmproamlist = (clientName, port, dwell_time_str)
                        dispRoamList.append(tmproamlist)
                        
                        roamindx += 1
                        if roamindx == len(roamList):
                            roamindx = 0
                            
                        curr_tot_time += dwell_time
                        (port, next_dwell_time) = roamList[roamindx]
                        if ((total_test_time - curr_tot_time) 
                                < next_dwell_time):
                            next_dwell_time = total_test_time - curr_tot_time
                            stopF = True
                    Indx += 1
                    if Indx == len(roamList):
                        Indx = 0
                    
            if timeDistFlag == 2:
                Indx = 0
                portlist = []
                for i in range(numClients):
                    indx = Indx
                    tmproamlist = []
                    for j in range(len(roamList)):
                        tmproamlist.append(roamList[indx])
                        indx += 1
                        if indx == len(roamList):
                            indx = 0
                    Indx += 1
                    if Indx == len(roamList):
                        Indx = 0
                    portlist.append(tmproamlist)   
               
                (port, config_dwell_time) = roamList[0]
                
                if repeatType == 2:
                    if config_dwell_time > repeatVal:
                        config_dwell_time = repeatVal
                max_roam_delay = 0.100 
                delta = ((abs(config_dwell_time) - max_roam_delay) / numClients)
                
                for i in range(numClients):
                    firstroundF = True; roamindx = 0
                    total_test_time = 0.0
                    if repeatType == 2:
                        total_test_time = repeatVal
                    elif repeatType == 1:
                        total_test_time = ((delta + (i * delta) + 
                            config_dwell_time * (len(roamList) - 1)) +
                            (config_dwell_time * len(roamList) * repeatVal))
                    curr_tot_time = 0; dwell_time = delta + (i * delta)
                    clientportlist = portlist[i]
                    while curr_tot_time < total_test_time:
                        (port, time) = clientportlist[roamindx]
                        
                        clientName = currentGroupName + '_' + 'Client' + str(i+1).zfill(3)
                                                
                        dwell_time_str = str("%0.3f" % dwell_time)
                        tmproamlist = (clientName, port, dwell_time_str)
                        dispRoamList.append(tmproamlist)
                                               
                        roamindx += 1
                        if roamindx == len(clientportlist):
                           roamindx = 0
                        
                        curr_tot_time += dwell_time
                        if firstroundF == True:
                            dwell_time = config_dwell_time
                            firstroundF = False
                        if ((total_test_time - curr_tot_time) 
                                < config_dwell_time):
                            dwell_time = total_test_time - curr_tot_time
            
        numRows = self.roamStepsTable.numRows()
       
        for ii in range(0,numRows+1):
            self.roamStepsTable.removeRow(1)
        
        
        absDispRoamList = [] 
        
        if len(roamList) > 1:
            absDispRoamList.append([dispRoamList[0][0], dispRoamList[0][1], roamList[1][0], float(dispRoamList[0][2])])
            absTime = float(dispRoamList[0][2])
            for ii in range(1,len(dispRoamList)):
                if dispRoamList[ii][0] == dispRoamList[ii-1][0]:
                    absTime = absTime + float(dispRoamList[ii][2])
                    if (ii+1) < len(dispRoamList):
                        if dispRoamList[ii][0] == dispRoamList[ii+1][0]:
                            absDispRoamListItem = [dispRoamList[ii][0],dispRoamList[ii][1], dispRoamList[ii+1][1], absTime]
                            absDispRoamList.append(absDispRoamListItem) 
                       
                else:
                    absTime = float(dispRoamList[ii][2])
                    if (ii+1) < len(dispRoamList):
                        if dispRoamList[ii][0] == dispRoamList[ii+1][0]:
                            absDispRoamListItem = [dispRoamList[ii][0], dispRoamList[ii][1], dispRoamList[ii+1][1], float(dispRoamList[ii][2])]
                            absDispRoamList.append(absDispRoamListItem)  
            
            absDispRoamList = sorted(absDispRoamList, key=operator.itemgetter(3))
        
        
        if len(absDispRoamList) != 0:    
            for ii in range(0,(len(absDispRoamList)-1)):
                self.roamStepsTable.insertRows(1,1)    
                    
            for ii in range(0,len(absDispRoamList)):
                for jj in range(0,len(absDispRoamList[ii])):
                    self.roamStepsTable.setText(ii,jj, str(absDispRoamList[ii][jj]))
        else:
            numRows = self.roamStepsTable.numRows()
            for ii in range(0,numRows+1):
                self.roamStepsTable.removeRow(1)
                self.roamStepsTable.clearCell(0,0)
                self.roamStepsTable.clearCell(0,1)
                self.roamStepsTable.clearCell(0,2)
                self.roamStepsTable.clearCell(0,3)
                
        
        self.numRoamsLineEdit.setText(str(len(absDispRoamList))) 
        
        if len(portList) > 1:  
            if repeatType == 1:
                   avgRoams = float(len(absDispRoamList)/((len(portList)-1)*dwellTime*(repeatVal+1))) 
                
            else:
                avgRoams = float(len(absDispRoamList)/repeatVal)
        else:
            avgRoams = 0    
                    
        self.avgRoamsLineEdit.setText(str(avgRoams))
        self.numClientsLineEdit.setText(str(numClients))
        
    #### Procedure to return the roaming dictionary to the waveapps    
    def returnRoamTestDict(self):
        global roam_dict       
         
        return self.roam_dict
        
    ### Procedure to load the roaming dictionary from waveapps    
    def loadRoamTestDict(self, waveTestSpecificStore):
        global roam_dict        
        self.roam_dict = self._normalizeData(waveTestSpecificStore.copy())

    def _normalizeData(self, testSpecificStore):
        normalizedData = {}
        for groupName in testSpecificStore:
            #if groupName in self.client_group_names:#Maybe group is deleted
            normalizedData[groupName] = self._getNormalizedGroupData(testSpecificStore[groupName])    
        
        return normalizedData
    
    def _getNormalizedGroupData(self, groupData):
        """
        Check for any normalization required, any changes in the data format
        required for backward & forward compatibility
        """
        normalizedGroupData = copy.deepcopy(groupData)
        #A fix for the case when the configuration file is saved with 
        #bssidList, portNameList being str type, rather than list
        
        if ('bssidList' in groupData 
            and 
            (not isinstance(groupData['bssidList'], list))):
            if isinstance(groupData['bssidList'], str):
                normalizedGroupData['bssidList'] = [groupData['bssidList']]
            else:
                normalizedGroupData['bssidList'] = []
        
        if ('portNameList' in groupData 
            and 
            (not isinstance(groupData['portNameList'], list))):
            if isinstance(groupData['portNameList'], str):
                normalizedGroupData['portNameList'] = [groupData['portNameList']]
            else:
                normalizedGroupData['portNameList'] = []
        
        return normalizedGroupData
