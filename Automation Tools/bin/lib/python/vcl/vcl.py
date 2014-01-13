#############################################################################
#
# VeriWave Command Library -- Python Module
#
# Copyright 2006 VeriWave Inc., All rights reserved.
#
# Use of this module is governed by the license agreement provided with
# this software package.
# 
#############################################################################

import vclapi
import sets

#############################################################################
# Initialize the basic set of "command" objects.
session     = vclapi.VclSession()
chassis     = vclapi.VclChassis()
card        = vclapi.VclCard()
port        = vclapi.VclPort()
mc          = vclapi.VclMobileClient()
ec          = vclapi.VclEthernetClient()
clientGroup = vclapi.VclClientGroup()
capture     = vclapi.VclCapture()
stats       = vclapi.VclStats()
flowStats   = vclapi.VclFlowStats()
clientStats = vclapi.VclStatsClient()
action      = vclapi.VclActions()
flow        = vclapi.VclFlow()
flowGroup   = vclapi.VclFlowGroup()
biflow      = vclapi.VclBiflow()
appSession  = vclapi.VclAppSession()
rawServer   = vclapi.VclRawServer()
rawClient   = vclapi.VclRawClient()
httpServer  = vclapi.VclHttpServer()
httpClient  = vclapi.VclHttpClient()
ftpServer   = vclapi.VclFtpServer()
ftpClient   = vclapi.VclFtpClient()
mac         = vclapi.VclFlowModMac()
ipv4        = vclapi.VclFlowModIpv4()
icmp        = vclapi.VclFlowModIcmp()
udp         = vclapi.VclFlowModUdp()
tcp         = vclapi.VclFlowModTcp()
rtp         = vclapi.VclFlowModRtp()
enetQos     = vclapi.VclFlowModEnetQos()
wlanQos     = vclapi.VclFlowModWlanQos()
igmp        = vclapi.VclIgmpRsp()
membuf      = vclapi.MemoryBuffer()
checksum    = vclapi.Checksum()
vclUtils    = vclapi.VclUtilities()
sendData    = vclapi.MemoryBuffer()
recvData    = vclapi.MemoryBuffer()
wtrpc       = vclapi.VclPortIf()
capfile     = vclapi.VclCapFile()
biflowTcp   = vclapi.VclBiflowModTcp()
biflowQos   = vclapi.VclBiflowModQos()
biflowIpv4  = vclapi.VclBiflowModIpv4()
tt          = vclapi.VclTheoreticalThroughput()
curl        = vclapi.VclCurl()
dns         = vclapi.VclDns()
forwarder   = vclapi.VclForwarder()
upgrade     = vclapi.VclUpgrade()
roamingArea = vclapi.VclRoamingArea()
roamingCircuit = vclapi.VclRoamingCircuit()
roamingStatsCapture = vclapi.VclRoamingStatsCapture()
roamingRecord = vclapi.VclRoamingRecord()
roamingClientStats = vclapi.VclStatsRoamingInfoClient()

#############################################################################
# Hook up modifiers to flow command object.

mac.setDefaultFlow(flow)
ipv4.setDefaultFlow(flow)
icmp.setDefaultFlow(flow)
udp.setDefaultFlow(flow)
tcp.setDefaultFlow(flow)
rtp.setDefaultFlow(flow)
enetQos.setDefaultFlow(flow)
wlanQos.setDefaultFlow(flow)
biflowTcp.setDefaultBiflow(biflow)
appSession.setDefaultBiflow(biflow)
biflowQos.setDefaultBiflow(biflow)
biflowIpv4.setDefaultBiflow(biflow)

#############################################################################
MemoryBuffer = vclapi.MemoryBuffer
Checksum     = vclapi.Checksum

#############################################################################
# Expose vcl actions and utilties via short names
vclVersion = action.getVclVersionStr()

startFlowGroup = action.startFlowGroup
stopFlowGroup = action.stopFlowGroup

startFlowTransmit = action.startFlowTransmit
stopFlowTransmit = action.stopFlowTransmit

getVclVersionStr = action.getVclVersionStr
getVersionStr = action.getVersionStr
getBuildStr = action.getBuildStr

vclError = vclUtils.getErrorString
vclAppError = vclUtils.getAppErrorString
vclTime  = vclUtils.getTime

#############################################################################
# Exception class for use with vclCheck.
class VclException(Exception):
    def __init__(self, code, func = None, args = ()):
        self.code = code
        self.func = func
        self.args = args
    def what(self):
        return vclError(self.code)
    def __str__(self):
        return self.what()

#############################################################################
# In support of clean namespaces with from vcl import *, clean up names
del vclapi

#############################################################################
def vclCheck(func, *args):
    """Provides error handling for VCL methods to convert between the
    returned error codes and a throw exception. Example usage is simply to
    call with a function and any necessary arguments:

    from vcl import *
    try:
       vclCheck(chassis.connect, 'bogus-chassis')
       vclCheck(port.bind, 'port', 'bogus-chassis', 1)
    except VclException, ex:
       print ex
    """
    retCode = func(*args)
    if retCode != None and retCode < 0:
        raise VclException(retCode, func, args)
    return retCode

#############################################################################
def vclGetCommandNames():
       cmdList = ['chassis',
                  'card',
                  'port',
                  'mc',
                  'ec',
                  'clientGroup',
                  'capture',
                  'stats',
                  'flowStats',
                  'clientStats',
                  'flow',
                  'flowGroup',
                  'mac',
                  'ipv4',
                  'icmp',
                  'udp',
                  'tcp',
                  'rtp',
                  'enetQos',
                  'wlanQos',
                  'igmp',
                  'buffer',
                  'checksum'
                  'vclUtils']
       return cmdList

# gets names of all actions
def vclGetActionNames():
       newList = []
       actionList = []
       k = 0
       actionList = dir(action)
       for k in range(len(actionList)):
            if actionList[k][0] != '_' and actionList[k] != 'this' and actionList[k] != 'thisown' and actionList[k].find("Version") == -1 :
              newList.append(actionList[k])
       return newList


def getList(cmd):
        newList = []
        commandList = []
        i = 0
        commandList = dir(eval(cmd))
        for i in range(len(commandList)):
                if commandList[i][0] != '_':
                        newList.append(commandList[i])
        j = 0
        parametersCommand = cmd + 'Parameters'
        parametersList = eval(cmd + '.__swig_getmethods__.keys()')
        newParametersCommand =  parametersCommand + '=' + str(parametersList)
        exec newParametersCommand
        return (parametersList,newList)

def getParameters(cmd):
    actions = vclGetActionNames()
    if (actions.count(cmd) == 1):
        return 1
    newList = []
    commandList = []
    i = 0
    commandList = dir(eval(cmd))
    for i in range(len(commandList)):
        if commandList[i][0] != '_'and commandList[i] != '_':
            newList.append(commandList[i])
    j = 0
    parametersCommand = cmd + 'Parameters'
    parametersList = eval(cmd + '.__swig_getmethods__.keys()')
    newParametersCommand =  parametersCommand + '=' + str(parametersList)
    for p in parametersList:
        if p[0] == "_":
            parametersList.remove(p)
    exec newParametersCommand
    return parametersList

def getMethods(cmd):
    actions = vclGetActionNames()
    if (actions.count(cmd) == 1):
        return 1
    (parametersList,newList) = getList(cmd)
    s1 = sets.Set(newList)
    s2 = sets.Set(parametersList)
    s3 = s1.difference(s2)
    methodsList = []
    for j in s3:
        if (j!= 'this') and (j!= 'thisown'):
            methodsList.append(j)
    methodsCommand = cmd + 'Methods'
    newMethodsCommand = methodsCommand + '=' + str(methodsList)
    exec newMethodsCommand
    return methodsList
