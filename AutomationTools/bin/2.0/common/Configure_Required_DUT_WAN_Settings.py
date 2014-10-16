#!/usr/bin/env python
import os, sys
import pexpect
import time
from optparse import OptionParser
def Get_Required_info(setCrWAN=False,l3mode=None,debug=False):

    parameters = []

    if not setCrWAN:
        if not l3mode :
            protocol = os.getenv('U_CUSTOM_REQUIRED_PROTOCOL', 'IPOE') 
        else :
            protocol = l3mode
        linemode = os.getenv('U_CUSTOM_REQUIRED_LINEMODE', 'ETH')
        isBonding = os.getenv('U_CUSTOM_REQUIRED_ISBONDING', '0')
        isTagged = os.getenv('U_CUSTOM_REQUIRED_ISTAGGED', '0') 

    else:
        linemode = os.getenv('U_CUSTOM_CURRENT_WAN_TYPE_LINEMODE', 'ETH') 
        isBonding = os.getenv('U_CUSTOM_CURRENT_WAN_TYPE_ISBONDING', '0')
        isTagged = os.getenv('U_CUSTOM_CURRENT_WAN_TYPE_ISTAGGED', '0') 
        protocol = os.getenv('U_CUSTOM_CURRENT_WAN_TYPE_PROTOCOL', 'IPOE')

    linemode = linemode.upper()
    protocol = protocol.upper()
    isBonding = str(isBonding).lower()
    isTagged = str(isTagged).lower()
    if isBonding in ['0', 'false'] :
        isBonding = 0
    if isTagged in ['0', 'false']:
        isTagged = 0
    _lm = ' -l ' + linemode
    _pr = ' -p ' + protocol
    parameters.append(_lm)
    parameters.append(_pr)
    #isTagged = 1
    if isTagged:
        parameters.append(" -t '1' ")
    if isBonding:
        parameters.append(' -b ')
    print 'So the args is :%s' % parameters
    return parameters
#run (command, timeout=-1, withexitstatus=False, events=None, extra_args=None, logfile=None, cwd=None, env=None)
#python $U_PATH_TOOLS/common/swapWANLink.py -l 'VDSL' -p 'PPPOE'    

def main():
    """
    This script is used to configure required DUT WAN settings that as Jenkins specified
    """
    usage = "usage not ready yet \n"
    
    parser = OptionParser(usage=usage)
    
    
    parser.add_option("-c", "--current", dest="setCrWan", action='store_true', default=False,
                            help="Set current wan mode.")
    
    parser.add_option("-l", "--l3mode", dest="l3mode",
                            help="Set Layer 3 wan mode.")

    (options, args) = parser.parse_args()

    if options.setCrWan:
        print 'Set current WAN mode!' 
        
    if options.l3mode:
        print 'Set Layer 3 wan mode!'
        print 'l3mode : ' , options.l3mode
    
    parameters = Get_Required_info(setCrWAN=options.setCrWan , l3mode=options.l3mode)
    Tool_PATH = os.getenv('U_PATH_TOOLS', '/root/automation/tools/2.0')
    cmd = 'python ' + Tool_PATH + '/common/swapWANLink.py'
    for cmd_arg in parameters:
        cmd += cmd_arg
    print 'So the cmd is ====> %s' % cmd
    timeStart = time.time()
    swapOutput, swapStatus = pexpect.run(cmd, withexitstatus=True, timeout=1800, logfile=sys.stdout)
    timeEnd = time.time()
    timeSpend = timeEnd - timeStart
    timeH, timeS = divmod(timeSpend, 60)
    print 'The configure used %dm and %ds result is: %s' % (int(timeH), int(round(timeS)), swapStatus)
    if swapStatus == 0:
        print 'Succeed to configure DUT WAN settings'
        exit(0)
    else :
        print 'AT_ERROR : configure DUT WAN settings failed.'
        exit(1)

if __name__ == '__main__':
    DUT_Type = os.getenv('U_DUT_TYPE', 'UNKNOWN')
    print 'DUT_Type='+DUT_Type
    if DUT_Type == 'WECB':
        print 'U_DUT_TYPE == WECB,No need Config WAN setting!'
        exit(0)
    elif DUT_Type == 'TelusWecb3000':
        print 'U_DUT_TYPE == TelusWecb3000,No need Config WAN setting!'
        exit(0)
    elif DUT_Type == 'ComcastWecb3000':
        print 'U_DUT_TYPE == ComcastWecb3000,No need Config WAN setting!'
    elif DUT_Type == 'VerizonWecb3000':
        print 'U_DUT_TYPE == VerizonWecb3000,No need Config WAN setting!'
        exit(0)
    elif DUT_Type == 'NcsWecb3000':
        print 'U_DUT_TYPE == NcsWecb3000,No need Config WAN setting!'
        exit(0)
    main()

