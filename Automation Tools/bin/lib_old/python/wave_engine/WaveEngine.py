# WaveEngine

# Imports
import time, sched
import sys, math
import os.path
import traceback
import re
import socket, struct, threading, random
import types
import urllib

from vcl import *
import portSetupModel as PSM
from CommonFunctions import *
from odict import *
#____________________________DataExport___________________________________
Error_list_db =[]
Error_list_db=Error_list_db+[('TestStatus', 0)]
Error_list_db=Error_list_db+[('TestError', "False")]
Error_list_db=Error_list_db+[('Testuserabort', "False")]
Error_list_db=Error_list_db+[('ErrorCondition',"None")]
#____________________________DataExport___________________________________
######################################## Constants ######################################
version = '$Revision: 1.230 $'.split(' ')[1]
date = '.'.join('$Date: 2007/09/06 16:49:50 $'.split(' ')[1].split('/')) + '.00'
full_version = "%s, %s" % (version, date)
MAXtxFrames = 28147497671065
MAXlatency  = 4294967295
TimeScriptStartmS = time.time()
SingleStepFlag = False
EthernetClientCode = 10
ClientStateDhcp = 5
ClientState80211Auth = 2
ClientStateAssoc = 3
ClientState8021xAuth = 4
ClientStateLearning = 8
ClientStateIdle = 0
BIFLOW_STATE_IDLE        = "IDLE"
BIFLOW_STATE_READY       = "READY"
BIFLOW_STATE_LISTEN      = "LISTEN"
BIFLOW_STATE_SYN_SENT    = "SYN-SENT"
BIFLOW_STATE_SYN_RCVD    = "SYN-RCVD"
BIFLOW_STATE_ESTAB       = "ESTABLISHED"
BIFLOW_STATE_FIN_WAIT1   = "FIN-WAIT-1"
BIFLOW_STATE_FIN_WAIT2   = "FIN-WAIT-2"
BIFLOW_STATE_CLOSE_WAIT  = "CLOSE-WAIT"
BIFLOW_STATE_CLOSING     = "CLOSING"
BIFLOW_STATE_LAST_ACK    = "LAST-ACK"
BIFLOW_STATE_TIMED_WAIT  = "TIMED-WAIT"
WLAN_80211E_QOS_AC_TO_UP_MAP = {'AC_BE/Best Effort':0, 'AC_BK/Background':1, 'AC_VI/Video':4, 'AC_VO/Voice':6}
#Interface identities
WiFiInterface = '802.11'
EthInterface = '802.3 Ethernet'
abgInterface = '802.11 a/b/g'
abgnInterface = '802.11 a/b/g/n'
WiFiInterfaceTypes = [abgInterface, abgnInterface]
ABGportType = '80211'
NportType = '80211n'
EthPortType = '8023'
WiFiPortTypes = [ABGportType, NportType]
PortTypes = WiFiPortTypes + [EthPortType]
#VPR 6379
DELAY_FOR_SCAN_BSSID = 0.4
################################## Hidden Module Varibles ###############################
_Timelog_Fhdl     = -1
_Detailed_Fhdl    = -1
_Console_FileName = ''
_RSSI_FileName    = -1
_PortInfo         = {}
_PortLocation     = {}
_PortBSSID2SSID   = {}
_LoggingDirectoryPath = ''
_LastPrintedPercentage = -1

################################ Global Module Variables ###############################
# Hack to allow upper layers to communicate that chassis management is handled
# outside of WaveEngine. -- mwb
DisconnectChassis = True

##################################### Exception Defination ###################################
# Changing the exception from string based to class based.  Any code that tries to catch the 
# WaveEngine.RaiseException will also catch all the subclasses to it.  This is the perferred
# method for backwards compatibilty
#
# General case
class RaiseException:
    def __repr__(self):
        return "WaveEngine: Aborting the test\n"

class RaiseVCLException(RaiseException):
    def __repr__(self):
        return "WaveEngine: User aborted a VCL error message\n"

class RaiseUserException(RaiseException):
    def __repr__(self):
        return "WaveEngine: User manually aborted the test\n"
    
class RaiseIterationFailed(RaiseException):
    def __init__(self, String= '', Time=0):
        self.String = String
        self.ElapsedTime = Time
    def __repr__(self):
        return "WaveEngine: Iteration terminated, reason: %s\n" % (String)
    
class RaiseScheduleException(RaiseException):
    def __repr__(self):
        return "WaveEngine: Ending the test as we reached the test duration\n"
    
class RaiseKeyException(RaiseException):
    def __repr__(self):
        return "WaveApps: Current license does not enable execution of the test.\n"

class ChassisConnectError(Exception):
    def __init__(self, errorCode):
        super(ChassisConnectError, self).__init__('Could not connect to the chassis, code:%r'%errorCode)

class ChassisDisconnectError(Exception):
    def __init__(self, errorCode):
        super(ChassisConnectError, self).__init__('Could not Disconnect from the chassis, code:%r'%errorCode)
        
class ChassisReadError(Exception):
    def __init__(self, chassisName):
        super(ChassisReadError, self).__init__('Could not read from the chassis %s'%self.chassisName)

class CardReadError(Exception):
    def __init__(self, chassisName='', cardName=''):
        super(CardReadError, self).__init__()
        self.chassisName = chassisName
        self.cardName = cardName
    def __str__(self):
        if self.chassisName and self.cardName:
            return 'Could not read from the chassis %s card %s'%(self.chassisName,
                                                                 self.cardName)
        else:
            return 'Could not read from the chassis card'

class TheoreticalMFRCalcException(Exception):
    def __str__(self):
        return 'Exception occured while calculating theoritical throughput'

class NotParsableVersionError(Exception):
    def __str__(self):
        return 'This version of WML file is not parsable'
    
##################################### SetOutputStream ###################################
# Redefine where we send the output text
#
MSG_DEBUG   = 0
MSG_OK      = 1
MSG_SUCCESS = 2
MSG_WARNING = 3
MSG_ERROR   = 4
MSG_QUERY   = 5
MSG_DATA    = 6
MSG_RESULTS = 7

def setPortInfo(portInfo):
    """
    set the WaveEngine attribute _PortInfo
    """
    global _PortInfo
    _PortInfo = portInfo
    
def setPortBSSID2SSID(portBSSID2SSID):
    """
    Set the WaveEngine attribute _PortBSSID2SSID
    """
    global _PortBSSID2SSID
    _PortBSSID2SSID = portBSSID2SSID
    
# Internal in case someone forgets to call us
def DefaultPrintToConsole(sMessage, iType):
    if iType == MSG_QUERY:
        InputString = raw_input(sMessage)
        return InputString
    else:
        print "DEFAULT:", sMessage,

_OutputstreamHDL  = DefaultPrintToConsole
def OutputstreamHDL(sMessage, iType):
    global _Console_FileName
    global _OutputstreamHDL
    ReturnValue = True

    if sMessage != '':
        #Log Messages to a filename
        if _Console_FileName != '':
            _Fhdl = None
            try:
                _Fhdl = open(_Console_FileName, 'a')
                htmltag = "font"
                if iType == MSG_OK:
                    htmltag = "MSG_OK"
                elif iType == MSG_SUCCESS:
                    htmltag = "MSG_SUCCESS"
                elif iType == MSG_WARNING:
                    htmltag = "MSG_WARNING"
                elif iType == MSG_ERROR:
                    htmltag = "MSG_ERROR"
                    #____________________________DataExport___________________________________
                    Err_Msg=sMessage
                    if Error_list_db[-1][1] != "None":
                         Err_Msg=''.join(Err_Msg.split('"'))
                         Err_Msg=Error_list_db[-1][1] + Err_Msg
                    Error_list_db[1]=('TestError',"True") 
                    Error_list_db[-1]=('ErrorCondition',Err_Msg)
                    Error_list_db[0]=('TestStatus', -1)
                    #____________________________DataExport___________________________________
                elif iType == MSG_DEBUG:
                    htmltag = "MSG_DEBUG"
                if sMessage[0] == '\r':
                    _Fhdl.write("\n<%s>%s</%s>" % (htmltag, sMessage[1:], htmltag) )
                else:
                    _Fhdl.write("<%s>%s</%s>" % (htmltag, sMessage, htmltag) )
                _Fhdl.close()
            except:
               if _Fhdl:
                   _Fhdl.close()

    #Now send it to the screen handler
    if iType != MSG_DEBUG:
        ReturnValue = _OutputstreamHDL(sMessage, iType)
        #If the return value is an instance, raise expection 
        if type(ReturnValue) is types.InstanceType:
            raise RaiseVCLException()
    
    Check4UserEscape()

    return ReturnValue

##################################### SetOutputStream ###################################
# Redirects the output messages somewhere besides the STDOUT.
# Also Arms the Escape key for different OS.  Recall this function to rearm the user ability
# to escape the program
#
EscapeStatusCode = Enum("off windows linux")
_ESCkeyStatus = EscapeStatusCode.off
def SetOutputStream(func):
    global _OutputstreamHDL
    global _ESCkeyStatus
    _OutputstreamHDL = func
    try:
        from msvcrt import kbhit, getch
        OutputstreamHDL("Detected keyboard library.  Press <ESC> to abort test.\n" , MSG_OK)
        _ESCkeyStatus = EscapeStatusCode.windows
    except:
        pass
    if _ESCkeyStatus != EscapeStatusCode.off:
        return

# Uncomment for Linux
#    try:
#        import termios
#        OutputstreamHDL("Detected termios library.  Press <ESC> to abort test.\n" , MSG_OK)
#        _ESCkeyStatus = EscapeStatusCode.linux
#    except:
#        pass

##################################### Check4UserEscape ###################################
# Depending upon the detected OS, it will check to see if the user pressed the ESC key to
# terminate this test run.
#
def Check4UserEscape():
    global _ESCkeyStatus
    keypress = 0

    if _ESCkeyStatus == EscapeStatusCode.off:
        return
    elif _ESCkeyStatus == EscapeStatusCode.windows:
        # Test to seee if the use press <ESC> Windows
        try:
            from msvcrt import kbhit, getch
            if kbhit():
                keypress = ord(getch())
        except:
            pass
    elif _ESCkeyStatus == EscapeStatusCode.linux:
        # Test to seee if the use press <ESC> Linux
        try:
            import termios
            fd = sys.stdin.fileno()
            old = termios.tcgetattr(fd)
            new = termios.tcgetattr(fd)
            new[3] = new[3] & ~termios.ICANON & ~termios.ECHO
            new[6][termios.VMIN] = 1
            new[6][termios.VTIME] = 0
            termios.tcsetattr(fd, termios.TCSANOW, new)
            try:
                keypress = ord(os.read(fd, 1))
            except IOError: pass
            termios.tcsetattr(fd, termios.TCSAFLUSH, old)
        except:
            pass
        
    if keypress == 27:
        _ESCkeyStatus = EscapeStatusCode.off
        raise RaiseUserException()

##################################### SingleStep ###################################
# Turns VCLtest single step on or off
#
def SingleStep(n):
    global SingleStepFlag
    SingleStepFlag = n

##################################### VCLtest ###################################
# Parses VCL's returned value and lets the user decide program flow upon error
#
def VCLtest(Func, negativesAreOK = False, globals=''):
    import traceback
    global _Timelog_Fhdl
    global SingleStepFlag
    code = 'ReturnValue = ' + Func
    IgnoreFlag = 1
    while IgnoreFlag > 0:
        D1 = time.time() - TimeScriptStartmS
        StartTime = time.clock()
        exec code 
        StopTime = time.clock()
        D2 = StopTime - StartTime
        if ReturnValue < 0 and not negativesAreOK:
            dataStuff = traceback.extract_stack()
            errMsg = vclError(ReturnValue)
            OutputstreamHDL("%s\n Error with %s in %s.\n" % (errMsg, Func, dataStuff[0][0]), MSG_ERROR)
            try:
                _Timelog_Fhdl.write('%08.3f, %6.3f, %s, <= %s\n' % (D1, D2, Func, errMsg))
                _Timelog_Fhdl.flush()
            except:
                pass
            IgnoreFlag = 2
            while IgnoreFlag == 2:
                if SingleStepFlag:
                    Inputkey = OutputstreamHDL("BREAKPOINT: (A)bort, (R)etry, (I)gnore, or (S)inglestep ?", MSG_QUERY)
                else:
                    Inputkey = OutputstreamHDL("(A)bort, (R)etry, (I)gnore, or (S)inglestep ?", MSG_QUERY)
                if Inputkey.lower() == 'a':
                    #DisconnectAll()
                    #CloseLogging()
                    raise RaiseVCLException
                elif Inputkey.lower() == 'i':
                    IgnoreFlag = 0
                elif Inputkey.lower() == 'r':
                    IgnoreFlag = 1
                elif Inputkey.lower() == 's':
                    SingleStepFlag = not SingleStepFlag
        else:
            IgnoreFlag = 0
            try:
                _Timelog_Fhdl.write('%08.3f, %6.3f, %s\n' % (D1, D2, Func) )
            except:
                pass
        if SingleStepFlag:
            dataStuff = traceback.extract_stack()
            Inputkey = OutputstreamHDL("BREAKPOINT: %s in %s (A)bort, (S)inglestep, or <Enter> to continue" % (Func, dataStuff[0][0]), MSG_QUERY)
            if Inputkey.lower() == 'a':
                #DisconnectAll()
                #CloseLogging()
                raise RaiseVCLException
            elif Inputkey.lower() == 's':
                SingleStepFlag = False
    return ReturnValue
                
##################################### PrintVersionInfo ###################################
# Print all known version info
#
def PrintVersionInfo():
    OutputstreamHDL("WaveEngine Version: %s\n" % (full_version), MSG_OK)
    OutputstreamHDL("Framework Version: %s\n" % (action.getVclVersionStr()), MSG_OK)
    OutputstreamHDL("Firmware Version: %s\n" % (chassis.version), MSG_OK)

    WriteDetailedLog(["WaveEngine Version", full_version])
    WriteDetailedLog(["Framework Version", action.getVclVersionStr()])
    WriteDetailedLog(["Firmware Version", chassis.version])
    WriteDetailedLog([''])

##################################### GetCachePortInfo ###################################
# Method to cache the port type (either 8023 or 80211 or 80211n).  
# Port reads take 100mS to execute.
# THis is a shortcuts if you ONLY need to know the port type
#
def GetCachePortInfo(Portname):
    global _PortInfo
    # FIXME - workaround for VPR 3028 - use first port if given a list
    if isinstance( Portname, list ):
        Portname = Portname[0]
    # read port if not in cache
    if not _PortInfo.has_key(Portname):
        VCLtest("port.read('%s')" % (Portname))
        _PortInfo[Portname] = port.type
    return _PortInfo[Portname]

##################################### GetCacheSSID ###################################
# Maps a Portname and BSSID to a SSID.  The cache is cleared and set on GroupVerifyBSSID_MAC
# This is much faster than using a port read for every entry
#
def GetCacheSSID(Portname, BSSID):
    global _PortBSSID2SSID
    if not _PortBSSID2SSID.has_key(Portname):
        _PortBSSID2SSID[Portname] = {}
        VCLtest("port.read('%s')" % (Portname))
    if not _PortBSSID2SSID[Portname].has_key(BSSID):
        _PortBSSID2SSID[Portname][BSSID] =  port.getBssidSsid(BSSID) 
        
    if _PortBSSID2SSID[Portname][BSSID] == '':
        ssid = getHiddenSSID(Portname, BSSID)
        _PortBSSID2SSID[Portname][BSSID] = ssid

    return _PortBSSID2SSID[Portname][BSSID]

def getHiddenSSID(portName, bssid):
    #Hack to get the hidden SSID, if it weren't for the time
    #constraint for 2.4.2, would look for better approach
    global gPortBssidSsid
    if portName in gPortBssidSsid:
        if bssid in gPortBssidSsid[portName]:
            ssid = gPortBssidSsid[portName][bssid]
        else:
            ssid = ''
    else:
        ssid = ''
    
    return ssid

#Hack to get the hidden SSID, if it weren't for the time
#constraint for 2.4.2, would look for better approach
gPortBssidSsid = {}
def setPortBssidSsid(wavePortStore):
    global gPortBssidSsid
    gPortBssidSsid.update(wavePortStore)

##################################### OpenLogging ###################################
# Open up timelogs and capture logs
#
# Returns: Base name of the calling script
#
def OpenLogging(Path='', Timelog = '', Console='', RSSI='', Detailed=-1):
    global _LoggingDirectoryPath
    global _Timelog_Fhdl
    global _Detailed_Fhdl
    global _Console_FileName
    global _RSSI_FileName
    ScriptName = re.search("([.0-9a-zA-Z_-]+).py", sys._getframe(1).f_code.co_filename)

    #Test to seee if the path exists
    if Path != '':
        if not os.path.exists(Path):
            OutputstreamHDL("Warning: Logging path '%s' does not exist. Creating now...\n" % (Path), MSG_WARNING) 
            os.makedirs(Path)
        _LoggingDirectoryPath = Path

    #Open Timelog file
    if Timelog == '':
        Timelog = "Timelog_" + ScriptName.group(1) + ".txt"
    _Timelog_Fhdl = open(os.path.join(_LoggingDirectoryPath, Timelog ), 'w')
    InsertTimelogMessage("WaveEngine: %s Framework: %s" % (version, action.getVclVersionStr()) )

    #Open Detailed Log file
    if Detailed != -1:
        if Detailed == '':
            Filename = os.path.join(_LoggingDirectoryPath, "Detailed_" + ScriptName.group(1) + ".csv")
        else:
            Filename = os.path.join(_LoggingDirectoryPath, Detailed)
        try:
            _Detailed_Fhdl = open(Filename, 'w')
        except:
            OutputstreamHDL("Error: Could not open %s for writing\n" % (Filename), MSG_ERROR)
            return -1

    #Open Console logfile
    if Console == '':
        _Console_FileName = os.path.join(_LoggingDirectoryPath, "Console_" + ScriptName.group(1) + ".html")
    else:
        _Console_FileName = os.path.join(_LoggingDirectoryPath, Console)
    _Fhdl = open(_Console_FileName, 'w')
    _Fhdl.write("<!----- VeriWave script %s ----->\n" % (ScriptName.group(1)))
    _Fhdl.write("<HEAD><STYLE TYPE=\"text/css\">\n")
    _Fhdl.write("<!--\n")
    _Fhdl.write("MSG_OK      { color:white }\n")
    _Fhdl.write("MSG_SUCCESS { color:green }\n")
    _Fhdl.write("MSG_WARNING { color:yellow }\n")
    _Fhdl.write("MSG_ERROR   { color:red }\n")
    _Fhdl.write("MSG_DEBUG   { color:#800080 }\n")
    _Fhdl.write("-->\n")
    _Fhdl.write("</STYLE></HEAD>\n")
    _Fhdl.write("<body bgcolor=black> <pre>\n")
    _Fhdl.close()

    #Create RSSI File
    if RSSI == '':
        _RSSI_FileName = os.path.join(_LoggingDirectoryPath, "RSSI_" + ScriptName.group(1) + ".csv")
    else:
        _RSSI_FileName = os.path.join(_LoggingDirectoryPath, RSSI)
    _Fhdl = open(_RSSI_FileName, 'w')
    _Fhdl.write("Time, Port Name, Channel, BSSID, SSID, RSSI\n")
    _Fhdl.close()

    return ScriptName.group(1)

##################################### InsertTimelogMessage ###################################
# Insert a message in the Timelog file
#
def InsertTimelogMessage(PrintString):
    global _Timelog_Fhdl
    ScriptTime = time.time() - TimeScriptStartmS
    try:
        _Timelog_Fhdl.write('%08.3f, %6s, %s,\n' % (ScriptTime, ' ', PrintString) )
    except:
        pass

##################################### CloseLogging ###################################
# Close up timelogs and detailed logs
#
def CloseLogging():
    global _Timelog_Fhdl
    global _Detailed_Fhdl
    try:
        _Timelog_Fhdl.close()
    except:
        pass
    _Timelog_Fhdl = -1
    try:
        _Detailed_Fhdl.close()
    except:
        pass
    _Detailed_Fhdl = -1

##################################### GetLogFile ###################################
# Retreive the log files for a list of cards and save it as a file
#
def GetLogFile(ListofCards, ScriptName=None):
    global _LoggingDirectoryPath
    if ScriptName == None:
        Temp = re.search("([.0-9a-zA-Z_-]+).py", sys._getframe(1).f_code.co_filename)
        ScriptName = Temp.group(1)

    for Portname in ListofCards:
        Filename = os.path.join(_LoggingDirectoryPath, ScriptName + "-" + Portname)
        OutputstreamHDL("Saving %s to file %s ... " % (Portname, Filename), MSG_OK)
        VCLtest("capture.setFileName(r'%s')" % (Filename))
        VCLtest("capture.write('%s')"       % (Portname))
        VCLtest("capture.grabLog('%s', 'pcap')"     % (Portname))

        Filename += ".vwr"
        if os.path.isfile(Filename):
            BytesRead = Float2EngNotation(os.path.getsize(Filename), 3)
            OutputstreamHDL("%sbytes\n" % (BytesRead), MSG_OK)
        else:
            OutputstreamHDL("NOT CREATED\n", MSG_WARNING)

################################ PortEnableFeature #############################
# enable the feature on the port. Currently, only 'TCP' is supported
# input:
# - listofCardsUsed: list of cards
def PortEnableFeature(listofCardsUsed, feature='tcp-port'):
    for portname in listofCardsUsed:    
        VCLtest("port.enableFeature('%s', '%s')" % (portname, feature))      
              
##################################### ConnectPorts ###################################
# Reserves ports for the test
#
def ConnectPorts(ListofCardsUsed, ListofKnownCardLocations, PortOptions={}):
    global _PortInfo
    global _PortLocation
    OutputstreamHDL("Reserving ports for the test\n", MSG_OK)
    ListofConnectedPorts = []
    ReturnErrorCode = 0
    _PortInfo       = {}
    _PortLocation   = ListofKnownCardLocations.copy()

    #Process the option field
    #Initialize perPortOptionList
    perPortOptionList = {}
    for portName in ListofCardsUsed:
        perPortOptionList[portName] = []
         
    for OptionKey in PortOptions.keys():
        OptionMethod = "set%s" % (OptionKey)
        if OptionMethod in getMethods('port'):
            for portName in ListofCardsUsed:
                if isnum(PortOptions[OptionKey][portName]):
                    optionCmd = "port.%s(%s)"  % (OptionMethod, 
                                                  PortOptions[OptionKey][portName]) 
                else:
                    optionCmd = "port.%s('%s')" % (OptionMethod, 
                                                   PortOptions[OptionKey][portName]) 
                perPortOptionList[portName].append(optionCmd)
        else:
            OutputstreamHDL("Warning: Port option '%s' not supported (ignoring)\n" % (OptionKey), MSG_WARNING)

    # VPR 3953 -- ensure that all chassis in the CareMap are connected, exactly
    # once. Connecting all chassis is required so that it is possible to create
    # flow groups across a sync'd chassis set even if there are no ports bound
    # on the master chassis. Exactly once is an optimization since it is
    # expensive to connect to a chassis. This connection process assumes that
    # the user has ensured that the CardMap contains a port from the master
    # chassis, even if that port will never be used.
    ChassisList = {}
    for CardParam in ListofKnownCardLocations.values():
        ChassisList[CardParam[0]] = 1
    for Chassis in ChassisList.keys():
        VCLtest("chassis.connect('%s')" % Chassis)

    for Portname in ListofCardsUsed:
        if not ListofKnownCardLocations.has_key(Portname):
            OutputstreamHDL("Error: Could not find %s in list of cards\n" % (Portname), MSG_ERROR)
            ReturnErrorCode = -1
            continue
        if Portname in ListofConnectedPorts:
            OutputstreamHDL("Warning: Port %s is already reserved (ignoring dupicate)\n" % (Portname), MSG_WARNING)
            continue
        
        CardParam = ListofKnownCardLocations[Portname]

        # compare VCL version with firmware
        MyVCLversion = str( action.getVclVersionStr() )
        VCLtest( "card.read('%s', %s)" % (CardParam[0], CardParam[1]) )
        cardVersion = str( card.getVersion() )
        if MyVCLversion != cardVersion:
            # per VPR 3083, print only a warning message for mis-matched versions
            msg = "Warning: Firmware version %s on Chassis %s, Card %s, does not match framework version %s.\n" % \
                   ( cardVersion, CardParam[0], CardParam[1], MyVCLversion )
            OutputstreamHDL( msg, MSG_WARNING )

        # create and bind port
        VCLtest("port.create('%s')" % (Portname))
        #FIXME - Change bind failure to a message instead of VCL error
        VCLtest("port.bind('%s', '%s', %s, %s)" % (Portname, CardParam[0], CardParam[1], CardParam[2]) )
        VCLtest("port.reset('%s')" % (Portname))

        if GetCachePortInfo(Portname) == '8023':
            if len(CardParam) == 6:
                VCLtest("port.setAutonegotiation('%s')" % (CardParam[3]))
                VCLtest("port.setSpeed(%s)"   % (CardParam[4]))
                VCLtest("port.setDuplex('%s')"  % (CardParam[5]))
            else:
                OutputstreamHDL("Warning: Port %s does not have the right number of paramters for 802.3 (expected 6)\n" % (Portname), 
                                MSG_WARNING)
        elif GetCachePortInfo(Portname) in WiFiPortTypes:
            if len(CardParam) == 6:
                VCLtest("port.setRadioBand(%s)" % (CardParam[3]))
                VCLtest("port.setRadioChannel(%s)" % (CardParam[4]))
                VCLtest("port.setSecondaryChannelPlacement('%s')" % (CardParam[5]))
                VCLtest("port.setRadio('on')")
            else:
                OutputstreamHDL("Warning: Port %s does not have the right number of paramters for 802.11 (expected 6)\n" % (Portname), 
                                MSG_WARNING)
        else:
            OutputstreamHDL("Error: %s unknown port type of %s\n" % (Portname, GetCachePortInfo(Portname)), MSG_ERROR)
            ReturnErrorCode = -1

        #Process port options
        for CurrentOption in perPortOptionList[Portname]:
            VCLtest(CurrentOption)
            
        VCLtest("port.write('%s')" % (Portname))
        
        ListofConnectedPorts.append(Portname)
        VCLtest("capture.disable('%s')" % (Portname))
        VCLtest("capture.clear('%s')" % (Portname))
        VCLtest("capture.enable('%s')" % (Portname))
    return ReturnErrorCode

##################################### ClearAllCounter ###################################
# Clears all port counters in a list
#
def ClearAllCounter (ListofCards):
    for Portname in ListofCards:
        VCLtest("stats.resetAll('%s')" % (Portname))

##################################### ClearAllCounterBlocking ###################################
# Clear the counters and block until they read zero or timeout
#
def WaitForCountersoZero(ListofCards, Timeout):
    for Portname in ListofCards:
        VCLtest("stats.resetAll('%s')" % (Portname))
    StopTime = time.time() + Timeout
    while StopTime > time.time():
        ReturnValue = True
        for Portname in ListofCards:
            VCLtest("stats.setDefaults()")
            VCLtest("stats.read('%s')" % (Portname))
            if stats.txIpPacketsOk != 0 or stats.rxIpPacketsOk != 0:
                ReturnValue = False
        if ReturnValue:
            return True
    OutputstreamHDL("Warning: The IpPacketsOk counters have not cleared after %s seconds\n" % (Timeout), MSG_WARNING)
    return False

################################# DisconnectAll #################################
# Free all resources and disconnect form all chassis'
#
def DisconnectAll():
    InsertTimelogMessage("DisconnectAll()")
    for fgname in flowGroup.getNames():
        action.stopFlowGroup(fgname)
        flowGroup.destroy(fgname)
    for flowname in flow.getNames():
        flow.destroy(flowname)
    for name in curl.getNames():
        curl.destroy(name)
    for name in mc.getNames():
        mc.deauthenticate(name, 1) 
        mc.destroy(name)
    for name in ec.getNames():
        ec.destroy(name)
    for portname in port.getNames():
        port.destroy(portname)
    if DisconnectChassis:
        for ChassisName in chassis.getNames():
            chassis.disconnect(ChassisName)

##################################### GroupFindFirstBSSID ###################################
# Modifies the list of clients with the first BSSID found on each port
#
def GroupFindFirstBSSID (ClientList, timeout):
    # Create a list of all the used ports
    PortsToScan = []
    _Port2BSSID = {}
    for CurrentClient in ClientList:
        if CurrentClient[1] not in PortsToScan:
            PortsToScan.append(CurrentClient[1])

    #Start the scan
    for PortName in PortsToScan:
        VCLtest("port.read('%s')" % (PortName))
        if port.type in WiFiPortTypes:
            VCLtest("port.scanBssid('%s')" % (PortName))
            #VPR 6379
            time.sleep(DELAY_FOR_SCAN_BSSID)
            VCLtest("port.write('%s')" % (PortName))
    # Keep checking until we timeout or have all the BSSIDs
    StopTime = time.time() + timeout
    while StopTime > time.time():
        GotAllBSSIDs = True
        for PortName in PortsToScan:
            if not _Port2BSSID.has_key(PortName):
                VCLtest("port.read('%s')" % (PortName))
                GotAllBSSIDs = False
                if port.type in WiFiPortTypes:
                    if len( port.getBssidList() ) > 0:
                        BSSID = port.getBssidList()
                        _Port2BSSID[PortName] = BSSID[0]
                        OutputstreamHDL("Completed: found AP on %s, BSSID=%s SSID=%s\n" % (PortName, BSSID[0], port.getBssidSsid( BSSID[0])), MSG_SUCCESS)
                else:
                    _Port2BSSID[PortName] = "0-0-0-0-0-0"
        if GotAllBSSIDs: break
        time.sleep(0.25)

    if StopTime < time.time():
        OutputString = "Error: Could not find any BSSIDs on [ "
        for PortName in PortsToScan:
            if not _Port2BSSID.has_key(PortName):
                OutputString += PortName
        OutputString += " ]\n"
        OutputstreamHDL(OutputString, MSG_ERROR)
        return -1

    #We found BSSIDs for all ports, now lets update the client list
    for x in range(len(ClientList)):
        PortName = ClientList[x][1]
        ClientList[x] = ClientList[x][:2] + ( _Port2BSSID[PortName], ) + ClientList[x][3:]
    return 0   

##################################### GetBSSIDdictonary ###################################
# Returns the a dictinoary of Port -> BSSID 
#
def GetBSSIDdictonary(PortList, timeout, CountofBSSIDs=1):
    global _PortBSSID2SSID
    _Port2BSSID = {}
    _PortBSSID2SSID = {}
    #Start the scan
    for PortName in PortList:
        VCLtest("port.read('%s')" % (PortName))
        if port.type in WiFiPortTypes:
            VCLtest("port.scanBssid('%s')" % (PortName))
            #VPR 6379
            time.sleep(DELAY_FOR_SCAN_BSSID)
            VCLtest("port.write('%s')" % (PortName))
            _PortBSSID2SSID[PortName] = {}
    StopTime = time.time() + timeout
       
    # Keep checking until we timeout or have all the BSSIDs
    while StopTime > time.time():
        time.sleep(0.3)
        GotAllBSSIDs = True
        for PortName in PortList:
            if not _Port2BSSID.has_key(PortName):
                GotAllBSSIDs = False
                VCLtest("port.read('%s')" % (PortName))
                if port.type in WiFiPortTypes:
                    #print "getBssidList(%s)=" % (PortName), port.getBssidList() 
                    if len( port.getBssidList() ) > 0:
                        for TempBSSID in port.getBssidList():
                            if not _Port2BSSID.has_key(PortName):
                                OutputstreamHDL("Completed: found AP on %s, BSSID=%s SSID=%s\n" % (PortName, TempBSSID, port.getBssidSsid(TempBSSID)), MSG_SUCCESS)
                                _PortBSSID2SSID[PortName][TempBSSID] = port.getBssidSsid(TempBSSID)
                            elif TempBSSID not in _Port2BSSID[PortName]:
                                OutputstreamHDL("Completed: found AP on %s, BSSID=%s SSID=%s\n" % (PortName, TempBSSID, port.getBssidSsid(TempBSSID)), MSG_SUCCESS)
                                _PortBSSID2SSID[PortName][TempBSSID] = port.getBssidSsid(TempBSSID)
                        _Port2BSSID[PortName] = port.getBssidList()
                else:
                    _Port2BSSID[PortName] = "0-0-0-0-0-0"
            elif len(_Port2BSSID[PortName]) < CountofBSSIDs: 
                GotAllBSSIDs = False
        if GotAllBSSIDs: break

    if StopTime < time.time():
        OutputString = "Error: Could not find enough BSSIDs on [ "
        for PortName in PortList:
            if not _Port2BSSID.has_key(PortName):
                OutputString += PortName + " "
        OutputString += " ]\n"
        OutputstreamHDL(OutputString, MSG_ERROR)
        return {}

    #We found BSSIDs for all ports, now lets update the client list
    return _Port2BSSID

##################################### GroupVerifyBSSID_MAC ###################################
# Validates the BSSID and MAC address for each client group
# If the BSSID is 00:00:00:00:00:00 then with replace with the first scanned
# If the BSSID is not a valid MAC format, will try to match it to a SSID and replace with BSSID
# Otherwise BSSID MUST be found in the scan process
# If the MAC address is 'DEFAULT' then replace per 'Address Hash and Bit Stuffing Draft (04)'
#
# ListofClientLists is a List of one or more lists of client profiles.  Done this way to combine the
# scanning into one, but keep source and destintaion separate
#
def GroupVerifyBSSID_MAC(ListofClientLists, timeout):
    # Used by getCachedSSID
    global _PortBSSID2SSID
    # Create a list of all the used ports
    ReturnSuccess = True
    _Port2BSSID = {}
    _PortSSID2BSSID = {}
    _PortBSSID2SSID = {}
    PortsToScan = []
    for ClientList in ListofClientLists:
        for CurrentClient in ClientList:
            PortList = CurrentClient[1]
            if isinstance(PortList, list):
                for PortName in PortList:
                    if PortName not in PortsToScan:
                        PortsToScan.append(PortName)
            else:
                if PortList not in PortsToScan:
                    PortsToScan.append(PortList)

    #Start the scan
    for PortName in PortsToScan:
        VCLtest("port.read('%s')" % (PortName))
        if GetCachePortInfo(PortName) in WiFiPortTypes:
            VCLtest("port.scanBssid('%s')" % (PortName))
            #VPR 6379
            time.sleep(DELAY_FOR_SCAN_BSSID)
            VCLtest("port.write('%s')" % (PortName))
    Sleep(float(timeout), 'Populating SSID/BSSID tables')

    #Get the BSSIDs/SSIDs
    _PortSSID_dupe = {}
    _PortBSSID_dupe = {}
    for PortName in PortsToScan:
        VCLtest("port.read('%s')" % (PortName))
        _PortSSID2BSSID[PortName] = {}
        _PortBSSID2SSID[PortName] = {}
        _PortSSID_dupe[PortName]  = {}
        _PortBSSID_dupe[PortName] = {}
        if port.type in WiFiPortTypes:
            _Port2BSSID[PortName] = port.getBssidList()
            if len(_Port2BSSID[PortName]) == 0:
                OutputstreamHDL("Error: Port %s did not find any BSSIDs on channel %s\n" % (PortName, port.getChannel()), MSG_ERROR)
                ReturnSuccess = False
            for eachBSSID in _Port2BSSID[PortName]:
                eachSSID = port.getBssidSsid(eachBSSID)
                if _PortSSID2BSSID[PortName].has_key(eachSSID):
                    if _PortSSID_dupe[PortName].has_key(eachSSID):
                        _PortSSID_dupe[PortName][eachSSID] += ', ' + str(eachBSSID)
                    else:
                        _PortSSID_dupe[PortName][eachSSID] = str(_PortSSID2BSSID[PortName][eachSSID]) + ', ' + str(eachBSSID)
                _PortSSID2BSSID[PortName][eachSSID] = eachBSSID
                
                if _PortBSSID2SSID[PortName].has_key(eachBSSID):
                    if _PortBSSID_dupe[PortName].has_key(eachBSSID):
                        _PortBSSID_dupe[PortName][eachBSSID] += ', ' + str(eachSSID)
                    else:
                        _PortBSSID_dupe[PortName][eachBSSID] = str(_PortBSSID2SSID[PortName][eachBSSID]) + ', ' + str(eachSSID)
                _PortBSSID2SSID[PortName][eachBSSID] = eachSSID
        else:
            _Port2BSSID[PortName] = [ "0-0-0-0-0-0", ]
            _PortSSID2BSSID[PortName]['Ethernet'] = "0-0-0-0-0-0"
    if not ReturnSuccess:
        return ReturnSuccess

    #We found BSSIDs for all ports, now lets update the client list
    for ClientList in ListofClientLists:
        for x in range(len(ClientList)):
            (BaseName, PortName, BSSID, Base_MAC,  Base_IP, Subnet, Gateway, IncrTuple, Security, Options) = ClientList[x]
            if isinstance(PortName, list):
                InitialPort = PortName[0]
            else:
                InitialPort = PortName
            if BSSID == '00:00:00:00:00:00':
                BSSID = _Port2BSSID[InitialPort][0]
                if  _PortBSSID2SSID[InitialPort].has_key(BSSID):
                    OutputstreamHDL("Completed: Found AP on %s with BSSID=%s SSID=%s\n" % (InitialPort, BSSID, _PortBSSID2SSID[InitialPort][BSSID]), MSG_SUCCESS)
            elif BSSID in _Port2BSSID[InitialPort]:
                if _PortBSSID_dupe[InitialPort].has_key(BSSID):
                    OutputstreamHDL("Warning: Port %s with BSSID '%s' matches SSIDs %s\n" % (InitialPort, BSSID, _PortBSSID_dupe[InitialPort][BSSID]), MSG_WARNING)
                pass
            elif _PortSSID2BSSID[InitialPort].has_key(BSSID):
                #Test to see if 2 BSSIDs match the same SSID
                if _PortSSID_dupe[InitialPort].has_key(BSSID):
                    OutputstreamHDL("Warning: Port %s SSID:'%s' matches BSSID %s, using %s\n" % (InitialPort, BSSID, _PortSSID_dupe[InitialPort][BSSID], _PortSSID2BSSID[InitialPort][BSSID]), MSG_WARNING)
                BSSID = _PortSSID2BSSID[InitialPort][BSSID]
            else:
                OutputstreamHDL("Error: Client:%s Port:%s can not match '%s' to any known BSSID or SSID\n" % (BaseName, InitialPort, BSSID), MSG_ERROR)
                ReturnSuccess = False
                
            # here is where IETF draft-ietf-bmwg-hash-stuffing-05 is supported
            if Base_MAC.upper() == 'DEFAULT':
                Base_MAC = IETF_MAC(PortsToScan.index(InitialPort) + 1)
                if len(IncrTuple) == 3:
                    IncrTuple = ( IncrTuple[0], 'DEFAULT', IncrTuple[2] )
            ClientList[x] = (BaseName, PortName, BSSID, Base_MAC,  Base_IP, Subnet, Gateway, IncrTuple, Security, Options)
    return ReturnSuccess

def SetTxpower(power):
    VCLtest("mc.setTxPower(%d)" % power, globals()) 

def UpdateTxpower(clientname):
    VCLtest("mc.updateTxPowerModulation('%s')" % (clientname), globals()) 

def UpdateBssid(clientname, bssid):
    VCLtest("mc.updateBssid('%s', '%s')" % (clientname, bssid), globals())

def SetActiveBssid(clientname, port, bssid):
    VCLtest("mc.setActiveBssid('%s', '%s', '%s')" %(clientname,port, bssid))
    
def Getroamdelay(clientname, secClass = 1):
    VCLtest("clientStats.read('%s')" % (clientname), globals())
    VCLtest("clientStats.read('%s')" % (clientname), globals())
    probe_response_time = (clientStats.tstampProbeRsp - clientStats.txMcStartTime)/1000000.0
    auth_time_80211= (clientStats.tstampAuth1Rsp - clientStats.tstampAuth1Req)/1000000.0
    assoc_time = (clientStats.rxMcAssociationEndTime - clientStats.txMcAssociationStartTime)/1000000.0
    process_time = clientStats.tgaProcessingTime
    roam_start = clientStats.txMcStartTime
    roam_end = clientStats.rxMcStartTime
    total_roam_delay = (roam_end - roam_start)/1000000.0
    roam_delay = ((roam_end - roam_start - process_time)/1000000.0)
    
    #The defaults for these metrics
    WEPauthReqTS = 'NA'
    WepauthRspTS = 'NA'
    WEPauthTime = 'NA'
    EapReqIdTS = 'NA'
    EAPOLGroupKeyTS = 'NA'
    AuthTime = 'NA'
    
    if secClass == 1:    #Security: Open, WEP-Open
        pass    #All defaults 
        
    elif secClass == 2:    #WEP
        WEPauthReqTS = clientStats.tstampAuth2Req
        WepauthRspTS = clientStats.tstampAuth2Rsp
        WEPauthTime = clientStats.tstampAuth2Rsp - clientStats.tstampAuth2Req
        
    elif secClass == 3 :    #WPA-PSK, WPA2-PSK 
        AuthTime = (clientStats.tstampMcConnectionComplete - 
                    clientStats.rxMcAssociationEndTime)/1000000.0 
        
    elif secClass == 4:    #CCKM methods
        EAPOLGroupKeyTS = clientStats.tstampMcConnectionComplete
        AuthTime = (clientStats.tstampMcConnectionComplete - 
                    clientStats.rxMcAssociationEndTime)/1000000.0 
        
    elif secClass == 5:             # 802.1x
        EapReqIdTS = clientStats.tstampEapReqIdentity
        EAPOLGroupKeyTS = clientStats.tstampMcConnectionComplete
        AuthTime = (clientStats.tstampMcConnectionComplete - 
                    clientStats.rxMcAssociationEndTime)/1000000.0 
        
    roamDelayDetails = {
                        'Total Roam Delay':total_roam_delay,
                        'Client Delay':process_time/1000000.0,
                        'AP Roam Delay':roam_delay,
                        'Probe Request Timestamp':clientStats.txMcStartTime,
                        'Probe Response Timestamp':clientStats.tstampProbeRsp,
                        'AP Probe Response Delay': probe_response_time,
                        '802.11 Auth Request Timestamp':clientStats.tstampAuth1Req,
                        '802.11 Auth Response Timestamp':clientStats.tstampAuth1Rsp,
                        'AP 802.11 Auth Delay': auth_time_80211,
                        'WEP Auth Request Timestamp': WEPauthReqTS,
                        'WEP Auth Response Timestamp':WepauthRspTS,
                        'AP WEP Auth Delay': WEPauthTime,
                        'Assoc Request Timestamp':clientStats.txMcAssociationStartTime,
                        'Assoc Response Timestamp':clientStats.rxMcAssociationEndTime,
                        'AP Assoc Delay':assoc_time,
                        'EAP ReqIdentity Timestamp':EapReqIdTS,
                        'EAPOL Group Key Timestamp':EAPOLGroupKeyTS,
                        'Auth Time':AuthTime
                        }

    roamFailStage = _getRoamFailStage(clientname, roam_delay)
        
    return roamDelayDetails, roamFailStage

def GetRoamdelayLegacy(clientname, secClass = 1):
    VCLtest("clientStats.read('%s')" % (clientname), globals())
    VCLtest("clientStats.read('%s')" % (clientname), globals())
    probe_response_time = (clientStats.tstampProbeRsp - clientStats.txMcStartTime)/1000000.0
    auth_time_80211= (clientStats.tstampAuth1Rsp - clientStats.tstampAuth1Req)/1000000.0
    assoc_time = (clientStats.rxMcAssociationEndTime - clientStats.txMcAssociationStartTime)/1000000.0
    process_time = clientStats.tgaProcessingTime
    roam_start = clientStats.txMcStartTime
    roam_end = clientStats.rxMcStartTime
    total_roam_delay = (roam_end - roam_start)/1000000.0
    roam_delay = ((roam_end - roam_start - process_time)/1000000.0)
    if secClass == 1:    #Security: Open, WEP-Open
        roamStats = (total_roam_delay, process_time/1000000.0, roam_delay, 
                     clientStats.txMcStartTime, clientStats.tstampProbeRsp, 
                     probe_response_time, clientStats.tstampAuth1Req, 
                     clientStats.tstampAuth1Rsp, auth_time_80211, "NA", "NA", 
                     "NA", clientStats.txMcAssociationStartTime, 
                     clientStats.rxMcAssociationEndTime, assoc_time, "NA", "NA", "NA")

    elif secClass == 2:    #WEP
        WEP_auth_time = clientStats.tstampAuth2Rsp - clientStats.tstampAuth2Req
        
        roamStats = (total_roam_delay, process_time/1000000.0, roam_delay, 
                     clientStats.txMcStartTime, clientStats.tstampProbeRsp, 
                     probe_response_time, clientStats.tstampAuth1Req, 
                     clientStats.tstampAuth1Rsp, auth_time_80211, 
                     clientStats.tstampAuth2Req, clientStats.tstampAuth2Rsp, 
                     WEP_auth_time, clientStats.txMcAssociationStartTime,
                     clientStats.rxMcAssociationEndTime, assoc_time, "NA", "NA", "NA")
         
    elif secClass == 3 :    #WPA-PSK, WPA2-PSK 
        auth_time = (clientStats.tstampMcConnectionComplete - clientStats.rxMcAssociationEndTime)/1000000.0 
        
        roamStats = (total_roam_delay, process_time/1000000.0, roam_delay, 
                     clientStats.txMcStartTime, clientStats.tstampProbeRsp, 
                     probe_response_time, clientStats.tstampAuth1Req, 
                     clientStats.tstampAuth1Rsp, auth_time_80211, "NA", "NA", 
                     "NA", clientStats.txMcAssociationStartTime, 
                     clientStats.rxMcAssociationEndTime, assoc_time, "NA", "NA", 
                     auth_time)

    elif secClass == 4:    #CCKM methods
        auth_time = (clientStats.tstampMcConnectionComplete - clientStats.rxMcAssociationEndTime)/1000000.0 
        
        roamStats = (total_roam_delay, process_time/1000000.0, roam_delay, 
                     clientStats.txMcStartTime, clientStats.tstampProbeRsp, 
                     probe_response_time, clientStats.tstampAuth1Req, 
                     clientStats.tstampAuth1Rsp, auth_time_80211, 'NA', 'NA', 
                     'NA', clientStats.txMcAssociationStartTime, 
                     clientStats.rxMcAssociationEndTime, assoc_time, 
                     'NA', 
                     clientStats.tstampMcConnectionComplete, auth_time)
        
    elif secClass == 5:             # 802.1x
        auth_time = (clientStats.tstampMcConnectionComplete - clientStats.rxMcAssociationEndTime)/1000000.0 
        
        roamStats = (total_roam_delay, process_time/1000000.0, roam_delay, 
                     clientStats.txMcStartTime, clientStats.tstampProbeRsp, 
                     probe_response_time, clientStats.tstampAuth1Req, 
                     clientStats.tstampAuth1Rsp, auth_time_80211, "NA", "NA", 
                     "NA", clientStats.txMcAssociationStartTime, 
                     clientStats.rxMcAssociationEndTime, assoc_time, 
                     clientStats.tstampEapReqIdentity, 
                     clientStats.tstampMcConnectionComplete, auth_time)
    
    roamFailStage = _getRoamFailStage(clientname, roam_delay)
        
    return roamStats, roamFailStage

def _getRoamFailStage(clientName, roam_delay):
    #Find the roam failure step, 
    roamFailStage = ''
    if roam_delay < 0:
        connectionStageList = ['Probe response', 'Authentication request',
                               'Authentication response', 'Authentication request 2', 
                               'Authentication response 2', 'Association request', 
                               'Association response', 'EAP identity request', 
                               'EAP identity response', 'EAP Success or Failure', 
                               'EAPOL pairwise key installed', 
                               'EAPOL group key installed', 
                               'EAPOL pairwise key installed', 'DHCP discover', 
                               'DHCP offer', 'DHCP request', 'DHCP ACK']
        connTranscript = ConnectionTranscript(clientName)
        
        for connStage in connectionStageList:
            result = connTranscript.get(connStage, 'NA')
            if result == 'FAILED':
                statusCode = mc.checkStatusCode(clientName)
                roamFailStage = "%s: FAILED.\nStatus Code: %d"%(connStage, statusCode)
                break
        else:    #Implies clientStats.rxMcStartTime == 0
            roamFailStage = 'No Downstream packet received'
            
    return roamFailStage

def GetTxflowstats(portname, flowname):
    VCLtest("flowStats.read('%s', '%s')" % (portname, flowname), globals())
    return flowStats.txFlowFramesOk

def GetRxflowstats(portname, flowname):
    VCLtest("flowStats.read('%s', '%s')" % (portname, flowname), globals())
    return flowStats.rxFlowFramesOk

def GetPortstats(portname):
    VCLtest("stats.read('%s')" % (portname), globals())
    TXframes = RXframes = TXrate = RXrate = 0
    if GetCachePortInfo(portname) == '8023':
        TXframes = stats.txMacFrames 
        RXframes = stats.rxMacFrames
        TXrate = stats.txMacFramesRate
        RXrate = stats.rxMacFramesRate
    if GetCachePortInfo(portname) in WiFiPortTypes:
        TXframes = stats.txMacData
        RXframes = stats.rxMacData
        TXrate = stats.txMacDataRate
        RXrate = stats.rxMacDataRate
    return (TXframes, RXframes, TXrate, RXrate)

def StopFlowgrp(groupname):
    VCLtest("action.stopFlowGroup('%s')" % (groupname), globals())

def StartFlowgrp(groupname):
    VCLtest("action.startFlowGroup('%s')" % (groupname), globals())

def moveFlows(srcGrp, dstGrp):
    VCLtest("flowGroup.read('%s')" % (srcGrp))
    for flowName in flowGroup.getFlowNames(srcGrp):
        VCLtest("flowGroup.move('%s', '%s', '%s')" % (flowName, srcGrp,
            dstGrp))

def ConfigureLearnFlow(groupname, fromGrpname, flowname, numpkts, framesize, 
        ratemode, rate, src, dst):

    #These config values don't change. Keeping it commented for now
    #VCLtest("flow.setFrameSize(%d)" % (framesize), globals())
    #VCLtest("flow.setRateMode('%s')" % (ratemode), globals())
    #VCLtest("flow.setIntendedRate(%d)" % (rate), globals())
    #VCLtest("flow.setSrcClient('%s')" % (src), globals())
    #VCLtest("flow.setDestClient('%s')" % (dst), globals())

    moveFlows(groupname, fromGrpname)
    VCLtest("flowGroup.move('%s', '%s', '%s')" % (flowname, fromGrpname,
        groupname), globals())
    VCLtest("action.stopFlowGroup('%s')" % (groupname), globals())
    VCLtest("flow.read('%s')" % (flowname), globals())
    VCLtest("flow.setNumFrames(%d)" % (numpkts), globals())

def UnConfigureLearnFlow(groupname, nogroupname, flowname):
    VCLtest("flowGroup.move('%s', '%s', '%s')" % (flowname, groupname, 
        nogroupname))

def GetBssidSsid(portname, bssid):
    VCLtest("port.read('%s')" % (portname), globals())
    return port.getBssidSsid(bssid)

def MCdisassociate(clientname):
    VCLtest("mc.disassociate('%s', %d)" % (clientname, 0), globals())

def MCdeauthenticate(clientname):
    VCLtest("mc.deauthenticate('%s', %d)" % (clientname, 0), globals())

def MCconfigureReassocOn():
    VCLtest("mc.setUseReassociation('%s')" % "on", globals())

def MCsetPreAuth(clientname, port, bssid):
    returnVal = VCLtest("mc.doPreauthBssid('%s', '%s', '%s')" % (clientname, port, bssid),
                        globals())
    return returnVal

##################################### CreateClients ###################################
#Per Carl, These are the only types of security profiles we support 
#                    Name                        security apAuthMethod keyMethod   networkAuthMethod encryptionMethod Options
_SecurityProfile = {'NONE':                       ( 'off',   'open',      'none',       'none',            'none',   []),
                    'WEP-OPEN-40':                ( 'on',    'open',      'wepStatic',  'none',            'wep40',  ['KeyId', 'NetworkKey', 'KeyType']),
                    'WEP-OPEN-128':               ( 'on',    'open',      'wepStatic',  'none',            'wep104', ['KeyId', 'NetworkKey', 'KeyType']),
                    'WEP-SHAREDKEY-40':           ( 'on',    'shared',    'wepStatic',  'none',            'wep40',  ['KeyId', 'NetworkKey', 'KeyType']),
                    'WEP-SHAREDKEY-128':          ( 'on',    'shared',    'wepStatic',  'none',            'wep104', ['KeyId', 'NetworkKey', 'KeyType']),
                    'WPA-PSK':                    ( 'on',    'open',      'wpa',        'psk',             'tkip',   ['NetworkKey']),
                    'WPA-EAP-TLS':                ( 'on',    'open',      'wpa',        'eapTls',          'tkip',   ['Identity', 'Password', 'RootCertificate', 'ClientCertificate', 'PrivateKeyFile']),
                    'WPA-EAP-TLS-AES':            ( 'on',    'open',      'wpa',        'eapTls',          'ccmp',    ['Identity', 'Password', 'RootCertificate', 'ClientCertificate', 'PrivateKeyFile']),
                    'WPA-EAP-TTLS-GTC':           ( 'on',    'open',      'wpa',        'eapTtlsGtc',      'tkip',   ['Identity', 'Password', 'RootCertificate', 'AnonymousIdentity']),
                    'WPA-PEAP-MSCHAPV2':          ( 'on',    'open',      'wpa',        'peapMschapv2',    'tkip',   ['Identity', 'Password', 'RootCertificate', 'EnableValidateCertificate', 'AnonymousIdentity']),
                    'WPA-EAP-FAST':               ( 'on',    'open',      'wpa',        'eapFast',         'tkip',   ['Identity', 'Password']),
                    'WPA2-PSK':                   ( 'on',    'open',      'wpa2',       'psk',             'ccmp',   ['NetworkKey']),
                    'WPA2-EAP-TLS':               ( 'on',    'open',      'wpa2',       'eapTls',          'ccmp',   ['Identity', 'Password', 'RootCertificate', 'ClientCertificate', 'PrivateKeyFile']),
                    'WPA2-EAP-TTLS-GTC':          ( 'on',    'open',      'wpa2',       'eapTtlsGtc',      'ccmp',   ['Identity', 'Password', 'RootCertificate', 'AnonymousIdentity']),
                    'WPA2-PEAP-MSCHAPV2':         ( 'on',    'open',      'wpa2',       'peapMschapv2',    'ccmp',   ['Identity', 'Password', 'RootCertificate', 'EnableValidateCertificate', 'AnonymousIdentity']),
                    'WPA2-EAP-FAST':              ( 'on',    'open',      'wpa2',       'eapFast',         'ccmp',   ['Identity', 'Password']),
                    'DWEP-EAP-TLS':               ( 'on',    'open',      'wepDynamic', 'eapTls',          'wep104', ['Identity', 'Password', 'RootCertificate', 'ClientCertificate', 'PrivateKeyFile']),
                    'DWEP-EAP-TTLS-GTC':          ( 'on',    'open',      'wepDynamic', 'eapTtlsGtc',      'wep104', ['Identity', 'Password', 'RootCertificate', 'AnonymousIdentity']),
                    'DWEP-PEAP-MSCHAPV2':         ( 'on',    'open',      'wepDynamic', 'peapMschapv2',    'wep104', ['Identity', 'Password', 'RootCertificate', 'EnableValidateCertificate', 'AnonymousIdentity']),
                    'LEAP':                       ( 'on',    'open',      'wepDynamic', 'leap',            'wep104', ['Identity', 'Password']), 
                    'WPA-LEAP':                   ( 'on',    'open',      'wpa',        'leap',            'tkip',   ['Identity', 'Password']),
                    'WPA2-LEAP':                  ( 'on',    'open',      'wpa2',       'leap',            'ccmp',   ['Identity', 'Password']), 
                    'WPA-PSK-AES':                ( 'on',    'open',      'wpa',        'psk',             'ccmp',   ['NetworkKey']),
                    'WPA-PEAP-MSCHAPV2-AES':      ( 'on',    'open',      'wpa',        'peapMschapv2',    'ccmp',   ['Identity', 'Password', 'RootCertificate', 'EnableValidateCertificate', 'AnonymousIdentity']),
                    'WPA2-PEAP-MSCHAPV2-TKIP':    ( 'on',    'open',      'wpa2',       'peapMschapv2',    'tkip',   ['Identity', 'Password', 'RootCertificate', 'EnableValidateCertificate', 'AnonymousIdentity']),
                    'WPA2-EAP-TLS-TKIP':          ( 'on',    'open',      'wpa2',       'eapTls',          'tkip',   ['Identity', 'Password', 'RootCertificate', 'ClientCertificate', 'PrivateKeyFile']),
                    'WPA2-PSK-TKIP':              ( 'on',    'open',      'wpa2',       'psk',             'tkip',   ['NetworkKey']),
                    'WPA-CCKM-PEAP-MSCHAPV2-TKIP':( 'on',    'open',      'wpa_cckm',   'peapMschapv2',    'tkip',   ['Identity', 'Password', 'RootCertificate', 'EnableValidateCertificate', 'AnonymousIdentity']),
                    'WPA-CCKM-PEAP-MSCHAPV2-AES-CCMP':( 'on', 'open',     'wpa_cckm',   'peapMschapv2',    'ccmp',   ['Identity', 'Password', 'RootCertificate', 'EnableValidateCertificate', 'AnonymousIdentity']), 
                    'WPA-CCKM-TLS-TKIP':          ( 'on',    'open',      'wpa_cckm',   'eapTls',          'tkip',   ['Identity', 'Password', 'RootCertificate', 'ClientCertificate', 'PrivateKeyFile']),  
                    'WPA-CCKM-TLS-AES-CCMP':      ( 'on',    'open',      'wpa_cckm',   'eapTls',          'ccmp',   ['Identity', 'Password', 'RootCertificate', 'ClientCertificate', 'PrivateKeyFile']),
                    'WPA-CCKM-LEAP-TKIP':         ( 'on',    'open',      'wpa_cckm',   'leap',            'tkip',   ['Identity', 'Password']),   
                    'WPA-CCKM-LEAP-AES-CCMP':     ( 'on',    'open',      'wpa_cckm',   'leap',            'ccmp',   ['Identity', 'Password']),
                    'WPA-CCKM-FAST-TKIP':         ( 'on',    'open',      'wpa_cckm',   'eapFast',         'tkip',   ['Identity', 'Password']),
                    'WPA-CCKM-FAST-AES-CCMP':     ( 'on',    'open',      'wpa_cckm',   'eapFast',         'ccmp',   ['Identity', 'Password']),
                    'WPA2-CCKM-PEAP-MSCHAPV2-TKIP':('on',    'open',     'wpa2_cckm',  'peapMschapv2',    'tkip',   ['Identity', 'Password', 'RootCertificate', 'EnableValidateCertificate', 'AnonymousIdentity']),
                    'WPA2-CCKM-PEAP-MSCHAPV2-AES-CCMP':('on','open',      'wpa2_cckm',  'peapMschapv2',    'ccmp',   ['Identity', 'Password', 'RootCertificate', 'EnableValidateCertificate', 'AnonymousIdentity']), 
                    'WPA2-CCKM-TLS-TKIP':         ( 'on',    'open',      'wpa2_cckm',  'eapTls',          'tkip',   ['Identity', 'Password', 'RootCertificate', 'ClientCertificate', 'PrivateKeyFile']),
                    'WPA2-CCKM-TLS-AES-CCMP':     ( 'on',    'open',      'wpa2_cckm',  'eapTls',          'ccmp',   ['Identity', 'Password', 'RootCertificate', 'ClientCertificate', 'PrivateKeyFile']),
                    'WPA2-CCKM-LEAP-TKIP':        ( 'on',    'open',      'wpa2_cckm',  'leap',            'tkip',   ['Identity', 'Password']), 
                    'WPA2-CCKM-LEAP-AES-CCMP':    ( 'on',    'open',      'wpa2_cckm',  'leap',            'ccmp',   ['Identity', 'Password']), 
                    'WPA2-CCKM-FAST-TKIP':        ( 'on',    'open',      'wpa2_cckm',  'eapFast',         'tkip',   ['Identity', 'Password']),
                    'WPA2-CCKM-FAST-AES-CCMP':    ( 'on',    'open',      'wpa2_cckm',  'eapFast',         'ccmp',   ['Identity', 'Password'])}
# Dict of 802.1x authentication methods supported for the Ethernet client
#                    Name                security networkAuthMethod  Options
_EthAuthProfile =  {
                    'NONE':               ('off', 'none',            []),                    
                    'EAP/TLS':            ('on',  'tls8021x',        ['Identity', 'Password', 'RootCertificate', 'ClientCertificate', 'PrivateKeyFile']),
                    'EAP/TTLS-GTC':       ('on',  'ttls8021x',       ['Identity', 'Password', 'RootCertificate', 'AnonymousIdentity']),
                    'PEAP/MSCHAPV2':      ('on',  'peap8021x',       ['Identity', 'Password', 'RootCertificate', 'EnableValidateCertificate', 'AnonymousIdentity']),                    
                    }
#
# LoginList = List of Users for the authenication server in the form [ (Username1, Password1), (Username2, Password2), (Username3, Password3), ... ]
#
_ClientMACCounter = 0
def SetClientMACCounter():
    global _ClientMACCounter
    _ClientMACCounter = 0
def CreateClients (ClientList, ClientOptions={}, SecurityProfile=_SecurityProfile, LoginList=None, EthAuthProfile=_EthAuthProfile):
    """
    Creates clients on the ports.
    ClientList = (BaseName, Port, BSSID, Base_MAC,  Base_IP, Subnet, 
                  Gateway, (Count=1, Incr_MAC='0:0:0:0:0:0', Incr_IP='0.0.0.0'),
                  SecurityMethod, Options)
    Returns a dictionarry of created clients tuples ( Status, PortName, EC or MC, )
    """
    global _ClientMACCounter
    global _PortLocation
    ListofClientProperties = OrderedDict()
    StartTime = time.time()
    ClientCounter = 1
    StartCounter  = ClientCounter
    LoginCounter  = 0
    TotalClients  = 0
    
    # type of LoginList:
    LoginListType = None
    if LoginList != None:
        if isinstance( LoginList, list ):
            LoginListType = 'list'
        elif isinstance( LoginList, dict ):
            LoginListType = 'dict'

    #Precount the Number of clients
    for (BaseName, PortName, BSSID, MACaddr, IPaddr, Subnet, Gateway, IncrTuple, SecurityOptions, ClientOptions) in ClientList:
        if len(IncrTuple) == 3:
            TotalClients  += int(IncrTuple[0])
        else:
            TotalClients  += 1     

    for (BaseName, PortName, BSSID, MACaddr, IPaddr, Subnet, Gateway, IncrTuple, SecurityOptions, ClientOptions) in ClientList:
        if not isinstance(SecurityOptions, dict):
            OutputstreamHDL("Warning: Client %s SecurityOptions is not a dictionary (defaulting to open)\n" % (BaseName), MSG_WARNING)
            SecurityOptions = {'Method': 'NONE', 'KeyId' : 'Butter', 'NetworkKey': '00:00:00:00:00:00', 'Identity': 'anonymous', 'Password' : 'whatever'}
        if not SecurityOptions.has_key('Method'):
            OutputstreamHDL("Warning: Client %s SecurityOptions does not have a 'Method' key (defaulting to open)\n" % (BaseName), MSG_WARNING)
            SecurityOptions = {'Method': 'NONE', 'KeyId' : 'Butter', 'NetworkKey': '00:00:00:00:00:00', 'Identity': 'anonymous', 'Password' : 'whatever'}
        if LoginListType == 'dict':
            # reset counter since a dictionary of lists is used per-group.
            LoginCounter = 0

        # initial IP address
        IPnum    = IPv4toInt(IPaddr)

        # initial MAC address
        if MACaddr == 'AUTO':
            # VPR 3657
            # automatic mode -- assign MAC by cc:ss:pp:ip:ip:ip
            # get port location ( first port if a list is given )
            if isinstance( PortName, list ):
                loc = _PortLocation[ PortName[0] ]
            else:
                loc = _PortLocation[ PortName ]
            # get chassis number ( FIXME -- this is a crude way to do it )
            chassisList = []
            for eachPort in _PortLocation:
                ch = _PortLocation[ eachPort ][ 0 ]
                if ch not in chassisList:
                    chassisList.append( ch )
            chassisNum = chassisList.index( loc[0] )
            # get client IP address for last three bytes of the MAC
            if IPnum == 0:
                # dhcp, use client counter instead
                #VPR 4202. The _ClientMACCounter also helps distinguish the clients belonging
                #to different groups based on their MAC. Client group (with dhcp)created first
                #on a port would have third octet from right as '1' (in its MAC), group
                #created next would have that octet value as '2' and so on. 
                _ClientMACCounter +=1
                lowIPnum = (_ClientMACCounter << 16) & 0xFF0000
            else:
                # static IP, use lowest three bytes
                lowIPnum = IPnum & 0xFFFFFF
            # assemble new MAC address
            newMACnum = '%02x:%02x:%02x:%02x:%02x:%02x' % ( chassisNum * 2,
                                                            loc[1],
                                                            loc[2],
                                                            ( lowIPnum & 0xFF0000 ) >> 16,
                                                            ( lowIPnum & 0x00FF00 ) >> 8,
                                                            ( lowIPnum & 0x0000FF ) >> 0 )
            # got the next MAC address
            MACnum = MACaddress(newMACnum)
        else:
            MACnum = MACaddress( MACaddr )
            #VPR 4035. If the least significant bit in the most significant byte
            #is '1' the address is multicast. Should we do this check for each client?
            #what if the base is e.g. 00:ff:ff:ff:ff:ff or 74:ff:ff:ff:ff:ff and increment
            #mode is set? When increment is performed the most significant byte is not altered
            #so, inc would not move them to 01:ff:ff:ff:ff:ff but instead to 01:00:00:00:00:00
            
            #if  int('0x' + MACaddr.split(':')[0], 16) % 2 == 1:    #Usage int('string', base)
            if MACnum.isMulticast():
                OutputstreamHDL("The base MAC address used for %s is a multicast address(The least significant bit in the most significant byte is '1')" % (BaseName), MSG_WARNING) 
            
        #print "init mac for Clientgrp -", BaseName ,"MAC", MACnum

        if isinstance(PortName, list):
            ConnectCompleteCMD = ''
            FirstPortName = PortName[0]
            for EachPortname in PortName:
                if GetCachePortInfo(EachPortname) == '8023':
                    if ConnectCompleteCMD == 'mc':
                        OutputstreamHDL("\nError: Client %s is attempting to roam between 802.11 and 802.3 ports.\n" % (BaseName), MSG_ERROR)
                        raise RaiseException
                    else:
                        ConnectCompleteCMD   = 'ec'
                elif GetCachePortInfo(EachPortname) in WiFiPortTypes:
                    if ConnectCompleteCMD == 'ec':
                        OutputstreamHDL("\nError: Client %s is attempting to roam between 802.3 and 802.11 ports.\n" % (BaseName), MSG_ERROR)
                        raise RaiseException
                    else:
                        ConnectCompleteCMD   = 'mc'
                else:
                    OutputstreamHDL("\nError: Client %s is using port %s of an unknown type %s.\n" % (BaseName, EachPortname, GetCachePortInfo(EachPortname) ), MSG_ERROR)
                    raise RaiseException
        else:
            FirstPortName = PortName
            if GetCachePortInfo(FirstPortName) == '8023':
                ConnectCompleteCMD   = 'ec'
            elif GetCachePortInfo(FirstPortName) in WiFiPortTypes:
                ConnectCompleteCMD   = 'mc'
            else:
                OutputstreamHDL("\nHoly atomic pile, Batman! Client %s Port %s is unknown type (%s)\n" % (BaseName, FirstPortName, GetCachePortInfo(FirstPortName)), MSG_ERROR)
                raise RaiseException
        
        #Process the option field
        OptionList = []
        clientLearnF = False
        enableNetworkInterface = False
        loopbackMode = False
        
        for OptionKey in ClientOptions.keys():
            if OptionKey == "ClientLearning":
                if ClientOptions[OptionKey] == "on":
                    clientLearnF = True
            if OptionKey == "ConnectMode":
                if ClientOptions[OptionKey] == "loopback":
                    loopbackMode = True
            if OptionKey == "enableNetworkInterface":
                enableNetworkInterface = True
            else:
                OptionMethod = "set%s" % (OptionKey)
                if OptionMethod in getMethods(ConnectCompleteCMD):
                    if isnum(ClientOptions[OptionKey]):
                        OptionList.append("%s.%s(%s)" % (ConnectCompleteCMD, OptionMethod, ClientOptions[OptionKey]) )
                    else:
                        OptionList.append("%s.%s('%s')" % (ConnectCompleteCMD, OptionMethod, ClientOptions[OptionKey]) )
                else:
                    OutputstreamHDL("Warning: Client %s option '%s' not supported (ignoring)\n" % (ConnectCompleteCMD, OptionKey), MSG_WARNING)
        
        #if count tuple does not have 3 entries set default
        # print "IncrTuple", IncrTuple
        if len(IncrTuple) == 3:
            Count  = int(IncrTuple[0])
            if IncrTuple[1].upper() in [ 'DEFAULT', 'AUTO' ]:
                MACinc = IncrTuple[1].upper()
            else:
                MACinc = MACaddress(IncrTuple[1])
            IPinc  = IPv4toInt(IncrTuple[2])
        else:
            Count  = 1     
            MACinc = 1
            IPinc  = 0
            
        # Loop thru all clients for this group.
        for RepeatClient in range(Count):
            Check4UserEscape()
            if Count == 1:
                ClientName = BaseName
            else:
                ClientName = BaseName + "_%03d" % (ClientCounter)

            if IPnum > 4278190078:
                OutputstreamHDL("Error: Client %s has an illegal IPv4 address of %s.\n" % (ClientName, int2IPv4(IPnum)), MSG_ERROR)
                raise RaiseException

            clientType = 'ec'
            ConnectCompleteState = -1
            if ConnectCompleteCMD == 'ec':
                ConnectCompleteState = EthernetClientCode
                VCLtest("ec.create('%s')"        % (ClientName))
                VCLtest("ec.setMacAddress('%s')" % (MACnum))
                if IPnum == 0:
                    VCLtest("ec.setIpAddressMode('dhcp')")
                    IPinc  = 0
                else:
                    VCLtest("ec.setIpAddressMode('static')")
                    VCLtest("ec.setIpAddress('%s')"  % (int2IPv4(IPnum)))
                    VCLtest("ec.setSubnetMask('%s')" % (Subnet))
                    VCLtest("ec.setGateway('%s')"    % (Gateway))

                #Process Ethernet Client type options
                for CurrentOption in OptionList:
                    VCLtest(CurrentOption)

                if isinstance(PortName, list):
                    if len(PortName) > 1:
                        OutputstreamHDL("\nError: 802.3 client %s wants to roam ports. (not supported)\n" % (BaseName), MSG_ERROR)
                        raise RaiseException
                VCLtest("ec.setPort('%s')"           % (FirstPortName))
                VCLtest("ec.write('%s')"             % (ClientName))
                
            elif ConnectCompleteCMD == 'mc':
                ConnectCompleteState = ClientStateAssoc
                clientType = 'mc'
                VCLtest("mc.create('%s')"        % (ClientName))
                VCLtest("mc.setMacAddress('%s')" % (MACnum))
                if IPnum == 0:
                    VCLtest("mc.setIpAddressMode('dhcp')")
                    IPinc  = 0
                else:
                    VCLtest("mc.setIpAddressMode('static')")
                    VCLtest("mc.setIpAddress('%s')"  % (int2IPv4(IPnum)))
                    VCLtest("mc.setSubnetMask('%s')" % (Subnet))
                    VCLtest("mc.setGateway('%s')"    % (Gateway))
                if isinstance(PortName, list):
                    VCLtest("mc.setPortList(%s)" % (PortName))
                else:
                    VCLtest("mc.setPortList(['%s'])" % (FirstPortName))
                if loopbackMode == False:
                    if isinstance(BSSID, list):
                        VCLtest("mc.setBssidList(%s)" % (BSSID))
                        VCLtest("mc.setSsid('%s')" % (GetCacheSSID(FirstPortName, BSSID[0])))
                    else:
                        VCLtest("mc.setBssidList(['%s'])" % (BSSID))
                        VCLtest("mc.setSsid('%s')" % (GetCacheSSID(FirstPortName, BSSID)))
                        
                # Process Wireless Client type options
                for CurrentOption in OptionList:
                    VCLtest(CurrentOption)
                    
                VCLtest("mc.write('%s')"         % (ClientName))
            else:
                OutputstreamHDL("\nPort %s is unknown type (%s)\n" % (FirstPortName, GetCachePortInfo(FirstPortName)), MSG_ERROR)

            #If security is set, the configure it
            secOK = False
            if clientType == 'mc' and SecurityProfile.has_key(SecurityOptions['Method'].upper()):
                Security = SecurityOptions['Method']                
                CurrentSec = SecurityProfile[Security.upper()]
                VCLtest("mc.setSecurity('%s')"          % (CurrentSec[0]))
                VCLtest("mc.setApAuthMethod('%s')"      % (CurrentSec[1]))
                VCLtest("mc.setKeyMethod('%s')"         % (CurrentSec[2]))
                VCLtest("mc.setNetworkAuthMethod('%s')" % (CurrentSec[3]))
                VCLtest("mc.setEncryptionMethod('%s')"  % (CurrentSec[4]))
                secOptions = CurrentSec[5]
                secOK = True
            elif clientType == 'ec': 
                if (SecurityOptions.has_key('EthNetworkAuthMethod') and \
                    EthAuthProfile.has_key(SecurityOptions['EthNetworkAuthMethod'].upper())):
                    Security = SecurityOptions['EthNetworkAuthMethod']       
                    CurrentSec = EthAuthProfile[Security.upper()]  
                    VCLtest("ec.setSecurity('%s')"          % (CurrentSec[0]))                                                       
                    VCLtest("ec.setNetworkAuthMethod('%s')" % (CurrentSec[1]))  
                    secOptions = CurrentSec[2]    
                    secOK = True                                  
            else:
                OutputstreamHDL("\Warning: Client %s with Security method %s is not supported\n" % (ClientName, Security.upper()), MSG_WARNING)
            if secOK:
                for OptionKey in secOptions:
                    loginMethod = SecurityOptions.get( 'LoginMethod', '' )                        
                    if SecurityOptions.has_key(OptionKey):
                        #VPR3541 - Cycle through a list of username/passwords
                        if OptionKey == 'Identity' or OptionKey == 'Password':
                            if LoginListType == 'list':
                                # LoginList exists an will be used to provide
                                # per-client identities and passwords across all groups.
                                (UserName, Password) = LoginList[LoginCounter]
                                if OptionKey == 'Identity':
                                    VCLtest("%s.set%s('%s')" % (clientType, OptionKey, UserName) )
                                else:
                                    VCLtest("%s.set%s('%s')" % (clientType, OptionKey, Password) )
                            elif LoginListType == 'dict':
                                # dictionary lookup
                                try:
                                    (UserName, Password) = LoginList[ BaseName ][ LoginCounter ]
                                except:
                                    # group doesn't exist in dictionary, use default values
                                    UserName = SecurityOptions.get( 'Identity', '' )
                                    Password = SecurityOptions.get( 'Password', '' )
                                if OptionKey == 'Identity':
                                    VCLtest("%s.set%s('%s')" % (clientType, OptionKey, UserName) )
                                else:
                                    VCLtest("%s.set%s('%s')" % (clientType, OptionKey, Password) )
                            elif loginMethod == "Increment":
                                UserName = SecurityOptions.get( 'Identity', '' )
                                Password = SecurityOptions.get( 'Password', '' )
                                startIndx = int(SecurityOptions.get( 'StartIndex'))                                    
                                uName = str( UserName + "%04d" % ( startIndx + RepeatClient ))
                                pwd = str( Password + "%04d" % ( startIndx + RepeatClient ))
                                if OptionKey == 'Identity':
                                    VCLtest("%s.set%s('%s')" % (clientType, OptionKey, uName) )
                                else:
                                    VCLtest("%s.set%s('%s')" % (clientType, OptionKey, pwd) )                                                                        
                            else:
                                # no LoginList specified, so use the per-group
                                # identity and password.
                                VCLtest("%s.set%s('%s')" % (clientType, OptionKey, SecurityOptions[OptionKey]) )
                            # endif
                    
                        elif isnum(SecurityOptions[OptionKey]) and OptionKey == 'KeyId':
                            VCLtest("%s.set%s(%s)" % (clientType, OptionKey, SecurityOptions[OptionKey]) )
                        elif OptionKey == 'ClientCertificate' and loginMethod == "Increment":
                            clCert = SecurityOptions.get( 'ClientCertificate', '' )
                            startIndx = int(SecurityOptions.get( 'StartIndex'))
                            if clCert != '':
                                clientCertSplit = clCert.split('/')
                                clientCertName = clientCertSplit.pop()
                                clientCertPath = ""
                                for ii in range(0, len(clientCertSplit)):
                                    clientCertPath = clientCertPath + clientCertSplit[ii] + "/"
                                clientCertNameBase = clientCertName.split('.')[0]
                                clientCertNameExt = clientCertName.split('.')[1]
                                clientCert = str( clientCertPath + clientCertNameBase + "%04d" % ( RepeatClient + startIndx ) + "." + clientCertNameExt )
                                if os.path.exists(clientCert):
                                    VCLtest("%s.set%s('%s')" % (clientType, OptionKey, clientCert) )
                                else:
                                    OutputstreamHDL("\nClient Cert %s doesn't exist\n" % (clientCert), MSG_ERROR)
                        elif OptionKey == 'PrivateKeyFile' and loginMethod == "Increment":   
                            pKey = SecurityOptions.get( 'ClientCertificate', '' )
                            startIndx = int(SecurityOptions.get( 'StartIndex'))                                    
                            if pKey != '':
                                pKeySplit = pKey.split('/')
                                pKeyName = pKeySplit.pop()
                                pKeyPath = ""
                                for jj in range(0, len(pKeySplit)):
                                    pKeyPath = pKeyPath + pKeySplit[jj] + "/"
                                pKeyNameBase = pKeyName.split('.')[0]
                                pKeyNameExt = pKeyName.split('.')[1]
                                pKey = str( pKeyPath + pKeyNameBase + "%04d" % ( RepeatClient + startIndx ) + "." + pKeyNameExt )
                                if os.path.exists(pKey):
                                    VCLtest("%s.set%s('%s')" % (clientType, OptionKey, pKey) )
                                else:
                                    OutputstreamHDL("\nPrivate Key %s doesn't exist\n" % (pKey), MSG_ERROR)                                    
                        else:
                            VCLtest("%s.set%s('%s')" % (clientType, OptionKey, SecurityOptions[OptionKey]) )
                    else:
                        OutputstreamHDL("\Warning: Client %s with Security method %s is missing %s SecurityOptions\n" % (ClientName, Security.upper(), OptionKey), MSG_WARNING)
                VCLtest("%s.updateSecurity('%s')" % (clientType, ClientName))
                
                if clientType == 'mc':
                    if CurrentSec[0] == 'on' and CurrentSec[2] != 'wepStatic' and CurrentSec[2] != 'none':
                        ConnectCompleteState = ClientState8021xAuth
                elif clientType == 'ec' and CurrentSec[0] == 'on':
                    ConnectCompleteState = ClientState8021xAuth
            # done with security

            # for TCP traffic, we need to enable the network interface
            if enableNetworkInterface == True:
                VCLtest("%s.enableNetworkInterface('%s')" % (clientType, ClientName))                           
            
            # done with ec/mc

            if IPnum == 0:
                ConnectCompleteState = ClientStateDhcp
            if clientLearnF == True:
                ConnectCompleteState = ClientStateLearning
            if loopbackMode == True and ConnectCompleteCMD == 'mc':
                ConnectCompleteState = ClientStateIdle
#                                                ( Status, PortName, EC or MC, )
            ListofClientProperties[ClientName] = (ConnectCompleteState, PortName, ConnectCompleteCMD)

            # increment the IP number
            IPnum += IPinc

            # generate next MAC address
            if MACinc == 'DEFAULT':
                # default mode -- assign MAC by the IETF draft rr:pp:pp:rr:rr:rr
                # also known as random mode
                MACnum = MACaddress(IETF_MAC(MACnum[1] * 256 + MACnum[2]))

            elif MACinc == 'AUTO':
                # automatic mode -- assign MAC by cc:ss:pp:ip:ip:ip
                # get port location ( first port if a list is given )
                if isinstance( PortName, list ):
                    loc = _PortLocation[ PortName[0] ]
                else:
                    loc = _PortLocation[ PortName ]
                # get chassis number ( FIXME -- this is a crude way to do it )
                chassisList = []
                for eachPort in _PortLocation:
                    ch = _PortLocation[ eachPort ][ 0 ]
                    if ch not in chassisList:
                        chassisList.append( ch )
                chassisNum = chassisList.index( loc[0] )
                # get client IP address for last three bytes of the MAC
                if IPnum == 0:
                    # dhcp, use client counter instead
                    lowIPnum = (_ClientMACCounter << 16 & 0xFF0000) + ClientCounter
                else:
                    # static IP, use lowest three bytes
                    lowIPnum = IPnum & 0xFFFFFF
                # assemble new MAC address
                newMACnum = '%02x:%02x:%02x:%02x:%02x:%02x' % ( chassisNum * 2,
                                                                loc[1],
                                                                loc[2],
                                                                ( lowIPnum & 0xFF0000 ) >> 16,
                                                                ( lowIPnum & 0x00FF00 ) >> 8,
                                                                ( lowIPnum & 0x0000FF ) >> 0 )
                # got the next MAC address
                MACnum = MACaddress(newMACnum)

            else:
                # normal increment/decrement mode
                MACnum += MACinc
            # done with the MAC address
            
            # increment the client counter
            ClientCounter += 1

            # increment the login counter
            if LoginListType != None:
                LoginCounter  += 1
                # get size of list and reset counter to zero if needed
                if LoginListType == 'list':
                    listSize = len( LoginList )
                elif LoginList.has_key( BaseName ):
                    listSize = len( LoginList[ BaseName ] )
                else:
                    listSize = 0
                if LoginCounter >= listSize:
                    LoginCounter = 0
            # else LoginListType is None

            #Print out an update
            OutputstreamHDL("%s" % '', MSG_OK)
            #_printCreateStatus('Creating Clients', TotalClients, (ClientCounter - StartCounter))
            # next client...
        # done creating clients for this group
        # next group...
    # done with all groups.
        
    ElaspedTime = time.time() - StartTime
    #_printCreateStatus('Creating Clients', 0, 0)
    OutputstreamHDL("Completed: Created %d clients in %.2f seconds\n" % (ClientCounter - StartCounter, ElaspedTime), MSG_SUCCESS)
    return ListofClientProperties
            
############################### ClientState2Text ###############################
# Converts a client's state number to a human understandable text
#
def ClientState2Text(number):
    StateDict = { 0: 'IDLE', 1: 'PROBE', 2: 'AUTH', 3: 'ASSOC', 4: 'EAPOL', 5: 'DHCP', 6: 'ARP', 7: 'ADDT', 8: 'LEARNING', 20: 'DEAUTH', 21: 'DISASS', EthernetClientCode: 'ETH'}
    if StateDict.has_key(number):
        return StateDict[number]
    else:
        return "Unknown state %s" % (number)

############################### SetLoopbackMode ################################
# Set the BssidList of the src client to the dest client mac address and vice
# versa.
#
def SetLoopbackMode(ListofSrcClient, ListofDesClient):
    for srcClient, desClient in zip(ListofSrcClient.keys(), ListofDesClient.keys()):
        if ListofSrcClient[srcClient][2] == ListofDesClient[desClient][2] == 'mc':
            VCLtest("mc.read('%s')" % (srcClient))
            srcMac = mc.getMacAddress()
            VCLtest("mc.read('%s')" % (desClient))
            desMac = mc.getMacAddress()
            UpdateBssid(desClient, srcMac)
            UpdateBssid(srcClient, desMac)
            
############################## ConnectClients ##################################
# Connects Ethernet & Mobile clients
# Currently there are 2 types of client connection process:
# - Aggregate Connection Process (default)
# - Variable Connection Process
#
def ConnectClients (Clients, Rate=100,  Retries=0, ClientTimeout=1.0, GroupTimeout=5.0, connType='Aggregate'):
    OutputstreamHDL("\nAttempting to connect the client(s)%s" % '', MSG_OK)
    if connType == 'Aggregate':
        return AggregateConnectClients(Clients, Retries, ClientTimeout)
    elif connType == 'Variable':
        return VariableConnectClients(Clients, Rate, Retries, ClientTimeout, GroupTimeout)

########################## AggregateConnectClients #############################
# Connects mobile clients to the AP(s) and do DHCP for Ethernet (if enabled) in
# a more reliable and robust way.
# Imput:
# -Clients, is a dict of: 'group_x_xxx': (final state, portname, client type)
# -Retries: number of retry per client
# -ClientTimeout: per client association timeout
# -noSummary: boolean to indicate not to print the Achieved State summary for 
#             the connected clients
# Returns: Positive number is time in Seconds to complete all Associations
#          Negative number means not all Clients reached expected state
def AggregateConnectClients(Clients, Retries, ClientTimeout, noSummary=False):  
    volleySet = OrderedDict()
    portDict = {}
    portLen = {}
    clientsKey = Clients.keys()
    clientsKey.sort()
    # Store the clients based on their port name into portDict
    for clientName in clientsKey:  
        try:
            # In Roaming tests, the portname is a list of ports instead of a
            # single port. We'll use the 1st port in the list for simplicity
            portName = Clients[clientName][1].pop(0)
            Clients[clientName][1].insert(0, portName)
        except:
            portName = Clients[clientName][1]
        client = list(Clients[clientName])
        client.insert(0,clientName)
        client = tuple(client)
        if portDict.has_key(portName):
            portDict[portName].append(client)
        else:
            portDict[portName] = []
            portDict[portName].append(client)
    # Figure out num of clients per port
    maxLen = 0
    for portName in portDict:
        portLen[portName] = len(portDict[portName])
        maxLen = max(maxLen, portLen[portName]) 
    
    # Build the volley Set
    for i in range(maxLen):
        for portName in portDict:
            if portDict[portName] != []:
                client = portDict[portName].pop(0) 
                if not volleySet.has_key(i):
                    volleySet[i] = []                
                volleySet[i].append(client)                          

    # connecting mobile clients to APs
    Result = _doConnect(volleySet, Retries, ClientTimeout, noSummary)  

    return (Result)

################################# _doConnect ###################################    
# _doConnect() provides the info on a client in an ordered dict
# input: 
# -volleySet, i.e.: ('Group_4_003', 3, 'wt-tga-10-28_port6', 'mc')
# -Retries: number of retry per client
# -ClientTimeout: per client association timeout
# -noSummary: boolean to indicate not to print the Achieved State summary for 
#             the connected clients
# Returns: -1 if failed, 0 if successful
def _doConnect(volleySet, Retries, ClientTimeout, noSummary=False):
    timeOut = ClientTimeout # timeout in n seconds if checkStatus() doesn't complete
    connectedCtr = [0,0,0,0,0,0,0,0,0,0,0]
    doneClient = {}
    startTime = time.time()
    for volleyNum, volley in volleySet.iteritems():
        startVolleyTime = time.time()
        for client in volley:  
            name = client[0]
            type = client[3]
            expectedState = client[1]
            if type == 'mc':
                VCLtest("%s.doConnectToAP('%s', %d)" % (type, name, 0))
            #elif type == 'ec' and expectedState == ClientStateDhcp:
            #    VCLtest("%s.doDhcpExchange('%s')" % (type, name))   
            elif type == 'ec' and (expectedState == ClientStateDhcp or \
                                   expectedState == ClientState8021xAuth): 
                VCLtest("%s.doConnectEc('%s')" % (type, name))                                     
            doneClient[name] = False         
        doneVolley = False
        time.sleep(0.08)        # sleep so we don't overwhelm the AP
        while(not doneVolley):
            doneVolley = True   # initialize to True, each client will be tested
            for client in volley:
                name = client[0]    
                type = client[3]
                expectedState = client[1]
                # print '' to log screen so WaveApps UI doesn't freeze
                OutputstreamHDL("%s" % '', MSG_OK)
                #status1 = -1 
                if doneClient[name] == True:
                    continue
                if type == 'mc' or (type == 'ec' and (expectedState == ClientStateDhcp or \
                                                      expectedState == ClientState8021xAuth)):
                    exec("status = %s.checkStatus('%s')" % (type, name))
                else:
                    status = EthernetClientCode  
                    #status1 = 10    
                if time.time() - startVolleyTime > ClientTimeout: 
                    # if drop here, connection process failed and we give up
                    status = 1001 # set status to some invalid positive number        
                #print "type: ", type, " expectedState: ", expectedState, " status: ", status#, " status1: ", status1                   
                if status >= 0 and not doneClient[name]:
                    doneClient[name] = True
                    if type == 'ec' and expectedState == EthernetClientCode: 
                        #doneClient[name] = True
                        connectedCtr[expectedState] += 1
                        continue                    
                    VCLtest("%s.read('%s')" % (type, name))
                    exec("status = %s.getState()" % (type)) 
                    if type == 'mc':
                        # in the event that gratuitous ARP or Client Learning is
                        # enabled, the achived state may be higher than the expected
                        # state which should be no higher than DHCP 
                        doLearning = mc.getClientLearning()
                        gratArp = mc.getGratuitousArp()
                        ipMode = mc.getIpAddressMode()
                        secMode = mc.getSecurity()
                        netAuthMethod = mc.getNetworkAuthMethod()
                        if expectedState != ClientStateIdle:
                            if gratArp == 'on' or doLearning == 'on':
                                expectedState = ClientStateAssoc
                                if secMode == 'on' and netAuthMethod != 'none':
                                    expectedState = ClientState8021xAuth
                                if ipMode == 'dhcp':
                                    expectedState = ClientStateDhcp                        
                    if status >= expectedState and (status != 20 and status != 21):
                        # if drop here, we managed to connect
                        VCLtest("clientStats.read('%s')" % (name))
                        if type == 'mc':
                            deltaT = clientStats.getTstampMcConnectionComplete() - clientStats.getTxMcStartTime()
                            ctype = 'Mobile client'
                        else:
                            if expectedState == ClientStateDhcp:
                                deltaT = clientStats.getTstampDhcpAck() - clientStats.getTstampDhcpDiscover() 
                            else:
                                #FIXME: fix this when timestamps for ec are added
                                deltaT = 0
                            ctype = 'Ethernet client'
                        deltaT = float(deltaT/1000000.0)
                        OutputstreamHDL("\r%0.2fms %s %s achieved the state %s and is connected" % \
                                       (deltaT, ctype, name, ClientState2Text(expectedState)), MSG_OK)
                        connectedCtr[expectedState] += 1
                    else:
                        # if drop here, we failed to connect 
                        # see if we need to retry (Retries != 0)
                        if Retries > 0:
                            doneClient[name] = False
                            startVolleyTime = time.time() #reset the time
                            time.sleep(0.08)
                            if type == 'mc':
                                if status >= ClientState80211Auth:
                                    VCLtest("%s.deauthenticate('%s', %d)" % (type, name, 0))
                                    time.sleep(0.08)
                                VCLtest("%s.doConnectToAP('%s', %d)" % (type, name, 0))
                            elif type == 'ec' and (expectedState == ClientStateDhcp or \
                                                   expectedState == ClientState8021xAuth):
                                VCLtest("%s.doConnectEc('%s')" % (type, name)) 
                            Retries = Retries - 1
                        else:
                            OutputstreamHDL("\n%s failed to connect" % (name), MSG_ERROR)
                            OutputstreamHDL("\nExpected %s, achieved %s" % \
                                           (ClientState2Text(expectedState), ClientState2Text(status)), MSG_ERROR)
                            if type == 'mc':
                                exec("errCode = mc.checkStatusCode('%s')" % (name))
                                OutputstreamHDL("\nInformation from the SUT - status code: %d" % (errCode), MSG_ERROR) 
                            clientContext = ClientContext(name)
                            str = ''
                            for key, item in clientContext.iteritems():
                                str += "\n%s: %s" % (key, item)
                            OutputstreamHDL("%s" % (str), MSG_OK)
                            connTrans = ConnectionTranscript(name)
                            str = ''
                            OutputstreamHDL("\nConnection transcript: %s" % (''), MSG_OK)
                            for key, item in connTrans.iteritems():
                                if isnum(item):
                                    item = "%0.4f" % float(item / 1000000.0)
                                    if item == "0.0000":
                                        item = "0"
                                    item = item + 'ms'
                                str += "\n%s: %s" % (key, item)
                            OutputstreamHDL("%s" % (str), MSG_OK)                           
                            return -1
                doneVolley = doneVolley and doneClient[name]
                
    elapsedTime = time.time() - startTime  
    if noSummary == False:
        OutputstreamHDL("\n             ETH   ASSOC   EAPOL    DHCP%s" % (''), MSG_OK)   
        OutputstreamHDL("\nAchieved: %6d  %6d  %6d  %6d" %
                       (connectedCtr[EthernetClientCode], connectedCtr[ClientStateAssoc], 
                        connectedCtr[ClientState8021xAuth], connectedCtr[ClientStateDhcp]), MSG_OK)      
        OutputstreamHDL("\nCompleted: All clients were connected in %.2f seconds\n" % (elapsedTime), MSG_SUCCESS)
    return (elapsedTime)       
                        
############################### ClientContext ##################################    
# ClientContext() provides the info on a client in an ordered dict
# input: 
# - client's name, i.e. 'Group_1_001'
# Returns:
# clientContext, which is an ordered dict, keys are client properties name and
# items are the properties values
def ClientContext(name):
    clientContext = OrderedDict()    
    
    # find out if it's an Ethernet of Mobile client. Note that here we assume
    # the all client's names to be unique
    if mc.read(name) == 0: 
        type = 'mc'
    else:
        ec.read(name)           
        type = 'ec'
        
    clientContext['Client name'] = name
    clientContext['Type'] = 'Ethernet'
    if type == 'mc':         
        clientContext['Type'] = 'Mobile'            
        exec("clientContext['Port'] = %s.getCurrentPort()" % (type))     
    else:
        exec("clientContext['Port'] = %s.getPort()" % (type))    
        exec("clientContext['Vlan Tag'] = %s.getVlanTag()" % (type)) 
        if clientContext['Vlan Tag'] == -1:
            clientContext['Vlan Tag'] = 'off'                    
    exec("clientContext['MAC address'] = %s.getMacAddress()" % (type))       
    exec("ipAddrMode = %s.getIpAddressMode()" % (type))                       
    exec("clientContext['IP address'] = %s.getIpAddress()" % (type))  
    if ipAddrMode != 'static':    
        clientContext['IP address'] = 'DHCP'        
    if type == 'mc':      
        clientContext['Target SSID'] = mc.getSsid()
        clientContext['Target BSSID'] = mc.getCurrentBssid()
        clientContext['Security'] = mc.getSecurity()
        clientContext['AP authentication method'] = mc.getApAuthMethod()
        clientContext['Key method'] = mc.getKeyMethod()
        clientContext['Network authentication method'] = mc.getNetworkAuthMethod()
        clientContext['Encryption method'] = mc.getEncryptionMethod()      
 
    return clientContext                  

############################ ConnectionTranscript ##############################
# ConnectionTranscript() provides the timestamp of the connection process
# input: 
# - client's name, i.e.: 'Group_4_003'
# Returns:
# connTrans, which is an ordered dict, keys are time delta names and items are
# the delta values
def ConnectionTranscript(name):
    connTrans = OrderedDict()
    #                                               +------ 2nd 802.11 auth
    #                                               | +---- 802.1x
    #                                               | | +-- Key Gen & Install
    #                                               | | | 
    securityMethodDict = {'None':                  [0,0,0],
                          'WEP-Open-40':           [0,0,0],
                          'WEP-Open-128':          [0,0,0],
                          'WEP-SharedKey-40':      [1,0,0],
                          'WEP-SharedKey-128':     [1,0,0],
                          'WPA-PSK':               [0,0,1],
                          'WPA-EAP-TLS':           [0,1,1],
                          'WPA-EAP-TTLS-GTC':      [0,1,1],
                          'WPA-PEAP-MSCHAPV2':     [0,1,1],
                          'WPA-EAP-FAST':          [0,1,1],
                          'WPA2-PSK':              [0,0,1],
                          'WPA2-EAP-TLS':          [0,1,1],
                          'WPA2-EAP-TTLS-GTC':     [0,1,1],
                          'WPA2-PEAP-MSCHAPV2':    [0,1,1],
                          'WPA2-EAP-FAST':         [0,1,1],
                          'DWEP-EAP-TLS':          [0,1,1],
                          'DWEP-EAP-TTLS-GTC':     [0,1,1],
                          'DWEP-PEAP-MSCHAPV2':    [0,1,1],
                          'LEAP':                  [0,1,1],
                          'WPA-LEAP':              [0,1,1],
                          'WPA2-LEAP':             [0,1,1],
                          'WPA-PSK-AES':           [0,0,1],
                          'WPA-PEAP-MSCHAPV2-AES': [0,1,1],
                         'WPA2-PEAP-MSCHAPV2-TKIP':[0,1,1],
                          'WPA2-EAP-TLS-TKIP':     [0,1,1],
                          'WPA2-PSK-TKIP':         [0,0,1]}  

    # find out if it's an Ethernet of Mobile client. Note that here we assume
    # the all client's names to be unique
    if mc.read(name) == 0: 
        type = 'mc'
        dhcpOn = mc.getIpAddressMode()
    else:
        ec.read(name)           
        type = 'ec'
        dhcpOn = ec.getIpAddressMode()
       
    if type == 'mc':
        probe = mc.getProbeBeforeAssoc()
        security = mc.getSecurity()
        apAuthMethod = mc.getApAuthMethod()       
        netAuthMethod = mc.getNetworkAuthMethod()
        keyMethod= mc.getKeyMethod()
        
        VCLtest("clientStats.read('%s')" % (name))
        if probe != 'off':
            connTrans['Probe request'] = 'start'
            connTrans['Probe response'] = clientStats.getTstampProbeRsp() - clientStats.getTxMcStartTime()
            connTrans['Authentication request'] = clientStats.getTstampAuth1Req() - clientStats.getTstampProbeRsp() 
        else:
            connTrans['Authentication request'] = 'start'
        connTrans['Authentication response'] = clientStats.getTstampAuth1Rsp() - clientStats.getTstampAuth1Req() 
        if security == 'on' and apAuthMethod == 'shared':
            connTrans['Authentication request 2'] = clientStats.getTstampAuth2Req() - clientStats.getTstampAuth1Rsp()
            connTrans['Authentication response 2'] = clientStats.getTstampAuth2Rsp() - clientStats.getTstampAuth2Req()
            connTrans['Association request'] = clientStats.getTstampAssocReq() - clientStats.getTstampAuth2Rsp()                   
        else:           
            connTrans['Association request'] = clientStats.getTstampAssocReq() - clientStats.getTstampAuth1Rsp()   
        connTrans['Association response'] = clientStats.getTstampAssocRsp() - clientStats.getTstampAssocReq()   
        prevTimeStamp = clientStats.getTstampAssocRsp()
        if security == 'on':
            if netAuthMethod != 'none' and netAuthMethod != 'psk':
                connTrans['EAP identity request'] = clientStats.getTstampEapReqIdentity() - clientStats.getTstampAssocRsp()
                connTrans['EAP identity response'] = clientStats.getTstampEapRspIdentity() - clientStats.getTstampEapReqIdentity()
                connTrans['EAP Success or Failure'] = clientStats.getTstampEapSuccessOrFailure() - clientStats.getTstampEapRspIdentity()
                prevTimeStamp = clientStats.getTstampEapSuccessOrFailure()
            if keyMethod != 'wepStatic':
                if keyMethod == 'wpa' or keyMethod == 'wepDynamic':  
                    connTrans['EAPOL pairwise key installed'] = clientStats.getTstampEapolPairwiseKey() - prevTimeStamp
                    connTrans['EAPOL group key installed'] = clientStats.getTstampEapolGroupKey() - clientStats.getTstampEapolPairwiseKey()
                    prevTimeStamp = clientStats.getTstampEapolGroupKey()
                elif keyMethod == 'wpa2':          
                    connTrans['EAPOL pairwise key installed'] = clientStats.getTstampEapolPairwiseKey() - prevTimeStamp
                    prevTimeStamp = clientStats.getTstampEapolPairwiseKey()             
    if dhcpOn == 'dhcp':
        if type == 'mc':
            connTrans['DHCP discover'] = clientStats.getTstampDhcpDiscover() - prevTimeStamp
        else:
            VCLtest("clientStats.read('%s')" % (name))
            if clientStats.getTstampDhcpOffer() == 0:
                connTrans['DHCP discover'] = -1
            else:
                connTrans['DHCP discover'] = 'start'
        connTrans['DHCP offer'] = clientStats.getTstampDhcpOffer() - clientStats.getTstampDhcpDiscover()
        connTrans['DHCP request'] = clientStats.getTstampDhcpRequest() - clientStats.getTstampDhcpOffer()
        connTrans['DHCP ACK'] = clientStats.getTstampDhcpAck() - clientStats.getTstampDhcpRequest()   
    
    for key, item in connTrans.iteritems():
        if item == 0:
            connTrans[key] = '-'
        elif item < 0:
            connTrans[key] = 'FAILED'
        elif item == 'start':
            connTrans[key] = 0
    
    return connTrans        

                       
########################### VariableConnectClients #############################
# Connects mobile clients to the AP(s) and do DHCP for Ethernet (if enabled) in
# a variable manner
# Returns: Positive number is time in Seconds to complete all Associations
#          Negative number means not all Clients reached expected state
#
def VariableConnectClients (Clients, Rate=100,  Retries=1, ClientTimeout=1.0, GroupTimeout=5.0):
    CodeList = [0, 1, 2, 3, 4, 5, 7, EthernetClientCode, 20, 21]
    IntervalConnect  = 1.0 / Rate
    IntervalPrintSec = 0.750
    ConnectToAPCount = 0
    ConnectStatus    = {}
    ExpectedStatus   = {}
    ClientRetryCount = {}
    ClientTimeoutSec = {}
    ElaspedTime      = -1
    ClientStatus     = {}
    ClientList       = Clients.keys()
    ClientListLength = len(ClientList)
    ClientIndex      = 0       

    for x in CodeList:
        ConnectStatus[x] = 0
    TotalClients = 0
    for ClientName in ClientList:
        # Assume that the AP will not deauth us because the client does not exsists from a previous run
        ClientRetryCount[ClientName] = Retries + 1
        ClientTimeoutSec[ClientName] = time.time() + TotalClients * IntervalConnect
        TotalClients += 1
        expectedState = Clients[ClientName][0]
        
        if Clients[ClientName][2] == 'mc':
            VCLtest("%s.read('%s')" % (Clients[ClientName][2], ClientName))
            doLearning = mc.getClientLearning()
            gratArp = mc.getGratuitousArp()
            ipMode = mc.getIpAddressMode()
            secMode = mc.getSecurity()
            if gratArp == 'on' or doLearning == 'on':
                expectedState = ClientStateAssoc
                if secMode == 'on':
                    expectedState = ClientState8021xAuth
                if ipMode == 'dhcp':
                    expectedState = ClientStateDhcp
                    
        ExpectedStatus[ClientName] = expectedState
        ConnectStatus[expectedState] += 1
    OutputstreamHDL("\nConnecting %d clients at %d per second, status is:\n" % (TotalClients, Rate), MSG_OK)
    OutputstreamHDL("         ETH IDLE PROBE AUTH ASSOC EAPOL DHCP DEAUTH DISASSOC Attempts Time\n", MSG_OK)
    OutputstreamHDL("Expect :%4d %4d  %4d %4d  %4d  %4d %4d   %4d     %4d\n" % (ConnectStatus[EthernetClientCode], ConnectStatus[0], ConnectStatus[1], ConnectStatus[2], ConnectStatus[3], ConnectStatus[4], ConnectStatus[5], ConnectStatus[20], ConnectStatus[21]), MSG_OK)

    StartTime = time.time()
    StopTime  = StartTime + GroupTimeout
    PrintTime = StartTime
    while StopTime > time.time():
        #Check to see if we have any to ininiate
        for ClientName in ClientList:
            if ( time.time() > ClientTimeoutSec[ClientName]):
                if ClientRetryCount[ClientName] > 0:
                    if Clients[ClientName][2] == 'ec':
                        #Only do DHCP if the expected state is DHCP
                        if Clients[ClientName][0] != EthernetClientCode:
                            VCLtest("%s.doDhcpExchange('%s')"    % (Clients[ClientName][2], ClientName))
                    else:
                        VCLtest("%s.doConnectToAP('%s', %d)" % (Clients[ClientName][2], ClientName, 1))
                    ClientTimeoutSec[ClientName] = time.time() + ClientTimeout
                    ClientRetryCount[ClientName] -= 1
                    ConnectToAPCount += 1
                else:
                    ClientTimeoutSec[ClientName] = StopTime + GroupTimeout
        
        #Get the states for a client
        if ClientIndex >= ClientListLength:
            ClientIndex = 0
        ClientName = ClientList[ClientIndex]
        
        VCLtest("%s.read('%s')" % (Clients[ClientName][2], ClientName))
        exec("ClientStatus[ClientName] = %s.getState()" % (Clients[ClientName][2])) 
        if Clients[ClientName][2] == 'ec' and Clients[ClientName][0] == EthernetClientCode:
            ClientStatus[ClientName] = EthernetClientCode
        ClientIndex += 1
        #print "ClientStatus[ClientName]: ", ClientStatus[ClientName]
        #Update the display if it is time
        if time.time() > PrintTime:
            CompletedClients = 0
            for x in CodeList:
                ConnectStatus[x] = 0
            for ClientName in ClientStatus.keys():
                #if ClientStatus[ClientName] >= Clients[ClientName][0]:
                #    CompletedClients += 1
                if ClientStatus[ClientName] >= ExpectedStatus[ClientName] and (ClientStatus[ClientName] != 20 and \
                                                                               ClientStatus[ClientName] != 21):
                    CompletedClients += 1
                    ConnectStatus[ExpectedStatus[ClientName]] += 1
                else:
                    ConnectStatus[ClientStatus[ClientName]] += 1
                                                  
            TimeLeft  = StopTime - time.time()
            if TimeLeft >= 10.0:
                min = int(TimeLeft / 60)
                sec = int(TimeLeft % 60)
                TimeStr =  "%02d:%02d" % (min, sec)
            else:
                TimeStr = "%5.1f" % (TimeLeft)
            OutputstreamHDL("\rCurrent:%4d %4d  %4d %4d  %4d  %4d %4d   %4d     %4d %8d %5s" % (ConnectStatus[EthernetClientCode],ConnectStatus[0], ConnectStatus[1], ConnectStatus[2], ConnectStatus[3], ConnectStatus[4], ConnectStatus[5], ConnectStatus[20], ConnectStatus[21], ConnectToAPCount, TimeStr), MSG_OK)
            PrintTime = time.time() + IntervalPrintSec
            if CompletedClients == TotalClients:
                StopTime    = StartTime
    
    # Add 1 sec of sleep to let the system complete the client state updates
    time.sleep(1.0)            
    #Test if clients are connected, and do not have dupelicte MAC or IP adresses
    OutputstreamHDL("\n", MSG_OK)
    DictofMAC = {}
    DictofIP  = {}
    NoErrors  = True
    for ClientName in ClientList:
        VCLtest("%s.read('%s')" % (Clients[ClientName][2], ClientName))
        exec("Status = %s.getState()" % (Clients[ClientName][2]))
        if Clients[ClientName][2] == 'ec' and Clients[ClientName][0] == EthernetClientCode:
            Status = EthernetClientCode
        MyMACaddress = VCLtest("%s.macAddress" % (Clients[ClientName][2]))
        MyIPaddress  = IPv4toInt( VCLtest("%s.ipAddress" % (Clients[ClientName][2])) )
        if Status < Clients[ClientName][0]:
            if Clients[ClientName][0] == ClientStateLearning:
                OutputstreamHDL("Error: Client failed to send learning frames\n", MSG_ERROR)                
            else:
                OutputstreamHDL("Error: Client %s status only at %s, expected %s\n" % (ClientName, ClientState2Text(Status), ClientState2Text(ExpectedStatus[ClientName])), MSG_ERROR)
            NoErrors = False
        if DictofMAC.has_key(MyMACaddress):
            DictofMAC[MyMACaddress].append(ClientName)
        else:
            DictofMAC[MyMACaddress] = [ ClientName, ] 
        if DictofIP.has_key(MyIPaddress):
            DictofIP[MyIPaddress].append(ClientName)
        else:
            DictofIP[MyIPaddress] = [ ClientName, ] 
    #Check the list for duplcates
    for eachMAC in DictofMAC.keys():
        if len(DictofMAC[eachMAC]) > 1:
            TextString = ''
            for eachClient in DictofMAC[eachMAC]:
                if len(TextString) > 1:
                   TextString += ', '
                TextString += eachClient
            OutputstreamHDL("Warning: MAC address %s belongs to clients %s\n" % (eachMAC, TextString), MSG_WARNING)
    for eachIP in DictofIP.keys():
        if len(DictofIP[eachIP]) > 1:
            TextString = ''
            for eachClient in DictofIP[eachIP]:
                if len(TextString) > 1:
                   TextString += ', '
                TextString += eachClient
            OutputstreamHDL("Warning: IP address %s belongs to clients %s\n" % (int2IPv4(eachIP), TextString), MSG_WARNING)

    if NoErrors:
        ElaspedTime = time.time() - StartTime
        OutputstreamHDL("Completed: A total of %d clients were connected in %.2f seconds\n" % (TotalClients, ElaspedTime), MSG_SUCCESS)
    return ElaspedTime

################################ ConnectClient #################################
# Connect one client. Client can be a mobile or ethernet client. 
# Input:
# - Name: the client name, i.e. Group_1_001 
# - State: the expected final state. Here is a list of possible states:
# CLIENT_STATE_IDLE           0
# CLIENT_STATE_PROBING        1
# CLIENT_STATE_80211AUTH      2
# CLIENT_STATE_ASSOC          3
# CLIENT_STATE_8021xAUTH      4
# CLIENT_STATE_DHCP_COMPLETE  5
# CLIENT_STATE_ARP_COMPLETE   6
# CLIENT_STATE_DEAUTH         20
# CLIENT_STATE_DISASSOIC      21
# - Type: 'ec' or 'mc'
# - Timeout: number of seconds we should wait for each trial
# - Retries: number of times we should try before giving up
# Returns:
# 0 if successful, -1 if failed
def ConnectClient(Name, State, Type, Timeout, Retries):                             
    if (Type == 'ec' and State == ClientStateDhcp) or Type == 'mc':
        Attempts = 0
        while Attempts < Retries:
            doConnectTime = time.time()
            if Type == 'mc':# If mc, doConnectToAP()
                VCLtest("%s.doConnectToAP('%s', %d)" % (Type,Name,Timeout*1000))
            else:           # If ec, do DHCP
                VCLtest("%s.doDhcpExchange('%s')"  % (Type, Name))
                            
            while time.time() < doConnectTime + Timeout:                   
                VCLtest("%s.read('%s')" % (Type, Name))   
                exec("status = %s.getState()" % (Type))                
                OutputstreamHDL("%s" % '', MSG_OK)
                           # Add a sleep delay so we don't overwhelm the AP with
                           # too much new connections in a short period time
                time.sleep(0.08) 
                if Status == State:
                    OutputstreamHDL(
                    "\r%s client %s - expected: %s, achieved: %s" %
                    (Type,Name,ClientState2Text(State),ClientState2Text(Status)) 
                     ,MSG_OK)
                    return 0# successful, return 0 
            else:           # time's up
                Attempts = Attempts + 1
                OutputstreamHDL("\nTrial #%d: %s client %s - status: %s" %
                (Attempts, Type, Name, ClientState2Text(Status)), MSG_WARNING)
                    
            #if Status == State:
                            # if connected, move to next client
                #OutputstreamHDL("\n%s client %s - expected: %s, achieved: %s" %
                #(Type, Name, ClientState2Text(State), ClientState2Text(Status)), 
                # MSG_OK)
                #return 0
                
        else:               # exhausted the Retries
            OutputstreamHDL(
            "\nWARNING: %s client %s - expected: %s, achieved: %s" %
            (Type, Name, ClientState2Text(State), ClientState2Text(Status)), 
             MSG_ERROR)
            clientContext = ClientContext(Name)
            for key, item in clientContext.iteritems():
                OutputstreamHDL("%s: %s" % (key, item), MSG_OK)
            connTrans = ConnectionTranscript(Name)
            OutputstreamHDL("\nConnection transcript: %s" % (''), MSG_OK)
            for key, item in connTrans.iteritems():
                if isnum(item):
                    item = "%0.4f" % float(item / 1000000.0)
                    if item == "0.0000":
                        item = "0"
                    item = item + 'ms'
                OutputstreamHDL("%s: %s" % (key, item), MSG_OK)   
            if Type == 'mc':# if mc, deauthenticate from AP
                OutputstreamHDL("\nDisassociating mc %s" % Name, MSG_OK)
                MCdeauthenticate(Name)
            return -1       # Failed to connect, return -1  

    OutputstreamHDL("\n%s client %s - expected: %s, achieved: %s" %
    (Type, Name, ClientState2Text(State), ClientState2Text(State)), MSG_OK)                            
    return 0                # if ec with no DHCP just return 0

############################# CheckDuplicateMacIp ##############################
# Make sure that the connected clients do not have duplicate MAC/IP adresses
# Input:
# - baseIpAddr: base IP address for each group
# - ipAddrMode: IP address DHCP mode (Enabled or Disabled)
# - numIpAddr: number of client for each group
# - baseMacAddr: base MAC address for each group
# - macAddrMode: MAC address mode (Increment or Decrement)
# - numMacAddr: number of client for each group
# - macIncrSize: MAC address step size
# Note that we shouldn't include the IP for group with Dhcp enabled
# or MAC for group with Mac address mode set to Auto or Random.
def CheckDuplicateMacIp(baseIpAddr, ipAddrMode, numIpAddr, baseMacAddr ,macAddrMode, numMacAddr, macIncrSize):
    startIp = []
    endIp = []
    ipList = []
    if len(baseIpAddr) != len(ipAddrMode) != len(numIpAddr) != len(baseMacAddr) != len(macAddrMode) != len(numMacAddr):
        raise RaiseIterationFailed("Invalid input for WaveEgine.CheckDuplicateMacIp()")
    # validate no overlap in IP address
    for ipAddr, numClient, dhcpMode in zip(baseIpAddr, numIpAddr, ipAddrMode):
        if dhcpMode == 'Enable':
            continue
        startIp.append(IPv4toInt(ipAddr))
        endIp.append(IPv4toInt(ipAddr) + int(numClient))
    ipList = startIp + endIp  
    ipList.sort()
    startIp.sort()
    endIp.sort() 
    for i in range(len(startIp)):
        tempIp = ipList.pop(0)
        if startIp[i] != tempIp:
            return(-1, "Client base IP address %s is too close to client base IP address %s" % \
                       (int2IPv4(startIp[i]),int2IPv4(startIp[i+1])))
        tempIp = ipList.pop(0)
        if endIp[i] != tempIp:
            return(-1, "Client base IP address %s is too close to client base IP address %s" % \
                       (int2IPv4(startIp[i]),int2IPv4(startIp[i+1])))
    # validate no overlap in MAC address  
    macList = {}       
    for macAddr, addrMode, numClient, incrSize in zip(baseMacAddr, macAddrMode, numMacAddr, macIncrSize):
        if addrMode != 'Increment' and addrMode != 'Decrement':
            continue
        startMac = MACaddress(macAddr)                        
        for i in range(int(numClient)):
            if macList.has_key(startMac.get()):
                return(-1, "Client base MAC address %s is too close to client base MAC address %s" % \
                           (MACaddress(macAddr).get(), macList[startMac.get()]))
            macList[startMac.get()] = MACaddress(macAddr).get()  
            if addrMode == 'Increment':
                startMac.inc(int(incrSize))
            elif addrMode == 'Decrement':
                startMac.dec(int(incrSize))                                
    return(0, "")
        
################################# DestroyClients ###############################
# Destroy existing mc & ec clients in the ClientList
# Note: it will check the state of the mc clients and do a deauth if necessary 
# Input:
# - ClientList:
def DestroyClients(ClientList):  
    if len(ClientList) > 0:
        Keys = ClientList.keys()    # Fetch all the client's name     
        (Status, PortName, ClientType) = ClientList[Keys[0]]
        if ClientType == 'mc':
            for ClientName in Keys:
                VCLtest("%s.read('%s')" % (ClientType, ClientName))     
                Status = mc.getState() 
                if Status == ClientState80211Auth or \
                   Status == ClientStateAssoc or \
                   Status == ClientState8021xAuth or \
                   Status == ClientStateDhcp:
                    MCdeauthenticate(ClientName)
                VCLtest("mc.destroy('%s')" % ClientName)
                #OutputstreamHDL("Client to destroy: %s" % ClientName, MSG_OK)
        elif ClientType == 'ec':
            for ClientName in Keys:
                VCLtest("ec.destroy('%s')" % ClientName)
                #OutputstreamHDL("Client to destroy: %s" % ClientName, MSG_OK) 
                                             
##################################### ModifyClients ###################################
# Modify existing clients with new options
#
def ModifyClients(ClientList, ClientOptions):
    for ClientName in ClientList.keys():
        Check4UserEscape()
        (ConnectCompleteState, PortName, ConnectCompleteCMD) = ClientList[ClientName]
        VCLtest("%s.read('%s')"  % (ConnectCompleteCMD, ClientName))

        for OptionKey in ClientOptions.keys():
            OptionMethod = "set%s" % (OptionKey)
            if OptionMethod in getMethods(ConnectCompleteCMD):
                if isnum(ClientOptions[OptionKey]):
                    VCLtest("%s.%s(%s)" % (ConnectCompleteCMD, OptionMethod, ClientOptions[OptionKey]) )
                else:
                    VCLtest("%s.%s('%s')" % (ConnectCompleteCMD, OptionMethod, ClientOptions[OptionKey]) )
            else:
                OutputstreamHDL("Warning: Client %s option '%s' not supported (ignoring)\n" % (ConnectCompleteCMD, OptionKey), MSG_WARNING)
        
        VCLtest("%s.write('%s')" % (ConnectCompleteCMD, ClientName))

##################################### ClientLearning ###################################
# Each Client will send out a reverse DNS request for it's IP address.  This should be
# enough for a AP to thing that there is a real client attached to it.
#
def ClientLearning(Clients, Time=1, Rate=10, DNSserver='10.1.1.1',
                   flowPhyRate = 11.0):
    if Time <= 0:
        return
    StartTime = time.time()
    TempGroupName    = "Temp"
    DNSserver        = "10.1.1.1"
    ClientList       = Clients.keys()
    ClientListLength = len(ClientList)
    PacketCount = int(Time * Rate) 
    
    #Create the flows
    VCLtest("flowGroup.create('%s')" % (TempGroupName))
    for ClientName in ClientList:
        (ConnectCompleteState, PortName, ConnectCompleteCMD) = Clients[ClientName]
        VCLtest("%s.read('%s')" % (ConnectCompleteCMD, ClientName))
        IPaddress = VCLtest("%s.getIpAddress()"  % (ConnectCompleteCMD))
        REvalue = re.search("(\d+)\.(\d+)\.(\d+)\.(\d+)", IPaddress)
        Payload = "%02X:%02X:01:00:00:01:00:00:00:00:00:00:" % (int(random.random()*256), int(random.random()*256))
        for n in range(4, 0, -1):
            val = ascii2hex(str(REvalue.group(n)))
            x   = int(len(val)/3) + 1
            Payload += "%02X:%s:" % (x, val)
        Payload += '07:69:6E:2D:61:64:64:72:04:61:72:70:61:00:00:0C:00:01'
        PayloadLen = int(len(Payload)/3) + 1
        
        FlowName = "Learning_%s" % (ClientName)
        VCLtest("flow.create('%s')"        % (FlowName))
        VCLtest("flow.setSrcClient('%s')"  % (ClientName))
        VCLtest("flow.setFrameSize(%d)"    % (PayloadLen + 46))
        VCLtest("flow.setType('IP UDP')")
        VCLtest("flow.setRateMode('pps')")
        VCLtest("flow.setIntendedRate(%d)" % (Rate))
        VCLtest("flow.setPhyRate(%f)" %flowPhyRate)        
        VCLtest("flow.setNumFrames(%d)"    % (PacketCount))
        VCLtest("flow.setPayload('%s')"    % (Payload) )
        VCLtest("flow.setPayloadLen(%d)"   % (PayloadLen) )

        VCLtest("mac.readFlow()")
        VCLtest("mac.setDestAddr('FF:FF:FF:FF:FF:FF')")
        VCLtest("mac.modifyFlow()")
        
        VCLtest("ipv4.readFlow()")
        VCLtest("ipv4.setDestAddr('%s')" % (DNSserver) )
        VCLtest("ipv4.modifyFlow()")

        VCLtest("udp.readFlow()")
        VCLtest("udp.setSrcPort(%d)" % (1048) )
        VCLtest("udp.setDestPort(%d)" % (53) )
        VCLtest("udp.modifyFlow()")
        
        VCLtest("flow.write('%s')"           % (FlowName))
        VCLtest("flowGroup.add('%s')" % (FlowName))
    VCLtest("flowGroup.write('%s')" % (TempGroupName))

    #Send them out for a fixed time
    VCLtest("action.startFlowGroup('%s')" % (TempGroupName))
    Sleep(Time, "Client Learning")

    #Delete the flows so we can reuse the resource for the actual test
    VCLtest("action.stopFlowGroup('%s')" % (TempGroupName))
    VCLtest("flowGroup.destroy('%s')" % (TempGroupName))
    for ClientName in ClientList:
        FlowName = "Learning_%s" % (ClientName)
        VCLtest("flow.destroy('%s')" % (FlowName))
    OutputstreamHDL("Completed: Client Learning Phase in %.2f seconds\n" % (time.time() - StartTime), MSG_SUCCESS)
    
######################### CheckEthLinkWifiClientState ##########################
# Check the Ethernet ports link status & the wireless client connection status
# Print a warning messsage if the Ethernet link is down or the wireless client
# connection state is not as expected. 
def CheckEthLinkWifiClientState(PortList, ClientList):
    #OutputstreamHDL("Checking Ethernet ports link status...", MSG_OK)
    sMessage = "Warning: "
    AllUp = True
    for Portname in PortList:
        VCLtest("port.read('%s')" % (Portname))
        if port.type  == '8023':
            if port.link == 'down':  
                AllUp = False  
                sMessage += "%s " % (Portname)
    if AllUp == False:
        sMessage += "link status is down. Test result may be invalid."
        OutputstreamHDL(sMessage, MSG_ERROR)

    #OutputstreamHDL("Checking wireless clients connection status...", MSG_OK)
    for client in ClientList.keys():
        if ClientList[client][2] == 'mc':
            VCLtest("mc.read('%s')" % (client))
            status = mc.getState()        
            if status < ClientList[client][0]:
                OutputstreamHDL("Warning: client %s connection status is %s, expected %s. Test result may be invalid." %
                                (client, ClientState2Text(status), ClientState2Text(ClientList[client][0])), MSG_WARNING)
            #retry = ClientStats.getAuthenticationHandshakeRetryCount()
        
        
##################################### WaitforEthernetLink ###################################
# Wait up to 4 seconds to get link up on a list of ports
#  
def WaitforEthernetLink(PortList, Timeout= 4):
    LoopTime = 0.250
    
    for i in range(int(Timeout/LoopTime)):
        AllUp = True
        sMessage = "\rWaiting for Link on: "
        for Portname in PortList:
            VCLtest("port.read('%s')" % (Portname))
            if port.type  == '8023':
                if port.link == 'down':
                    AllUp = False
                    sMessage += "%s " % (Portname)
        OutputstreamHDL(sMessage, MSG_OK)
        if AllUp:
            break
        time.sleep(LoopTime)
    if not AllUp: 
        sMessage = "\nERROR: Did not get link up on ports "
        for Portname in PortList:
            VCLtest("port.read('%s')" % (Portname))
            if port.type  == '8023':
                if port.link == 'down':
                     sMessage += "%s " % (Portname)
        sMessage += "\n"
        OutputstreamHDL(sMessage, MSG_ERROR)
        return -1
    OutputstreamHDL("\nCompleted: Ethernet link is up\n", MSG_SUCCESS)
    return 0

##################################### SetClientContention ###################################
# Sets the level of FCS errors in random packets transmitted on the Wireless port when 2 flows
# from different clients try to transmit.  
#
# Probability - Range between 0% and 100%.  The number should be interpreted as the "probability" 
#               of contention, and will be specified as the maximum probability of the [n-1,n]
#               segment.  Example, specifying 50 means that the probability is between 40 and 50.
#               Only Values of 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, and 100 make a difference. 
#
def SetClientContention(PortList, Probability=False):
    # Current VCL only accept MagicNumber of 0 through 100
    if isnum(Probability):
        if int(Probability) > 100:
            MagicNumber = 100
        elif int(Probability) < 0:
            MagicNumber = 0
        else:
            MagicNumber = 10 * int(Probability/10)
    else:
        MagicNumber = 0

    # Now set them
    for PortName in PortList:
        VCLtest("port.read('%s')" % (PortName))
        VCLtest("port.setContentionProbability(%s)" % (MagicNumber))
        VCLtest("port.write('%s')" % (PortName))

##################################### CleanUpClients ###################################
# Tells the AP to deauthenicate then removes the client from VCL
#
def CleanUpClients (Clients, Rate=100):
    IntervaltoUnConnect  = 1.0 / Rate
    if len(Clients) > 0:
        for ClientName in Clients.keys():
            (Status, PortName, ClientType) = Clients[ClientName]
            if ClientType == 'mc':
                VCLtest("mc.destroy('%s')" % ClientName)
                VCLtest("mc.deauthenticate('%s', %d)" % (ClientName, 1))
                VCLtest("mc.destroy('%s')" % (ClientName))
                time.sleep(IntervaltoUnConnect)

##################################### CreateFlow Helper routines ###################################
# Common between all the types (reusaeble code)
def _processFlowOptions(Options):
    OptionList = []
    #Create a local copy of the options since we modify it to work around VCL
    FlowOptions = Options.copy()

    flowType = 'flow'
    if FlowOptions.has_key('Type'):
        pktType = FlowOptions['Type']
        if pktType == 'TCP':
            flowType = 'biflow'
    
    #VPR 3236 - Force FrameSize to be the first option on the list before setType
    if FlowOptions.has_key('FrameSize'):
        OptionList.append("%s.setFrameSize(%s)" % (flowType, FlowOptions['FrameSize']) )
        del FlowOptions['FrameSize']
    
    if FlowOptions.has_key('Type'):
        if FlowOptions['Type'] == 'IP':
            OptionList.append("%s.setType('IP')" % (flowType))
        elif FlowOptions['Type'] == 'ICMP':
            OptionList.append("%s.setType('IP ICMP')" % (flowType))
            OptionList.append("icmp.readFlow()")
            if FlowOptions.has_key('type'):
                OptionList.append("icmp.setType(%s)" % (FlowOptions['type']) )
                del FlowOptions['type']
            if FlowOptions.has_key('code'):
                OptionList.append("icmp.setCode(%s)" % (FlowOptions['code']) )
                del FlowOptions['code']
            OptionList.append("icmp.modifyFlow()")
        elif 'TCP' in FlowOptions['Type']:
            OptionList.append("biflowTcp.readBiflow()")
            if FlowOptions.has_key('srcPort'):
                OptionList.append("biflowTcp.setSrcPort(%s)" % (FlowOptions['srcPort']) )
                del FlowOptions['srcPort']
            if FlowOptions.has_key('destPort'):
                OptionList.append("biflowTcp.setDestPort(%s)" % (FlowOptions['destPort']) )
                del FlowOptions['destPort']
            if FlowOptions.has_key('Mss'):
                OptionList.append("biflowTcp.setMss(%s)" % (FlowOptions['Mss']) )
                del FlowOptions['Mss']   
            if FlowOptions.has_key('Window'):
                OptionList.append("biflowTcp.setWindow(%s)" % (FlowOptions['Window']) )
                del FlowOptions['Window']                                
            OptionList.append("biflowTcp.modifyBiflow()")
        elif 'UDP' in FlowOptions['Type']:
            OptionList.append("%s.setType('IP UDP')" % (flowType))
            OptionList.append("udp.readFlow()")
            if FlowOptions.has_key('srcPort'):
                OptionList.append("udp.setSrcPort(%s)" % (FlowOptions['srcPort']) )
                del FlowOptions['srcPort']
            if FlowOptions.has_key('destPort'):
                OptionList.append("udp.setDestPort(%s)" % (FlowOptions['destPort']) )
                del FlowOptions['destPort']
            OptionList.append("udp.modifyFlow()")
        elif 'RTP' in FlowOptions['Type']:
            OptionList.append("%s.setType('IP UDP RTP')" % (flowType))
            OptionList.append("rtp.readFlow()")
            if FlowOptions.has_key('payloadType'):    
                OptionList.append("rtp.setPayloadType(%s)" % (FlowOptions['payloadType']) )        
            else:    
                OptionList.append("rtp.setPayloadType(0)")                
            OptionList.append("rtp.setInitialTimestamp(0)")
            OptionList.append("rtp.setInitialSeqNum(0)")
            OptionList.append("rtp.modifyFlow()")
            OptionList.append("udp.readFlow()")
            if FlowOptions.has_key('srcPort'):
                OptionList.append("udp.setSrcPort(%s)" % (FlowOptions['srcPort']) )
                del FlowOptions['srcPort']
            if FlowOptions.has_key('destPort'):
                OptionList.append("udp.setDestPort(%s)" % (FlowOptions['destPort']) )
                del FlowOptions['destPort']
            OptionList.append("udp.modifyFlow()")        
        else:
            OptionList.append("%s.setType('%s')" % (flowType, FlowOptions['Type']) )

    #Process the other options
    for OptionKey in FlowOptions.keys():
        if OptionKey == 'Type':
            continue
        OptionMethod = "set%s" % (OptionKey)
        if OptionMethod in getMethods(flowType):
            if isnum(FlowOptions[OptionKey]):
                OptionList.append("%s.%s(%s)" % (flowType, OptionMethod, FlowOptions[OptionKey]) )
            else:
                OptionList.append("%s.%s('%s')" % (flowType, OptionMethod, FlowOptions[OptionKey]) )
        else:
            # Leave these along to be processed after a flow write
            if OptionKey not in ['TOS', 'QOS']:
                OutputstreamHDL("Error: Flow option '%s' not supported (ignoring)\n" % (OptionKey), MSG_WARNING)

    # If no user-defined payload, add a default payload of 'Veriwave'.
    if 'Payload' not in FlowOptions.keys():
        OptionList.append("%s.setPayload('%s')" % (flowType, ascii2hex('Veriwave')))
        if flowType == 'flow': # setPayloadLen only applies to 'flow'
            OptionList.append("%s.setPayloadLen(8)" % (flowType))
        OptionList.append("%s.setPayloadMode('fixed')" % (flowType))

    return OptionList

def _processFlowQosOptions(srcPort, FlowOptions):
    if FlowOptions.has_key('QOS'):
        userPriority = FlowOptions['QOS']
        if GetCachePortInfo(srcPort) == '8023':
            VCLtest("enetQos.readFlow()")    
            VCLtest("enetQos.setPriorityTag('on')")
            VCLtest("enetQos.setTgaPriority(%s)" % userPriority)
            VCLtest("enetQos.setUserPriority(%s)" % userPriority)
            VCLtest("enetQos.modifyFlow()")                    
        elif GetCachePortInfo(srcPort) in WiFiPortTypes:
            VCLtest("wlanQos.readFlow()")    
            VCLtest("wlanQos.setTgaPriority(%s)" % userPriority)
            VCLtest("wlanQos.setUserPriority(%s)" % userPriority)
            VCLtest("wlanQos.modifyFlow()")    

def _printCreateStatus(Text, Total, Count):
    global _LastPrintedPercentage
    if Total <= 0:
        OutputstreamHDL("\n", MSG_OK)
        return
    if Total <= 20:
        return
    
    PercentageDone = int( 100 * Count / Total )
    if PercentageDone != _LastPrintedPercentage:
        _LastPrintedPercentage = PercentageDone
        OutputstreamHDL("\r%s: %3d%% written to hardware" % (Text, PercentageDone), MSG_OK)
    
##################################### CreateFlows_Pairs ###################################
# Creates a 1 to 1 port pair between clients
#
# Returns a dictionary of created flow tuples (src_port, src_client, des_port, des_client)
#
def CreateFlows_Pairs(LeftSideClients, RightSideClients,  Bidirectional, FlowOptions={}, Prefix=''):
    if len(LeftSideClients) != len(RightSideClients):
        OutputstreamHDL("Error: Flow port pairing requires an equal number of clients on each side\n", MSG_ERROR)
        raise RaiseException
    
    if not FlowOptions.has_key('Type'):
        OutputstreamHDL("Error: Flow type is not specified\n", MSG_ERROR)
        raise RaiseException        
    pktType = FlowOptions['Type']
    biFlow = False
    flowType = 'flow'
    if pktType == 'TCP':
        flowType = 'biflow'
        biFlow = True     
    
    #Process Flow type options
    StartTime = time.time()
    OptionList = _processFlowOptions(FlowOptions)
    FlowCounter = 0

    #Count total Flows
    if Bidirectional:
        TotalFlows = 2 * len(LeftSideClients)
    else:
        TotalFlows =     len(LeftSideClients)
 
    SrcClientsNames = LeftSideClients.keys()
    DesClientsNames = RightSideClients.keys()
    ListofCreatedFlows = OrderedDict()
    for FlowIndex in range(len(LeftSideClients)):
        Check4UserEscape()
        src_client = SrcClientsNames[FlowIndex]
        src_port   = LeftSideClients[src_client][1]
        des_client = DesClientsNames[FlowIndex]
        des_port   = RightSideClients[des_client][1]
        if isinstance(src_port, list):
            src_port = src_port[0]
        if isinstance(des_port, list):
            des_port = des_port[0]

        FlowName = "F_%s%s-->%s" % (Prefix, src_client, des_client)
        VCLtest("%s.create('%s')"        % (flowType, FlowName))
        VCLtest("%s.setSrcClient('%s')"  % (flowType, src_client))
        VCLtest("%s.setDestClient('%s')" % (flowType, des_client))
        _processFlowQosOptions(src_port, FlowOptions)
        for CurrentOption in OptionList:
            VCLtest(CurrentOption)
        VCLtest("%s.setInsertSignature('on')" % (flowType))
        VCLtest("%s.write('%s')"           % (flowType, FlowName))
        FlowCounter += 1
        ListofCreatedFlows[FlowName] = ( src_port, src_client, des_port, des_client )
        OutputstreamHDL("%s" % '', MSG_OK)
        #_printCreateStatus('Creating Flows', TotalFlows, FlowCounter)
                         # FIXME: remove this once we support bidirectional TCP
    if Bidirectional and biFlow == False:
        for FlowIndex in range(len(LeftSideClients)):
            Check4UserEscape()
            src_client = SrcClientsNames[FlowIndex]
            src_port   = LeftSideClients[src_client][1]
            des_client = DesClientsNames[FlowIndex]
            des_port   = RightSideClients[des_client][1]
            FlowName = "F_%s%s-->%s" % (Prefix, des_client, src_client)
            VCLtest("%s.create('%s')"        % (flowType, FlowName))
            VCLtest("%s.setSrcClient('%s')"  % (flowType, des_client))
            VCLtest("%s.setDestClient('%s')" % (flowType, src_client))
            _processFlowQosOptions(des_port, FlowOptions)
            for CurrentOption in OptionList:
                VCLtest(CurrentOption)
            VCLtest("%s.setInsertSignature('on')" % (flowType) )
            VCLtest("%s.write('%s')"           % (flowType, FlowName))
            FlowCounter += 1
            ListofCreatedFlows[FlowName] = ( des_port, des_client, src_port, src_client )
            OutputstreamHDL("%s" % '', MSG_OK)
            #_printCreateStatus('Creating Flows', TotalFlows, FlowCounter)
    
    #_printCreateStatus('Creating Flows', 0, 0)
    ElaspedTime = time.time() - StartTime
    #OutputstreamHDL("Completed: Wrote %d flows in %.2f seconds\n" % (FlowCounter, ElaspedTime), MSG_SUCCESS)
    return ListofCreatedFlows

##################################### CreateFlows_Many2One ###################################
# Creates a 1 to 1 port pair between clients
#
# Returns a dictionary of created flow tuples (src_port, src_client, des_port, des_client)
#
def CreateFlows_Many2One(ManyClients, OneClients,  Bidirectional, FlowOptions={}, Prefix=''):
    #Process Flow type options
    StartTime = time.time()
    
    if not FlowOptions.has_key('Type'):
        OutputstreamHDL("Error: Flow type is not specified\n", MSG_ERROR)
        raise RaiseException        
    pktType = FlowOptions['Type']
    biFlow = False
    flowType = 'flow'
    if pktType == 'TCP':
        flowType = 'biflow'
        biFlow = True      
    
    OptionList = _processFlowOptions(FlowOptions)
    FlowCounter = 0
    
    #Count total Flows
    TotalFlows =0
    if Bidirectional:
        TotalFlows += 2 * len(ManyClients)
    else:
        TotalFlows += len(ManyClients)
            
    ManyClientsNames = ManyClients.keys()
    OneClientsNames  = OneClients.keys()
    ListofCreatedFlows = OrderedDict()
    for FlowIndex in range(len(ManyClientsNames)):
        Check4UserEscape()
        src_client = ManyClientsNames[FlowIndex]
        des_client = OneClientsNames[0]
        FlowName = "F_%s%s-->%s" % (Prefix, src_client, des_client)
        VCLtest("%s.create('%s')"        % (flowType, FlowName))
        VCLtest("%s.setSrcClient('%s')"  % (flowType, src_client))
        VCLtest("%s.setDestClient('%s')" % (flowType, des_client))
        _processFlowQosOptions(ManyClients[src_client][1], FlowOptions)
        for CurrentOption in OptionList:
            VCLtest(CurrentOption)
        VCLtest("%s.setInsertSignature('on')" % (flowType))
        VCLtest("%s.write('%s')"           % (flowType, FlowName))
        FlowCounter += 1
        #                               src_port, src_client, des_port, des_client
        ListofCreatedFlows[FlowName] = ( ManyClients[src_client][1], src_client, OneClients[des_client][1], des_client)
        #_printCreateStatus('Creating Flows', TotalFlows, FlowCounter)
                         # FIXME: remove this once we support bidirectional TCP
    if Bidirectional and biFlow == False:
        for FlowIndex in range(len(ManyClientsNames)):
            Check4UserEscape()
            src_client = ManyClientsNames[FlowIndex]
            des_client = OneClientsNames[0]
            FlowName = "F_%s%s-->%s" % (Prefix, des_client, src_client)
            VCLtest("%s.create('%s')"        % (flowType, FlowName))
            VCLtest("%s.setSrcClient('%s')"  % (flowType, des_client))
            VCLtest("%s.setDestClient('%s')" % (flowType, src_client))
            _processFlowQosOptions(OneClients[des_client][1], FlowOptions)
            for CurrentOption in OptionList:
                VCLtest(CurrentOption)
            VCLtest("%s.setInsertSignature('on')" % (flowType))
            VCLtest("%s.write('%s')"           % (flowType, FlowName))
            FlowCounter += 1
            ListofCreatedFlows[FlowName] = ( OneClients[des_client][1], des_client, ManyClients[src_client][1], src_client )
            #_printCreateStatus('Creating Flows', TotalFlows, FlowCounter)
    
    #_printCreateStatus('Creating Flows', 0, 0)
    ElaspedTime = time.time() - StartTime
    #OutputstreamHDL("Completed: Wrote %d flows in %.2f seconds\n" % (FlowCounter, ElaspedTime), MSG_SUCCESS)
    return ListofCreatedFlows

##################################### CreateFlows_PartialMesh ###################################
# Creates a many to many  partial meshed pattern between clients
#
# Returns a dictionary of created flow tuples (src_port, src_client, des_port, des_client)
#
def CreateFlows_PartialMesh(LeftSideClients, RightSideClients,  Bidirectional, FlowOptions={}, Prefix=''):
    if not FlowOptions.has_key('Type'):
        OutputstreamHDL("Error: Flow type is not specified\n", MSG_ERROR)
        raise RaiseException        
    pktType = FlowOptions['Type']
    biFlow = False
    flowType = 'flow'
    if pktType == 'TCP':
        flowType = 'biflow'
        biFlow = True      
    
    CountofLeftSideClients  = len(LeftSideClients)
    CountofRightSideClients = len(RightSideClients)
    
    #Process Flow type options
    StartTime = time.time()
    OptionList = _processFlowOptions(FlowOptions)
    FlowCounter = 0

    #Count total Flows
    TotalFlows = CountofLeftSideClients * CountofRightSideClients
    if Bidirectional:
        TotalFlows *= 2
    
    SrcClientsNames = LeftSideClients.keys()
    DesClientsNames = RightSideClients.keys()
    ListofCreatedFlows = OrderedDict()
    currtPrintTime = 0.0
    for left in range(CountofLeftSideClients):
        for right in range(CountofRightSideClients):
            Check4UserEscape()
            SrcNum = left
            DesNum = ( left + right ) % CountofRightSideClients
            src_client = SrcClientsNames[SrcNum]
            des_client = DesClientsNames[DesNum]
            FlowName = "F_%s%s-->%s" % (Prefix, src_client, des_client)
            VCLtest("%s.create('%s')"        % (flowType, FlowName))
            VCLtest("%s.setSrcClient('%s')"  % (flowType, src_client))
            VCLtest("%s.setDestClient('%s')" % (flowType, des_client))
            _processFlowQosOptions(LeftSideClients[src_client][1], FlowOptions)
            for CurrentOption in OptionList:
                VCLtest(CurrentOption)
            VCLtest("%s.setInsertSignature('on')" % (flowType))
            VCLtest("%s.write('%s')"           % (flowType, FlowName))
            FlowCounter += 1
            #                                   src_port, src_client, des_port, des_client
            ListofCreatedFlows[FlowName] = ( LeftSideClients[src_client][1], src_client, RightSideClients[des_client][1], des_client )
            timenow = time.time() - currtPrintTime
            if timenow > 0.25 or int(100 * FlowCounter/TotalFlows) == 100 :    #VPR 3697
                #_printCreateStatus('Creating Flows', TotalFlows, FlowCounter)
                currtPrintTime = time.time()
                         # FIXME: remove this once we support bidirectional TCP
    if Bidirectional and biFlow == False:
        for left in range(CountofLeftSideClients):
            for right in range(CountofRightSideClients):
                Check4UserEscape()
                SrcNum = left
                DesNum = ( left + right ) % CountofRightSideClients
                src_client = DesClientsNames[DesNum]
                des_client = SrcClientsNames[SrcNum]
                FlowName = "F_%s%s-->%s" % (Prefix, src_client, des_client)
                VCLtest("%s.create('%s')"        % (flowType, FlowName))
                VCLtest("%s.setSrcClient('%s')"  % (flowType, src_client))
                VCLtest("%s.setDestClient('%s')" % (flowType, des_client))
                _processFlowQosOptions(RightSideClients[src_client][1], FlowOptions)
                for CurrentOption in OptionList:
                    VCLtest(CurrentOption)
                VCLtest("%s.setInsertSignature('on')" % (flowType))
                VCLtest("%s.write('%s')"           % (flowType, FlowName))
                FlowCounter += 1
                #                                   src_port, src_client, des_port, des_client
                ListofCreatedFlows[FlowName] = ( RightSideClients[src_client][1], src_client, LeftSideClients[des_client][1], des_client )
                #Print out an update
                timenow = time.time() - currtPrintTime
                if timenow > 0.25 or int(100 * FlowCounter/TotalFlows) == 100: #VPR 3697
                    #_printCreateStatus('Creating Flows', TotalFlows, FlowCounter)
                    currtPrintTime = time.time()
    #_printCreateStatus('Creating Flows', 0, 0)
    ElaspedTime = time.time() - StartTime
    #OutputstreamHDL("Completed: Wrote %d flows in %.2f seconds\n" % (FlowCounter, ElaspedTime), MSG_SUCCESS)
    return ListofCreatedFlows

##################################### CreateFlows_FullMesh ###################################
# Creates a fully meshed pattern between clients
#
# Returns a dictionary of created flow tuples (src_port, src_client, des_port, des_client)
#
def CreateFlows_FullMesh(Clients, NotUsedList, NotUsedFlag, FlowOptions={}, Prefix=''):
    if not FlowOptions.has_key('Type'):
        OutputstreamHDL("Error: Flow type is not specified\n", MSG_ERROR)
        raise RaiseException        
    pktType = FlowOptions['Type']
    if pktType == 'TCP':
        flowType = 'biflow'
    else:
        flowType = 'flow'
            
    CountOfClients = len(Clients)
    
    #Process Flow type options
    StartTime = time.time()
    OptionList = _processFlowOptions(FlowOptions)
    FlowCounter = 0
    
    #Count total Flows
    TotalFlows = CountOfClients * (CountOfClients - 1)
        
    ClientsNames = Clients.keys()
    ListofCreatedFlows = OrderedDict()
    for left in range(CountOfClients):
        for right in range(CountOfClients):
            Check4UserEscape()
            SrcNum = left
            DesNum = ( left + right ) % CountofRightSideClients
            if SrcNum != DesNum:
                src_client = ClientsNames[SrcNum]
                des_client = ClientsNames[DesNum]
                FlowName = "F_%s%s-->%s" % (Prefix, src_client, des_client)
                VCLtest("%s.create('%s')"        % (flowType, FlowName))
                VCLtest("%s.setSrcClient('%s')"  % (flowType, src_client))
                VCLtest("%s.setDestClient('%s')" % (flowType, des_client))
                _processFlowQosOptions(LeftSideClients[src_client][1], FlowOptions)
                for CurrentOption in OptionList:
                    VCLtest(CurrentOption)
                VCLtest("%s.setInsertSignature('on')" %(flowType))
                VCLtest("%s.write('%s')"           % (flowType, FlowName))
                FlowCounter += 1
                #                                   src_port, src_client, des_port, des_client
                ListofCreatedFlows[FlowName] = ( LeftSideClients[src_client][1], src_client, RightSideClients[des_client][1], des_client )
                _printCreateStatus('Creating Flows', TotalFlows, FlowCounter)
    
    #_printCreateStatus('Creating Flows', 0, FlowCounter)
    ElaspedTime = time.time() - StartTime
    #OutputstreamHDL("Completed: Wrote %d flows in %.2f seconds\n" % (FlowCounter, ElaspedTime), MSG_SUCCESS)
    return ListofCreatedFlows

##################################### CreateFlows_Custom ###################################
# Creates a custom traffic topology between clients.
# Requires a list of clients names, where other routines require a dictionary.  This works
# around the problem of 2 flows going to the same client.  Does not check for duplicate flow
# names (User MUST use the Prefix option to prevent this).
#
# Returns a dictionary of created flow tuples (src_port, src_client, des_port, des_client)
#
def CreateFlows_Custom(SrcClientNames, DesClientNames, ClientDict, FlowOptions={}, Prefix=''):
    if len(SrcClientNames) != len(DesClientNames):
        OutputstreamHDL("Error: CreateFlows_List requires an equal number of clients on each side\n", MSG_ERROR)
        raise RaiseException

    if not FlowOptions.has_key('Type'):
        OutputstreamHDL("Error: Flow type is not specified\n", MSG_ERROR)
        raise RaiseException        
    pktType = FlowOptions['Type']
    if pktType == 'TCP':
        flowType = 'biflow'
    else:
        flowType = 'flow'

    #Process Flow type options
    StartTime = time.time()
    OptionList = _processFlowOptions(FlowOptions)
    FlowCounter = 0

    #Count total Flows
    TotalFlows = len(SrcClientNames)
 
    ListofCreatedFlows = OrderedDict()
    for FlowIndex in range(len(SrcClientNames)):
        Check4UserEscape()
        src_client = SrcClientNames[FlowIndex]
        src_port   = ClientDict[src_client][1]
        des_client = DesClientNames[FlowIndex]
        des_port   = ClientDict[des_client][1]
        if isinstance(src_port, list):
            src_port = src_port[0]
        if isinstance(des_port, list):
            des_port = des_port[0]

        FlowName = "F_%s%s-->%s" % (Prefix, src_client, des_client)
        VCLtest("%s.create('%s')"        % (flowType, FlowName))
        VCLtest("%s.setSrcClient('%s')"  % (flowType, src_client))
        VCLtest("%s.setDestClient('%s')" % (flowType, des_client))
        _processFlowQosOptions(src_port, FlowOptions)
        for CurrentOption in OptionList:
            VCLtest(CurrentOption)
        VCLtest("%s.setInsertSignature('on')" % (flowType))
        VCLtest("%s.write('%s')"           % (flowType, FlowName))
        FlowCounter += 1
        ListofCreatedFlows[FlowName] = ( src_port, src_client, des_port, des_client )
        #_printCreateStatus('Creating Flows', TotalFlows, FlowCounter)
            
    #_printCreateStatus('Creating Flows', 0, 0)
    ElaspedTime = time.time() - StartTime
    #OutputstreamHDL("Completed: Wrote %d flows in %.2f seconds\n" % (FlowCounter, ElaspedTime), MSG_SUCCESS)
    return ListofCreatedFlows

################################# ConnectBiflow ################################
# issue biflow.connect() to initiate the TCP 3-way handshake for all biflows
# input:
# - flowList: list of biflow names
# output:
# - status: -1 if TCP handshake failed, 0 if successful
#
def ConnectBiflow(flowList, clientTimeOut=10, totalTimeOut=10, expectedState=BIFLOW_STATE_READY, operation='connect', noSummary=False):
    def getAppErrorStr(flowName):
        try:
            fwdErrorMsg = ""
            fwdErr = int(clientStateDict[flowName]['Forward:Application Error'])
            if fwdErr < 0:
                fwdErrorMsg = vclAppError(fwdErr)
            revErrorMsg = ""
            revErr = int(clientStateDict[flowName]['Reverse:Application Error'])
            if revErr < 0:
                revErrorMsg = vclAppError(revErr)      
            return (fwdErrorMsg, revErrorMsg)
        except:
            return ("", "")

    connectTime = {}
    totalConnectTime = vclTime()
    flowLen = len(flowList)
    clientStateDict = OrderedDict()
    
    if noSummary == False:
        OutputstreamHDL("\nAttempting TCP %s operation on %d flow(s)\n" % (operation, len(flowList)), MSG_OK)
    
    # connect/disconnect all biflow at 1 shot
    for flowName in flowList:
        try:
            clientStateDict[flowName] = OrderedDict()
            clientStateDict[flowName]['Forward:Application State'] = ''
            clientStateDict[flowName]['Forward:State'] = ''
            clientStateDict[flowName]['Forward:Application Error'] = ''
            clientStateDict[flowName]['Reverse:Application State'] = ''
            clientStateDict[flowName]['Reverse:State'] = ''
            clientStateDict[flowName]['Reverse:Application Error'] = ''   
            connectTime[flowName] = vclTime()  
            if operation == 'resetConnection':   
                VCLtest("biflow.%s('%s','both')" % (operation, flowName))                    
            else:                                    
                VCLtest("biflow.%s('%s')" % (operation, flowName))
            # print '' to log screen so WaveApps UI doesn't freeze
            OutputstreamHDL("%s" % '', MSG_OK)
        except:
            strStates = ""
            for item in clientStateDict[flowName].keys():     
                strStates += item + ": " + biflow.get(item) + ",\t"  
            if noSummary == False:   
                (fwdErrorMsg, revErrorMsg) = getAppErrorStr(flowName)  
                OutputstreamHDL("\nError: TCP %s operation failed for %s\n%s\n%s" % (operation, flowName, fwdErrorMsg, revErrorMsg), MSG_ERROR)                
            WriteL7Log()
            return -1                 

    # wait for 0.1 sec before start polling TCP connection state
    time.sleep(0.1)
    flowCtr = 0
    # calculate the total time out. 
    tempTime = totalTimeOut + (clientTimeOut * len(flowList))
    if tempTime > 90:
        # VPR 5031: limit the max total time out to 120 sec
        totalTimeOut = vclTime() + 90
    else:                                       
        totalTimeOut = vclTime() + totalTimeOut + (clientTimeOut * len(flowList))    
    
    # check the TCP connection state
    while len(flowList) != 0 and (totalTimeOut - vclTime() > 0):
        removeList = []
        for flowName in flowList:
            # print '' to log screen so WaveApps UI doesn't freeze
            OutputstreamHDL("%s" % '', MSG_OK)
            InsertTimelogMessage("biflow.checkStatus('%s', '%s')" % (flowName, expectedState))
            state = biflow.checkStatus(flowName, expectedState)  
            
            # query 6 biflow states, print them to timelog       
            statusChanged = False
            strStates = ""
            for item in clientStateDict[flowName].keys():
                biflowState = biflow.get(item) 
                if biflowState != clientStateDict[flowName][item]:    
                    statusChanged = True
                    # update to the current state
                    clientStateDict[flowName][item] = biflowState
                strStates += item + ": " + clientStateDict[flowName][item] + ",\t"    
            if statusChanged == True:
                # state has changed since last query, so print states to timelog
                InsertTimelogMessage("%s: %s" % (flowName, strStates))    
            if flowCtr%30 == 0 or len(flowList) < 30:                              
                time.sleep(0.01) # sleep for 10 ms for every 30 checkStatus'
            flowCtr += 1            
                    
            if state == -101:
                continue
            elif state == 0:              
                if biflow.getState() == expectedState: 
                    #OutputstreamHDL("\r%.2fsec %s forward & reverse flows achieved %s state" % 
                    #                (biflow.get('Forward:Connection Time'), flowName, expectedState), MSG_OK)                    
                    if noSummary == False:
                        OutputstreamHDL("\r%.2fsec %s forward & reverse flows achieved %s state" % 
                                        ((vclTime()-connectTime[flowName]), flowName, expectedState), MSG_OK)
                    removeList.append(flowName)
                    continue  
            # if drop here, operation failed                                                           
            if operation == 'disconnect':
                if noSummary == False:   
                    OutputstreamHDL("\n%s: TCP disconnect operation failed, resetting the TCP connection\n" % (flowName), MSG_OK)                                            
                if ConnectBiflow([flowName,], totalTimeOut=10, expectedState=BIFLOW_STATE_IDLE, operation='resetConnection', noSummary=True) < 0:
                    return -1            
                else:
                    removeList.append(flowName) 
            elif operation == 'resetConnection':
                # ignore the error
                return 0
            else:
                if noSummary == False:
                    (fwdErrorMsg, revErrorMsg) = getAppErrorStr(flowName)
                    OutputstreamHDL("\nError: TCP %s operation failed for %s\n%s\n%s" % (operation, flowName, fwdErrorMsg, revErrorMsg), MSG_ERROR)
                WriteL7Log()
                return -1 
        # remove the flows  flowList    
        for i in removeList:
            flowList.remove(i)
        time.sleep(0.01) # sleep for 10 ms in between retries
    if flowList != []:     
        if operation == 'disconnect':
            # if disconnect failed, force a reset connection
            if noSummary == False:   
                OutputstreamHDL("\nTCP disconnect operation timed out, resetting the TCP connection\n", MSG_OK)                            
            if ConnectBiflow(flowList, totalTimeOut=10, expectedState=BIFLOW_STATE_IDLE, operation='resetConnection', noSummary=True) < 0:
                return -1                       
            #for flowName in flowList:
                #VCLtest("biflow.%s('%s','%s')" % ('resetConnection', flowName, 'both'))
        elif operation == 'resetConnection':
            # ignore the error
            return 0
        else:    
            if noSummary == False:   
                OutputstreamHDL("\nError: TCP %s operation timed out\n" % (operation), MSG_ERROR)                
            WriteL7Log()
            return -1
    totalTime = vclTime()-totalConnectTime
    if noSummary == False:
        OutputstreamHDL("\nCompleted %d TCP %s operation in %.2f sec\n" % (flowLen, operation, totalTime), MSG_OK)                    
        OutputstreamHDL("TCP %s rate is %.2f connection/sec\n" % (operation, flowLen/totalTime), MSG_OK)
    return 0

################################## WriteL7Log ##################################
# Write L7 app daemon log to file
# 
def WriteL7Log(ScriptName=None):
    # VPR 4896: create L7 appd log files
    if ScriptName == None:
        ScriptName = ""
        # Quick & dirty hack: fetch the test name from the console file name  
        Temp = re.search("(Console_)([.0-9a-zA-Z_-]+).html", _Console_FileName)
        if Temp != None:
            ScriptName = Temp.group(2)     
    for portname in port.getNames():
        try:
            res = re.split('port', portname)
            slot_num = res[1]
            query = "http://%s/cgi-bin/execute_slot_linux_cmd.cgi?slot=%d&cmd=cat&param1=/tmp/l7appd.log" % (chassis.getIpAddress(), int(slot_num))            
            l7log = urllib.urlopen(query)
            l7LogFileName = os.path.join(_LoggingDirectoryPath, "L7appdlog_port%s_" % str(slot_num) + ScriptName + ".txt")
            _l7_Fhdl = open(l7LogFileName, 'w')
            _l7_Fhdl.write(l7log.read())
            _l7_Fhdl.close() 
        except:
            OutputstreamHDL("\nError: failed to write the L7 appd log to the files\n", MSG_ERROR)
            break
            
################################# DestroyBiflow #################################
# Destroy all biflows
#
def DestroyBiflow():
    for fgname in flowGroup.getNames():
        action.stopFlowGroup(fgname)
    biflowList = biflow.getNames()
    if biflowList != ():
        for flowname in biflowList:
            biflow.destroy(flowname)
        #Sleep(2, "Destroying all TCP connections") 
                
##################################### ModifyFlows ###################################
# Modify existsing flows with new options
#
# Input:
# - FlowList: dict of flows
# - FlowOptions: flow options
# - doTcpConnect: valid only for TCP (biflow). If it's set to True, we will disconnect
#                 and reconnect all TCP flows before and after modifying the flow
#                 properties. Set this flag to False if you want to perform TCP
#                 disconnect & connect in the test script itself.
def ModifyFlows(FlowList, FlowOptions, doTcpConnect=True):  
    if not FlowOptions.has_key('Type'):
        OutputstreamHDL("Error: Flow type is not specified\n", MSG_ERROR)
        raise RaiseException        
    pktType = FlowOptions['Type']
    if pktType == 'TCP':
        flowType = 'biflow'
    else:
        flowType = 'flow'  

    # VPR 4935:
    # 'Type' is only needed to determine whether it's a biflow or flow
    # We don't need to re-set the type since we've already set it when we create the flow
    del FlowOptions['Type']
             
    #Process the option field
    OptionList = []
    TcpOptionList = []
    for OptionKey in FlowOptions.keys():
        OptionMethod = "set%s" % (OptionKey)
        if OptionMethod in getMethods(flowType):
            if isnum(FlowOptions[OptionKey]):
                OptionList.append("%s.%s(%s)" % (flowType, OptionMethod, FlowOptions[OptionKey]))
            else:
                OptionList.append("%s.%s('%s')" % (flowType, OptionMethod, FlowOptions[OptionKey]))
        # check if it's a biflowTcp method
        elif flowType == 'biflow' and OptionMethod in getMethods('biflowTcp'):
            if isnum(FlowOptions[OptionKey]):
                TcpOptionList.append("%s.%s(%s)" % ('biflowTcp', OptionMethod, FlowOptions[OptionKey]))
            else:
                TcpOptionList.append("%s.%s('%s')" % ('biflowTcp', OptionMethod, FlowOptions[OptionKey]))                
        else:
            if OptionKey not in ['TOS', 'QOS']:
                OutputstreamHDL("Error: Modify Flow option '%s' not supported (ignoring)\n" % (OptionKey), MSG_WARNING)

    TotalFlows  = len(FlowList)
    FlowCounter = 0
    currtPrintTime = 0.0
    
    if flowType == 'biflow' and doTcpConnect == True:   
        # for biflow TCP, before modifying biflow attributes we need to:
        # - disconnect the biflow
        # - set the biflow attributes
        # - reconnect the biflow
        if ConnectBiflow(FlowList.keys(), totalTimeOut=10, expectedState=BIFLOW_STATE_IDLE, operation='disconnect') < 0:
            raise RaiseException            
                
    for FlowName in FlowList.keys():
        Check4UserEscape()   
        VCLtest("%s.read('%s')"  % (flowType, FlowName))       
        for CurrentOption in OptionList:
            VCLtest(CurrentOption)
        if TcpOptionList != []:
            VCLtest("biflowTcp.readBiflow()")
            for CurrentOption in TcpOptionList:
                VCLtest(CurrentOption)        
            VCLtest("biflowTcp.modifyBiflow()")
            
        # Set the QOS bits in the 802.11e header
        _processFlowQosOptions(FlowList[FlowName][0], FlowOptions)

        """
        #VPR 4736: adjust the IP length size if we have VLAN tag
        lengthMac = 18
        if GetCachePortInfo(FlowList[FlowName][0]) == '8023':
            VCLtest("ec.read('%s')" % (FlowList[FlowName][1]))    
            if ec.getVlanTag() != -1:  
                lengthMac = 22
        """
        if flowType == 'flow':
            # Workaround for VPR 2822
            lengthMac = 18
            LengthIP  = int(flow.getFrameSize()) - lengthMac
            LengthUDP = LengthIP - 20
            if 'IP' in flow.getType():
                VCLtest("ipv4.readFlow()")
                VCLtest("ipv4.setTotalLength(%d)" % (LengthIP) )
                if FlowOptions.has_key('TOS'):
                    # Set the TOS bits
                    VCLtest("ipv4.setTosField(%s)" % FlowOptions['TOS'] )
                VCLtest("ipv4.modifyFlow()")
            if 'UDP' in flow.getType():
                pass
                #VCLtest("udp.readFlow()")
                #print "UDP:", FlowName, dir(udp)
                # FIXME - UDP lengths still wrong
                #VCLtest ("udp.setTotalLength(%d)" % (LengthUDP) )
                #VCLtest("udp.modifyFlow()")
            
        FlowCounter += 1
        VCLtest("%s.write('%s')" % (flowType, FlowName)) 
                         
        timenow = time.time() - currtPrintTime
        if timenow > 0.25 or int(100*FlowCounter/TotalFlows) == 100:    #VPR 3697
            #_printCreateStatus('Modifying Flows', TotalFlows, FlowCounter)
            currtPrintTime = time.time()
      
    #FIXME: a trial should consist of connect, flow setup and disconnect     
    if flowType == 'biflow':
        Sleep(2, "Configuring TCP flows")   
        if doTcpConnect == True:                    
            # reconnect all biflows        
            if ConnectBiflow(FlowList.keys()) < 0:
                raise RaiseException
    
##################################### CreateFlowGroup ###################################
# Connects clients to the AP
#
def CreateFlowGroup(FlowList, GroupName):
    StartTime = time.time()
    VCLtest("flowGroup.create('%s')" % (GroupName))
    for FlowName in FlowList.keys():
        VCLtest("flowGroup.add('%s')" % (FlowName))
    VCLtest("flowGroup.write('%s')" % (GroupName))
    ElaspedTime = time.time() - StartTime
    if ElaspedTime > 0.100:
        OutputstreamHDL("Completed: Created flowGroup '%s' in %.2f seconds\n" % (GroupName, ElaspedTime), MSG_SUCCESS)

##################################### ExchangeARP ###################################
# Do an ARP exchange on the flows and check to see if it worked
#
# GroupName - no longer used, kept for backwards compatibility
# Rate      - Number of ARP request ststaed per second.  Set to 0.0 to disable ARPs
# Retry     - Number of times each flow will attempt to retry if no ARP responce
# Timeout   - number of seconds AFTER the lat ARP is initated to wait before giving up.
#
# Returns: Positive number is number of seconds for all flows to compete the exchange
#          Negative number means some did not complete
#
def ExchangeARP(FlowDict, GroupName, Rate=100, Retry=3, Timeout=10):
    IntervalPrintSec = 0.2
    
    if len(FlowDict) == 0:
        return 0
    if Rate == 0.0 :
        OutputstreamHDL("\nWarning: ARP rate of zero set (bypassing the ARP process)\n", MSG_WARNING)
        return Rate
    ARPstatus      = {}
    FlowRetryCount = {}
    FlowTimeoutSec = {}
    FlowIndex = 0
    FailedARP = False
    flowType = 'flow'
    if Rate < 1.0 :
        OutputstreamHDL("\nWarning: Changing the ARP rate to be 1 ARP/second (minimum supported)\n", MSG_WARNING)
        Rate = 1
    if Rate > 500.0 :
        OutputstreamHDL("\nWarning: Changing the ARP rate to be 500 ARPs/second (maximum supported)\n", MSG_WARNING)
        Rate = 500
    FlowListLength = 0
    FlowList = FlowDict.keys()
    for FlowName in FlowList:
        FlowRetryCount[FlowName] = Retry + 1
        FlowTimeoutSec[FlowName] = time.time() + (float(FlowListLength) / float(Rate))
        FlowListLength += 1
        ARPstatus[FlowName] = None
        
    StartTime = time.time()
    StopTime  = StartTime + Timeout + float(FlowListLength)/float(Rate)
    PrintTime = StartTime
    while StopTime > time.time():
        # Start the ARP and retry if timed out
        for FlowName in FlowTimeoutSec.keys():
            if time.time() >= FlowTimeoutSec[FlowName]:
                if FlowRetryCount[FlowName] > 0:
                    VCLtest("%s.doArpExchange('%s')" % (flowType, FlowName))
                    FlowTimeoutSec[FlowName] = time.time() + pow(2, Retry - FlowRetryCount[FlowName])
                    FlowRetryCount[FlowName] -= 1
                    ARPstatus[FlowName]      = 0  
                else:
                    del FlowTimeoutSec[FlowName]
           
        #Get the state for a flow that is currently zero
        StartIndex = FlowIndex
        while True:
            FlowName = FlowList[FlowIndex]
            FlowIndex += 1
            if FlowIndex >= FlowListLength:
                FlowIndex = 0
            if ARPstatus[FlowName] == 0:
                ARPstatus[FlowName] = VCLtest("%s.doArpStatus('%s')" % (flowType, FlowName) )
                if ARPstatus[FlowName] == 1:
                    #ARP complete, take out of the retry list
                    if FlowTimeoutSec.has_key(FlowName):
                        del FlowTimeoutSec[FlowName]
                break
            elif FlowIndex == StartIndex: # We cycled through all the flows
                break
            
        #Update the display if it is time
        if time.time() > PrintTime:
            CountNone   = 0
            CountActive = 0
            CountDone   = 0
            for FlowName in FlowList:
                if ARPstatus[FlowName] == 0:
                    CountActive += 1
                elif ARPstatus[FlowName] == 1:
                    CountDone += 1
                else:
                    CountNone += 1
            remainingTime = StopTime - time.time()
            #Hack to avoid printing negative times, this can happen when 
            #we have a NAT device
            if remainingTime < 0:
                remainingTime = 0.0
            OutputstreamHDL("\rExchanging ARPs, Idle: %d Active: %d Completed: %d (%.1f secs remaining)" % (CountNone, CountActive, CountDone, remainingTime), MSG_OK)     
            PrintTime = time.time() + IntervalPrintSec
            if FlowListLength == CountDone:
                break            
    else:
        OutputstreamHDL("\n", MSG_OK)
        for FlowName in FlowList:
            if ARPstatus[FlowName] == None:
                (src_port, src_client, des_port, des_client) = FlowDict[FlowName]
                OutputstreamHDL("Error: Flow %s did not start an ARP request from port %s\n" % (FlowName, src_port), MSG_ERROR)
            elif VCLtest("%s.doArpStatus('%s')" % (flowType, FlowName)) == 0:
                (src_port, src_client, des_port, des_client) = FlowDict[FlowName]
                if GetCachePortInfo(src_port) == '8023':
                    VCLtest("ec.read('%s')" % (src_client))
                    src_ip     = ec.getIpAddress()
                    src_subnet = ec.getSubnetMask()
                    src_gateway= ec.getGateway()
                if GetCachePortInfo(src_port) in WiFiPortTypes:
                    VCLtest("mc.read('%s')" % (src_client))
                    src_ip     = mc.getIpAddress()
                    src_subnet = mc.getSubnetMask()
                    src_gateway= mc.getGateway()
                if GetCachePortInfo(des_port) == '8023':
                    VCLtest("ec.read('%s')" % (des_client))
                    des_ip     = ec.getIpAddress()
                if GetCachePortInfo(des_port) in WiFiPortTypes:
                    VCLtest("mc.read('%s')" % (des_client))
                    des_ip     = mc.getIpAddress()
                numSub = IPv4toInt(src_subnet)
                numIPs = numSub & IPv4toInt(src_ip)
                numIPd = numSub & IPv4toInt(des_ip)
                if numIPs == numIPd:
                    Arp_ip = "Destination %s" % (des_ip)
                else:
                    Arp_ip = "Gateway %s" % (src_gateway)
                OutputstreamHDL("Error: Flow %s Source %s did not receive an ARP response from %s\n" % (FlowName, src_ip, Arp_ip), MSG_ERROR)
                FailedARP = True

    if FailedARP:
        return -1
    ElaspedTime = time.time() - StartTime
    OutputstreamHDL("\nCompleted: %d flows finished ARP in %.2f seconds\n" % (FlowListLength, ElaspedTime), MSG_SUCCESS)
    return int(ElaspedTime * 1000)

    
##################################### TransmitIteration ###################################
# Do a test iteration
# WARNING: Make sure that UpdateFunction returns before the UpdateTime, otherwise bad things will happen
#
def TransmitIteration(TXtime, RXtime, UpdateTime, GroupName, StopTX, UpdateFunction, PassedParameters):
    scheduler = sched.scheduler(time.time, time.sleep)

    #               delay, priority,  action, arguments
    scheduler.enter(    0,        1, startFlowAndNoteTime,(GroupName,) )
    if StopTX:
        scheduler.enter(TXtime,     1, stopFlowAndNoteTime, (GroupName,) )

    for n in range(int((TXtime + RXtime) / UpdateTime)):
        ElapsedTime = UpdateTime * (n+1)
        Timeleft    = (TXtime + RXtime) - ElapsedTime
        Transmitting_Flag = 'TX'
        if ElapsedTime > TXtime:
            Transmitting_Flag = 'RX'
        # Do not call the realtime stats when its close to stopping the flows
        if TXtime - ElapsedTime > UpdateTime or ElapsedTime > TXtime:
            scheduler.enter(ElapsedTime,     100, UpdateFunction, (Transmitting_Flag, Timeleft, ElapsedTime, PassedParameters))
    scheduler.enter(TXtime + RXtime, 100, UpdateFunction, (Transmitting_Flag, 0.0, TXtime + RXtime, PassedParameters))

    #Run the Iteration
    scheduler.run()
    
    return getLatestFlowTime(GroupName)
    
_gLatestTransmitTimeOfFlowGroup = {}

def startFlowAndNoteTime(flowGroupName):
    """
    Sometimes the sched.scheduler doesn't time the events with the accuracy 
    desired but timing is critical for the measurements taken in benchmark tests
    as we can't control the transmit time of flow, we would note down the time
    and make the measurements based on this actual transmit time (obtained by 
    difference in the stop and start of flow timings) 
    """
    global _gLatestTransmitTimeOfFlowGroup
    
    _gLatestTransmitTimeOfFlowGroup[flowGroupName] = {}
    
    VCLtest("action.startFlowGroup('%s')" %flowGroupName )
    _gLatestTransmitTimeOfFlowGroup[flowGroupName]['StartTime'] = time.time()
    
def stopFlowAndNoteTime(flowGroupName):
    """
    See doc of startFlowAndNoteTime
    """
    global _gLatestTransmitTimeOfFlowGroup
    VCLtest("action.stopFlowGroup('%s')" %flowGroupName)
 
    _gLatestTransmitTimeOfFlowGroup[flowGroupName]['StopTime'] = time.time()
    
def getLatestFlowTime(flowGroupName):
    global _gLatestTransmitTimeOfFlowGroup
    if flowGroupName not in _gLatestTransmitTimeOfFlowGroup:
        print "Can't find %s in  _gLatestTransmitTimeOfFlowGroup"%flowGroupName
    else:
        if 'StartTime' and 'StopTime' in _gLatestTransmitTimeOfFlowGroup[flowGroupName]:
            flowTime = (_gLatestTransmitTimeOfFlowGroup[flowGroupName]['StopTime'] 
                        - 
                        _gLatestTransmitTimeOfFlowGroup[flowGroupName]['StartTime'])
        
            return flowTime

    
##################################### TransmitIterationForBlogCards ###################################
# Do a test iteration
# WARNING: Make sure that UpdateFunction returns before the UpdateTime, otherwise bad things will happen
#

def TransmitIterationWithBlogCards(TXtime, RXtime, UpdateTime, GroupName, StopTX, UpdateFunction, PassedParameters, waveBlogStore):
    scheduler = sched.scheduler(time.time, time.sleep)
    #Find out the frame size strike probability and the corresponding bin that
    #it belongs to so that the corresponding bin can be configured when
    #ConfigureBlogPorts method is called
    FrameSize = int(PassedParameters['FrameSize'])
    blogPortList = []
    for portName in waveBlogStore:
        #Set the default strike probability and binId 
        strikeProbability = []        
        binId = 0
        if waveBlogStore[portName]['BlogMode'] == 'True':
            binNamesList = waveBlogStore[portName]['BlogBinSetUpConfig'].keys()
            binNamesList.sort()
            for eachBin in binNamesList:
                lowValue = int(waveBlogStore[portName]['BlogBinSetUpConfig'][eachBin]['BinLow'])
                highValue = int(waveBlogStore[portName]['BlogBinSetUpConfig'][eachBin]['BinHigh'])
                if FrameSize in range(lowValue,highValue):
                    binLow = lowValue
                    binHigh = highValue 
                    binId = int(eachBin.split('_')[1])
            if binId == 0:
                OutputstreamHDL("Frame size being iterated does not fall into any of the bin boundaries", MSG_WARNING)
            else:
                scheduler.enterabs(0,1,ConfigureBlogPorts,(portName, waveBlogStore))
                blogPortList.append(portName)

    #               delay, priority,  action, arguments
    scheduler.enter(    0,        1, VCLtest, ("action.startFlowGroup('%s')" % (GroupName), ))

    if StopTX:
        scheduler.enter(TXtime,     1, VCLtest, ("action.stopFlowGroup('%s')" % (GroupName), ))
        for blogPortName in blogPortList:
            scheduler.enter(TXtime,     1,ConfigureBlogPortsToTgaMode,(blogPortName,))
    for n in range(int((TXtime + RXtime) / UpdateTime)):
        ElapsedTime = UpdateTime * (n+1)
        Timeleft    = (TXtime + RXtime) - ElapsedTime
        Transmitting_Flag = 'TX'
        if ElapsedTime > TXtime:
            Transmitting_Flag = 'RX'
        # Do not call the realtime stats when its close to stopping the flows
        if TXtime - ElapsedTime > UpdateTime or ElapsedTime > TXtime:
            scheduler.enter(ElapsedTime,     100, UpdateFunction, (Transmitting_Flag, Timeleft, ElapsedTime, PassedParameters))
    scheduler.enter(TXtime + RXtime, 100, UpdateFunction, (Transmitting_Flag, 0.0, TXtime + RXtime, PassedParameters))

    #Run the Iteration
    scheduler.run()
    
def ConfigureBlogPorts(Portname, waveBlogStore):
    """
    Configure the BLOG Port with the specific Portname
    """
    #Initialize the bins that need to be configured by default for VCL along with
    #a defaultStrikeProbability of 0.
    bin4High = 2340
    bin4Low  = 1765
    bin3High = 1765
    bin3Low  = 1190
    bin2High = 1190
    bin2Low  =  615
    bin1High =  615
    bin1Low  =   40
    defaultStrikeProbability = 0
    
    OutputstreamHDL("Starting interference generation from port (in IG mode) : %s " % Portname,MSG_OK)
    #Get the chassis, port and card number from the PortName string,
    #nice hah..:-)...we create our portnames in a nice way...:-)
    ChassisName = str(Portname.split('_')[0])
    CardNumber = PSM.ChassisCardPort.getCardNum(Portname)
    PortNumber = PSM.ChassisCardPort.getPortNum(Portname)
    
    #Bind to the ports to get the port in the "og" mode
    VCLtest("port.create('%s')" % (Portname))
    VCLtest("port.bind('%s', '%s', %s, %s)" % (Portname, ChassisName, CardNumber, PortNumber) )
    VCLtest("port.reset('%s')" % (Portname))
    time.sleep(0.2)
    if VCLtest("port.getType") == '8023':
        OutputstreamHDL("BLOG Card selected is an ethernet card", MSG_ERROR)
        VCLtest("port.unbind('%s')" %(Portname))
        return
    VCLtest("port.setRadio('on')")
    VCLtest("port.write('%s')" %(Portname))
    VCLtest("port.read('%s')" %(Portname))
    VCLtest("port.setOperationalMode('og')")
    VCLtest("port.write('%s')" %(Portname))
    VCLtest("port.read('%s')" %(Portname))
    if VCLtest("port.getOperationalMode()") == 'og':
        binNamesList = waveBlogStore[Portname]['BlogBinSetUpConfig'].keys()
        binNamesList.sort()
        binLow = []
        binHigh = []
        strikeProbability = []
        for eachBin in binNamesList:
            binId = int(eachBin.split('_')[1])
            binLow.append(int(waveBlogStore[Portname]['BlogBinSetUpConfig'][eachBin]['BinLow']))
            binHigh.append(int(waveBlogStore[Portname]['BlogBinSetUpConfig'][eachBin]['BinHigh']))
            #binId = int(eachBin.split('_')[1])
            strikeProbability_percent = int(waveBlogStore[Portname]['BlogBinSetUpConfig'][eachBin]['BinStrikeProbability'])
            #Convert the striking percent value to hardware register values from 0 - 255
            strikeProbability.append(int(math.ceil(strikeProbability_percent * 2.55)))

        #Set all the bins with the valid striking probabilities
        VCLtest("port.setOgBin4Low(%d)" % binLow[3], globals())
        VCLtest("port.setOgBin4High(%d)" % binHigh[3], globals())
        VCLtest("port.setOgBin4Probability(%d)" %strikeProbability[3], globals())
        
        VCLtest("port.setOgBin3Low(%d)" % binLow[2], globals())
        VCLtest("port.setOgBin3High(%d)" % binHigh[2], globals())
        VCLtest("port.setOgBin3Probability(%d)" %strikeProbability[2], globals())
        
        VCLtest("port.setOgBin2Low(%d)" % binLow[1], globals())
        VCLtest("port.setOgBin2High(%d)" % binHigh[1], globals())
        VCLtest("port.setOgBin2Probability(%d)" %strikeProbability[1], globals())
        
        VCLtest("port.setOgBin1Low(%d)" % binLow[0], globals())
        VCLtest("port.setOgBin1High(%d)" % binHigh[0], globals())
        VCLtest("port.setOgBin1Probability(%d)" %strikeProbability[0], globals())
                        
        VCLtest("port.write('%s')" %(Portname))
        #VCLtest("port.read('%s')" %(Portname))
        
def ConfigureBlogPortsToTgaMode(Portname):
    """
    Switch the port back to TGA mode
    after the interference generation
    schedule for that particular port
    has completed
    """
    
    OutputstreamHDL("Stopping interference generation from port (in IG mode) : %s " % Portname,MSG_OK)
    VCLtest("port.read('%s')" %(Portname))
    if VCLtest("port.getOperationalMode()") == 'og':
        VCLtest("port.read('%s')" %(Portname))
        VCLtest("port.setOperationalMode('tga')")
        VCLtest("port.write('%s')" %(Portname))
        VCLtest("port.read('%s')" %(Portname))

    if Portname in port.getNames():
        VCLtest("port.destroy('%s')" %(Portname))

##################################### MeausreThroughput ###################################
# Measure the thourghput and show just a progress bar
#
def MeausreThroughput(CardList, FlowList, TransmitTime, SettleTime, FlowGroupName, minimum, maximum, resolution, SearchAcceptLossPercent):
    SearchLogic = BinarySerach()
    SearchLogic.minimum(minimum)
    SearchLogic.maximum(maximum)
    SearchLogic.resolution(resolution)
    Totalinterations = 1 + int( log((maximum - minimum) / resolution) / log(2.0) )
    
    # Internal handle for realtime stats
    prog = progressBar(0, TransmitTime * Totalinterations, 60)
    def tputRealtimeStats(TXstate, Timeleft, ElapsedTime, PassedParameters):
        prog.updateAmount(ElapsedTime + PassedParameters)
        OutputstreamHDL("\rMeasuring Throughput ", MSG_OK)
        OutputstreamHDL(prog.progBar, MSG_OK)
        
    IterationCount = 0
    MaxOLOAD = 0.0
    while SearchLogic.searching():
        ModifyFlows(FlowList, {'IntendedRate': SearchLogic.query() ,'NumFrames': MAXtxFrames})
        ClearAllCounter(CardList)
        TransmitIteration(TransmitTime, SettleTime, 1.0, FlowGroupName, True, tputRealtimeStats , IterationCount * TransmitTime )
        (OLOAD, FR, FrameLossRate) = MeasureFlow_OLOAD_FR_LossRate(FlowList, TransmitTime)
        if FrameLossRate > SearchAcceptLossPercent:
            SearchLogic.FAIL()
        else:
            SearchLogic.PASS()
            MaxOLOAD = OLOAD
        IterationCount += 1
    
    # return results for that frame size
    OutputstreamHDL("\n", MSG_OK)
    if SearchLogic.neverpassed:
        return -1
    else:
        return MaxOLOAD

##################################### RoamingIteration ###################################
# Handles roaming events during the test iteration 
# UpdateFunction(MessageString, ElapsedTime, Transmitting_Flag, PassedParameters)
def RoamingIteration(ListOfCards, RoamingSchedule, EthClientName, TXtime, RXtime, UpdateTime, GroupName, UpdateFunction, PassedParameters):
    # Test for Stupidity
    if not len(ListOfCards) > 0:
        OutputstreamHDL("Error: RoamingIteration was passed a empty list of used cards.\n", MSG_ERROR)
        raise RaiseException
    if not len(RoamingSchedule) > 0:
        OutputstreamHDL("Error: It's not roaming unless there is at least one entry in RoamingSchedule.\n", MSG_ERROR)
        raise RaiseException
       
    WaitForCountersoZero(ListOfCards, TXtime)
    _sMessage = ''
    roam_delay_list = []
    roam_delay_client_name = []
    def PrintStatsLine(Cards, Blank_Flag, Time, TX_Flag):
        _sMessage = '\r'
        iReturn  = 0
        for PortName in Cards:
            if Blank_Flag:
                _sMessage    += "                    "
            else:
                VCLtest("stats.setDefaults()")
                VCLtest("stats.read('%s')" % (PortName))
                txDataFrames = stats.txIpPacketsOk
                rxDataFrames = stats.rxIpPacketsOk
                iReturn     += abs(txDataFrames) + abs(rxDataFrames)
                _sMessage    += "%9ld %9ld " % (txDataFrames, rxDataFrames)
        _sMessage +=  "%4.1f %2s" % (Time, TX_Flag)
        return OutputstreamHDL(_sMessage, MSG_OK)

    for Portname in ListOfCards:
        OutputstreamHDL("     %9s      " % (Portname), MSG_OK)
    OutputstreamHDL("\n", MSG_OK)    
    for Portname in ListOfCards:
        OutputstreamHDL("       TX        RX ", MSG_OK)
    OutputstreamHDL("Time Mode Last_Action\n", MSG_OK)
    iReturn = -1
        
    VCLtest("action.startFlowGroup('%s')" % (GroupName))
    Test_StartTime = time.clock()
    Test_UpdateTime= Test_StartTime + UpdateTime
    Test_StopTime  = Test_StartTime + TXtime
    Test_DoneTime  = Test_StopTime + RXtime
    Transmitting_Flag = 'TX'
    RoamEventIndex = 0
    NextRoamEvent  = RoamingSchedule[RoamEventIndex]
    ActiveRoamClient = []
    while Test_DoneTime > time.clock():
        ElapsedTime = time.clock() - Test_StartTime
        if time.clock() > Test_StopTime and Transmitting_Flag == 'TX':
            VCLtest("action.stopFlowGroup('%s')" % (GroupName))
            Transmitting_Flag = 'RX'
            _sMessage = "\n"
            OutputstreamHDL(_sMessage, MSG_OK)
            UpdateFunction(_sMessage, ElapsedTime, Transmitting_Flag, PassedParameters)

        #Roaming schedular - list contains: $Absol_time $Client $port $up_time $down_time
        if ElapsedTime >= NextRoamEvent[0]:
            (timer, Clientname, Location, TheBSSID, RoamTime) = NextRoamEvent
            FlowNameUp   = "F_%s-->%s" % ( Clientname, EthClientName)
            FlowNameDown = "F_%s-->%s" % ( EthClientName, Clientname)
            InsertTimelogMessage("Starting roam event: %s -> %s" % (Clientname, Location) )
            _sMessage = " %s -> %s\n" % (Clientname, Location)
            OutputstreamHDL(_sMessage, MSG_OK)
            UpdateFunction(_sMessage, ElapsedTime, Transmitting_Flag, PassedParameters)

            VCLtest("clientStats.read('%s')" % (Clientname))
            roam_delay = (clientStats.rxMcStartTime - clientStats.txMcStartTime) / 1000000.0

            VCLtest("mc.setActiveBssid('%s', '%s', '%s')" % (Clientname, Location, TheBSSID))
            ElapsedTime = time.clock() - Test_StartTime
            VCLtest("flowStats.read('%s', '%s')" % (Location, FlowNameDown))
            ActiveRoamClient.append( (Location, FlowNameDown, flowStats.rxFlowFramesOk,
                time.clock(), RoamEventIndex, ElapsedTime, Clientname) )

            PrintStatsLine(ListOfCards, True, ElapsedTime, Transmitting_Flag)
            RoamEventIndex += 1
            if RoamEventIndex >= len(RoamingSchedule):
                NextRoamEvent = (TXtime + RXtime + 2, 'Null', 'Null', 'Null', 0 )
            else:
                NextRoamEvent = RoamingSchedule[RoamEventIndex]

            if (roam_delay > 0) and (roam_delay < 500000):
                roam_delay_list.append(roam_delay)
            else:
                roam_delay_list.append("NR")
                OutputstreamHDL("Warning: Invalid roam delay reported", MSG_OK)

            roam_delay_client_name.append(Clientname)

        if len(ActiveRoamClient) > 0:
            TempActiveRoamClient = []
            for (PortName, FlowName, rxCount, startTime, EventIndex, Elasped, ClientName) in ActiveRoamClient:
                VCLtest("flowStats.read('%s', '%s')" % (PortName, FlowName))
                if flowStats.rxFlowFramesOk != rxCount:
                    (timer, Clientname, Location, TheBSSID, RoamTime) = RoamingSchedule[EventIndex]
                    RoamTime = time.clock() - startTime
                    RoamingSchedule[EventIndex] = (Elasped, Clientname, Location, TheBSSID, RoamTime)
                else:
                    TempActiveRoamClient.append( (PortName, FlowName, rxCount, startTime, EventIndex, Elasped, ClientName) )
            ActiveRoamClient = TempActiveRoamClient[:]
        elif NextRoamEvent[0] - ElapsedTime > 0.350:
            if time.clock() >Test_UpdateTime:
                PrintStatsLine(ListOfCards, False, ElapsedTime, Transmitting_Flag)
                Test_UpdateTime = time.clock() + UpdateTime
                UpdateFunction(_sMessage, ElapsedTime, Transmitting_Flag, PassedParameters)
    _sMessage += "\n"
    UpdateFunction(_sMessage, ElapsedTime, Transmitting_Flag, PassedParameters)
    if len(ActiveRoamClient) > 0:
        InsertTimelogMessage("ActiveRoamClient=%s" % (ActiveRoamClient) )
        for (PortName, FlowName, rxCount, startTime, EventIndex, Elasped, ClientName) in ActiveRoamClient:
            OutputstreamHDL("Error: %s did not see RX pkts increment after %.3f secs (Index=%d)\n" % (ClientName, Elasped, EventIndex), MSG_ERROR)
        return (False, roam_delay_client_name, roam_delay_list)
    return (True, roam_delay_client_name, roam_delay_list)

##################################### BinarySerach ###################################
# Handles the binary search alogrithm
# After creating the object, you set the search range my the minimum and maximum methods.
# The search will end when the desired resolution is meet.  Resolution is defined in only
# one of two methods:
#   resolutionPercent -  The +/- percentage of the final search number (0.0 < value <= 100.0)
#   resolutionAbsolute - When the difference between pass and fail are less than an number 
# Setting the min & max values thru the setMinMaxVal() will cause the search logic
# to start from the lower bound instead of upper bound.
class BinarySerach:
    LastValue   = 0
    NextValue   = 0
    minimum     = 0
    maximum     = 0
    _resolutionPercent   = None
    _resolutionAbsolute  = None
    neverpassed = True
    neverrunned = True
    def setMinMaxVal(self, minVal, maxVal):
        self.minimum = minVal
        self.maximum = maxVal
        self.NextValue = minVal        
        self.neverpassed = True
        self.neverrunned = True  
    def minimum(self, value):
        self.minimum = value
        self.neverpassed = True
        self.neverrunned = True
    def maximum(self, value):
        self.maximum = value
        self.NextValue = value
        self.neverpassed = True
        self.neverrunned = True
    def resolutionPercent(self, value):
        self._resolutionPercent  = float(value) / 100.0 
        if self._resolutionPercent <= 0.0:
            self._resolutionPercent = 0.00001
        if self._resolutionPercent > 1.0:
            self._resolutionPercent = 1.0
        self._resolutionAbsolute = None
        self.neverpassed = True
        self.neverrunned = True
    def resolutionAbsolute(self, value):
        self._resolutionPercent  = None
        self._resolutionAbsolute = value
        if self._resolutionAbsolute < 1:
            self._resolutionAbsolute = 1
        self.neverpassed = True
        self.neverrunned = True
    def resolution(self, value):
        # Old method keep for backwards compatability
        self._resolutionPercent  = None
        self._resolutionAbsolute = value
        self.neverpassed = True
        self.neverrunned = True
    def PASS(self):
        self.LastValue = self.NextValue
        self.minimum   = self.NextValue
        self.NextValue = self.minimum + ( self.maximum - self.minimum ) / 2.0
        self.neverpassed = False
        self.neverrunned = False
    def FAIL(self):
        self.LastValue = self.NextValue
        self.maximum   = self.NextValue
        self.NextValue = self.minimum + ( self.maximum - self.minimum ) / 2.0
        self.neverrunned = False
    def query(self):
        if self.minimum > self.maximum:
            self.minimum = self.maximum
        return self.NextValue
    def searching(self):
        #if they swapped the numbers, correct it
        if self.minimum > self.maximum:
            _temp        = self.minimum 
            self.minimum = self.maximum
            self.maximum = _temp
        #print self.LastValue, self.NextValue, self.minimum, self.maximum, 
        if self.neverrunned:
            return self.neverrunned

        if self._resolutionAbsolute == None:
            if self.LastValue > 0.0:
                _percentDetla = abs(self.LastValue - self.NextValue) / self.LastValue
            else:
                return True
            if self._resolutionPercent >= _percentDetla:
                return False
            else:
                return True
            
        if self._resolutionPercent == None:
            if self._resolutionAbsolute >= self.maximum - self.minimum :
                return False
            else:
                return True

        # If I get here, someone screwed up and I am going to just quit
        return False
            
    def neverpassed(self):
        if self.neverpassed:
            return True
        else:
            return False 
   
##################################### Sleep ###################################
# We want to sleep the process until some future time
#
def Sleep(TimeinSeconds, sMessage= ''):
    DoneTime = time.time() + TimeinSeconds
    while DoneTime > time.time():
        time.sleep(0.250)
        TimeLeft = DoneTime - time.time()
        if TimeLeft < 0.0:
            TimeLeft = 0.0
        OutputstreamHDL( "\r%s waiting %.1f seconds" % (sMessage, TimeLeft), MSG_OK)
    OutputstreamHDL( "\n", MSG_OK)
    
##################################### MeasurePort_OfferredLoad ###################################
# Returns the offered load based on TX port counts
#
def MeasurePort_OfferredLoad(ListofPorts, TestDuration):
    TotalTX = 0
    WriteDetailedLog(['Port Name', 'txMacFrames', 'txMacAck'])
    for Portname in ListofPorts:
        VCLtest("stats.read('%s')" % (Portname))
        TotalTX += ( stats.txMacFrames - stats.txMacAck)
        WriteDetailedLog([Portname, stats.txMacFrames, stats.txMacAck])
    if TotalTX == 0:
        OutputstreamHDL("\nWarning: No frames were transmitted; Offerred Load is zero.\n", MSG_WARNING)
    return ( TotalTX / float(TestDuration) )

##################################### MeasurePort_ForwardingRate ###################################
# Returns the offered load based on RX port counts
#
def MeasurePort_ForwardingRate(ListofPorts, TestDuration):
    TotalRX = 0
    WriteDetailedLog(['Port Name', 'rxMacFrames', 'rxMacAck', 'rxMacBeacon'])
    for Portname in ListofPorts:
        VCLtest("stats.read('%s')" % (Portname))
        TotalRX += ( stats.rxMacFrames - stats.rxMacAck - stats.rxMacBeacon )
        WriteDetailedLog([Portname, stats.rxMacFrames, stats.rxMacAck, stats.rxMacBeacon])
    if TotalRX == 0:
        OutputstreamHDL("\nWarning: No frames were receievd; Forwarding Rate is zero.\n", MSG_WARNING)
    return ( TotalRX / float(TestDuration) )

##################################### MeasurePort_OLOAD_FR_LOSSRate ###################################
# Returns the offered load, Forwarding rate, and frame loss as a tuple
# This is quicker than getting each metric separately
#
def MeasurePort_OLOAD_FR_LOSSRate(ListofPorts, TestDuration, PktType='IP',
                                  FrameSize = 0):
    """
    
    When FrameSize is passed by the caller, we give the octet count as the
    FrameSize * Frames, otherwise we take the octets value from the counter.
    
    """
    TotalTXframes = 0
    TotalRXframes = 0
    TotalTXoctets = 0
    TotalRXoctets = 0
    WriteDetailedLog(['Port Name', "tx%sFramesOk" % (PktType), "txIPOctetsOk", 
                      "rx%sFramesOk" % (PktType), "rxIPOctetsOk", 'Loss'])
    for Portname in ListofPorts:
        VCLtest("stats.read('%s')" % (Portname))
        if PktType == 'TCP':
            TotalTXframes += stats.txTcpFramesOk 
            TotalRXframes += stats.rxTcpPacketsOk
            TotalTXoctets += stats.txIpOctetsOk 
            TotalRXoctets += stats.rxIpOctetsOk
            
            txFramesOk = stats.txTcpFramesOk
            rxFramesOk = stats.rxTcpPacketsOk         
        elif PktType == 'UDP':
            TotalTXframes += stats.txUdpFramesOk 
            TotalRXframes += stats.rxUdpPacketsOk
            TotalTXoctets += stats.txIpOctetsOk 
            TotalRXoctets += stats.rxIpOctetsOk
            
            txFramesOk = stats.txUdpFramesOk
            rxFramesOk = stats.rxUdpPacketsOk         
        else:
            TotalTXframes += stats.txIpPacketsOk 
            TotalRXframes += stats.rxIpPacketsOk
            TotalTXoctets += stats.txIpOctetsOk 
            TotalRXoctets += stats.rxIpOctetsOk
            
            txFramesOk = stats.txUdpFramesOk
            rxFramesOk = stats.rxUdpPacketsOk         
        
        txIPOctetsOk = stats.txIpOctetsOk 
        rxIPOctetsOk = stats.rxIpOctetsOk
        
        WriteDetailedLog([Portname, 
                          txFramesOk, txIPOctetsOk, 
                          rxFramesOk, rxIPOctetsOk])
    if TotalTXframes > 0:
        FrameLossRate = 100.0 * (TotalTXframes - TotalRXframes) / TotalTXframes
    else:
        FrameLossRate = 0.0
        OutputstreamHDL("\nWarning: No frames were transmitted; FrameLoss Rate is invalid.\n", MSG_WARNING)
    if TotalRXframes == 0:
        OutputstreamHDL("\nWarning: No frames were received; Forwarding Rate is zero.\n", MSG_WARNING)
    if FrameSize:
        OLOAD     = TotalTXframes / float(TestDuration)
        OLOAD_bps = 8 * FrameSize * TotalTXframes / float(TestDuration)
        FR        = TotalRXframes / float(TestDuration)
        FR_bps    = 8 * FrameSize * TotalRXframes / float(TestDuration)
        WriteDetailedLog(['Totals', 
                          TotalTXframes, (FrameSize * TotalTXframes), 
                          TotalRXframes, (FrameSize * TotalRXframes), 
                          TotalTXframes - TotalRXframes])

    else:
        OLOAD     = TotalTXframes / float(TestDuration)
        OLOAD_bps = 8 * TotalTXoctets / float(TestDuration)
        FR        = TotalRXframes / float(TestDuration)
        FR_bps    = 8 * TotalRXoctets / float(TestDuration)
        WriteDetailedLog(['Totals', 
                          TotalTXframes, TotalTXoctets, 
                          TotalRXframes, TotalRXoctets, 
                          TotalTXframes - TotalRXframes])
    
    return (OLOAD, OLOAD_bps, FR, FR_bps, FrameLossRate )
##################################### MeasurePort_Latency ###################################
# Returns the (min, MAX, avg) latency based on a list of ports
#
def MeasurePort_Latency(ListofPorts, TestDuration):
    latencyMin = MAXlatency
    latencyMax = 0.0
    latencyAvg = 0.0
    TotalRX    = 0
    WriteDetailedLog(['Port Name', "minimum Latency Overall", "maximum Latency Overall", "average Latency Overall", 'rxSignature'])
    for Portname in ListofPorts:
        VCLtest("stats.setDefaults()")
        VCLtest("stats.read('%s')" % (Portname))
        # VPR - Different name for the same counter
        if GetCachePortInfo(Portname) == '8023':
            rxSignature = stats.rxSignatureValid
        else:
            rxSignature = stats.rxSignatureValidFrames
        # VCL returns uS
        if stats.minimumLatencyOverall < latencyMin:
            latencyMin = stats.minimumLatencyOverall
        if stats.maximumLatencyOverall > latencyMax:
            latencyMax = stats.maximumLatencyOverall
        if rxSignature == 0:
            OutputstreamHDL("Warning: Port %s did not receive any valid VeriWave frames; latency numbers may be invalid.\n" % (Portname), MSG_WARNING)
        latencyAvg += rxSignature * stats.averageLatencyOverall
        TotalRX    += rxSignature
        WriteDetailedLog([Portname, stats.minimumLatencyOverall, stats.maximumLatencyOverall, stats.averageLatencyOverall, rxSignature])
    latencyMin = latencyMin / 1000000.0
    latencyMax = latencyMax / 1000000.0
    if TotalRX > 0:
        latencyAvg = latencyAvg / (TotalRX * 1000000.0)
    else:        
        latencyAvg = 0.0
    #Convert TGA's nanosecond into seconds
    return (latencyMin, latencyMax, latencyAvg)

##################################### MeasureFlow_OfferredLoad ###################################
# Returns the offered load based on a list of flows
#
def MeasureFlow_OfferredLoad(ListofFlows, TestDuration):
    TotalTX = 0
    for Flowname in ListofFlows.keys():
        (src_port, src_client, des_port, des_client) = ListofFlows[Flowname]
        VCLtest("flowStats.read('%s','%s')" % (src_port, Flowname))
        TotalTX += flowStats.txFlowFramesOk 
    if TotalTX == 0:
        OutputstreamHDL("\nWarning: No frames were transmitted; Offerred Load is zero.\n", MSG_WARNING)
    return TotalTX / float(TestDuration)

##################################### MeasureFlow_ForwardingRate ###################################
# Returns the forwarding rate based on a list of flows
#
def MeasureFlow_ForwardingRate(ListofFlows, TestDuration):
    TotalRX = 0
    for Flowname in ListofFlows.keys():
        (src_port, src_client, des_port, des_client) = ListofFlows[Flowname]
        VCLtest("flowStats.read('%s','%s')" % (des_port, Flowname))
        TotalRX += flowStats.rxFlowFramesOk 
    if TotalRX == 0:
        OutputstreamHDL("\nWarning: No frames were receievd; Forwarding Rate is zero.\n", MSG_WARNING)
    return TotalRX / float(TestDuration)

##################################### MeasureFlow_FrameLoss ###################################
# Returns the frame loss based on a list of flows
#
def MeasureFlow_FrameLoss(ListofFlows, TestDuration):
    TotalTX = 0
    TotalRX = 0
    for Flowname in ListofFlows.keys():
        (src_port, src_client, des_port, des_client) = ListofFlows[Flowname]
        VCLtest("flowStats.read('%s','%s')" % (src_port, Flowname))
        TotalTX += flowStats.txFlowFramesOk 
        VCLtest("flowStats.read('%s','%s')" % (des_port, Flowname))
        TotalRX += flowStats.rxFlowFramesOk 
    if TotalTX == 0:
        OutputstreamHDL("\nWarning: No frames were transmitted; Frame Loss measurement is invalid.\n", MSG_WARNING)
    if TotalRX == 0:
        OutputstreamHDL("\nWarning: No frames were receievd; Frame Loss will be very high.\n", MSG_WARNING)
    return TotalTX - TotalRX

##################################### MeasureFlow_FrameLossRate ###################################
# Returns the frame loss rate based on a list of flows
#
def MeasureFlow_FrameLossRate(ListofFlows, TestDuration):
    TotalTX = 0
    TotalRX = 0
    for Flowname in ListofFlows.keys():
        (src_port, src_client, des_port, des_client) = ListofFlows[Flowname]
        VCLtest("flowStats.read('%s','%s')" % (src_port, Flowname))
        TotalTX += flowStats.txFlowFramesOk 
        VCLtest("flowStats.read('%s','%s')" % (des_port, Flowname))
        TotalRX += flowStats.rxFlowFramesOk 
    if TotalTX > 0:
        FrameLossRate = 100.0 * (TotalTX - TotalRX) / TotalTX
    else:
        FrameLossRate = 0
        OutputstreamHDL("\nWarning: No frames were transmitted; Frame Loss Rate is invalid.\n", MSG_WARNING)
    if TotalRX == 0:
        OutputstreamHDL("\nWarning: No frames were receievd; Frame Loss Rate will be 100%%.\n", MSG_WARNING)
    return FrameLossRate

#################################### MeasureFlow_OLOAD_FR_LossRate ##################################
# Returns the offered load (and bps), Forwarding rate (and bps) , and frame loss as a tuple
# It is quicker to get 5 metrics together than separately
#
def MeasureFlow_OLOAD_FR_LossRate(ListofFlows, TestDuration, FrameSize = 0):
    """
    
    When FrameSize is passed by the caller, we give the octet count as the
    FrameSize * Frames, otherwise we take the octets value from the counter.
    
    """
    TotalTXframes = 0
    TotalRXframes = 0
    TotalTXoctets = 0
    TotalRXoctets = 0
    TotalOutOfSequence = 0
    WriteDetailedLog(['Flow Name', 'src_port', 'src_client', 'des_port', 
                      'des_client', 'txFlowFramesOk', 'txFlowOctetsOk', 
                      'rxFlowFramesOk', 'rxFlowOctetsOk', 'OutOfSequence', 
                      'Loss'])
    for Flowname in ListofFlows.keys():
        (src_port, src_client, des_port, des_client) = ListofFlows[Flowname]
        VCLtest("flowStats.read('%s','%s')" % (src_port, Flowname))
        TotalTXframes += VCLtest("flowStats.txFlowFramesOk")
        TXframes       = VCLtest("flowStats.txFlowFramesOk")
        TotalTXoctets += VCLtest("flowStats.txFlowOctetsOk") 
        TXoctets       = VCLtest("flowStats.txFlowOctetsOk")
        VCLtest("flowStats.read('%s','%s')" % (des_port, Flowname))
        TotalRXframes += VCLtest("flowStats.rxFlowFramesOk")
        TotalRXoctets += VCLtest("flowStats.rxFlowOctetsOk")
        TotalOutOfSequence += flowStats.rxFlowOutOfSequenceFrames
        if FrameSize:
            txFlowOctetsOk = (FrameSize * TXframes)
            rxFlowOctetsOk = (FrameSize * flowStats.rxFlowFramesOk)
        else:
            txFlowOctetsOk = TXoctets
            rxFlowOctetsOk = flowStats.rxFlowOctetsOk
            
        WriteDetailedLog([Flowname, src_port, src_client, des_port, des_client, 
                          TXframes, txFlowOctetsOk, 
                          flowStats.rxFlowFramesOk, rxFlowOctetsOk, 
                          flowStats.rxFlowOutOfSequenceFrames ,
                          TXframes - flowStats.rxFlowFramesOk])
    if TotalTXframes > 0:
        FrameLossRate = 100.0 * (TotalTXframes - TotalRXframes) / TotalTXframes
    else:
        FrameLossRate = 0.0
        OutputstreamHDL("\nWarning: No frames were transmitted; Frame Loss Rate is invalid.\n", MSG_WARNING)
    if TotalRXframes == 0:
        OutputstreamHDL("\nWarning: No frames were received; Forwarding Rate is zero.\n", MSG_WARNING)
    
    if FrameSize:
        #bits per second should be derived from frame rate, not the octet counters
        OLOAD        = TotalTXframes / float(TestDuration)
        OLOAD_bps    = 8 * FrameSize * TotalTXframes / float(TestDuration)
        FR           = TotalRXframes / float(TestDuration)
        FR_bps       = 8 * FrameSize * TotalRXframes / float(TestDuration)
        
        TotalTXoctets = (FrameSize * TotalTXframes)
        TotalRXoctets = (FrameSize * TotalRXframes)

    else:
        OLOAD     = TotalTXframes / float(TestDuration) 
        OLOAD_bps = 8 * TotalTXoctets / float(TestDuration) 
        FR        = TotalRXframes / float(TestDuration)
        FR_bps    = 8 * TotalRXoctets / float(TestDuration) 
        
    WriteDetailedLog(['Totals', '', '', '', '', 
                      TotalTXframes, TotalTXoctets,
                      TotalRXframes, TotalRXoctets, 
                      TotalOutOfSequence, 
                      TotalTXframes - TotalRXframes])

    return (OLOAD, OLOAD_bps, FR, FR_bps, FrameLossRate)

#################################### MeasureFlow_Statistics ##################################
# Returns a dictionary of everytime we can determine from the flow/port counters
#
def MeasureFlow_Statistics(ListofFlows, TestDuration, FrameSize = 0):
    """
    
    When FrameSize is passed by the caller, we give the octet count as the
    FrameSize * Frames, otherwise we take the octets value from the counter.
    
    """
    TotalTXframes = 0
    TotalRXframes = 0
    TotalTXoctets = 0
    TotalRXoctets = 0
    TotalOutOfSequence = 0
    jitterMin = 4294967295
    jitterMax = 0.0
    jitterAvg = 0.0
    ListofPorts   = []
    ListofRxPorts = []
    WriteDetailedLog(['Flow Name', 'src_port', 'src_client', 'des_port', 
                      'des_client', 'txFlowFramesOk', 'txFlowOctetsOk', 
                      'rxFlowFramesOk', 'rxFlowOctetsOk', 'OutOfSequence', 
                      'Loss', 'RxFlowSmoothedInterarrivalJitter'])
    for Flowname in ListofFlows.keys():
        (src_port, src_client, des_port, des_client) = ListofFlows[Flowname]
        if src_port not in ListofPorts:
            ListofPorts.append(src_port)
        if des_port not in ListofPorts:
            ListofPorts.append(des_port)
        if des_port not in ListofRxPorts:
            ListofRxPorts.append(des_port)

        VCLtest("flowStats.read('%s','%s')" % (src_port, Flowname))
        TotalTXframes += VCLtest("flowStats.txFlowFramesOk")
        TXframes       = VCLtest("flowStats.txFlowFramesOk")
        TotalTXoctets += VCLtest("flowStats.txFlowOctetsOk") 
        TXoctets       = VCLtest("flowStats.txFlowOctetsOk")
        VCLtest("flowStats.read('%s','%s')" % (des_port, Flowname))
        TotalRXframes += VCLtest("flowStats.rxFlowFramesOk")
        TotalRXoctets += VCLtest("flowStats.rxFlowOctetsOk")
        TotalOutOfSequence += flowStats.rxFlowOutOfSequenceFrames
        jitter = flowStats.getRxFlowSmoothedInterarrivalJitter()
        if FrameSize:
            txFlowOctetsOk = (FrameSize * TXframes)
            rxFlowOctetsOk = (FrameSize * flowStats.rxFlowFramesOk)
        else:
            txFlowOctetsOk = TXoctets
            rxFlowOctetsOk = flowStats.rxFlowOctetsOk
            
        WriteDetailedLog([Flowname, src_port, src_client, des_port, des_client, 
                          TXframes, txFlowOctetsOk, 
                          flowStats.rxFlowFramesOk, rxFlowOctetsOk, 
                          flowStats.rxFlowOutOfSequenceFrames ,
                          TXframes - flowStats.rxFlowFramesOk, jitter])
        if jitter < jitterMin:
            jitterMin = jitter
        if jitter > jitterMax:
            jitterMax = jitter
        jitterAvg =  jitterAvg + jitter
        
    if TotalTXframes > 0:
        FrameLossRate = 100.0 * (TotalTXframes - TotalRXframes) / TotalTXframes
    else:
        FrameLossRate = 0.0
        OutputstreamHDL("\nWarning: No frames were transmitted; Frame Loss Rate is invalid.\n", MSG_WARNING)
    if TotalRXframes == 0:
        OutputstreamHDL("\nWarning: No frames were received; Forwarding Rate is zero.\n", MSG_WARNING)
    
    OLOAD     = TotalTXframes / float(TestDuration)
    FR        = TotalRXframes / float(TestDuration)
    jitterAvg = jitterAvg/len(ListofFlows) 
    if FrameSize:
        #bits per second should be derived from frame rate, not the octet counters
        OLOAD_bps    = 8 * FrameSize * TotalTXframes / float(TestDuration)
        FR_bps       = 8 * FrameSize * TotalRXframes / float(TestDuration)
        TotalTXoctets = (FrameSize * TotalTXframes)
        TotalRXoctets = (FrameSize * TotalRXframes)
    else:
        OLOAD_bps = 8 * TotalTXoctets / float(TestDuration) 
        FR_bps    = 8 * TotalRXoctets / float(TestDuration) 
        
    WriteDetailedLog(['Totals', '', '', '', '', 
                      TotalTXframes, TotalTXoctets,
                      TotalRXframes, TotalRXoctets, 
                      TotalOutOfSequence, 
                      TotalTXframes - TotalRXframes, jitterAvg])
    
    #Now measure the latency
    latencyMin = MAXlatency
    latencyMax = 0.0
    latencyAvg = 0.0
    TotalRX    = 0
    WriteDetailedLog(['Port Name', "minimum Latency Overall", "maximum Latency Overall", "average Latency Overall", \
                      'txSignature', 'txRetransmission', 'txACKerror', 'rxSignature', 'rxFCSerror', 'rxACKerror'])
    ListofPorts.sort()
    for Portname in ListofPorts:
        VCLtest("stats.setDefaults()")
        VCLtest("stats.read('%s')" % (Portname))
        # VPR - Different name for the same counter
        if GetCachePortInfo(Portname) == '8023':
            txSignature = stats.getTxSignatureValid()
            txRetransmission = stats.txCollisions
            txACKerror  = ''
            rxSignature = stats.rxSignatureValid
            rxFCSerror  = stats.rxFragmentFrames
            rxACKerror  = ''
        else:
            txSignature = stats.getTxSignatureValidFrames()
            txRetransmission= stats.txMacTotalRetransmissions
            txACKerror  = stats.getTxMacAckFailureCount()
            rxSignature = stats.rxSignatureValidFrames
            rxFCSerror  = stats.rxMacFcsError
            rxACKerror  = stats.rxMacAckError
        # VCL returns uS
        if stats.minimumLatencyOverall < latencyMin and stats.minimumLatencyOverall > 0:
            latencyMin = stats.minimumLatencyOverall
        if stats.maximumLatencyOverall > latencyMax:
            latencyMax = stats.maximumLatencyOverall
        if rxSignature == 0 and Portname in ListofRxPorts:
            OutputstreamHDL("Warning: Port %s did not receive any valid VeriWave frames; latency numbers may be invalid.\n" % (Portname), MSG_WARNING)
        latencyAvg += rxSignature * stats.averageLatencyOverall
        TotalRX    += rxSignature
        WriteDetailedLog([Portname, stats.minimumLatencyOverall, stats.maximumLatencyOverall, stats.averageLatencyOverall, \
                         txSignature, txRetransmission, txACKerror, rxSignature, rxFCSerror, rxACKerror])
    if TotalRX > 0:
        latencyAvg = latencyAvg / (TotalRX * 1000000.0)
    else:        
        latencyAvg = 0.0
    WriteDetailedLog(['',])
    
    ReturnDict = { 'OLOAD'          : OLOAD,
                   'OLOAD bps'      : OLOAD_bps,
                   'FR'             : FR,
                   'FR bps'         : FR_bps,
                   'FrameLossRate'  : FrameLossRate,
                   'Min Latency'    : latencyMin /   1000000.0, 
                   'Max Latency'    : latencyMax /   1000000.0,
                   'Avg Latency'    : latencyAvg,
                   'Min Jitter'     : jitterMin / 1000000000.0, 
                   'Max Jitter'     : jitterMax / 1000000000.0,
                   'Avg Jitter'     : jitterAvg / 1000000000.0,
                 }

    return ReturnDict

##################################### MeasureFlow_LatencyHistogram ###################################
# Returns the sum of all the flows Latency Histogram counts
#
def MeasureFlow_LatencyHistogram(ListofFlows, TestDuration):
    TotalBuckets = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    TotalRX = 0
    WriteDetailedLog(['Port Name', 'Flow Name', 'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B9', 'B10', 'B11', 'B12', 'B13', 'B14', 'B15', 'B16'])
    for Flowname in ListofFlows.keys():
        (src_port, src_client, des_port, des_client) = ListofFlows[Flowname]
        _Detailed = [ des_port, Flowname ]
        VCLtest("flowStats.read('%s','%s')" % (des_port, Flowname))
        for x in range( 16 ):
            TotalBuckets[x] += int(flowStats.getRxFlowLatencyBucket(x))
            _Detailed.append(int(flowStats.getRxFlowLatencyBucket(x)))
        WriteDetailedLog(_Detailed)
    return TotalBuckets

##################################### MeasureFlow_Jitter ###################################
# Returns the sum of all the flows Latency Histogram counts
#
def MeasureFlow_Jitter(ListofFlows, BucketValues):
    if BucketValues == None:
        return 0.0
    TotalCount = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    TotalRX = 0
    TextList = ['Port Name', 'Flow Name']
    for eachValue in BucketValues:
        TextList.append("%ss" % (Float2EngNotation(float(eachValue) / 1000000.0, 4)))
    WriteDetailedLog(TextList)
    for Flowname in ListofFlows.keys():
        (src_port, src_client, des_port, des_client) = ListofFlows[Flowname]
        _Detailed = [ des_port, Flowname ]
        VCLtest("flowStats.read('%s','%s')" % (des_port, Flowname))
        for x in range( 16 ):
            TotalCount[x] += int(flowStats.getRxFlowLatencyBucket(x))
            _Detailed.append(int(flowStats.getRxFlowLatencyBucket(x)))
        WriteDetailedLog(_Detailed)
        
    #Now Compute the Average
    Midpoint  = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    Weighting = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    Variance  = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    SumofWeighting = 0.0
    SumOfCount     = 0
    SumofVariance  = 0.0
    for x in range( 16 ):
        Midpoint[x] = BucketValues[x]
        if x > 0:
            Midpoint[x] += (BucketValues[x] - BucketValues[x-1]) / 2.0
        Weighting[x]     = Midpoint[x] * TotalCount[x]
        SumofWeighting  += Weighting[x]
        SumOfCount      += TotalCount[x]
    AverageDelay = SumofWeighting / SumOfCount

    #Then the jitter
    for x in range( 16 ):
        Variance[x] = (AverageDelay - Midpoint[x]) * (AverageDelay - Midpoint[x]) * TotalCount[x]
        SumofVariance += Variance[x]
    jitter = sqrt(SumofVariance/ float(SumOfCount-1)) / 1000000.0
    return jitter 

##################################### MeasureFlow_Jitter ###################################
# Prints the smoothed interarrival jitter(microsec) for each flow to the detailed csv
# Prints and returns the min, max & avg jitters from all flows
#
def MeasureFlow_Jitter(ListofFlows):
    jitterMin = 4294967295
    jitterMax = 0.0
    jitterAvg = 0.0        
    
    WriteDetailedLog(['Port Name', 'Flow Name', 'Smoothed Interarrival Jitter(us)'])
    for Flowname in ListofFlows.keys():
        (src_port, src_client, des_port, des_client) = ListofFlows[Flowname] 
        VCLtest("flowStats.read('%s','%s')" % (des_port, Flowname))  
        jitter = flowStats.getRxFlowSmoothedInterarrivalJitter() / 1000.0
        WriteDetailedLog([des_port, Flowname, jitter])
        if jitter < jitterMin:
            jitterMin = jitter
        if jitter > jitterMax:
            jitterMax = jitter
        jitterAvg =  jitterAvg + jitter
    jitterAvg = jitterAvg/len(ListofFlows) 
    WriteDetailedLog(['Min Jitter', 'Max Jitter', 'Avg Jitter'])
    WriteDetailedLog([jitterMin, jitterMax, jitterAvg])
    return(jitterMin, jitterMax, jitterAvg)  

##################################### RecordAllPortCounters ###################################
# Puts all the port counters into the Detailed file
# Does not return anything
#
def RecordAllPortCounters(ListofPorts, TestDuration=0):
    ListOfRateCounters  = []
    ListOfEventCounters = []
    #Get all the names of the counters
    for eachCounter in dir(stats):
        if eachCounter[:3] == 'get':
            code = 'ReturnValue = stats.' + eachCounter + '()'
            try:
                exec code
            except:
                continue
            if eachCounter[-4:] == 'Rate':
                ListOfRateCounters.append(eachCounter[3:])
            else:
                ListOfEventCounters.append(eachCounter[3:])

    EventHeaderList = ['Port Name'] + ListOfEventCounters
    WriteDetailedLog(EventHeaderList)
#    RateDict = {}
    for Portname in ListofPorts:
        EventStatsList = [ Portname, ]
        VCLtest("stats.read('%s')" % (Portname))
        for eachCounter in ListOfEventCounters:
            code = 'ReturnValue = stats.get' + eachCounter + '()'
            try:
                exec code
            except:
                ReturnValue = 'ERROR'
            EventStatsList.append(ReturnValue)
        WriteDetailedLog(EventStatsList)

#        RateStatsList = [ Portname, ]
#        for eachCounter in ListOfRateCounters:
#            code = 'ReturnValue = stats.get' + eachCounter + '()'
#            try:
#                exec code
#            except:
#                ReturnValue = 'ERROR'
#            RateStatsList.append(ReturnValue)
#        RateDict[Portname] = RateStatsList

#    RateHeaderList = ['Port Name']  + ListOfRateCounters
#    WriteDetailedLog(RateHeaderList)
#    for Portname in ListofPorts:
#        WriteDetailedLog(RateDict[Portname])
    return 

##################################### WriteDetailedLog ###################################
# Writes a list of fields to the Detailed lof file, if enabled
#
def WriteDetailedLog(pList):
    global _Detailed_Fhdl
    if _Detailed_Fhdl != -1:
        First = True
        for CurrentObject in pList:
            if First:
                _Detailed_Fhdl.write("%s" % (CurrentObject))
                First = False
            else:
                _Detailed_Fhdl.write(", %s" % (CurrentObject))
        _Detailed_Fhdl.write("\n")
        _Detailed_Fhdl.flush()
    return
##################################### WriteDetailedLog ###################################
# Writes a list of fields to the RSSI csv file, 
def WriteRSSIdetails(bssidList):
    global _RSSI_FileName
    _Fhdl = None
    try:
        _Fhdl = open(_RSSI_FileName, 'a')
        for eachLine in bssidList:
            _Fhdl.write("%s, %s, %d, %s, %s, %d\n" % \
                        (time.asctime(), eachLine[0], eachLine[1], 
                         eachLine[2], eachLine[3], eachLine[4]))
        _Fhdl.close()
    except:
        if _Fhdl:
            _Fhdl.close()

    return

##################################### CreateCSVFile ###################################
# Creates a CSV file and writes a list of tuples in the columns      
#
def CreateCSVFile(Filename, Results):
    try:
        _Fhdl = open(Filename, 'w')
    except:
        OutputstreamHDL("Warning: Could not open %s for writing.  Results can not be saved.\n" % (Filename), MSG_WARNING)
        return
    
    for CurrentLine in Results:
        First = True
        for CurrentObject in CurrentLine:
            if First:
                _Fhdl.write("%s" % (str(CurrentObject)))
                First = False
            else:
                _Fhdl.write(", %s" % (str(CurrentObject)))
        _Fhdl.write("\n")
    _Fhdl.close()

##################################### ConfigurationCSVFile ###################################
# This will read the attributes from an object and attempt to write them into a CSV file      
#
def ConfigurationCSVFile(Filename, TestObject):
    try:
        _Fhdl = open(Filename, 'w')
    except:
        OutputstreamHDL("Warning: Could not open %s for writing.  Results can not be saved.\n" % (Filename), MSG_WARNING)
        return

    for eachParam in dir(TestObject):
        if eachParam[0] == '_' or eachParam == 'this' or eachParam == 'thisown':
            continue
        object = eval("TestObject.%s" % (eachParam))
        if type(object) is types.MethodType:
            continue
        if type(object) is types.ClassType:
            continue
         
        if type(object) is types.NoneType:
            _Fhdl.write("%s, None\n" % (eachParam) )
            continue
        if type(object) is types.FloatType:
            _Fhdl.write("%s, %f\n" % (eachParam, object) )
            continue
        if type(object) is types.IntType:
            _Fhdl.write("%s, %d\n" % (eachParam, object) )
            continue
        if type(object) is types.StringType:
            _Fhdl.write("%s, '%s'\n" % (eachParam, object) )
            continue
        if type(object) is types.BooleanType :
            _Fhdl.write("%s, %s\n" % (eachParam, object) )
            continue
        if type(object) is types.ListType:
            n = 1
            for eachKey in object:
                if n == 1:
                    _Fhdl.write("%s, %s\n" % (eachParam, eachKey) )
                else:    
                    _Fhdl.write("%s, %s\n" % ('', eachKey) )
                n += 1
            continue
        if type(object) is types.DictType:
            n = 1
            for eachKey in object.keys():
                if n == 1:
                    _Fhdl.write("%s, %s, %s\n" % (eachParam, eachKey, object[eachKey]) )
                else:    
                    _Fhdl.write(", %s, %s\n" % (eachKey, object[eachKey]) )
                n += 1
            continue
        if type(object) is types.FunctionType:
            _Fhdl.write("%s, %s()\n" % (eachParam, object.func_name) )
            continue 
        if type(object) is OrderedDict:
            n = 1
            for eachKey in object.keys():
                if n == 1:
                    _Fhdl.write("%s, %d, %s, %s\n" % (eachParam, n, eachKey, object[eachKey]) )
                else:    
                    _Fhdl.write(", %d, %s, %s\n" % (n, eachKey, object[eachKey]) )
                n += 1
            continue 
        OutputstreamHDL("Warning: Parameter %s with type %s not saved in configuration file.\n" % (eachParam, type(object)), MSG_WARNING)
    _Fhdl.close()

##################################### ReadCSVFile ###################################
# Read a file and returns a list of tuples in the columns      
#
def ReadCSVFile(Filename):
    results = []
    try:
        _Fhdl = open(Filename, 'r')
    except:
        OutputstreamHDL("Warning: Could not open %s for reading.\n" % (Filename), MSG_WARNING)
        return results
    else:
        _Fhdl.close()

    for line in open(Filename, 'r'):
        if len(line) == 1:
            results.append( (), )
        else:
            lineTuple = ()
            for eachValue in string.split(line[:-1], ','):
                value = eachValue.strip()
                try:
                    lineTuple += (int(value), )
                except ValueError:
                    try:
                        lineTuple += (float(value), )
                    except ValueError:
                        lineTuple += (value, )    
            results.append(lineTuple)
    return results

##################################### ConfigureLatencyBuckets ###################################
# Computes desired bucket spacing on min/max and set the ports      
#
def ConfigureLatencyBuckets(PortList, MinLatency, MaxLatency):
    bucketsUsed = 16
    extraBuckets = 1

    # The minm param default was determined from the 800us range to ensure no overlap
    # of the bucket values. The minb parameter of -13.8 corresponds to a 1us zero point.
    def ExpBuckets(mn, mx, bu = bucketsUsed - 3, xb = extraBuckets, minm = 0.05, minb = -13.8):
        if mn == 0:
            # If min latency is 0, set it to non zero value, because
            # we can't calculate log(0)
            mn = 10e-6
        lmn = log(mn)
        lmx = log(mx)
        m = (lmx - lmn) / float(bu)
        b = lmn - m * xb
        m = max(m, minm)
        b = max(b, minb)
        lb = ()
        for x in range(0, bu + xb * 2):
            y = exp(m * x + b)
            lb += (y, )
        return lb

    # The minm and minb are set to 1us values to ensure the linear range starts at 1us
    # and rises in at least 1us increments.
    def LinBuckets(mn, mx, bu = bucketsUsed - 3, xb = extraBuckets, minm = 1e-6, minb = 1e-6):
        lb = ()
        m = (mx - mn) / float(bu)
        b = mn - m * xb
        m = max(m, minm)
        b = max(b, minb)
        for x in range(0, bu + xb * 2):
            y = m * x + b
            lb += (y, )
        return lb

    def MidPointBuckets(mn, mx):
        mp = (mn + mx) / 2.0
        return LinBuckets(mp - 8E-6, mp + 8E-6, bucketsUsed - 1, 0)

    _Detailed = ['Buckets', 'set to']
    #if MinLatency == 0.0:
    #    OutputstreamHDL("Error: ConfigureLatencyBuckets was passed a zero for Minimum Latency.\n", MSG_ERROR)
    #    raise RaiseException
    #if MaxLatency == 0.0:
    #    OutputstreamHDL("Error: ConfigureLatencyBuckets was passed a zero for Maximum Latency.\n", MSG_ERROR)
    #    raise RaiseException

    latRange = MaxLatency - MinLatency
    if latRange < 16E-6:
        LatencyValues = MidPointBuckets(MinLatency, MaxLatency)
    elif latRange < 800E-6:
        LatencyValues = LinBuckets(MinLatency, MaxLatency)
    else:
        LatencyValues = ExpBuckets(MinLatency, MaxLatency)
            
    LatencyBuckets = ()
    for value in LatencyValues:
        LatencyBuckets += ( long(int(1E6 * round(value, 6))), )
        _Detailed.append("< %ss" % (Float2EngNotation(value, 3)))
    LatencyBuckets += ( long(MAXlatency), )
    _Detailed.append('MAX')
    WriteDetailedLog(_Detailed)

    for PortName in PortList:
        VCLtest("port.read('%s')" % (PortName))
        VCLtest("port.setLatencyBoundaries(%s)" % ( str(LatencyBuckets) ))
        VCLtest("port.write('%s')" % (PortName))
    return LatencyBuckets


##################################### Import_CardMap #####################################
#                    Name     Chassis      Cd Pt  Chan
def Import_CardMap(waveChassisStore):
    CardLocation = {}
    for eachChassisName in waveChassisStore.keys():
        for eachCardName in waveChassisStore[eachChassisName].keys():
            for eachPortName in waveChassisStore[eachChassisName][eachCardName].keys():
                port = waveChassisStore[eachChassisName][eachCardName][eachPortName]
                ccpTuple = ()
                ccpTuple += (str(eachChassisName),)
                ccpTuple += (int(port['CardID']),)
                ccpTuple += (int(port['PortID']),)
                if str(port['PortType']) in WiFiPortTypes:
                    # Channel can take on all kinds of funky values that are not
                    # int compatible.
                    ccpTuple += (port['Band'],)
                    try:
                        ccpTuple += (int(port['Channel']),)
                    except:
                        ccpTuple += (0,)
                    ccpTuple += (port['SecondaryChannelPlacement'],)
                if str(port['PortType']) == "8023":
                    ccpTuple += (str(port['Autonegotiation']),)
                    ccpTuple += (int(port['EthernetSpeed']),)
                    ccpTuple += (str(port['Duplex']),)
                portName = port['PortName']
                CardLocation[portName] = ccpTuple

    return CardLocation

##################################### Import_FlowInfo #####################################
# 
def Import_FlowInfo(waveMappingStore):
    if waveMappingStore[3] == 'One To One':
        Map = CreateFlows_Pairs
    else:
        OutputstreamHDL("Unable to understand the flow mapping of %s" % (waveMappingStore[2]), MSG_ERROR)
        Map = CreateFlows_Pairs

    if waveMappingStore[4].lower() == 'unidirectional':
        BiDir = False
    else:
        BiDir = True       
    Options  = waveMappingStore[5]
    
    return Map, BiDir, Options

##################################### FindPerFlowMAXrate #####################################
#
def FindPerFlowMAXrate(ClientDict, FlowDict, options, Framesize, Flow_PhyRate):
    _PortSpeed   = {}
    _PortFullDuplex  = {}
    _PortFlowCnt = {}
    _ClientPort  = {}

    #Figure out the Max frame rate for all the ports used
    for ClientName in ClientDict.keys():
        (ConnectState, PortName, ConnectCMD) = ClientDict[ClientName]
        if not _PortSpeed.has_key(PortName):
            VCLtest("port.read('%s')" % (PortName))
            _PortFullDuplex[PortName] = False
            if port.type == '8023':
                Frate = 1000000.0 * port.speed
                Technology = port.type
                if port.duplex in 'full':
                    _PortFullDuplex[PortName] = True
            elif port.type in WiFiPortTypes:
                Frate = 1000000.0 * float(Flow_PhyRate)
                if port.type == NportType:
                    Technology = '80211n'
                elif port.channel > 14:
                    Technology = '80211a'
                elif Flow_PhyRate in [1 , 2 , 5.5 , 11]:
                    Technology = '80211b'
                else:
                    Technology = '80211g'
                
            _PortSpeed[PortName] = TheroicalMAXpackets(Technology, options, Frate, Framesize)
            _PortFlowCnt[PortName] = 0

    #Figure out how many flows per port
    for FlowName in FlowDict.keys():
        (src_port, src_client, des_port, des_client) = FlowDict[FlowName]
        _PortFlowCnt[src_port] += 1
        if _PortFullDuplex[des_port] == False:
            _PortFlowCnt[des_port] += 1
        
    #Now that magic, pick the lower Speed/Cnt port
    LowestRate = MAXtxFrames
    for PortName in _PortSpeed.keys():
        if _PortFlowCnt[PortName] > 0:
            rate = _PortSpeed[PortName] / _PortFlowCnt[PortName]
            if LowestRate > rate:
                LowestRate = rate
    if LowestRate == MAXtxFrames:
        OutputstreamHDL("Error: WaveEngine.FindPerFlowMAXrate could not find a port with flows on it\n", MSG_ERROR)
        return 0.0
    return LowestRate

##################################### FindPerFlowrate #####################################
#
def FindPerFlowrate(FlowDict, ILOAD):
    #Figure out how many flows per port
    _PortFlowCnt = {}
    for FlowName in FlowDict.keys():
        (src_port, src_client, des_port, des_client) = FlowDict[FlowName]
        if _PortFlowCnt.has_key(src_port):
            _PortFlowCnt[src_port] += 1
        else:
            _PortFlowCnt[src_port] = 1
        
    return ILOAD / len (_PortFlowCnt)

##################################### get11nPhyRate #####################################
#
def get11nPhyRate(mcsIndex, guardInterval, channelBW):
    if guardInterval == 'short':
        Tsymbol = 3.6
    else:
        Tsymbol = 4.0

    if channelBW == 20:
        baseArray = [26, 52, 78, 104, 156, 208, 234, 260]
    else:
        baseArray = [54, 108, 162, 216, 324, 432, 486, 540]

    Ndbps = (baseArray[mcsIndex - (8 * (int(mcsIndex/8)))]) * (int(mcsIndex/8)+1)

    return Ndbps / Tsymbol

##################################### SUTtheoreticalThroughput #####################################
# Attempts to figure out what the theoretical Maximum throuput of a DUT/SUT
# Assumes that all flows run the same frame rate
#
def SUTtheoreticalThroughput(ClientDict, FlowDict, options, Framesize, Flow_PhyRate):
    _PortSpeed      = {}
    _PortFullDuplex  = {}
    _PortSrcFlowCnt = {}
    _PortDesFlowCnt = {}
    _ClientPort = {}

    #Figure out the Max frame rate for all the ports used
    for ClientName in ClientDict.keys():
        (ConnectState, PortName, ConnectCMD) = ClientDict[ClientName]
        #Use the first Port in roaming
        if isinstance(PortName, list):
            PortName = PortName[0]
        if not _PortSpeed.has_key(PortName):
            VCLtest("port.read('%s')" % (PortName))
            _PortFullDuplex[PortName] = False
            if port.type == '8023':
                Frate = 1000000.0 * port.speed
                Technology = port.type
                if port.duplex in 'full':
                    _PortFullDuplex[PortName] = True
            elif port.type in WiFiPortTypes:
                Frate = 1000000.0 * float(Flow_PhyRate)
                if port.type == NportType:
                    Technology = '80211n'
                elif port.channel > 14:
                    Technology = '80211a'
                elif Flow_PhyRate == 1 or Flow_PhyRate == 2 or Flow_PhyRate == 5.5 or Flow_PhyRate == 11:
                    Technology = '80211b'
                else:
                    Technology = '80211g'
               
            _PortSpeed[PortName] = TheroicalMAXpackets(Technology, options, Frate, Framesize)
            _PortSrcFlowCnt[PortName] = 0
            _PortDesFlowCnt[PortName] = 0

    #Figure out how many flows per port
    TotalFlows = len(FlowDict)
    for FlowName in FlowDict.keys():
        (src_port, src_client, des_port, des_client) = FlowDict[FlowName]
        _PortSrcFlowCnt[src_port] += 1
        _PortDesFlowCnt[des_port] += 1
    
    #Now that magic, pick the lowest Speed/Cnt port
    LowestRate = MAXtxFrames
    for PortName in _PortSpeed.keys():
        if _PortFullDuplex[PortName]:
            #Full duplex - check each direction separately
            if _PortSrcFlowCnt[PortName] > 0:
                rate = _PortSpeed[PortName] / _PortSrcFlowCnt[PortName]
                if LowestRate > rate:
                    LowestRate = rate
            if _PortDesFlowCnt[PortName] > 0:
                rate = _PortSpeed[PortName] / _PortDesFlowCnt[PortName]
                if LowestRate > rate:
                    LowestRate = rate
        else:
            #Half duplex - total both directions before checking
            TotalPortFlows = _PortSrcFlowCnt[PortName] + _PortDesFlowCnt[PortName]
            if TotalPortFlows > 0:
                rate = _PortSpeed[PortName] / TotalPortFlows
                if LowestRate > rate:
                    LowestRate = rate
            
    if LowestRate == MAXtxFrames:
        OutputstreamHDL("Error: WaveEngine.FindPerFlowMAXrate could not find a port with flows on it\n", MSG_ERROR)
        return 0.0    

    #Since all flows run teh same rate we can cumpute the DUT/SUT total rate
    return LowestRate * TotalFlows

##################################### ScanAPinformation #####################################
# Returns a table of information about he AP's BSSID, SSID, RSSI, and other information
#
def ScanAPinformation(ClientDict, Count=1):
    listofPortstoScan = []
    listofUsedBSSIDs  = []
    
    #Create a list of wireless ports to scan
    for ClientName in ClientDict.keys():
        (ConnectCompleteState, PortName, ConnectCompleteCMD) = ClientDict[ClientName]
        if ConnectCompleteCMD == 'ec':
            continue
        if not PortName in listofPortstoScan:
            listofPortstoScan.append(PortName)
        VCLtest("mc.read('%s')" % (ClientName))
        for eachBSSID in mc.getBssidList():
            eachKey = (PortName, MACaddress(eachBSSID).get())
            if not eachKey in listofUsedBSSIDs:
                listofUsedBSSIDs.append(eachKey)
    listofPortstoScan.sort()

    #Get the AP info
    ReturnedData = []
    for PortName in listofPortstoScan:
        VCLtest("port.read('%s')" % (PortName))
        for eachBSSID in port.getBssidList():
            eachKey = (PortName, MACaddress(eachBSSID).get())
            if eachKey in listofUsedBSSIDs:
                receivedRSSIval = port.getBssidRssi(eachBSSID)
                realRSSI = _getRealRSSI(receivedRSSIval)
                ReturnedData.append( (PortName, port.getChannel(), MACaddress(eachBSSID).get(), port.getBssidSsid(eachBSSID), realRSSI), )
    return ReturnedData

def _getRealRSSI(receivedRSSIval):
    #Per Document ID: 55A-SPC-0051, Rev 01, Negative RSSI numbers have the most significant bit set.
    rawRSSI = 0xFF & receivedRSSIval
    if rawRSSI > 128:
        realRSSI = 128 - rawRSSI
    else:
        realRSSI = rawRSSI
    
    return realRSSI
##################################### WriteAPinformation #####################################
# Returns a table of information about he AP's BSSID, SSID, RSSI, and other information
#
def WriteAPinformation(ClientDict, Time=0):
    """
    
    Write into RSSI_script the info Port Name     Channel     BSSID     SSID     
    RSSI of all the Port, BSSID combinations on which any of the clients in 
    ClientDict stays i.e., all the APs to which any of these clients connect to
    """
    global _RSSI_FileName
    global TimeScriptStartmS
    listofUsedBSSIDs  = []
    portToBssidsDict = {}
    usedPortBSSIDtuples = []
    #For each client, find the port, bssid 
    for ClientName in ClientDict.keys():
        (ConnectCompleteState, PortName, ConnectCompleteCMD) = ClientDict[ClientName]
        if ConnectCompleteCMD == 'ec':
            continue
        if isinstance(PortName, str):
            PortList = [PortName]
        elif isinstance(PortName, list):
            PortList = PortName
        VCLtest("mc.read('%s')" % (ClientName)) 
        mcBssidList = VCLtest("mc.getBssidList()")
        for prtName in PortList:
            if prtName not in portToBssidsDict:
                #Keep polling to get the bssidList, timeout if it takes more than 
                #2 seconds, why 2 seconds? picked it almost arbitrarily (or say, 
                #to keep timeout optimal)
                """
                Commenting this for VPR 6163. port.scanBssid is not required for
                port.getBssidList(), bssidList gets populated even with beacons.
                  
                VCLtest("port.read('%s')"%prtName)
                VCLtest("port.scanBssid('%s')"%prtName)
                #VPR 6379
                time.sleep(DELAY_FOR_SCAN_BSSID)
                VCLtest("port.write('%s')" % (prtName))
                """
                VCLtest("port.read('%s')"%prtName)
                timeStart = time.time()
                while True:
                    bssidList = VCLtest("port.getBssidList()")
                    if bssidList:
                        break
                    if time.time() - timeStart > 2:    #Bail out if it took more than 2 secs
                        break
                    VCLtest("port.read('%s')"%prtName)
                portToBssidsDict[prtName] = bssidList
            for eachBSSID in mcBssidList:
                if ((prtName, eachBSSID) not in usedPortBSSIDtuples) and \
                eachBSSID in portToBssidsDict[prtName]:
                    VCLtest("port.read('%s')" % (prtName))
                    eachKey = (prtName, int(VCLtest("port.getChannel()")),
                               MACaddress(eachBSSID).get(),
                               VCLtest("port.getBssidSsid('%s')"%eachBSSID), 
                               port.getBssidRssi(eachBSSID))    #VCL raises error for -ve values, where as a -ve rssi value is valid
                    listofUsedBSSIDs.append(eachKey)
                    usedPortBSSIDtuples.append((prtName, eachBSSID))

    #Get the AP info
    _Fhdl = None
    try:
        _Fhdl = open(_RSSI_FileName, 'a')
        for eachKey in listofUsedBSSIDs:
            _Fhdl.write("%.3f, %s, %d, %s, %s, %d\n" % \
                        (time.time() - TimeScriptStartmS, eachKey[0], 
                         eachKey[1], eachKey[2], eachKey[3], eachKey[4]))
        _Fhdl.close()
    except:
        if _Fhdl:
            _Fhdl.close()

def writeLoopBackRSSIinformation(flowDict):
    """
    Write the RSSI information of the clients sending the flows in Loopback test.
    """
    
    global _RSSI_FileName
    global TimeScriptStartmS
    transmitterReceiver = _getLoopbackTransmitterReceiver(flowDict)
    rssiInfo = {}
    for (transmitter, receiver) in transmitterReceiver:
        timeVal = time.time() - TimeScriptStartmS
        
        VCLtest("mc.read('%s')"%transmitter)
        portVal = VCLtest("mc.getCurrentPort()")
        
        VCLtest("port.read('%s')"%portVal)
        channelVal = VCLtest("port.getChannel()")
        
        bssid = VCLtest("mc.getMacAddress()")
        
        ssid = 'NA'
        
        VCLtest("clientStats.read('%s')"%receiver)
        receivedRSSIval = VCLtest("clientStats.rssiOfLast80211DataPacketReceived")
        rssiVal = _getRealRSSI(receivedRSSIval)
        rssiInfo[transmitter] = (timeVal, portVal, channelVal, bssid, ssid,
                                 rssiVal)
    _Fhdl = None
    try:
        _Fhdl = open(_RSSI_FileName, 'a')
        for (transmitter, receiver) in transmitterReceiver:
            (timeVal, portVal, channelVal, bssid, ssid, rssiVal) = rssiInfo[transmitter] 
            _Fhdl.write("%.3f, %s, %d, %s, %s, %d\n" % \
                        (timeVal, portVal, channelVal, bssid, ssid, rssiVal))
        _Fhdl.close()
    except:
        if _Fhdl:
            _Fhdl.close()    
    
    
def _getLoopbackTransmitterReceiver(flowDict):
    """
    
    """
    transmitterReceiver = []
    for flow in flowDict:
        srcPort, srcClient, destPort, destClient = flowDict[flow]
        transmitterReceiver.append((srcClient, destClient))
    
    #Remove redundants
    transmitterReceiver = list(set(transmitterReceiver))
    
    return transmitterReceiver


##################################### ReadAPinformation #####################################
# Returns a table of information about he AP's BSSID, SSID, RSSI, and other information
#
def ReadAPinformation(Filename = None):
    global _LoggingDirectoryPath
    if Filename == None:
        ScriptName = re.search("([.0-9a-zA-Z_-]+).py", sys._getframe(1).f_code.co_filename)
        Filename = os.path.join(_LoggingDirectoryPath, "RSSI_" + ScriptName.group(1) + ".csv")
    else:
        Filename  = os.path.join(_LoggingDirectoryPath, Filename)
    return ReadCSVFile(Filename)

##################################### TheoreticalThroughput Object #####################################
# Attempts to figure out what the theoretical Maximum throughput of a DUT/SUT.  Takes into account the AP
# and clients advertized rates, the number of clients on each AP, add different frames sizes.  Assumes
# that all flows have the same frame rate.  Create the object by passing the Client and Flow dictionaries.
#
# Methods:
#
#   QuerySystem()         - Reads information from the WT-90 to figure out the current negoitated info.
#                           This is a snapshot of the system and will take some time.  Must be called before
#                           computing rates.
#   
#   SetOptions()          - These are things that I can't find when I query the system.  Such as the 
#                           AP's RTS threshold.  Will add temporary code to work around VPRs.
#
#   ComputeBPS(FrameSize) - Computes the Theoretical Maximum bits per second the DUT/SUT should forward.
#                           If the length of the frame changed through the DUT/SUT, the algorithm will use
#                           the large of the two sizes in the calculations.  If frame size is not passed,
#                           it will use the flow frame size found during QuerySystem().  Do not pass 
#                           FrameSize if the flows have different sizes.
#
#   ComputeFPS(FrameSize) - Computes the Theoretical Maximum frames per second the DUT/SUT should forward.
#                           If frame size is not passed, it will use the flow frame size found during
#                           QuerySystem().  Do not pass FrameSize if the flows have different sizes 

class TheoreticalThroughput:
    def __init__(self, ClientDict, FlowDict):
        self.ClientDict = ClientDict
        self.FlowDict   = FlowDict
        self.RTSthreshold         = 2312
        self.PortClientTransmitting = {}
        self.ClientSpeed          = {}
        self.ClientSizeOffset     = {}
        self.ClientShortPreamble  = {}
        self.ClientShortSlotTime  = {}
        self.CachedPortType       = {}
        self.CachedPortFullDuplex = {}
        self.CachedPortChannel    = {}
        self.CachedPortBSSIDShortPreamble = {}
        self.CachedPortBSSIDShortSlotTime = {}
        self.CachedPortBSSID_CTSself      = {}
        self.FlowFrameSize = {}
        self.FlowTXSpeed   = {}

    def SetOptions(self, Text, Value):
        if Text.lower() == 'rtsthreshold':
            self.RTSthreshold = int(Value)

    def QuerySystem(self):
        self.PortClientTransmitting = {}
        self.ClientSpeed            = {}
        self.ClientSizeOffset       = {}
        self.ClientShortPreamble    = {}
        self.ClientShortSlotTime    = {}
        self.CachedPortType               = {}
        self.CachedPortFullDuplex         = {}
        self.CachedPortChannel            = {}
        self.CachedPortBSSIDShortPreamble = {}
        self.CachedPortBSSIDShortSlotTime = {}
        self.CachedPortBSSID_CTSself      = {}
        self.FlowFrameSize    = {}
        self.FlowTXSpeed      = {}
        _CachedPortSpeed      = {}
        _CachedPortBSSIDRates = {}

        #Figure out the speed of each client 
        for ClientName in self.ClientDict.keys():
            (ConnectState, PortName, ConnectCMD) = self.ClientDict[ClientName]
            MyBSSID = MACaddress()
            #Use the first Port in roaming
            if isinstance(PortName, list):
                PortName = PortName[0]
            self.CachedPortFullDuplex[PortName] =  False
            if not self.CachedPortType.has_key(PortName):
                VCLtest("port.read('%s')" % (PortName)) 
                self.CachedPortType[PortName]   = port.type
                if port.type == '8023':
                    _CachedPortSpeed[PortName]  = port.speed * 1000000.0
                    if port.duplex in 'full':
                        self.CachedPortFullDuplex[PortName] =  True
                elif port.type in WiFiPortTypes:
                    _CachedPortBSSIDRates[PortName]         = {}
                    self.CachedPortBSSIDShortPreamble[PortName] = {}
                    self.CachedPortBSSIDShortSlotTime[PortName] = {}
                    self.CachedPortBSSID_CTSself[PortName]      = {}
                    for eachBSSID in port.getBssidList():
                        MyBSSID.set(eachBSSID)
                        _CachedPortBSSIDRates[PortName][MyBSSID.get()]         =   port.getBssidSupportedRates(eachBSSID)
                        self.CachedPortBSSIDShortPreamble[PortName][MyBSSID.get()] = ( port.getBssidCapabilities(eachBSSID) & 0x0020 > 0 )
                        self.CachedPortBSSIDShortSlotTime[PortName][MyBSSID.get()] = ( port.getBssidCapabilities(eachBSSID) & 0x0400 > 0 )
                        self.CachedPortBSSID_CTSself[PortName][MyBSSID.get()]      = ( port.getBssidFlags(eachBSSID) & 0x0020 > 0 )
                    self.CachedPortChannel[PortName] = port.channel
                    
            if self.CachedPortType[PortName] == '8023':
                self.ClientSpeed[ClientName]    = _CachedPortSpeed[PortName]
                self.ClientSizeOffset[ClientName] = 0
            elif self.CachedPortType[PortName] in WiFiPortTypes:
                VCLtest("mc.read('%s')" % (ClientName))
                if mc.getBssidList() == ():
                    MyBSSID.set('00:00:00:00:00:00')
                else:
                    MyBSSID.set(mc.getBssidList()[0])
                if mc.getBOnlyMode() == 'on':
                    MyRates = ('1', '2', '5.5', '11')
                else:
                    MyRates = ('1', '2', '5.5', '11', '6', '12', '24', '36', '9', '18', '48', '54')
                HighestRate = 0.0
                if _CachedPortBSSIDRates[PortName].has_key(MyBSSID.get()):
                    for eachRateAdv in _CachedPortBSSIDRates[PortName][MyBSSID.get()]:
                        # Strip off any trailing text in the advertised rates so we are comparing numbers only
                        eachRate = eachRateAdv.split('(')[0]
                        if eachRate in MyRates:
                            if float(eachRate) > HighestRate:
                                HighestRate =  float(eachRate)
                else:
                    # if we can't find the advertised BSSID rate for the port, set it to the highest rate
                    HighestRate = int(MyRates[-1])
                self.ClientSpeed[ClientName] = HighestRate * 1000000.0
                Encryption = mc.getEncryptionMethod()
                #                          802.11 header + Security header
                if "wep" in Encryption.lower():
                    self.ClientSizeOffset[ClientName] = 18 + 8
                elif "tkip" in Encryption.lower():
                    self.ClientSizeOffset[ClientName] = 18 + 20
                elif "ccmp" in Encryption.lower():
                    self.ClientSizeOffset[ClientName] = 18 + 16
                else:
                    self.ClientSizeOffset[ClientName] = 18
                #Add 2 bytes if the client has WME enabled
                if 'on' in  mc.getWmeEnabled():
                    self.ClientSizeOffset[ClientName] += 2

                #Options for long/short preambles and slot times
                self.ClientShortPreamble[ClientName] = False
                if _CachedPortBSSIDRates[PortName].has_key(MyBSSID.get()):
                    self.ClientShortPreamble[ClientName] = self.CachedPortBSSIDShortPreamble[PortName][MyBSSID.get()] and ('on' in mc.getShortPreamble() )
                self.ClientShortSlotTime[ClientName] = False
                if _CachedPortBSSIDRates[PortName].has_key(MyBSSID.get()):
                    #VPR 4335 - No set/get method for this, 2.3 firmware is always off
                    self.ClientShortSlotTime[ClientName] = self.CachedPortBSSIDShortSlotTime[PortName][MyBSSID.get()] and True 

                #Figure out RTSthreshold
                #VPR 4343 - mc.getRtsThreshold() is always zero
                #print ClientName, mc.getRtsThreshold()
                
        for FlowName in self.FlowDict.keys():
            (src_port, src_client, des_port, des_client) = self.FlowDict[FlowName]
            if FlowName in flow.getNames():
                VCLtest("flow.read('%s')"  % (FlowName))
            elif FlowName in biflow.getNames():
                VCLtest("biflow.read('%s')"  % (FlowName))
            else:
                OutputstreamHDL("Error: WaveEngine.TheoreticalThroughput could not read flow: %s\n" % (FlowName), MSG_ERROR)                                
                return
            self.FlowFrameSize[FlowName] = flow.getFrameSize()
            if self.CachedPortType[src_port] in WiFiPortTypes: 
                self.FlowTXSpeed[FlowName]   = flow.getPhyRate() * 1000000.0
            # Need to know how many clients are transmitting on a 802.11 port
            for eachPort in [src_port, des_port]:
                if not self.PortClientTransmitting.has_key(eachPort):
                    self.PortClientTransmitting[eachPort] = []
            if not src_client in self.PortClientTransmitting[src_port]:
                self.PortClientTransmitting[src_port].append(src_client)
            if self.CachedPortType[des_port] in WiFiPortTypes:
                if not 'AP' in self.PortClientTransmitting[des_port]:
                    self.PortClientTransmitting[des_port].append('AP')

            #FIXME - Detech if the flow has QOS
            #VPR 4340 - status broken
            #VCLtest("enetQos.readFlow()")    
            #print FlowName, VCLtest("enetQos.getPriorityTag()"), VCLtest("enetQos.getTgaPriority()"), VCLtest("enetQos.getUserPriority()")


    def ComputeFPS(self, FrameSize = None):
        _PortTimeSrc = {}
        _PortTimeDes = {}
        _SrcPortFlowCount = {}
        _DesPortFlowCount = {}
        for eachPort in self.CachedPortType.keys():
            _PortTimeSrc[eachPort] = 0.0
            _PortTimeDes[eachPort] = 0.0
            _SrcPortFlowCount[eachPort] = 0
            _DesPortFlowCount[eachPort] = 0
            
        #Compute the time to cycle through the flows
        for FlowName in self.FlowDict.keys():
            (src_port, src_client, des_port, des_client) = self.FlowDict[FlowName]
            _SrcPortFlowCount[src_port] += 1
            _DesPortFlowCount[des_port] += 1

            ActualFrameSize = self.FlowFrameSize[FlowName]
            if FrameSize != None:
                ActualFrameSize = FrameSize

            #FIXME - How to include CTS to Self VPR 4344
            #FIXME - RTS/CTS support per client instead of globally

            #Do the sorcres first
            if self.CachedPortType[src_port] == '8023':
                _PortTimeSrc[src_port] += self.ComputeTheroical8023(self.ClientSpeed[src_client], ActualFrameSize)
            elif self.CachedPortType[src_port] in WiFiPortTypes:
                if self.CachedPortChannel[src_port] > 14:
                    _PortTimeSrc[src_port] += self.ComputeTheroical80211a(self.FlowTXSpeed[FlowName], ActualFrameSize + self.ClientSizeOffset[src_client], len(self.PortClientTransmitting[src_port]))
                elif self.FlowTXSpeed[FlowName] == 1000000.0 or self.FlowTXSpeed[FlowName] ==  2000000.0 or \
                     self.FlowTXSpeed[FlowName] == 5500000.0 or self.FlowTXSpeed[FlowName] == 11000000.0:
                    _PortTimeSrc[src_port] += self.ComputeTheroical80211b(self.FlowTXSpeed[FlowName], ActualFrameSize + self.ClientSizeOffset[src_client], len(self.PortClientTransmitting[src_port]), self.ClientShortPreamble[src_client])
                else:
                    _PortTimeSrc[src_port] += self.ComputeTheroical80211g(self.FlowTXSpeed[FlowName], ActualFrameSize + self.ClientSizeOffset[src_client], len(self.PortClientTransmitting[src_port]), self.ClientShortSlotTime[src_client])
            
            #Now the destinations
            if self.CachedPortType[des_port] == '8023':
                _PortTimeDes[des_port] += self.ComputeTheroical8023(self.ClientSpeed[des_client], ActualFrameSize)
            elif self.CachedPortType[des_port] in WiFiPortTypes:
                if self.CachedPortChannel[des_port] > 14:
                    _PortTimeDes[des_port] += self.ComputeTheroical80211a(self.ClientSpeed[des_client], ActualFrameSize + self.ClientSizeOffset[des_client], len(self.PortClientTransmitting[des_port]))
                elif self.ClientSpeed[des_client] == 1000000.0 or self.ClientSpeed[des_client] ==  2000000.0 or \
                     self.ClientSpeed[des_client] == 5500000.0 or self.ClientSpeed[des_client] == 11000000.0:
                    _PortTimeDes[des_port] += self.ComputeTheroical80211b(self.ClientSpeed[des_client], ActualFrameSize + self.ClientSizeOffset[des_client], len(self.PortClientTransmitting[des_port]), self.ClientShortPreamble[des_client])
                else:
                    _PortTimeDes[des_port] += self.ComputeTheroical80211g(self.ClientSpeed[des_client], ActualFrameSize + self.ClientSizeOffset[des_client], len(self.PortClientTransmitting[des_port]), self.ClientShortSlotTime[des_client])

        #Figure out who is the slowest
        LongestTime  = 0.0
        for eachPort in self.CachedPortType.keys():
            if self.CachedPortFullDuplex[eachPort]:
                if _PortTimeSrc[eachPort] > LongestTime:
                    LongestTime  = _PortTimeSrc[eachPort]
                if _PortTimeDes[eachPort] > LongestTime:
                    LongestTime  = _PortTimeDes[eachPort]
            else:
                if _PortTimeSrc[eachPort] + _PortTimeDes[eachPort] > LongestTime:
                    LongestTime = _PortTimeSrc[eachPort] + _PortTimeDes[eachPort]

        if LongestTime == 0.0:
            OutputstreamHDL("Error: WaveEngine.TheoreticalThroughput could not find a port with flows on it\n", MSG_ERROR)
            return LongestTime

        #convert Time into Frames/second
        return float(len(self.FlowDict)) / LongestTime

    def ComputeBPS(self, FrameSize = None):
        #FIXME - source or destination bits?
        #Until I can decide, lets pick the bigger frame size.
        TotalBytes = 0
        TotalFlows = 0
        for FlowName in self.FlowDict.keys():
            (src_port, src_client, des_port, des_client) = self.FlowDict[FlowName]
            TotalFlows += 1
            if FrameSize == None:
                TotalBytes += self.FlowFrameSize[FlowName]
            else:
                TotalBytes += FrameSize
            if self.ClientSizeOffset[src_client] > self.ClientSizeOffset[des_client]:
                TotalBytes += self.ClientSizeOffset[src_client]
            else:
                TotalBytes += self.ClientSizeOffset[des_client]

        return float(TotalBytes * 8) * self.ComputeFPS(FrameSize) / float(TotalFlows)

    def PrintDebug(self):

        ReturnedString = "----- Port Info -----\n"
        Portlist = self.CachedPortType.keys()
        Portlist.sort()
        for eachPort in Portlist:
            ReturnedString += "  %s: Type=%5s FullDuplex=%5s Active=%s\n" % (eachPort, self.CachedPortType[eachPort], self.CachedPortFullDuplex[eachPort], self.PortClientTransmitting[eachPort])
            
        ReturnedString += "\n----- Client Info -----\n"
        ClientList = self.ClientSpeed.keys()
        ClientList.sort()
        for eachClient in ClientList:
            (ConnectState, PortName, ConnectCMD) = self.ClientDict[eachClient]
            Technology = self.CachedPortType[PortName]
            if Technology in WiFiPortTypes:
                if Technology == NportType:
                    #This case is here just for completeness, if 'n' type, type 
                    #already is 80211n, don't need to add 'n'
                    pass
                elif self.CachedPortChannel[PortName] > 14:
                    Technology += "a"
                elif self.ClientSpeed[eachClient] == 1000000.0 or self.ClientSpeed[eachClient] ==  2000000.0 or \
                     self.ClientSpeed[eachClient] == 5500000.0 or self.ClientSpeed[eachClient] == 11000000.0:
                    Technology += "b"
                    if self.ClientShortPreamble[eachClient]:
                        Technology += " Short Preamble"
                else:
                    Technology += "g"
                    if self.ClientShortSlotTime[eachClient]:
                        Technology += " Short SlotTime"
                         
            ReturnedString += "  %s: %sbps, %s, Frame Size +%d bytes\n" % (eachClient, Float2EngNotation(self.ClientSpeed[eachClient] , 3), Technology, self.ClientSizeOffset[eachClient])
        
        ReturnedString += "\n----- Options -----\n"
        ReturnedString += "RTS threshold %d bytes\n" % self.RTSthreshold
        return ReturnedString

    def ComputeTheroical8023(self, BitRate, FrameSize):
        IFG = 96
        preamble = 64
        return  ( preamble + 8 * FrameSize + IFG ) / BitRate
        
    def ComputeTheroical80211a(self, BitRate, FrameSize, ClientCount):
        SIFS = EngNotation2Int("16u")
        DIFS = EngNotation2Int("34u")
        MeanRandomBackoff = EngNotation2Int("67.5u")
        Ndbps = (BitRate / 1000000.0 ) * 4
        Nbits = FrameSize * 8
        Tmac  = int((Nbits + 22 + Ndbps - 1) / Ndbps) * 0.000004
        Tplcp = EngNotation2Int("20u")
        Ttxframe_DATA = Tplcp + Tmac
        if   BitRate < EngNotation2Int("11M"):
            Ttxframe_ACK = EngNotation2Int("44u")
        elif BitRate > EngNotation2Int("20M"):
            Ttxframe_ACK = EngNotation2Int("28u")
        else:
            Ttxframe_ACK = EngNotation2Int("32u")
        return Ttxframe_DATA + SIFS + Ttxframe_ACK + DIFS + MeanRandomBackoff/ClientCount
       
    def ComputeTheroical80211b(self, BitRate, FrameSize, ClientCount, ShortPreamble):
        SIFS = EngNotation2Int("10u")
        DIFS = EngNotation2Int("50u")
        MeanRandomBackoff = EngNotation2Int("310u")
        Nbits = FrameSize * 8
        Tmac  = Nbits / BitRate
        if ShortPreamble:
            Tplcp = EngNotation2Int("96u")
        else: 
            Tplcp = EngNotation2Int("192u")
        Ttxframe_DATA = Tplcp + Tmac
        Ttxframe_ACK  = Tplcp + ( 112 / BitRate )

        RTSCTStime = 0.0
        if FrameSize > self.RTSthreshold:
            RTSCTStime = ((20+14)*8)/BitRate + Tplcp
                    
        return RTSCTStime + Ttxframe_DATA + SIFS + Ttxframe_ACK + DIFS + MeanRandomBackoff/ClientCount
    
    def ComputeTheroical80211g(self, BitRate, FrameSize, ClientCount, SlotTime, CTS2self=False):
        SIFS = EngNotation2Int("16u")
        if SlotTime:
            MeanRandomBackoff = EngNotation2Int("67.5u")
            DIFS = EngNotation2Int("34u")
        else: 
            MeanRandomBackoff = EngNotation2Int("150u")
            DIFS = EngNotation2Int("50u")

        Ndbps = (BitRate / 1000000.0 ) * 4
        Nbits = FrameSize * 8
        Tmac  = int((Nbits + 22 + Ndbps - 1) / Ndbps) * 0.000004
        Tplcp = EngNotation2Int("20u")
        Ttxframe_DATA = Tplcp + Tmac
        if   BitRate < EngNotation2Int("11M"):
            Ttxframe_ACK = EngNotation2Int("44u")
        elif BitRate > EngNotation2Int("20M"):
            Ttxframe_ACK = EngNotation2Int("28u")
        else:
            Ttxframe_ACK = EngNotation2Int("32u")

        #Can not have both CTS2self AND RTS/CTS Handshake 
        RTSCTStime   = 0.0
        if CTS2self:
            RTSCTStime = Tplcp + int((    14 *8 + 22 + Ndbps - 1) / Ndbps)* 0.000004 + SIFS
        elif FrameSize > self.RTSthreshold:
            RTSCTStime = Tplcp + int(((20+14)*8 + 22 + Ndbps - 1) / Ndbps)* 0.000004 + 2*SIFS

        return RTSCTStime + Ttxframe_DATA + SIFS + Ttxframe_ACK + DIFS + MeanRandomBackoff/ClientCount


##################################### P2Pcommunications Object #####################################
# This is a quick and dirty way of multiple python scripts on either the same machine or different
# machines to communicate signalling.  The underlying mechanism uses UDP broadcast sockets.
# 
# Parameters:
#
#   IntanceNumber         - Used to filter out commucnications from other tests.  Every instance that
#                           is part of this test must have the same number.  IntanceNumber is a 32 bit
#                           unsigned integer.
#
#   PortNumber            - Optional.  Sets the UDP port number to broadcast on.  Default is 8080
#
# Methods:
#
#   Shutdown()            - Closes the UDP sockets and threads.  MUST be called before the script exits.
#   
#   getTotalHosts()       - Returns the count of instances that share your IntanceNumber.  Returns
#                           1 if you are alone.
#
#   setReady(value)       - Announces to all other systems that you are ready to start tranmitting.
#                           Set value to False to say NotReady (at the end of the test duration).
#                           If value is omitted, then default it True
#
#   getAllReady(Blocking) - Returns True if all instances that share your IntanceNumber have announced
#                           setReady.  If Blocking is set to True, then the function will wait until
#                           all instances are ready before returning.  Make sure you announce that you
#                           are ready before Blocking.  If Blocking is omitted, then default it False.
#
class P2Pcommunications:
    # How to pack the bytes into the message
    def encodeHeader(self, IntanceNumber, HostIdentity, MessageType, MessageValue=0):
        return struct.pack('>LLHH', IntanceNumber, HostIdentity, MessageType, MessageValue)

    # How to unpack the bytes into the message
    def decodeHeader(self, data):
        IntanceNumber = 0
        HostIdentity  = 0
        MessageType   = 0
        MessageValue  = 0
        if len(data) >= 12 :
            (IntanceNumber, HostIdentity, MessageType, MessageValue) = struct.unpack('>LLHH', data[:12])
        return (IntanceNumber, HostIdentity, MessageType, MessageValue)
    
    # Process to handle the transmitting
    class TXthread(threading.Thread):
        def __init__(self, root, BroadcastAddress, Portnumber, BroadcastTime = 1.0):
            self.Root = root
            self.BroadcastAddress   = BroadcastAddress
            self.portnumber = Portnumber
            self.BroadcastTime = BroadcastTime
            self.ThreadName = 'IPCtran'
            self.ThreadID   = None #threading.currentThread()
            self.ThreadCount= 0
            self.quit       = 0
            threading.Thread.__init__(self)
            self.MyHostname    = socket.gethostname()
        
        def run(self):
            self.ThreadID   = threading.currentThread()
            self.server = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self.server.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
            while not self.quit:
                data = self.Root.encodeHeader(self.Root.IntanceNumber, self.Root.IdentityNumber, self.Root.IPCmessage_Broadcast)
                try:
                    # Heartbeat
                    self.server.sendto(data, (self.BroadcastAddress, self.portnumber) )
                except socket.error:
                    pass
                self.ThreadCount = 0xFFFF & (self.ThreadCount+1)
                time.sleep(self.BroadcastTime)
            self.server.close()

        def sendReady(self, value=True):
            if self.quit:
                return False
            if value:
                data = self.Root.encodeHeader(self.Root.IntanceNumber, self.Root.IdentityNumber, self.Root.IPCmessage_Ready, 0xFFFF)
            else:
                data = self.Root.encodeHeader(self.Root.IntanceNumber, self.Root.IdentityNumber, self.Root.IPCmessage_Ready, 0x0000)
            try:
                self.server.sendto(data, (self.BroadcastAddress, self.portnumber) )
                returnValue = True
            except socket.error:
                returnValue = False
            return returnValue
            
        def terminate(self):
            self.quit = 1
    
    # Process to hand the reciever
    class RXthread(threading.Thread):
        def __init__(self, root, Portnumber):
            self.Root = root
            self.portnumber = Portnumber
            self.ThreadName = 'IPCrecv'
            self.ThreadID   = None #threading.currentThread()
            self.ThreadCount= 0
            self.quit       = 0
            threading.Thread.__init__(self)
        
        def run(self):
            self.ThreadID   = threading.currentThread()
            self.server = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self.server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.server.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
            self.server.bind(('0.0.0.0', self.portnumber))
            while not self.quit:
                RecvAddress = None
                while RecvAddress == None:
                    try:
                        recvData, RecvAddress = self.server.recvfrom(8192)
                    except socket.error:
                        RecvAddress = None
                self.ThreadCount = 0xFFFF & (self.ThreadCount+1)
                (IntanceNumber, HostIdentity, MessageType, MessageValue) = self.Root.decodeHeader(recvData)
                if IntanceNumber != self.Root.IntanceNumber:
                    #Ignore messages that don't belong to us
                    continue
                
                self.Root.KnownPeersMutex.acquire()
                if self.Root.KnownPeers.has_key(HostIdentity):
                    LastTime, Status = self.Root.KnownPeers[HostIdentity]
                else:
                    Status = None
                if MessageType == self.Root.IPCmessage_Broadcast:
                     self.Root.KnownPeers[HostIdentity] = (time.time(), Status)
                elif MessageType == self.Root.IPCmessage_Ready:
                     self.Root.KnownPeers[HostIdentity] = (time.time(), MessageValue)
                self.Root.KnownPeersMutex.release()
            self.server.close()
            
        def terminate(self):
            self.quit = 1

    def __init__(self, IntanceNumber, PortNumber=8080):
        # These parameters mat be changed
        self.IdentityAgingTime     = 10.0
        self.IdentityBroadcastTime =  1.0
        # MessageType Constants
        self.IPCmessage_Broadcast    = 0x0000
        self.IPCmessage_Ready        = 0x0001

        self.IdentityNumber    = id(self)
        try:
            self.IntanceNumber = 0xFFFFFFFF & int(IntanceNumber)
        except:
            self.IntanceNumber = 0xFFFFFFFF & hash(IntanceNumber)
        self.KnownPeers      = {}
        self.KnownPeersMutex = threading.Lock()
        self.TXthread = P2Pcommunications.TXthread(self, '255.255.255.255', PortNumber, self.IdentityBroadcastTime)
        self.TXthread.start()
        self.RXthread = P2Pcommunications.RXthread(self, PortNumber)
        self.RXthread.start()

    def Shutdown(self):
        self.RXthread.terminate()
        self.RXthread.join()
        self.TXthread.terminate()
        self.TXthread.join()

    def getTotalHosts(self):
        # Prune the list only when I care
        self.KnownPeersMutex.acquire()
        for eachKey in self.KnownPeers.keys():
            if self.KnownPeers[eachKey][0] + self.IdentityAgingTime < time.time():
                del self.KnownPeers[eachKey]
        n = len(self.KnownPeers)
        self.KnownPeersMutex.release()
        return n

    def setReady(self, value=True):
        return self.TXthread.sendReady(value)

    def getListOfHosts(self):
        self.KnownPeersMutex.acquire()
        TheList = self.KnownPeers.keys()
        TheList.sort()
        self.KnownPeersMutex.release()
        return TheList

    def getHostStatus(self, HostID):
        self.KnownPeersMutex.acquire()
        if self.KnownPeers.has_key(HostID):
            TheInfo = self.KnownPeers[HostID]
        else:
            TheInfo = None
        self.KnownPeersMutex.release()
        return TheInfo
            
    
    def getAllReady(self, Blocking=False):
        while True:
            allReady = True
            self.KnownPeersMutex.acquire()
            for eachKey in self.KnownPeers.keys():
                if self.KnownPeers[eachKey][0] + self.IdentityAgingTime < time.time():
                    del self.KnownPeers[eachKey]
                elif self.KnownPeers[eachKey][1] != 0xFFFF:
                    allReady = False
            self.KnownPeersMutex.release()        
            if not Blocking or allReady:
                break
            time.sleep(0.01)
            Check4UserEscape()
        return allReady
